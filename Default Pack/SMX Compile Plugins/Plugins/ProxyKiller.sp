#pragma semicolon 1

#include <json>
#include <SteamWorks>
#include <ProxyKiller>

#pragma dynamic 131072
#pragma newdecls required

ConVar gCV_Enable = null;
ConVar gCV_KickMsg = null;
ConVar gCV_LogSteamId = null;
ConVar gCV_CacheLifetime = null;
ConVar gCV_IgnoreAppOwners = null;

ProxyLogger g_Logger = null;
ProxyDatabase g_Database = null;
ProxyServices g_Services = null;
ProxyCacheLayer g_cacheLayer = null;

#include "ProxyKiller/http.sp"
#include "ProxyKiller/cache.sp"
#include "ProxyKiller/config.sp"

public Plugin myinfo =
{
	name = PROXYKILLER_NAME,
	author = PROXYKILLER_AUTHOR,
	description = PROXYKILLER_DESCRIPTION,
	version = PROXYKILLER_VERSION,
	url = PROXYKILLER_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gCV_Enable = CreateConVar("ProxyKiller_Enable", "1", "Enable/disable ProxyKiller\n0 = Disable - 1 = Enable", _, true, 0.0, true, 1.0);
	gCV_KickMsg = CreateConVar("ProxyKiller_KickMessage", "Kicked due to proxy usage!", "Message to be sent to clients when they're kicked");
	gCV_LogSteamId = CreateConVar("ProxyKiller_LogSteamId", "1", "Logs steamid in addition of ip for a punished client", _, true, 0.0, true, 1.0);
	gCV_CacheLifetime = CreateConVar("ProxyKiller_CacheLifetime", "43200", "Time in second(s) when to invalidate cache entries and re-query ip addresses\nIt is recommended that you set this to at least 1 hour (3600 seconds)", _, true, 0.0, false);
	gCV_IgnoreAppOwners = CreateConVar("ProxyKiller_IgnoreAppOwners", "624820", "Ignore owners of these appids when checking for proxies\nChecking will occur if a client does not have any of these appids\nSeparate appids by a comma ex: \"123, 4444\"");

	AutoExecConfig(true, "ProxyKiller");
}

public void OnPluginStart()
{
	g_Logger = new ProxyLogger();
	g_Database = new ProxyDatabase();
	g_Services = new ProxyServices();
	ParseConfig(DEFAULT_CONFIG, g_Services);

	g_Database.Initialize();
	g_cacheLayer = new ProxyCacheLayer(g_Database);
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

	char ignoreApps[256];
	gCV_IgnoreAppOwners.GetString(ignoreApps, sizeof(ignoreApps));

	TrimString(ignoreApps);
	bool shouldCheck = true;

	if (strlen(ignoreApps) > 0)
	{
		char appIds[16][16];
		int appCount = ExplodeString(ignoreApps, ",", appIds, sizeof(appIds), sizeof(appIds[]));

		for (int i = 0; i < appCount; i++)
		{
			if (HasApp(client, StringToInt(appIds[i])))
			{
				shouldCheck = false;
				break;
			}
		}
	}

	if (shouldCheck)
	{
		char clientIpAddress[24];
		char clientSteamId[32] = "Undefined";
		GetClientIP(client, clientIpAddress, sizeof(clientIpAddress));

		if (gCV_LogSteamId.BoolValue)
		{
			if (!GetClientAuthId(client, AuthId_Steam2, clientSteamId, sizeof(clientSteamId)))
			{
				clientSteamId = "Unknown";
			}
		}

		DataPack data = new DataPack();
		data.WriteString(clientIpAddress);
		data.WriteString(clientSteamId);
		g_cacheLayer.TryGetCache(clientIpAddress, OnCache, data);
	}
}

void ReplaceIP(char[] ipAddress, char[] buffer, int maxlength)
{
	ReplaceString(buffer, maxlength, IP_CONF_TOKEN, ipAddress);
}

bool HasApp(int client, int appid)
{
	return (SteamWorks_HasLicenseForApp(client, appid) == k_EUserHasLicenseResultHasLicense);
}

void KickClientsByIp(char[] ipAddress)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (!IsClientConnected(i))
			continue;
		
		if (IsFakeClient(i))
			continue;

		char clientIp[24];
		GetClientIP(i, clientIp, sizeof(clientIp));

		if (StrEqual(ipAddress, clientIp))
		{
			char kickMsg[KICK_MESSAGE_LENGTH];
			gCV_KickMsg.GetString(kickMsg, sizeof(kickMsg));
			
			KickClient(i, "%s", kickMsg);
		}
	}
}