#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define NOSCOP 1
#define FLASH 2
#define SMOKE 4

static const char g_sExtendedInfo[][] = {"n", "f", "nf", "s", "ns", "fs", "nfs"};
static const char g_sWeapons[][] = {"deagle", "elite", "fiveseven", "glock", "ak47", "aug", "awp", "famas", "g3sg1", "galilar", "m249", "m4a1", "mac10", "p90", "mp5sd", "ump45", "xm1014", "bizon", "mag7", "negev", "sawedoff", "tec9", "p2000", "hkp2000", "mp7", "mp9", "nova", "p250", "scar20", "sg556", "ssg08", "m4a1_silencer", "m4a1_silencer_off", "usp_silencer", "usp_silencer_off", "cz75a", "revolver"};
static const char g_sSniperWeapons[][] = {"awp", "g3sg1", "scar20", "ssg08"};

float g_DamagePosition[MAXPLAYERS+1][3];

public Plugin myinfo =
{
	name = "[CSGO] Extended Player Death Info",
	author = "Phoenix (˙·٠●Феникс●٠·˙) & Bastaz | Edited: somebody.",
	description = "Extended Player Death Info",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_player_death, EventHookMode_Pre);

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
	{
		OnClientPutInServer(i);
	}
}

public void OnMapStart()
{
	char sPath[] = "materials/panorama/images/icons/equipment/";
	char sBuf[128];
	for(int i = 0; i < sizeof g_sWeapons; i++)
	{
		FormatEx(sBuf, sizeof sBuf, "%s%s_f_bz.svg", sPath, g_sWeapons[i]);
		AddFileToDownloadsTable(sBuf);
		FormatEx(sBuf, sizeof sBuf, "%s%s_s_bz.svg", sPath, g_sWeapons[i]);
		AddFileToDownloadsTable(sBuf);
		FormatEx(sBuf, sizeof sBuf, "%s%s_fs_bz.svg", sPath, g_sWeapons[i]);
		AddFileToDownloadsTable(sBuf);
	}
	for(int i = 0; i < sizeof g_sSniperWeapons; i++)
	{
		FormatEx(sBuf, sizeof sBuf, "%s%s_n_bz.svg", sPath, g_sSniperWeapons[i]);
		AddFileToDownloadsTable(sBuf);
		FormatEx(sBuf, sizeof sBuf, "%s%s_nf_bz.svg", sPath, g_sSniperWeapons[i]);
		AddFileToDownloadsTable(sBuf);
		FormatEx(sBuf, sizeof sBuf, "%s%s_ns_bz.svg", sPath, g_sSniperWeapons[i]);
		AddFileToDownloadsTable(sBuf);
		FormatEx(sBuf, sizeof sBuf, "%s%s_nfs_bz.svg", sPath, g_sSniperWeapons[i]);
		AddFileToDownloadsTable(sBuf);
	}
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
}

public void OnTakeDamageAlivePost(int iClient, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	g_DamagePosition[iClient] = damagePosition;
}

public Action Event_player_death(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid"), attacker = event.GetInt("attacker"), iClient, iAttacker;

	if(userid != attacker && (iClient = GetClientOfUserId(userid)) && (iAttacker = GetClientOfUserId(attacker)))
	{
		char sWeapon[64];
		event.GetString("weapon", sWeapon, sizeof sWeapon);

		if(IsWeaponHasExtendedInfo(sWeapon))
		{
			int ExtendedInfo = 0;

			if(!GetEntProp(iAttacker, Prop_Send, "m_bIsScoped") && IsSniperWeapon(sWeapon))
			{
				ExtendedInfo |= NOSCOP;
			}

			if (GetEntPropFloat(iAttacker, Prop_Send, "m_flFlashDuration") > 0.0)
			{
				ExtendedInfo |= FLASH;
			}

			float from[3];
			GetClientEyePosition(iAttacker, from);
			if(LineGoesThroughSmoke(from, g_DamagePosition[iClient]))
			{
				ExtendedInfo |= SMOKE;
			}

			if(ExtendedInfo)
			{
				Format(sWeapon, sizeof sWeapon, "%s_%s_bz", sWeapon, g_sExtendedInfo[ExtendedInfo-1]);

				event.BroadcastDisabled = true;

				Event event_fake = CreateEvent("player_death", true);

				event_fake.SetInt("userid", userid);
				event_fake.SetInt("attacker", attacker);
				event_fake.SetInt("assister", event.GetInt("assister"));
				event_fake.SetBool("assistedflash", event.GetBool("assistedflash"));
				event_fake.SetString("weapon", sWeapon);
				event.GetString("weapon_itemid", sWeapon, sizeof sWeapon);
				event_fake.SetString("weapon_itemid", sWeapon);
				event.GetString("weapon_fauxitemid", sWeapon, sizeof sWeapon);
				event_fake.SetString("weapon_fauxitemid", sWeapon);
				event.GetString("weapon_originalowner_xuid", sWeapon, sizeof sWeapon);
				event_fake.SetString("weapon_originalowner_xuid", sWeapon);
				event_fake.SetBool("headshot", event.GetBool("headshot"));
				event_fake.SetInt("dominated", event.GetInt("dominated"));
				event_fake.SetInt("revenge", event.GetInt("revenge"));
				event_fake.SetInt("wipe", event.GetInt("wipe"));
				event_fake.SetInt("penetrated", event.GetInt("penetrated"));
				event_fake.SetBool("noreplay", event.GetBool("noreplay"));

				for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
				{
					event_fake.FireToClient(i);
				}

				event_fake.Cancel();
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

bool IsWeaponHasExtendedInfo(const char[] sWeapon)
{
	for(int i = 0; i < sizeof g_sWeapons; i++)
	{
		if(strcmp(g_sWeapons[i], sWeapon) == 0)
		{
			return true;
		}
	}
	return false;
}

bool IsSniperWeapon(const char[] sWeapon)
{
	for(int i = 0; i < sizeof g_sSniperWeapons; i++)
	{
		if(strcmp(g_sSniperWeapons[i], sWeapon) == 0)
		{
			return true;
		}
	}
	return false;
}

stock bool LineGoesThroughSmoke(float from[3], float to[3])
{
	static Address TheBots;
	static Handle CBotManager_IsLineBlockedBySmoke;
	static int OS;

	if(OS == 0)
	{
		Handle hGameConf = LoadGameConfigFile("LineGoesThroughSmoke.games");
		if(!hGameConf)
		{
			SetFailState("Could not read LineGoesThroughSmoke.games.txt");
			return false;
		}

		OS = GameConfGetOffset(hGameConf, "OS");

		TheBots = GameConfGetAddress(hGameConf, "TheBots");
		if(!TheBots)
		{
			CloseHandle(hGameConf);
			SetFailState("TheBots == null");
			return false;
		}

		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		if(OS == 1) PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		if(!(CBotManager_IsLineBlockedBySmoke = EndPrepSDKCall()))
		{
			CloseHandle(hGameConf);
			SetFailState("Failed to get CBotManager::IsLineBlockedBySmoke function");
			return false;
		}

		CloseHandle(hGameConf);
	}

	if(OS == 1) return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to, 1.0);
	return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to);
}