#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <bhopstats>

#pragma newdecls required

bool gB_PadEnabled[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[CSGO] Bhop Stats - Scroll Pad",
	author = "Shavit | Edited: somebody.",
	description = "Bhop Stats - Scroll Pad",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_pad", Command_Pad, ADMFLAG_RESERVATION, "Toggle scroll pad.");
	RegAdminCmd("sm_pads", Command_Pad, ADMFLAG_RESERVATION, "Toggle scroll pad.");
	RegAdminCmd("sm_bhopstat", Command_Pad, ADMFLAG_RESERVATION, "Toggle scroll pad.");
	RegAdminCmd("sm_bhopstats", Command_Pad, ADMFLAG_RESERVATION, "Toggle scroll pad.");
}

public Action Command_Pad(int client, int args)
{
	gB_PadEnabled[client] = !gB_PadEnabled[client];

	PrintToChat(client, " \x06[\x02ViP\x06] \x07Bhop statisztika ellenőrző: \x06%s\x07.", (gB_PadEnabled[client])? "Bekapcsolva":"Kikapcsolva");

	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	gB_PadEnabled[client] = false;
}

public void Bunnyhop_OnJumpPressed(int client)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !gB_PadEnabled[i])
		{
			continue;
		}

		int iObserverMode = GetEntProp(client, Prop_Send, "m_iObserverMode");

		if(i == client || (IsClientObserver(i) && (iObserverMode >= 3 || iObserverMode <= 5) && GetEntPropEnt(i, Prop_Send, "m_hObserverTarget") == client))
		{
			PrintToConsole(i, "%d", BunnyhopStats.GetScrollCount(client));
		}
	}
}