#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <basecomm>
#define REQUIRE_PLUGIN
#include <hosties>

new Handle:gH_Cvar_MuteStatus = INVALID_HANDLE;
new gShadow_MuteStatus;
new Handle:gH_Cvar_MuteLength = INVALID_HANDLE;
new Float:gShadow_MuteLength;
new Handle:gH_Timer_Unmuter = INVALID_HANDLE;
new Handle:gH_Cvar_MuteImmune = INVALID_HANDLE;
new String:gShadow_MuteImmune[37];
new Handle:gH_Cvar_MuteCT = INVALID_HANDLE;
new bool:gShadow_MuteCT = false;
new gAdmFlags_MuteImmunity = 0;
bool MutedInThisRound[MAXPLAYERS + 1] = false;

MutePrisoners_OnPluginStart()
{
	gH_Cvar_MuteStatus = CreateConVar("sm_hosties_mute", "1", "Setting for muting terrorists automatically: 0 - disable, 1 - terrorists are muted the first few seconds of a round, 2 - terrorists are muted when they die, 3 - both", 0, true, 0.0, true, 3.0);
	gShadow_MuteStatus = 0;

	gH_Cvar_MuteLength = CreateConVar("sm_hosties_roundstart_mute", "15.0", "The length of time the Terrorist team is muted for after the round begins", 0, true, 3.0, true, 90.0);
	gShadow_MuteLength = Float:30.0;

	gH_Cvar_MuteImmune = CreateConVar("sm_hosties_mute_immune", "a", "Admin flags which are immune from getting muted: 0 - nobody, 1 - all admins, flag values: abcdefghijklmnopqrst");
	Format(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), "a");

	gH_Cvar_MuteCT = CreateConVar("sm_hosties_mute_ct", "0", "Setting for muting counter-terrorists automatically when they die (requires sm_hosties_mute 2 or 3): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gShadow_MuteCT = false;

	HookConVarChange(gH_Cvar_MuteStatus, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteLength, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteImmune, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteCT, MutePrisoners_CvarChanged);

	g_Offset_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
}

MutePrisoners_AllPluginsLoaded()
{
	if (DoesContainBaseCommNatives())
	{
		HookEvent("round_start", MutePrisoners_RoundStart);
		HookEvent("round_end", MutePrisoners_RoundEnd);
		HookEvent("player_death", MutePrisoners_PlayerDeath);
		HookEvent("player_spawn", MutePrisoners_PlayerSpawn);
	}
	else
	{
		PrintToServer("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
		LogMessage("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
	}
}

MutePrisoners_OnConfigsExecuted()
{
	gShadow_MuteStatus = GetConVarInt(gH_Cvar_MuteStatus);
	gShadow_MuteLength = GetConVarFloat(gH_Cvar_MuteLength);

	GetConVarString(gH_Cvar_MuteImmune, gShadow_MuteImmune, sizeof(gShadow_MuteImmune));
	MutePrisoners_CalcImmunity();
}

stock MuteTs()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if ((IsClientInGame(i)) && (IsPlayerAlive(i)))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				MutePlayer(i);
			}
		}
	}
}

stock UnmuteAlive()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			if (!BaseComm_IsClientMuted(i))
			{
				UnmutePlayer(i);
			}
		}
	}
}

stock bool:DoesContainBaseCommNatives()
{
	if (GetFeatureStatus(FeatureType_Native, "BaseComm_IsClientMuted") == FeatureStatus_Available)
	{
		return true;
	}
	return false;
}

stock UnmuteAll()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!BaseComm_IsClientMuted(i))
			{
				UnmutePlayer(i);
			}
		}
	}
}

void MutePrisoners_CalcImmunity()
{
	if (StrEqual(gShadow_MuteImmune, "0"))
	{
		gAdmFlags_MuteImmunity = 0;
	}
	else
	{
		if(StrEqual(gShadow_MuteImmune, "1"))
		{
			Format(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), "bcdefghijklmnopqrstz");
		}

		gAdmFlags_MuteImmunity = ReadFlagString(gShadow_MuteImmune);
	}
}

public MutePrisoners_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_MuteStatus)
	{
		gShadow_MuteStatus = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_MuteLength)
	{
		gShadow_MuteLength = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_MuteImmune)
	{
		Format(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), newValue);
		MutePrisoners_CalcImmunity();
	}
	else if (cvar == gH_Cvar_MuteCT)
	{
		gShadow_MuteCT = bool:StringToInt(newValue);
	}
}

public MutePrisoners_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus == 1 || gShadow_MuteStatus == 3)
	{
		if (gH_Timer_Unmuter != INVALID_HANDLE)
		{
			new client = GetClientOfUserId(GetEventInt(event, "userid"));
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (gAdmFlags_MuteImmunity == 0)
				{
					CreateTimer(0.1, Timer_Mute, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					if (!(GetUserFlagBits(client) & gAdmFlags_MuteImmunity))
					{
						CreateTimer(0.1, Timer_Mute, client, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

public Action:Timer_Mute(Handle:timer, any:client)
{
	if (IsClientInGame(client) && MutedInThisRound[client] == false)
	{
		MutePlayer(client);
		MutedInThisRound[client] = true;
		PrintToChat(client, CHAT_BANNER, "Now Muted");
		if (gShadow_LR_Debug_Enabled == true)
		{
			PrintToChatAll("\x01[\x07Entity-Debug\x01] \x10%N \x06has been muted", client);
		}
	}
	else
	{
		if (gShadow_LR_Debug_Enabled == true)
		{
			PrintToChatAll("\x01[\x07Entity-Debug\x01] \x10%N \x06was muted so not getting muted this time", client);
		}
	}

	return Plugin_Stop;
}

public MutePrisoners_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus <= 1)
	{
		return;
	}

	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	if (gAdmFlags_MuteImmunity == 0 || !(GetUserFlagBits(victim) & gAdmFlags_MuteImmunity))
	{
		new team = GetClientTeam(victim);
		switch (team)
		{
			case CS_TEAM_T:
			{
				CreateTimer(0.1, Timer_Mute, victim, TIMER_FLAG_NO_MAPCHANGE);
			}
			case CS_TEAM_CT:
			{
				if (gShadow_MuteCT)
				{			
					CreateTimer(0.1, Timer_Mute, victim, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public MutePrisoners_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus)
	{
		CreateTimer(0.2, Timer_UnmuteAll, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (gH_Timer_Unmuter != INVALID_HANDLE)
	{
		CloseHandle(gH_Timer_Unmuter);
		gH_Timer_Unmuter = INVALID_HANDLE;
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			MutedInThisRound[i] = false;
		}
	}
}

public MutePrisoners_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus == 1 || gShadow_MuteStatus == 3)
	{
		if (gAdmFlags_MuteImmunity == 0)
		{
			MuteTs();
		}
		else
		{
			for (new idx = 1; idx <= MaxClients; idx++)
			{
				if (IsClientInGame(idx) && (GetClientTeam(idx) == CS_TEAM_T) && !(GetUserFlagBits(idx) & gAdmFlags_MuteImmunity))
				{
					MutePlayer(idx);
				}
			}
		}

		gH_Timer_Unmuter = CreateTimer(gShadow_MuteLength, Timer_UnmutePrisoners, _, TIMER_FLAG_NO_MAPCHANGE);

		PrintToChatAll(CHAT_BANNER, "Ts Muted", RoundToNearest(gShadow_MuteLength));
	}
}

public Action:Timer_UnmutePrisoners(Handle:timer)
{
	UnmuteAlive();
	PrintToChatAll(CHAT_BANNER, "Ts Can Speak Again");
	gH_Timer_Unmuter = INVALID_HANDLE;

	return Plugin_Stop;
}

public Action:Timer_UnmuteAll(Handle:timer)
{
	UnmuteAll();

	return Plugin_Stop;
}