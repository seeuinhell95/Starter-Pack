#pragma semicolon  1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] DroneGun Spawn",
	author = "e54385991 | Edited: somebody.",
	description = "DroneGun Spawn",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_spawn_dg",	CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
	RegAdminCmd("sm_spawndg",	CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
	RegAdminCmd("sm_dg",		CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
	RegAdminCmd("sm_dronegun",	CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
	RegAdminCmd("sm_turret",	CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
	RegAdminCmd("sm_sentry",	CMD_SpawnDroneGun,	ADMFLAG_GENERIC);
}

public void OnMapStart()
{
	int precache = PrecacheModel("models/props_survival/dronegun/dronegun.mdl", true);

	if (precache == 0)
	{
		SetFailState("models/props_survival/dronegun/dronegun.mdl not precached !");
	}

	PrecacheModel("models/props_survival/dronegun/dronegun_gib1.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib2.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib3.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib4.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib5.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib6.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib7.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib8.mdl", true);

	PrecacheSound("sound/survival/turret_death_01.wav", true);
	PrecacheSound("sound/survival/turret_idle_01.wav", true);

	PrecacheSound("sound/survival/turret_takesdamage_01.wav", true);
	PrecacheSound("sound/survival/turret_takesdamage_02.wav", true);
	PrecacheSound("sound/survival/turret_takesdamage_03.wav", true);

	PrecacheSound("sound/survival/turret_lostplayer_01.wav", true);
	PrecacheSound("sound/survival/turret_lostplayer_02.wav", true);
	PrecacheSound("sound/survival/turret_lostplayer_03.wav", true);

	PrecacheSound("sound/survival/turret_sawplayer_01.wav", true);
}

public Action CMD_SpawnDroneGun(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	float vec[2][3];
	GetClientEyePosition(client, vec[0]);
	GetClientEyeAngles(client, vec[1]);

	Handle trace = TR_TraceRayFilterEx(vec[0], vec[1], MASK_SOLID, RayType_Infinite, Filter_ExcludePlayers);
	if(!TR_DidHit(trace))
	{
		delete trace;
		return Plugin_Handled;
	}

	TR_GetEndPosition(vec[0], trace);
	delete (trace);

	int dronegun = CreateEntityByName("dronegun");
	if(dronegun == -1 || !IsValidEntity(dronegun))
	{
		return Plugin_Handled;
	}

	vec[0][2] = vec[0][2] + 16.0;
	TeleportEntity(dronegun, vec[0], NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(dronegun);

	return Plugin_Handled;
}

public bool Filter_ExcludePlayers(int entity, int contentsMask, any data)
{
	return !((entity > 0) && (entity <= MaxClients));
}