#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#include <geoip>

#define Scoreboard_Reveal 1

#define START_XP_INDEX 1200
#define END_XP_INDEX 1395

int g_iLang[MAXPLAYERS+1], m_nPersonaDataPublicLevel;

public Plugin myinfo =
{
	name = "[CSGO] ScoreBoard Language (Country Flag Icons)",
	author = "Wend4r | Edited: somebody.",
	description = "ScoreBoard Language (Country Flag Icons)",
	version = "1.0",
	url = "http://sourcemod.net"
};

public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] sError, int iErrorSize)
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		strcopy(sError, iErrorSize, "This plugin works only on CS:GO");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	m_nPersonaDataPublicLevel = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");

	for(int i = MaxClients + 1; --i;)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnMapStart()
{
	static char sBuffer[PLATFORM_MAX_PATH];

	for(int i = START_XP_INDEX; i != END_XP_INDEX; i++)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/xp/level%i.png", i);
		AddFileToDownloadsTable(sBuffer);
	}

	SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}

void OnThinkPost(int iEnt)
{
	for(int i = MaxClients + 1; --i;)
	{
		if(IsClientInGame(i))
		{
			SetEntData(iEnt, m_nPersonaDataPublicLevel + i*4, g_iLang[i]);
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	if(!IsFakeClient(iClient))
	{
		static char sLang[3], sIP[32];

		static const char sCodes[][] =
		{
			"US", "SV", "BR", "BG", "CZ", "DK", "LU", "FL", "FR", "DE",
			"LU", "IL", "HU", "IT", "JP", "KR", "AT", "LT", "NO", "PL",
			"PT", "AD", "RU", "CN", "SK", "ES", "SE", "CN", "TH", "TR",
			"UA", "SA", "GB", "MH", "BN", "BI", "SM", "MK", "BT", "GY",
			"KI", "JM", "KN", "NA", "TT", "KM", "BZ", "TZ", "AL", "PG",
			"ZA", "SC", "BA", "SB", "ER", "LC", "GD", "ET", "TL", "VU",
			"AU", "AG", "VA", "TN", "XK", "PK", "FJ", "TV", "MR", "DZ",
			"NZ", "KE", "KG", "SS", "ST", "AF", "CU", "TM", "DJ", "EC",
			"JO", "CY", "MY", "MM", "CD", "DM", "ZW", "HR", "PH", "SZ",
			"GQ", "NP", "SD", "BS", "MZ", "SG", "KH", "RS", "LY", "KZ",
			"BH", "CV", "KP", "VS", "BD", "CA", "AZ", "PA", "MV", "KW",
			"PW", "QA", "BB", "LR", "ME", "TJ", "TG", "LB", "MA", "MX",
			"WS", "SO", "UY", "SN", "NR", "IN", "IR", "UZ", "BF", "UG",
			"SY", "VN", "SI", "FM", "HT", "TW", "VC", "CM", "GE", "SR",
			"LI", "CL", "GT", "BO", "GH", "GW", "AR", "MW", "CG", "DO",
			"PY", "MD", "NI", "CF", "EG", "HN", "LA", "ZM", "LS", "MN",
			"RW", "MT", "TO", "CH", "NE", "BY", "GR", "IS", "OM", "IQ",
			"LK", "CR", "BW", "AE", "GM", "MU", "RO", "BJ", "GN", "MG",
			"BE", "TD", "ML", "SL", "YE", "NL", "AM", "NG", "PE", "EE",
			"LV", "CO", "ID", "MC", "GA"
		};

		GetClientIP(iClient, sIP, sizeof(sIP));

		if(strncmp(sIP, "192.168.1", 12))
		{
			int iLang = 0;

			GeoipCode2(sIP, sLang);

			while(strcmp(sCodes[iLang], sLang))
			{
				if(++iLang == sizeof(sCodes))
				{
					return;
				}
			}

			g_iLang[iClient] = START_XP_INDEX + iLang;
		}
	}
}

public void OnClientDisconnect(int iClient)
{
	g_iLang[iClient] = 0;
}

#if Scoreboard_Reveal
public void OnPlayerRunCmdPost(int iClient, int iButtons)
{
	static int iOldButtons[MAXPLAYERS+1];

	if(iButtons & IN_SCORE && !(iOldButtons[iClient] & IN_SCORE))
	{
		StartMessageOne("ServerRankRevealAll", iClient, USERMSG_BLOCKHOOKS);
		EndMessage();
	}

	iOldButtons[iClient] = iButtons;
}
#endif