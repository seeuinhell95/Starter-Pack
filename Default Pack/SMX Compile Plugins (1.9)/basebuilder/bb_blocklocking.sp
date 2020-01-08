public void Locking_OnClientPutInServer(int client)
{
	clientlocks[client] = 0;	
}

public void Locking_RoundStart()
{
	LoopAllPlayers(i)
		clientlocks[i] = 0;
}

void LockBlock(int client, int entitys = 0, bool lockedWithG = false)
{
	if (IsAdmin(client) || IsPlayerAlive(client) && GetClientTeam(client) == BUILDERS && IsBuildTime())
	{
		int entity = (entitys == 0) ? GetTargetBlock(client) : entitys;

		if (entity != -1)
		{
			int owner = GetBlockOwner(entity);

			if (owner <= 0)
			{
				if (clientlocks[client] < g_iMaxLocks)
				{
					ColorBlockByEntity(client, entity, false);
					SetBlockOwner(entity, client);
					if(lockedWithG)
						PrintHintText(client, "%T", "Locked", client);
					clientlocks[client]++;
				} 
				else  PrintHintText(client, "%T", "Max locked", client, g_iMaxLocks);
			}

			else
			{
				if (client != owner && !IsAdmin(client)) 
				{
					char username[MAX_NAME_LENGTH];
					GetClientName(owner, username, sizeof(username));
					PrintHintText(client, "%T", "Already locked", client, username);
				}

				else if(!g_OnceStopped[client])
				{
					ColorBlockByEntity(client, entity, true);
					SetBlockOwner(entity, 0);
					PrintHintText(client, "%T", "Unlocked", client);
					clientlocks[client]--;
				}
			}
		}
	}
}

void ColorBlockByEntity(int client, int entity, bool reset)
{
	if(IsValidEntity(entity) && client != -1) 
	{
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);

		if (reset)
			Entity_SetRenderColor(entity, 255, 255, 255, 255);
		else Entity_SetRenderColor(entity, colorr[client], colorg[client], colorb[client], 255);
	}
}