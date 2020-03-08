#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#if SOURCEMOD_V_MINOR < 10
	#error This plugin can only compile on SourceMod 1.10.
#endif

#pragma newdecls required

#include <lvl_ranks>

#if !defined PLUGIN_INT_VERSION || PLUGIN_INT_VERSION != 03010200
	#error This plugin can only compile on lvl_ranks.inc v3.1.2.
#endif

#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHORS "RoadSide Romeo & Wend4r | Edited: somebody."

#include "levels_ranks/defines.sp"

enum struct LR_PlayerInfo
{
	bool bHaveBomb;
	bool bInitialized;
	int iAccountID;
	int iStats[LR_StatsType];
	int iSessionStats[LR_StatsType];
	int iRoundExp;
	int iKillStreak;
}

any				g_Settings[LR_SettingType];

bool			g_bAllowStatistic,
				g_bDatabaseSQLite,
				g_bRoundEndGiveExp = true,
				g_bRoundAllowExp = true;

int				g_iBonus[11],
				g_iCountRetryConnect,
				g_iDBCountPlayers;

char			g_sDBConfigName[] = "levels_ranks",
				g_sPluginName[] = PLUGIN_NAME,
				g_sPluginTitle[64],
				g_sTableName[32],
				g_sSoundUp[PLATFORM_MAX_PATH],
				g_sSoundDown[PLATFORM_MAX_PATH];

LR_PlayerInfo	g_iPlayerInfo[MAXPLAYERS+1],
				g_iInfoNULL;

GlobalForward	g_hForward_OnCoreIsReady;

PrivateForward	g_hForward_Hook[LR_HookType],
				g_hForward_CreatedMenu[LR_MenuType],
				g_hForward_SelectedMenu[LR_MenuType];

EngineVersion	g_iEngine;

ArrayList		g_hRankNames,
				g_hRankExp;

Cookie			g_hLastResetMyStats;

Database		g_hDatabase;

Transaction		g_hTransactionLossDB;

#include "levels_ranks/settings.sp"
#include "levels_ranks/database.sp"
#include "levels_ranks/commands.sp"
#include "levels_ranks/menus.sp"
#include "levels_ranks/custom_functions.sp"
#include "levels_ranks/events.sp"
#include "levels_ranks/api.sp"

public Plugin myinfo =
{
	name = "[CSGO] " ... PLUGIN_NAME ... " - Core",
	author = PLUGIN_AUTHORS,
	description = "Levels Ranks - Core",
	version = PLUGIN_VERSION,
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations(g_iEngine == Engine_SourceSDK2006 ? "lr_core_old.phrases" : "lr_core.phrases");
	LoadTranslations("lr_core_ranks.phrases");

	RegConsoleCmd("sm_lvl", Call_MainMenu, "Opens the statistics menu");
	RegConsoleCmd("sm_level", Call_MainMenu, "Opens the statistics menu");

	RegAdminCmd("sm_lvl_reload", Call_ReloadSettings, ADMFLAG_ROOT, "Reloads core and module configuration files");
	RegServerCmd("sm_lvl_reset", Call_ResetData, "Сlearing all data in the database");
	RegAdminCmd("sm_lvl_del", Call_ResetPlayer, ADMFLAG_ROOT, "Resets player stats");

	SetSettings();
	ConnectDB();
}

public void OnMapStart()
{
	if(g_Settings[LR_IsLevelSound])
	{
		static char sSoundPath[PLATFORM_MAX_PATH + 6] = "sound/";

		strcopy(sSoundPath[6], sizeof(g_sSoundUp), g_sSoundUp);
		AddFileToDownloadsTable(sSoundPath);

		strcopy(sSoundPath[6], sizeof(g_sSoundDown), g_sSoundDown);
		AddFileToDownloadsTable(sSoundPath);

		if(g_iEngine == Engine_CSGO)
		{
			int iStringTable = FindStringTable("soundprecache");

			AddToStringTable(iStringTable, g_sSoundUp);
			AddToStringTable(iStringTable, g_sSoundDown);
		}
		else
		{
			PrecacheSound(g_sSoundUp);
			PrecacheSound(g_sSoundDown);
		}
	}

	OnCleanDB();
}

public void OnPluginEnd()
{
	for(int i = GetMaxPlayers(); --i;)
	{
		if(g_iPlayerInfo[i].bInitialized)
		{
			SaveDataPlayer(i, true);
		}
	}
}