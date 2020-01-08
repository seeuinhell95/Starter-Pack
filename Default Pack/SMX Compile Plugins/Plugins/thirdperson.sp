#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <zephstocks>

bool g_bThirdperson[MAXPLAYERS+1] = {false,...};
bool mirror[MAXPLAYERS+1] = {false,...};
ConVar mp_forcecamera;

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] ThirdPerson & Mirror Mode",
	author = "Zephyrus | Edited: somebody",
	description = "ThirdPerson & Mirror Mode",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	IdentifyGame();
	HookEvent("player_spawn", Event_PlayerSpawn);

	RegConsoleCmd("sm_tp", Command_TP);
	RegConsoleCmd("sm_thirdperson", Command_TP);
	RegConsoleCmd("sm_fp", Command_FP);
	RegConsoleCmd("sm_firstperson", Command_FP);
	RegConsoleCmd("sm_mirror", Cmd_Mirror, "Toggle Rotational Thirdperson view");

	mp_forcecamera = FindConVar("mp_forcecamera");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("IsPlayerInTP", Native_IsPlayerInTP);
	CreateNative("TogglePlayerTP", Native_TogglePlayerTP);

	return APLRes_Success;
}

public int Native_IsPlayerInTP(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if(g_bThirdperson[client] || mirror[client])
		return true;

	return false;
}

public int Native_TogglePlayerTP(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	g_bThirdperson[client] = !g_bThirdperson[client];
	ToggleThirdperson(client);
}

public void OnClientConnected(int client)
{
	g_bThirdperson[client] = false;
	mirror[client] = false;
}

public Action Command_TP(int client, int args)
{
	if(mirror[client])
		SetMirror(client,false);

	g_bThirdperson[client] = !g_bThirdperson[client];
	ToggleThirdperson(client);
	return Plugin_Handled;
}

public Action Command_FP(int client, int args)
{
	g_bThirdperson[client] = false;
	SetThirdperson(client, false);
	SetMirror(client,false);
	mirror[client] = false;

	return Plugin_Handled;
}

public Action Event_PlayerSpawn(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if(g_bThirdperson[client])
		SetThirdperson(client, true);

	return Plugin_Handled;
}

stock void ToggleThirdperson(int client)
{
	if(g_bThirdperson[client])
		SetThirdperson(client, true);
	else
	SetThirdperson(client, false);
}

stock void SetThirdperson(int client, bool tp)
{
	if(GAME_CSGO)
	{
		static Handle m_hAllowTP = INVALID_HANDLE;
		if(m_hAllowTP == INVALID_HANDLE)
			m_hAllowTP = FindConVar("sv_allow_thirdperson");
		
		SetConVarInt(m_hAllowTP, 1);
		
		if(tp)
			ClientCommand(client, "thirdperson");
		else
		ClientCommand(client, "firstperson");
	}
	else if(GAME_TF2)
	{
		if(tp)
			SetVariantInt(1);
		else
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}

public Action Cmd_Mirror(int client, int args)
{
	if (!IsPlayerAlive(client))
	{
		ReplyToCommand(client, "[SM] Ezt a parancsot csak élőként használhatod.");
		return Plugin_Handled;
	}

	if(mirror[client])
		SetMirror(client,false);
	else SetMirror(client,true);

	return Plugin_Handled;
}

stock void SetMirror(int client, bool b_Mirror)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}

	if(g_bThirdperson[client])
	{
		g_bThirdperson[client] = false;
		SetThirdperson(client, false);
	}

	if (b_Mirror)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0); 
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 120);
		SendConVarValue(client, mp_forcecamera, "1");
		mirror[client] = true;
	}
	else
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
		char valor[6];
		GetConVarString(mp_forcecamera, valor, 6);
		SendConVarValue(client, mp_forcecamera, valor);
		mirror[client] = false;
	}
}