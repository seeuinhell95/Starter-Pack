#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin myinfo =
{
	name = "[CSGO] Clan Tag Kicker",
	author = "PeEzZ | Edited: somebody.",
	description = "Clan Tag Kicker",
	version = "1.0",
	url = "http://sourcemod.net"
};

#define TIME_CHECK 3.0
#define TIME_BLOCK 5.0
#define STR_RENAME "x EasY x"

new bool: g_bImBlocked[MAXPLAYERS + 1];

new String: DisallowedClan[][] =
{
	"Owner", "Tulaj", "Admin", "ViP", "EzFrags", "Ez Frags", "EzHook", "Ez Hook", "Aim", "Hack", "Cheat"
};

new String: DisallowedName[][] =
{
	"Owner", "Tulaj", "Admin", "ViP", "EzFrags", "Ez Frags", "EzHook", "Ez Hook", "Aim", "Hack", "Cheat"
};

new String: DisallowedChat[][] =
{
	".hu", ".eu", ".com", ".ru", ".uk", ".net", ".org"
};

public OnPluginStart()
{
	AddCommandListener(CMD_Say, "say");
	AddCommandListener(CMD_Say, "say_team");

	CreateTimer(TIME_CHECK, Timer_Check);

	LoadTranslations("clankicker.phrases");
}

public OnClientPutInServer(client)
{
	g_bImBlocked[client] = false;
}

public Action: OnClientCommandKeyValues(client, KeyValues: keyvalue)
{
	if(!(GetUserFlagBits(client) & ADMFLAG_GENERIC))
	{
		new String: buffer[16];
		if(KvGetSectionName(keyvalue, buffer, sizeof(buffer)) && StrEqual(buffer, "ClanTagChanged", false))
		{
			if(g_bImBlocked[client] || (TIME_BLOCK == 0))
			{
				return Plugin_Handled;
			}
			else
			{
				g_bImBlocked[client] = true;
				CreateTimer(60 * TIME_BLOCK, Timer_Unblock, client);
				PrintToChat(client, "[SM] %t", "BlockMessage", RoundToNearest(TIME_BLOCK));
				
				return Plugin_Continue;
			}
		}
	}
	return Plugin_Continue;
}

public Action: CMD_Say(client, const String: command[], args) 
{
	if(!IsClientValid(client) || !IsClientInGame(client) || (GetUserFlagBits(client) & ADMFLAG_GENERIC))
	{
		return Plugin_Continue;
	}

	new String: buffer[128];
	GetCmdArgString(buffer, sizeof(buffer));
	for(new i = 0; i < sizeof(DisallowedChat); i++)
	{
		if(StrContains(buffer, DisallowedChat[i], false) != -1)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action: Timer_Unblock(Handle: timer, any: client)
{
	if(IsClientInGame(client))
	{
		g_bImBlocked[client] = false;
	}
}

public Action: Timer_Check(Handle: timer)
{
	new String: buffer[32];
	for(new client = 1; client <= MaxClients; client ++)
	{
		if(IsClientInGame(client) && !(GetUserFlagBits(client) & ADMFLAG_GENERIC))
		{
			CS_GetClientClanTag(client, buffer, sizeof(buffer));
			for(new i = 0; i < sizeof(DisallowedClan); i++)
			{
				if(StrContains(buffer, DisallowedClan[i], false) != -1)
				{
					CS_SetClientClanTag(client, STR_RENAME);
				}
			}

			GetClientName(client, buffer, sizeof(buffer));
			for(new i = 0; i < sizeof(DisallowedName); i++)
			{
				if(StrContains(buffer, DisallowedName[i], false) != -1)
				{
					KickClient(client, "%t", "DisallowedName", DisallowedName[i]);
				}
			}
		}
	}
	CreateTimer(TIME_CHECK, Timer_Check);
}

bool: IsClientValid(client)
{
	return ((client > 0) && (client <= MaxClients));
}