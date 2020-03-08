#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] SB - Admin Config Loader",
	author = "AlliedModders LLC & SourceBans++ Dev Team | Edited: somebody.",
	description = "SB - Admin Config Loader",
	version = "1.0",
	url = "http://sourcemod.net"
};

bool g_LoggedFileName = false;
int g_ErrorCount = 0;
int g_IgnoreLevel = 0;
int g_CurrentLine = 0;
char g_Filename[PLATFORM_MAX_PATH];

#include "sbpp_admcfg/sbpp_admin_groups.sp"
#include "sbpp_admcfg/sbpp_admin_users.sp"

public void OnRebuildAdminCache(AdminCachePart part)
{
	if (part == AdminCache_Groups)
	{
		ReadGroups();
	} else if (part == AdminCache_Admins)
	{
		ReadUsers();
	}
}

void ParseError(const char[] format, any...)
{
	char buffer[512];

	if (!g_LoggedFileName)
	{
		LogError("Error(s) Detected Parsing %s", g_Filename);
		g_LoggedFileName = true;
	}

	VFormat(buffer, sizeof(buffer), format, 2);

	LogError(" (line %d) %s", g_CurrentLine, buffer);

	g_ErrorCount++;
}

void InitGlobalStates()
{
	g_ErrorCount = 0;
	g_IgnoreLevel = 0;
	g_CurrentLine = 0;
	g_LoggedFileName = false;
}