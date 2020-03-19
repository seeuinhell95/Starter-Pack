#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define REASON_LEN 68
#define EVENT_PARAMS Handle event, const char[] name, bool dontBroadcast
#define VALID_PLAYER if(IsCorrectPlayer(client))
#define VALID_TARGET if(IsCorrectPlayer(target))
#define EVENT_GET_PLAYER GetClientOfUserId(GetEventInt(event, "userid"));

public Plugin myinfo =
{
	name		=	"[CSGO] GameVoting",
	author		=	"Neatek | Edited: somebody.",
	description	=	"GameVoting",
	version		=	"1.0",
	url			=	"http://sourcemod.net"
};

#define VOTE_BAN 1
#define VOTE_KICK 2
#define VOTE_MUTE 3
#define VOTE_SILENCE 4
#define VAR_VOTEBAN g_VoteChoise[client][vbSteam]
#define VAR_VOTEKICK g_VoteChoise[client][vkSteam]
#define VAR_VOTEMUTE g_VoteChoise[client][vmSteam]
#define VAR_VOTESILENCE g_VoteChoise[client][vsSteam]
#define VAR_IVOTEBAN g_VoteChoise[i][vbSteam]
#define VAR_IVOTEKICK g_VoteChoise[i][vkSteam]
#define VAR_IVOTEMUTE g_VoteChoise[i][vmSteam]
#define VAR_IVOTESILENCE g_VoteChoise[i][vsSteam]
#define VAR_TVOTEBAN g_VoteChoise[target][vbSteam]
#define VAR_TVOTEKICK g_VoteChoise[target][vkSteam]
#define VAR_TVOTEMUTE g_VoteChoise[target][vmSteam]
#define VAR_TVOTESILENCE g_VoteChoise[target][vsSteam]
#define VAR_CTYPE g_VoteChoise[client][current_type]
#define PLUG_TAG "GameVoting"
#define BAN_COMMAND  "voteban"
#define KICK_COMMAND "votekick"
#define GAG_COMMAND  "votegag"
#define MUTE_COMMAND "votemute"
#define SILENCE_COMMAND "votesilence"
#define CONVAR_ENABLED ConVars[1]
#define CONVAR_BAN_DURATION ConVars[2]
#define CONVAR_MUTE_DURATION ConVars[3]
#define CONVAR_KICK_DURATION ConVars[5]
#define CONVAR_BAN_ENABLE ConVars[6]
#define CONVAR_KICK_ENABLE ConVars[7]
#define CONVAR_MUTE_ENABLE ConVars[8]
#define CONVAR_MIN_PLAYERS ConVars[10]
#define CONVAR_AUTODISABLE ConVars[11]
#define CONVAR_BAN_PERCENT ConVars[12]
#define CONVAR_KICK_PERCENT ConVars[13]
#define CONVAR_MUTE_PERCENT ConVars[14]
#define CONVAR_IMMUNITY_FLAG ConVars[16]
#define CONVAR_IMMUNITY_zFLAG ConVars[17]
#define CONVAR_FLAG_START_VOTE ConVars[4]
#define CONVAR_START_VOTE_DELAY ConVars[9]
#define CONVAR_START_VOTE_ENABLE ConVars[15]
#define CONVAR_AUTHID_TYPE ConVars[18]
#define CONVAR_ENABLE_LOGS ConVars[19]
#define CONVAR_START_VOTE_MIN ConVars[20]
#define LOGS_ENABLED if(strlen(LogFilePath) > 0 && CONVAR_ENABLE_LOGS.IntValue > 0)

int g_startvote_delay = 0;
ConVar ConVars[21];
char LogFilePath[512];
ArrayList gReasons;
enum ENUM_VOTE_CHOISE
{
	current_type,
	voteban_reason,
	String:vbSteam[32],
	String:vkSteam[32],
	String:vmSteam[32],
	String:vsSteam[32]
}

int g_VoteChoise[MAXPLAYERS+1][ENUM_VOTE_CHOISE];
enum ENUM_KICKED_PLAYERS
{
	time,
	String:Steam[32],
}

int g_KickedPlayers[MAXPLAYERS+1][ENUM_KICKED_PLAYERS];

public void register_ConVars()
{
	CONVAR_ENABLED = CreateConVar("gamevoting_enable", "1", "Enable or disable plugin (def:1)", _, true, 0.0, true, 1.0);	
	CONVAR_AUTHID_TYPE = CreateConVar("gamevoting_authid", "2", "AuthID type, 1 - AuthId_Engine, 2 - AuthId_Steam2, 3 - AuthId_Steam3, 4 - AuthId_SteamID64 (def:1)", _, true, 1.0, true, 4.0);
	CONVAR_ENABLE_LOGS = CreateConVar("gamevoting_logs", "1", "Enable or disable logs for plugin (def:1)", _, true, 0.0, true, 1.0);

	CONVAR_MIN_PLAYERS = CreateConVar("gamevoting_players", "4", "Minimum players need to enable votes (def:8)", _, true, 0.0, true, 20.0);
	CONVAR_AUTODISABLE = CreateConVar("gamevoting_autodisable", "1", "Disable plugin when admins on server? (def:0)", _, true, 0.0, true, 1.0);

	CONVAR_BAN_ENABLE = CreateConVar("gamevoting_voteban", "1", "Enable or disable voteban functional (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_KICK_ENABLE = CreateConVar("gamevoting_votekick", "1", "Enable or disable votekick (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_MUTE_ENABLE = CreateConVar("gamevoting_votemute", "1", "Enable or disable votemute (def:1)", _, true, 0.0, true, 1.0);

	CONVAR_BAN_DURATION = CreateConVar("gamevoting_voteban_delay", "120", "Ban duration in minutes (def:120)", _, true, 0.0, false);
	CONVAR_KICK_DURATION = CreateConVar("gamevoting_votekick_delay", "120", "Kick duration in seconds (def:20)", _, true, 0.0, false);
	CONVAR_MUTE_DURATION = CreateConVar("gamevoting_votemute_delay", "120", "Mute duration in minutes (def:120)", _, true, 0.0, false);

	CONVAR_BAN_PERCENT = CreateConVar("gamevoting_voteban_percent", "80", "Needed percent of players for ban someone (def:80)", _, true, 0.0, true, 100.0);
	CONVAR_KICK_PERCENT = CreateConVar("gamevoting_votekick_percent", "80", "Needed percent of players for kick someone (def:80)", _, true, 0.0, true, 100.0);
	CONVAR_MUTE_PERCENT = CreateConVar("gamevoting_votemute_percent", "75", "Needed percent of players for mute someone (def:75)", _, true, 0.0, true, 100.0);

	CONVAR_IMMUNITY_FLAG = CreateConVar("gamevoting_immunity_flag", "a", "Immunity flag from all votes, set empty for disable immunity (def:a)");
	CONVAR_IMMUNITY_zFLAG = CreateConVar("gamevoting_immunity_zflag", "1", "Immunity for admin flag \"z\"");

	CONVAR_START_VOTE_ENABLE = CreateConVar("gamevoting_startvote_enable", "0", "Disable of enable public votes (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_FLAG_START_VOTE = CreateConVar("gamevoting_startvote_flag", "", "Who can start voting for ban or something, set empty for all players (def:a)");
	CONVAR_START_VOTE_DELAY = CreateConVar("gamevoting_startvote_delay", "0", "Delay between public votes in seconds (def:20)", _, true, 0.0, false);
	CONVAR_START_VOTE_MIN = CreateConVar("gamevoting_startvote_min", "0", "Minimum players for start \"startvote\" feature (def:4)", _, true, 0.0);

	AddCommandListener(OnClientCommands, "say");
	AddCommandListener(OnClientCommands, "say_team");

	AutoExecConfig(true, "GameVote");
	LoadTranslations("GameVote.phrases");
}

public int MenuHandler_Reason(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char item1[11];
		GetMenuItem(menu, client, item1, sizeof(item1));
		g_VoteChoise[client][voteban_reason] = StringToInt(item1);
		ShowMenu(client, VOTE_BAN, true);
	}
}

public void DisplayReasons(int client)
{
	Menu mReasons = CreateMenu(MenuHandler_Reason);
	SetMenuTitle(mReasons, "[GameVoting] Reason");

	int sSize = ((gReasons.Length)-1);
	char buff[REASON_LEN];
	char buff2[18];
	for(int i = 0; i <= sSize; i++) {
		gReasons.GetString(i, buff, sizeof(buff));
		IntToString(i, buff2, sizeof(buff2));
		AddMenuItem(mReasons, buff2, buff, ITEMDRAW_DEFAULT);
	}

	DisplayMenu(mReasons, client, 0);
}

public void checkcommands(int client, char[] string)
{
	VALID_PLAYER {

		#if defined PLUGIN_DEBUG_MODE
			PrintToChatAll("checkcommands : %s", string);
		#endif
	
		if(string[0] == '!' && string[1] == 'v' && string[2] == 'o' && string[3] == 't' && string[4] == 'e') {
			CheckCommand(client, string, "!");
		}
		
		else if(string[0] == '/' && string[1] == 'v' && string[2] == 'o' && string[3] == 't' && string[4] == 'e') {
			CheckCommand(client, string, "/");
		}
		
		else if(string[0] == 'v' && string[1] == 'o' && string[2] == 't' && string[3] == 'e') {
			CheckCommand(client, string, "");
		}
	}
}

public Action OnClientCommands(int client, char[] command, int argc) 
{
	char text[32]; 
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);

	#if defined PLUGIN_DEBUG_MODE
		PrintToChatAll("s : %s", text);
	#endif

	checkcommands(client,text);
	return Plugin_Continue;
}

public void OnPluginStart()
{
	ServerCommand("sv_allow_votes 0");
	HookEvent("player_disconnect", Event_PlayerDisconnected);
	register_ConVars();
	GVInitLog();
}

public void OnPluginEnd()
{
	UnhookEvent("player_disconnect", Event_PlayerDisconnected);
}

public void GVInitLog()
{
	if(CONVAR_ENABLE_LOGS.IntValue > 0)
	{
		BuildPath(Path_SM, LogFilePath, sizeof(LogFilePath), "logs/GameVote/");

		if(!DirExists(LogFilePath))
		{
			CreateDirectory(LogFilePath, 777);
		}

		char ftime[68];
		FormatTime(ftime, sizeof(ftime), "logs/GameVote/GameVote-%m-%d.txt",  GetTime());
		BuildPath(Path_SM, LogFilePath, sizeof(LogFilePath), ftime);
	}
}

public int FindFreeSlot()
{
	for(int i =0 ; i <= MAXPLAYERS; i ++) {
	
		if(g_KickedPlayers[i][time] == 0) {
		
			return i;
			
		
		} else if(g_KickedPlayers[i][time] < GetTime()) {
		
			g_KickedPlayers[i][time] = 0;
		
		}
		
	}

	return -1;

}

public bool isadmin(int client)
{
	if(CheckCommandAccess(client, "sm_command", ADMFLAG_GENERIC))
		return true;

	return false;
}

public bool adminsonserver()
{
	bool result = false;
	for(int i=0; i < GetMaxClients(); ++i) {
		if(IsCorrectPlayer(i)) {
			if(isadmin(i)) {
				result = true;
				break;
			}
		}
	}

	return result;
}

public void ClearVotesForClient(int client, int type)
{
	VALID_PLAYER {
		
		char auth[32];
		player_steam(client, auth, sizeof(auth));
		
		for(int i =0 ; i <= MAXPLAYERS; i ++) {
			
			switch(type) {
				case VOTE_BAN: {
					if(StrEqual(VAR_IVOTEBAN,auth,true)) {
						strcopy(VAR_IVOTEBAN, 32, "");
					}
				}
				
				case VOTE_KICK: {
					if(StrEqual(VAR_IVOTEKICK,auth,true)) {
						strcopy(VAR_IVOTEKICK, 32, "");
					}
				}
				
				case VOTE_MUTE: {
					if(StrEqual(VAR_IVOTEMUTE,auth,true)) {
						strcopy(VAR_IVOTEMUTE, 32, "");
					}
				}

				default: {
					break;
				}
				
			}
		}
	}
}

public void PushKickedPlayer(int client)
{
	VALID_PLAYER {
		int slot = FindFreeSlot();
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("Kicked free slot : %d", slot);
		#endif
		if(slot > -1) {
		
			g_KickedPlayers[client][time] = GetTime() + ( CONVAR_KICK_DURATION.IntValue );
			
			#if defined PLUGIN_DEBUG_MODE
				LogMessage("Kicked time : %d", (GetTime() + ( CONVAR_KICK_DURATION.IntValue )));
			#endif
			
			char auth[32];
			player_steam(client, auth, sizeof(auth));
			
			strcopy(g_KickedPlayers[client][Steam], 32, auth);
			
		}
		KickClient(client, "A játékosok kirúgtak. Várj %d másodpercet", CONVAR_KICK_DURATION.IntValue);
	}
}

public int KickedPlayer(int client)
{
	VALID_PLAYER {
		char auth[32];
		player_steam(client, auth, sizeof(auth));
		
		for(int i =0 ; i <= MAXPLAYERS; i ++) {
			if(StrEqual(g_KickedPlayers[i][Steam],auth,true)) {
			
				if(g_KickedPlayers[i][time] > GetTime()) {
					return ( g_KickedPlayers[i][time] - GetTime() );
				}
				else {
					strcopy(g_KickedPlayers[i][Steam], 32, "");
					g_KickedPlayers[i][time] = 0;
					return 0;
				
				}
			}
		}
	}
	
	return 0;
}

public void OnClientPostAdminCheck(int client)
{
	VALID_PLAYER {
		int wait = KickedPlayer(client);
		
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("Kicked wait : %d", wait);
		#endif
		
		if(wait > 0) {
			KickClient(client, "A játékosok kirúgtak. Várj %d másodpercet", wait);
		}
	}
}

public int GetCountVotes(int client, int type)
{
	VALID_PLAYER {
	
		int i_Counted = 0;
	
		char auth[32];
		player_steam(client, auth, sizeof(auth));
	
		for(int target = 0; target <= MAXPLAYERS; target++) {
			VALID_TARGET {
			
				switch(type) {
					case VOTE_BAN: {
						if(StrEqual(VAR_TVOTEBAN,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_KICK: {
						if(StrEqual(VAR_TVOTEKICK,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_MUTE: {
						if(StrEqual(VAR_TVOTEMUTE,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_SILENCE: {
						if(StrEqual(VAR_TVOTESILENCE,auth,true)) {
							i_Counted++;
						}
					}
				
					default: {
						break;
					}
				
				}
			
			}
		
		}

		return i_Counted;

	}

	return 0;
}

public void ClearChoise(int client)
{
	strcopy(VAR_VOTEBAN, 32, "");
	strcopy(VAR_VOTEKICK, 32, "");
	strcopy(VAR_VOTEMUTE, 32, "");
	g_VoteChoise[client][voteban_reason] = 0;
}

public int GetCountNeeded(int type)
{
	int players = CountPlayers();

	switch(type)
	{
		case VOTE_BAN:
		{
			return ((players * CONVAR_BAN_PERCENT.IntValue) / 100);
		}

		case VOTE_KICK:
		{
			return ((players * CONVAR_KICK_PERCENT.IntValue) / 100);
		}
	
		case VOTE_MUTE:
		{
			return ((players * CONVAR_MUTE_PERCENT.IntValue) / 100);
		}

		default:
		{
			return -1;
		}
	}

	return -1;
}

public void SetChoise(int type, int client, int target)
{
	VALID_PLAYER {
		VALID_TARGET {
		
			char auth[32];
			player_steam(target, auth, sizeof(auth));
			
			int needed = GetCountNeeded(type);
			
			if(needed < 1) {
				needed = 3;
			}
			
			int current = 0;
			
			switch(type) {
					
				case VOTE_BAN: {
					strcopy(VAR_VOTEBAN, 32, auth);
					current = GetCountVotes(target, VOTE_BAN);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("[\x04GameVoting\x01] \x02> \x06%t", "gv_voted_for_ban", c_name, t_name, current, needed);
					
					LOGS_ENABLED {
						char auth1[32];//,auth2[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for ban %N(%s). (%d/%d)",  client, auth1, target, auth, current, needed);
					}
				}
				
				case VOTE_KICK: {
					strcopy(VAR_VOTEKICK, 32, auth);
					current = GetCountVotes(target, VOTE_KICK);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("[\x04GameVoting\x01] \x02> \x06%t", "gv_voted_for_kick", c_name, t_name, current, needed);
					
					LOGS_ENABLED {
						char auth1[32];//,auth2[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for kick %N(%s). (%d/%d)",  client, auth1, target, auth, current, needed);
					}
				}
				
				case VOTE_MUTE: {
					strcopy(VAR_VOTEMUTE, 32, auth);
					current = GetCountVotes(target, VOTE_MUTE);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("[\x04GameVoting\x01] \x02> \x06%t", "gv_voted_for_mute", c_name, t_name, current, needed);
					
					LOGS_ENABLED {
						char auth1[32];//,auth2[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for mute %N(%s). (%d/%d)",  client, auth1, target, auth, current, needed);
					}
				}

				default: {
					return;
				}
				
			}

			if(current >= needed) {
				DoAction(target, type, client);
			}
			else if(current >= CONVAR_START_VOTE_MIN.IntValue && StartVoteFlag(client)) {
				if(type != VOTE_BAN) {
					ShowMenu(client, type, true);
				}
				else {
					DisplayReasons(client);
				}
			}
		}
	}
}

public int CountPlayers() {
	int output = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
		if(IsCorrectPlayer(i) && !HasImmunity(i)) 
			output++;
	
	return output;
}

public int CountPlayers_withoutImmunity() {
	int output = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
		if(IsCorrectPlayer(i)) 
			output++;
	
	return output;
}

public bool IsCorrectPlayer(int client) {
	if(client > 4096) {
		client = EntRefToEntIndex(client);
	}
		
	if( (client < 1 || client > MaxClients) || !IsClientConnected(client) ||  !IsClientInGame( client ) ) {
		return false;
	}
	
	#if !defined PLUGIN_DEBUG_MODE
	if(IsFakeClient(client) || IsClientSourceTV(client)) {
		return false;
	}
	#endif
	
	return true;
}

public Action Event_PlayerDisconnected(EVENT_PARAMS) 
{
	int client = EVENT_GET_PLAYER
	VALID_PLAYER {
		ClearChoise(client);
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("%N player disconnected", client);
		#endif
	}
}

public void CheckCommand(int client, const char[] args, const char[] pref)
{
	char command[24];
	strcopy(command, sizeof(command), args);
	TrimString(command);
	
	#if defined PLUGIN_DEBUG_MODE
		PrintToChatAll("CheckCommand : %s", command);
	#endif
	
	if(strlen(pref) > 0) {
		ReplaceString(command, sizeof(command), pref, "", true);
	}
	
	if(CONVAR_ENABLED.IntValue < 1) {
		return;
	}

	if(CountPlayers_withoutImmunity() < CONVAR_MIN_PLAYERS.IntValue) {
		PrintToChat(client, "[\x04GameVoting\x01] \x02> \x06%t", "gv_min_players", CONVAR_MIN_PLAYERS.IntValue);
		return;
	}

	if(CONVAR_AUTODISABLE.IntValue > 0) {
		if(adminsonserver()) {
			PrintToChat(client, "[\x04GameVoting\x01] \x02> \x06Jelenleg nem lehet szavazást indítani mivel van fent legalább egy \x02adminisztrátor\x06.");
			return;
		}
	}

	if(StrEqual(command, BAN_COMMAND, false)) {
		if(CONVAR_BAN_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_BAN,false);
		return;
	}
	
	if(StrEqual(command, KICK_COMMAND, false)) {
		if(CONVAR_KICK_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_KICK,false);
		return;
	}
	
	if(StrEqual(command, MUTE_COMMAND, false)) {
		if(CONVAR_MUTE_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_MUTE,false);
		return;
	}
}

public bool StartVoteFlag(int client) {

	char s_flag[11];
	GetConVarString(CONVAR_FLAG_START_VOTE, s_flag, sizeof(s_flag));

	if(CONVAR_START_VOTE_ENABLE.IntValue < 1) {
		return false;
	}

	if(g_startvote_delay > GetTime() && CONVAR_START_VOTE_ENABLE.IntValue > 0 ) {
		PrintToChat(client, "[\x04GameVoting\x01] \x02> \x06%t", "gv_wait_before_startvote", ((g_startvote_delay)-GetTime()));
		return false;
	}

	if(strlen(s_flag) < 1) {
		return true;
	}
	
	int b_flags = ReadFlagString(s_flag);
	if ((GetUserFlagBits(client) & b_flags) == b_flags) {
		return true;
	}
	
	return false;
}

public bool HasImmunity(int client) {
	char s_flag[11];
	GetConVarString(CONVAR_IMMUNITY_FLAG, s_flag, sizeof(s_flag));
	
	if(strlen(s_flag) < 1) {
		return false;
	}
	
	int b_flags = ReadFlagString(s_flag);

	if ((GetUserFlagBits(client) & b_flags) == b_flags) {
		return true;
	}
	if(CONVAR_IMMUNITY_zFLAG.IntValue > 0) {
		if (GetUserFlagBits(client) & ADMFLAG_ROOT) {
			return true;
		}
	}

	return false;
}

public void ShowMenu(int client, int type, bool startvote_force) {

	VALID_PLAYER {
	
		if(CountPlayers_withoutImmunity() < 1)
			return;
	
		VAR_CTYPE = type;
		
		Menu mymenu;

		if(!startvote_force) {
			mymenu = new Menu(menu_handler);
		}
		else {
			mymenu = new Menu(startvote_menu_player_handler);
		}

		char s_mtitle[48];
		switch(type) {
			case VOTE_BAN: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_ban_title", client);
			}
			case VOTE_KICK: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_kick_title", client);
			}
			case VOTE_MUTE: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_mute_title", client);
			}
			default: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING");
			}	
		}
		
		mymenu.SetTitle(s_mtitle);

		char Name[48], id[11];
		for(int target=0;target<GetMaxClients();target++) {
			VALID_TARGET {
			
				if(target != client && !HasImmunity(target)) {
					IntToString(target, id, sizeof(id));
					FormatEx(Name,sizeof(Name),"%N",target);
					mymenu.AddItem(id,Name);
				}

			}
		}
		mymenu.Display(client, MENU_TIME_FOREVER);
	}
}

public void StartVote(int client, int target, int type) {

	VALID_PLAYER { VALID_TARGET {
		if(g_startvote_delay > GetTime()) {
			PrintToChat(client, "[\x04GameVoting\x01] \x02> \x06%t", "gv_wait_before_startvote", ((g_startvote_delay)-GetTime()));
			return;
		}

		g_startvote_delay = GetTime() + CONVAR_START_VOTE_DELAY.IntValue;
		
		char s_logs[128];
		char t_name[32];
		GetClientName(target, t_name, sizeof(t_name));
		
		for(int i = 1; i <= MaxClients; i++) {
			if(IsCorrectPlayer(i)) {
				Menu mymenu = new Menu(menu_startvote_action_handler);
				char s_typeInitiator[48];
				FormatEx(s_typeInitiator,sizeof(s_typeInitiator),"%d|%d|%d",client,target,VAR_CTYPE);
				
				char s_Menu[86];
				switch(VAR_CTYPE) {
					case VOTE_BAN: {
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_ban_title_question", i, t_name);
						
						char reason[64];
						gReasons.GetString(g_VoteChoise[client][voteban_reason], reason, sizeof(reason));
						
						if(strlen(s_logs) < 1) {
						LOGS_ENABLED {
							char auth[32], auth1[32];
							player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
							FormatEx(s_logs, sizeof(s_logs), "Player %N(%s) started public vote for ban %N(%s). Reason = %s",  client, auth,target,auth1,reason);
						}
						}
					}
					case VOTE_KICK: {
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_kick_title_question", i, t_name);
						
						if(strlen(s_logs) < 1) {
						LOGS_ENABLED {
							char auth[32],auth1[32];
							player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
							FormatEx(s_logs, sizeof(s_logs), "Player %N(%s) started public vote for kick %N(%s).",  client, auth,target,auth1);
						}
						}
					}
					case VOTE_MUTE: {
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_mute_title_question", i, t_name);
						
						if(strlen(s_logs) < 1) {
						LOGS_ENABLED {
							char auth[32],auth1[32];
							player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
							FormatEx(s_logs,sizeof(s_logs), "Player %N(%s) started public vote for mute %N(%s).",  client, auth,target,auth1);
						}
						}
					}
					default: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING?");
						return;
					}	
				}
				mymenu.SetTitle(s_Menu);
				
				mymenu.AddItem("","----", ITEMDRAW_DISABLED);
				mymenu.AddItem("","----", ITEMDRAW_DISABLED);
				
				Format(s_Menu, sizeof(s_Menu), "%T", "gv_yes", i);
				
				mymenu.AddItem(s_typeInitiator,s_Menu);
				
				Format(s_Menu, sizeof(s_Menu), "%T", "gv_no", i);
				
				mymenu.AddItem("",s_Menu);
				
				mymenu.Display(i, MENU_TIME_FOREVER);
			}
		}
		
		LOGS_ENABLED {
			LogToFile(LogFilePath, s_logs);
		}

	} }
}

public int startvote_menu_player_handler(Menu menu, MenuAction action, int client, int item) {

	if (action == MenuAction_Select) {
	
		char info[11];
		GetMenuItem(menu, item, info, sizeof(info));
		StartVote(client, StringToInt(info), VAR_CTYPE);
		
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public int menu_startvote_action_handler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[48];
		GetMenuItem(menu, item, info, sizeof(info));
		
		if(strlen(info) > 0) 
		{
		
		char ex[3][11];
		ExplodeString(info, "|", ex, 3, 11);

		int target = StringToInt(ex[1]);
		int type = StringToInt(ex[2]);

		VALID_TARGET {
			SetChoise(type, client, target);
		}
		
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public int menu_handler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[11];
		GetMenuItem(menu, item, info, sizeof(info));
		int target = StringToInt(info);
		VALID_TARGET {
			SetChoise(VAR_CTYPE, client, target);
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public void player_steam(int client, char[] steam_id, int size) {
	char auth[32];
	switch(CONVAR_AUTHID_TYPE.IntValue)
	{
		case 1: {
			if(GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 2: {
			if(GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 3:  {
			if(GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 4:  {
			if(GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
	}
}

public void DoAction(int client, int type, int last) {
	
	switch(type) {
		case VOTE_BAN: {
			ClearChoise(client);
			ClearVotesForClient(client, VOTE_BAN);
			
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was banned by voting. (Last voted player: %N)",  client, auth,last);
			}
			
			int reason_num = HasReason(client);
			char reason[64];
			if(reason_num > -1) {
				gReasons.GetString(reason_num, reason, sizeof(reason));
			}
			else {
				strcopy(reason, sizeof(reason), "Empty reason");
			}

			ServerCommand("sm_ban #%d %d \"Játékosok szavazása.\"", GetClientUserId(client), CONVAR_BAN_DURATION.IntValue);
		}
		case VOTE_KICK: {
			ClearChoise(client);
			ClearVotesForClient(client, VOTE_KICK);
			
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was kicked by voting. (Last voted player: %N)",  client, auth,last);
			}

			PushKickedPlayer(client);
		}
		case VOTE_MUTE: {
			ClearVotesForClient(client, VOTE_MUTE);
			
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was muted by voting. (Last voted player: %N)",  client, auth,last);
			}

			ServerCommand("sm_silence #%d %d \"Játékosok szavazása.\"", GetClientUserId(client), CONVAR_MUTE_DURATION.IntValue);
		}
	}
}

public int HasReason(int target)
{
	char auth[32];
	player_steam(target, auth, sizeof(auth));
	for(int i =0 ; i <= MAXPLAYERS; i ++) {
		if(StrEqual(VAR_IVOTEBAN,auth,true)) {
			if(g_VoteChoise[i][voteban_reason] > 0) {
				return g_VoteChoise[i][voteban_reason];
			}
		}
	}

	return -1;
}