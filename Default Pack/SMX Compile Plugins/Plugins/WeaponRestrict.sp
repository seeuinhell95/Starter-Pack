#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required;
#include <cstrike_weapons>
#include <restrict>

#define WARMUP
#define CONFIGLOADER
#define STOCKMENU
#define PERPLAYER

#if defined STOCKMENU
#undef REQUIRE_PLUGIN
#include <adminmenu>
#endif

#define ADMINCOMMANDTAG "[SM] "
#define MAXWEAPONGROUPS 7

EngineVersion g_iEngineVersion;
char g_WeaponGroupNames[][] = {"pistols", "smgs", "shotguns", "rifles", "snipers", "grenades", "armor"};

bool g_bRestrictSound = false;
char g_sCachedSound[PLATFORM_MAX_PATH];
bool g_bLateLoaded = false;

RoundType g_nextRoundSpecial = RoundType_None;
RoundType g_currentRoundSpecial = RoundType_None;

#include "restrictinc/cvars.sp"

#if defined WARMUP
#include "restrictinc/warmup.sp"
#endif

#if defined CONFIGLOADER
#include "restrictinc/configloader.sp"
#endif

#if defined PERPLAYER
#include "restrictinc/perplayer.sp"
#endif

#include "restrictinc/weapon-tracking.sp"
#include "restrictinc/natives.sp"
#include "restrictinc/functions.sp"
#include "restrictinc/events.sp"
#include "restrictinc/admincmds.sp"

public Plugin myinfo =
{
	name = "[CSGO] Weapon Restrict",
	author = "Dr!fter | Edited: somebody.",
	description = "Weapon Restrict",
	version = "1.0",
	url = "http://sourcemod.net"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char [] error, int err_max)
{
	g_iEngineVersion = GetEngineVersion();

	if(g_iEngineVersion != Engine_CSGO && g_iEngineVersion != Engine_CSS)
	{
		strcopy(error, err_max, "This plugin is only supported on CS");
		return APLRes_Failure;
	}

	g_bLateLoaded = late;
	RegisterNatives();

	return APLRes_Success;
}

public void OnPluginStart()
{	
	HookEvents();
	RegisterAdminCommands();
	RegisterForwards();

	#if defined WARMUP
	RegisterWarmup();
	#endif

	LoadTranslations("common.phrases");
	LoadTranslations("WeaponRestrict.phrases");

	CreateTimer(0.1, LateLoadExec, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action LateLoadExec(Handle timer)
{
    char szFile[] = "cfg/sourcemod/WeaponRestrict.cfg";

    if(FileExists(szFile))
    {
        ServerCommand("exec sourcemod/WeaponRestrict.cfg");
    }
}