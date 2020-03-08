#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required

public Plugin myinfo =
{
	name		=	"[CSGO] BombSite Locker",
	author		=	"Ilusion9 | Edited: somebody.",
	description	=	"BombSite Locker",
	version		=	"1.0",
	url			=	"http://sourcemod.net"
};

ConVar g_Cvar_FreezeTime;
Handle g_Timer_FreezeEnd;

int g_SiteA;
int g_SiteB;

char g_RestrictedSite;
int g_RestrictedSiteLimit;

public void OnPluginStart()
{
	LoadTranslations("bombsite_locker.phrases");

	HookEvent("round_start", Event_RoundStart);	
	g_Cvar_FreezeTime = FindConVar("mp_freezetime");
}

public void OnMapStart()
{
	g_RestrictedSiteLimit = 0;
	g_RestrictedSite = 0;

	g_SiteA = -1;
	g_SiteB = -1;
}

public void OnMapEnd()
{
	delete g_Timer_FreezeEnd;
}

public void OnConfigsExecuted()
{
	char path[PLATFORM_MAX_PATH];	
	BuildPath(Path_SM, path, sizeof(path), "configs/bombsite_locker.cfg");
	KeyValues kv = new KeyValues("BombSiteLocker"); 

	if (!kv.ImportFromFile(path))
	{
		LogError("The configuration file could not be read.");
		delete kv;
		return;
	}

	char map[PLATFORM_MAX_PATH], displayName[PLATFORM_MAX_PATH];
	GetCurrentMap(map, sizeof(map));
	GetMapDisplayName(map, displayName, sizeof(displayName));

	if (kv.JumpToKey(displayName)) 
	{
		char key[64];

		kv.GetString("site_locked", key, sizeof(key));
		g_RestrictedSite = CharToUpper(key[0]);

		if (g_RestrictedSite != 'A' && g_RestrictedSite != 'B')
		{
			g_RestrictedSite = 0;
		}

		g_RestrictedSiteLimit = kv.GetNum("ct_limit", 0);
	}

	delete kv;

	if (g_RestrictedSite)
	{
		FindConVar("mp_join_grace_time").SetInt(0);
	}
}

public void OnClientConnected(int client)
{
	if (g_SiteA == -1 || g_SiteB == -1)
	{
		GetMapBombsites(g_SiteA, g_SiteB);
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	delete g_Timer_FreezeEnd;

	if (IsWarmupPeriod())
	{
		return;
	}

	if (g_RestrictedSite)
	{
		g_Timer_FreezeEnd = CreateTimer(g_Cvar_FreezeTime.FloatValue + 1.0, Timer_HandleFreezeEnd);
	}
}

public Action Timer_HandleFreezeEnd(Handle timer, any data)
{
	if (g_SiteA != -1 && g_SiteB != -1)
	{
		AcceptEntityInput(g_SiteA, "Enable");
		AcceptEntityInput(g_SiteB, "Enable");

		if (GetCounterTerroristsCount() < g_RestrictedSiteLimit)
		{
			AcceptEntityInput(g_RestrictedSite != 'A' ? g_SiteB : g_SiteA, "Disable");

			PrintToChatAll("[\x04C4\x01] %t", "Bombsite Disabled Reason", g_RestrictedSite, g_RestrictedSiteLimit);
		}
	}

	g_Timer_FreezeEnd = null;
}

void GetMapBombsites(int &siteA, int &siteB)
{
	int ent = FindEntityByClassname(-1, "cs_player_manager");
	if (ent != -1)
	{
		float bombsiteCenterA[3], bombsiteCenterB[3];
		GetEntPropVector(ent, Prop_Send, "m_bombsiteCenterA", bombsiteCenterA); 
		GetEntPropVector(ent, Prop_Send, "m_bombsiteCenterB", bombsiteCenterB);

		ent = -1;
		while ((ent = FindEntityByClassname(ent, "func_bomb_target")) != -1)
		{
			float vecMins[3], vecMaxs[3];
			GetEntPropVector(ent, Prop_Send, "m_vecMins", vecMins); 
			GetEntPropVector(ent, Prop_Send, "m_vecMaxs", vecMaxs);

			if (IsVecBetween(bombsiteCenterA, vecMins, vecMaxs))
			{
				siteA = ent; 
			}

			else if (IsVecBetween(bombsiteCenterB, vecMins, vecMaxs))
			{
				siteB = ent;
			}
		}
	}
}

bool IsVecBetween(const float vec[3], const float mins[3], const float maxs[3]) 
{
	for (int i = 0; i < 3; i++)
	{
		if (vec[i] < mins[i] || vec[i] > maxs[i])
		{
			return false;
		}
	}

	return true;
}

int GetCounterTerroristsCount()
{
	int num = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT)
		{
			num++;
		}
	}

	return num;
}

bool IsWarmupPeriod()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}