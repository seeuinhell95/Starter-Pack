#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Slots Fix (Console Connect Block)",
	author = "R1KO & MaZa | Edited: somebody.",
	description = "Slots Fix (Console Connect Block)",
	version = "1.0",
	url = "http://sourcemod.net"
}

int g_iSlots;
int g_iBuffer;

public void OnMapStart()
{
	g_iSlots = GetMaxHumanPlayers();
}

public void OnClientConnected(int client)
{
	g_iBuffer = 0;
	for(int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientConnected(i) && !IsClientInKickQueue(i) && !IsFakeClient(i) && ++g_iBuffer > g_iSlots)
		{
			KickClient(client, "A szerver jelenleg tele van. Próbáld újra később");
			return;
		}
	}
}