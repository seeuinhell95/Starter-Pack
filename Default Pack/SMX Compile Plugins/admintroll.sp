#pragma semicolon 1

#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#include <sdkhooks>

enum Punishments
{
	None = 0,
	Hide,
	Damage,
	Mirror
};

new Punishments:Punishment[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "[CSGO] Admin Troll",
	author = "HTCarnage | Edited: somebody.",
	description = "Admin Troll",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_troll", OpenTrollMenu, ADMFLAG_GENERIC, "Open the troll player menu");
	RegAdminCmd("sm_untroll", UntrollPlayer, ADMFLAG_GENERIC, "Stop trolling a player");
	RegAdminCmd("sm_showtrolls", ShowTrolls, ADMFLAG_GENERIC, "Show trolled players");

	LoadTranslations("common.phrases.txt");
}

public OnClientDisconnect(client)
{
	Punishment[client] = None;
	if(client > 0 && client < MaxClients)
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}

public OnClientPutInServer(client)
{
	if(client > 0 && client < MaxClients && IsClientInGame(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit); 
	}
}

public Action:ShowTrolls(client, args)
{
	PrintTrollsToConsole(client);
	return Plugin_Handled;
}

public Action:UntrollPlayer(client, args)
{
	new String:arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if(args < 1)
	{
		ReplyToCommand(client, " \x06[\x02Troll\x06] \x07Használat: <\x06sm_untroll\x07> <\x06játékos\x07>");
		return Plugin_Handled;
	}

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_NO_BOTS,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToCommand(client, " \x06[\x02Troll\x06] \x07A játékos nem található.");
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		Punishment[target_list[i]] = None;
	}

	if (tn_is_ml)
	{
		ReplyToCommand(client, " \x06[\x02Troll\x06] \x07Trollkodás megszüntetve \x06%t \x07játékoson.", target_name);
	}
	else
	{
		ReplyToCommand(client, " \x06[\x02Troll\x06] \x07Trollkodás megszüntetve \x06%s \x07játékoson.", target_name);
	}

	return Plugin_Handled;
}

public Action:OpenTrollMenu(client, args)
{	
	if(client > 0)
	{
		new Handle:menu = CreateMenu(Troll_Menu_Handler);
		SetMenuTitle(menu, "Troll Menü");
		AddMenuItem(menu, "Troll", "Játékos megtrollkodása");
		AddMenuItem(menu, "Untroll", "Trollkodás megszüntetése");
		AddMenuItem(menu, "List", "Trollkodott játékosok listája");
		SetMenuExitButton(menu, true);

		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
		ReplyToCommand(client, "\x06[\x02Troll\x06] \x07Ez a parancs csak a játékban használható.");

	return Plugin_Handled;
}

public Troll_Menu_Handler(Handle:trollmenu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			new String:item[64];
			GetMenuItem(trollmenu, param2, item, sizeof(item));

			if(StrEqual(item, "Troll"))
			{
				new Handle:menu = CreateMenu(Punishment_Menu_Handler, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				SetMenuTitle(menu, "Troll Menü");

				AddMenuItem(menu, "Damage", "0 sebzés");
				AddMenuItem(menu, "Hide", "Láthatatlan ellenfelek");
				AddMenuItem(menu, "Mirror", "Tükörsebzés");
				SetMenuExitButton(menu, true);

				DisplayMenu(menu, param1, MENU_TIME_FOREVER);
			}

			if(StrEqual(item, "Untroll"))
			{
				new Handle:menu = CreateMenu(Untroll_Menu_Handler, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				SetMenuTitle(menu, "Válassz játékost");
				AddTargetsToMenu2(menu, param1, COMMAND_FILTER_NO_BOTS);
				SetMenuExitButton(menu, true);

				DisplayMenu(menu, param1, MENU_TIME_FOREVER);
			}

			if(StrEqual(item, "List"))
			{
				PrintTrollsToConsole(param1);
				OpenTrollMenu(param1, 0);
			}
		}
		case MenuAction_Cancel:
		{
			//CloseHandle(trollmenu);
		}
		case MenuAction_End:
		{
			CloseHandle(trollmenu);
		}
	}
}

public Punishment_Menu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Damage"))
			{
				new Handle:DamageMenu = CreateMenu(DamageMenu_Handler);
				SetMenuTitle(DamageMenu, "Válassz játékost");
				AddTargetsToMenu2(DamageMenu, param1, COMMAND_FILTER_NO_BOTS);
				DisplayMenu(DamageMenu, param1, MENU_TIME_FOREVER);
			}
			else if (StrEqual(item, "Hide"))
			{
				new Handle:HideMenu = CreateMenu(HideMenu_Handler);
				SetMenuTitle(HideMenu, "Válassz játékost");
				AddTargetsToMenu2(HideMenu, param1, COMMAND_FILTER_NO_BOTS);
				DisplayMenu(HideMenu, param1, MENU_TIME_FOREVER);
			}
			else if(StrEqual(item, "Mirror"))
			{
				new Handle:MirrorMenu = CreateMenu(MirrorMenu_Handler);
				SetMenuTitle(MirrorMenu, "Válassz játékost");
				AddTargetsToMenu2(MirrorMenu, param1, COMMAND_FILTER_NO_BOTS);
				DisplayMenu(MirrorMenu, param1, MENU_TIME_FOREVER);
			}
		}

		case MenuAction_Cancel:
		{
			//CloseHandle(menu);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

public Untroll_Menu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			new String:sUserid[20];
			GetMenuItem(menu, param2, sUserid, sizeof(sUserid));
			new userid = StringToInt(sUserid);
			new target = GetClientOfUserId(userid);
			if(Punishment[target] != None)
			{
				Punishment[target] = None;
				PrintToChat(param1, " \x06[\x02Troll\x06] \x06%N \x07már nincs trollkodás alatt.", target);
				LogAction(param1, target, "%L removed the troll punishment from %L", param1, target);
				OpenTrollMenu(param1, 0);
			}
			else
			{
				PrintToChat(param1, " \x06[\x02Troll\x06] \x06%N \x07nincs trollkodás alatt.", target);
				OpenTrollMenu(param1, 0);
			}
		}
		case MenuAction_Cancel:
		{
			//CloseHandle(menu);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

public DamageMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	new String:sUserid[20];
	GetMenuItem(menu, param2, sUserid, sizeof(sUserid));
	new userid = StringToInt(sUserid);
	new target = GetClientOfUserId(userid);
	if(target > 0 && param1 > 0)
	{
		Punishment[target] = Damage;
		PrintToChat(param1, " \x06[\x02Troll\x06] \x06%N \x07meglett trollkodva. (\x060 sebzés\x07)", target);
		LogAction(param1, target, "%L set zero damage on %L", param1, target);
	}
}

public HideMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	new String:sUserid[20];
	GetMenuItem(menu, param2, sUserid, sizeof(sUserid));
	new userid = StringToInt(sUserid);
	new target = GetClientOfUserId(userid);
	if(target > 0 && param1 > 0)
	{
		Punishment[target] = Hide;
		PrintToChat(param1, " \x06[\x02Troll\x06] \x06%N \x07meglett trollkodva. (\x06Láthatatlan ellenfelek\x07)", target);
		LogAction(param1, target, "%L hide enemy players from %L", param1, target);
	}
}

public MirrorMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	new String:sUserid[20];
	GetMenuItem(menu, param2, sUserid, sizeof(sUserid));
	new userid = StringToInt(sUserid);
	new target = GetClientOfUserId(userid);
	if(target > 0 && param1 > 0)
	{
		Punishment[target] = Mirror;
		PrintToChat(param1, " \x06[\x02Troll\x06] \x06%N \x07meglett trollkodva. (\x06Tükörsebzés\x07)", target);
		LogAction(param1, target, "%L mirrored damage on %L", param1, target);
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(Punishment[attacker] == Damage)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
		if(Punishment[attacker] == Mirror)
		{
			SDKHooks_TakeDamage(attacker, victim, victim, damage, damagetype);
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

PrintTrollsToConsole(client)
{
	PrintToChat(client, " \x06[\x02Troll\x06] \x07Nézd meg a konzolt az információkért.");
	PrintToConsole(client, "---------------------------------------------");
	PrintToConsole(client, "------ Jelenlegi trollkodott játékosok ------");
	PrintToConsole(client, "---------------------------------------------");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(Punishment[i] != None)
			{
				new String:name[50];
				GetClientName(i, name, sizeof(name));
				PrintToConsole(client, "%s", name);
			}
		}
	}
}

public Action:Hook_SetTransmit(entity, client) 
{ 
	if (client != entity && (0 < entity <= MaxClients) && Punishment[client] == Hide && IsPlayerAlive(client))
	{
		if(GetClientTeam(entity) != GetClientTeam(client))	
			return Plugin_Handled;
	}			

	return Plugin_Continue; 
}