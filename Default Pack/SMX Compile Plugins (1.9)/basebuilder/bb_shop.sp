public void Shop_PlayerSpawn(int client)
{
	g_buyOnceRound[client] = true;
	g_buyOnceRoundGravity[client] = true;
}

public Action CMD_Shop(int client, int args)
{
	if(GetClientTeam(client) == 2)
	{
		Menu shopmenu = new Menu(MenuHandler_Shop);
		SetMenuTitle(shopmenu, "Zombi Bolt");

		AddMenuItem(shopmenu, "sknife", "Szuper Kés (100$)");
		AddMenuItem(shopmenu, "health", "+5000 Élet (80$)");
		AddMenuItem(shopmenu, "health2", "+3000 Élet (50$)");
		AddMenuItem(shopmenu, "speed", "+Sebesség (60$)");
		AddMenuItem(shopmenu, "gravity", "+Graviáticó (60$)");
		shopmenu.Display(client, 0);
	}

	else if(GetClientTeam(client) == 3 && !IsBuildTime())
	{
		Menu shopmenu = new Menu(MenuHandler_Shop);
		SetMenuTitle(shopmenu, "Építő Bolt");

		AddMenuItem(shopmenu, "goldenak47", "Szuper AK-47 (100$)");
		AddMenuItem(shopmenu, "sknife", "Szuper Kés (100$)");
		AddMenuItem(shopmenu, "weapon_decoy", "Fagyasztás (70$)");
		AddMenuItem(shopmenu, "weapon_hegrenade", "Égetés (70$)");
		AddMenuItem(shopmenu, "health", "+200 Élet (50$)");
		shopmenu.Display(client, 0);
	}

	return Plugin_Handled;
}

public int MenuHandler_Shop(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));

			int clientMoney = Client_GetMoney(client);

			if(GetClientTeam(client) == 2)
			{
				if(StrEqual(info, "speed"))
				{
					if(clientMoney < 60)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 60;
						Client_SetMoney(client, newClientMoney);
						hasitem[client] = true;
						float fspeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fspeed * 1.5);
					}
				}
				else if(StrEqual(info, "gravity"))
				{
					if(clientMoney < 60)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						if(g_buyOnceRoundGravity[client])
						{
							int newClientMoney = clientMoney - 60;
							Client_SetMoney(client, newClientMoney);
							float fgravity = GetEntityGravity(client);
							SetEntityGravity(client, fgravity * 0.8);
							g_buyOnceRoundGravity[client] = false;
								
						} else if(!g_buyOnceRoundGravity[client])
						{
							CPrintToChat(client, "%s%T", Prefix, "Money returned", client);		
						}
					}
				}

				else if(StrEqual(info, "health"))
				{
					if(clientMoney < 80)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						if(g_buyOnceRound[client])
						{
							int newClientMoney = clientMoney - 80;
							Client_SetMoney(client, newClientMoney);
							int ihealth = GetClientHealth(client);
							SetEntityHealth(client, ihealth + 5000);
							
							if(GetClientTeam(client) == 2)
								g_buyOnceRound[client] = false;
								
						} else if(!g_buyOnceRound[client])
						{
							CPrintToChat(client, "%s%T", Prefix, "Money returned", client);		
						}
					}
				}
				else if(StrEqual(info, "health2"))
				{
					if(clientMoney < 50)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						if(g_buyOnceRound[client])
						{
							int newClientMoney = clientMoney - 50;
							Client_SetMoney(client, newClientMoney);
							int ihealth = GetClientHealth(client);
							SetEntityHealth(client, ihealth + 3000);
							
							if(GetClientTeam(client) == 2)
								g_buyOnceRound[client] = false;
								
						} else if(!g_buyOnceRound[client])
						{
							CPrintToChat(client, "%s%T", Prefix, "Money returned", client);		
						}
					}
				}
				else if(StrEqual(info, "sknife"))
				{
					if(clientMoney < 100)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 100;
						Client_SetMoney(client, newClientMoney);
						GiveSuperKnife(client);
					}
				}
			}

			if(GetClientTeam(client) == 3)
			{
				if(StrEqual(info, "goldenak47"))
				{
					if(clientMoney < 100)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 100;
						Client_SetMoney(client, newClientMoney);
						GiveGoldenAk(client);
					}
				}
				else if(StrEqual(info, "health"))
				{
					if(clientMoney < 50)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						if(g_buyOnceRound[client])
						{
							int newClientMoney = clientMoney - 50;
							Client_SetMoney(client, newClientMoney);
							int ihealth = GetClientHealth(client);
							SetEntityHealth(client, ihealth + 200);
							
							if(GetClientTeam(client) == 3)
								g_buyOnceRound[client] = false;
								
						} else if(!g_buyOnceRound[client])
						{
							CPrintToChat(client, "%s%T", Prefix, "Money returned", client);		
						}
					}
				}
				else if(StrEqual(info, "weapon_decoy"))
				{
					if(clientMoney < 70)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 70;
						Client_SetMoney(client, newClientMoney);
						GivePlayerItem(client, "weapon_decoy");
					}
				}
				else if(StrEqual(info, "weapon_hegrenade"))
				{
					if(clientMoney < 70)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 70;
						Client_SetMoney(client, newClientMoney);
						GivePlayerItem(client, "weapon_hegrenade");
					}
				}
				else if(StrEqual(info, "sknife"))
				{
					if(clientMoney < 100)
						CPrintToChat(client, "%s%T", Prefix, "Shop not enough money", client);
					else
					{
						int newClientMoney = clientMoney - 100;
						Client_SetMoney(client, newClientMoney);
						GiveSuperKnife(client);
					}
				}
			}
		}
	}
}