#include <sdktools_client>

public Plugin myinfo =
{
	name 		= "[CSGO] TickRate Control",
	author 		= "Rostu | Edited: somebody.",
	description = "TickRate Control",
	version 	= "1.0",
	url 		= "http://sourcemod.net"
};

#define PTR(%0) view_as<Address>(%0)
#define nullptr Address_Null

int g_iDefaultTick;
int g_iCurrentTick;

Address g_pTickInterval;
Address g_pIntervalPerTick;

ConVar g_hTick;
ConVar g_hForceRetry;

public APLRes AskPluginLoad2( Handle hPlugin, bool late, char[] sError, int error_len )
{
	CreateNative("TickRate_GetCurrentTick", Native_GetCurrentTick);
	CreateNative("TickRate_GetDefaultTick", Native_GetDefaultTick);
	CreateNative("TickRate_SetTickRate", Native_SetTickRate);
}

public void OnPluginStart()
{
	(g_hTick = CreateConVar("tickrate_value", "128.0", "Server TickRate", 0, true, 21.0, true, 128.0)).AddChangeHook(OnTickRateChange);
	g_hForceRetry = CreateConVar("tickrate_force_retry", "0", "1 - After changing the tickrate_value value - all players will be forced to log in to the server\n0 - Nothing will happen", 0, true, 0.0, true, 1.0)
	ReadGameData();

	AutoExecConfig(true, "TickRateControl");
}

public void OnPluginEnd()
{
	if(g_iDefaultTick != g_iCurrentTick)
	{
		SetTickRate(g_iDefaultTick);
	}
}

public void OnConfigsExecuted()
{
	CheckToChangeTickRate(g_hTick.FloatValue);
}

public void OnTickRateChange (ConVar hCvar, const char[] sOldValue, const char[] sNewValue)
{
	CheckToChangeTickRate(StringToFloat(sNewValue), g_hForceRetry.BoolValue);
}

void CheckToChangeTickRate(float fTick, bool bForceRetry = false)
{
	float fNewTick = 1.0 / fTick;

	if(fNewTick > 0.048828125 || fNewTick < 0.0078125)
	{
		fNewTick = view_as<float>(g_iDefaultTick);
	}

	SetTickRate(view_as<int>(fNewTick));

	if(bForceRetry)
	{
		for(int x = 1; x <= MaxClients; x++) if(IsClientInGame(x) && !IsFakeClient(x))
		{
			ReconnectClient(x);
		}
	}
}

void SetTickRate(int iTick)
{
	StoreToAddress(g_pTickInterval, iTick, NumberType_Int32);
	StoreToAddress(g_pIntervalPerTick, iTick, NumberType_Int32);

	static GlobalForward hForward;

	if(hForward == null) 
		hForward = new GlobalForward("TickRate_OnTickRateChanged", ET_Ignore, Param_Cell, Param_Cell);

	Call_StartForward(hForward);
	Call_PushCell( 1.0 / view_as<float>(g_iCurrentTick));
	Call_PushCell( 1.0 / view_as<float>(iTick));
	Call_Finish();

	g_iCurrentTick = iTick;
}

void ReadGameData()
{
	GameData hGameData = new GameData("tickrate");

	if(!hGameData)
	{
		SetFailState("Couldn't read gamedata/tickrate.txt");
	}

	Address pStartSound 	= hGameData.GetAddress("sv_startsound");
	Address pSpawnServer 	= hGameData.GetAddress("spawnserver");

	int iTickInterval 		= hGameData.GetOffset("m_flTickInterval");
	int iStateInterval 		= hGameData.GetOffset("host_state_interval");

	if(pStartSound == nullptr || pSpawnServer == nullptr) 	SetFailState("Couldn't get Address sv_startsound/spawnserver :(");
	if(iTickInterval <= 0 || iStateInterval <= 0)					SetFailState("Couldn't get Offset m_flTickInterval/host_state_interval :(");

	g_pTickInterval 		= PTR(LoadFromAddress(pStartSound + PTR(iTickInterval), NumberType_Int32));
	g_pIntervalPerTick 		= PTR(LoadFromAddress(pSpawnServer + PTR(iStateInterval), NumberType_Int32));

	g_iDefaultTick 			= LoadFromAddress(g_pTickInterval, NumberType_Int32);

	delete hGameData;
}

public int Native_GetCurrentTick (Handle hPlugin, int iParams)
{
	return view_as<int>(1.0 / view_as<float>(g_iCurrentTick));
}

public int Native_GetDefaultTick (Handle hPlugin, int iParams)
{
	return view_as<int>(1.0 / view_as<float>(g_iDefaultTick));
}

public int Native_SetTickRate (Handle hPlugin, int iParams)
{
	CheckToChangeTickRate(GetNativeCell(1), GetNativeCell(2));
}