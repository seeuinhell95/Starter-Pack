#pragma semicolon 1

#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <custom_rounds>

public Plugin myinfo =
{
	name = "[CSGO] Remove Deagle",
	author = "Fr4nch & Grey83 | Edited: somebody.",
	description = "Remove Deagle",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
}

public Action OnWeaponEquip(int client, int weapon)
{
	return (GetFeatureStatus(FeatureType_Native, "CR_IsCustomRound") || !CR_IsCustomRound()) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 1 ? Plugin_Handled : Plugin_Continue;
}