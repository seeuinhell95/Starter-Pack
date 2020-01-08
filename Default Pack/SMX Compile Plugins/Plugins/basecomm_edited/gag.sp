enum CommType
{
	CommType_Mute,
	CommType_UnMute,
	CommType_Gag,
	CommType_UnGag,
	CommType_Silence,
	CommType_UnSilence
};

void PerformMute(int client, int target, bool silent=false)
{
	g_Muted[target] = true;
	SetClientListeningFlags(target, VOICE_MUTED);
	
	FireOnClientMute(target, true);
	
	if (!silent)
	{
		LogAction(client, target, "\"%L\" muted \"%L\"", client, target);
	}
}

void PerformUnMute(int client, int target, bool silent=false)
{
	g_Muted[target] = false;
	if (g_Cvar_Deadtalk.IntValue == 1 && !IsPlayerAlive(target))
	{
		SetClientListeningFlags(target, VOICE_LISTENALL);
	}
	else if (g_Cvar_Deadtalk.IntValue == 2 && !IsPlayerAlive(target))
	{
		SetClientListeningFlags(target, VOICE_TEAM);
	}
	else
	{
		SetClientListeningFlags(target, VOICE_NORMAL);
	}
	
	FireOnClientMute(target, false);
	
	if (!silent)
	{
		LogAction(client, target, "\"%L\" unmuted \"%L\"", client, target);
	}
}

void PerformGag(int client, int target, bool silent=false)
{
	g_Gagged[target] = true;
	FireOnClientGag(target, true);
	
	if (!silent)
	{
		LogAction(client, target, "\"%L\" gagged \"%L\"", client, target);
	}
}

void PerformUnGag(int client, int target, bool silent=false)
{
	g_Gagged[target] = false;
	FireOnClientGag(target, false);
	
	if (!silent)
	{
		LogAction(client, target, "\"%L\" ungagged \"%L\"", client, target);
	}
}

void PerformSilence(int client, int target)
{
	if (!g_Gagged[target])
	{
		g_Gagged[target] = true;
		FireOnClientGag(target, true);
	}
	
	if (!g_Muted[target])
	{
		g_Muted[target] = true;
		SetClientListeningFlags(target, VOICE_MUTED);
		FireOnClientMute(target, true);
	}
	
	LogAction(client, target, "\"%L\" silenced \"%L\"", client, target);
}

void PerformUnSilence(int client, int target)
{
	if (g_Gagged[target])
	{
		g_Gagged[target] = false;
		FireOnClientGag(target, false);
	}
	
	if (g_Muted[target])
	{
		g_Muted[target] = false;
		
		if (g_Cvar_Deadtalk.IntValue == 1 && !IsPlayerAlive(target))
		{
			SetClientListeningFlags(target, VOICE_LISTENALL);
		}
		else if (g_Cvar_Deadtalk.IntValue == 2 && !IsPlayerAlive(target))
		{
			SetClientListeningFlags(target, VOICE_TEAM);
		}
		else
		{
			SetClientListeningFlags(target, VOICE_NORMAL);
		}
		FireOnClientMute(target, false);
	}
	
	LogAction(client, target, "\"%L\" unsilenced \"%L\"", client, target);
}

public Action Command_Mute(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_mute <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		PerformMute(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Muted target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Muted target", "_s", target_name);
	}
	
	return Plugin_Handled;	
}

public Action Command_Gag(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_gag <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		PerformGag(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Gagged target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Gagged target", "_s", target_name);
	}
	
	return Plugin_Handled;	
}

public Action Command_Silence(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_silence <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		PerformSilence(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Silenced target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Silenced target", "_s", target_name);
	}
	
	return Plugin_Handled;	
}

public Action Command_Unmute(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_unmute <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		if (!g_Muted[target])
		{
			continue;
		}
		
		PerformUnMute(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Unmuted target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Unmuted target", "_s", target_name);
	}
	
	return Plugin_Handled;	
}

public Action Command_Ungag(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_ungag <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		PerformUnGag(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Ungagged target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Ungagged target", "_s", target_name);
	}
	
	return Plugin_Handled;	
}

public Action Command_Unsilence(int client, int args)
{	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_unsilence <player>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
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

	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		PerformUnSilence(client, target);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Unsilenced target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Unsilenced target", "_s", target_name);
	}

	return Plugin_Handled;	
}