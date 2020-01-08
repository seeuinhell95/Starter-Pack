#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Trigger Push Fix",
	author = "Mev, George, Blacky, Slidy & Rio | Edited: somebody.",
	description = "Trigger Push Fix",
	version = "1.0",
	url = "http://sourcemod.net"
}

enum
{
	SF_TRIGGER_ALLOW_CLIENTS				= 0x01,
	SF_TRIGGER_ALLOW_NPCS					= 0x02,
	SF_TRIGGER_ALLOW_PUSHABLES				= 0x04,
	SF_TRIGGER_ALLOW_PHYSICS				= 0x08,
	SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS		= 0x10,
	SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES		= 0x20,
	SF_TRIGGER_ALLOW_ALL					= 0x40,
	SF_TRIGGER_ONLY_CLIENTS_OUT_OF_VEHICLES	= 0x200, 
	SF_TRIG_PUSH_ONCE						= 0x80,
	SF_TRIG_PUSH_AFFECT_PLAYER_ON_LADDER	= 0x100,
	SF_TRIG_TOUCH_DEBRIS 					= 0x400,
	SF_TRIGGER_ONLY_NPCS_IN_VEHICLES		= 0x800,
	SF_TRIGGER_PUSH_USE_MASS				= 0x1000,
};

ConVar g_hTriggerPushFixEnable;
bool   g_bTriggerPushFixEnable;
Handle g_hPassesTriggerFilters;

public void OnPluginStart()
{
	Handle hFiltersConf = LoadGameConfigFile("pushfix.games");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hFiltersConf, SDKConf_Virtual, "CBaseTrigger::PassesTriggerFilters");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hPassesTriggerFilters = EndPrepSDKCall();

	delete hFiltersConf;

	g_hTriggerPushFixEnable = CreateConVar("triggerpushfix_enable", "1", "Enables trigger push fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hTriggerPushFixEnable, OnTriggerPushFixChanged);

	HookEvent("round_start", Event_RoundStart);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_push")) != -1)
	{
		SDKHook(entity, SDKHook_Touch, OnTouch);
	}
}

public void OnConfigsExecuted()
{
	g_bTriggerPushFixEnable = GetConVarBool(g_hTriggerPushFixEnable);
}

public void OnTriggerPushFixChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bTriggerPushFixEnable = view_as<bool>(StringToInt(newValue));
}

public void OnMapStart()
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_push")) != -1)
	{
		SDKHook(entity, SDKHook_Touch, OnTouch);
	}
}

public Action OnTouch(int entity, int other)
{
	if(0 < other <= MaxClients && g_bTriggerPushFixEnable == true)
	{
		DoPush(entity, other);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void SinCos( float radians, float &sine, float &cosine)
{
	sine = Sine(radians);
	cosine = Cosine(radians);
}

void DoPush(int entity, int other)
{
	if(0 < other <= MaxClients)
	{
		if(!PassesTriggerFilters(entity, other))
		{
			return;
		}
		
		int spawnflags = GetEntProp(entity, Prop_Data, "m_spawnflags");

		if(GetEntityMoveType(other) == MOVETYPE_LADDER && !(spawnflags & SF_TRIG_PUSH_AFFECT_PLAYER_ON_LADDER))
		{
			return;
		}
		
		float fPushSpeed = GetEntPropFloat(entity, Prop_Data, "m_flSpeed");
		
		float m_vecPushDir[3];
		GetEntPropVector(entity, Prop_Data, "m_vecPushDir", m_vecPushDir);
		float angRotation[3];
		GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", angRotation);

		float sr, sp, sy, cr, cp, cy;
		float matrix[3][4]
		
		SinCos(DegToRad(angRotation[1]), sy, cy );
		SinCos(DegToRad(angRotation[0]), sp, cp );
		SinCos(DegToRad(angRotation[2]), sr, cr );
		
		matrix[0][0] = cp*cy;
		matrix[1][0] = cp*sy;
		matrix[2][0] = -sp;
		
		float crcy = cr*cy;
		float crsy = cr*sy;
		float srcy = sr*cy;
		float srsy = sr*sy;
		
		matrix[0][1] = sp*srcy - crsy;
		matrix[1][1] = sp*srsy + crcy;
		matrix[2][1] = sr*cp;
		
		matrix[0][2] = (sp*crcy + srsy);
		matrix[1][2] = (sp*crsy - srcy);
		matrix[2][2] = cr*cp;
		
		matrix[0][3] = angRotation[0];
		matrix[1][3] = angRotation[1];
		matrix[2][3] = angRotation[2];
		
		float vecAbsDir[3];
		vecAbsDir[0] = m_vecPushDir[0]*matrix[0][0] + m_vecPushDir[1]*matrix[0][1] + m_vecPushDir[2]*matrix[0][2];
		vecAbsDir[1] = m_vecPushDir[0]*matrix[1][0] + m_vecPushDir[1]*matrix[1][1] + m_vecPushDir[2]*matrix[1][2];
		vecAbsDir[2] = m_vecPushDir[0]*matrix[2][0] + m_vecPushDir[1]*matrix[2][1] + m_vecPushDir[2]*matrix[2][2];
		
		ScaleVector(vecAbsDir, fPushSpeed);
		
		if(spawnflags & SF_TRIG_PUSH_ONCE)
		{
			float newVelocity[3];
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", newVelocity);
			AddVectors(newVelocity, vecAbsDir, newVelocity);
			
			TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, newVelocity);
			
			if(vecAbsDir[2] > 0.0)
			{
				SetEntPropEnt(other, Prop_Data, "m_hGroundEntity", -1);
			}
			
			RemoveEdict(entity);
			
			return;
		}
		
		if(GetEntityFlags(other) & FL_BASEVELOCITY)
		{
			float vecBaseVel[3];
			GetEntPropVector(other, Prop_Data, "m_vecBaseVelocity", vecBaseVel);
			AddVectors(vecAbsDir, vecBaseVel, vecAbsDir);
		}
		
		float newVelocity[3];
		GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", newVelocity);
		newVelocity[2] += vecAbsDir[2] * GetTickInterval() * GetEntPropFloat(other, Prop_Data, "m_flLaggedMovementValue"); // frametime = tick_interval * laggedmovementvalue
		
		TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, newVelocity);

		vecAbsDir[2] = 0.0;

		SetEntPropVector(other, Prop_Data, "m_vecBaseVelocity", vecAbsDir);
		SetEntityFlags(other, GetEntityFlags(other) | FL_BASEVELOCITY);
	}
}

stock bool PassesTriggerFilters(int entity, int client)
{
	return SDKCall(g_hPassesTriggerFilters, entity, client);
}