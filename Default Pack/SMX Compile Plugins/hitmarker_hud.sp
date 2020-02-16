#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] HitMarker - HUD",
	author = "Rachnus | Edited: somebody.",
	description = "HitMarker - HUD",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
}

public Action OnPlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(!IsValidClient(victim))
		return Plugin_Continue;

	if(!IsValidClient(attacker))
		return Plugin_Continue;

	if(weapon < 0 || !IsValidEntity(weapon))
		return Plugin_Continue;

	char className[64];
	GetEntityClassname(weapon, className, sizeof(className));

	if(StrContains(className, "knife", false) != -1 || StrContains(className, "bayonet", false)  != -1)
		return Plugin_Continue;

	if(damage <= 0.0)
		return Plugin_Continue;

	EmitSoundToClient(attacker, "hitmarker/hitmarker.mp3");

	SetHudTextParams(0.495, 0.491, 0.1, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
	ShowHudText(attacker, -1, "X");

	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if(client > 0 && client <= MaxClients)
	{
		if(IsClientInGame(client))
			return true;
	}
	return false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);

	AddFileToDownloadsTable("sound/hitmarker/hitmarker.mp3");
	PrecacheSound("hitmarker/hitmarker.mp3", true);
}