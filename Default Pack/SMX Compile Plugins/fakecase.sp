#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

new Handle:SelectedKnife;
Menu g_KnifeMenu = null;
Menu g_SkinMenu = null;

public Plugin myinfo =
{
	name = "[CSGO] Fake Case",
	author = "Tommie113 | Edited: somebody.",
	description = "Fake Case",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	LoadTranslations("fakecase.phrases");

	RegAdminCmd("sm_fakecase", FakeCaseCMD, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_casefake", FakeCaseCMD, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_case", FakeCaseCMD, ADMFLAG_RESERVATION);

	SelectedKnife = CreateArray(32);
	for(new i = 0; i < MAXPLAYERS; i++)
	{
		PushArrayString(SelectedKnife, "null");
	}
}

public void OnMapStart()
{
	g_KnifeMenu = BuildKnifeMenu();
	g_SkinMenu = BuildSkinMenu();
}

public void OnMapEnd()
{
	if(g_KnifeMenu != INVALID_HANDLE)
	{
		delete(g_KnifeMenu);
		g_KnifeMenu = null;
	}

	if(g_SkinMenu != INVALID_HANDLE)
	{
		delete(g_SkinMenu);
		g_SkinMenu = null;
	}
}

public Action FakeCaseCMD(client, int args)
{
	g_KnifeMenu.Display(client, MENU_TIME_FOREVER);
}

Menu BuildKnifeMenu()
{
	char buffer[128];
	Menu menu = new Menu(Menu_Knife);
	Format(buffer, sizeof(buffer), "%T", "Bayonet", LANG_SERVER);
	menu.AddItem("Bayonet", buffer);
	Format(buffer, sizeof(buffer), "%T", "Butterfly", LANG_SERVER);
	menu.AddItem("Butterfly", buffer);
	Format(buffer, sizeof(buffer), "%T", "Falchion knife", LANG_SERVER);
	menu.AddItem("Falchion knife", buffer);
	Format(buffer, sizeof(buffer), "%T", "Flip knife", LANG_SERVER);
	menu.AddItem("Flip knife", buffer);
	Format(buffer, sizeof(buffer), "%T", "Gut knife", LANG_SERVER);
	menu.AddItem("Gut knife", buffer);
	Format(buffer, sizeof(buffer), "%T", "Huntsman knife", LANG_SERVER);
	menu.AddItem("Huntsman knife", buffer);
	Format(buffer, sizeof(buffer), "%T", "Karambit", LANG_SERVER);
	menu.AddItem("Karambit", buffer);
	Format(buffer, sizeof(buffer), "%T", "M9 Bayonet", LANG_SERVER);
	menu.AddItem("M9 Bayonet", buffer);
	Format(buffer, sizeof(buffer), "%T", "Shadow Daggers", LANG_SERVER);
	menu.AddItem("Shadow Daggers", buffer);
	Format(buffer, sizeof(buffer), "%T", "Select knife:", LANG_SERVER);
	menu.SetTitle(buffer);
	return menu;
}

public int Menu_Knife(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char knife_id[32];
		menu.GetItem(param2, knife_id, sizeof(knife_id));

		SetArrayString(SelectedKnife, param1, knife_id);
		g_SkinMenu.Display(param1, MENU_TIME_FOREVER);
	}
}

Menu BuildSkinMenu()
{
	char buffer[128];
	Menu menu = new Menu(Menu_Skin);
	Format(buffer, sizeof(buffer), "%T", "Blue Steel", LANG_SERVER);
	menu.AddItem("Blue Steel", buffer);
	Format(buffer, sizeof(buffer), "%T", "Boreal Forest", LANG_SERVER);
	menu.AddItem("Boreal Forest", buffer);
	Format(buffer, sizeof(buffer), "%T", "Case Hardened", LANG_SERVER);
	menu.AddItem("Case Hardened", buffer);
	Format(buffer, sizeof(buffer), "%T", "Damascus Steel", LANG_SERVER);
	menu.AddItem("Damascus Steel", buffer);
	Format(buffer, sizeof(buffer), "%T", "Doppler", LANG_SERVER);
	menu.AddItem("Doppler", buffer);
	Format(buffer, sizeof(buffer), "%T", "Fade", LANG_SERVER);
	menu.AddItem("Fade", buffer);
	Format(buffer, sizeof(buffer), "%T", "Forest DDPAT", LANG_SERVER);
	menu.AddItem("Forest DDPAT", buffer);
	Format(buffer, sizeof(buffer), "%T", "Marble Fade", LANG_SERVER);
	menu.AddItem("Marble Fade", buffer);
	Format(buffer, sizeof(buffer), "%T", "Safari Mesh", LANG_SERVER);
	menu.AddItem("Safari Mesh", buffer);
	Format(buffer, sizeof(buffer), "%T", "Scorched", LANG_SERVER);
	menu.AddItem("Scorched", buffer);
	Format(buffer, sizeof(buffer), "%T", "Slaughter", LANG_SERVER);
	menu.AddItem("Slaughter", buffer);
	Format(buffer, sizeof(buffer), "%T", "Stained", LANG_SERVER);
	menu.AddItem("Stained", buffer);
	Format(buffer, sizeof(buffer), "%T", "Tiger Tooth", LANG_SERVER);
	menu.AddItem("Tiger Tooth", buffer);
	Format(buffer, sizeof(buffer), "%T", "Urban Masked", LANG_SERVER);
	menu.AddItem("Urban Masked", buffer);
	Format(buffer, sizeof(buffer), "%T", "Select knife skin:", LANG_SERVER);
	menu.SetTitle(buffer);
	return menu;
}

public int Menu_Skin(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char skin_id[32];
		menu.GetItem(param2, skin_id, sizeof(skin_id));

		char knife[32];
		GetArrayString(SelectedKnife, param1, knife, sizeof(knife));

		char name[32];
		GetClientName(param1, name, sizeof(name));

		char buffer[128]; char buffer1[128]; char buffer2[128]; char buffer3[128];

		for(new i = 1; i < MAXPLAYERS; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
			{
				Format(buffer1, sizeof(buffer1), "%T", knife, i);
				Format(buffer2, sizeof(buffer2), "%T", skin_id, i);
				Format(buffer, sizeof(buffer), "★ %s | %s", buffer1, buffer2);
				Format(buffer3, sizeof(buffer3), "%T", "Chat message", i);
				CPrintToChat(i, " %s{default} %s \x07%s", name, buffer3, buffer);
			}
		}
	}
}