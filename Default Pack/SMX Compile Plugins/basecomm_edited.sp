#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <adminmenu>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] SourceBans - Basic Comms",
	author = "AlliedModders LLC | Edited: Cherry & somebody.",
	description = "SourceBans - Basic Comms",
	version = "1.0",
	url = "http://sourcemod.net"
};

bool g_Muted[MAXPLAYERS+1];
bool g_Gagged[MAXPLAYERS+1];

ConVar g_Cvar_Deadtalk;
ConVar g_Cvar_Alltalk;
bool g_Hooked = false;

#include "basecomm_edited/gag.sp"
#include "basecomm_edited/natives.sp"
#include "basecomm_edited/forwards.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("BaseComm_IsClientGagged", Native_IsClientGagged);
	CreateNative("BaseComm_IsClientMuted",  Native_IsClientMuted);
	CreateNative("BaseComm_SetClientGag",   Native_SetClientGag);
	CreateNative("BaseComm_SetClientMute",  Native_SetClientMute);

	RegPluginLibrary("basecomm_edited");

	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("basecomm.phrases");

	g_Cvar_Deadtalk = CreateConVar("sm_deadtalk", "2", "Controls how dead communicate. 0 - Off. 1 - Dead players ignore teams. 2 - Dead players talk to living teammates.", 0, true, 0.0, true, 2.0);
	g_Cvar_Alltalk = FindConVar("sv_alltalk");

	RegAdminCmd("sm_mute", Command_Mute, ADMFLAG_CHAT, "sm_mute <player> - Removes a player's ability to use voice.");
	RegAdminCmd("sm_gag", Command_Gag, ADMFLAG_CHAT, "sm_gag <player> - Removes a player's ability to use chat.");
	RegAdminCmd("sm_silence", Command_Silence, ADMFLAG_CHAT, "sm_silence <player> - Removes a player's ability to use voice or chat.");

	RegAdminCmd("sm_unmute", Command_Unmute, ADMFLAG_CHAT, "sm_unmute <player> - Restores a player's ability to use voice.");
	RegAdminCmd("sm_ungag", Command_Ungag, ADMFLAG_CHAT, "sm_ungag <player> - Restores a player's ability to use chat.");
	RegAdminCmd("sm_unsilence", Command_Unsilence, ADMFLAG_CHAT, "sm_unsilence <player> - Restores a player's ability to use voice and chat.");

	g_Cvar_Deadtalk.AddChangeHook(ConVarChange_Deadtalk);
	g_Cvar_Alltalk.AddChangeHook(ConVarChange_Alltalk);
}

public void ConVarChange_Deadtalk(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_Cvar_Deadtalk.IntValue)
	{
		HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
		HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
		g_Hooked = true;
	}
	else if (g_Hooked)
	{
		UnhookEvent("player_spawn", Event_PlayerSpawn);
		UnhookEvent("player_death", Event_PlayerDeath);		
		g_Hooked = false;
	}
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	g_Gagged[client] = false;
	g_Muted[client] = false;

	return true;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (client && g_Gagged[client])
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void ConVarChange_Alltalk(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int mode = g_Cvar_Deadtalk.IntValue;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
		{
			continue;
		}

		if (g_Muted[i])
		{
			SetClientListeningFlags(i, VOICE_MUTED);
		}
		else if (g_Cvar_Alltalk.BoolValue)
		{
			SetClientListeningFlags(i, VOICE_NORMAL);
		}
		else if (!IsPlayerAlive(i))
		{
			if (mode == 1)
			{
				SetClientListeningFlags(i, VOICE_LISTENALL);
			}
			else if (mode == 2)
			{
				SetClientListeningFlags(i, VOICE_TEAM);
			}
		}
	}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client)
	{
		return;	
	}

	if (g_Muted[client])
	{
		SetClientListeningFlags(client, VOICE_MUTED);
	}
	else
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client)
	{
		return;	
	}

	if (g_Muted[client])
	{
		SetClientListeningFlags(client, VOICE_MUTED);
		return;
	}

	if (g_Cvar_Alltalk.BoolValue)
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
		return;
	}

	int mode = g_Cvar_Deadtalk.IntValue;
	if (mode == 1)
	{
		SetClientListeningFlags(client, VOICE_LISTENALL);
	}
	else if (mode == 2)
	{
		SetClientListeningFlags(client, VOICE_TEAM);
	}
}