#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] ExoJump Giver",
	author = "Franc1sco | Edited: somebody.",
	description = "ExoJump Giver",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_exojump", Command_ExoJump, ADMFLAG_GENERIC);
	RegAdminCmd("sm_jump", Command_ExoJump, ADMFLAG_GENERIC);
	RegAdminCmd("sm_exo", Command_ExoJump, ADMFLAG_GENERIC);
}

public Action Command_ExoJump(int client, int args)
{
	if(args < 2)
	{
		ReplyToCommand(client, " \x06[\x02ExoJump\x06] \x07Használat: \x07<\x06sm_exojump\x07> <\x06#UserID|Név\x07> <\x060-1\x07>");
		return Plugin_Handled;
	}

	char strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 
	char strEnable[32]; GetCmdArg(2, strEnable, sizeof(strEnable)); 

	int enable = StringToInt(strEnable);

	if(enable > 1 || enable < 0)
	{
		ReplyToCommand(client, " \x06[\x02ExoJump\x06] \x07Használat: \x07<\x06sm_exojump\x07> <\x06#UserID|Név\x07> <\x060-1\x07>");
		return Plugin_Handled;
	}

	char strTargetName[MAX_TARGET_LENGTH]; 
	int TargetList[MAXPLAYERS], TargetCount; 
	bool TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{
		ReplyToCommand(client, " \x06[\x02ExoJump\x06] \x07A játékos nem található.");
		return Plugin_Handled; 
	}

	for (int i = 0; i < TargetCount; i++) 
	{
		int iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{
			SetEntProp(iClient, Prop_Send, "m_passiveItems", enable, 1, 1);
			ReplyToCommand(client, " \x06[\x02ExoJump\x06] \x07Extra ugrás \x06%s \x07a következőnél: \x06%N", iClient, enable==1?"bekapcsolva":"kikapcsolva");
		}
	}

	return Plugin_Handled;
}