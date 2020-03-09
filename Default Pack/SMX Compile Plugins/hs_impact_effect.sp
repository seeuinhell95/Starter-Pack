#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#define DMG_HEADSHOT (1 << 30)

new Handle:g_hHS_enabled = INVALID_HANDLE;
new bool:g_bHS_enabled;
new Handle:g_hTimeOverlay;
new g_bClientPrefHsOverlays[MAXPLAYERS+1];
new Handle:g_hClientCookieHsOverlays = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "[CSGO] HeadShot Impact Effect",
	author = "Tony Baretta | Edited: somebody.",
	description = "HeadShot Impact Effect",
	version = "1.0",
	url = "http://sourcemod.net"
}

public OnMapStart()
{
	decl String:file[256];
	BuildPath(Path_SM, file, 255, "configs/hs_impact.ini");
	new Handle:fileh = OpenFile(file, "r");
	if (fileh != INVALID_HANDLE)
	{
		decl String:buffer[256];
		decl String:buffer_full[PLATFORM_MAX_PATH];

		while(ReadFileLine(fileh, buffer, sizeof(buffer)))
		{
			TrimString(buffer);
			if ( (StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")) )
			{
				PrintToServer("Reading overlay_downloads line :: %s", buffer);
				Format(buffer_full, sizeof(buffer_full), "materials/%s", buffer);
				if (FileExists(buffer_full))
				{
					PrintToServer("Precaching %s", buffer);
					PrecacheDecal(buffer, true);
					AddFileToDownloadsTable(buffer_full);
				}
			}
		}
	}
	AddFileToDownloadsTable("sound/hssound/impact.mp3");
	PrecacheSound("hssound/impact.mp3", true);
}

public OnPluginStart()
{
	HookEvent("player_death", PlayerDeath);

	g_hHS_enabled = CreateConVar("sm_hsonly_enabled", "1", "Set hs only show glass");
	g_bHS_enabled = GetConVarBool(g_hHS_enabled);
	g_hTimeOverlay = CreateConVar("hs_ovtime", "2.0", "Set overlay time");

	RegConsoleCmd("sm_hs", Command_HsImpact, "Set on or off overlay");
	RegConsoleCmd("sm_hseffect", Command_HsImpact, "Set on or off overlay");
	RegConsoleCmd("sm_headshot", Command_HsImpact, "Set on or off overlay");
	RegConsoleCmd("sm_headshoteffect", Command_HsImpact, "Set on or off overlay");
	RegConsoleCmd("sm_headshots", Command_HsImpact, "Set on or off overlay");
	RegConsoleCmd("sm_hsimpact", Command_HsImpact, "Set on or off overlay");

	g_hClientCookieHsOverlays = RegClientCookie("HS Impact Overlays", "set overlays on / off ", CookieAccess_Private);
}

public OnClientPutInServer(client)
{
	LoadClientCookiesFor(client);
}

public LoadClientCookiesFor(client)
{
	new String:buffer[5];
	GetClientCookie(client,g_hClientCookieHsOverlays,buffer,5);
	if(!StrEqual(buffer,""))
	{
		g_bClientPrefHsOverlays[client] = StringToInt(buffer);
	}
	if(StrEqual(buffer,""))
	{
		g_bClientPrefHsOverlays[client] = 1;
	}
}

public PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bHS_enabled = GetConVarBool(g_hHS_enabled);
	new userId = GetEventInt(event, "userid"); 
	new iClient = GetClientOfUserId(userId); 
	if (GetEventBool(event, "headshot") && IsValidClient(iClient) && (g_bHS_enabled) && (g_bClientPrefHsOverlays[iClient]))
	{
		switch (GetRandomInt(0, 1))
		{
			case 0:
			{
				EmitSoundToClient(iClient, "hssound/impact.mp3");
				SetClientOverlay(iClient, "hsoverlays/bullet2b");
			}
			case 1:
			{
				EmitSoundToClient(iClient, "hssound/impact.mp3");
				SetClientOverlay(iClient, "hsoverlays/bullet1a");
			}
		}
		CreateTimer(GetConVarFloat(g_hTimeOverlay), DeleteOverlay, iClient);
	}
	if (IsValidClient(iClient) && (!g_bHS_enabled) && (g_bClientPrefHsOverlays[iClient]))
	{
		switch (GetRandomInt(0, 1))
		{
			case 0:
			{
				EmitSoundToClient(iClient, "hssound/impact.mp3");
				SetClientOverlay(iClient, "hsoverlays/bullet2b");
			}
			case 1:
			{
				EmitSoundToClient(iClient, "hssound/impact.mp3");
				SetClientOverlay(iClient, "hsoverlays/bullet1a");
			}
		}
		CreateTimer(GetConVarFloat(g_hTimeOverlay), DeleteOverlay, iClient);
	}
}

public Action:DeleteOverlay(Handle:timer, any:iClient)
{
	if (IsValidClient(iClient))
	{
		SetClientOverlay(iClient, "");
	}
	return Plugin_Handled;
}

stock bool:IsValidClient(iClient)
{
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}

SetClientOverlay(client, String:strOverlay[])
{
	if (IsValidClient(client))
	{
		new iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);	
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
		return true;
	}
	return false;
}

public Action:Command_HsImpact(client, args)
{
	if(!g_bClientPrefHsOverlays[client])
	{
		g_bClientPrefHsOverlays[client] = 1;
		PrintToChat(client, " \x06[\x02HS\x06] \x07Fejlövés törés effekt: \x06Bekapcsolva\x07.");
	}
	else
	if(g_bClientPrefHsOverlays[client])
	{
		g_bClientPrefHsOverlays[client] = 0;
		PrintToChat(client, " \x06[\x02HS\x06] \x07Fejlövés törés effekt: \x06Kikapcsolva\x07.");
	}
}