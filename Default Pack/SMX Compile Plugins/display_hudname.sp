#pragma semicolon 1

#include <sdktools>

#pragma newdecls required

ConVar cType;
ConVar cTimeout;
ConVar cTeam;
ConVar cColor[3];
ConVar cPos[2];
ConVar cGIType;

int msgColor[3];

int hudSyncRef = 0;

public Plugin myinfo =
{
	name = "[CSGO] Display HUD Name",
	author = "Mitchell | Edited: somebody.",
	description = "Display HUD Name",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	cType = CreateConVar("sm_advdisplayname_type", "0", "0 = Hint, 1 = HudMsg, 2 = GameInstructor");
	cTimeout = CreateConVar("sm_advdisplayname_timeout", "3.0", "Time the message is displayed");
	cTeam = CreateConVar("sm_advdisplayname_team", "1", "0 = White, 1 = Team Colors, 2 = Team1 is Ally color, Team2 is Enemy color.");
	cColor[0] = CreateConVar("sm_advdisplayname_color_team0", "255,255,255", "Default color");
	cColor[1] = CreateConVar("sm_advdisplayname_color_team1", "195,149,63", "Color of Terrorist team, or color of Enemies. (depending on sm_giname_team)");
	cColor[2] = CreateConVar("sm_advdisplayname_color_team2", "63,116,200", "Color of Counter-Terrorist team, or color of Allies. (depending on sm_giname_team)");
	cGIType = CreateConVar("sm_advdisplayname_gi_type", "0", "0 = Default just on player's screen, 1 = display over looked at player.");
	cPos[0] = CreateConVar("sm_advdisplayname_hm_x", "-1.0", "X position of the HudMsg");
	cPos[1] = CreateConVar("sm_advdisplayname_hm_y", "0.4", "Y position of the HudMsg");

	cType.AddChangeHook(convarChangeCallback);
	cColor[0].AddChangeHook(convarChangeCallback);
	cColor[1].AddChangeHook(convarChangeCallback);
	cColor[2].AddChangeHook(convarChangeCallback);
	cPos[0].AddChangeHook(convarChangeCallback);
	cPos[1].AddChangeHook(convarChangeCallback);

	resetStoredVariables();
	AutoExecConfig(true, "displaye_hudname");

	CreateTimer(0.5, Timer_Display, _, TIMER_REPEAT);
}

public void OnPluginEnd()
{
	if(isValidRef(hudSyncRef))
	{
		AcceptEntityInput(hudSyncRef, "Kill");
	}
}

public void convarChangeCallback(ConVar convar, const char[] oldValue, const char[] newValue)
{
	resetStoredVariables();
}

public void resetStoredVariables()
{
	if(cType.IntValue == 0)
	{
		char colorString[24];
		char colorBuffer[3][5];
		for(int c = 0; c < 3; c++)
		{
			cColor[c].GetString(colorString, sizeof(colorString));
			ExplodeString(colorString, ",", colorBuffer, 3, sizeof(colorBuffer[]), false);

			int clr; 
			clr |= ((StringToInt(colorBuffer[0]) & 0xFF) << 16);
			clr |= ((StringToInt(colorBuffer[1]) & 0xFF) << 8 );
			clr |= ((StringToInt(colorBuffer[2]) & 0xFF) << 0 );
			msgColor[c] = clr;
		}
	}
	if(isValidRef(hudSyncRef))
	{
		AcceptEntityInput(hudSyncRef, "Kill");
	} 
}

public Action Timer_Display(Handle timer)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			int target = getClientAimPlayer(client);
			if(target > 0 && target <= MaxClients 
					&& IsClientInGame(target) && IsPlayerAlive(target))
			{
				showNameMessage(client, target);
			}
		}
	}
	return Plugin_Continue; 
}

public int showNameMessage(int client, int target)
{
	int color = (cTeam.IntValue == 1) ? (GetClientTeam(target) - 1) : (cTeam.IntValue == 2) ? (GetClientTeam(target) != GetClientTeam(client) ? 1 : 2) : 0;
	if(color < 0 || color > 2)
	{
		color = 0;
	}

	switch(cType.IntValue)
	{
		case 1:
		{
			char message[256];
			Format(message, sizeof(message), "%N", target);
			showHudMsg(client, message, color);
		}
		case 2:
		{
			char message[256];
			Format(message, sizeof(message), "%N          ", target);
			showInstructorHint(client, message, cGIType.IntValue == 0 ? 0 : target, color);
		}
		default:
		{
			PrintHintText(client, "<font color='#%06X'>%N", msgColor[color], target);
		}
	}
}
	
public void showInstructorHint(int client, char[] message, int target, int color)
{
	char colorString[24];
	cColor[color].GetString(colorString, sizeof(colorString));

	int userId = GetClientUserId(client);
	char hintName[32];
	Format(hintName, sizeof(hintName), "gi_%d", userId);
	int iFlags = 0;
	Event event = CreateEvent("instructor_server_hint_create", true);
	event.SetString("hint_name", hintName);
	event.SetString("hint_replace_key", hintName);
	event.SetInt("hint_target", target);
	event.SetInt("hint_activator_userid", userId);
	event.SetInt("hint_timeout", cTimeout.IntValue);
	event.SetString("hint_icon_onscreen", "");
	event.SetString("hint_icon_offscreen", "");
	event.SetString("hint_caption", message);
	event.SetString("hint_activator_caption", message);
	event.SetString("hint_color", colorString);
	event.SetFloat("hint_icon_offset", 0.0);
	event.SetFloat("hint_range", 0.0);
	event.SetInt("hint_flags", iFlags);
	event.SetString("hint_binding", "");
	event.SetBool("hint_allow_nodraw_target", true);
	event.SetBool("hint_nooffscreen", true);
	event.SetBool("hint_forcecaption", true);
	event.SetBool("hint_local_player_only", true);
	event.FireToClient(client);
	event.Cancel();
	delete event;
}

public void showHudMsg(int client, char[] message, int color)
{
	char tempString[32];
	if(!isValidRef(hudSyncRef))
	{
		int gameText = CreateEntityByName("game_text");
		DispatchKeyValue(gameText, "channel", "1");
		DispatchKeyValueFloat(gameText, "holdtime", cTimeout.FloatValue);
		DispatchKeyValue(gameText, "color", "255 255 255");
		DispatchKeyValue(gameText, "color2", "0 0 0");
		DispatchKeyValue(gameText, "effect", "0");
		DispatchKeyValueFloat(gameText, "x", cPos[0].FloatValue);
		DispatchKeyValueFloat(gameText, "y", cPos[1].FloatValue);
		DispatchSpawn(gameText);

		hudSyncRef = EntIndexToEntRef(gameText);
	}
	cColor[color].GetString(tempString, sizeof(tempString));
	ReplaceString(tempString, sizeof(tempString), ",", " ", false);
	DispatchKeyValue(hudSyncRef, "color", tempString);
	DispatchKeyValue(hudSyncRef, "message", message);

	SetVariantString("!activator");
	AcceptEntityInput(hudSyncRef, "display", client);
}

stock int getClientAimPlayer(int client)
{
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	Handle traceRay = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterOnlyPlayers, client);
	if(TR_DidHit(traceRay))
	{
		int target = TR_GetEntityIndex(traceRay);
		delete traceRay;
		return target;
	}
	delete traceRay;
	return -1;
}

public bool TraceEntityFilterOnlyPlayers(int entity, int contentsMask, any data)
{
	return entity > 0 && entity <= MaxClients && entity != data;
}

public bool isValidRef(int ref)
{
	int index = EntRefToEntIndex(ref);
	if(index > MaxClients && IsValidEntity(index))
	{
		return true;
	}
	return false;
}