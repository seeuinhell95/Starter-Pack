#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#pragma newdecls required

Handle g_hWeapon_ShootPosition = INVALID_HANDLE;
float  g_vecOldWeaponShootPos[MAXPLAYERS + 1][3];

public Plugin myinfo =
{
	name = "[CSGO] Fire Bullets Fix",
	author = "XutaxKamay | Edited: somebody.",
	description = "Fire Bullets Fix",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	Handle gameData = LoadGameConfigFile("dhooks.weapon_shootposition");

	if (gameData == INVALID_HANDLE)
	{
		SetFailState("[FireBullets Fix] No game data present");
	}

	int offset = GameConfGetOffset(gameData, "Weapon_ShootPosition");

	if (offset == -1)
	{
		SetFailState("[FireBullets Fix] failed to find offset");
	}

	LogMessage("Found offset for Weapon_ShootPosition %d", offset);

	g_hWeapon_ShootPosition = DHookCreate(offset, HookType_Entity, ReturnType_Vector, ThisPointer_CBaseEntity);

	if (g_hWeapon_ShootPosition == INVALID_HANDLE)
	{
		SetFailState("[FireBullets Fix] couldn't hook Weapon_ShootPosition");
	}

	CloseHandle(gameData);

	for (int client = 1; client <= MaxClients; client++)
		OnClientPutInServer(client);
}

public void OnClientPutInServer(int client)
{
	if (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		DHookEntity(g_hWeapon_ShootPosition, true, client, _, Weapon_ShootPosition_Post);
	}
}

public Action OnPlayerRunCmd(int client)
{	
	if (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		GetClientEyePosition(client, g_vecOldWeaponShootPos[client]);
	}

	return Plugin_Continue;
}

public MRESReturn Weapon_ShootPosition_Post(int client, Handle hReturn)
{
	DHookSetReturnVector(hReturn, g_vecOldWeaponShootPos[client]);
	return MRES_Supercede;
}