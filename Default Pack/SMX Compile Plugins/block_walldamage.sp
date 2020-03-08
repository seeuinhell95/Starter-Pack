#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Block Wall Damage",
	author = "Ilusion9 | Edited: somebody.",
	description = "Block Wall Damage",
	version = "1.0",
	url = "http://sourcemod.net"
};

bool g_IsPluginLoadedLate;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_IsPluginLoadedLate = late;
}

public void OnPluginStart()
{
	if (g_IsPluginLoadedLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public Action SDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (attacker < 1 || attacker > MaxClients || inflictor < 1 || inflictor > MaxClients)
	{
		return Plugin_Continue;
	}

	float attackerPos[3];
	GetClientEyePosition(attacker, attackerPos);

	Handle trace = TR_TraceRayFilterEx(attackerPos, damagePosition, MASK_SHOT, RayType_EndPoint, TraceRayFilterPlayers);
	bool blockDamage = TR_DidHit(trace);
	delete trace;

	if (blockDamage)
	{
		damage = 0.0;
		damagetype |= DMG_PREVENT_PHYSICS_FORCE;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public bool TraceRayFilterPlayers(int entity, int contentsMask, any data)
{
	if (entity < 0 || entity > MaxClients)
	{
		return true;
	}

	return false;
}