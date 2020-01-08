#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

bool canafk[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "[CSGO] AFK Commands",
	author = "You Fake | Edited: Cherry & somebody.",
	description = "AFK Commands",
	version = "1.0",
	url = "http://sourcemod.net"
}

public OnPluginStart()
{
	RegConsoleCmd("say", AfkCommand);
	RegConsoleCmd("say_team", AfkCommand);
}

public void OnClientConnected(client)
{
	canafk[client] = true;
}

public Action:AfkCommand(client, args)
{
	decl String:Said[128];
	GetCmdArgString(Said, sizeof(Said) - 1);
	StripQuotes(Said);
	TrimString(Said);

	if(StrEqual(Said, "!afk") || StrEqual(Said, "!spect"))
	{
		if(canafk[client] == true)
		{
			canafk[client] = false;
			CreateTimer(5.0, time_to_afk, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		if(canafk[client] == false)
		{
			PrintToChat(client, " \x04[\x02AFK\x04] \x10Várj \x025 \x10másodpercet és át leszel helyezve a nézőkhöz!");
		}
	}
}

public Action time_to_afk(Handle hTimer, int client)
{
	if ((client = GetClientOfUserId(client)))
	{
		ChangeClientTeam(client, 1);
		canafk[client] = true;
		PrintToChat( client, " \x04[\x02AFK\x04] \x10Át lettél helyezve a nézőkhöz!");
	}
}