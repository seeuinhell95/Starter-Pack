#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Soccer Ball Spawner",
	author = "Franc1sco | Edited: somebody.",
	description = "Soccer Ball Spawner",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_ball", Bola, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_noball", NoBola, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_noballs", NoBola, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_clearball", NoBola, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_clearballs", NoBola, ADMFLAG_RESERVATION);
}

public Action: Bola(client,args)
{
	decl Float:start[3], Float:angle[3], Float:end[3], Float:normal[3];
	GetClientEyePosition(client, start);
	GetClientEyeAngles(client, angle);
	TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, RayDontHitSelf, client);

	if (TR_DidHit(INVALID_HANDLE))
	{
		TR_GetEndPosition(end, INVALID_HANDLE);
		TR_GetPlaneNormal(INVALID_HANDLE, normal);
		GetVectorAngles(normal, normal);
		normal[0] += 90.0;

		new ent = CreateEntityByName("prop_physics_override");

		if(ent == -1)
		return Plugin_Handled;

		SetEntityModel(ent, "models/forlix/soccer/soccerball.mdl");
		DispatchKeyValue(ent, "StartDisabled", "false");
		DispatchKeyValue(ent, "Solid", "6");
		DispatchKeyValue(ent, "spawnflags", "1026");
		DispatchKeyValue(ent, "classname", "models/forlix/soccer/soccerball.mdl");
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "TurnOn", ent, ent, 0);
		AcceptEntityInput(ent, "EnableCollision");
		TeleportEntity(ent, end, normal, NULL_VECTOR);
		SetEntProp(ent, Prop_Data, "m_CollisionGroup", 5);
		SDKHook(ent, SDKHook_OnTakeDamage, OnTakeBallDamage);
	}
	PrintToChat(client, " \x06[\x02Ball\x06] \x07Sikeresen lehívtál egy \x06egyedi focilabdát\x07.");

	return Plugin_Handled;
}

public bool: RayDontHitSelf(entity, contentsMask, any:data)
{
	return (entity != data);
}

public OnMapStart()
{
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.dx80.vtx");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.dx90.vtx");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.mdl");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.phy");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.sw.vtx");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.vvd");
	AddFileToDownloadsTable("models/forlix/soccer/soccerball.xbox.vtx");
	AddFileToDownloadsTable("materials/models/forlix/soccer/soccerball.vmt");
	AddFileToDownloadsTable("materials/models/forlix/soccer/soccerball.vtf");

	PrecacheModel("models/forlix/soccer/soccerball.mdl");
}

public Action: NoBola(client, args)
{
	new index2 = -1;
	while ((index2 = FindEntityByClassname2(index2, "models/forlix/soccer/soccerball.mdl")) != -1)
	AcceptEntityInput(index2, "Kill");

	PrintToChat(client, " \x06[\x02Ball\x06] \x07Sikeresen törölted az összes focilabdát.");
	return Plugin_Handled;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;

	return true;
}

public Action: OnTakeBallDamage(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker)) return Plugin_Continue;

	if(damage > 45.0)
	{
		Elevar(entity);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Elevar(Bola)
{
	decl Float:normal[3], Float:velocidad[3];
	GetVectorAngles(normal, normal);
	normal[0] += 90.0;
	velocidad[2] = 550.0;
	TeleportEntity(Bola, NULL_VECTOR, normal, velocidad);
}