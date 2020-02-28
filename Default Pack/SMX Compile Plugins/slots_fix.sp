#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "[CSGO] Slots Fix (Console Connect Block)",
	author = "R1KO & MaZa | Edited: Cherry & somebody.",
	description = "Slots Fix (Console Connect Block)",
	version = "1.0",
	url = "http://sourcemod.net"
}

int g_iSlots;
int g_iBuffer;

public OnPluginStart()
{
	HookEvent("player_connect_full", connected, EventHookMode_Pre);
}

public void OnMapStart()
{
	g_iSlots = GetMaxHumanPlayers();
}

public Action:connected(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_iBuffer = 0;
	for(int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientConnected(i) && !IsClientInKickQueue(i) && !IsFakeClient(i) && ++g_iBuffer > g_iSlots && GetUserAdmin(client) == INVALID_ADMIN_ID)
		{
			KickClient(client, "A szerver jelenleg tele van. Próbáld újra később vagy vásárolj ViP-t, hogy bármikor felcsatlakozhass");
			return;
		}
	}
}