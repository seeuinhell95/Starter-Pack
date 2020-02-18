#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <hosties>
#include <steamworks>

new Handle:gH_Cvar_GameDescriptionOn = INVALID_HANDLE;
new bool:gShadow_GameDescriptionOn;
new Handle:gH_Cvar_GameDescriptionTag = INVALID_HANDLE;
new String:gShadow_GameDescriptionTag[64];
new bool:g_bSTAvailable = false;

GameDescription_OnPluginStart()
{
	gH_Cvar_GameDescriptionOn = CreateConVar("sm_hosties_override_gamedesc", "1", "Enable or disable an override of the game description (standard Counter-Strike: Source, override to Hosties/jailbreak): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gShadow_GameDescriptionOn = true;

	gH_Cvar_GameDescriptionTag = CreateConVar("sm_hosties_gamedesc_tag", "> [JailBreak] <", "Sets the game description tag.", 0);
	Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), "> [JailBreak] <");

	HookConVarChange(gH_Cvar_GameDescriptionOn, GameDescription_CvarChanged);
	HookConVarChange(gH_Cvar_GameDescriptionTag, GameDescription_CvarChanged);

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_SetGameDescription") == FeatureStatus_Available)
	{
		g_bSTAvailable = true;
	}
}

public GameDescription_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_GameDescriptionOn)
	{
		gShadow_GameDescriptionOn = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_GameDescriptionTag)
	{
		Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), newValue);
		
		if (gShadow_GameDescriptionOn && g_bSTAvailable)
		{
			SteamWorks_SetGameDescription(gShadow_GameDescriptionTag);
		}
	}
}

GameDesc_OnConfigsExecuted()
{
	gShadow_GameDescriptionOn = GetConVarBool(gH_Cvar_GameDescriptionOn);
	GetConVarString(gH_Cvar_GameDescriptionTag, gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag));

	if (gShadow_GameDescriptionOn && g_bSTAvailable)
	{
		SteamWorks_SetGameDescription(gShadow_GameDescriptionTag);
	}
}