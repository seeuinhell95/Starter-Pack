#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Server UpTime",
	author = "PeEzZ | Edited: somebody.",
	description = "Server UpTime",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle: CVAR_UPTIME_PRINT = INVALID_HANDLE,
	UPTIME;

public OnPluginStart()
{
	CVAR_UPTIME_PRINT = CreateConVar("sm_uptime_print", "3600", "Uptime will be printed to the chat after this seconds.", _, true, 60.0);

	RegConsoleCmd("sm_uptime", CMD_UpTime);

	Timer_UpTime(INVALID_HANDLE);
	CreateTimer(GetConVarFloat(CVAR_UPTIME_PRINT), Timer_PrintToAll);

	LoadTranslations("uptime.phrases");
}

public Action: CMD_UpTime(client, args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	PrintUpTime(client);
	return Plugin_Handled;
}

PrintUpTime(client)
{
	new days = UPTIME / 86400,
		hours = (UPTIME / 3600) % 24,
		minutes = (UPTIME / 60) % 60,
		seconds = UPTIME % 60,
		String: buffer[128];

	if(days > 0)
	{
		Format(buffer, sizeof(buffer), "%t", "CMD_UpTime_DayHourMinSec", days, hours, minutes, seconds);
	}
	else if(hours > 0)
	{
		Format(buffer, sizeof(buffer), "%t", "CMD_UpTime_HourMinSec", hours, minutes, seconds);
	}
	else if(minutes > 0)
	{
		Format(buffer, sizeof(buffer), "%t", "CMD_UpTime_MinSec", minutes, seconds);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%t", "CMD_UpTime_Sec", seconds);
	}
	{
	PrintToChat(client, buffer);
	}
}

public Action: Timer_UpTime(Handle: timer)
{
	UPTIME ++;
	CreateTimer(1.0, Timer_UpTime);
}

public Action: Timer_PrintToAll(Handle: timer)
{
	for(new client = 1; client <= MaxClients; client++)
    {
		if(IsClientInGame(client))
		{
			PrintUpTime(client);
		}
	}
	CreateTimer(GetConVarFloat(CVAR_UPTIME_PRINT), Timer_PrintToAll);
}