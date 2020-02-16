#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Grenade Block Fix",
	author = "Cherry | Edited: somebody.",
	description = "Grenade Block Fix",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnGameFrame()
{
	int client, grenade = -1, grenade2 = -1, grenade3 = -1;

	while ((grenade = FindEntityByClassname(grenade, "decoy_projectile")) != -1)
	{
		client = GetEntPropEnt(grenade, Prop_Send, "m_hThrower");
		int clientTeam = GetClientTeam(client);
		for(int i = 1; i<=MaxClients; ++i)
		{
			if( IsClientInGame(i) && i != client && IsPlayerAlive(i))
			{
				float vecMins[3];
				float vecMaxs[3];
				int clientTeamnoob = GetClientTeam(i);
				GetClientMins(i, vecMins);
				GetClientMaxs(i, vecMaxs);
				float nooborg[3];
				GetClientAbsOrigin(i, nooborg);
				TR_TraceHullFilter(nooborg, nooborg, vecMins, vecMaxs, MASK_ALL, TraceRayHitFilter, grenade);
				bool bDidHit = TR_DidHit();

				if(bDidHit && clientTeamnoob != 1 && clientTeam != 1 && clientTeam != clientTeamnoob && IsClientIndex(i))
				{
					SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BULLET, grenade);
					AcceptEntityInput(grenade, "Kill");
				}
			}
		}
	}

	while ((grenade2 = FindEntityByClassname(grenade2, "flashbang_projectile")) != -1)
	{
		client = GetEntPropEnt(grenade2, Prop_Send, "m_hThrower");
		int clientTeam = GetClientTeam(client);
		for(int i = 1; i<=MaxClients; ++i)
		{
			if( IsClientInGame(i) && i != client && IsPlayerAlive(i))
			{
				float vecMins[3];
				float vecMaxs[3];
				int clientTeamnoob = GetClientTeam(i);
				GetClientMins(i, vecMins);
				GetClientMaxs(i, vecMaxs);
				float nooborg[3];
				GetClientAbsOrigin(i, nooborg);
				TR_TraceHullFilter(nooborg, nooborg, vecMins, vecMaxs, MASK_ALL, TraceRayHitFilter, grenade2);
				bool bDidHit = TR_DidHit();

				if(bDidHit && clientTeamnoob != 1 && clientTeam != 1 && clientTeam != clientTeamnoob && IsClientIndex(i))
				{
					SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BULLET, grenade2);
					AcceptEntityInput(grenade2, "Kill");
				}
			}
		}
	}

	while ((grenade3 = FindEntityByClassname(grenade3, "smokegrenade_projectile")) != -1)
	{
		client = GetEntPropEnt(grenade3, Prop_Send, "m_hThrower");
		int clientTeam = GetClientTeam(client);
		for(int i = 1; i<=MaxClients; ++i)
		{
			if( IsClientInGame(i) && i != client && IsPlayerAlive(i))
			{
				float vecMins[3];
				float vecMaxs[3];
				int clientTeamnoob = GetClientTeam(i);
				GetClientMins(i, vecMins);
				GetClientMaxs(i, vecMaxs);
				float nooborg[3];
				GetClientAbsOrigin(i, nooborg);
				TR_TraceHullFilter(nooborg, nooborg, vecMins, vecMaxs, MASK_ALL, TraceRayHitFilter, grenade3);
				bool bDidHit = TR_DidHit();

				if(bDidHit && clientTeamnoob != 1 && clientTeam != 1 && clientTeam != clientTeamnoob && IsClientIndex(i))
				{
					SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BULLET, grenade3);
					AcceptEntityInput(grenade3, "Kill");
				}
			}
		}
    }
}

public bool TraceRayHitFilter(int entity, int mask, any data)
{
	return entity == data;
}

bool IsClientIndex(int index)
{
	return (index > 0) && (index <= MaxClients);
}