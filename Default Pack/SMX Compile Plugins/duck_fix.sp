#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Duck Fix",
	author = "Kamay | Edited: somebody.",
	description = "Duck Fix",
	version = "1.0",
	url = "http://sourcemod.net"
};

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Continue;
	}

	new Float:DuckSpeed = GetEntPropFloat(client, Prop_Data, "m_flDuckSpeed");

	if (DuckSpeed < 7.0)
	{
		SetEntPropFloat(client, Prop_Send, "m_flDuckSpeed", 7.0, 0);
	}

	return Plugin_Continue;
}