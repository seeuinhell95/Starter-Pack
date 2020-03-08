#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:cvDelay = INVALID_HANDLE;
new Handle:cvType = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "[CSGO] Dissolve",
	author = "LDuke | Edited: somebody.",
	description = "Dissolve",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart() 
{ 
	HookEvent("player_death",PlayerDeath);

	cvDelay = CreateConVar("sm_dissolve_delay","1");
	cvType = CreateConVar("sm_dissolve_type", "3");
}

public OnEventShutdown()
{
	UnhookEvent("player_death",PlayerDeath);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client;
	client = GetClientOfUserId(GetEventInt(event, "userid"));

	new Float:delay = GetConVarFloat(cvDelay);
	if (delay>0.0)
	{
		CreateTimer(delay, Dissolve, client); 
	}
	else
	{
		Dissolve(INVALID_HANDLE, client);
	}
	return Plugin_Continue;
}

public Action:Dissolve(Handle:timer, any:client)
{
	if (!IsValidEntity(client))
	return;

	new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (ragdoll<0)
	{
		PrintToServer("[DISSOLVE] Could not get ragdoll for player!");  
		return;
	}

	new String:dname[32], String:dtype[32];
	Format(dname, sizeof(dname), "dis_%d", client);
	Format(dtype, sizeof(dtype), "%d", GetConVarInt(cvType));

	new ent = CreateEntityByName("env_entity_dissolver");
	if (ent>0)
	{
		DispatchKeyValue(ragdoll, "targetname", dname);
		DispatchKeyValue(ent, "dissolvetype", dtype);
		DispatchKeyValue(ent, "target", dname);
		AcceptEntityInput(ent, "Dissolve");
		AcceptEntityInput(ent, "kill");
	}
}