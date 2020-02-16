public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Gloves_IsClientUsingGloves", Native_IsClientUsingGloves);
	CreateNative("Gloves_RegisterCustomArms", Native_RegisterCustomArms);
	CreateNative("Gloves_SetArmsModel", Native_SetArmsModel);
	CreateNative("Gloves_GetArmsModel", Native_GetArmsModel);
	return APLRes_Success;
}

public int Native_IsClientUsingGloves(Handle plugin, int numParams)
{
	int clientIndex = GetNativeCell(1);
	int playerTeam = GetClientTeam(clientIndex);
	return g_iGloves[clientIndex][playerTeam] != 0;
}

public int Native_RegisterCustomArms(Handle plugin, int numParams)
{
	int clientIndex = GetNativeCell(1);
	int playerTeam = GetClientTeam(clientIndex);
	GetNativeString(2, g_CustomArms[clientIndex][playerTeam], 256);
}

public int Native_SetArmsModel(Handle plugin, int numParams)
{
	int clientIndex = GetNativeCell(1);
	int playerTeam = GetClientTeam(clientIndex);
	GetNativeString(2, g_CustomArms[clientIndex][playerTeam], 256);
	if(g_iGloves[clientIndex][playerTeam] == 0)
	{
		SetEntPropString(clientIndex, Prop_Send, "m_szArmsModel", g_CustomArms[clientIndex][playerTeam]);
	}
}

public int Native_GetArmsModel(Handle plugin, int numParams)
{
	int clientIndex = GetNativeCell(1);
	int playerTeam = GetClientTeam(clientIndex);
	int size = GetNativeCell(3);
	SetNativeString(2, g_CustomArms[clientIndex][playerTeam], size);
}