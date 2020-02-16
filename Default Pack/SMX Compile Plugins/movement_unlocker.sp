#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

Address g_iPatchAddress;
int g_iPatchRestore[100];
int g_iPatchRestoreBytes;

bool g_bUnlockMovement[MAXPLAYERS + 1] = { true, ... };

public Plugin myinfo =
{
	name = "[CSGO] Movement Unlocker",
	author = "Peace-Maker | Edited: somebody.",
	description = "Movement Unlocker",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_movementunlocker", Command_MovementUnlocker);
	RegConsoleCmd("sm_mu", Command_MovementUnlocker);
	RegConsoleCmd("sm_boost", Command_MovementUnlocker);
	RegConsoleCmd("sm_bhopboost", Command_MovementUnlocker);

	Handle hGameConf = LoadGameConfigFile("csgo_movement_unlocker.games");
	if(hGameConf == null)
		SetFailState("Can't find csgo_movement_unlocker.games.txt gamedata.");

	Address iAddr = GameConfGetAddress(hGameConf, "WalkMoveMaxSpeed");
	if(iAddr == Address_Null)
	{
		CloseHandle(hGameConf);
		SetFailState("Can't find WalkMoveMaxSpeed address.");
	}

	int iCapOffset = GameConfGetOffset(hGameConf, "CappingOffset");
	if(iCapOffset == -1)
	{
		CloseHandle(hGameConf);
		SetFailState("Can't find CappingOffset in gamedata.");
	}

	iAddr += view_as<Address>(iCapOffset);
	g_iPatchAddress = iAddr;

	g_iPatchRestoreBytes = GameConfGetOffset(hGameConf, "PatchBytes");

	delete hGameConf;

	if(g_iPatchRestoreBytes == -1)
	{
		delete hGameConf;
		SetFailState("Can't find PatchBytes in gamedata.");
	}

	for(int i = 0; i < g_iPatchRestoreBytes; i++)
	{
		g_iPatchRestore[i] = LoadFromAddress(iAddr, NumberType_Int8);

		StoreToAddress(iAddr, 0x90, NumberType_Int8);
		
		iAddr++;
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnPluginEnd()
{
	UnpatchGame();
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client))
	{
		return;
	}

	g_bUnlockMovement[client] = true;

	SDKHook(client, SDKHook_PreThinkPost, Hook_PreThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void Hook_PreThinkPost(int client)
{
	if(!g_bUnlockMovement[client])
	{
		UnpatchGame();
	}
}

public void Hook_PostThinkPost(int client)
{
	if(!g_bUnlockMovement[client])
	{
		RepatchGame();
	}
}

public Action Command_MovementUnlocker(int client, int args)
{
	g_bUnlockMovement[client] = !g_bUnlockMovement[client];
	ReplyToCommand(client, "[SM] BunnyHop Gyorsító: \x06%s", g_bUnlockMovement[client] ? "Bekapcsolva" : "Kikapcsolva");

	return Plugin_Handled;
}

void RepatchGame()
{
	if(g_iPatchAddress != Address_Null)
	{
		for(int i = 0; i < g_iPatchRestoreBytes; i++)
		{
			StoreToAddress(g_iPatchAddress + view_as<Address>(i), 0x90, NumberType_Int8);
		}
	}
}

void UnpatchGame()
{
	if(g_iPatchAddress != Address_Null)
	{
		for(int i = 0; i < g_iPatchRestoreBytes; i++)
		{
			StoreToAddress(g_iPatchAddress + view_as<Address>(i), g_iPatchRestore[i], NumberType_Int8);
		}
	}
}