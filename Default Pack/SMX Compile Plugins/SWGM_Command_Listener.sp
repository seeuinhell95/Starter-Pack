#pragma semicolon 1

#include <SWGM>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] SWGM - Command Listener",
	author = "Someone | Edited: somebody.",
	description = "SWGM - Command Listener",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnAllPluginsLoaded()
{
	LoadTranslations("SWGM.phrases");
	LoadConfig();

	RegAdminCmd("sm_swgm_cl_reload", CMD_RELOAD, ADMFLAG_ROOT);
	RegAdminCmd("sm_swgm_reload", CMD_RELOAD, ADMFLAG_ROOT);
}

public Action CMD_RELOAD(int iClient, int iArgs)
{
	LoadConfig();
}

public Action Check(int iClient, const char[] sCommand, int iArgc)
{
	if(iClient != 0 && !SWGM_InGroup(iClient))
	{
		PrintToChat(iClient, "[\x02Steam\x01] \x06%t", "JoinSteam");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void LoadConfig()
{
	KeyValues Kv = new KeyValues("Command_Listener");

	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/SWGM/command_listener.ini");
	if (!FileToKeyValues(Kv, sBuffer)) SetFailState("Missing config file %s", sBuffer);

	if (Kv.GotoFirstSubKey())
	{
		do
		{
			if (Kv.GetSectionName(sBuffer, sizeof(sBuffer)))
			{
				AddCommandListener(Check, sBuffer);
			}
		} 
		while (Kv.GotoNextKey());
	}
	delete Kv;
}