#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <geoip>

public Plugin myinfo =
{
	name = "[CSGO] Player List",
	author = "O!KAK & Dimic | Edited: somebody.",
	description = "Player List",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_playerslist", Command_Users, ADMFLAG_GENERIC, "Show list players on a server");
	RegAdminCmd("sm_playerlist", Command_Users, ADMFLAG_GENERIC, "Show list players on a server");
	RegAdminCmd("sm_plist", Command_Users, ADMFLAG_GENERIC, "Show list players on a server");
	RegAdminCmd("sm_users", Command_Users, ADMFLAG_GENERIC, "Show list players on a server");
	RegAdminCmd("sm_user", Command_Users, ADMFLAG_GENERIC, "Show list players on a server");
}

public Action: Command_Users(client, args)
{
	decl String:t_name[64], String:t_ip[24], String:t_steamid2[24], String:t_steamid3[24], String:t_country[10], String:code[4], String:t_team[16];

	Format(t_name, sizeof(t_name), "Name");
	Format(t_ip, sizeof(t_ip), "IP");
	Format(t_steamid2, sizeof(t_steamid2), "SteamID v2");
	Format(t_steamid3, sizeof(t_steamid3), "SteamID v3");
	Format(t_country, sizeof(t_country), "[=]");
	Format(t_team, sizeof(t_team), "  F:D    Team");

	PrintToConsole(client, "+-----------------------------------------------------------------------------------------------------------+");
	PrintToConsole(client, " %20s %16s %17s %5s %s   ####   %s", t_steamid2, t_steamid3, t_ip, t_country, t_team, t_name);
	PrintToConsole(client, "+-----------------------------------------------------------------------------------------------------------+");

	new count = 0, bool:find;
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			count++;
			GetClientName(i, t_name, sizeof(t_name));
			GetClientIP(i, t_ip, sizeof(t_ip));
			GetClientAuthId(i, AuthId_Steam2, t_steamid2, sizeof(t_steamid2));
			GetClientAuthId(i, AuthId_Steam3, t_steamid3, sizeof(t_steamid3));
			switch( GetClientTeam(i) ) {

				case 1: {
					Format(t_team, sizeof(t_team), "SPEC");
				}

				case 2: {
					Format(t_team, sizeof(t_team), "RED ");
				}

				case 3: {
					Format(t_team, sizeof(t_team), "BLUE");
				}

				default: {
					Format(t_team, sizeof(t_team), "-_- ");
				}
			}

			find = GeoipCode3(t_ip, code);
			if(!find) {
				Format(t_country, sizeof(t_country), "---");
				PrintToConsole(client, " %20s %16s %17s %4s %4d:%-4d %s   %4d   %s",
									t_steamid2, t_steamid3, t_ip, t_country, GetClientFrags(i), GetClientDeaths(i), t_team, GetClientUserId(i), t_name);
			} else {
				PrintToConsole(client, " %20s %16s %17s %4s %4d:%-4d %s   %4d   %s",
									t_steamid2, t_steamid3, t_ip, code, GetClientFrags(i), GetClientDeaths(i), t_team, GetClientUserId(i), t_name);
			}

		}
	}

	PrintToConsole(client, "+-[%d]------------------------------------------------------------------------------------------------------+", count);

	if(GetCmdReplySource() == SM_REPLY_TO_CHAT)
	PrintToChat(client, "[SM] See console for output.");

	return Plugin_Handled;
}