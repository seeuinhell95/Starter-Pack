#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Zeus Boost",
	author = "PeEzZ | Edited: somebody.",
	description = "Zeus Boost",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle: CVAR_BOOST = INVALID_HANDLE,
	Handle: CVAR_MAXSPEED = INVALID_HANDLE;

public OnPluginStart()
{
	CVAR_BOOST = CreateConVar("sm_zeus_boost", "1.8", "Zeus boost amount. 0 - Disable.", _, true, 0.0, true, 20.0);
	CVAR_MAXSPEED = CreateConVar("sm_zeus_maxspeed", "800", "Maximal speed boosted with zeus.", _, true, 200.0);

	HookEvent("weapon_fire", OnWeaponFire);
}

public Action: OnWeaponFire(Handle: event, const String: name[], bool: dontBroadcast)
{
	new String: buffer[32];
	GetEventString(event, "weapon", buffer, sizeof(buffer));
	if(StrEqual(buffer, "weapon_taser"))
	{
		new Float: value = GetConVarFloat(CVAR_BOOST);
		if(value > 0)
		{
			new client = GetClientOfUserId(GetEventInt(event, "userid"));
			if(IsClientValid(client) && IsClientInGame(client))
			{
				new Float: vel[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);
				if( (FloatAbs(vel[1]) + FloatAbs(vel[2]) / 2) < GetConVarInt(CVAR_MAXSPEED))
				{
					vel[0] = vel[0] * value;
					vel[1] = vel[1] * value;
					if(vel[2] > 0.0)
					{
						vel[2] = vel[2] * value;
					}
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
				}
			}
		}
	}
}

bool: IsClientValid(client)
{
	return ((client > 0) && (client <= MaxClients));
}