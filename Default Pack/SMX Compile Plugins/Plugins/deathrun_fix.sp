#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#pragma newdecls required

char mapname[128];

public Plugin myinfo =
{
	name		= "[CSGO] Deathrun Fix",
	author		= "Cherry | Edited: somebody.",
	description = "Deathrun Fix",
	version		= "1.0",
	url			= "http://sourcemod.net"
};

public void OnMapStart() 
{
	GetCurrentMap(mapname, sizeof(mapname));
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

public Action OnWeaponCanUse(int client, int weapon) 
{
	if (StrEqual(mapname, "deathrun_family_guy_mgw5", true))
	{
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled; 
	}

	if (StrEqual(mapname, "deathrun_aztecan_csgo_v1", true))
	{
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled; 
	}
	return Plugin_Continue; 
}

public Action OnWeaponDrop(int client, int weapon) 
{
	if (StrEqual(mapname, "deathrun_family_guy_mgw5", true))
	{
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled; 
	}

	if (StrEqual(mapname, "deathrun_aztecan_csgo_v1", true))
	{
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled; 
	}
	return Plugin_Continue; 
}