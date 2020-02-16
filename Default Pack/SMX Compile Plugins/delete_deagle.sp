#pragma semicolon 1

#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <custom_rounds>

#pragma tabsize 0

public Plugin myinfo =
{
	name = "[CSGO] Remove Deagle",
	author = "Fr4nch | Edited: somebody.",
	description = "Remove Deagle",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_WeaponEquip, OnWeaponEquip);
}

Action OnWeaponEquip(int iClient, int iWeapon)
{
	return (!CR_IsCustomRound() && GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex") == 1) ? Plugin_Handled:Plugin_Continue;
}