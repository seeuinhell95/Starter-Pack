bool g_RoundEnd;

public void Respawn_OnClientPutInServer(int client)
{
	g_bFirstTeamJoin[client] = true;
}

public void Respawn_PlayerTeam(int client)
{
	if(g_bFirstTeamJoin[client] && !IsClientSourceTV(client)) 
	{
		g_bFirstTeamJoin[client] = false;
		CreateTimer(5.0, Respawn_Player, client);
	}		
}

public Action CMD_Respawn(int client, int args)
{
	if(IsClientInGame(client) && client > 0)
	{
		if(IsBuildTime() || IsPrepTime())
		{
			CS_RespawnPlayer(client);
			return Plugin_Handled;
		}

		CPrintToChat(client, "%s%T", Prefix, "Respawn", client);
	}
	return Plugin_Continue;
}

public void Respawn_OnPrepTimeStart()
{
	LoopAllPlayers(i)
	{
		if(GetClientTeam(i) == BUILDERS)
			CS_RespawnPlayer(i);
	}
}

public void Respawn_OnPrepTimeEnd()
{
	LoopAllPlayers(i)
	{
		if(GetClientTeam(i) == ZOMBIES)
		{
			TeleportEntity(i, CTSpawnOrg, CTSpawnAng, NULL_VECTOR);
		}
	}
}

public void Respawn_OnPlayerDeath(int client)
{
	CreateTimer(1.0, Respawn_Player, client);
}

public Action Respawn_Player(Handle tmr, any client)
{
	if(IsClientInGame(client) && !IsPlayerAlive(client))
	{
		if(!g_RoundEnd && client != 0 && IsClientInGame(client))
		{
			if(GetClientTeam(client) == ZOMBIES)
			{
				if(IsBuildTime() || IsPrepTime()) 
					CS_RespawnPlayer(client);

				if(!IsBuildTime() && !IsPrepTime())
				{
					CS_RespawnPlayer(client);
					TeleportEntity(client, CTSpawnOrg, CTSpawnAng, NULL_VECTOR);
				}
			}

			else if(GetClientTeam(client) == BUILDERS)
			{
				if(IsBuildTime() || IsPrepTime())
					CS_RespawnPlayer(client);

				if(!IsBuildTime() && !IsPrepTime())
				{
					CS_SwitchTeam(client, ZOMBIES);
					CS_RespawnPlayer(client);
					TeleportEntity(client, CTSpawnOrg, CTSpawnAng, NULL_VECTOR);
				}
			}
		}
	}
}

public void Respawn_RoundEnd()
{
	g_RoundEnd = true;
}

public void Respawn_RoundStart()
{
	g_RoundEnd = false;	
}

void GetTeleportCoords()
{	
	int entindex;
	char name[150];

	while ((entindex = FindEntityByClassname(entindex, "info_teleport_destination")) != -1)
	{
		if(IsValidEntity(entindex) && entindex != -1) 
		{
			GetEntPropString(entindex, Prop_Data, "m_iName", name, sizeof(name));
			if (StrEqual(name, "teleport_lobby"))
			{
				GetEntPropVector(entindex, Prop_Send, "m_vecOrigin", 	CTSpawnOrg);
				GetEntPropVector(entindex, Prop_Data, "m_angRotation", 	CTSpawnAng); 

				CTSpawnOrg[2] += 20;
			}
		}
	}
}