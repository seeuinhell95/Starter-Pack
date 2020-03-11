#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>

Handle hPluginEnable;
Handle hPublic;
Handle hSaveScores;
Handle hResetCost;
bool CSGO;

ArrayList playersList;
ArrayList scores;

public Plugin myinfo =
{
	name = "[CSGO] ResetScore",
	author = "AbneR | Edited: somebody.",
	description = "ResetScore",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{  
	HookEvent("player_disconnect", PlayerDisconnect);

	char theFolder[40];
	GetGameFolderName(theFolder, sizeof(theFolder));
	CSGO = StrEqual(theFolder, "csgo");

	RegConsoleCmd("resetmyscore", CommandResetScore);
	RegConsoleCmd("resetscore", CommandResetScore);
	RegConsoleCmd("rs", CommandResetScore);

	RegAdminCmd("sm_resetstats", CommandResetPlayer, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_resetstat", CommandResetPlayer, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_reset", CommandResetPlayer, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_abner_setstars", CommandSetStars, ADMFLAG_ROOT);

	LoadTranslations("common.phrases");
	LoadTranslations("resetscore.phrases");

	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_file_last \"\"");
	ServerCommand("mp_backup_round_file_pattern \"\"");
	ServerCommand("mp_backup_round_auto 0");

	if(CSGO)
	{
		RegAdminCmd("sm_abner_setassists", CommandSetAssists, ADMFLAG_ROOT);
		RegAdminCmd("sm_abner_setpoints", CommandSetPoints, ADMFLAG_ROOT);
		RegAdminCmd("sm_abner_setscore", CommandSetScoreCSGO, ADMFLAG_ROOT);
	}
	else
	{
		RegAdminCmd("sm_abner_setscore", CommandSetScore, ADMFLAG_ROOT);
	}

	AutoExecConfig(true, "resetscore");

	hPluginEnable = CreateConVar("sm_resetscore", "1", "Enable/Disable the Plugin.");
	hPublic = CreateConVar("sm_resetscore_public", "0", "Enable or disable the messages when player reset score.");
	hSaveScores = CreateConVar("sm_resetscore_savescores", "1", "Save scores when players retry.");
	hResetCost = CreateConVar("sm_resetscore_cost", "0", "Money cost to reset score.");

	playersList = new ArrayList(64);
	scores = new ArrayList(4);

	for(int i = 0;i < GetMaxClients();i++)
	{
		if(!IsValidClient(i))
			continue;
		OnClientPutInServer(i);
	}
}

public void OnMapStart()
{
	playersList = new ArrayList(64);
	scores = new ArrayList(4);
	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_file_last \"\"");
	ServerCommand("mp_backup_round_file_pattern \"\"");
	ServerCommand("mp_backup_round_auto 0");
}  

public void OnClientPutInServer(int client)
{
	if(GetConVarInt(hSaveScores) != 1 || IsFakeClient(client))
		return;
	
	char steamId[64];
	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
	int infoArray[5];
	int index = playersList.FindString(steamId);
	if(index != -1)
	{
		CreateTimer(2.0, MSG, client);
		scores.GetArray(index, infoArray, sizeof(infoArray));
		SetEntProp(client, Prop_Data, "m_iFrags", infoArray[0]);
		SetEntProp(client, Prop_Data, "m_iDeaths", infoArray[1]);
		CS_SetMVPCount(client, infoArray[2]);
		if(CSGO)
		{
			CS_SetClientContributionScore(client, infoArray[3]);
			CS_SetClientAssists(client, infoArray[4]);
		}
	}
	else
	{
		playersList.PushString(steamId);
		scores.PushArray(infoArray);
	}
}

public Action MSG(Handle timer, any client)
{
	if(IsValidClient(client))
		PrintToChat(client, "[\x02RS\x01] \x06%t", "Restored");
}

public void PlayerDisconnect(Handle event,const char[] name,bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return;
	if(GetConVarInt(hSaveScores) != 1 || IsFakeClient(client))
		return;
		
	char steamId[64];
	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
	int infoArray[5];
	int index = playersList.FindString(steamId);
	if(index != -1)
	{
		infoArray[0] = GetClientFrags(client);
		infoArray[1] = GetClientDeaths(client);
		infoArray[2] = CS_GetMVPCount(client);
		if(CSGO)
		{
			infoArray[3] = CS_GetClientContributionScore(client);
			infoArray[4] = CS_GetClientAssists(client);
		}
		scores.SetArray(index, infoArray);
	}
}

public Action CommandResetScore(int client, int args)
{                        
	if(GetConVarInt(hPluginEnable) == 0)
	{
		PrintToChat(client, "[SM] %t", "Plugin Disabled");
		return Plugin_Continue;
	}
	
	if(GetClientDeaths(client) == 0 && GetClientFrags(client) == 0 && CS_GetMVPCount(client) == 0)
	{
		if(!CSGO || CS_GetClientAssists(client) == 0)
		{
			PrintToChat(client, "[\x02RS\x01] \x06%t", "Score 0");
			return Plugin_Continue;
		}
	}
	
	int cost = GetConVarInt(hResetCost);
	int money = GetEntProp(client, Prop_Send, "m_iAccount");
	if(cost > 0 && money < cost)
	{
		PrintToChat(client, "[SM] %t", "No Money", cost);
		return Plugin_Continue;
	}
	
	ResetPlayer(client);
	SetEntProp(client, Prop_Send, "m_iAccount", money-cost);
	
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	if(GetConVarInt(hPublic) == 1)
	{
		if(GetClientTeam(client) == 2)
		{
			CPrintToChatAll("[SM] %t", "Player Reset Red", name);
		}
		else if(GetClientTeam(client) == 3)
		{
			CPrintToChatAll("[SM] %t", "Player Reset Blue", name);
		}
		else
		{
			CPrintToChatAll("[SM] %t", "Player Reset Normal", name);
		}
	}
	else
	{
		PrintToChat(client, "[\x02RS\x01] \x06%t", "You Reset");
	}
	return Plugin_Continue;
}

void ResetPlayer(int client)
{
	if(IsValidClient(client))
	{
		SetEntProp(client, Prop_Data, "m_iFrags", 0);
		SetEntProp(client, Prop_Data, "m_iDeaths", 0);
		CS_SetMVPCount(client, 0);
		if(CSGO)
		{
			CS_SetClientAssists(client, 0);
			CS_SetClientContributionScore(client, 0);
		}
	}
}
	
public Action CommandResetPlayer(int client, int args)
{                           
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));

	if (args != 1)
	{
		ReplyToCommand(client, "[SM] sm_reset <name or #userid>");
		return Plugin_Continue;
	}
 	
	char target_name[MAX_TARGET_LENGTH];
	char nameadm[MAX_NAME_LENGTH];
	GetClientName(client, nameadm, sizeof(nameadm));
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

  	for (int i = 0; i < target_count; i++)
	{
		ResetPlayer(target_list[i]);
	}
	ShowActivity2(client, "[SM] ", "%t", "Reset Score of", target_name);
	return Plugin_Continue;
}

public Action CommandSetScore(int client, int args)
{                           
  	char arg1[32], arg2[20], arg3[20],arg4[20];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	int kills = StringToInt(arg2);
	int deaths = StringToInt(arg3);
	int stars = StringToInt(arg4);
      
	if (args != 4)
	{
		ReplyToCommand(client, "[SM] sm_abner_setscore <name or #userid> <Kills> <Deaths><Stars>");
		return Plugin_Continue;
	}
 	
	char target_name[MAX_TARGET_LENGTH];
	char nameadm[MAX_NAME_LENGTH];
	GetClientName(client, nameadm, sizeof(nameadm));
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

  	for (int i = 0; i < target_count; i++)
	{
		SetEntProp(target_list[i], Prop_Data, "m_iFrags", kills);
		SetEntProp(target_list[i], Prop_Data, "m_iDeaths", deaths);
		CS_SetMVPCount(target_list[i], stars);
	}
	
	ShowActivity2(client, "[SM] ", "%t", "Set Score", target_name);
	return Plugin_Continue;
}

public Action CommandSetScoreCSGO(int client, int args)
{                           
  	if (args != 6)
	{
		ReplyToCommand(client, "[SM] sm_abner_setscore <name or #userid> <Kills> <Deaths><Assists><Stars><Points>");
		return Plugin_Continue;
	}
	
	char arg1[32], arg2[20], arg3[20], arg4[20], arg5[20], arg6[20];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	GetCmdArg(5, arg5, sizeof(arg5));
	GetCmdArg(6, arg6, sizeof(arg6));
	int kills = StringToInt(arg2);
	int deaths = StringToInt(arg3);
	int assists = StringToInt(arg4);
	int stars = StringToInt(arg5);
	int points = StringToInt(arg6);
 	
	char target_name[MAX_TARGET_LENGTH];
	char nameadm[MAX_NAME_LENGTH];
	GetClientName(client, nameadm, sizeof(nameadm));
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

  	for (int i = 0; i < target_count; i++)
	{
		SetEntProp(target_list[i], Prop_Data, "m_iFrags", kills);
		SetEntProp(target_list[i], Prop_Data, "m_iDeaths", deaths);
		CS_SetClientAssists(target_list[i], assists);
		CS_SetMVPCount(target_list[i], stars);
		CS_SetClientContributionScore(target_list[i], points);
	}
	
	ShowActivity2(client, "[SM] ", "%t", "Set Score", target_name);
	return Plugin_Continue;
}

public Action CommandSetPoints(int client, int args)
{                           
	char arg1[32], arg2[20];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int points = StringToInt(arg2);
		
	if (args != 2)
	{
		ReplyToCommand(client, "[SM] sm_abner_setpoints <name or #userid> <points>");
		return Plugin_Continue;
	}

	char target_name[MAX_TARGET_LENGTH];
	char nameadm[MAX_NAME_LENGTH];
	GetClientName(client, nameadm, sizeof(nameadm));
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;

	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

	for (int i = 0; i < target_count; i++)
	{   
		CS_SetClientContributionScore(target_list[i], points);
	}

	ShowActivity2(client, "[SM] ", "%t", "Set Points of", target_name, points);
	return Plugin_Continue;
}

public Action CommandSetAssists(int client, int args)
{                           
	char arg1[32], arg2[20];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int assists = StringToInt(arg2);
		
	if (args != 2)
	{
		ReplyToCommand(client, "[SM] sm_abner_setassists <name or #userid> <assists>");
		return Plugin_Continue;
	}

	char target_name[MAX_TARGET_LENGTH];
	char nameadm[MAX_NAME_LENGTH];
	GetClientName(client, nameadm, sizeof(nameadm));
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;

	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

	for (int i = 0; i < target_count; i++)
	{   
		CS_SetClientAssists(target_list[i], assists);
	}

	ShowActivity2(client, "[SM] ", "%t", "Set Assists of", target_name, assists);
	return Plugin_Continue;
}

public Action CommandSetStars(int client, int args)
{                           
	char arg1[32], arg2[20];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int stars = StringToInt(arg2);

	if (args != 2)
	{
		ReplyToCommand(client, "[SM] sm_abner_setstars <name or #userid> <stars>");
		return Plugin_Continue;
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;

	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_TARGET_NONE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Continue;
	}

	for (int i = 0; i < target_count; i++)
	{
		CS_SetMVPCount(target_list[i], stars);
	}

	ShowActivity2(client, "[SM] ", "%t", "Set Stars of", target_name, stars);
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}