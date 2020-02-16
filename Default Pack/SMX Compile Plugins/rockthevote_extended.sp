#pragma semicolon 1

#include <sourcemod>
#include <mapchooser>
#include "include/mapchooser_extended"
#include <nextmap>
#include <colors>

public Plugin myinfo =
{
	name = "[CSGO] MCE - Rock The Vote",
	author = "PowerLord & AlliedModders LLC | Edited: somebody.",
	description = "MCE - Rock The Vote",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle:g_Cvar_Needed = INVALID_HANDLE;
new Handle:g_Cvar_MinPlayers = INVALID_HANDLE;
new Handle:g_Cvar_InitialDelay = INVALID_HANDLE;
new Handle:g_Cvar_Interval = INVALID_HANDLE;
new Handle:g_Cvar_ChangeTime = INVALID_HANDLE;
new Handle:g_Cvar_RTVPostVoteAction = INVALID_HANDLE;

new bool:g_CanRTV = false;
new bool:g_RTVAllowed = false;
new g_Voters = 0;
new g_Votes = 0;
new g_VotesNeeded = 0;
new bool:g_Voted[MAXPLAYERS+1] = {false, ...};

new bool:g_InChange = false;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("rockthevote.phrases");
	LoadTranslations("basevotes.phrases");

	g_Cvar_Needed = CreateConVar("sm_rtv_needed", "0.60", "Percentage of players needed to rockthevote (Def 60%)", 0, true, 0.05, true, 1.0);
	g_Cvar_MinPlayers = CreateConVar("sm_rtv_minplayers", "0", "Number of players required before RTV will be enabled.", 0, true, 0.0, true, float(MAXPLAYERS));
	g_Cvar_InitialDelay = CreateConVar("sm_rtv_initialdelay", "30.0", "Time (in seconds) before first RTV can be held", 0, true, 0.00);
	g_Cvar_Interval = CreateConVar("sm_rtv_interval", "240.0", "Time (in seconds) after a failed RTV before another can be held", 0, true, 0.00);
	g_Cvar_ChangeTime = CreateConVar("sm_rtv_changetime", "1", "When to change the map after a succesful RTV: 0 - Instant, 1 - RoundEnd, 2 - MapEnd", _, true, 0.0, true, 2.0);
	g_Cvar_RTVPostVoteAction = CreateConVar("sm_rtv_postvoteaction", "0", "What to do with RTV's after a mapvote has completed. 0 - Allow, success = instant change, 1 - Deny", _, true, 0.0, true, 1.0);

	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);

	RegConsoleCmd("sm_rtv", Command_RTV);

	RegAdminCmd("sm_forcertv", Command_ForceRTV, ADMFLAG_CHANGEMAP, "Force an RTV vote");
	RegAdminCmd("mce_forcertv", Command_ForceRTV, ADMFLAG_CHANGEMAP, "Force an RTV vote");

	AutoExecConfig(true, "rockthevote_extended");
}

public OnMapStart()
{
	g_Voters = 0;
	g_Votes = 0;
	g_VotesNeeded = 0;
	g_InChange = false;

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			OnClientConnected(i);	
		}	
	}
}

public OnMapEnd()
{
	g_CanRTV = false;	
	g_RTVAllowed = false;
}

public OnConfigsExecuted()
{	
	g_CanRTV = true;
	g_RTVAllowed = false;
	CreateTimer(GetConVarFloat(g_Cvar_InitialDelay), Timer_DelayRTV, _, TIMER_FLAG_NO_MAPCHANGE);
}

public OnClientConnected(client)
{
	if(IsFakeClient(client))
		return;
	
	g_Voted[client] = false;

	g_Voters++;
	g_VotesNeeded = RoundToCeil(float(g_Voters) * GetConVarFloat(g_Cvar_Needed));
	
	return;
}

public OnClientDisconnect(client)
{
	if(IsFakeClient(client))
		return;
	
	if(g_Voted[client])
	{
		g_Votes--;
	}
	
	g_Voters--;
	
	g_VotesNeeded = RoundToCeil(float(g_Voters) * GetConVarFloat(g_Cvar_Needed));
	
	if (!g_CanRTV)
	{
		return;	
	}
	
	if (g_Votes && 
		g_Voters && 
		g_Votes >= g_VotesNeeded && 
		g_RTVAllowed ) 
	{
		if (GetConVarInt(g_Cvar_RTVPostVoteAction) == 1 && HasEndOfMapVoteFinished())
		{
			return;
		}
		
		StartRTV();
	}	
}

public Action:Command_RTV(client, args)
{
	if (!g_CanRTV || !client)
	{
		return Plugin_Handled;
	}
	
	AttemptRTV(client);
	
	return Plugin_Handled;
}

public Action:Command_Say(client, args)
{
	if (!g_CanRTV || !client)
	{
		return Plugin_Continue;
	}
	
	decl String:text[192];
	if (!GetCmdArgString(text, sizeof(text)))
	{
		return Plugin_Continue;
	}
	
	new startidx = 0;
	if(text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	
	new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
	
	if (strcmp(text[startidx], "rtv", false) == 0 || strcmp(text[startidx], "rockthevote", false) == 0)
	{
		AttemptRTV(client);
	}
	
	SetCmdReplySource(old);
	
	return Plugin_Continue;	
}

AttemptRTV(client)
{
	if (!g_RTVAllowed  || (GetConVarInt(g_Cvar_RTVPostVoteAction) == 1 && HasEndOfMapVoteFinished()))
	{
		CReplyToCommand(client, "[SM] %t", "RTV Not Allowed");
		return;
	}
		
	if (!CanMapChooserStartVote())
	{
		CReplyToCommand(client, "[SM] %t", "RTV Started");
		return;
	}
	
	if (GetClientCount(true) < GetConVarInt(g_Cvar_MinPlayers))
	{
		CReplyToCommand(client, "[SM] %t", "Minimal Players Not Met");
		return;			
	}
	
	if (g_Voted[client])
	{
		CReplyToCommand(client, "[SM] %t", "Already Voted", g_Votes, g_VotesNeeded);
		return;
	}	
	
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	g_Votes++;
	g_Voted[client] = true;
	
	CPrintToChatAll("[SM] %t", "RTV Requested", name, g_Votes, g_VotesNeeded);
	
	if (g_Votes >= g_VotesNeeded)
	{
		StartRTV();
	}	
}

public Action:Timer_DelayRTV(Handle:timer)
{
	g_RTVAllowed = true;
}

StartRTV()
{
	if (g_InChange)
	{
		return;	
	}
	
	if (EndOfMapVoteEnabled() && HasEndOfMapVoteFinished())
	{
		new String:map[PLATFORM_MAX_PATH];
		if (GetNextMap(map, sizeof(map)))
		{
			CPrintToChatAll("[SM] %t", "Changing Maps", map);
			CreateTimer(5.0, Timer_ChangeMap, _, TIMER_FLAG_NO_MAPCHANGE);
			g_InChange = true;
			
			ResetRTV();
			
			g_RTVAllowed = false;
		}
		return;	
	}
	
	if (CanMapChooserStartVote())
	{
		new MapChange:when = MapChange:GetConVarInt(g_Cvar_ChangeTime);
		InitiateMapChooserVote(when);
		
		ResetRTV();
		
		g_RTVAllowed = false;
		CreateTimer(GetConVarFloat(g_Cvar_Interval), Timer_DelayRTV, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

ResetRTV()
{
	g_Votes = 0;
			
	for (new i=1; i<=MAXPLAYERS; i++)
	{
		g_Voted[i] = false;
	}
}

public Action:Timer_ChangeMap(Handle:hTimer)
{
	g_InChange = false;

	LogMessage("RTV changing map manually");

	new String:map[PLATFORM_MAX_PATH];
	if (GetNextMap(map, sizeof(map)))
	{	
		ForceChangeLevel(map, "RTV after mapvote");
	}

	return Plugin_Stop;
}

public Action:Command_ForceRTV(client, args)
{
	if (!g_CanRTV || !client)
	{
		return Plugin_Handled;
	}

	ShowActivity2(client, "[RTVE] ", "%t", "Initiated Vote Map");

	StartRTV();

	return Plugin_Handled;
}