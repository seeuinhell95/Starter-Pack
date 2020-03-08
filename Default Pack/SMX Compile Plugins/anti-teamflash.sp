#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <dhooks>

#pragma newdecls required

enum
{
	DSPEffect_FlashMuffleLong = 134,
	DSPEffect_FlashMuffleMedium = 135,
	DSPEffect_FlashMuffleShort = 136
};

Handle hDetonate; 
Handle hBlind;
Handle hSetPlayerDSP;
Handle hCreateInterface;

ConVar hTeamFlash;
ConVar hFlashDeafen;
ConVar hFlashSpec;
ConVar hFlashDeafenOwner;
ConVar hFlashDeafenTeam;

int g_iTeam = -1;
int g_iThrower = -1;

public Plugin myinfo =
{
	name		=	"[CSGO] Anti Team Flash",
	author		=	"Dr!fter | Edited: somebody.",
	description	=	"Anti Team Flash",
	version		=	"1.0",
	url			=	"http://sourcemod.net"
};

public void OnPluginStart() 
{
	hTeamFlash = CreateConVar("sm_flash_team", "0", "Whether to flash teammates or not");
	hFlashDeafen = CreateConVar("sm_flash_deafen", "1", "Whether to \"deafen\" when a flash goes off");
	hFlashDeafenOwner = CreateConVar("sm_flash_deafen_owner", "1", "Whether to \"deafen\" the thrower of the flash (ignored if sm_flash_deafen is set to 0)");
	hFlashDeafenTeam = CreateConVar("sm_flash_deafen_team", "1", "Whether to \"deafen\" the throwers team (ignored if sm_flash_deafen is set to 0)");
	hFlashSpec = CreateConVar("sm_flash_specs", "1", "Whether to flash spectators or not");

	AutoExecConfig(true, "anti_teamflash");

	Handle pGameConfig = LoadGameConfigFile("anti-teamflash.games");

	if(pGameConfig == INVALID_HANDLE)
	{
		SetFailState("Failed to load anti-teamflash.games.txt gamedata.");
	}

	int offset = GameConfGetOffset(pGameConfig, "Detonate");

	if(offset == -1)
	{
		SetFailState("Failed to get Detonate offset");
	}

	hDetonate = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, Flash_Detonate);

	offset = GameConfGetOffset(pGameConfig, "Blind");

	if(offset == -1)
	{
		SetFailState("Failed to get Blind offset");
	}

	hBlind = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, Player_Blind);
	DHookAddParam(hBlind, HookParamType_Float);
	DHookAddParam(hBlind, HookParamType_Float);
	DHookAddParam(hBlind, HookParamType_Float);

	StartPrepSDKCall(SDKCall_Static);

	if(!PrepSDKCall_SetFromConf(pGameConfig, SDKConf_Signature, "CreateInterface"))
	{
		SetFailState("Failed to get CreateInterface signature");
	}

	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hCreateInterface = EndPrepSDKCall();

	char szEngineSoundInterface[] = "IEngineSoundServer003";

	Address pEngineSoundInterface = SDKCall(hCreateInterface, szEngineSoundInterface, 0);
	delete hCreateInterface;

	if(!pEngineSoundInterface)
	{
		SetFailState("Failed to get engine sound interface");
	}

	offset = GameConfGetOffset(pGameConfig, "SetPlayerDSP");

	if(offset == -1)
	{
		SetFailState("Failed to get SetPlayerDSP offset");
	}

	hSetPlayerDSP = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, Enginesound_SetPlayerDSP);
	DHookAddParam(hSetPlayerDSP, HookParamType_ObjectPtr);
	DHookAddParam(hSetPlayerDSP, HookParamType_Int);
	DHookAddParam(hSetPlayerDSP, HookParamType_Bool);
	DHookRaw(hSetPlayerDSP, false, pEngineSoundInterface);

	delete pGameConfig;
}

public void OnClientPutInServer(int client)
{
	DHookEntity(hBlind, false, client);
}

public MRESReturn Enginesound_SetPlayerDSP(Handle hParams)
{	
	int m_Size = DHookGetParamObjectPtrVar(hParams, 1, 20, ObjectValueType_Int);

	if(m_Size != 1)
		return MRES_Ignored;

	int effect = DHookGetParam(hParams, 2);

	if(effect == DSPEffect_FlashMuffleLong || effect == DSPEffect_FlashMuffleMedium || effect == DSPEffect_FlashMuffleShort)
	{
		bool bDeafen = hFlashDeafen.BoolValue;
		bool bDeafenTeam = hFlashDeafenTeam.BoolValue;
		bool bDeafenOwner = hFlashDeafenOwner.BoolValue;

		if(bDeafen && bDeafenTeam && bDeafenOwner)
			return MRES_Ignored;

		if(!bDeafen)
			return MRES_Supercede;

		Address pMemory = view_as<Address>(DHookGetParamObjectPtrVar(hParams, 1, 24, ObjectValueType_Int));
		int entity = LoadFromAddress(pMemory, NumberType_Int32);

		if(entity <= 0 || entity > MaxClients || !IsClientInGame(entity))
			return MRES_Ignored;

		int team = GetClientTeam(entity);

		if((!bDeafenTeam && team == g_iTeam && entity != g_iThrower) || (!bDeafenOwner && entity == g_iThrower))
			return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn Player_Blind(int entity, Handle hParams) 
{
	if(entity == g_iThrower)
		return MRES_Ignored;

	bool bSpecFlash = hFlashSpec.BoolValue;
	bool bTeamFlash = hTeamFlash.BoolValue;

	if((g_iTeam != CS_TEAM_T && g_iTeam != CS_TEAM_CT) || (bTeamFlash && bSpecFlash) || !IsClientInGame(entity))
		return MRES_Ignored;

	int team = GetClientTeam(entity);

	if(((team == CS_TEAM_NONE || team == CS_TEAM_SPECTATOR) && !hFlashSpec.BoolValue) || (team == g_iTeam && !hTeamFlash.BoolValue))
		return MRES_Supercede;

	return MRES_Ignored;
}

public MRESReturn Flash_Detonate(int entity) 
{
	g_iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	g_iTeam = GetEntProp(entity, Prop_Data, "m_iTeamNum");
	return MRES_Ignored;
}

public void OnEntityCreated(int entity, const char[] classname) 
{ 
    if(StrEqual(classname, "flashbang_projectile")) 
    { 
        DHookEntity(hDetonate, false, entity); 
    } 
}