#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name		=	"[CSGO] Steam Group Info",
	author		=	"PeEzZ | Edited: somebody.",
	description	=	"Steam Group Info",
	version		=	"1.0",
	url			=	"http://sourcemod.net"
};

public OnPluginStart()
{
	LoadTranslations("steamgroup.phrases");

	RegConsoleCmd("sm_steamgroup", CMD_SteamGroup);
	RegConsoleCmd("sm_group", CMD_SteamGroup);
	RegConsoleCmd("sm_steam", CMD_SteamGroup);
	RegConsoleCmd("sm_join", CMD_SteamGroup);
	RegConsoleCmd("sm_link", CMD_SteamGroup);

	RegConsoleCmd("sm_discord", CMD_Discord);
	RegConsoleCmd("sm_disc", CMD_Discord);
	RegConsoleCmd("sm_dc", CMD_Discord);

	RegConsoleCmd("sm_rules", CMD_Rules);

	RegConsoleCmd("sm_steamprofile", CMD_SteamProfile);
	RegConsoleCmd("sm_profile", CMD_SteamProfile);
	RegConsoleCmd("sm_owner", CMD_SteamProfile);
	RegConsoleCmd("sm_tulaj", CMD_SteamProfile);
	RegConsoleCmd("sm_tulajdonos", CMD_SteamProfile);
}

public Action: CMD_SteamGroup(client, args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	PrintToChat(client, "[\x04Steam\x01] \x06%t", "CMD_SteamGroup");
	PrintToChat(client, "[\x04Steam\x01] \x06%t", "CMD_SteamLink");

	return Plugin_Handled;
}

public Action: CMD_Discord(client, args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	PrintToChat(client, "[\x04Discord\x01] \x06%t", "CMD_Discord");

	return Plugin_Handled;
}

public Action: CMD_Rules(client, args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	PrintToChat(client, "[\x04Rules\x01] \x06%t", "CMD_Rules");

	return Plugin_Handled;
}

public Action: CMD_SteamProfile(client, args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	PrintToChat(client, "[\x04Profile\x01] \x06%t", "CMD_SteamProfile");

	return Plugin_Handled;
}