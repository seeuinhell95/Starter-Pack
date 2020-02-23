#define name_LENGTH			32
#define title_LENGTH		64
#define phrase_LENGTH		64

#define key_LENGTH			48
#define text_LENGTH			256 // panel
#define cmds_LENGTH			512

#define PANEL_BACK			8
#define MAX_ARGS			10
#define PLAYER_LIST			"PLAYER_LIST"

#define ERROR_SYNTAX		"Invalid syntax"
#define ERROR_NOMENU		"First need create a menu"

#define MC_MENU				1
#define MC_PANEL			2

#define IT_TEXT				1
#define IT_ITEM				2

#define MSG_CHAT			1
#define MSG_CONSOLE			2
#define MSG_CENTER			3

#define MC_FLAG_no_title	(1 << 0)
#define MC_FLAG_no_text		(1 << 1)
#define MC_FLAG_no_item		(1 << 2)
#define MC_FLAG_no_back		(1 << 3)
#define MC_FLAG_no_exit		(1 << 4)

new Handle:g_hTrie_cmd;		// "cmd" -> "name"
new Handle:g_hTrie_alias;	// "key" -> "rcon commands"

enum ClientTrie
{
	Handle:ct_LastPage = 0,	// "name" -> pos
	Handle:ct_ItemBlocked,	// "name" -> 1
	Handle:ct_ItemHidden,	// "name" -> 1
	Handle:ct_ItemInfo,		// "name" -> "info"
	Handle:ct_PlayerList	// "cmds" -> "value"
};
new Handle:g_hClientTrie[MAXPLAYERS + 1][ClientTrie];

enum ItemTrie
{
	Handle:it_info = 0,		// "name1" -> "info"
	Handle:it_text,			// "name1" -> "text"
	Handle:it_cmds,			// "name1" -> "cmds"
	Handle:it_type,			// "name1" -> IT_TEXT or IT_ITEM
	Handle:it_flag,			// "name1" -> ADMFLAG_ROOT
	Handle:it_pos			// "name1" -> 0
};
new Handle:g_hItemTrie[ItemTrie];

enum MenuArray
{
	Handle:ma_name = 0,		// "name"
	Handle:ma_title,		// "text" or "#text"
	Handle:ma_type,			// MC_MENU or MC_PANEL
	Handle:ma_item,			// items count
	Handle:ma_back,			// "name"
	Handle:ma_back_cmds,	// "cmds"
	Handle:ma_exit			// 1 = exit button on, 0 = off
};
new Handle:g_hMenuArray[MenuArray]; // общий индекс

new g_MenuCount	= 0;		// ma_name size

new g_pos;					// panel item pos
new g_panel_item_count;		// 7 limit

new String:g_client_join_cmd[cmds_LENGTH];
new String:g_map_start_cmd[cmds_LENGTH];

new g_LastRandomNumber;
new EngineVersion:g_Engine;

new g_MyLastMenuIndex[MAXPLAYERS + 1] = {-1, ...}; // ma_name index
new String:g_sMyLastKey[MAXPLAYERS + 1][key_LENGTH];
new g_MyLastTargetId[MAXPLAYERS + 1];
new bool:g_TargetCanBeInMenu[MAXPLAYERS + 1][MAXPLAYERS + 1]; // [client][target]
new Handle:g_hJoinCmdTimer[MAXPLAYERS + 1], g_JoinCmdDelay;