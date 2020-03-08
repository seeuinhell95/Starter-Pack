#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#undef REQUIRE_EXTENSIONS
#include <dhooks>

#pragma newdecls required

Address g_iPatchAddress[2];
int g_iPatchRestore[2][100];
int g_iPatchSize[2];

Handle g_hPlayerRoughLandingEffectsHook;

public Plugin myinfo =
{
	name = "[CSGO] Ramp Slope Fix",
	author = "Peace-Maker | Edited: somebody.",
	description = "Ramp Slope Fix",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	Handle hGameConf = LoadGameConfigFile("ramp_slope_fix.games");
	if(hGameConf == INVALID_HANDLE)
		SetFailState("Can't find ramp_slope_fix.games.txt gamedata.");

	PatchBytes(0, hGameConf, "PlayerDidntMove", "PlayerDidntMove_Offset", "PlayerDidntMove_PatchSize", "PlayerDidntMove_Replacement");
	PatchBytes(1, hGameConf, "OppositeDirection", "OppositeDirection_Offset", "OppositeDirection_PatchSize", "OppositeDirection_Replacement");

	delete hGameConf;

	if (LibraryExists("dhooks"))
		OnLibraryAdded("dhooks");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "dhooks"))
	{
		Handle hGameData = LoadGameConfigFile("ramp_slope_fix.games");
		if(hGameData == null)
		{
			LogError("Failed to load ramp_slope_fix.games.txt gamedata for CGameMovement::PlayerRoughLandingEffects hook.");
			return;
		}

		Address pGameMovement = GameConfGetAddress(hGameData, "g_pGameMovement");
		if (pGameMovement == Address_Null)
		{
			LogError("Failed to find g_pGameMovement address");
			return;
		}

		int iOffset = GameConfGetOffset(hGameData, "CGameMovement::PlayerRoughLandingEffects");
		delete hGameData;

		if(iOffset == -1)
		{
			LogError("Can't find CGameMovement::PlayerRoughLandingEffects offset in gamedata.");
			return;
		}

		g_hPlayerRoughLandingEffectsHook = DHookCreate(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, DHooks_OnPlayerRoughLandingEffects);
		if(g_hPlayerRoughLandingEffectsHook == null)
		{
			LogError("Failed to create CGameMovement::PlayerRoughLandingEffects hook.");
			return;
		}

		DHookAddParam(g_hPlayerRoughLandingEffectsHook, HookParamType_Float);
		DHookRaw(g_hPlayerRoughLandingEffectsHook, false, pGameMovement);
	}
}

public MRESReturn DHooks_OnPlayerRoughLandingEffects(Handle hParams)
{
	float fvol = DHookGetParam(hParams, 1);
	if (fvol > 0.0)
	{
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

void PatchBytes(int iIndex, Handle hGameConf, const char[] sAddress, const char[] sOffset, const char[] sPatchSize, const char[] sReplacement)
{
	Address iAddr = GameConfGetAddress(hGameConf, sAddress);
	if(iAddr == Address_Null)
	{
		LogError("Can't find %s address.", sAddress);
		return;
	}

	int iOffset = GameConfGetOffset(hGameConf, sOffset);
	if(iOffset == -1)
	{
		LogError("Can't find %s in gamedata.", sOffset);
		return;
	}

	g_iPatchSize[iIndex] = GameConfGetOffset(hGameConf, sPatchSize);
	if(g_iPatchSize[iIndex] == -1)
	{
		LogError("Can't find %s in gamedata.", sPatchSize);
		return;
	}

	int iReplacement = GameConfGetOffset(hGameConf, sReplacement);
	if (iReplacement == -1)
	{
		LogError("Can't find %s in gamedata.", sReplacement);
		return;
	}

	iAddr += view_as<Address>(iOffset);
	g_iPatchAddress[iIndex] = iAddr;

	int iData;
	for(int i; i < g_iPatchSize[iIndex]; i++)
	{
		iData = LoadFromAddress(iAddr, NumberType_Int8);
		g_iPatchRestore[iIndex][i] = iData;

		StoreToAddress(iAddr, iReplacement, NumberType_Int8);

		iAddr++;
	}
}

public void OnPluginEnd()
{
	for (int i; i < sizeof(g_iPatchAddress); i++)
	{
		if(g_iPatchAddress[i] != Address_Null)
		{
			for(int b; b < g_iPatchSize[i]; b++)
			{
				StoreToAddress(g_iPatchAddress[i] + view_as<Address>(b), g_iPatchRestore[i][b], NumberType_Int8);
			}
		}
	}
}