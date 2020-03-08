#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_stringtables>

new bool:g_IsHitEnabled[MAXPLAYERS + 1] = {true,...},
	bool:CSGO;

public Plugin myinfo =
{
	name = "[CSGO] HitMarker - OverLays Big",
	author = "iEx | Edited: somebody.",
	description = "HitMarker - Overlays Big",
	version = "1.0",
	url = "http://sourcemod.net"
};
	
public OnPluginStart()
{
	CSGO = GetEngineVersion() == Engine_CSGO;
	HookEvent("player_hurt", player_hurt);

	RegConsoleCmd("sm_hitmarker", sm_hitmark);
	RegConsoleCmd("sm_hitmark", sm_hitmark);
	RegConsoleCmd("sm_hm", sm_hitmark);
}

public OnMapStart()
{
	AddFileToDownloadsTable("materials/hitmarker/hit01_big.vmt");
	AddFileToDownloadsTable("materials/hitmarker/hit01_big.vtf");
	AddFileToDownloadsTable("materials/hitmarker/hit02_big.vmt");
	AddFileToDownloadsTable("materials/hitmarker/hit02_big.vtf");
	AddFileToDownloadsTable("sound/hitmarker/hit.mp3");

	AddToStringTable(FindStringTable("soundprecache"), "*hitmarker/hit.mp3");
	PrecacheSound("hitmarker/hit.mp3", true);

	PrecacheModel("materials/hitmarker/hit01_big.vmt", true);
	PrecacheModel("materials/hitmarker/hit02_big.vmt", true);
}

public Action:sm_hitmark(client,args)
{
	g_IsHitEnabled[client] = !g_IsHitEnabled[client];
	PrintToChat(client, "[SM] Találat jelző: %s.", g_IsHitEnabled[client] ? "Bekapcsolva" : "Kikapcsolva");

	return Plugin_Handled;
}

public player_hurt(Handle:event, const String:name[], bool:silent)
{
	static U, A;
	U = GetEventInt(event, "attacker");
	A = GetClientOfUserId(U);
	if(A && A != GetClientOfUserId(GetEventInt(event, "userid")) && g_IsHitEnabled[A])
	{
		ClientCommand(A, CSGO ? "play *hitmarker/hit.mp3" : "play hitmarker/hit.mp3");
		ClientCommand(A, GetEventInt(event, "health") < 1 ? "r_screenoverlay hitmarker/hit02_big.vmt" : "r_screenoverlay hitmarker/hit01_big.vmt");
		CreateTimer(0.2, Timer_RemoveHitMarker, U, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Timer_RemoveHitMarker(Handle:timer, any:client)
{
	if((client = GetClientOfUserId(client))) ClientCommand(client, "r_screenoverlay off");
}