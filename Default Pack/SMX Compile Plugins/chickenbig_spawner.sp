#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Chicken Big Spawner",
	author = "PeEzZ | Edited: somebody.",
	description = "Chicken Big Spawner",
	version = "1.0",
	url = "http://sourcemod.net"
};

#define MODEL_CHICKEN "models/chicken/chicken.mdl"
#define MODEL_CHICKEN_ZOMBIE "models/chicken/chicken_zombie.mdl"
#define SOUND_SPAWN "player/pl_respawn.wav"

public OnPluginStart()
{
	RegAdminCmd("sm_spawnchickenbig", CMD_SpawnChicken, ADMFLAG_GENERIC, "Spawning chicken to the aim position.");
	RegAdminCmd("sm_scb", CMD_SpawnChicken, ADMFLAG_GENERIC, "Spawning chicken to the aim position.");

	LoadTranslations("chickenbig_spawner.phrases");
}

public OnMapStart()
{
	PrecacheModel(MODEL_CHICKEN, true);
	PrecacheModel(MODEL_CHICKEN_ZOMBIE, true);
	PrecacheSound(SOUND_SPAWN, true);
}

public Action: CMD_SpawnChicken(client, args)
{
	new String: arg[16];
	GetCmdArg(1, arg, sizeof(arg));

	if((args == 0) || (StringToInt(arg) == 0))
	{
		SpawnChicken(client, 0);
	}
	else
	{
		SpawnChicken(client, 1);
	}
	return Plugin_Handled;
}

SpawnChicken(client, type)
{
	if(IsClientValid(client) && IsClientInGame(client))
	{
		if(IsPlayerAlive(client))
		{
			new Float: eye_pos[3],
				Float: eye_ang[3];

			GetClientEyePosition(client, eye_pos);
			GetClientEyeAngles(client, eye_ang);

			new Handle: trace = TR_TraceRayFilterEx(eye_pos, eye_ang, MASK_SOLID, RayType_Infinite, Filter_DontHitPlayers);
			if(TR_DidHit(trace))
			{
				if(TR_GetEntityIndex(trace) == 0)
				{
					new chicken = CreateEntityByName("chicken");
					if(IsValidEntity(chicken))
					{
						new Float: end_pos[3];
						TR_GetEndPosition(end_pos, trace);
						end_pos[2] = (end_pos[2] + 10.0);

						new String: skin[16];
						Format(skin, sizeof(skin), "%i", GetRandomInt(0, 1));

						DispatchKeyValue(chicken, "glowenabled", "0");
						DispatchKeyValue(chicken, "glowcolor", "255 255 255");
						DispatchKeyValue(chicken, "rendercolor", "255 255 255");
						DispatchKeyValue(chicken, "modelscale", "2.0");
						DispatchKeyValue(chicken, "skin", skin);
						DispatchSpawn(chicken);

						TeleportEntity(chicken, end_pos, NULL_VECTOR, NULL_VECTOR);

						if(type == 0)
						{
							CreateParticle(chicken, 0);
						}
						else
						{
							CreateParticle(chicken, 1);
							SetEntityModel(chicken, MODEL_CHICKEN_ZOMBIE);
							HookSingleEntityOutput(chicken, "OnBreak", OnBreak);
						}

						EmitSoundToAll(SOUND_SPAWN, chicken);
						ReplyToCommand(client, "%t", "ChickenSpawned");
					}
				}
				else
				{
					ReplyToCommand(client, "%t", "CantSpawnHere");
				}
			}
			else
			{
				ReplyToCommand(client, "%t", "CantSpawnHere");
			}
		}
		else
		{
			ReplyToCommand(client, "%t", "OnlyAlive");
		}
	}
}

CreateParticle(entity, type)
{	
	new particle = CreateEntityByName("info_particle_system");
	if(IsValidEntity(particle))
	{
		new Float: pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);

		if(type == 0)
		{
			DispatchKeyValue(particle, "effect_name", "chicken_gone_feathers");
		}
		else
		{
			DispatchKeyValue(particle, "effect_name", "chicken_gone_feathers_zombie");
		}

		DispatchKeyValue(particle, "angles", "-90 0 0");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "Start");

		CreateTimer(5.0, Timer_KillEntity, EntIndexToEntRef(particle));
	}
}

bool: IsClientValid(client)
{
	return ((client > 0) && (client <= MaxClients));
}

public OnBreak(const String: output[], caller, activator, Float: delay)
{
	CreateParticle(caller, 1);
}

public Action: Timer_KillEntity(Handle: timer, any: reference)
{
	new entity = EntRefToEntIndex(reference);
	if(entity != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

public bool: Filter_DontHitPlayers(entity, contentsMask, any: data)
{
	return !((entity > 0) && (entity <= MaxClients));
}