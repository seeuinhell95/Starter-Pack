#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define MAX_WEAPONS 12

public Plugin myinfo =
{
	name = "[CSGO] Give Weapons & Items",
	author = "Kiske & Kento | Edited: somebody.",
	description = "Give Weapons & Items",
	version = "1.0",
	url = "http://sourcemod.net"
};

char g_weapons[MAX_WEAPONS][] =
{
	"item_nvgs",
	"weapon_c4",
	"weapon_healthshot",
	"weapon_tablet",
	"weapon_shield",
	"weapon_knife",
	"weapon_knifegg",
	"weapon_fists",
	"weapon_hammer",
	"weapon_axe",
	"weapon_spanner",
	"weapon_snowball"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_weapon", smWeapon, ADMFLAG_GENERIC, "- <target> <weaponname>");
	RegAdminCmd("sm_weapongive", smWeapon, ADMFLAG_GENERIC, "- <target> <weaponname>");
	RegAdminCmd("sm_giveweapon", smWeapon, ADMFLAG_GENERIC, "- <target> <weaponname>");

	RegAdminCmd("sm_weaponlist", smWeaponList, ADMFLAG_GENERIC, "- list of the weapon names");
}

public Action smWeapon(int client, int args)
{
	if(args < 2)
	{
		ReplyToCommand(client, " \x06[\x02Weapons\x06] \x07Használat: <\x06#UserID|Név\x07> <\x06sm_weapon\x07>");
		return Plugin_Handled;
	}

	char sArg[256];
	char sTempArg[32];
	char sWeaponName[32], sWeaponToGive[32];
	int iL;
	int iNL;

	GetCmdArgString(sArg, sizeof(sArg));
	iL = BreakString(sArg, sTempArg, sizeof(sTempArg));

	if((iNL = BreakString(sArg[iL], sWeaponName, sizeof(sWeaponName))) != -1)
		iL += iNL;

	int iValid = 0;

	for(int i = 0; i < MAX_WEAPONS; ++i)
	{
		if(StrContains(g_weapons[i], sWeaponName) != -1)
		{
			iValid = 1;
			strcopy(sWeaponToGive, sizeof(sWeaponToGive), g_weapons[i]);
			break;
		}
	}
	if(!iValid)
	{
		ReplyToCommand(client, " \x06[\x02Weapons\x06] \x07Ez a fegyvernév (\x06%s\x07) érvénytelen.", sWeaponName);
		return Plugin_Handled;
	}

	char sTargetName[MAX_TARGET_LENGTH];
	int sTargetList[MAXPLAYERS], iTargetCount;
	bool bTN_IsML;

	if((iTargetCount = ProcessTargetString(sTempArg, client, sTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bTN_IsML)) <= 0)
	{
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}

	for (int i = 0; i < iTargetCount; i++)
		GivePlayerItem(sTargetList[i], sWeaponToGive);

	return Plugin_Handled;
}

public Action smWeaponList(int client, int args)
{
	for(int i = 0; i < MAX_WEAPONS; ++i)
		ReplyToCommand(client, "%s", g_weapons[i]);

	ReplyToCommand(client, "");
	ReplyToCommand(client, "* Nem szükséges a weapon_ előtag a <fegyvernévhez>");

	return Plugin_Handled;
}