public int Native_IsClientGagged(Handle hPlugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}
	
	return g_Gagged[client];
}

public int Native_IsClientMuted(Handle hPlugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}
	
	return g_Muted[client];
}

public int Native_SetClientGag(Handle hPlugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}
	
	bool gagState = GetNativeCell(2);
	
	if (gagState)
	{
		if (g_Gagged[client])
		{
			return false;
		}
		
		PerformGag(-1, client, true);
	}
	else
	{
		if (!g_Gagged[client])
		{
			return false;
		}
		
		PerformUnGag(-1, client, true);
	}
	
	return true;
}

public int Native_SetClientMute(Handle hPlugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}
	
	bool muteState = GetNativeCell(2);
	
	if (muteState)
	{
		if (g_Muted[client])
		{
			return false;
		}
		
		PerformMute(-1, client, true);
	}
	else
	{
		if (!g_Muted[client])
		{
			return false;
		}
		
		PerformUnMute(-1, client, true);
	}

	return true;
}