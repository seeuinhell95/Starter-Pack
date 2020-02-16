#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin myinfo =
{
	name		= "[CSGO] Reserve Ammo",
	author		= "Franc1sco | Edited: somebody.",
	description	= "Reserve Ammo",
	version		= "1.0",
	url			= "http://sourcemod.net"
};

new Handle:trie_armas;

public OnPluginStart()
{
	trie_armas = CreateTrie();

	HookEvent("weapon_fire", ClientWeaponReload);

	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
}

public ClientWeaponReload(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,  "userid"));
	Darm(client);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponEquipPost, EventItemPickup2);
}

Darm(client)
{
	if(IsPlayerAlive(client))
	{
		new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if(weapon > 0 && (weapon == GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) || weapon == GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY)))
		{
			new warray;
			decl String:classname[4];
			Format(classname, 4, "%i", GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"));

			if(GetTrieValue(trie_armas, classname, warray))
			{
				if(GetReserveAmmo(weapon) != warray) SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", warray);
			}
		}
	}
}

stock GetReserveAmmo(weapon)
{
	return GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
}

public Action:EventItemPickup2(client, weapon)
{
	if(weapon == GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) || weapon == GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY))
	{
		new warray;
		decl String:classname[4];
		Format(classname, 4, "%i", GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"));

		if(!GetTrieValue(trie_armas, classname, warray))
		{
			warray = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");

			SetTrieValue(trie_armas, classname, warray);
		}
	}
}