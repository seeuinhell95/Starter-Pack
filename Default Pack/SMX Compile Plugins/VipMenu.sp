#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>

#define Choice_Chickens		0
#define Choice_Balls		1
#define Choice_Weapons		2
#define Choice_Invis		3
#define Choice_Models		4
#define Choice_Colors		5
#define Choice_FVK			6
#define Choice_Case			7
#define Choice_Users		8

public Plugin myinfo =
{
	name = "[CSGO] ViP Menu",
	author = "Cherry | Edited: somebody.",
	description = "ViP Menu",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	RegAdminCmd("sm_vip", Command_VipMenu, ADMFLAG_RESERVATION, "ViP Menu");
	RegAdminCmd("sm_vipmenu", Command_VipMenu, ADMFLAG_RESERVATION, "ViP Menu");
}

public Handler_AdminMenu(Handle:hMenu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		if(param2 == Choice_Chickens)
		{
			DisplayChickensMenu(param1);
		}

		if(param2 == Choice_Balls)
		{
			DisplayBallsMenu(param1);
		}

		if(param2 == Choice_Weapons)
		{
			DisplayWeaponsMenu(param1);
		}

		if(param2 == Choice_Invis)
		{
			DisplayInvisMenu(param1);
		}

		if(param2 == Choice_Models)
		{
			ClientCommand(param1, "sm_models");
		}

		if(param2 == Choice_Colors)
		{
			ClientCommand(param1, "sm_colors");
		}

		if(param2 == Choice_FVK)
		{
			DisplayFVKMenu(param1);
		}

		if(param2 == Choice_Case)
		{
			ClientCommand(param1, "sm_case");
		}

		if(param2 == Choice_Users)
		{
			ClientCommand(param1, "sm_users");
		}
	}
}

stock DisplayInvisMenu(client)
{
	Handle vMenu = CreateMenu(MenuHandler_InvisMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(vMenu, "Láthatatlanság Menü");

	AddMenuItem(vMenu, "InvisOn", "Láthatatlanság bekapcsolása");
	AddMenuItem(vMenu, "InvisOff", "Láthatatlanság kikapcsolása");

	SetMenuExitButton(vMenu, true);
	DisplayMenu(vMenu, client, 30);
}

public int MenuHandler_InvisMenu(Handle vMenu, MenuAction maAction, int client, int choice)
{
	if(maAction == MenuAction_Select)
	{
		char sChoice[8];
		GetMenuItem(vMenu, choice, sChoice, 8);

		if(StrEqual(sChoice, "InvisOn"))
		{
			DisplayInvisOnMenu(client);
		}

		if(StrEqual(sChoice, "InvisOff"))
		{
			DisplayInvisOffMenu(client);
		}
	}

	else if(maAction == MenuAction_End)
	{
		CloseHandle(vMenu);
	}
}

stock DisplayInvisOffMenu(client)
{
	new Handle:ymenu = CreateMenu(MenuHandler_InvisOffMenu);
	SetMenuTitle(ymenu, "Láthatatlanság kikapcsolása");
	SetMenuExitBackButton(ymenu, true);

	AddTargetsToMenu2(ymenu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(ymenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_InvisOffMenu(Handle:ymenu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(ymenu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(ymenu, param2, info, sizeof(info));
			new userid = StringToInt(info);

			if ((target = GetClientOfUserId(userid)) == 0)
			{
				PrintToChat(param1, " \x06[\x02ViP\x06] \x07Az általad kiválasztott játékos már nem elérhető.");
			}
			else
			{
				ClientCommand(param1, "sm_invis %N 0", target);
			}
		}
	}
}

stock DisplayInvisOnMenu(client)
{
	new Handle:qmenu = CreateMenu(MenuHandler_InvisOnMenu);
	SetMenuTitle(qmenu, "Láthatatlanság bekapcsolása");
	SetMenuExitBackButton(qmenu, true);

	AddTargetsToMenu2(qmenu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(qmenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_InvisOnMenu(Handle:qmenu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(qmenu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(qmenu, param2, info, sizeof(info));
			new userid = StringToInt(info);

			if ((target = GetClientOfUserId(userid)) == 0)
			{
				PrintToChat(param1, " \x06[\x02ViP\x06] \x07Az általad kiválasztott játékos már nem elérhető.");
			}
			else
			{
				ClientCommand(param1, "sm_invis %N 1", target);
			}
		}
	}
}

stock DisplayChickensMenu(client)
{
	Handle fMenu = CreateMenu(MenuHandler_ChickensMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(fMenu, "Csirke Menü");

	AddMenuItem(fMenu, "DefaultChicken",	"Csirke");
	AddMenuItem(fMenu, "DefaultChickenBig",	"Nagy csirke");
	AddMenuItem(fMenu, "BirthdayChicken",	"Szülinapi csirke");
	AddMenuItem(fMenu, "GhostChicken",		"Szellem csirke");
	AddMenuItem(fMenu, "ChristmasChicken",	"Karácsonyi csirke");
	AddMenuItem(fMenu, "BunnyChicken",		"Húsvéti csirke");
	AddMenuItem(fMenu, "PumpkinChicken",	"Halloweeni csirke");
	AddMenuItem(fMenu, "ZombieChicken",		"Zombi csirke");

	SetMenuExitButton(fMenu, true);
	DisplayMenu(fMenu, client, 30);
}

public int MenuHandler_ChickensMenu(Handle fMenu, MenuAction maAction, int client, int choice)
{
	if(maAction == MenuAction_Select)
	{
		char sChoice[8];
		GetMenuItem(fMenu, choice, sChoice, 8);

		if(StrEqual(sChoice, "DefaultChicken"))
		{
			ClientCommand(client, "sm_sc 0");
		}

		if(StrEqual(sChoice, "DefaultChickenBig"))
		{
			ClientCommand(client, "sm_scbig");
		}

		if(StrEqual(sChoice, "BirthdayChicken"))
		{
			ClientCommand(client, "sm_sc 1");
		}

		if(StrEqual(sChoice, "GhostChicken"))
		{
			ClientCommand(client, "sm_sc 2");
		}

		if(StrEqual(sChoice, "ChristmasChicken"))
		{
			ClientCommand(client, "sm_sc 3");
		}

		if(StrEqual(sChoice, "BunnyChicken"))
		{
			ClientCommand(client, "sm_sc 4");
		}

		if(StrEqual(sChoice, "PumpkinChicken"))
		{
			ClientCommand(client, "sm_sc 5");
		}

		if(StrEqual(sChoice, "ZombieChicken"))
		{
			ClientCommand(client, "sm_sc 6");
		}
	}

	else if(maAction == MenuAction_End)
	{
		CloseHandle(fMenu);
	}
}

stock DisplayBallsMenu(client)
{
	Handle jMenu = CreateMenu(MenuHandler_BallsMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(jMenu, "Focilabda Menü");

	AddMenuItem(jMenu, "CustomBall",			"Egyedi focilabda");
	AddMenuItem(jMenu, "ValveBall",				"Valve sima focilabda");
	AddMenuItem(jMenu, "ValveBallPumpkin",		"Valve tök focilabda");

	SetMenuExitButton(jMenu, true);
	DisplayMenu(jMenu, client, 30);
}

public int MenuHandler_BallsMenu(Handle jMenu, MenuAction maAction, int client, int choice)
{
	if(maAction == MenuAction_Select)
	{
		char sChoice[8];
		GetMenuItem(jMenu, choice, sChoice, 8);

		if(StrEqual(sChoice, "CustomBall"))
		{
			ClientCommand(client, "sm_ball");
		}

		if(StrEqual(sChoice, "ValveBall"))
		{
			ClientCommand(client, "sm_spawnent ball");
		}

		if(StrEqual(sChoice, "ValveBallPumpkin"))
		{
			ClientCommand(client, "sm_spawnent ball 1");
		}
	}

	else if(maAction == MenuAction_End)
	{
		CloseHandle(jMenu);
	}
}

stock DisplayWeaponsMenu(client)
{
	Handle gMenu = CreateMenu(MenuHandler_WeaponsMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(gMenu, "Fegyver Menü");

	AddMenuItem(gMenu, "Shield",		"Taktikai pajzs");
	AddMenuItem(gMenu, "HealthShot",	"Elsősegély-injekció");
	AddMenuItem(gMenu, "GoldKnife",		"Arany kés");

	SetMenuExitButton(gMenu, true);
	DisplayMenu(gMenu, client, 30);
}

public int MenuHandler_WeaponsMenu(Handle gMenu, MenuAction maAction, int client, int choice)
{
	if(maAction == MenuAction_Select)
	{
		char sChoice[8];
		GetMenuItem(gMenu, choice, sChoice, 8);

		if(StrEqual(sChoice, "Shield"))
		{
			ClientCommand(client, "sm_weapon @me shield");
		}

		if(StrEqual(sChoice, "HealthShot"))
		{
			ClientCommand(client, "sm_weapon @me healthshot");
		}

		if(StrEqual(sChoice, "GoldKnife"))
		{
			ClientCommand(client, "sm_weapon @me knifegg");
		}
	}

	else if(maAction == MenuAction_End)
	{
		CloseHandle(gMenu);
	}
}

stock DisplayFVKMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_FVKMenu);
	SetMenuTitle(menu, "Hamis VAC kirúgás");
	SetMenuExitBackButton(menu, true);

	AddTargetsToMenu2(menu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_FVKMenu(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(menu, param2, info, sizeof(info));
			new userid = StringToInt(info);

			if ((target = GetClientOfUserId(userid)) == 0)
			{
				PrintToChat(param1, " \x06[\x02ViP\x06] \x07Az általad kiválasztott játékos már nem elérhető.");
			}
			else
			{
				ServerCommand("sm_fvk %N", target);
			}
		}
	}
}

public Action: Command_VipMenu(client, args)
{
	new Handle:hMenu = CreateMenu(Handler_AdminMenu, MENU_ACTIONS_ALL );
	SetMenuTitle(hMenu, "ViP Menü");

	AddMenuItem(hMenu,		"Choice_Chickens",		"Csirkék lehívása");
	AddMenuItem(hMenu,		"Choice_Balls",			"Focilabdák lehívása");
	AddMenuItem(hMenu,		"Choice_Weapons",		"Fegyver lehívás");
	AddMenuItem(hMenu,		"Choice_Invis",			"Láthatatlanság");
	AddMenuItem(hMenu,		"Choice_Models",		"Karakter kinézetek");
	AddMenuItem(hMenu,		"Choice_Colors",		"Karakter színezés");
	AddMenuItem(hMenu,		"Choice_FVK",			"Hamis VAC kirúgás");
	AddMenuItem(hMenu,		"Choice_Case",			"Hamis kés nyitás");
	AddMenuItem(hMenu,		"Choice_Users",			"Játékosok adatai");

	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}