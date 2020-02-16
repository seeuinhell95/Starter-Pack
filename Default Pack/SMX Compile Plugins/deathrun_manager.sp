#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required

#define TRCONDITIONS GetTeamClientCount(2) == 0  && GetTeamClientCount(3) > 1

bool jaTR[MAXPLAYERS+1] = false;
Handle roundTime = INVALID_HANDLE;

Handle g_Enabled;
Handle g_TrKills;
Handle g_killTRFrag;
Handle g_TimeLimit;
Handle g_TRSpeed;

public Plugin myinfo =
{
	name = "[CSGO] Deathrun Manager",
	author = "AbneR | Edited: somebody.",
	description = "Deathrun Manager",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	AutoExecConfig(true, "deathrun_manager");

	LoadTranslations("common.phrases");
	LoadTranslations("deathrun_manager.phrases");

	g_Enabled 				= CreateConVar("dr_enabled", "1", "Enable or Disable the Plugin.");
	g_TrKills 			    = CreateConVar("dr_tr_kills", "1", "Give kills to terrorists.");
	g_killTRFrag 			= CreateConVar("dr_kill_tr_frag", "10", "Frags gives to cts who kills terrorists");
	g_TimeLimit			    = CreateConVar("dr_time_limit", "1", "Kill alive cts if round time ends.");
	g_TRSpeed 				= CreateConVar("dr_tr_speed", "1.0", "Terrorist speed, 1.0 to default speed.");

	AddCommandListener(JoinTeam, "jointeam");
	AddCommandListener(Suicide, "kill");
	AddCommandListener(Suicide, "killvector");
	AddCommandListener(Suicide, "explode");
	AddCommandListener(Suicide, "explodevector");

	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_team", PlayerJoinTeam);
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_disconnect", Disconnect, EventHookMode_Post);

	RegConsoleCmd("goct", GoCT);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
		{
			continue;
		}
		jaTR[i] = false;
		SDKHook(i, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	}
}

public void OnMapStart()
{
	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_file_last \"\"");
	ServerCommand("mp_backup_round_file_pattern \"\"");
	ServerCommand("mp_backup_round_auto 0");
}

public Action GoCT(int client, int args)
{
	if(GetClientTeam(client) == 1)
		ChangeClientTeam(client, 3);
}

public void OnConfigsExecuted()
{
	SetCvar("mp_autoteambalance", "0");
	SetCvar("mp_limitteams", "0");
}

public Action PlayerJoinTeam(Handle ev, char[] name, bool dbroad)
{
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	if(GetEventInt(ev, "team") == 2 && GetTeamClientCount(2)+1 > 1)
	{
		CreateTimer(0.1, ChangeTeamTime, client);
		PrintCenterText(client, "%t", "Team Limit");
	}
}

public Action PlayerSpawn(Handle event, char[] name, bool dontBroadcast) 
{
	if(GetConVarInt(g_Enabled)!= 1)
		return Plugin_Handled;

	int client		 = GetClientOfUserId(GetEventInt(event, "userid"));
	float trspeed 	 = GetConVarFloat(g_TRSpeed);

	if(GetClientTeam(client) == 2)
	{
		if(trspeed != 1.0)
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", trspeed);
		}
	}

	return Plugin_Handled;
}

public void Disconnect(Handle event,const char[] name,bool dontBroadcast)
{
	if(GetConVarInt(g_Enabled) == 1)
		CreateTimer(0.5, CheckTR);
}

public Action CheckTR(Handle time)
{
	if(TRCONDITIONS)
	{
		NewRandomTR();
	}
}

public void PlayerDeath(Handle event,const char[] name,bool dontBroadcast)
{
	if(GetConVarInt(g_Enabled) != 1)
		return;

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(IsValidClient(attacker) && GetClientTeam(victim) == 2 && GetClientTeam(attacker) == 3)
	{
		int frags = GetClientFrags(attacker) +GetConVarInt(g_killTRFrag)-1;
		int score =  CS_GetClientContributionScore(attacker) +GetConVarInt(g_killTRFrag)*2-2;
		SetEntProp(attacker, Prop_Data, "m_iFrags", frags);
		CS_SetClientContributionScore(attacker, score);
	}
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetConVarInt(g_Enabled) != 1 || GetConVarInt(g_TrKills) != 1)
		return Plugin_Continue;

	int tr = getCurrentTR();
	if(GetClientTeam(client) == 3 && IsValidClient(tr))
	{
		attacker = tr;
	}
	return Plugin_Changed;
}

public void OnClientPutInServer(int client)
{	
	jaTR[client] = false;
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
}

public Action RoundStart(Handle event, const char[] name, bool dontBroadcast) 
{
	if(GetConVarInt(g_Enabled) != 1)
		return Plugin_Continue;

	CreateTimer(2.0, CheckTR);

	for(int  i=0;i<GetMaxEntities();++i)
	{
		if(!IsValidEdict(i))
			continue;
	
		char strName[64];
		GetEdictClassname(i, strName, sizeof(strName));
		if(StrEqual(strName, "weapon_c4"))
			RemoveEdict(i);
	}

	CreateTimer(1.0, RespawnPlayers);
	
	if(GetConVarInt(g_TimeLimit) != 1)
		return Plugin_Continue;

	if(roundTime != INVALID_HANDLE)
	{
		KillTimer(roundTime);
	}

	Handle timeCvar = FindConVar("mp_roundtime");
	roundTime = CreateTimer(GetConVarFloat(timeCvar)*60.0, TimeKill);
	return Plugin_Continue;
}

public Action RespawnPlayers(Handle time)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) > 1 && !IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);
		}
	}
}

public Action TimeKill(Handle timer)
{
	roundTime = INVALID_HANDLE;
	if(GetConVarInt(g_Enabled) != 1 || GetConVarInt(g_TimeLimit) != 1)
		return Plugin_Continue;
		
	for (int i = 1; i < MaxClients; i++)
	{	
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
		{
			int life = GetClientHealth(i) * 2; 
			DealDamage(i, life, 0,(1 << 1));
		}
	}
	PrintToChatAll(" \x0B[Deathrun] \x06%t", "TimeOver");
	return Plugin_Continue;
}

void DealDamage(int victim,int damage,int attacker=0,int dmg_type, char[] weapon="")
{
	if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim) && damage>0)
	{
		char dmg_str[16];
		IntToString(damage,dmg_str,16);
		char dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
		int pointHurt = CreateEntityByName("point_hurt");
		if(pointHurt)
		{
			DispatchKeyValue(victim,"targetname","war3_hurtme");
			DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
			DispatchKeyValue(pointHurt,"Damage",dmg_str);
			DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
			if(!StrEqual(weapon,""))
			{
				DispatchKeyValue(pointHurt,"classname",weapon);
			}
			DispatchSpawn(pointHurt);
			AcceptEntityInput(pointHurt,"Hurt",(attacker>0)?attacker:-1);
			DispatchKeyValue(pointHurt,"classname","point_hurt");
			DispatchKeyValue(victim,"targetname","war3_donthurtme");
			RemoveEdict(pointHurt);
		}
	}
}

int getCurrentTR()
{
	for (int  i = 1; i < MaxClients; i++)
	{	
		if(IsValidClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			return i;
		}
	}
	return -1;
}

public Action RoundEnd(Handle event, const char[] name, bool dontBroadcast) 
{ 
	if(GetConVarInt(g_Enabled) != 1)
		return;

	allGod();

	int winner = GetEventInt(event, "winner");
	if (winner > 1 || GetTeamClientCount(2) == 0)
	{
		CreateTimer(1.0, TimeEnd);
	}
}

public Action TimeEnd(Handle time)
{
	NewRandomTR();
}

public void allGod()
{
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i))
		{
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
		}
	}
}

public Action ChangeTeamTime(Handle timer, any client)
{
	if(IsValidClient(client))
		ChangeTeam(client, 3);
}

public void ChangeTeam(int client, int index)
{
	if(IsPlayerAlive(client) && GetClientTeam(client) != index)
	{
		int frags = GetClientFrags(client) +1;
		int deaths = GetClientDeaths(client) -1;
		int score = CS_GetClientContributionScore(client)+2;
		SetEntProp(client, Prop_Data, "m_iFrags", frags);
		SetEntProp(client, Prop_Data, "m_iDeaths", deaths);
		CS_SetClientContributionScore(client, score);
	}
	ChangeClientTeam(client, index);
}

public void NewRandomTR()
{
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsValidClient(i) && GetClientTeam(i) == 2)
		{
			ChangeTeam(i, 3);
		}
	}

	int client = randomTR();
	if(IsValidClient(client))
	{
		ChangeTeam(client, 2);
		PrintToChatAll(" \x0B[Deathrun] \x06%t", "RandomTR");
	}
}

int randomTR()
{
	if(GetClientCount() < 2)
		return 0;
	
	int count = 0;
	int clients[MAXPLAYERS+1];
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !jaTR[i] && GetClientTeam(i) == 3)
		{
			clients[count++] = i;
		}
	}
	
	if(count > 0)
	{
		int novotr = clients[GetRandomInt(0, count-1)];
		jaTR[novotr] = true;
		return novotr;
	}
	
	count = 0;
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsValidClient(i) &&  GetClientTeam(i) == 3)
		{
			jaTR[i] = false;
			clients[count++] = i;
		}
	}
	
	if(count > 0)
	{
		int novotr = clients[GetRandomInt(0, count-1)];
		jaTR[novotr] = true;
		return novotr;
	}
	
	return 0;	
} 

stock void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	if(cvar != INVALID_HANDLE)
		SetConVarString(cvar, svalue, true);
}

public Action JoinTeam(int client, const char[] command, int args)
{
	if(GetConVarInt(g_Enabled) != 1)
		return Plugin_Continue;

	char argz[32];  
	GetCmdArg(1, argz, sizeof(argz));
	int arg = StringToInt(argz);
	
	if(GetClientTeam(client) == 1)
	{
		ChangeClientTeam(client, 3);
		return Plugin_Handled;
	}

	if(GetTeamClientCount(3) > 0 &&  GetClientTeam(client) == 2)
	{		
		PrintCenterText(client, "%t", "Cant Change");
		return Plugin_Handled;
	}
		
	if(arg == 2 || arg == 0)
	{
		PrintCenterText(client, "%t", "Team Limit");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Suicide(int client, const char[] command, int args)
{
	if(GetConVarInt(g_Enabled) != 1)
		return Plugin_Continue;

	PrintToChat(client, " \x0B[Deathrun] \x06%t.", "KillPrevent");
	return Plugin_Handled;
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}