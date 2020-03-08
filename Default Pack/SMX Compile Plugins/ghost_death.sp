#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

int dead;
int Ghost[MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "[CSGO] Ghost Death",
    author = "ONIONZZZ | Edited: somebody.",
    description = "Ghost Death",
    version = "1.0",
    url = "http://sourcemod.net"
};

public OnPluginStart()
{
    HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
    HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);  	

    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);

    RegConsoleCmd("sm_ghost", Command_Ghost);
    RegConsoleCmd("sm_ghosts", Command_Ghost);
    RegConsoleCmd("sm_redie", Command_Ghost);
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
    SDKHook(client, SDKHook_TraceAttack, OnTakedamage);
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) 
{
    dead = 0;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
    dead = 1;
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(Ghost[client])
    {
        CreateTimer(0.5, fixSolids, client);
        Ghost[client] = 0;
    }
}

public Action fixSolids(Handle timer, any client)
{    
    SetEntProp(client, Prop_Data, "m_CollisionGroup", 1);
    SetEntProp(client, Prop_Data, "m_nSolidType", 0);
    SetEntProp(client, Prop_Send, "m_usSolidFlags", 4);
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    PrintToChat(client, "[SM] Írd be \x06!ghost \x02ha halott vagy és tartsd lenyomva az \x06'E' \x02betűt a repüléshez!");
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    if(GetEntProp(client, Prop_Send, "m_lifeState") == 1)
    {
        MoveType movetype = GetEntityMoveType(client);
        if((buttons & IN_USE))
        {    
            if(movetype != MOVETYPE_NOCLIP)
            {
                SetEntityMoveType(client, MOVETYPE_NOCLIP);
            }
        }else{
            if(movetype != MOVETYPE_WALK)
            {
                SetEntityMoveType(client, MOVETYPE_WALK);
            }
        }            
        buttons &= ~IN_USE;
    }
    return Plugin_Continue;
}

public Action Command_Ghost(client, args)
{
    if(dead)
    {
        if (!IsPlayerAlive(client))
        {
            if(GetClientTeam(client) > 1)
            {
                Ghost[client] = 1;
                CS_RespawnPlayer(client);
                int weaponIndex;
                for (new i = 0; i <= 3; i++)
                {
                    if ((weaponIndex = GetPlayerWeaponSlot(client, i)) != -1)
                    {  
                        RemovePlayerItem(client, weaponIndex);
                        RemoveEdict(weaponIndex);
                    }
                }
                GivePlayerItem(client, "weapon_knife");
                SetEntProp(client, Prop_Send, "m_lifeState", 1);
                PrintToChat(client, "[SM] Jelenleg egy szellem vagy.");
            }
            else
            {
                PrintToChat(client, "[SM] CT vagy T csapatban kell lenni a parancs használatához.");
            }
        }
        else
        {
            PrintToChat(client, "[SM] Ezt a parancsot csak halottak használhatják!");
        }
    }
    else
    {
        PrintToChat(client, "[SM] Kérlek várd meg a következő kört.");
    }
    return Plugin_Handled;
}

public Action:OnWeaponCanUse(client, weapon)
{
    if(GetEntProp(client, Prop_Send, "m_lifeState") == 1)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if(GetEntProp(victim, Prop_Send, "m_lifeState") == 1)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}   

stock bool:IsValidClient(client, bool:nobots = true) 
{  
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client))) 
    {  
      return false;  
    }  
    return IsClientInGame(client);  
}