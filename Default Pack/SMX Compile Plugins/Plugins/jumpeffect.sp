#pragma semicolon 1

#include <sdktools>
#include <clientprefs>

#pragma newdecls required

bool IsJumpingEnabled[MAXPLAYERS + 1];
bool IsJumpingsEnabled;

ConVar g_IsJumpingsEnabled;

Handle jumpcookie;

public Plugin myinfo =
{
	name = "[CSGO] Jump Effect",
	author = "iEx | Edited: Cherry & somebody.",
	description = "Jump Effect",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	g_IsJumpingsEnabled = CreateConVar("jumpeffect_enable", "1", "Enables jump effect.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	RegConsoleCmd("sm_jumpeffect", JumpingDisableClient, "toggle jump effects");
	RegConsoleCmd("sm_je", JumpingDisableClient, "toggle jump effects");

	HookEvent("player_jump", jump, EventHookMode_Pre);

	jumpcookie = RegClientCookie("jumpcookie", "jump particle cookie save", CookieAccess_Protected);

	HookConVarChange(g_IsJumpingsEnabled, jumpcvarchanged);

	for(int i=1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
			if(!AreClientCookiesCached(i))
			{
				continue;
			}
			OnClientCookiesCached(i);
		}
	}
}

public void OnMapStart()
{
	AddFileToDownloadsTable("particles/ex_jump.pcf");
	PrecacheGeneric("particles/ex_jump.pcf", true);
}

public void OnConfigsExecuted()
{
	IsJumpingsEnabled = GetConVarBool(g_IsJumpingsEnabled);
}

public void jumpcvarchanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsJumpingsEnabled = StringToInt(newValue) == 1 ? true : false;
}

public void OnClientPutInServer(int client)
{
	if (IsJumpingsEnabled)
	{
		IsJumpingEnabled[client] = false;
	}
}

public void OnClientCookiesCached(int client)
{
	char sValue[8];

	GetClientCookie(client, jumpcookie, sValue, sizeof(sValue));
	IsJumpingEnabled[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public Action jump(Event event, char[] name, bool wtfdoihere)
{
	if (IsJumpingsEnabled)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsJumpingEnabled[client])
		{
			float Pos[3] = 0.0;
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Pos);
			Pos[2] += 5.0;
			int Jumping = CreateEntityByName("info_particle_system", -1);
			DispatchKeyValue(Jumping, "start_active", "1");
			DispatchKeyValue(Jumping, "effect_name", "JumpEX");
			DispatchSpawn(Jumping);
			TeleportEntity(Jumping, Pos, NULL_VECTOR, NULL_VECTOR);
			ActivateEntity(Jumping);
			CreateTimer(0.5, JumpEffectRemove, Jumping, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Handled;
}

public Action JumpEffectRemove( Handle timer, int ent )
{
	if (IsValidEntity(ent))
	{
		AcceptEntityInput(ent, "Stop", -1, -1, 0);
		AcceptEntityInput(ent, "Kill", -1, -1, 0);
	}
}

public Action JumpingDisableClient(int client, int args)
{
	char sValue[8];
	if (IsJumpingEnabled[client])
	{
		PrintToChat(client, " \x10[HR] \x02Ugrás Effekt: \x04Bekapcsolva.");
		IsJumpingEnabled[client] = false;
		IntToString(IsJumpingEnabled[client], sValue, sizeof(sValue));
		SetClientCookie(client, jumpcookie, sValue);
	}
	else
	{
		PrintToChat(client, " \x10[HR] \x02Ugrás Effekt: \x04Kikapcsolva");
		IsJumpingEnabled[client] = true;
		IntToString(IsJumpingEnabled[client], sValue, sizeof(sValue));
		SetClientCookie(client, jumpcookie, sValue);
	}
	return Plugin_Handled;
}