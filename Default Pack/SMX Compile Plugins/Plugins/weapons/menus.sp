public int WeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				int index = g_iIndex[client];
				
				char skinIdStr[32];
				menu.GetItem(selection, skinIdStr, sizeof(skinIdStr));
				int skinId = StringToInt(skinIdStr);
				
				g_iSkins[client][index] = skinId;
				char updateFields[256];
				char weaponName[32];
				RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
				Format(updateFields, sizeof(updateFields), "%s = %d", weaponName, skinId);
				UpdatePlayerData(client, updateFields);
				
				RefreshWeapon(client, index);
				
				DataPack pack;
				CreateDataTimer(0.1, WeaponsMenuTimer, pack);
				pack.WriteCell(menu);
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(GetMenuSelectionPosition());
			}
		}
		case MenuAction_DisplayItem:
		{
			if(IsClientInGame(client))
			{
				char info[32];
				char display[64];
				menu.GetItem(selection, info, sizeof(info));
				
				if (StrEqual(info, "0"))
				{
					Format(display, sizeof(display), "%T", "DefaultSkin", client);
					return RedrawMenuItem(display);
				}
				else if (StrEqual(info, "-1"))
				{
					Format(display, sizeof(display), "%T", "RandomSkin", client);
					return RedrawMenuItem(display);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
	}
	return 0;
}

public Action WeaponsMenuTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	Menu menu = pack.ReadCell();
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int menuSelectionPosition = pack.ReadCell();
	
	if(IsValidClient(clientIndex))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0)
		{
			menu.DisplayAt(clientIndex, menuSelectionPosition, menuTime);
		}
	}
}

public int WeaponMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				if(StrEqual(buffer, "skin"))
				{
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						menuWeapons[g_iClientLanguage[client]][g_iIndex[client]].Display(client, menuTime);
					}
				}
				else if(StrEqual(buffer, "allskins"))
				{
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateAllSkinsMenu(client).Display(client, menuTime);
					}
				}
				else if(StrEqual(buffer, "float"))
				{
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateFloatMenu(client).Display(client, menuTime);
					}
				}
				else if(StrEqual(buffer, "stattrak"))
				{
					g_iStatTrak[client][g_iIndex[client]] = 1 - g_iStatTrak[client][g_iIndex[client]];
					char updateFields[256];
					char weaponName[32];
					RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));
					Format(updateFields, sizeof(updateFields), "%s_trak = %d", weaponName, g_iStatTrak[client][g_iIndex[client]]);
					UpdatePlayerData(client, updateFields);
					
					RefreshWeapon(client, g_iIndex[client]);
					
					CreateTimer(1.0, StatTrakMenuTimer, GetClientUserId(client));
				}
				else if(StrEqual(buffer, "nametag"))
				{
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateNameTagMenu(client).Display(client, menuTime);
					}
				}
				else if (StrEqual(buffer, "seed"))
				{
					int menuTime;
					if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateSeedMenu(client).Display(client, menuTime);
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateMainMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action StatTrakMenuTimer(Handle timer, int userid)
{
	int clientIndex = GetClientOfUserId(userid);
	if(IsValidClient(clientIndex))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0)
		{
			CreateWeaponMenu(clientIndex).Display(clientIndex, menuTime);
		}
	}
}

Menu CreateFloatMenu(int client)
{
	char buffer[60];
	Menu menu = new Menu(FloatMenuHandler);
	
	float fValue = g_fFloatValue[client][g_iIndex[client]];
	fValue = fValue * 100.0;
	int wear = 100 - RoundFloat(fValue);
	
	menu.SetTitle("%T%d%%", "SetFloat", client, wear);
	
	Format(buffer, sizeof(buffer), "%T", "Increase", client, g_iFloatIncrementPercentage);
	menu.AddItem("increase", buffer, wear == 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(buffer, sizeof(buffer), "%T", "Decrease", client, g_iFloatIncrementPercentage);
	menu.AddItem("decrease", buffer, wear == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	menu.ExitBackButton = true;
	
	return menu;
}

public int FloatMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				if(StrEqual(buffer, "increase"))
				{
					g_fFloatValue[client][g_iIndex[client]] = g_fFloatValue[client][g_iIndex[client]] - g_fFloatIncrementSize;
					if(g_fFloatValue[client][g_iIndex[client]] < 0.0)
					{
						g_fFloatValue[client][g_iIndex[client]] = 0.0;
					}
					if(g_FloatTimer[client] != INVALID_HANDLE)
					{
						KillTimer(g_FloatTimer[client]);
						g_FloatTimer[client] = INVALID_HANDLE;
					}
					DataPack pack;
					g_FloatTimer[client] = CreateDataTimer(0.1, FloatTimer, pack);
					pack.WriteCell(GetClientUserId(client));
					pack.WriteCell(g_iIndex[client]);
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateFloatMenu(client).Display(client, menuTime);
					}
				}
				else if(StrEqual(buffer, "decrease"))
				{
					g_fFloatValue[client][g_iIndex[client]] = g_fFloatValue[client][g_iIndex[client]] + g_fFloatIncrementSize;
					if(g_fFloatValue[client][g_iIndex[client]] > 1.0)
					{
						g_fFloatValue[client][g_iIndex[client]] = 1.0;
					}
					if(g_FloatTimer[client] != INVALID_HANDLE)
					{
						KillTimer(g_FloatTimer[client]);
						g_FloatTimer[client] = INVALID_HANDLE;
					}
					DataPack pack;
					g_FloatTimer[client] = CreateDataTimer(0.1, FloatTimer, pack);
					pack.WriteCell(GetClientUserId(client));
					pack.WriteCell(g_iIndex[client]);
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateFloatMenu(client).Display(client, menuTime);
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action FloatTimer(Handle timer, DataPack pack)
{

	ResetPack(pack);
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int index = pack.ReadCell();
	
	if(IsValidClient(clientIndex))
	{
		char updateFields[256];
		char weaponName[32];
		RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
		Format(updateFields, sizeof(updateFields), "%s_float = %.2f", weaponName, g_fFloatValue[clientIndex][g_iIndex[clientIndex]]);
		UpdatePlayerData(clientIndex, updateFields);
		
		RefreshWeapon(clientIndex, index);
	}
	
	g_FloatTimer[clientIndex] = INVALID_HANDLE;
}

Menu CreateSeedMenu(int client)
{
	Menu menu = new Menu(SeedMenuHandler);

	char buffer[128];

	if (g_iWeaponSeed[client][g_iIndex[client]] != -1)
	{
		Format(buffer, sizeof(buffer), "%T", "SeedTitle", client, g_iWeaponSeed[client][g_iIndex[client]]);
	}
	else if (g_iSeedRandom[client][g_iIndex[client]] > 0)
	{
		Format(buffer, sizeof(buffer), "%T", "SeedTitle", client, g_iSeedRandom[client][g_iIndex[client]]);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "SeedTitleNoSeed", client);
	}
	menu.SetTitle(buffer);

	Format(buffer, sizeof(buffer), "%T", "SeedRandom", client);
	menu.AddItem("rseed", buffer);

	Format(buffer, sizeof(buffer), "%T", "SeedManual", client);
	menu.AddItem("cseed", buffer);

	Format(buffer, sizeof(buffer), "%T", "SeedSave", client);
	menu.AddItem("sseed", buffer, g_iSeedRandom[client][g_iIndex[client]] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	Format(buffer, sizeof(buffer), "%T", "ResetSeed", client);
	menu.AddItem("seedr", buffer, g_iWeaponSeed[client][g_iIndex[client]] == -1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;
	
	return menu;
}

public int SeedMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				if(StrEqual(buffer, "rseed"))
				{
					g_iWeaponSeed[client][g_iIndex[client]] = -1;
					RefreshWeapon(client, g_iIndex[client]);
					CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));
				}
				else if (StrEqual(buffer, "cseed"))
				{
					g_bWaitingForSeed[client] = true;
					PrintToChat(client, " \x02%s \x06%t", g_ChatPrefix, "SeedInstruction");
				}
				else if (StrEqual(buffer, "sseed"))
				{
					if(g_iSeedRandom[client][g_iIndex[client]] > 0) 
					{
						g_iWeaponSeed[client][g_iIndex[client]] = g_iSeedRandom[client][g_iIndex[client]];
					}
					g_iSeedRandom[client][g_iIndex[client]] = 0;
					RefreshWeapon(client, g_iIndex[client]);

					char updateFields[256];
					char weaponName[32];
					RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));
					Format(updateFields, sizeof(updateFields), "%s_seed = %d", weaponName, g_iWeaponSeed[client][g_iIndex[client]]);
					UpdatePlayerData(client, updateFields);
					CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));

					PrintToChat(client, " \x02%s \x06%t", g_ChatPrefix, "SeedSaved");
				}
				else if (StrEqual(buffer, "seedr"))
				{
					g_iWeaponSeed[client][g_iIndex[client]] = -1;
					g_iSeedRandom[client][g_iIndex[client]] = 0;
					
					char updateFields[256];
					char weaponName[32];
					RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));
					Format(updateFields, sizeof(updateFields), "%s_seed = -1", weaponName);
					UpdatePlayerData(client, updateFields);
					CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));
					
					PrintToChat(client, " \x02%s \x06%t", g_ChatPrefix, "SeedReset");
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action SeedMenuTimer(Handle timer, int userid)
{
	int clientIndex = GetClientOfUserId(userid);
	if(IsValidClient(clientIndex))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0)
		{
			CreateSeedMenu(clientIndex).Display(clientIndex, menuTime);
		}
	}
}

Menu CreateNameTagMenu(int client)
{
	Menu menu = new Menu(NameTagMenuHandler);
	
	char buffer[128];
	
	StripHtml(g_NameTag[client][g_iIndex[client]], buffer, sizeof(buffer));
	menu.SetTitle("%T: %s", "SetNameTag", client, buffer);
	
	Format(buffer, sizeof(buffer), "%T", "ChangeNameTag", client);
	menu.AddItem("nametag", buffer);

	Format(buffer, sizeof(buffer), "%T", "DeleteNameTag", client);
	menu.AddItem("delete", buffer, strlen(g_NameTag[client][g_iIndex[client]]) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	
	return menu;
}

public int NameTagMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				if(StrEqual(buffer, "nametag"))
				{
					g_bWaitingForNametag[client] = true;
					PrintToChat(client, " \x02%s \x06%t", g_ChatPrefix, "NameTagInstruction");
				}
				else if(StrEqual(buffer, "delete"))
				{
					g_NameTag[client][g_iIndex[client]] = "";
					
					char updateFields[256];
					char weaponName[32];
					RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));
					Format(updateFields, sizeof(updateFields), "%s_tag = ''", weaponName);
					UpdatePlayerData(client, updateFields);
					
					RefreshWeapon(client, g_iIndex[client]);
					
					int menuTime;
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateWeaponMenu(client).Display(client, menuTime);
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

Menu CreateAllSkinsMenu(int client)
{
	Menu menu = new Menu(AllSkinsMenuHandler);
	menu.SetTitle("%T", "AllSkins", client);

	char buffer[60];
	for (int i = 0; i < sizeof(g_WeaponClasses); i++)
	{
		Format(buffer, sizeof(buffer), "%T", g_WeaponClasses[i], client);
		menu.AddItem(g_WeaponClasses[i], buffer);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int AllSkinsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char class[30];
				menu.GetItem(selection, class, sizeof(class));

				int iClass;
				g_smWeaponIndex.GetValue(class, iClass);
				g_iSkinIndex[client] = iClass;

				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateSkinsMenu(client, iClass).Display(client, menuTime);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

Menu CreateSkinsMenu(int client, int index)
{
	Menu menu = new Menu(SkinMenuHandler);

	char buffer[60];
	Format(buffer, sizeof(buffer), "%T", g_WeaponClasses[index], client);
	menu.SetTitle("%T", "AllSkinsSub", client, buffer);

	char idTemp[4];
	char infoTemp[32];

	int max = menuWeapons[g_iClientLanguage[client]][index].ItemCount;
	for(int i = 2; i < max; i++)
	{
		menuWeapons[g_iClientLanguage[client]][index].GetItem(i, idTemp, sizeof(idTemp), _, infoTemp, sizeof(infoTemp));
		menu.AddItem(idTemp, infoTemp);
	}

	menu.ExitBackButton = true;
	return menu;
}

public int SkinMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				int index = g_iIndex[client];

				char skinIdStr[32];
				menu.GetItem(selection, skinIdStr, sizeof(skinIdStr));
				int skinId = StringToInt(skinIdStr);

				g_iSkins[client][index] = skinId;
				char updateFields[256];
				char weaponName[32];
				RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
				Format(updateFields, sizeof(updateFields), "%s = %d", weaponName, skinId);
				UpdatePlayerData(client, updateFields);

				RefreshWeapon(client, index);

				DataPack pack;
				CreateDataTimer(0.1, SkinsMenuTimer, pack);
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(GetMenuSelectionPosition());
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateAllSkinsMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action SkinsMenuTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int menuSelectionPosition = pack.ReadCell();

	if(IsValidClient(clientIndex))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0)
		{
			CreateSkinsMenu(clientIndex, g_iSkinIndex[clientIndex]).DisplayAt(clientIndex, menuSelectionPosition, menuTime);
		}
	}
}

Menu CreateAllWeaponsMenu(int client)
{
	Menu menu = new Menu(AllWeaponsMenuHandler);
	menu.SetTitle("%T", "AllWeaponsMenuTitle", client);
	
	char name[32];
	for (int i = 0; i < sizeof(g_WeaponClasses); i++)
	{
		Format(name, sizeof(name), "%T", g_WeaponClasses[i], client);
		menu.AddItem(g_WeaponClasses[i], name);
	}
	
	menu.ExitBackButton = true;
	
	return menu;
}

public int AllWeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char class[30];
				menu.GetItem(selection, class, sizeof(class));
				
				g_smWeaponIndex.GetValue(class, g_iIndex[client]);
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateWeaponMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateMainMenu(client).Display(client, menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

Menu CreateWeaponMenu(int client)
{
	int index = g_iIndex[client];
	
	Menu menu = new Menu(WeaponMenuHandler);
	menu.SetTitle("%T", g_WeaponClasses[index], client);
	
	char buffer[128];
	
	Format(buffer, sizeof(buffer), "%T", "SetSkin", client);
	menu.AddItem("skin", buffer);

	if (g_bEnableAllSkins)
	{
		Format(buffer, sizeof(buffer), "%T", "AllSkins", client);
		menu.AddItem("allskins", buffer);
	}

	bool weaponHasSkin = (g_iSkins[client][index] != 0);
	
	if (g_bEnableFloat)
	{
		float fValue = g_fFloatValue[client][index];
		fValue = fValue * 100.0;
		int wear = 100 - RoundFloat(fValue);
		Format(buffer, sizeof(buffer), "%T%d%%", "SetFloat", client, wear);
		menu.AddItem("float", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	if (g_bEnableStatTrak)
	{
		if (g_iStatTrak[client][index] == 1)
		{
			Format(buffer, sizeof(buffer), "%T%T", "StatTrak", client, "On", client);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T%T", "StatTrak", client, "Off", client);
		}
		menu.AddItem("stattrak", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	if (g_bEnableNameTag)
	{
		Format(buffer, sizeof(buffer), "%T", "SetNameTag", client);
		menu.AddItem("nametag", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	if (g_bEnableSeed)
	{
		Format(buffer, sizeof(buffer), "%T", "Seed", client);
		menu.AddItem("seed", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	menu.ExitBackButton = true;
	
	return menu;
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));
				int menuTime;
				if(StrEqual(info, "all"))
				{
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateAllWeaponsMenu(client).Display(client, menuTime);
					}
				}
				else if(StrEqual(info, "lang"))
				{
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateLanguageMenu(client).Display(client, menuTime);
					}
				}
				else
				{
					g_smWeaponIndex.GetValue(info, g_iIndex[client]);
					if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
					{
						CreateWeaponMenu(client).Display(client, menuTime);
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

Menu CreateMainMenu(int client)
{
	char buffer[60];
	Menu menu = new Menu(MainMenuHandler, MENU_ACTIONS_DEFAULT);
	
	menu.SetTitle("%T", "WSMenuTitle", client);
	
	Format(buffer, sizeof(buffer), "%T", "ConfigAllWeapons", client);
	menu.AddItem("all", buffer);
	
	int index = 2;
	
	if (IsPlayerAlive(client))
	{
		char weaponClass[32];
		char weaponName[32];
		
		int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
		for (int i = 0; i < size; i++)
		{
			int weaponEntity = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
			if(weaponEntity != -1 && GetWeaponClass(weaponEntity, weaponClass, sizeof(weaponClass)))
			{
				Format(weaponName, sizeof(weaponName), "%T", weaponClass, client);
				menu.AddItem(weaponClass, weaponName, (IsKnifeClass(weaponClass) && g_iKnife[client] == 0) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				index++;
			}
		}
	}
	
	for(int i = index; i < 6; i++)
	{
		menu.AddItem("", "", ITEMDRAW_SPACER);
	}
	
	Format(buffer, sizeof(buffer), "%T", "ChangeLang", client);
	menu.AddItem("lang", buffer);
	
	return menu;
}

Menu CreateKnifeMenu(int client)
{
	Menu menu = new Menu(KnifeMenuHandler);
	menu.SetTitle("%T", "KnifeMenuTitle", client);
	
	char buffer[60];
	Format(buffer, sizeof(buffer), "%T", "OwnKnife", client);
	menu.AddItem("0", buffer, g_iKnife[client] != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_cord", client);
	menu.AddItem("49", buffer, g_iKnife[client] != 49 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_canis", client);
	menu.AddItem("50", buffer, g_iKnife[client] != 50 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_outdoor", client);
	menu.AddItem("51", buffer, g_iKnife[client] != 51 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_skeleton", client);
	menu.AddItem("52", buffer, g_iKnife[client] != 52 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_css", client);
	menu.AddItem("48", buffer, g_iKnife[client] != 48 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_ursus", client);
	menu.AddItem("43", buffer, g_iKnife[client] != 43 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_gypsy_jackknife", client);
	menu.AddItem("44", buffer, g_iKnife[client] != 44 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_stiletto", client);
	menu.AddItem("45", buffer, g_iKnife[client] != 45 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_widowmaker", client);
	menu.AddItem("46", buffer, g_iKnife[client] != 46 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_karambit", client);
	menu.AddItem("33", buffer, g_iKnife[client] != 33 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_m9_bayonet", client);
	menu.AddItem("34", buffer, g_iKnife[client] != 34 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_bayonet", client);
	menu.AddItem("35", buffer, g_iKnife[client] != 35 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_survival_bowie", client);
	menu.AddItem("36", buffer, g_iKnife[client] != 36 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_butterfly", client);
	menu.AddItem("37", buffer, g_iKnife[client] != 37 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_flip", client);
	menu.AddItem("38", buffer, g_iKnife[client] != 38 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_push", client);
	menu.AddItem("39", buffer, g_iKnife[client] != 39 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_tactical", client);
	menu.AddItem("40", buffer, g_iKnife[client] != 40 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_falchion", client);
	menu.AddItem("41", buffer, g_iKnife[client] != 41 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "%T", "weapon_knife_gut", client);
	menu.AddItem("42", buffer, g_iKnife[client] != 42 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	return menu;
}

public int KnifeMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char knifeIdStr[32];
				menu.GetItem(selection, knifeIdStr, sizeof(knifeIdStr));
				int knifeId = StringToInt(knifeIdStr);
				
				g_iKnife[client] = knifeId;
				char updateFields[50];
				Format(updateFields, sizeof(updateFields), "knife = %d", knifeId);
				UpdatePlayerData(client, updateFields);
				
				RefreshWeapon(client, knifeId, knifeId == 0);
				
				int menuTime;
				if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
				{
					CreateKnifeMenu(client).DisplayAt(client, GetMenuSelectionPosition(), menuTime);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

Menu CreateLanguageMenu(int client)
{
	Menu menu = new Menu(LanguageMenuHandler);
	menu.SetTitle("%T", "ChooseLanguage", client);
	
	char buffer[4];
	
	for (int i = 0; i < sizeof(g_Language); i++)
	{
		if(strlen(g_Language[i]) == 0)
			break;
		IntToString(i, buffer, sizeof(buffer));
		menu.AddItem(buffer, g_Language[i]);
	}
	
	return menu;
}

public int LanguageMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char langIndexStr[4];
				menu.GetItem(selection, langIndexStr, sizeof(langIndexStr));
				int langIndex = StringToInt(langIndexStr);
				
				g_iClientLanguage[client] = langIndex;
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}