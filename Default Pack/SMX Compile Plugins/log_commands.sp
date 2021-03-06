#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new String:g_sCmdLogPath[256];

public Plugin myinfo =
{
    name = "[CSGO] Command Log",
    author = "Franc1sco | Edited: somebody.", 
    description = "Command Log", 
    version = "1.0", 
    url = "http://sourcemod.net"
};

public OnPluginStart()
{
	for(new i=0;;i++)
	{
		BuildPath(Path_SM, g_sCmdLogPath, sizeof(g_sCmdLogPath), "logs/LogCmd_%d.log", i);
		if ( !FileExists(g_sCmdLogPath) )
			break;
	}
}

public OnAllPluginsLoaded()
{
	AddCommandListener(Commands_CommandListener);
}

public Action:Commands_CommandListener(client, const String:command[], argc)
{
	if (client < 1 || !IsClientInGame(client))
		return Plugin_Continue;


	decl String:f_sCmdString[256];
	GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
	LogToFileEx(g_sCmdLogPath, "%L used: %s %s", client, command, f_sCmdString);

	return Plugin_Continue;
}