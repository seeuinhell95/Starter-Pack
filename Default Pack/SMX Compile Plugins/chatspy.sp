#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#pragma newdecls required

static const char g_szTag[] = "[\x0EChatSpy\x01]";

Handle g_clientcookie;
bool g_bEnabled[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[CSGO] Chat Spy",
	author = "ESK0 | Edited: somebody.",
	description = "Chat Spy",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_chatspy", Command_ChatSpy, ADMFLAG_GENERIC);
	RegAdminCmd("sm_spychat", Command_ChatSpy, ADMFLAG_GENERIC);
	RegAdminCmd("sm_spy", Command_ChatSpy, ADMFLAG_GENERIC);

	g_clientcookie = RegClientCookie("chatspy_cookie", "", CookieAccess_Private);

	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientCookiesCached(client);
		}
	}
}

public void OnClientCookiesCached(int client)
{
	char szValue[4];
	GetClientCookie(client, g_clientcookie, szValue, sizeof(szValue));
	g_bEnabled[client] = szValue[0] ? view_as<bool>(StringToInt(szValue)):true;
}

public Action Command_ChatSpy(int client, int args)
{
	g_bEnabled[client] = !g_bEnabled[client];
	if(g_bEnabled[client])
	{
		SetClientCookie(client, g_clientcookie, "0");
		PrintToChat(client,"%s \x10Ellenséges csapatüzenetek: \x06engedélyezve.", g_szTag);
	}
	else
	{
		SetClientCookie(client, g_clientcookie, "1");
		PrintToChat(client,"%s \x10Ellenséges csapatüzenetek: \x02letiltva.", g_szTag);
	}
	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(0 < client && client <= MaxClients && IsClientInGame(client) && StrEqual(command, "say_team") && sArgs[0] != 0 && sArgs[0] != '@' && sArgs[0] != '/' && sArgs[0] != '!')
	{
		int iSenderTeam = GetClientTeam(client);
		for(int i = 1; i <= MaxClients; i++)
		{
			if(g_bEnabled[i] && IsClientInGame(i) && !IsFakeClient(i) && iSenderTeam != GetClientTeam(i) && CheckCommandAccess(i, "", ADMFLAG_GENERIC, true))
			{
				PrintToChat(i, "%s%s%s %N: %s",
				(iSenderTeam == 3) ? " \x0C" : (iSenderTeam == 2) ? " \x10" : " \x08",
				IsPlayerAlive(client) ? "" : (iSenderTeam == 2) ? "\x0E*HALOTT* " : (iSenderTeam == 3) ? "\x0E*HALOTT* " : "",
				(iSenderTeam == 3) ? "\x02* \x0C(CT)\x08" : (iSenderTeam == 2) ? "\x0C* \x02(T)\x08" : "", client, sArgs);
			}
		}
	}
	return Plugin_Continue;
}