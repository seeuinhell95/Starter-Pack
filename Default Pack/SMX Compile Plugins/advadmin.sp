#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <geoip>

public Plugin myinfo =
{
	name = "[CSGO] Advanced Admin Commands",
	author = "PeEzZ | Edited: Cherry & somebody.",
	description = "Advanced Admin Commands",
	version = "1.0",
	url = "http://sourcemod.net"
};

#define CMD_PREFIX				"[SM] "

#define MODEL_CHICKEN			"models/chicken/chicken.mdl"
#define MODEL_CHICKEN_ZOMBIE	"models/chicken/chicken_zombie.mdl"
#define MODEL_BALL				"models/props/de_dust/hr_dust/dust_soccerball/dust_soccer_ball001.mdl"

#define SOUND_RESPAWN			"player/pl_respawn.wav"
#define SOUND_CHICKEN			"ambient/creatures/chicken_panic_03.wav"
#define SOUND_BURY				"physics/concrete/boulder_impact_hard4.wav"

new Handle: CVAR_INVALID = INVALID_HANDLE,
	Handle: CVAR_LOG = INVALID_HANDLE;

new Float: SaveVec[MAXPLAYERS + 1][2][3];
new Float: g_DeathLocation[MAXPLAYERS+1][3];

new String: WeaponsList[][] =
{
	"c4", "knife", "knifegg", "taser", "healthshot", "shield", "bumpmine", "breachcharge",
	"decoy", "flashbang", "hegrenade", "molotov", "incgrenade", "smokegrenade", "tagrenade", "snowball",
	"usp_silencer", "glock", "tec9", "p250", "hkp2000", "cz75a", "deagle", "revolver", "fiveseven", "elite",
	"nova", "xm1014", "sawedoff", "mag7", "m249", "negev",
	"mp9", "mp7", "mp5sd", "ump45", "p90", "bizon", "mac10",
	"ak47", "aug", "famas", "sg556", "galilar", "m4a1", "m4a1_silencer",
	"awp", "ssg08", "scar20", "g3sg1"
};

new String: ItemsList[][] =
{
	"defuser", "cutters",
	"kevlar", "assaultsuit", "heavyassaultsuit",
	"nvgs"
};

public OnPluginStart()
{
	CVAR_INVALID		= CreateConVar("sm_advadmin_invalid",		"1",		"Invalid given item will show for all players just for fun, 0 - disable, 1 - enable", _, true, 0.0, true, 1.0);
	CVAR_LOG			= CreateConVar("sm_advadmin_log",			"1",		"Enable logging for plugin, 0 - disable, 1 - enable", _, true, 0.0, true, 1.0);

	RegAdminCmd("sm_extend",		CMD_Extend,			ADMFLAG_GENERIC,		"Extending the map");
	RegAdminCmd("sm_extendmap",		CMD_Extend,			ADMFLAG_GENERIC,		"Extending the map");
	RegAdminCmd("sm_clearmap",		CMD_ClearMap,		ADMFLAG_CONFIG,			"Deleting dropped weapons and items");
	RegAdminCmd("sm_clearchicken",	CMD_ClearChicken,	ADMFLAG_RESERVATION,	"Deleting chickens");
	RegAdminCmd("sm_restartgame",	CMD_RestartGame,	ADMFLAG_GENERIC,		"Restarting the game after the specified seconds");
	RegAdminCmd("sm_rg",			CMD_RestartGame,	ADMFLAG_GENERIC,		"Restarting the game after the specified seconds");
	RegAdminCmd("sm_restartround",	CMD_RestartRound,	ADMFLAG_GENERIC,		"Restarting the round after the specified seconds");
	RegAdminCmd("sm_rr",			CMD_RestartRound,	ADMFLAG_GENERIC,		"Restarting the round after the specified seconds");
	RegAdminCmd("sm_equipments",	CMD_Equipments,		ADMFLAG_GENERIC,		"Showing the valid equipment names in the console");
	RegAdminCmd("sm_playsound",		CMD_PlaySound,		ADMFLAG_CONFIG,			"Playing a sound for the targets, with custom settings");
	RegAdminCmd("sm_play",			CMD_PlaySound,		ADMFLAG_CONFIG,			"Playing a sound for the targets, with custom settings");

	RegAdminCmd("sm_teleport",		CMD_Teleport,		ADMFLAG_GENERIC,		"Teleporting the target to something");
	RegAdminCmd("sm_tpp",			CMD_Teleport,		ADMFLAG_GENERIC,		"Teleporting the target to something");
	RegAdminCmd("sm_saveloc",		CMD_SaveVec,		ADMFLAG_GENERIC,		"Saving the current position for the teleport");
	RegAdminCmd("sm_savevec",		CMD_SaveVec,		ADMFLAG_GENERIC,		"Saving the current position for the teleport");

	RegAdminCmd("sm_team",			CMD_Team,			ADMFLAG_GENERIC,		"Set the targets team");
	RegAdminCmd("sm_swap",			CMD_Swap,			ADMFLAG_GENERIC,		"Swap the targets team");
	RegAdminCmd("sm_spec",			CMD_Spec,			ADMFLAG_GENERIC,		"Set the targets team to spectator");
	RegAdminCmd("sm_scramble",		CMD_Scramble,		ADMFLAG_CHEATS,			"Scramble the teams by scores");
	RegAdminCmd("sm_balance",		CMD_Scramble,		ADMFLAG_CHEATS,			"Scramble the teams by scores");

	RegAdminCmd("sm_give",			CMD_Give,			ADMFLAG_GENERIC,		"Give something for the targets");
	RegAdminCmd("sm_equip",			CMD_Equip,			ADMFLAG_GENERIC,		"Equipping something for the targets");
	RegAdminCmd("sm_melee",			CMD_Equip,			ADMFLAG_GENERIC,		"Equipping something for the targets");
	RegAdminCmd("sm_disarm",		CMD_Disarm,			ADMFLAG_GENERIC,		"Disarming the targets");

	RegAdminCmd("sm_respawn",		CMD_Respawn,		ADMFLAG_GENERIC,		"Respawning the targets");
	RegAdminCmd("sm_revive",		CMD_Respawn,		ADMFLAG_GENERIC,		"Respawning the targets");
	RegAdminCmd("sm_hrespawn",		CMD_RespawnLast,	ADMFLAG_GENERIC,		"Respawning the targets last position");
	RegAdminCmd("sm_hrevive",		CMD_RespawnLast,	ADMFLAG_GENERIC,		"Respawning the targets last position");
	RegAdminCmd("sm_bury",			CMD_Bury,			ADMFLAG_GENERIC,		"Bury a player");

	RegAdminCmd("sm_helmet",		CMD_Helmet,			ADMFLAG_GENERIC,		"Set helmet for the targets");
	RegAdminCmd("sm_armor",			CMD_Armor,			ADMFLAG_GENERIC,		"Set the armor for the targets");
	RegAdminCmd("sm_armour",		CMD_Armor,			ADMFLAG_GENERIC,		"Set the armor for the targets");

	RegAdminCmd("sm_hp",			CMD_Health,			ADMFLAG_GENERIC,		"Set the health for the targets");
	RegAdminCmd("sm_health",		CMD_Health,			ADMFLAG_GENERIC,		"Set the health for the targets");
	RegAdminCmd("sm_god",			CMD_God,			ADMFLAG_GENERIC,		"Set godmode for the targets");
	RegAdminCmd("sm_speed",			CMD_Speed,			ADMFLAG_GENERIC,		"Set the speed multipiler of the targets");

	RegAdminCmd("sm_setstats",		CMD_SetStats,		ADMFLAG_GENERIC,		"Set the stats for the targets");
	RegAdminCmd("sm_setstat",		CMD_SetStats,		ADMFLAG_GENERIC,		"Set the stats for the targets");
	RegAdminCmd("sm_ss",			CMD_SetStats,		ADMFLAG_GENERIC,		"Set the stats for the targets");
	RegAdminCmd("sm_cash",			CMD_Cash,			ADMFLAG_GENERIC,		"Set the cash for the targets");
	RegAdminCmd("sm_teamscores",	CMD_TeamScores,		ADMFLAG_GENERIC,		"Set the teams scores");
	RegAdminCmd("sm_teamscore",		CMD_TeamScores,		ADMFLAG_GENERIC,		"Set the teams scores");

	RegAdminCmd("sm_spawnchicken",	CMD_SpawnChicken,	ADMFLAG_RESERVATION,	"Spawn one chicken on your aim position");
	RegAdminCmd("sm_sc",			CMD_SpawnChicken,	ADMFLAG_RESERVATION,	"Spawn one chicken on your aim position");
	RegAdminCmd("sm_spawnball",		CMD_SpawnBall,		ADMFLAG_RESERVATION,	"Spawn one ball on your aim position");
	RegAdminCmd("sm_sb",			CMD_SpawnBall,		ADMFLAG_RESERVATION,	"Spawn one ball on your aim position");

	HookEvent("player_death", Respawn_PlayerDeath);

	LoadTranslations("common.phrases");
	LoadTranslations("advadmin.phrases");
}

public OnMapStart()
{
	if(!StrEqual(SOUND_RESPAWN, "", false))
	{
		PrecacheSound(SOUND_RESPAWN, true);
	}
	if(!StrEqual(SOUND_BURY, "", false))
	{
		PrecacheSound(SOUND_BURY, true);
	}
	if(!StrEqual(SOUND_CHICKEN, "", false))
	{
		PrecacheSound(SOUND_CHICKEN, true);
	}

	PrecacheModel(MODEL_CHICKEN, true);
	PrecacheModel(MODEL_CHICKEN_ZOMBIE, true);
	PrecacheModel(MODEL_BALL, true);
}

public Respawn_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	GetClientAbsOrigin(victim, g_DeathLocation[victim]);
	g_DeathLocation[victim][2] -= 45.0;
}

public Action: CMD_Extend(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "%t", "CMD_Extend_Usage");
		return Plugin_Handled;
	}
	
	new String: buffer[6];
	GetCmdArg(1, buffer, sizeof(buffer));
	
	new value = StringToInt(buffer);
	ExtendMapTimeLimit(value * 60);
	
	ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Extend", value);
	LogActionEx(client, "%t", "CMD_Extend", value);
	return Plugin_Handled;
}

public Action: CMD_ClearMap(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	new String: buffer[64];
	for(new entity = MaxClients; entity < GetMaxEntities(); entity++)
	{
		if(IsValidEntity(entity))
		{
			GetEntityClassname(entity, buffer, sizeof(buffer));
			if(((StrContains(buffer, "weapon_", false) != -1) && (GetEntProp(entity, Prop_Data, "m_iState") == 0) && (GetEntProp(entity, Prop_Data, "m_spawnflags") != 1)) || StrEqual(buffer, "item_defuser", false) )
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
	}
	
	ShowActivity2(client, CMD_PREFIX, "%t", "CMD_ClearMap");
	LogActionEx(client, "%t", "CMD_ClearMap");
	return Plugin_Handled;
}

public Action: CMD_ClearChicken(client, args)
{
    if(!IsClientValid(client) || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }
   
    new String: classname[65];
    for(new entity = MaxClients; entity < GetMaxEntities(); entity++)
    {
        if(IsValidEntity(entity))
        {
            GetEntityClassname(entity, classname, sizeof(classname));
            if( (StrContains(classname, "chicken", false) != -1) )
            {
                AcceptEntityInput(entity, "Kill");
            }
        }
    }
   
    ShowActivity2(client, CMD_PREFIX, "%t", "CMD_ClearChicken");
    LogActionEx(client, "%t", "CMD_ClearChicken");
    return Plugin_Handled;
}

public Action: CMD_RestartGame(client, args)
{
	new Float: time;
	if(args)
	{
		new String: buffer[2];
		GetCmdArg(1, buffer, sizeof(buffer));
		time = StringToFloat(buffer);
	}
	
	if(time > 0.0)
	{
		ServerCommand("mp_restartgame %i", time);
	}
	else
	{
		CS_TerminateRound(0.0, CSRoundEnd_GameStart);
	}
	
	ShowActivity2(client, CMD_PREFIX, "%t", "CMD_RestartGame");
	LogActionEx(client, "%t", "CMD_RestartGame");
	return Plugin_Handled;
}

public Action: CMD_RestartRound(client, args)
{
	new Float: time;
	if(args)
	{
		new String: buffer[2];
		GetCmdArg(1, buffer, sizeof(buffer));
		time = StringToFloat(buffer);
	}
	CS_TerminateRound(time, CSRoundEnd_Draw);
	
	ShowActivity2(client, CMD_PREFIX, "%t", "CMD_RestartRound");
	LogActionEx(client, "%t", "CMD_RestartRound");
	return Plugin_Handled;
}

public Action: CMD_Equipments(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	new String: buffer[512];
	for(new i = 0; i < sizeof(WeaponsList); i++)
	{
		if(StrEqual(buffer, "", false))
		{
			Format(buffer, sizeof(buffer), "%s", WeaponsList[i]);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s, %s", buffer, WeaponsList[i]);
		}
	}
	PrintToConsole(client, "%t", "CMD_Equipments_Weapons", buffer);
	
	buffer = "";
	
	for(new i = 0; i < sizeof(ItemsList); i++)
	{
		if(StrEqual(buffer, "", false))
		{
			Format(buffer, sizeof(buffer), "%s", ItemsList[i]);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s, %s", buffer, ItemsList[i]);
		}
	}
	PrintToConsole(client, "%t", "CMD_Equipments_Items", buffer);
	ReplyToCommand(client, "%t", "CMD_Equipments_Printed");
	return Plugin_Handled;
}

public Action: CMD_PlaySound(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "%t", "CMD_PlaySound_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[512],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));	
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	new value[3];
	GetCmdArg(3, buffer, sizeof(buffer));
	value[0] = StringToInt(buffer);
	if((value[0] < 50) || (value[0] > 250))
	{
		value[0] = 100;
	}
	
	GetCmdArg(4, buffer, sizeof(buffer));
	value[1] = StringToInt(buffer);
	if((value[1] < 1) || (value[1] > 100))
	{
		value[1] = 100;
	}
	
	GetCmdArg(5, buffer, sizeof(buffer));
	value[2] = StringToInt(buffer);
	if((value[2] < 1) || (value[2] > 10))
	{
		value[2] = 1;
	}
	
	new String: file[512];
	GetCmdArg(2, buffer, sizeof(buffer));
	Format(file, sizeof(file), "sound/%s", buffer);
	if(!FileExists(file))
	{
		ReplyToCommand(client, "[SM] File is not exists: %s", buffer);
		return Plugin_Handled;
	}
	
	PrecacheSound(buffer, true);
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			for(new n = 0; n < value[2]; n++)
			{
				EmitSoundToClient(target_list[i], buffer, _, _, _, _, value[1] * 0.01, value[0]);
			}
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_PlaySound", target_name, buffer, value[0], value[1], value[2]);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_PlaySound", "_s", target_name, buffer, value[0], value[1], value[2]);
	}
	return Plugin_Handled;
}

public Action: CMD_Teleport(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Teleport_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
		
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	new Float: vec[2][3];
	GetCmdArg(2, buffer, sizeof(buffer));
	if(!StrEqual(buffer, "", false))
	{
		if(StrEqual(buffer, "@blink", false))
		{
			GetClientEyePosition(client, vec[0]);
			GetClientEyeAngles(client, vec[1]);
			
			new Handle: trace = TR_TraceRayFilterEx(vec[0], vec[1], MASK_SOLID, RayType_Infinite, Filter_ExcludePlayers);
			if(!TR_DidHit(trace))
			{
				return Plugin_Handled;
			}
			TR_GetEndPosition(vec[0], trace);
			CloseHandle(trace);
			
			vec[1][0] = 0.0;
			
			if(tn_is_ml)
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Blink", target_name);
				LogActionEx(client, "%t", "CMD_Teleport_To_Blink", target_name);
			}
			else
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Blink", "_s", target_name);
				LogActionEx(client, "%t", "CMD_Teleport_To_Blink", "_s", target_name);
			}
		}
		else
		{
			new target = FindTarget(client, buffer, false, false);
			if(!IsClientValid(target) || !IsClientInGame(target))
			{
				return Plugin_Handled;
			}
			
			GetClientAbsOrigin(target, vec[0]);
			GetClientEyeAngles(target, vec[1]);
			
			if(tn_is_ml)
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Player", target_name, target);
				LogActionEx(client, "%t", "CMD_Teleport_To_Player", target_name, target);
			}
			else
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Player", "_s", target_name, target);
				LogActionEx(client, "%t", "CMD_Teleport_To_Player", "_s", target_name, target);
			}
		}
	}
	else
	{
		if((SaveVec[client][0][0] + SaveVec[client][0][1] + SaveVec[client][0][2]) == 0)
		{
			ReplyToCommand(client, "%t", "CMD_Teleport_NoSaved");
			return Plugin_Handled;
		}
		else
		{
			vec[0] = SaveVec[client][0];
			vec[1] = SaveVec[client][1];
			
			if(tn_is_ml)
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Saved", target_name);
				LogActionEx(client, "%t", "CMD_Teleport_To_Saved", target_name);
			}
			else
			{
				ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Teleport_To_Saved", "_s", target_name);
				LogActionEx(client, "%t", "CMD_Teleport_To_Saved", "_s", target_name);
			}
		}
	}
	
	vec[0][2] = vec[0][2] + 2.0;
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			TeleportEntity(target_list[i], vec[0], vec[1], Float: {0.0, 0.0, 0.0});
		}
	}
	
	if(!StrEqual(SOUND_RESPAWN, "", false))
	{
		EmitSoundToAll(SOUND_RESPAWN, target_list[target_count - 1]);
	}
	return Plugin_Handled;
}

public Action: CMD_SaveVec(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	GetClientAbsOrigin(client, SaveVec[client][0]);
	GetClientEyeAngles(client, SaveVec[client][1]);
	ReplyToCommand(client, "%t", "CMD_SaveVec");
	return Plugin_Handled;
}

public Action: CMD_Team(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 2) && (args != 3))
	{
		ReplyToCommand(client, "%t", "CMD_Team_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	new team;
	GetCmdArg(2, buffer, sizeof(buffer));
	if(StrEqual(buffer, "spectator", false) || StrEqual(buffer, "spec", false) || StrEqual(buffer, "1", false))
	{
		team = CS_TEAM_SPECTATOR;
		if(tn_is_ml)
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_Spec", target_name);
			LogActionEx(client, "%t", "CMD_Team_Spec", target_name);
		}
		else
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_Spec", "_s", target_name);
			LogActionEx(client, "%t", "CMD_Team_Spec", "_s", target_name);
		}
	}
	else if(StrEqual(buffer, "t", false) || StrEqual(buffer, "2", false))
	{
		team = CS_TEAM_T;
		if(tn_is_ml)
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_T", target_name);
			LogActionEx(client, "%t", "CMD_Team_T", target_name);
		}
		else
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_T", "_s", target_name);
			LogActionEx(client, "%t", "CMD_Team_T", "_s", target_name);
		}
	}
	else if(StrEqual(buffer, "ct", false) || StrEqual(buffer, "3", false))
	{
		team = CS_TEAM_CT;
		if(tn_is_ml)
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_CT", target_name);
			LogActionEx(client, "%t", "CMD_Team_CT", target_name);
		}
		else
		{
			ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_CT", "_s", target_name);
			LogActionEx(client, "%t", "CMD_Team_CT", "_s", target_name);
		}
	}
	else
	{
		ReplyToCommand(client, "%t", "CMD_Invalid_Team");
		return Plugin_Handled;
	}
	
	GetCmdArg(3, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(!value)
			{
				if(team != 1)
				{
					CS_SwitchTeam(target_list[i], team);
					if(IsPlayerAlive(target_list[i]))
					{
						//CS_RespawnPlayer(target_list[i]);
					}
				}
				else
				{
					ChangeClientTeam(target_list[i], team);
				}
			}
			else
			{
				SetEntProp(target_list[i], Prop_Data, "m_iPendingTeamNum", team);
			}
		}
	}
	return Plugin_Handled;
}

public Action: CMD_Swap(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Swap_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if(StrEqual(buffer, "@spec", false) || StrEqual(buffer, "@spectator", false))
	{
		ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
		return Plugin_Handled;
	}
	
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer),
		team;
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			team = GetClientTeam(target_list[i]);
			if(team >= 2)
			{
				if(!value)
				{
					if(team == CS_TEAM_T)
					{
						CS_SwitchTeam(target_list[i], CS_TEAM_CT);
					}
					else
					{
						CS_SwitchTeam(target_list[i], CS_TEAM_T);
					}
					if(IsPlayerAlive(target_list[i]))
					{
						//CS_RespawnPlayer(target_list[i]);
					}
				}
				else
				{
					if(team == CS_TEAM_T)
					{
						SetEntProp(target_list[i], Prop_Data, "m_iPendingTeamNum", CS_TEAM_CT);
					}
					else
					{
						SetEntProp(target_list[i], Prop_Data, "m_iPendingTeamNum", CS_TEAM_T);
					}
				}
			}
			else if(!tn_is_ml)
			{
				ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
				return Plugin_Handled;
			}
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Swap", target_name);
		LogActionEx(client, "%t", "CMD_Swap", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Swap", "_s", target_name);
		LogActionEx(client, "%t", "CMD_Swap", "_s", target_name);
	}
	return Plugin_Handled;
}

public Action: CMD_Spec(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Team_Spec_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(!value)
			{
				ChangeClientTeam(target_list[i], CS_TEAM_SPECTATOR);
			}
			else
			{
				SetEntProp(target_list[i], Prop_Data, "m_iPendingTeamNum", CS_TEAM_SPECTATOR);
			}
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_Spec", target_name);
		LogActionEx(client, "%t", "CMD_Team_Spec", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Team_Spec", "_s", target_name);
		LogActionEx(client, "%t", "CMD_Team_Spec", "_s", target_name);
	}
	return Plugin_Handled;
}

public Action: CMD_Scramble(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	ServerCommand("mp_scrambleteams");
	
	ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Scramble");
	LogActionEx(client, "%t", "CMD_Scramble");
	return Plugin_Handled;
}

public Action: CMD_Give(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Give_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[128],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	if(StrEqual(buffer, "", false))
	{
		Format(buffer, sizeof(buffer), "knife");
	}
	
	new type = ItemType(buffer);
	if(!type)
	{
		if(GetConVarBool(CVAR_INVALID))
		{
			if(tn_is_ml)
			{
				PrintToChatAll("%s%t", CMD_PREFIX, "CMD_Give", target_name, buffer);
			}
			else
			{
				PrintToChatAll("%s%t", CMD_PREFIX, "CMD_Give", "_s", target_name, buffer);
			}
		}
		ReplyToCommand(client, "%t", "CMD_Invalid_Weapon");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		if(StrEqual(buffer, "knife", false) && !GetConVarBool(FindConVar("mp_drop_knife_enable")))
		{
			new knife = -1;
			while((knife = GetPlayerWeaponSlot(target_list[i], 2)) != -1)
			{
				if(IsValidEntity(knife))
				{
					RemovePlayerItem(target_list[i], knife);
				}
			}
		}
		GivePlayerWeapon(target_list[i], buffer, type);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Give", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Give", target_name, buffer);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Give", "_s", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Give", "_s", target_name, buffer);
	}
	return Plugin_Handled;
}

public Action: CMD_Equip(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Equip_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[128],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
		
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	if(StrEqual(buffer, "", false))
	{
		Format(buffer, sizeof(buffer), "knife");
	}
	
	new type = ItemType(buffer);
	if(!type)
	{
		if(GetConVarBool(CVAR_INVALID))
		{
			if(tn_is_ml)
			{
				PrintToChatAll("%s%t", CMD_PREFIX, "CMD_Equip", target_name, buffer);
			}
			else
			{
				PrintToChatAll("%s%t", CMD_PREFIX, "CMD_Equip", "_s", target_name, buffer);
			}
		}
		ReplyToCommand(client, "%t", "CMD_Invalid_Weapon");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		DisarmPlayer(target_list[i]);
		GivePlayerWeapon(target_list[i], buffer, type);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Equip", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Equip", target_name, buffer);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Equip", "_s", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Equip", "_s", target_name, buffer);
	}
	return Plugin_Handled;
}

public Action: CMD_Disarm(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "%t", "CMD_Disarm_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		DisarmPlayer(target_list[i]);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Disarm", target_name);
		LogActionEx(client, "%t", "CMD_Disarm", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Disarm", "_s", target_name);
		LogActionEx(client, "%t", "CMD_Disarm", "_s", target_name);
	}
	return Plugin_Handled;
}

public Action: CMD_Respawn(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "%t", "CMD_Respawn_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if(StrEqual(buffer, "@spec", false) || StrEqual(buffer, "@spectator", false))
	{
		ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
		return Plugin_Handled;
	}
	
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(GetClientTeam(target_list[i]) >= 2)
			{
				CS_RespawnPlayer(target_list[i]);
				if(!StrEqual(SOUND_RESPAWN, "", false))
				{
					EmitSoundToAll(SOUND_RESPAWN, target_list[i]);
				}
			}
			else if(!tn_is_ml)
			{
				ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
				return Plugin_Handled;
			}
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Respawn", target_name);
		LogActionEx(client, "%t", "CMD_Respawn", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Respawn", "_s", target_name);
		LogActionEx(client, "%t", "CMD_Respawn", "_s", target_name);
	}
	return Plugin_Handled;
}

public Action: CMD_RespawnLast(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "%t", "CMD_HRespawn_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if(StrEqual(buffer, "@spec", false) || StrEqual(buffer, "@spectator", false))
	{
		ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
		return Plugin_Handled;
	}
	
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(GetClientTeam(target_list[i]) >= 2)
			{
				PerformRespawn(client, target_list[i]);
				if(!StrEqual(SOUND_RESPAWN, "", false))
				{
					EmitSoundToAll(SOUND_RESPAWN, target_list[i]);
				}
			}
			else if(!tn_is_ml)
			{
				ReplyToCommand(client, "%t", "CMD_OnlyInTeam");
				return Plugin_Handled;
			}
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_HRespawn", target_name);
		LogActionEx(client, "%t", "CMD_HRespawn", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_HRespawn", "_s", target_name);
		LogActionEx(client, "%t", "CMD_HRespawn", "_s", target_name);
	}
	return Plugin_Handled;
}

PerformRespawn(client, target)
{
	CS_RespawnPlayer(target);
	if (g_DeathLocation[target][0] == 0.0 && g_DeathLocation[target][1] == 0.0 && g_DeathLocation[target][2] == 0.0)
	{
		ReplyToCommand(client, "Respawn Data Unavailable", target);
	}
	else
	{
		TeleportEntity(target, g_DeathLocation[target], NULL_VECTOR, NULL_VECTOR);
	}
}

public Action: CMD_Bury(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%t", "CMD_Bury_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	new Float: pos[3];
	for(new i = 0; i < target_count; i++)
	{
		GetClientAbsOrigin(target_list[i], pos);
		if(value == 0)
		{
			pos[2] -= 36.5;
		}
		else
		{
			pos[2] += 36.5;
		}
		TeleportEntity(target_list[i], pos, NULL_VECTOR, Float: {0.0, 0.0, 0.0});
		if(!StrEqual(SOUND_BURY, "", false))
		{
			EmitSoundToAll(SOUND_BURY, target_list[i]);
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Bury", target_name);
		LogActionEx(client, "%t", "CMD_Bury", target_name);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Bury", "_s", target_name);
		LogActionEx(client, "%t", "CMD_Bury", "_s", target_name);
	}
	return Plugin_Handled;
}

public Action: CMD_Speed(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_Speed_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new Float: value = StringToFloat(buffer);
	if((value < 0.0) || (value > 500.0))
	{
		ReplyToCommand(client, "%t", "CMD_Speed_Usage");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		SetEntPropFloat(target_list[i], Prop_Data, "m_flLaggedMovementValue", value);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Speed", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Speed", target_name, buffer);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Speed", "_s", target_name, buffer);
		LogActionEx(client, "%t", "CMD_Speed", "_s", target_name, buffer);
	}
	return Plugin_Handled;
}

public Action: CMD_God(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_God_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	if((value != 0) && (value != 1))
	{
		ReplyToCommand(client, "%t", "CMD_God_Usage");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		SetEntProp(target_list[i], Prop_Data, "m_takedamage", value ? 0 : 2);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_God", target_name, value);
		LogActionEx(client, "%t", "CMD_God", target_name, value);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_God", "_s", target_name, value);
		LogActionEx(client, "%t", "CMD_God", "_s", target_name, value);
	}
	return Plugin_Handled;
}

public Action: CMD_Helmet(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_Helmet_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	if((value != 0) && (value != 1))
	{
		ReplyToCommand(client, "%t", "CMD_Helmet_Usage");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < target_count; i++)
	{
		SetEntProp(target_list[i], Prop_Send, "m_bHasHelmet", value);
	}

	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Helmet", target_name, value);
		LogActionEx(client, "%t", "CMD_Helmet", target_name, value);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Helmet", "_s", target_name, value);
		LogActionEx(client, "%t", "CMD_Helmet", "_s", target_name, value);
	}
	return Plugin_Handled;
}

public Action: CMD_Health(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_Health_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	for(new i = 0; i < target_count; i++)
	{
		if((buffer[0] == '+') || (buffer[0] == '-'))
		{
			value = value + GetEntProp(target_list[i], Prop_Data, "m_iHealth");
		}
		SetEntProp(target_list[i], Prop_Data, "m_iHealth", value);
		//SetEntProp(target_list[i], Prop_Data, "m_iMaxHealth", value);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Health", target_name, value);
		LogActionEx(client, "%t", "CMD_Health", target_name, value);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Health", "_s", target_name, value);
		LogActionEx(client, "%t", "CMD_Health", "_s", target_name, value);
	}
	return Plugin_Handled;
}

public Action: CMD_Armor(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_Armor_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	for(new i = 0; i < target_count; i++)
	{
		if((buffer[0] == '+') || (buffer[0] == '-'))
		{
			value = value + GetEntProp(target_list[i], Prop_Send, "m_ArmorValue");
		}
		SetEntProp(target_list[i], Prop_Send, "m_ArmorValue", value);
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Armor", target_name, value);
		LogActionEx(client, "%t", "CMD_Armor", target_name, value);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Armor", "_s", target_name, value);
		LogActionEx(client, "%t", "CMD_Armor", "_s", target_name, value);
	}
	return Plugin_Handled;
}

public Action: CMD_Cash(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_Cash_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if((buffer[0] == '+') || (buffer[0] == '-'))
			{
				value = value + GetEntProp(target_list[i], Prop_Send, "m_iAccount");
			}
			SetEntProp(target_list[i], Prop_Send, "m_iAccount", value);
		}
	}
	
	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Cash", target_name, value);
		LogActionEx(client, "%t", "CMD_Cash", target_name, value);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_Cash", "_s", target_name, value);
		LogActionEx(client, "%t", "CMD_Cash", "_s", target_name, value);
	}
	return Plugin_Handled;
}

public Action: CMD_SetStats(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 3)
	{
		ReplyToCommand(client, "%t", "CMD_SetStats_Usage");
		return Plugin_Handled;
	}
	
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[2][64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	
	GetCmdArg(1, buffer[0], sizeof(buffer[]));
	if((target_count = ProcessTargetString(buffer[0], client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer[0], sizeof(buffer[]));
	GetCmdArg(3, buffer[1], sizeof(buffer[]));
	new value = StringToInt(buffer[1]);
	
	for(new i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(StrEqual(buffer[0], "kills"))
			{
				if((buffer[1][0] == '+') || (buffer[1][0] == '-'))
				{
					value = value + GetEntProp(target_list[i], Prop_Data, "m_iFrags");
				}
				SetEntProp(target_list[i], Prop_Data, "m_iFrags", value);
				Format(buffer[1], sizeof(buffer[]), "%i", value);
			}
			else if(StrEqual(buffer[0], "assists"))
			{
				if((buffer[1][0] == '+') || (buffer[1][0] == '-'))
				{
					value = value + CS_GetClientAssists(target_list[i]);
				}
				CS_SetClientAssists(target_list[i], value);
				Format(buffer[1], sizeof(buffer[]), "%i", value);
			}
			else if(StrEqual(buffer[0], "deaths"))
			{
				if((buffer[1][0] == '+') || (buffer[1][0] == '-'))
				{
					value = value + GetEntProp(target_list[i], Prop_Data, "m_iDeaths");
				}
				SetEntProp(target_list[i], Prop_Data, "m_iDeaths", value);
				Format(buffer[1], sizeof(buffer[]), "%i", value);
			}
			else if(StrEqual(buffer[0], "mvps"))
			{
				if((buffer[1][0] == '+') || (buffer[1][0] == '-'))
				{
					value = value + CS_GetMVPCount(target_list[i]);
				}
				CS_SetMVPCount(target_list[i], value);
				Format(buffer[1], sizeof(buffer[]), "%i", value);
			}
			else if(StrEqual(buffer[0], "scores"))
			{
				if((buffer[1][0] == '+') || (buffer[1][0] == '-'))
				{
					value = value + CS_GetClientContributionScore(target_list[i]);
				}
				CS_SetClientContributionScore(target_list[i], value);
				Format(buffer[1], sizeof(buffer[]), "%i", value);
			}
			else if(StrEqual(buffer[0], "clan"))
			{
				CS_SetClientClanTag(target_list[i], buffer[1]);
			}
			else
			{
				ReplyToCommand(client, "%t", "CMD_SetStats_Values");
				return Plugin_Handled;
			}
		}
	}

	if(tn_is_ml)
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_SetStats", target_name, buffer[0], buffer[1]);
		LogActionEx(client, "%t", "CMD_SetStats", target_name, buffer[0], buffer[1]);
	}
	else
	{
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_SetStats", "_s", target_name, buffer[0], buffer[1]);
		LogActionEx(client, "%t", "CMD_SetStats", "_s", target_name, buffer[0], buffer[1]);
	}
	return Plugin_Handled;
}

public Action: CMD_TeamScores(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%t", "CMD_TeamScores_Usage");
		return Plugin_Handled;
	}
	
	new String: team[8],
		String: buffer[64];
	
	GetCmdArg(1, team, sizeof(team));
	GetCmdArg(2, buffer, sizeof(buffer));
	new value = StringToInt(buffer);
	
	if(StrEqual(team, "t", false) || StrEqual(team, "2", false))
	{
		if((buffer[0] == '+') || (buffer[0] == '-'))
		{
			value = value + GetTeamScore(CS_TEAM_T);
		}
		SetTeamScore(CS_TEAM_T, value);
		
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_TeamScores_T", value);
		LogActionEx(client, "%t", "CMD_TeamScores_T", value);
	}
	else if(StrEqual(team, "ct", false) || StrEqual(team, "3", false))
	{
		if((buffer[0] == '+') || (buffer[0] == '-'))
		{
			value = value + GetTeamScore(CS_TEAM_CT);
		}
		SetTeamScore(CS_TEAM_CT, value);
		
		ShowActivity2(client, CMD_PREFIX, "%t", "CMD_TeamScores_CT", value);
		LogActionEx(client, "%t", "CMD_TeamScores_CT", value);
	}
	else
	{
		ReplyToCommand(client, "%t", "CMD_Invalid_Team");
	}
	return Plugin_Handled;
}

public Action: CMD_SpawnChicken(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	new Float: vec[2][3];
	GetClientEyePosition(client, vec[0]);
	GetClientEyeAngles(client, vec[1]);
	
	new Handle: trace = TR_TraceRayFilterEx(vec[0], vec[1], MASK_SOLID, RayType_Infinite, Filter_ExcludePlayers);
	if(!TR_DidHit(trace))
	{
		return Plugin_Handled;
	}
	TR_GetEndPosition(vec[0], trace);
	CloseHandle(trace);
	
	new String: buffer[6][4],
		values[6];
	
	for(new i = 0; i <= 5; i++)
	{
		GetCmdArg(i + 1, buffer[i], sizeof(buffer[]));
		values[i] = StringToInt(buffer[i]);
	}
	
	if(((values[0] < 0) || (values[0] > 6)) || ((values[1] < -1) || (values[1] > 9999)) || ((values[2] < 0) || (values[2] > 255)) || ((values[3] < 0) || (values[3] > 255)) || ((values[4] < 0) || (values[4] > 255)) || ((values[5] < 0) || (values[5] > 3)))
	{
		return Plugin_Handled;
	}
	
	new chicken = CreateEntityByName("chicken");
	if(!IsValidEntity(chicken))
	{
		return Plugin_Handled;
	}
	
	new String: color[16];
	Format(color, sizeof(color), "%s %s %s", buffer[2], buffer[3], buffer[4]);
	DispatchKeyValue(chicken, "glowcolor", color);
	DispatchKeyValue(chicken, "glowdist", "640");
	DispatchKeyValue(chicken, "glowstyle", buffer[5]);
	DispatchKeyValue(chicken, "glowenabled", "1");
	DispatchKeyValue(chicken, "ExplodeDamage", buffer[1]);
	DispatchKeyValue(chicken, "ExplodeRadius", "0");
	DispatchSpawn(chicken);
	
	if(values[1] < 0)
	{
		SetEntProp(chicken, Prop_Data, "m_takedamage", 0);
	}
	
	if(values[0] == 6)
	{
		SetEntityModel(chicken, MODEL_CHICKEN_ZOMBIE);
	}
	else
	{
		SetEntProp(chicken, Prop_Data, "m_nSkin", GetRandomInt(0, 1));
		SetEntProp(chicken, Prop_Data, "m_nBody", values[0]);
	}
	
	vec[0][2] = vec[0][2] + 10.0;
	TeleportEntity(chicken, vec[0], NULL_VECTOR, NULL_VECTOR);
	
	if(!StrEqual(SOUND_CHICKEN, "", false))
	{
		EmitSoundToAll(SOUND_CHICKEN, chicken);
	}

	return Plugin_Handled;
}

public Action: CMD_SpawnBall(client, args)
{
	if(!IsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	new Float: vec[2][3];
	GetClientEyePosition(client, vec[0]);
	GetClientEyeAngles(client, vec[1]);
	
	new Handle: trace = TR_TraceRayFilterEx(vec[0], vec[1], MASK_SOLID, RayType_Infinite, Filter_ExcludePlayers);
	if(!TR_DidHit(trace))
	{
		return Plugin_Handled;
	}
	TR_GetEndPosition(vec[0], trace);
	CloseHandle(trace);
	
	new ball = CreateEntityByName("prop_physics_multiplayer");
	if(!IsValidEntity(ball))
	{
		return Plugin_Handled;
	}
	
	DispatchKeyValue(ball, "model", MODEL_BALL);
	DispatchKeyValue(ball, "physicsmode", "2");
	DispatchSpawn(ball);
	
	vec[0][2] = vec[0][2] + 16.0;
	TeleportEntity(ball, vec[0], NULL_VECTOR, NULL_VECTOR);

	return Plugin_Handled;
}

GivePlayerWeapon(client, String: weapon[], type)
{
	new String: buffer[64];
	if(type == 1)
	{
		Format(buffer, sizeof(buffer), "weapon_%s", weapon);
	}
	else
	{
		Format(buffer, sizeof(buffer), "item_%s", weapon);
	}
	return GivePlayerItem(client, buffer);
}

DisarmPlayer(client)
{
	for(new i = 0; i < 5; i++)
	{
		new weapon = -1;
		while((weapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			if(IsValidEntity(weapon))
			{
				RemovePlayerItem(client, weapon);
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
	SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", 0);
	SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
}

LogActionEx(client, String: message[], any: ...)
{
	if(GetConVarBool(CVAR_LOG))
	{
		new String: buffer[256];
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(buffer, sizeof(buffer), message, 3);
		LogMessage("%N: %s", client, buffer);
	}
}

bool: IsClientValid(client)
{
	return ((client > 0) && (client <= MaxClients));
}

ItemType(String: itemname[])
{
	for(new i = 0; i < sizeof(WeaponsList); i++)
	{
		if(StrEqual(itemname, WeaponsList[i], false))
		{
			return 1;
		}
	}
	for(new i = 0; i < sizeof(ItemsList); i++)
	{
		if(StrEqual(itemname, ItemsList[i], false))
		{
			return 2;
		}
	}
	return 0;
}

public bool: Filter_ExcludePlayers(entity, contentsMask, any: data)
{
	return !((entity > 0) && (entity <= MaxClients));
}