#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:HideAttackerTs = INVALID_HANDLE;
new Handle:HideAttackerCt = INVALID_HANDLE;

new bool:hide_cts;
new bool:hide_ts;

public Plugin myinfo =
{
	name = "[CSGO] Hide Attacker",
	author = "Franc1sco | Edited: somebody.",
	description = "Hide Attacker",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	HideAttackerTs = CreateConVar("sm_hideattacker_ts", "1", "hide Ts attackers");
	HideAttackerCt = CreateConVar("sm_hideattacker_ct", "0", "hide CTs attackers");

	HookEvent("player_death", event_Death, EventHookMode_Pre);

	HookConVarChange(HideAttackerCt, OnCVarChange);
	HookConVarChange(HideAttackerTs, OnCVarChange);
}

public OnCVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

public OnConfigsExecuted()
{
	GetCVars();
}

public GetCVars()
{
	hide_cts = GetConVarBool(HideAttackerCt);
	hide_ts = GetConVarBool(HideAttackerTs);
}

public Action:event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!dontBroadcast)
	{
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new userid = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userid);

		if (!attacker || attacker == client)
			return Plugin_Continue;

		new iTeam = GetClientTeam(attacker);
		if ((iTeam == 2 && hide_ts) || (iTeam == 3 && hide_cts))  
		{

			decl String:Weapon[32];
			GetEventString(event, "weapon", Weapon, sizeof(Weapon));

			new Handle:newEvent = CreateEvent("player_death", true);
			SetEventInt(newEvent, "userid", userid);
			SetEventInt(newEvent, "attacker", userid);
			SetEventString(newEvent, "weapon", Weapon);
			SetEventBool(newEvent, "headshot", GetEventBool(event, "headshot"));
			SetEventInt(newEvent, "dominated", GetEventInt(event, "dominated"));
			SetEventInt(newEvent, "revenge", GetEventInt(event, "revenge"));

			FireEvent(newEvent, false);

			dontBroadcast = true;
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}