#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Zeus Knock",
	author = "PeEzZ | Edited: somebody.",
	description = "Zeus Knock",
	version = "1.0",
	url = "http://sourcemod.net"
};

new Handle: CVAR_KNOCK = INVALID_HANDLE,
	Handle: CVAR_MAXSPEED = INVALID_HANDLE;

public OnPluginStart()
{
	CVAR_KNOCK = CreateConVar("sm_taser_knock", "-800", "Zeus boost amount. 0 - Disable.");
	CVAR_MAXSPEED = CreateConVar("sm_taser_maxspeed", "1000", "Maximal speed boosted with zeus.", _, true, 200.0);

	HookEvent("weapon_fire", OnWeaponFire);
}

public Action: OnWeaponFire(Handle: event, const String: name[], bool: dontBroadcast)
{
	new String: buffer[32];
	GetEventString(event, "weapon", buffer, sizeof(buffer));
	if(StrEqual(buffer, "weapon_taser"))
	{
		new Float: value = GetConVarFloat(CVAR_KNOCK);
		if(value != 0)
		{
			new client = GetClientOfUserId(GetEventInt(event, "userid"));
			if(IsClientValid(client) && IsClientInGame(client))
			{
				new Float: vec[2][3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vec[0]);
				if( (FloatAbs(vec[0][1]) + FloatAbs(vec[0][2]) / 2) < GetConVarInt(CVAR_MAXSPEED))
				{
					GetClientEyeAngles(client, vec[1]);
					GetAngleVectors(vec[1], vec[1], NULL_VECTOR, NULL_VECTOR);
					NormalizeVector(vec[1], vec[1]);
					ScaleVector(vec[1], value);
					AddVectors(vec[0], vec[1], vec[0]);  
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec[0]);
				}
			}
		}
	}
}

bool: IsClientValid(client)
{
	return ((client > 0) && (client <= MaxClients));
}