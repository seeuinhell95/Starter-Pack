#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <hosties>

#undef REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#tryinclude <SteamWorks>
#define REQUIRE_EXTENSIONS
#define REQUIRE_PLUGIN

#define MAX_DISPLAYNAME_SIZE		64
#define MAX_DATAENTRY_SIZE			5
#define SERVERTAG					"LR, Last Request, LastRequest, SM Hosties, ENT Hosties"

#define MODULE_NOBLOCK				1
#define MODULE_LASTREQUEST			1
#define MODULE_GAMEDESCRIPTION		1
#define MODULE_STARTWEAPONS			1
#define MODULE_MUTE					1

new GameType:g_Game = Game_Unknown;

new Handle:gH_Cvar_LR_Debug_Enabled = INVALID_HANDLE;
new bool:gShadow_LR_Debug_Enabled = false;

#if (MODULE_NOBLOCK == 1)
#include "hosties/noblock.sp"
#endif
#if (MODULE_LASTREQUEST == 1)
#include "hosties/lastrequest.sp"
#endif
#if (MODULE_GAMEDESCRIPTION == 1)
#include "hosties/gamedescription.sp"
#endif
#if (MODULE_STARTWEAPONS == 1)
#include "hosties/startweapons.sp"
#endif
#if (MODULE_MUTE == 1)
#include "hosties/muteprisoners.sp"
#endif

new Handle:gH_Cvar_Add_ServerTag = INVALID_HANDLE;
new Handle:gH_Cvar_Display_Advert = INVALID_HANDLE;

public Plugin myinfo =
{
	name		=	"[CSGO] SM, ENT Hosties - Last Request",
	author		=	"DataBomb & Entity | Edited: somebody.",
	description	=	"SM, ENT Hosties - Last Request",
	version		=	"1.0",
	url			=	"http://sourcemod.net"
};

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("hosties.phrases");

	HookEvent("round_start", Event_RoundStart);

	gH_Cvar_Add_ServerTag = CreateConVar("sm_hosties_add_servertag", "0", "Enable or disable automatic adding of SM_Hosties in sv_tags (visible from the server browser in CS:S): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Display_Advert = CreateConVar("sm_hosties_display_advert", "0", "Enable or disable the display of the Powered by SM Hosties message at the start of each round.", 0, true, 0.0, true, 1.0);

	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnPluginStart();
	#endif
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnPluginStart();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDescription_OnPluginStart();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnPluginStart();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnPluginStart();
	#endif

	AutoExecConfig(true, "sm_hosties");
}

public OnMapStart()
{
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnMapStart();
	#endif
}

public OnAllPluginsLoaded()
{
	#if (MODULE_MUTE == 1)
	MutePrisoners_AllPluginsLoaded();
	#endif
}

public APLRes:AskPluginLoad2(Handle:h_Myself, bool:bLateLoaded, String:sError[], error_max)
{
	if (GetEngineVersion() == Engine_CSS)
	{
		g_Game = Game_CSS;
	}
	else if (GetEngineVersion() == Engine_CSGO)
	{
		g_Game = Game_CSGO;
	}
	else
	{
		SetFailState("Game is not supported.");
	}

	MarkNativeAsOptional("SteamWorks_SetGameDescription");

	LastRequest_APL();
	
	RegPluginLibrary("hosties");
	
	return APLRes_Success;
}

public OnConfigsExecuted()
{
	if (GetConVarInt(gH_Cvar_Add_ServerTag) == 1)
	{
		ServerCommand("sv_tags %s\n", SERVERTAG);
	}

	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnConfigsExecuted();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnConfigsExecuted();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDesc_OnConfigsExecuted();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnConfigsExecuted();
	#endif
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnConfigsExecuted();
	#endif
}

public OnClientPutInServer(client)
{
	LastRequest_ClientPutInServer(client);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(gH_Cvar_Display_Advert))
	{
		PrintToChatAll("The server is Powered By Hosties. (Entity-Edition)");
	}
}