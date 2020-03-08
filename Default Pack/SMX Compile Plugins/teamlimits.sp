#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required

enum EJoinTeamReason
{
    k_OneTeamChange=0,
    k_TeamsFull=1,
    k_TTeamFull=2,
    k_CTTeamFull=3
}

int g_iTSpawns=-1;
int g_iCTSpawns=-1;
int g_iSelectedTeam[MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "[CSGO] Team Limit Blocker",
    author = "Zephyrus & PinHeaDi | Edited: somebody.",
    description = "Team Limit Blocker",
    version = "1.0",
    url = "http://sourcemod.net"
};

public void OnPluginStart()
{
    HookEvent("jointeam_failed", Event_JoinTeamFailed, EventHookMode_Pre);
    AddCommandListener(Command_JoinTeam, "jointeam");
}

public void OnMapStart()
{
    g_iTSpawns=-1;
    g_iCTSpawns=-1;

    CreateTimer(0.1, Timer_OnMapStart);
}

public void OnClientConnected(int client)
{
    g_iSelectedTeam[client]=0;
}

public Action Timer_OnMapStart(Handle timer, any data)
{
    g_iTSpawns=0;
    g_iCTSpawns=0;

    int ent = -1;
    while((ent = FindEntityByClassname(ent, "info_player_counterterrorist")) != -1) ++g_iCTSpawns;
    ent = -1;
    while((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1) ++g_iTSpawns;

    return Plugin_Stop;
}

public Action Event_JoinTeamFailed(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!client || !IsClientInGame(client))
        return Plugin_Continue;

    EJoinTeamReason m_eReason = view_as<EJoinTeamReason>(event.GetInt("reason"));

    int m_iTs = GetTeamClientCount(CS_TEAM_T);
    int m_iCTs = GetTeamClientCount(CS_TEAM_CT);

    switch(m_eReason)
    {
        case k_OneTeamChange:
        {
            return Plugin_Continue;
        }

        case k_TeamsFull:
        {
            if(m_iCTs == g_iCTSpawns && m_iTs == g_iTSpawns)
                return Plugin_Continue;
        }

        case k_TTeamFull:
        {
            if(m_iTs == g_iTSpawns)
                return Plugin_Continue;
        }

        case k_CTTeamFull:
        {
            if(m_iCTs == g_iCTSpawns)
                return Plugin_Continue;
        }

        default:
        {
            return Plugin_Continue;
        }
    }

    ChangeClientTeam(client, g_iSelectedTeam[client]);

    return Plugin_Handled;
}

public Action Command_JoinTeam(int client, char[] command, int args)
{
    if(!args || !client || !IsClientInGame(client))
        return Plugin_Continue;

    char m_szTeam[8];
    GetCmdArg(1, m_szTeam, sizeof(m_szTeam));
    int m_iTeam = StringToInt(m_szTeam);

    if(CS_TEAM_SPECTATOR<=m_iTeam<=CS_TEAM_CT)
    {
        g_iSelectedTeam[client]=m_iTeam;
        return Plugin_Continue;
    }

    return Plugin_Handled;
}