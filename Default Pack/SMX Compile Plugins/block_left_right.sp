#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "[CSGO] Block +left & +right",
	author = "Cherry | Edited: somebody.",
	description = "Block +left & +right",
	version = "1.0",
	url = "http://sourcemod.net"
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if(IsPlayerAlive(client))
	{
		if(buttons & IN_LEFT || buttons & IN_RIGHT)
		{
			PrintToChat(client, "[SM] Tilos a +left és a +right használata!");
			ForcePlayerSuicide(client);
		}
	}
}