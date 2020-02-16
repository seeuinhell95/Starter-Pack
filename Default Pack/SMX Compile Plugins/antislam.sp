#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <adminmenu>
#include <dhooks>
#include <voiceannounce_ex>

new bool:miew[MAXPLAYERS+1] = {false,...};
IsSpeaking[MAXPLAYERS+1] = 0;
HLDJ[MAXPLAYERS+1] = 0;

public Plugin myinfo =
{
	name = "[CSGO] Anti SLAM",
	author = "Cherry | Edited: somebody.",
	description = "Anti SLAM",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	HookEvent("player_disconnect", PlayerDisconnect_Event, EventHookMode_Post);

	RegAdminCmd("sm_slam", Command_AddSLAM, ADMFLAG_RESERVATION, "sm_slam <playername>");
	RegAdminCmd("sm_unslam", Command_UnSLAM, ADMFLAG_RESERVATION, "sm_unslam <playername>");
	RegAdminCmd("sm_allow", Command_AddSLAM, ADMFLAG_RESERVATION, "sm_allow <playername>");
	RegAdminCmd("sm_unallow", Command_UnSLAM, ADMFLAG_RESERVATION, "sm_unallow <playername>");
}

public OnMapEnd()
{
	for (new i = 1; i <= MAXPLAYERS; i++)
	{
		HLDJ[i] = 0;
	}
}

public Action Command_UnSLAM(int client, int args)
{
	if(client == 0)
	{
		PrintToChat(client, "[\x04SLAM\x01] \x02Nem lehet használni rcon-ból!");
		return Plugin_Handled;
	}

	if(args < 1) 
	{
		ReplyToCommand(client, "[\x04SLAM\x01] \x02Használat: \x04!unslam \x02<játékos>");
		DisplayunSLAMMenu(client);
		return Plugin_Handled;
	}

	char arg2[10];
	GetCmdArg(2, arg2, sizeof(arg2));

	char strTarget[32];
	GetCmdArg(1, strTarget, sizeof(strTarget));

	char strTargetName[MAX_TARGET_LENGTH];
	int TargetList[MAXPLAYERS], TargetCount;
	bool TargetTranslate;

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS,
	strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0)
	{
		ReplyToTargetError(client, TargetCount);
		return Plugin_Handled; 
	}

	for (int i = 0; i < TargetCount; i++)
	{ 
		if (TargetList[i] > 0 && TargetList[i] != client && IsClientInGame(TargetList[i]) && !CheckCommandAccess(TargetList[i], "sm_rcon", ADMFLAG_ROOT, true))
		{
			unSLAMTargetedPlayer(client, TargetList[i]);
		}
	}
	return Plugin_Handled;
}

stock void DisplayunSLAMMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_unSLAMMenu);
	SetMenuTitle(menu, "SLAM letiltása");
	SetMenuExitBackButton(menu, true);

	AddTargetsToMenu2(menu, 0, COMMAND_FILTER_NO_BOTS);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_unSLAMMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Select:
		{
			char info[32];
			int target;

			GetMenuItem(menu, param2, info, sizeof(info));
			int userid = StringToInt(info);
			
			if ((target = GetClientOfUserId(userid)) == 0)
			{
				PrintToChat(param1, "[\x04SLAM\x01] \x02Ez a játékos nem elérhető!");
			}
			else
			{
				if (!CheckCommandAccess(target, "sm_rcon", ADMFLAG_ROOT, true))
				{
					unSLAMTargetedPlayer(param1, target);
				}
			}
		}
	}
}

public void unSLAMTargetedPlayer(int client, int target)
{
	miew[target] = false;
	HLDJ[target] = 0;
	PrintToChatAll("[\x04SLAM\x01] \x06%N \x02nem használhatja \x01a \x06SLAM\x01-et!", target);
}

public Action Command_AddSLAM(int client, int args)
{
	if(client == 0)
	{
		PrintToChat(client, "[\x04SLAM\x01] \x02Nem lehet használni rcon-ból!");
		return Plugin_Handled;
	}

	if(args < 1) 
	{
		ReplyToCommand(client, "[\x04SLAM\x01] \x02Használat: \x04!slam \x02<játékos>");
		DisplaySLAMMenu(client);
		return Plugin_Handled;
	}

	char arg2[10];
	GetCmdArg(2, arg2, sizeof(arg2));

	char strTarget[32];
	GetCmdArg(1, strTarget, sizeof(strTarget));

	char strTargetName[MAX_TARGET_LENGTH];
	int TargetList[MAXPLAYERS], TargetCount;
	bool TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS,
	strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0)
	{
		ReplyToTargetError(client, TargetCount);
		return Plugin_Handled;
	}

	for (int i = 0; i < TargetCount; i++) 
	{ 
		if (TargetList[i] > 0 && TargetList[i] != client && IsClientInGame(TargetList[i]) && !CheckCommandAccess(TargetList[i], "sm_rcon", ADMFLAG_ROOT, true))
		{
			SLAMTargetedPlayer(client, TargetList[i]);
		}
	}
	return Plugin_Handled;
}

stock void DisplaySLAMMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_SLAMMenu);
	SetMenuTitle(menu, "SLAM engedélyezése");
	SetMenuExitBackButton(menu, true);

	AddTargetsToMenu2(menu, 0, COMMAND_FILTER_NO_BOTS);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_SLAMMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Select:
		{
			char info[32];
			int target;
			
			GetMenuItem(menu, param2, info, sizeof(info));
			int userid = StringToInt(info);
			
			if ((target = GetClientOfUserId(userid)) == 0)
			{
				PrintToChat(param1, "[\x04SLAM\x01] \x02Ez a játékos nem elérhető!");
			}
			else
			{
				if(!CheckCommandAccess(target, "sm_rcon", ADMFLAG_ROOT, true))
				{
					SLAMTargetedPlayer(param1, target);
				}
			}
		}
	}
}

public void SLAMTargetedPlayer(int client, int target)
{
	miew[target] = true;
	PrintToChatAll("[\x04SLAM\x01] \x02%N \x06használhatja \x01a \x02SLAM\x01-et!", target);
}

public Action:PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new clientid = GetEventInt(event,"userid");
	new client = GetClientOfUserId(clientid);
	IsSpeaking[client] = 0;
	HLDJ[client] = 0;
}

public void OnClientSpeakingEx(client)
{
	if (HLDJ[client] != -1)
	{
		if (IsSpeaking[client] == 0)
		{
			QueryClientConVar(client, "voice_inputfromfile", ConVarQueryFinished:ClientConVar, client);
			IsSpeaking[client] = 1;
		} else if (HLDJ[client] == 0)
		{
			if (GetRandomInt(0,100) == 100)
			{
				QueryClientConVar(client, "voice_inputfromfile", ConVarQueryFinished:ClientConVar, client);
			}
		}
	}
}

public OnClientSpeakingEnd(client)
{
	if (IsValidClient(client))
	{
		IsSpeaking[client] = 0;
	}
}

public ClientConVar(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	decl String:nick[64];
	GetClientName(client, nick, sizeof(nick));
	new Value = StringToInt(cvarValue);
	if (Value == 1 && IsClientSpeaking(client))
	{
		char steamId[64];
		GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
		if (CheckCommandAccess(client, "sm_rcon", ADMFLAG_ROOT, true))
		{
		}
		else
		{
			if (miew[client] == false)
			{
				if (HLDJ[client] == 0)
				{
					CreateTimer(5.0, ReCheck, client);
					PrintToChat(client, "[\x04SLAM\x01] \x06Észleltük nálad, hogy \x02SLAM-et \x06használsz! Fejezd be \x025 \x06másodpercen belül!");
					HLDJ[client] = 1;
				}	else if (HLDJ[client] == 1)
				{
					new clientid = GetClientUserId(client);
					ServerCommand("sm_mute #%i 60 \"SLAM/HLDJ használat\"", clientid);
					PrintToChat(client,"[\x04SLAM\x01] \x06Némítást kaptál \x021 \x06órára \x02SLAM \x06használat miatt!", clientid);
					HLDJ[client] = 3;
				}
			}
		}
	}
}

public Action ReCheck(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		QueryClientConVar(client, "voice_inputfromfile", ConVarQueryFinished:ClientConVar, client);
	}
}

bool:IsValidClient( client )
{
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) )
		return false; 

	return true; 
}