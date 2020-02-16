#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] No Block",
	author = "PeEzZ | Edited: somebody.",
	description = "No Block",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle: CVAR_PLAYER = INVALID_HANDLE,
	Handle: CVAR_GRENADE = INVALID_HANDLE;

public OnPluginStart()
{
	CVAR_PLAYER = CreateConVar("sm_noblock_player", "1", "Enabling player-player no-block.", _, true, 0.0, true, 1.0);
	CVAR_GRENADE = CreateConVar("sm_noblock_grenade", "0", "Enabling player-grenade no-block.", _, true, 0.0, true, 1.0);

	HookEvent("player_spawn", OnPlayerSpawn);
}

public OnEntityCreated(entity, const String: classname[])
{
	if(GetConVarBool(CVAR_GRENADE) && (StrContains(classname, "_projectile", false) != -1))
	{
		SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawnedPost);
	}
}

public Action: OnPlayerSpawn(Handle: event, const String: name[], bool: dontBroadcast)
{
	if(GetConVarBool(CVAR_PLAYER))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(IsClientInGame(client))
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
		}
	}
}

public OnEntitySpawnedPost(entity)
{
	if(IsValidEntity(entity))
	{
		CreateTimer(0.01, Timer_Spawn, EntIndexToEntRef(entity));
	}
}

public Action: Timer_Spawn(Handle: timer, any: reference)
{
	new entity = EntRefToEntIndex(reference);
	if((entity != INVALID_ENT_REFERENCE) && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_CollisionGroup", 2);
	}
}