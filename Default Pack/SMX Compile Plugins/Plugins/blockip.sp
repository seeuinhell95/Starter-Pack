#pragma semicolon 1

#include <sourcemod>
#include <regex>

new Handle:ip_serv = INVALID_HANDLE,
	Handle:g_ImmFlag = INVALID_HANDLE,
	Handle:g_warnings = INVALID_HANDLE,
	Handle:g_punishment_mode = INVALID_HANDLE,
	Handle:g_ban_time = INVALID_HANDLE,
	Handle:g_WhiteListEnable = INVALID_HANDLE,
	Handle:WhitelistTrie = INVALID_HANDLE;

new bool:whitelist_enable,
	my_warnings[MAXPLAYERS+1] = 0,
	bool:g_bIsAdmin[MAXPLAYERS+1] = false,
	String:g_adminFlags[20],
	WhitelistSize;

public Plugin myinfo =
{
	name = "[CSGO] Block IP",
	author = "R1KO | Edited: somebody.",
	description = "Block IP",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	g_warnings = CreateConVar("sm_ip_block_warning", "2", "Number of warnings before punishment");
	g_punishment_mode = CreateConVar("sm_ip_block_punishment_mode", "1", "Type of punishment (0 - Kick, 1 - Ban)");
	g_ban_time = CreateConVar("sm_ip_ban_time", "60", "Ban time in minutes at sm_ip_block_punishment_mode 1 (0 - Perma)");
	g_WhiteListEnable = CreateConVar("sm_ip_whitelist_enable", "1", "Whether to use exception list (0 - No, 1 - Yes)");
	whitelist_enable = GetConVarBool(g_WhiteListEnable);
	g_ImmFlag = CreateConVar("sm_ip_immuniti_flag", "z", "Admin flag for immunity (\"\" - No immunity)");

	GetConVarString(g_ImmFlag, g_adminFlags, sizeof(g_adminFlags));
	ip_serv = CompileRegex("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(:\\d*)?");

	HookEvent("player_changename", EventNameChange, EventHookMode_Pre);
	AddCommandListener(SayChat, "say");
	AddCommandListener(SayChat, "say_team");
	RegAdminCmd("sm_ip_whitelist_reload", Command_ReloadWhiteList, ADMFLAG_ROOT);

	AutoExecConfig(true, "blockip");

	HookConVarChange(g_WhiteListEnable, ConVarChanges);
	HookConVarChange(g_ImmFlag, ConVarChanges);
}

public ConVarChanges(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == g_WhiteListEnable)
		whitelist_enable = GetConVarBool(convar);
	else if (convar == g_ImmFlag)
		GetConVarString(g_ImmFlag, g_adminFlags, sizeof(g_adminFlags));
}

public OnConfigsExecuted()
{
	whitelist_enable = GetConVarBool(g_WhiteListEnable);
	GetConVarString(g_ImmFlag, g_adminFlags, sizeof(g_adminFlags));
	if(whitelist_enable)
	{
		WhitelistTrie = CreateTrie();
		LoadWhiteList();
	}
}

public Action: Command_ReloadWhiteList(client, args)
{
	if(whitelist_enable) LoadWhiteList();
	else ReplyToCommand(client, "Command not available.");
	return Plugin_Handled;
}

bool: CheckIP(String:CheckIPString[], len)
{
	ReplaceString(CheckIPString, len, " ", "", false);
	if (MatchRegex(ip_serv, CheckIPString) > 0)
	{
		if(whitelist_enable)
		{
			GetRegexSubString(ip_serv, 0, CheckIPString, 32);
			if (GetTrieString(WhitelistTrie, CheckIPString, CheckIPString, len))
			{
				LogAction(-1, -1, "IP Address Checked %s (Allowed)", CheckIPString);
				return false;
			} 
		}
		LogAction(-1, -1, "Blocked extraneous IP address %s", CheckIPString);
		return true;

	}
	return false;
}

bool: IsAdmin(client)
{
	if(!StrEqual(g_adminFlags, ""))
		return GetUserAdmin(client) == INVALID_ADMIN_ID ? false : true;

	return (GetUserFlagBits(client) & ReadFlagString(g_adminFlags)) ? true : false;
}

public OnClientPostAdminCheck(client)
{
	if(IsFakeClient(client) || client <= 0) return;
	g_bIsAdmin[client] = false;

	if(IsAdmin(client))
	{
		g_bIsAdmin[client] = true;
		return;
	}

	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	if(CheckIP(name, sizeof(name)))
		Client_Punishment(client);
	else my_warnings[client] = 0;
}

public Action: SayChat(client, const String:command[], args)
{ 
	if(client <= 0) return Plugin_Continue;
	if(g_bIsAdmin[client]) return Plugin_Continue;

	decl String:text[192];
	GetCmdArgString(text, sizeof(text));
	if(CheckIP(text, sizeof(text)))
	{
	   if(++my_warnings[client] >= GetConVarInt(g_warnings)) Client_Punishment(client);
	   else PrintToChat(client, "IP Blocked. When you repeat - ban!");
	   return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action: EventNameChange(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bIsAdmin[client]) return Plugin_Continue;
	if(IsFakeClient(client) || client <= 0) return Plugin_Continue;

	decl String:name_change[MAX_NAME_LENGTH];
	GetEventString(event, "newname", name_change, sizeof(name_change));
	if(CheckIP(name_change, sizeof(name_change)))
		Client_Punishment(client);
	return Plugin_Continue;
}

Client_Punishment(client)
{
	if(GetConVarBool(g_punishment_mode)) ServerCommand("sm_ban #%d %d JĂˇtĂ©kszerverek hĂ­rdetĂ©se", GetClientUserId(client), GetConVarInt(g_ban_time));
	else KickClient(client, "Advertising extraneous servers");
	my_warnings[client] = 0;
}

LoadWhiteList()
{
	decl String:szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/ip_whitelist.txt");
	new Handle:hFile = OpenFile(szPath, "r");

	if (hFile == INVALID_HANDLE) LogError("Could not open file '%s'", szPath);
	else
	{
		if (WhitelistTrie != INVALID_HANDLE)
			ClearTrie(WhitelistTrie);

		decl String:szLine[PLATFORM_MAX_PATH];
		while (!IsEndOfFile(hFile) && ReadFileLine(hFile, szLine, sizeof(szLine)))
		{
			TrimString(szLine);
			SetTrieString(WhitelistTrie, szLine, szLine, false);
		}
		WhitelistSize = GetTrieSize(WhitelistTrie);

		if (WhitelistTrie == INVALID_HANDLE || WhitelistSize <= 0) whitelist_enable = false;
	}
	CloseHandle(hFile);
}