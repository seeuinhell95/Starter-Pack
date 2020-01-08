char g_LastPrimaryWeapon[MAXPLAYERS + 1][50];
char g_LastSecondaryWeapon[MAXPLAYERS + 1][50];

public Action CMD_Guns(int client, int args)
{
	if(GetClientTeam(client) == BUILDERS && !IsPrepTime() && !IsBuildTime())
	{
		int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		if(!IsValidEntity(weapon))
		{
			ShowWeaponMenu(client);	
		}
	}
}

public void Weapons_OnClientPutInServer(int client)
{
	g_LastPrimaryWeapon[client] = "";
	g_LastSecondaryWeapon[client] = "";
}

public void RemoveAllPlayerWeapons(int client)
{
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0)
	{
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);	
	}

	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0)
	{
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);	
	}

	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon3 > 0)
	{
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);	
	}
}

public void Weapons_OnPrepTimeStart()
{
	LoopAllPlayers(i) 
	{
		if(GetClientTeam(i) == BUILDERS) 
		{
			ShowWeaponMenu(i);

			CreateTimer(0.2, Remove_Knife, i);
		}
	}	
}

public Action Remove_Knife(Handle tmr, any client)
{
	int knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	if(knife > -1)
	{
		RemovePlayerItem(client, knife);
		RemoveEdict(knife);	
	}
}

public void Weapons_OnPrepTimeEnd()
{
	LoopAllPlayers(i)
	{
		if(GetClientTeam(i) == BUILDERS)
		{
			GivePlayerItem(i, "weapon_knife");
			
			if(!StrEqual(g_LastPrimaryWeapon[i], "") && !StrEqual(g_LastSecondaryWeapon[i], ""))
			{
				GivePlayerItem(i, g_LastSecondaryWeapon[i]);
				GivePlayerItem(i, g_LastPrimaryWeapon[i]);	
			}		
		}
	}
}

void ShowWeaponMenu(int client)
{
	Menu menu = new Menu(MenuHandlers_PrimaryWeapon);
	menu.SetTitle("Válassz puskát");

	if(!StrEqual(g_LastPrimaryWeapon[client], "") && !StrEqual(g_LastSecondaryWeapon[client], ""))
		menu.AddItem("last", "Előző fegyverek");

	menu.AddItem("weapon_ak47", 			"AK-47");
	menu.AddItem("weapon_m4a1", 			"M4A1");
	menu.AddItem("weapon_m4a1_silencer", 	"M4A1-S");
	menu.AddItem("weapon_aug", 				"AUG");
	menu.AddItem("weapon_sg556", 			"SG 553");
	menu.AddItem("weapon_famas", 			"Famas");
	menu.AddItem("weapon_galilar", 			"Galil AR");
	menu.AddItem("weapon_mac10", 			"MAC-10");
	menu.AddItem("weapon_mp7", 				"MP7");
	menu.AddItem("weapon_mp9", 				"MP9");
	menu.AddItem("weapon_ump45", 			"UMP-45");
	menu.AddItem("weapon_nova", 			"Nova");
	menu.AddItem("weapon_nova", 			"XM1014");
	menu.AddItem("weapon_sawedoff", 		"Sawed-Off");
	menu.AddItem("weapon_mag7", 			"MAG-7");
	menu.AddItem("weapon_awp", 				"AWP");
	menu.AddItem("weapon_ssg08", 			"SSG 08");

	SetMenuExitButton(menu, false);
	menu.Display(client, 0);
}

public int MenuHandlers_PrimaryWeapon(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(GetClientTeam(client) == BUILDERS && IsPlayerAlive(client) && !IsBuildTime()) 
			{
				char info[32];
				GetMenuItem(menu, item, info, sizeof(info));

				if (StrEqual(info, "last"))
					return false;

				g_LastPrimaryWeapon[client] = info;

				if(!IsPrepTime() && StrEqual(g_LastPrimaryWeapon[client], ""))
					GivePlayerItem(client, info);

				Menu menu2 = new Menu(MenuHandlers_SecondaryWeapon);
				menu2.SetTitle("Válassz pisztolyt");
				menu2.AddItem("weapon_deagle", 			"Deagle");
				menu2.AddItem("weapon_revolver", 		"Revolver");
				menu2.AddItem("weapon_elite", 			"Dual Berettas");
				menu2.AddItem("weapon_fiveseven",		"Five-SeveN");
				menu2.AddItem("weapon_glock", 			"Glock");
				menu2.AddItem("weapon_usp_silencer",	"USP-S");
				menu2.AddItem("weapon_hkp2000", 		"P2000");
				menu2.AddItem("weapon_p250", 			"P250");
				menu2.AddItem("weapon_tec9", 			"Tec-9");
				menu2.AddItem("weapon_cz75a", 			"CZ75-Auto");
				SetMenuExitButton(menu2, false);
				menu2.Display(client, 0);
			}
		}
	}
	return false;
}

public int MenuHandlers_SecondaryWeapon(Menu menu2, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client)) 
			{
				char info[32];
				GetMenuItem(menu2, item, info, sizeof(info));

				g_LastSecondaryWeapon[client] = info;

				if(!IsPrepTime() && StrEqual(g_LastSecondaryWeapon[client], ""))
					GivePlayerItem(client, info);
			}
		}
	}
}