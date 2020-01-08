#pragma semicolon 1

#include <sourcemod>

#pragma tabsize 0

ConVar sm_removemessages_cvar,
sm_removemessages_gametext,
sm_removemessages_radiochat,
sm_removemessages_radioaudio,
sm_removemessages_changeteam,
sm_removemessages_changename,
sm_removemessages_connect,
sm_removemessages_disconnect;
bool cvar,
gametext,
radiochat,
radioaudio,
changeteam,
changename,
connect,
disconnect;

new const String:g_sBlockMsgs[][] =
{
    "#Team_Cash_Award_Win_Hostages_Rescue",
    "#Team_Cash_Award_Win_Defuse_Bomb",
    "#Team_Cash_Award_Win_Time",
    "#Team_Cash_Award_Elim_Bomb",
    "#Team_Cash_Award_Elim_Hostage",
    "#Team_Cash_Award_T_Win_Bomb",
    "#Player_Point_Award_Assist_Enemy_Plural",
    "#Player_Point_Award_Assist_Enemy",
    "#Player_Point_Award_Killed_Enemy_Plural",
    "#Player_Point_Award_Killed_Enemy",
    "#Player_Cash_Award_Kill_Hostage",
    "#Player_Cash_Award_Damage_Hostage",
    "#Player_Cash_Award_Get_Killed",
    "#Player_Cash_Award_Respawn",
    "#Player_Cash_Award_Interact_Hostage",
    "#Player_Cash_Award_Killed_Enemy",
    "#Player_Cash_Award_Rescued_Hostage",
    "#Player_Cash_Award_Bomb_Defused",
    "#Player_Cash_Award_Bomb_Planted",
    "#Player_Cash_Award_Killed_Enemy_Generic",
    "#Player_Cash_Award_Killed_VIP",
    "#Player_Cash_Award_Kill_Teammate",
    "#Team_Cash_Award_Win_Hostage_Rescue",
    "#Team_Cash_Award_Loser_Bonus",
    "#Team_Cash_Award_Loser_Zero",
    "#Team_Cash_Award_Rescued_Hostage",
    "#Team_Cash_Award_Hostage_Interaction",
    "#Team_Cash_Award_Hostage_Alive",
    "#Team_Cash_Award_Planted_Bomb_But_Defused",
    "#Team_Cash_Award_CT_VIP_Escaped",
    "#Team_Cash_Award_T_VIP_Killed",
    "#Team_Cash_Award_no_income",
    "#Team_Cash_Award_Generic",
    "#Team_Cash_Award_Custom",
    "#Team_Cash_Award_no_income_suicide",
    "#Player_Cash_Award_ExplainSuicide_YouGotCash",
    "#Player_Cash_Award_ExplainSuicide_TeammateGotCash",
    "#Player_Cash_Award_ExplainSuicide_EnemyGotCash",
    "#Player_Cash_Award_ExplainSuicide_Spectators",
    "#SFUI_Notice_Warmup_Has_Ended",
    "#SFUI_Notice_Match_Will_Start_Chat",
    "#hostagerescuetime",
    "#Chat_SavePlayer_Savior",
    "#Chat_SavePlayer_Saved",
    "#Chat_SavePlayer_Spectator",
	"#Cstrike_TitlesTXT_Game_teammate_attack"
};

public Plugin myinfo =
{
    name = "[CSGO] Remove Messages", 
    author = "Fox1qqq | Edited: somebody.", 
    version = "1.0",
    description = "Remove Messages",
    url = "http://sourcemod.net"
};

public OnPluginStart()
{
	sm_removemessages_cvar = CreateConVar("sm_removemessages_cvar",     			  "1",            "Cvar Message", _, true, 0.0, true, 1.0);
	sm_removemessages_gametext = CreateConVar("sm_removemessages_gametext",           "1",            "Game Text Message", _, true, 0.0, true, 1.0);
	sm_removemessages_radiochat = CreateConVar("sm_removemessages_radiochat",         "1",            "Radio Chat Message", _, true, 0.0, true, 1.0);
	sm_removemessages_radioaudio = CreateConVar("sm_removemessages_radioaudio",       "1",            "Radio Chat Audio", _, true, 0.0, true, 1.0);
	sm_removemessages_changeteam = CreateConVar("sm_removemessages_changeteam",       "1",            "Change Team Message", _, true, 0.0, true, 1.0);
	sm_removemessages_changename = CreateConVar("sm_removemessages_changename",       "1",            "Change Name Message", _, true, 0.0, true, 1.0);
	sm_removemessages_connect = CreateConVar("sm_removemessages_connect",             "1",            "Connect Message", _, true, 0.0, true, 1.0);
	sm_removemessages_disconnect = CreateConVar("sm_removemessages_disconnect",       "1",            "Disconnect Message.", _, true, 0.0, true, 1.0);

    HookUserMessage(GetUserMessageId("TextMsg"), UserMsgText, true);
    HookUserMessage(GetUserMessageId("RadioText"), UserMsgRadioText, true);
    HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);

    HookEvent("player_team", OnTeam, EventHookMode_Pre);
    HookEvent("server_cvar", Event_Cvar, EventHookMode_Pre);
    HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_PlayerConnect, EventHookMode_Pre);	

	decl String:r[][]={"cheer", "compliment", "coverme", "fallback", "followme", "enemydown", "enemyspot", "getinpos", "getout", "go", "holdpos", "inposition",
	"needbackup", "negative", "nice", "regroup", "report", "reportingin", "roger", "sectorclear", "sticktog", "stormfront", "takingfire", "takepoint", "thanks"};
	new i=sizeof(r)-1;
	do AddCommandListener(UserMsgRadioAudio, r[i]);
	while(i--);

	AutoExecConfig(true, "removemessages");
}

public OnConfigsExecuted()
{
	ServerCommand("sv_ignoregrenaderadio 1");
    cvar = sm_removemessages_cvar.BoolValue;
    gametext = sm_removemessages_gametext.BoolValue;
    radiochat = sm_removemessages_radiochat.BoolValue;
	radioaudio = sm_removemessages_radioaudio.BoolValue;
    changeteam = sm_removemessages_changeteam.BoolValue;
    changename = sm_removemessages_changename.BoolValue;
    connect = sm_removemessages_connect.BoolValue;
    disconnect = sm_removemessages_disconnect.BoolValue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == sm_removemessages_cvar)
    {
        cvar = convar.BoolValue;
    }
    else if (convar == sm_removemessages_gametext)
    {
        gametext = convar.BoolValue;
    }
    else if (convar == sm_removemessages_radiochat)
    {
        radiochat = convar.BoolValue;
    }
    else if (convar == sm_removemessages_radioaudio)
    {
        radioaudio = convar.BoolValue;
    }
    else if (convar == sm_removemessages_changeteam)
    {
        changeteam = convar.BoolValue;
    }
    else if (convar == sm_removemessages_changename)
    {
        changename = convar.BoolValue;
    }
    else if (convar == sm_removemessages_connect)
    {
        connect = convar.BoolValue;
    }
    else if (convar == sm_removemessages_disconnect)
    {
        disconnect = convar.BoolValue;
    }
}

public Action:Event_PlayerConnect(Handle:event, const String:name[], bool:dontBroadcast)
{
    SetEventBroadcast(event, true);
 
    return Plugin_Continue;
}

public Action:Event_Cvar(Handle:event, const String:name[], bool:dontBroadcast) return cvar ? Plugin_Handled : Plugin_Continue;

public Action:UserMsgText(UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init)
{
    if(gametext)
	{
        decl String:buffer[64];
        PbReadString(msg, "params", buffer, sizeof(buffer), 0);
        
        for(new i = 0; i < sizeof(g_sBlockMsgs); ++i)
        {
            if(!strcmp(buffer, g_sBlockMsgs[i]))
            {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action:UserMsgRadioText(UserMsg:msg_id, Handle:pb, players[], playersNum, bool:reliable, bool:init) return radiochat ? Plugin_Handled : Plugin_Continue;

public Action:UserMsgRadioAudio(C, String:N[], A) return radioaudio ? Plugin_Handled : Plugin_Continue;

public Action OnTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(!event.GetBool("disconnect"))
		event.SetBool("silent", true);
}

public Action:SayText2(UserMsg:msg_id, Handle:bf, players[], playersNum, bool:reliable, bool:init)
{
    if(changename)
	{
        if(!reliable)
        {
            return Plugin_Continue;
        }

        new String:buffer[25];

        if(GetUserMessageType() == UM_Protobuf)
        {
            PbReadString(bf, "msg_name", buffer, sizeof(buffer));

            if(StrEqual(buffer, "#Cstrike_Name_Change"))
            {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}