#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks2>

new Handle:hIsValidTarget;
new Handle:mp_forcecamera;
new bool:g_bCheckNullPtr = false;

public Plugin myinfo =
{
	name = "[CSGO] Admin All Spectate",
	author = "Dr!fter & R3V | Edited: somebody.",
	description = "Admin All Spectate",
	version = "1.0",
	url = "http://sourcemod.net"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("DHookIsNullParam");

	return APLRes_Success;
}

public OnPluginStart()
{
	mp_forcecamera = FindConVar("mp_forcecamera");

	if(!mp_forcecamera)
	{
		SetFailState("Failed to locate mp_forcecamera");
	}

	new Handle:temp = LoadGameConfigFile("allow-spec.games");

	if(!temp)
	{
		SetFailState("Failed to load allow-spec.games.txt");
	}

	new offset = GameConfGetOffset(temp, "IsValidObserverTarget");

	hIsValidTarget = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, IsValidTarget);

	DHookAddParam(hIsValidTarget, HookParamType_CBaseEntity);

	CloseHandle(temp);

	g_bCheckNullPtr = (GetFeatureStatus(FeatureType_Native, "DHookIsNullParam") == FeatureStatus_Available);
}

public OnClientPostAdminCheck(client)
{
	if(IsFakeClient(client))
		return;

	if(CheckCommandAccess(client, "admin_allspec_flag", ADMFLAG_RESERVATION))
	{
		SendConVarValue(client, mp_forcecamera, "0");
		DHookEntity(hIsValidTarget, true, client);
	}
}

public MRESReturn:IsValidTarget(thisPointer, Handle:hReturn, Handle:hParams)
{
	if (g_bCheckNullPtr && DHookIsNullParam(hParams, 1))
	{
		return MRES_Ignored;
	}

	new target = DHookGetParam(hParams, 1);

	if(target <= 0 || target > MaxClients || !IsClientInGame(thisPointer) || !IsClientInGame(target) || !IsPlayerAlive(target) || IsPlayerAlive(thisPointer) || GetClientTeam(thisPointer) <= 1 || GetClientTeam(target) <= 1)
	{
		return MRES_Ignored;
	}

	DHookSetReturn(hReturn, true);
	return MRES_Override;
}