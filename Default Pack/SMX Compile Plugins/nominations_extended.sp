#pragma semicolon 1

#include <sourcemod>
#include <mapchooser>
#include "include/mapchooser_extended"
#include <colors>

public Plugin myinfo =
{
	name = "[CSGO] MCE - Nominations",
	author = "PowerLord & AlliedModders LLC | Edited: somebody.",
	description = "MCE - Nominations",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle:g_Cvar_ExcludeOld = INVALID_HANDLE;
new Handle:g_Cvar_ExcludeCurrent = INVALID_HANDLE;

new Handle:g_MapList = INVALID_HANDLE;
new Handle:g_MapMenu = INVALID_HANDLE;
new g_mapFileSerial = -1;

#define MAPSTATUS_ENABLED (1<<0)
#define MAPSTATUS_DISABLED (1<<1)
#define MAPSTATUS_EXCLUDE_CURRENT (1<<2)
#define MAPSTATUS_EXCLUDE_PREVIOUS (1<<3)
#define MAPSTATUS_EXCLUDE_NOMINATED (1<<4)

new Handle:g_mapTrie;
new Handle:g_Cvar_MarkCustomMaps = INVALID_HANDLE;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("nominations.phrases");
	LoadTranslations("basetriggers.phrases");
	LoadTranslations("mapchooser_extended.phrases");

	new arraySize = ByteCountToCells(PLATFORM_MAX_PATH);	
	g_MapList = CreateArray(arraySize);

	g_Cvar_ExcludeOld = CreateConVar("sm_nominate_excludeold", "1", "Specifies if the current map should be excluded from the Nominations list", 0, true, 0.00, true, 1.0);
	g_Cvar_ExcludeCurrent = CreateConVar("sm_nominate_excludecurrent", "1", "Specifies if the MapChooser excluded maps should also be excluded from Nominations", 0, true, 0.00, true, 1.0);

	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);

	RegConsoleCmd("sm_nominate", Command_Nominate);

	RegAdminCmd("sm_nominate_addmap", Command_Addmap, ADMFLAG_CHANGEMAP, "sm_nominate_addmap <mapname> - Forces a map to be on the next mapvote.");

	g_mapTrie = CreateTrie();
}

public OnAllPluginsLoaded()
{
	g_Cvar_MarkCustomMaps = FindConVar("mce_markcustommaps");
}

public OnConfigsExecuted()
{
	if (ReadMapList(g_MapList,
					g_mapFileSerial,
					"nominations",
					MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_MAPSFOLDER)
		== INVALID_HANDLE)
	{
		if (g_mapFileSerial == -1)
		{
			SetFailState("Unable to create a valid map list.");
		}
	}
	
	BuildMapMenu();
}

public OnNominationRemoved(const String:map[], owner)
{
	new status;

	if (!GetTrieValue(g_mapTrie, map, status))
	{
		return;	
	}

	if ((status & MAPSTATUS_EXCLUDE_NOMINATED) != MAPSTATUS_EXCLUDE_NOMINATED)
	{
		return;
	}

	SetTrieValue(g_mapTrie, map, MAPSTATUS_ENABLED);	
}

public Action:Command_Addmap(client, args)
{
	if (args < 1)
	{
		CReplyToCommand(client, "[NE] Usage: sm_nominate_addmap <mapname>");
		return Plugin_Handled;
	}
	
	decl String:mapname[PLATFORM_MAX_PATH];
	GetCmdArg(1, mapname, sizeof(mapname));

	
	new status;
	if (!GetTrieValue(g_mapTrie, mapname, status))
	{
		CReplyToCommand(client, "%t", "Map was not found", mapname);
		return Plugin_Handled;		
	}
	
	new NominateResult:result = NominateMap(mapname, true, 0);
	
	if (result > Nominate_Replaced)
	{
		CReplyToCommand(client, "%t", "Map Already In Vote", mapname);
		
		return Plugin_Handled;	
	}
	
	
	SetTrieValue(g_mapTrie, mapname, MAPSTATUS_DISABLED|MAPSTATUS_EXCLUDE_NOMINATED);

	
	CReplyToCommand(client, "%t", "Map Inserted", mapname);
	LogAction(client, -1, "\"%L\" inserted map \"%s\".", client, mapname);

	return Plugin_Handled;		
}

public Action:Command_Say(client, args)
{
	if (!client)
	{
		return Plugin_Continue;
	}

	decl String:text[192];
	if (!GetCmdArgString(text, sizeof(text)))
	{
		return Plugin_Continue;
	}
	
	new startidx = 0;
	if(text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	
	new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
	
	if (strcmp(text[startidx], "nominate", false) == 0)
	{
		if (IsNominateAllowed(client))
		{
			AttemptNominate(client);
		}
	}
	
	SetCmdReplySource(old);
	
	return Plugin_Continue;	
}

public Action:Command_Nominate(client, args)
{
	if (!client || !IsNominateAllowed(client))
	{
		return Plugin_Handled;
	}
	
	if (args == 0)
	{
		AttemptNominate(client);
		return Plugin_Handled;
	}
	
	decl String:mapname[PLATFORM_MAX_PATH];
	decl String:displayName[PLATFORM_MAX_PATH];
	GetCmdArg(1, displayName, sizeof(displayName));
	
	new status;
	if (FindMap(displayName, mapname, sizeof(mapname)) == FindMap_NotFound)
	{
		CReplyToCommand(client, "%t", "Map was not found", mapname);
		return Plugin_Handled;		
	}
	if (!GetTrieValue(g_mapTrie, mapname, status)) {
		CReplyToCommand(client, "%t", "Map was not found", mapname);
		return Plugin_Handled;		
	}
	
	if ((status & MAPSTATUS_DISABLED) == MAPSTATUS_DISABLED)
	{
		if ((status & MAPSTATUS_EXCLUDE_CURRENT) == MAPSTATUS_EXCLUDE_CURRENT)
		{
			CReplyToCommand(client, "[NE] %t", "Can't Nominate Current Map");
		}
		
		if ((status & MAPSTATUS_EXCLUDE_PREVIOUS) == MAPSTATUS_EXCLUDE_PREVIOUS)
		{
			CReplyToCommand(client, "[NE] %t", "Map in Exclude List");
		}
		
		if ((status & MAPSTATUS_EXCLUDE_NOMINATED) == MAPSTATUS_EXCLUDE_NOMINATED)
		{
			CReplyToCommand(client, "[NE] %t", "Map Already Nominated");
		}
		
		return Plugin_Handled;
	}
	
	new NominateResult:result = NominateMap(mapname, false, client);
	
	if (result > Nominate_Replaced)
	{
		if (result == Nominate_AlreadyInVote)
		{
			CReplyToCommand(client, "%t", "Map Already In Vote", mapname);
		}
		else
		{
			CReplyToCommand(client, "[NE] %t", "Map Already Nominated");
		}
		
		return Plugin_Handled;	
	}

	SetTrieValue(g_mapTrie, mapname, MAPSTATUS_DISABLED|MAPSTATUS_EXCLUDE_NOMINATED);

	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	PrintToChatAll("[NE] %t", "Map Nominated", name, mapname);
	LogMessage("%s nominated %s", name, mapname);

	return Plugin_Continue;
}

AttemptNominate(client)
{
	SetMenuTitle(g_MapMenu, "%T", "Nominate Title", client);
	DisplayMenu(g_MapMenu, client, MENU_TIME_FOREVER);
	
	return;
}

BuildMapMenu()
{
	if (g_MapMenu != INVALID_HANDLE)
	{
		CloseHandle(g_MapMenu);
		g_MapMenu = INVALID_HANDLE;
	}
	
	ClearTrie(g_mapTrie);
	
	g_MapMenu = CreateMenu(Handler_MapSelectMenu, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem|MenuAction_DisplayItem);

	decl String:map[PLATFORM_MAX_PATH];
	
	new Handle:excludeMaps = INVALID_HANDLE;
	decl String:currentMap[32];
	
	if (GetConVarBool(g_Cvar_ExcludeOld))
	{	
		excludeMaps = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
		GetExcludeMapList(excludeMaps);
	}
	
	if (GetConVarBool(g_Cvar_ExcludeCurrent))
	{
		GetCurrentMap(currentMap, sizeof(currentMap));
	}
	
		
	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		new status = MAPSTATUS_ENABLED;
		
		GetArrayString(g_MapList, i, map, sizeof(map));
		
		if (GetConVarBool(g_Cvar_ExcludeCurrent))
		{
			if (StrEqual(map, currentMap))
			{
				status = MAPSTATUS_DISABLED|MAPSTATUS_EXCLUDE_CURRENT;
			}
		}

		if (GetConVarBool(g_Cvar_ExcludeOld) && status == MAPSTATUS_ENABLED)
		{
			if (FindStringInArray(excludeMaps, map) != -1)
			{
				status = MAPSTATUS_DISABLED|MAPSTATUS_EXCLUDE_PREVIOUS;
			}
		}
		
		AddMenuItem(g_MapMenu, map, map);
		SetTrieValue(g_mapTrie, map, status);
	}
	
	SetMenuExitButton(g_MapMenu, true);

	if (excludeMaps != INVALID_HANDLE)
	{
		CloseHandle(excludeMaps);
	}
}

public Handler_MapSelectMenu(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:map[PLATFORM_MAX_PATH], String:name[MAX_NAME_LENGTH];
			GetMenuItem(menu, param2, map, sizeof(map));		
			
			GetClientName(param1, name, MAX_NAME_LENGTH);
	
			new NominateResult:result = NominateMap(map, false, param1);

			if (result == Nominate_AlreadyInVote)
			{
				PrintToChat(param1, "[NE] %t", "Map Already Nominated");
				return 0;
			}
			else if (result == Nominate_VoteFull)
			{
				PrintToChat(param1, "[NE] %t", "Max Nominations");
				return 0;
			}
			
			SetTrieValue(g_mapTrie, map, MAPSTATUS_DISABLED|MAPSTATUS_EXCLUDE_NOMINATED);

			if (result == Nominate_Replaced)
			{
				PrintToChatAll("[NE] %t", "Map Nomination Changed", name, map);
				return 0;	
			}
			
			PrintToChatAll("[NE] %t", "Map Nominated", name, map);
			LogMessage("%s nominated %s", name, map);
		}
		
		case MenuAction_DrawItem:
		{
			decl String:map[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, map, sizeof(map));
			
			new status;
			
			if (!GetTrieValue(g_mapTrie, map, status))
			{
				LogError("Menu selection of item not in trie. Major logic problem somewhere.");
				return ITEMDRAW_DEFAULT;
			}
			
			if ((status & MAPSTATUS_DISABLED) == MAPSTATUS_DISABLED)
			{
				return ITEMDRAW_DISABLED;	
			}
			
			return ITEMDRAW_DEFAULT;
						
		}
		
		case MenuAction_DisplayItem:
		{
			decl String:map[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, map, sizeof(map));
			
			new mark = GetConVarInt(g_Cvar_MarkCustomMaps);
			new bool:official;

			new status;
			
			if (!GetTrieValue(g_mapTrie, map, status))
			{
				LogError("Menu selection of item not in trie. Major logic problem somewhere.");
				return 0;
			}
			
			decl String:buffer[100];
			decl String:display[150];
			
			if (mark)
			{
				official = IsMapOfficial(map);
			}
			
			if (mark && !official)
			{
				switch (mark)
				{
					case 1:
					{
						Format(buffer, sizeof(buffer), "%T", "Custom Marked", param1, map);
					}
					
					case 2:
					{
						Format(buffer, sizeof(buffer), "%T", "Custom", param1, map);
					}
				}
			}
			else
			{
				strcopy(buffer, sizeof(buffer), map);
			}
			
			if ((status & MAPSTATUS_DISABLED) == MAPSTATUS_DISABLED)
			{
				if ((status & MAPSTATUS_EXCLUDE_CURRENT) == MAPSTATUS_EXCLUDE_CURRENT)
				{
					Format(display, sizeof(display), "%s (%T)", buffer, "Current Map", param1);
					return RedrawMenuItem(display);
				}
				
				if ((status & MAPSTATUS_EXCLUDE_PREVIOUS) == MAPSTATUS_EXCLUDE_PREVIOUS)
				{
					Format(display, sizeof(display), "%s (%T)", buffer, "Recently Played", param1);
					return RedrawMenuItem(display);
				}
				
				if ((status & MAPSTATUS_EXCLUDE_NOMINATED) == MAPSTATUS_EXCLUDE_NOMINATED)
				{
					Format(display, sizeof(display), "%s (%T)", buffer, "Nominated", param1);
					return RedrawMenuItem(display);
				}
			}
			
			if (mark && !official)
				return RedrawMenuItem(buffer);
			
			return 0;
		}
	}
	
	return 0;
}

stock bool:IsNominateAllowed(client)
{
	new CanNominateResult:result = CanNominate();

	switch(result)
	{
		case CanNominate_No_VoteInProgress:
		{
			CReplyToCommand(client, "[ME] %t", "Nextmap Voting Started");
			return false;
		}

		case CanNominate_No_VoteComplete:
		{
			new String:map[PLATFORM_MAX_PATH];
			GetNextMap(map, sizeof(map));
			CReplyToCommand(client, "[NE] %t", "Next Map", map);
			return false;
		}

		case CanNominate_No_VoteFull:
		{
			CReplyToCommand(client, "[ME] %t", "Max Nominations");
			return false;
		}
	}

	return true;
}