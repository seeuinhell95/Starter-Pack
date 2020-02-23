#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "[CSGO] Fake Client Execute",
	author = "Twilight Suzuka | Edited: somebody.",
	description = "Fake Client Execute",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_fexec", ClientFakeExec, ADMFLAG_CHEATS);

	LoadTranslations("common.phrases");
}

public Action: ClientFakeExec(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Használat: sm_fexec <#userid|név> <parancs>");
		return Plugin_Handled;
	}

	decl String:arg[65], String:cmd[192];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, cmd, sizeof(cmd));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		PerformFakeExec(client, target_list[i], cmd);
	}

	return Plugin_Handled;
}

stock PerformFakeExec(client, target, const String:cmd[])
{
	FakeClientCommandEx(target,cmd);
}