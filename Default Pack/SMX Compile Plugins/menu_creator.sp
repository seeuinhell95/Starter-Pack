#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name		= "[CSGO] Menu Creator",
	author		= "wS! | Edited: Cherry & somebody.",
	description = "Menu Creator",
	version 	= "1.0",
	url			= "http://sourcemod.net"
};

#include "menu_creator/vars.sp"
#include "menu_creator/functions.sp"
#include "menu_creator/mc_cmd.sp"
#include "menu_creator/menu.sp"

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteString");
	return APLRes_Success;
}

public OnPluginStart()
{
	g_Engine = GetEngineVersion();
	for (new i = 1, target; i <= MaxClients; i++)
	{
		for (target = 1; target <= MaxClients; target++)
			g_TargetCanBeInMenu[i][target] = true;
	}
}

public OnConfigsExecuted()
{
	if (g_hTrie_cmd)
	{
		if (g_map_start_cmd[0])
		{
			decl String:s[sizeof(g_map_start_cmd)];
			strcopy(s, sizeof(s), g_map_start_cmd);
			wS_EditText(0, s, sizeof(s));
			ServerCommand(s);
		}
		return;
	}

	LoadTranslations("menu_creator.phrases");

	for (new ItemTrie:i; i < ItemTrie; i++)
		g_hItemTrie[i]			= CreateTrie();

	if (!(g_hTrie_cmd			= CreateTrie())) SetFailState("wtf");
	g_hTrie_alias				= CreateTrie();

	g_hMenuArray[ma_name]		= CreateArray(name_LENGTH);
	g_hMenuArray[ma_title]		= CreateArray(title_LENGTH);
	g_hMenuArray[ma_type]		= CreateArray(1);
	g_hMenuArray[ma_item]		= CreateArray(1);
	g_hMenuArray[ma_back]		= CreateArray(name_LENGTH);
	g_hMenuArray[ma_back_cmds]	= CreateArray(cmds_LENGTH);
	g_hMenuArray[ma_exit]		= CreateArray(1);

	RegAdminCmd("mc", mc_cmd, ADMFLAG_ROOT);
	RegAdminCmd("menucreator", mc_cmd, ADMFLAG_ROOT);
	RegAdminCmd("menu_creator", mc_cmd, ADMFLAG_ROOT);

	ServerCommand("exec menu_creator/menu_creator.cfg");
}

public OnClientDisconnect(client)
{
	g_sMyLastKey[client][0]		= 0;
	g_MyLastMenuIndex[client]	= -1;
	g_MyLastTargetId[client]	= 0;

	for (new ClientTrie:t; t < ClientTrie; t++)
		wS_CloseHandle(g_hClientTrie[client][t]);

	for (new target = 1; target <= MaxClients; target++)
		g_TargetCanBeInMenu[client][target] = true;

	if (g_hJoinCmdTimer[client])
	{
		KillTimer(g_hJoinCmdTimer[client]);
		g_hJoinCmdTimer[client]	= INVALID_HANDLE;
	}
}

public OnClientPostAdminCheck(client)
{
	if (g_client_join_cmd[0])
	{
		if (g_JoinCmdDelay > 0)
		{
			if (g_hJoinCmdTimer[client]) KillTimer(g_hJoinCmdTimer[client]);
			g_hJoinCmdTimer[client] = CreateTimer(float(g_JoinCmdDelay), JoinCmd_TIMER, client);
		}
		else
			JoinCmds(client);
	}
}

public Action:JoinCmd_TIMER(Handle:timer, any:client)
{
	g_hJoinCmdTimer[client]	= INVALID_HANDLE;
	JoinCmds(client);
	return Plugin_Stop;
}

static JoinCmds(client)
{
	decl String:s[sizeof(g_client_join_cmd)];
	strcopy(s, sizeof(s), g_client_join_cmd);
	wS_EditText(client, s, sizeof(s));
	ServerCommand(s);
}