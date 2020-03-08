#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>

#pragma newdecls required

#define TAG "[SM] "

Handle g_hTopMenu = null;

ConVar gcv_iArraySize = null;

ArrayList ga_Names;
ArrayList ga_SteamIds;
ArrayList ga_IPs;

public Plugin myinfo =
{
	name = "[CSGO] SB - Disconnected Bans",
	author = "HeadLine & MadHamster | Edited: Cherry & somebody.",
	description = "SB - Disconnected Bans",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	gcv_iArraySize = CreateConVar("hl_bandisconnected_max", "100", "List size of ban disconnected players menu");

	RegAdminCmd("sm_bandisconnected", Command_BanDisconnected, ADMFLAG_BAN, "Ban a player after they have disconnected!");
	RegAdminCmd("sm_listdisconnected", Command_ListDisconnected, ADMFLAG_BAN, "List all disconnected players!");
	RegAdminCmd("sm_bandisconnectedip", Command_BanDisconnectedip, ADMFLAG_BAN, "Ban a player after they have disconnected!");

	AddCommandListener(FakeDCBan, "sm_fakedcban");
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

	Handle topmenu;
	if(LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(topmenu);
	}
	LoadADTArray();
}

public Action FakeDCBan(int client, const char[] cmd, int argc)
{
	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client)
{
	char sSteamID[32];
	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));

	char clientIP[32];
	GetClientIP(client, clientIP, sizeof(clientIP));

	if (FindStringInArray(ga_SteamIds, sSteamID) != -1 || FindStringInArray(ga_IPs, clientIP) != -1)
	{
		ga_Names.Erase(ga_SteamIds.FindString(sSteamID));
		ga_SteamIds.Erase(ga_SteamIds.FindString(sSteamID));
		ga_IPs.Erase(ga_IPs.FindString(clientIP));
	}
}

public Action Event_PlayerDisconnect(Event hEvent, char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (IsValidClient(client))
	{
		char sName[MAX_NAME_LENGTH];
		GetClientName(client, sName, sizeof(sName));

		char sDisconnectedSteamID[32];
		GetClientAuthId(client, AuthId_Steam2, sDisconnectedSteamID, sizeof(sDisconnectedSteamID));

		char clientIP[32];
		GetClientIP(client, clientIP, sizeof(clientIP));

		if (FindStringInArray(ga_SteamIds, sDisconnectedSteamID) == -1 || FindStringInArray(ga_IPs, clientIP) == -1 )
		{
			PushToArrays(sName, sDisconnectedSteamID,clientIP);
		}
	}
}

void PushToArrays(const char[] clientName, const char[] clientSteam, const char[] clientIP)
{	
	if (ga_Names.Length == 0)
	{
		ga_Names.PushString(clientName);
		ga_SteamIds.PushString(clientSteam);
		ga_IPs.PushString(clientIP);
	}
	else
	{
		ga_Names.ShiftUp(0);
		ga_SteamIds.ShiftUp(0);
		ga_IPs.ShiftUp(0);

		ga_Names.SetString(0, clientName);
		ga_SteamIds.SetString(0, clientSteam);
		ga_IPs.SetString(0, clientIP);
	}

	if (ga_Names.Length >= gcv_iArraySize.IntValue && gcv_iArraySize.IntValue > 0)
	{
		ga_Names.Resize(gcv_iArraySize.IntValue);
		ga_SteamIds.Resize(gcv_iArraySize.IntValue);
		ga_IPs.Resize(gcv_iArraySize.IntValue);
	}
}

public Action Command_BanDisconnected(int client, int args)
{
	if (args != 3)
	{
		ReplyToCommand(client, " %sHasználat: sm_bandisconnected <\"steamid\"> <perc|0> [\"indok\"]", TAG);
		return Plugin_Handled;
	}
	else
	{
		char steamid[20], minutes[10], reason[256];
		GetCmdArg(1, steamid, sizeof(steamid));
		GetCmdArg(2, minutes, sizeof(minutes));
		GetCmdArg(3, reason,  sizeof(reason));
		CheckAndPerformBan(client, steamid, StringToInt(minutes), reason);
	}
	return Plugin_Handled;
}

public Action Command_BanDisconnectedip(int client, int args)
{
	if (args != 3)
	{
		ReplyToCommand(client, " %sHasználat: sm_bandisconnected <\"ip\"> <perc|0> [\"indok\"]", TAG);
		return Plugin_Handled;
	}
	else
	{
		char ipp[20], minutes[10], reason[256];
		GetCmdArg(1, ipp, sizeof(ipp));
		GetCmdArg(2, minutes, sizeof(minutes));
		GetCmdArg(3, reason,  sizeof(reason));
		FakeClientCommand(client, "sm_banip \"%s\" %d %s", ipp, StringToInt(minutes), reason);
	}
	return Plugin_Handled;
}

public Action Command_ListDisconnected(int client, int args)
{
	if (ga_Names.Length >= 10)
	{
		PrintToConsole(client, "************ LAST 10 DISCONNECTED PLAYERS *****************");
		for (int i = 0; i <= 10; i++)
		{
			char sName[MAX_TARGET_LENGTH], sSteamID[32], clientIP[32];
			
			ga_Names.GetString(i, sName, sizeof(sName));
			ga_SteamIds.GetString(i, sSteamID, sizeof(sSteamID));
			ga_IPs.GetString(i, clientIP, sizeof(clientIP));

			PrintToConsole(client, "NAME : %s  STEAMID : %s  IP : %s", sName, sSteamID, clientIP);
		}
		PrintToConsole(client, "************ LAST 10 DISCONNECTED PLAYERS *****************");
	}
	else
	{
		if (ga_Names.Length == 0)
		{
			PrintToConsole(client, "[SM] Jelenleg nincsenek lelépett játékosok a listában!");
		}
		else
		{
			PrintToConsole(client, "************ LAST %i DISCONNECTED PLAYERS *****************", GetArraySize(ga_Names) - 1);
			for (int i = 0; i < ga_Names.Length; i++)
			{
				char sName[MAX_TARGET_LENGTH], sSteamID[32], clientIP[32];
				
				ga_Names.GetString(i, sName, sizeof(sName));
				ga_SteamIds.GetString(i, sSteamID, sizeof(sSteamID));
				ga_IPs.GetString(i, clientIP, sizeof(clientIP));

				PrintToConsole(client, "** %s | %s | %s **", sName, sSteamID, clientIP);
			}
			PrintToConsole(client, "************ LAST %i DISCONNECTED PLAYERS *****************", GetArraySize(ga_Names) - 1);
		}
	}
	return Plugin_Handled;
}

void CheckAndPerformBan(int client, char[] steamid, int minutes, char[] reason)
{
	AdminId admClient = GetUserAdmin(client);
	AdminId admTarget;
	if ((admTarget = FindAdminByIdentity(AUTHMETHOD_STEAM, steamid)) == INVALID_ADMIN_ID || CanAdminTarget(admClient, admTarget))
	{
		bool hasRoot = GetAdminFlag(admClient, Admin_Root);
		SetAdminFlag(admClient, Admin_Root, true);
		FakeClientCommand(client, "sm_addban %d \"%s\" %s", minutes, steamid, reason);
		SetAdminFlag(admClient, Admin_Root, hasRoot);
	}
	else
	{
		ReplyToCommand(client, " %sNem tilthatsz ki egy magasabb szintű adminisztrátort.", TAG);
	}
}

public void OnAdminMenuReady(Handle hTopMenu)
{
	if(hTopMenu == g_hTopMenu)
	{
		return;
	}

	g_hTopMenu = hTopMenu;

	TopMenuObject MenuObject = FindTopMenuCategory(hTopMenu, ADMINMENU_PLAYERCOMMANDS);
	if(MenuObject == INVALID_TOPMENUOBJECT)
	{
		return;
	} 
	AddToTopMenu(hTopMenu, "sm_bandisconnected", TopMenuObject_Item, AdminMenu_Ban, MenuObject, "sm_bandisconnected", ADMFLAG_BAN, "Ban Disconnected Player");
}

public void AdminMenu_Ban(Handle hTopMenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Játékos kitiltása (lelépett)");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayTargetsMenu(param);
	}
}

public void DisplayTargetsMenu(int client) 
{
	if (ga_SteamIds.Length == 0)
	{
		ReplyToCommand(client, "[SM] Jelenleg nincsenek lelépett játékosok a listában.");
		return;
	}

	Menu MainMenu = new Menu(TargetsMenu_CallBack, MenuAction_Select | MenuAction_End); 
	MainMenu.SetTitle("Válassz játékost:"); 

	char sDisplayBuffer[128], sSteamID[32], clientIP[32], sName[MAX_NAME_LENGTH], steamipbuffer[64];
	for (int i = 0; i < ga_SteamIds.Length; i++)
	{
		ga_Names.GetString(i, sName, sizeof(sName));

		ga_SteamIds.GetString(i, sSteamID, sizeof(sSteamID));

		ga_IPs.GetString(i, clientIP, sizeof(clientIP));

		Format(sDisplayBuffer, sizeof(sDisplayBuffer), "%s (%s)", sName, sSteamID);

		Format(steamipbuffer, sizeof(steamipbuffer), "%s,%s,%s", sSteamID, clientIP,sName);

		MainMenu.AddItem(steamipbuffer, sDisplayBuffer); 
	}
	SetMenuExitBackButton(MainMenu, true);
	DisplayMenu(MainMenu, client, MENU_TIME_FOREVER); 
}

public int TargetsMenu_CallBack(Menu MainMenu, MenuAction action, int param1, int param2) 
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sInfo[128];
			GetMenuItem(MainMenu, param2, sInfo, sizeof(sInfo));

			DisplayBanTimeMenu(param1, sInfo);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(MainMenu);
		}
	}
}

public void DisplayBanTimeMenu(int client, char[] sInfo)
{
	Menu BanTimeMenu = new Menu(BanTime_CallBack, MenuAction_Select | MenuAction_End); 
	BanTimeMenu.SetTitle("Időtartam:"); 
	char sInfoBuffer[128];

	Format(sInfoBuffer, sizeof(sInfoBuffer), "%s,0", sInfo);
	BanTimeMenu.AddItem(sInfoBuffer, "Végleges");

	SetMenuExitBackButton(BanTimeMenu, true);
	DisplayMenu(BanTimeMenu, client, MENU_TIME_FOREVER); 
}

public int BanTime_CallBack(Handle BanTimeMenu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sInfo[128];
			GetMenuItem(BanTimeMenu, param2, sInfo, sizeof(sInfo));
			
			DisplayBanReasonMenu(param1, sInfo);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(BanTimeMenu);
		}
	}
}

void DisplayBanReasonMenu(int client, char[] sInfo)
{
	Menu BanReasonMenu = new Menu(BanReason_CallBack, MenuAction_Select | MenuAction_End); 
	BanReasonMenu.SetTitle("Indok:"); 
	char sInfoBuffer[128];

	Format(sInfoBuffer, sizeof(sInfoBuffer), "%s,Offline Kitiltás", sInfo);
	BanReasonMenu.AddItem(sInfoBuffer, "Offline Kitiltás");

	SetMenuExitBackButton(BanReasonMenu, true);
	DisplayMenu(BanReasonMenu, client, MENU_TIME_FOREVER);
}

public int BanReason_CallBack(Handle BanReasonMenu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sInfo[128], sTempArray[5][64];
			GetMenuItem(BanReasonMenu, param2, sInfo, sizeof(sInfo));
			ExplodeString(sInfo, ",", sTempArray, 5, 64);
			FakeClientCommand(param1, "sm_fakedcban \"%s\" \"%s\" \"%s\" %d \"%s\"", sTempArray[0], sTempArray[1],sTempArray[2], StringToInt(sTempArray[3]), sTempArray[4]);
			PrintToChat(param1, "[SM] Sikeresen kitiltottad a kiválasztott lecsatlakozott játékost!");
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && g_hTopMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(g_hTopMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(BanReasonMenu);
		}
	}
}

void LoadADTArray()
{
	ga_Names = new ArrayList(MAX_TARGET_LENGTH);
	ga_SteamIds = new ArrayList(32);
	ga_IPs = new ArrayList(32);
}

bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}