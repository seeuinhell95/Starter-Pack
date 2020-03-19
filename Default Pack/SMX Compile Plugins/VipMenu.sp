#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>

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

public Handler_AdminMenu(Handle: VipMenu, MenuAction: action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(VipMenu, param2, sChoice, 64);

		if(StrEqual(sChoice, "Choice_Chickens"))
		{
			DisplayChickensMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Balls"))
		{
			DisplayBallsMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Weapons"))
		{
			DisplayWeaponsMenu(param1); 
		}

		if(StrEqual(sChoice, "Choice_SLAM"))
		{
			DisplaySLAMMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_DropMoney"))
		{
			ClientCommand(param1, "sm_dm");
			OpenMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Models"))
		{
			ClientCommand(param1, "sm_models");
		}

		if(StrEqual(sChoice, "Choice_Colors"))
		{
			ClientCommand(param1, "sm_colors");
		}

		if(StrEqual(sChoice, "Choice_FVK"))
		{
			DisplayFVKMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Case"))
		{
			ClientCommand(param1, "sm_case");
		}

		if(StrEqual(sChoice, "Choice_RainBow"))
		{
			DisplayRainBowMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Invis"))
		{
			DisplayInvisMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Wasted"))
		{
			DisplayWastedMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_Users"))
		{
			ClientCommand(param1, "sm_users");
			PrintToChat(param1, " \x06[\x02ViP\x06] \x07Nézd meg a konzolt az információkért.");
			OpenMenu(param1);
		}

		if(StrEqual(sChoice, "Choice_BhopStats"))
		{
			ClientCommand(param1, "sm_pad");
			PrintToChat(param1, " \x06[\x02ViP\x06] \x07Nézd meg a konzolt az információkért.");
			OpenMenu(param1);
		}
	}
}

stock DisplayChickensMenu(client)
{
	Handle ChickensMenu = CreateMenu(MenuHandler_ChickensMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(ChickensMenu, "Csirke Menü");

	AddMenuItem(ChickensMenu, "DefaultChicken",		"Csirke");
	AddMenuItem(ChickensMenu, "DefaultChickenBig",	"Nagy csirke");
	AddMenuItem(ChickensMenu, "BirthdayChicken",	"Szülinapi csirke");
	AddMenuItem(ChickensMenu, "GhostChicken",		"Szellem csirke");
	AddMenuItem(ChickensMenu, "ChristmasChicken",	"Karácsonyi csirke");
	AddMenuItem(ChickensMenu, "BunnyChicken",		"Húsvéti csirke");
	AddMenuItem(ChickensMenu, "PumpkinChicken",		"Halloweeni csirke");
	AddMenuItem(ChickensMenu, "ZombieChicken",		"Zombi csirke");
	AddMenuItem(ChickensMenu, "ZombieChickenBig",	"Nagy zombi csirke \n \n");

	AddMenuItem(ChickensMenu, "BackVipMenu",		"Vissza a ViP menübe");

	SetMenuExitButton(ChickensMenu, true);
	DisplayMenu(ChickensMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_ChickensMenu(Handle ChickensMenu, MenuAction ChickensAction, int client, int choice)
{
	if(ChickensAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(ChickensMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "DefaultChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "DefaultChickenBig"))
		{
			ClientCommand(client, "sm_scbig");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "BirthdayChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 1");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "GhostChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 2");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "ChristmasChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 3");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "BunnyChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 4");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "PumpkinChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 5");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "ZombieChicken"))
		{
			ClientCommand(client, "sm_spawnent chicken 6");
			DisplayChickensMenu(client);
		}

		if(StrEqual(sChoice, "ZombieChickenBig"))
		{
			ClientCommand(client, "sm_scbig 1");
			DisplayChickensMenu(client);
		}
	}

	else if(ChickensAction == MenuAction_End)
	{
		CloseHandle(ChickensMenu);
	}
}

stock DisplayBallsMenu(client)
{
	Handle BallsMenu = CreateMenu(MenuHandler_BallsMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(BallsMenu, "Focilabda/Hógolyó Menü");

	AddMenuItem(BallsMenu, "CustomBall",		"Egyedi focilabda");
	AddMenuItem(BallsMenu, "SnowBalls",			"Hógolyó kupac");
	AddMenuItem(BallsMenu, "ValveBall",			"Valve focilabda");
	AddMenuItem(BallsMenu, "ValveBallPumpkin",	"Valve tök focilabda \n \n");

	AddMenuItem(BallsMenu, "BackVipMenu",		"Vissza a ViP menübe");

	SetMenuExitButton(BallsMenu, true);
	DisplayMenu(BallsMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_BallsMenu(Handle BallsMenu, MenuAction BallsAction, int client, int choice)
{
	if(BallsAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(BallsMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "CustomBall"))
		{
			ClientCommand(client, "sm_ball");
			DisplayBallsMenu(client);
		}

		if(StrEqual(sChoice, "SnowBalls"))
		{
			ClientCommand(client, "sm_spawnent snow");
			DisplayBallsMenu(client);
		}

		if(StrEqual(sChoice, "ValveBall"))
		{
			ClientCommand(client, "sm_spawnent ball");
			DisplayBallsMenu(client);
		}

		if(StrEqual(sChoice, "ValveBallPumpkin"))
		{
			ClientCommand(client, "sm_spawnent ball 1");
			DisplayBallsMenu(client);
		}
	}

	else if(BallsAction == MenuAction_End)
	{
		CloseHandle(BallsMenu);
	}
}

stock DisplayWeaponsMenu(client)
{
	Handle WeaponsMenu = CreateMenu(MenuHandler_WeaponsMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(WeaponsMenu, "Fegyver Menü");

	AddMenuItem(WeaponsMenu, "Shield",		"Taktikai pajzs");
	AddMenuItem(WeaponsMenu, "HealthShot",	"Elsősegély-injekció");
	AddMenuItem(WeaponsMenu, "SnowBall",	"Hógolyó");
	AddMenuItem(WeaponsMenu, "Knife",		"Kés");
	AddMenuItem(WeaponsMenu, "C4",			"C4");
	AddMenuItem(WeaponsMenu, "GoldKnife",	"Arany kés");
	AddMenuItem(WeaponsMenu, "Tablet",		"Tablet");
	AddMenuItem(WeaponsMenu, "NightVision",	"Éjjellátó szemüveg \n \n");

	AddMenuItem(WeaponsMenu, "BackVipMenu",	"Vissza a ViP menübe");

	SetMenuExitButton(WeaponsMenu, true);
	DisplayMenu(WeaponsMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_WeaponsMenu(Handle WeaponsMenu, MenuAction WeaponsAction, int client, int choice)
{
	if(WeaponsAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(WeaponsMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "Shield"))
		{
			ClientCommand(client, "sm_weapongive @me shield");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "HealthShot"))
		{
			ClientCommand(client, "sm_weapongive @me healthshot");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "SnowBall"))
		{
			ClientCommand(client, "sm_weapongive @me snowball");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "Knife"))
		{
			ClientCommand(client, "sm_weapongive @me knife");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "C4"))
		{
			ClientCommand(client, "sm_weapongive @me c4");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "GoldKnife"))
		{
			ClientCommand(client, "sm_weapongive @me knifegg");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "Tablet"))
		{
			ClientCommand(client, "sm_weapongive @me tablet");
			DisplayWeaponsMenu(client);
		}

		if(StrEqual(sChoice, "NightVision"))
		{
			ClientCommand(client, "sm_weapongive @me nvgs");
			DisplayWeaponsMenu(client);
		}
	}

	else if(WeaponsAction == MenuAction_End)
	{
		CloseHandle(WeaponsMenu);
	}
}

stock DisplaySLAMMenu(client)
{
	Handle SLAMMenu = CreateMenu(MenuHandler_SLAMMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(SLAMMenu, "SLAM engedélyek kezelése");

	AddMenuItem(SLAMMenu, "SLAMAllow",		"SLAM engedélyezése");
	AddMenuItem(SLAMMenu, "SLAMUnAllow",	"SLAM letiltása \n \n");

	AddMenuItem(SLAMMenu, "BackVipMenu", "Vissza a ViP menübe");

	SetMenuExitButton(SLAMMenu, true);
	DisplayMenu(SLAMMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_SLAMMenu(Handle SLAMMenu, MenuAction SLAMAction, int client, int choice)
{
	if(SLAMAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(SLAMMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "SLAMAllow"))
		{
			ClientCommand(client, "sm_slam");
		}

		if(StrEqual(sChoice, "SLAMUnAllow"))
		{
			ClientCommand(client, "sm_unslam");
		}
	}

	else if(SLAMAction == MenuAction_End)
	{
		CloseHandle(SLAMMenu);
	}
}

stock DisplayInvisMenu(client)
{
	Handle InvisMenu = CreateMenu(MenuHandler_InvisMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(InvisMenu, "Láthatatlanság Menü");

	AddMenuItem(InvisMenu, "InvisOn", "Láthatatlanság bekapcsolása");
	AddMenuItem(InvisMenu, "InvisOff", "Láthatatlanság kikapcsolása \n \n");

	AddMenuItem(InvisMenu, "BackVipMenu", "Vissza a ViP menübe");

	SetMenuExitButton(InvisMenu, true);
	DisplayMenu(InvisMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_InvisMenu(Handle InvisMenu, MenuAction InvisAction, int client, int choice)
{
	if(InvisAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(InvisMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "InvisOn"))
		{
			DisplayInvisOnMenu(client);
		}

		if(StrEqual(sChoice, "InvisOff"))
		{
			DisplayInvisOffMenu(client);
		}
	}

	else if(InvisAction == MenuAction_End)
	{
		CloseHandle(InvisMenu);
	}
}

stock DisplayInvisOnMenu(client)
{
	new Handle: InvisOnMenu = CreateMenu(MenuHandler_InvisOnMenu);
	SetMenuTitle(InvisOnMenu, "Láthatatlanság bekapcsolása");
	SetMenuExitButton(InvisOnMenu, true);

	AddTargetsToMenu2(InvisOnMenu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(InvisOnMenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_InvisOnMenu(Handle: InvisOnMenu, MenuAction: InvisOnAction, param1, param2)
{
	switch (InvisOnAction)
	{
		case MenuAction_End:
		{
			CloseHandle(InvisOnMenu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(InvisOnMenu, param2, info, sizeof(info));
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

stock DisplayInvisOffMenu(client)
{
	new Handle: InvisOffMenu = CreateMenu(MenuHandler_InvisOffMenu);
	SetMenuTitle(InvisOffMenu, "Láthatatlanság kikapcsolása");
	SetMenuExitButton(InvisOffMenu, true);

	AddTargetsToMenu2(InvisOffMenu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(InvisOffMenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_InvisOffMenu(Handle: InvisOffMenu, MenuAction: InvisOffAction, param1, param2)
{
	switch (InvisOffAction)
	{
		case MenuAction_End:
		{
			CloseHandle(InvisOffMenu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(InvisOffMenu, param2, info, sizeof(info));
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

stock DisplayFVKMenu(client)
{
	new Handle: FVKMenu = CreateMenu(MenuHandler_FVKMenu);
	SetMenuTitle(FVKMenu, "Hamis VAC kirúgás");
	SetMenuExitButton(FVKMenu, true);

	AddTargetsToMenu2(FVKMenu, 0, COMMAND_FILTER_NO_BOTS);
	DisplayMenu(FVKMenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_FVKMenu(Handle: FVKMenu, MenuAction: FVKAction, param1, param2)
{
	switch (FVKAction)
	{
		case MenuAction_End:
		{
			CloseHandle(FVKMenu);
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			new target;

			GetMenuItem(FVKMenu, param2, info, sizeof(info));
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

stock DisplayRainBowMenu(client)
{
	Handle RainBowMenu = CreateMenu(MenuHandler_RainBowMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(RainBowMenu, "Szivárvány írás és név");

	AddMenuItem(RainBowMenu, "RainBowChat",		"Szivárvány írás be/kikapcslás");
	AddMenuItem(RainBowMenu, "RainBowName",		"Szivárvány név be/kikapcsolás \n \n");

	AddMenuItem(RainBowMenu, "BackVipMenu",		"Vissza a ViP menübe");

	SetMenuExitButton(RainBowMenu, true);
	DisplayMenu(RainBowMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_RainBowMenu(Handle RainBowMenu, MenuAction RainBowAction, int client, int choice)
{
	if(RainBowAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(RainBowMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "RainBowChat"))
		{
			ClientCommand(client, "sm_rbm");
			DisplayRainBowMenu(client);
		}

		if(StrEqual(sChoice, "RainBowName"))
		{
			ClientCommand(client, "sm_rbn");
			DisplayRainBowMenu(client);
		}
	}

	else if(RainBowAction == MenuAction_End)
	{
		CloseHandle(RainBowMenu);
	}
}

stock DisplayWastedMenu(client)
{
	Handle WastedMenu = CreateMenu(MenuHandler_WastedMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(WastedMenu, "Játékosok közös szerverideje");

	AddMenuItem(WastedMenu, "WastedAll",	"Összes");
	AddMenuItem(WastedMenu, "WastedMonth",	"Havi \n \n");

	AddMenuItem(WastedMenu, "BackVipMenu",	"Vissza a ViP menübe");

	SetMenuExitButton(WastedMenu, true);
	DisplayMenu(WastedMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_WastedMenu(Handle WastedMenu, MenuAction WastedAction, int client, int choice)
{
	if(WastedAction == MenuAction_Select)
	{
		char sChoice[64];
		GetMenuItem(WastedMenu, choice, sChoice, 64);

		if(StrEqual(sChoice, "BackVipMenu"))
		{
			OpenMenu(client);
		}

		if(StrEqual(sChoice, "WastedAll"))
		{
			ClientCommand(client, "sm_wasted");
			DisplayWastedMenu(client);
		}

		if(StrEqual(sChoice, "WastedMonth"))
		{
			ClientCommand(client, "sm_wastedm");
			DisplayWastedMenu(client);
		}
	}

	else if(WastedAction == MenuAction_End)
	{
		CloseHandle(WastedMenu);
	}
}

public Action: Command_VipMenu(client, args)
{
	OpenMenu(client);
	return Plugin_Handled;
}

void OpenMenu(int client)
{
	new Handle: VipMenu = CreateMenu(Handler_AdminMenu, MENU_ACTIONS_ALL);
	SetMenuTitle(VipMenu, ">> === ViP Menü === <<");

	AddMenuItem(VipMenu,		"Choice_Chickens",		"Csirke lehívás");
	AddMenuItem(VipMenu,		"Choice_Balls",			"Focilabda/hógolyó lehívás");

	if (CheckCommandAccess(client, "sm_command", ADMFLAG_CUSTOM1))
	{
		AddMenuItem(VipMenu,	"Choice_Weapons",		"Fegyver lehívás");
	}

	AddMenuItem(VipMenu,		"Choice_SLAM",			"SLAM engedélyek");
	AddMenuItem(VipMenu,		"Choice_DropMoney",		"Pénz dobálás");
	AddMenuItem(VipMenu,		"Choice_Models",		"Karakter kinézetek");
	AddMenuItem(VipMenu,		"Choice_Colors",		"Karakter színezés");

	if (CheckCommandAccess(client, "sm_command", ADMFLAG_CUSTOM2))
	{
		AddMenuItem(VipMenu,	"Choice_FVK",			"Hamis VAC kirúgás");
	}

	AddMenuItem(VipMenu,		"Choice_Case",			"Hamis kés nyitás");
	AddMenuItem(VipMenu,		"Choice_RainBow",		"Szivárvány írás és név");

	if (CheckCommandAccess(client, "sm_command", ADMFLAG_GENERIC))
	{
		AddMenuItem(VipMenu,	"Choice_Invis",			"Láthatatlanság");
	}

	AddMenuItem(VipMenu,		"Choice_Wasted",		"Játékosok szerverideje");

	if (CheckCommandAccess(client, "sm_command", ADMFLAG_CUSTOM2))
	{
		AddMenuItem(VipMenu,	"Choice_Users",			"Játékosok adatai");
	}

	AddMenuItem(VipMenu,		"Choice_BhopStats",		"Bhop ellenőrzés be/kikapcsolása");

	SetMenuExitButton(VipMenu, true);
	DisplayMenu(VipMenu, client, MENU_TIME_FOREVER);
}