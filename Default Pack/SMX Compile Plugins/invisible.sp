#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Invisible",
	author = "Bl4nk | Edited: somebody.",
	description = "Invisible",
	version = "1.0",
	url = "http://sourcemod.net"
};

new bool:g_bInvisible[MAXPLAYERS+1];

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegAdminCmd("sm_invisible", Command_Invisible, ADMFLAG_GENERIC, "sm_invisible <#userid|name> <0/1> - Enable/Disable invisibility on a player");
	RegAdminCmd("sm_invis", Command_Invisible, ADMFLAG_GENERIC, "sm_invis <#userid|name> <0/1> - Enable/Disable invisibility on a player");
	RegAdminCmd("sm_inv", Command_Invisible, ADMFLAG_GENERIC, "sm_inv <#userid|name> <0/1> - Enable/Disable invisibility on a player");

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmit);
		}
	}
}

public OnClientPutInServer(iClient)
{
	g_bInvisible[iClient] = false;
	SDKHook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
}

public Action: Command_Invisible(iClient, iArgCount)
{
	if (iArgCount < 2)
	{
		decl String:szCommand[10];
		GetCmdArg(0, szCommand, sizeof(szCommand));

		ReplyToCommand(iClient, " \x06[\x02Invisible\x06] \x07Használat: <\x06%s\x07> <\x06#UserID|Név\x07> <\x060-1\x07>", szCommand);
		return Plugin_Handled;
	}

	decl String:szTarget[MAX_NAME_LENGTH+1];
	GetCmdArg(1, szTarget, sizeof(szTarget));

	decl String:szTargetName[MAX_TARGET_LENGTH+1];
	decl iTargetList[MAXPLAYERS+1], iTargetCount, bool:bTnIsMl;

	if ((iTargetCount = ProcessTargetString(
			szTarget,
			iClient,
			iTargetList,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			szTargetName,
			sizeof(szTargetName),
			bTnIsMl)) <= 0)
	{
		ReplyToTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}

	decl String:szEnable[2];
	GetCmdArg(2, szEnable, sizeof(szEnable));

	new bool:bEnable = !!StringToInt(szEnable);
	for (new i = 0; i < iTargetCount; i++)
	{
		g_bInvisible[iTargetList[i]] = bEnable;
	}

	return Plugin_Handled;
}

public Action: Hook_SetTransmit(iClient, iOther)
{
	if (g_bInvisible[iClient] && iClient != iOther)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}