#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:gH_Enabled = INVALID_HANDLE;
new Handle:gH_LAW = INVALID_HANDLE;
new Handle:gH_Return = INVALID_HANDLE;
new Handle:gH_Sound = INVALID_HANDLE;
new Handle:gH_SoundAll = INVALID_HANDLE;

new bool:bEnabled = true;
new bool:bLAW = false;
new bool:bRtn = false;
new bool:bSnd = false;
new bool:bSndAll = true;

new String:zsSnd[255];

public Plugin myinfo =
{
	name = "[CSGO] FlashLight",
	author = "Mitchell | Edited: somebody.",
	description = "FlashLight",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	gH_Enabled = CreateConVar("sm_flashlight_enabled",			"1",						"0 = Disables flashlight 1 = Enables flashlight", _, true, 0.0, true, 1.0);
	gH_LAW = CreateConVar("sm_flashlight_lookatweapon",			"0",						"0 = Doesn't use +LAW 1 = hooks +LAW",  _, true, 0.0, true, 1.0);
	gH_Return = CreateConVar("sm_flashlight_return",			"0",						"0 = Doesn't return blocking +LAW 1 = Does return", _, true, 0.0, true, 1.0);
	gH_Sound = CreateConVar("sm_flashlight_sound",				"items/flashlight1.wav",	"Sound path to use when a player uses the flash light.");
	gH_SoundAll = CreateConVar("sm_flashlight_sound_all",		"1",						"Play the sound to all players, or just to the activator?");

	UpdateSound();

	HookConVarChange(gH_Enabled, ConVarChanged);
	HookConVarChange(gH_LAW, ConVarChanged);
	HookConVarChange(gH_Return, ConVarChanged);
	HookConVarChange(gH_Sound, ConVarChanged);
	HookConVarChange(gH_SoundAll, ConVarChanged);

	AutoExecConfig(true, "flashlight");
	
	AddCommandListener(Command_LAW, "+lookatweapon");

	RegConsoleCmd("sm_flashlight", Command_FlashLight);
	RegConsoleCmd("sm_lightflash", Command_FlashLight);
	RegConsoleCmd("sm_flash", Command_FlashLight);
	RegConsoleCmd("sm_light", Command_FlashLight);
	RegConsoleCmd("sm_fl", Command_FlashLight);
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if(cvar == gH_Enabled)
		bEnabled = bool:StringToInt(newVal);
	if(cvar == gH_LAW)
		bLAW = bool:StringToInt(newVal);
	if(cvar == gH_Return)
		bRtn = bool:StringToInt(newVal);
	if(cvar == gH_SoundAll)
		bSndAll = bool:StringToInt(newVal);
	if(cvar == gH_Sound)
	{
		UpdateSound();
	}
}

public UpdateSound()
{
	decl String:formatedSound[256];
	GetConVarString(gH_Sound, formatedSound, sizeof(formatedSound));
	if(StrEqual(formatedSound, "") || StrEqual(formatedSound, "0"))
	{
		bSnd = false;
	} else
	{
		strcopy(zsSnd, sizeof(zsSnd), formatedSound);
		bSnd = true;
		PrecacheSound(zsSnd);
		if(!StrEqual(formatedSound, "items/flashlight1.wav"))
		{
			Format(formatedSound, sizeof(formatedSound), "sound/%s", formatedSound);
			AddFileToDownloadsTable(formatedSound);
		}
	}
}

public OnMapStart()
{
	if(bSnd)
	{
		PrecacheSound(zsSnd, true);
	}
}

public Action: Command_LAW(client, const String:command[], argc)
{
	if(!bLAW || !bEnabled)
		return Plugin_Continue;

	if(!IsClientInGame(client))
		return Plugin_Continue;

	if(!IsPlayerAlive(client))
		return Plugin_Continue;	

	ToggleFlashlight(client);

	return (bRtn) ? Plugin_Continue : Plugin_Handled;
}

public Action: Command_FlashLight(client, args)
{
	if(!bEnabled)
		return Plugin_Handled;

	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		ToggleFlashlight(client);
	}
	return Plugin_Handled;
}

ToggleFlashlight(client)
{
	SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	if(bSnd)
	{
		if(bSndAll)
		{
			EmitSoundToAll(zsSnd, client);
		} else
		{
			EmitSoundToClient(client, zsSnd);
		}
	}
}