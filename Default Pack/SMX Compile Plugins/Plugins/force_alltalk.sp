#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Force All Talk",
	author = "ITKiller | Edited: somebody.",
	description = "Force All Talk",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnAllPluginsLoaded()
{
	LOCKED("sm_deadtalk", 2.0);
	LOCKED("sv_deadtalk");
	LOCKED("sv_alltalk");
	LOCKED("sv_full_alltalk");
	LOCKED("sv_spec_hear");
	LOCKED("sv_talk_enemy_dead");
	LOCKED("sv_talk_enemy_living");
}

public void OnPluginEnd()
{
	RESTORE("sm_deadtalk", 2.0);
	RESTORE("sv_deadtalk");
	RESTORE("sv_alltalk");
	RESTORE("sv_full_alltalk");
	RESTORE("sv_spec_hear", 1.0);
	RESTORE("sv_talk_enemy_dead");
	RESTORE("sv_talk_enemy_living");
}

stock void LOCKED(char[] strCvar, float value = 1.0)
{
	ConVar cvar = FindConVar(strCvar);
	if(!cvar) return;
	cvar.SetFloat(value, false, false);
	cvar.SetBounds(ConVarBound_Upper, true, value);
	cvar.SetBounds(ConVarBound_Lower, true, value);
}

stock void RESTORE(char[] strCvar, float max = 1.0, float min = 0.0)
{
	ConVar cvar = FindConVar(strCvar);
	if(!cvar) return;
	cvar.SetBounds(ConVarBound_Upper, true, max);
	cvar.SetBounds(ConVarBound_Lower, true, min);
	cvar.RestoreDefault(false, false);
}