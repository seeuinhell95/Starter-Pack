#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Tesla Effect",
	author = "Cherry | Edited: somebody.",
	description = "Tesla Effect",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	HookEvent("player_death", PlayerDeath);
}

public void PlayerDeath(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker")), iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iAttacker && iClient && iAttacker != iClient && IsClientInGame(iAttacker) && IsClientInGame(iClient))
	{
		float fPos[3];
		GetClientAbsOrigin(iClient, fPos);
		MakeTeslaEffect(fPos);
	}
}

void MakeTeslaEffect(const float fPos[3])
{
	int iEntity = CreateEntityByName("point_tesla");
	DispatchKeyValue(iEntity, "beamcount_min", "5");
	DispatchKeyValue(iEntity, "beamcount_max", "10");
	DispatchKeyValue(iEntity, "lifetime_min", "0.2");
	DispatchKeyValue(iEntity, "lifetime_max", "0.5");
	DispatchKeyValue(iEntity, "m_flRadius", "100.0");
	DispatchKeyValue(iEntity, "m_SoundName", "DoSpark");
	DispatchKeyValue(iEntity, "texture", "sprites/physbeam.vmt");
	DispatchKeyValue(iEntity, "m_Color", "255 255 255");
	DispatchKeyValue(iEntity, "thick_min", "1.0");
	DispatchKeyValue(iEntity, "thick_max", "10.0");
	DispatchKeyValue(iEntity, "interval_min", "0.1");
	DispatchKeyValue(iEntity, "interval_max", "0.2");

	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
	AcceptEntityInput(iEntity, "DoSpark");

	SetVariantString("OnUser1 !self:kill::2.0:-1");
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}