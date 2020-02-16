#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "[CSGO] Admin Log",
	author = "VirDan | Edited: somebody.",
	description = "Admin Log",
	version = "1.0",
	url = "http://sourcemod.net"
};

public Action:OnLogAction(Handle:source, 
						   Identity:ident,
						   client,
						   target,
						   const String:message[])
{
	if (client < 1 || GetUserAdmin(client) == INVALID_ADMIN_ID)
	{
		return Plugin_Continue;
	}

	decl String:logtag[64];

	if (ident == Identity_Plugin)
	{
		GetPluginFilename(source, logtag, sizeof(logtag));
	} else {
		strcopy(logtag, sizeof(logtag), "SM");
	}

	decl String:steamid[32];
	decl String:name[40];
	GetAdminUsername(GetUserAdmin(client), name, sizeof(name));
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
	ReplaceString(steamid, sizeof(steamid), ":", "-");

	decl String:file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), "logs/Admin_%s_%s.log", name, steamid);

	LogToFileEx(file, "[%s] %s", logtag, message);

	return Plugin_Handled;
}