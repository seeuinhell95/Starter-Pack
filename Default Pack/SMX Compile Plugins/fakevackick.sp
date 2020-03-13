#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new bool:isBeingKicked;

public Plugin myinfo =
{
	name = "[CSGO] Fake VAC Kick",
	author = "Byte | Edited: somebody.",
	description = "Fake VAC Kick",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_fakevackick", Command_FakeVACKick, ADMFLAG_KICK, "sm_fakevackick <#userid|name>");
	RegAdminCmd("sm_fakekick", Command_FakeVACKick, ADMFLAG_KICK, "sm_fakevackick <#userid|name>");
	RegAdminCmd("sm_fvk", Command_FakeVACKick, ADMFLAG_KICK, "sm_fakevackick <#userid|name>");

	HookEvent( "player_disconnect", PlayerDisconnect_Event, EventHookMode_Pre );
	isBeingKicked = false;
}

public Action: Command_FakeVACKick(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, " \x06[\x02VAC\x06] \x07Használat: <\x06sm_fakevackick\x07> <\x06#UserID|Név\x07>");
		return Plugin_Handled;
	}

	decl String:Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	decl String:arg[65];
	new len = BreakString(Arguments, arg, sizeof(arg));

	if (len == -1)
	{
		len = 0;
		Arguments[0] = '\0';
	}

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
		arg,
		client, 
		target_list, 
		MAXPLAYERS, 
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) > 0)
	{
		isBeingKicked = true;
		decl String:reason[64];
		Format(reason, sizeof(reason), Arguments[len]);

		PrintToChatAll(" \x07%s has been permanently banned from official CS:GO servers.", target_name);
		new kick_self = 0;

		for (new i = 0; i < target_count; i++)
		{
			if (target_list[i] == client)
			{
				kick_self = client;
			}
			else
			{
				PerformKick(target_list[i]);
			}
		}
		if (kick_self)
		{
			PerformKick(client);
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}

	return Plugin_Handled;
}

PerformKick(target)
{
	KickClient(target, "%s", "VAC banned from secure server");
}

public Action: PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (isBeingKicked)
	{
		SetEventString(event, "reason", "");
		isBeingKicked = false;
	}

	return Plugin_Continue;
}