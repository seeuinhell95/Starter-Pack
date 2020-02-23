public Action:cmd_CallBack(client, args)
{
	decl String:cmd[64], String:name[name_LENGTH];
	GetCmdArg(0, cmd, sizeof(cmd));
	if (GetTrieString(g_hTrie_cmd, cmd, name, name_LENGTH))
	{
		g_MyLastTargetId[client] = 0;
		g_sMyLastKey[client][0]  = 0;
		ShowMenuByName(client, name);
	}
	return Plugin_Handled;
}

stock ShowMenuByName(client, const String:name[], bool:bShowLastPage = false, time = 0, MC_flags = 0)
{
	if (!strcmp(name, PLAYER_LIST))
	{
		ShowOldPlayerListMenu(client);
		return;
	}
	
	new item = FindStringInArray(g_hMenuArray[ma_name], name);
	if (item < 0)
		return;
	
	new item_count = GetArrayCell(g_hMenuArray[ma_item], item);
	if (item_count < 1)
		return;
	
	g_MyLastMenuIndex[client] = item;
	decl String:key[key_LENGTH], String:text[text_LENGTH], x;
	
	new menu_type = GetArrayCell(g_hMenuArray[ma_type], g_MyLastMenuIndex[client]);
	new Handle:menu = INVALID_HANDLE;
	new flags = GetUserFlagBits(client);
	
	for (item = 1; item <= item_count; item++)
	{
		FormatEx(key, key_LENGTH, "%s%d", name, item);
		
		if (GetTrieValue(g_hItemTrie[it_flag], key, x) && (!(flags & x) && !(flags & ADMFLAG_ROOT)))
			continue;
		
		if (g_hClientTrie[client][ct_ItemHidden] && GetTrieValue(g_hClientTrie[client][ct_ItemHidden], key, x))
			continue;
		
		if (!GetTrieValue(g_hItemTrie[it_type], key, x))
			continue; // wtf
		
		// title
		if (!(MC_flags & MC_FLAG_no_title) && GetArrayString(g_hMenuArray[ma_title], g_MyLastMenuIndex[client], text, sizeof(text)) && text[0])
		{
			if (!menu) menu = menu_type == MC_MENU ? CreateMenu(menu_CallBack) : CreatePanel();
			wS_EditText(client, text, sizeof(text));
			
			if (menu_type == MC_MENU)
				SetMenuTitle(menu, "%s\n \n", text);
			else
			{
				Format(text, sizeof(text), "%s\n \n", text);
				SetPanelTitle(menu, text);
			}
		}
		
		if (x == IT_TEXT && !(MC_flags & MC_FLAG_no_text))
		{
			text[0] = 0;
			if (GetTrieString(g_hItemTrie[it_text], key, text, sizeof(text)))
				wS_EditText(client, text, sizeof(text));
			
			if (menu_type == MC_MENU)
			{
				if (!menu) menu = CreateMenu(menu_CallBack);
				AddMenuItem(menu, "", text, ITEMDRAW_DISABLED);
			}
			else
			{
				if (!menu) menu = CreatePanel();
				DrawPanelText(menu, text);
			}
		}
		else if (x == IT_ITEM && !(MC_flags & MC_FLAG_no_item))
		{
			text[0] = 0;
			if (GetTrieString(g_hItemTrie[it_text], key, text, sizeof(text)))
				wS_EditText(client, text, sizeof(text));
			
			new ITEMDRAW_ = (GetTrieString(g_hItemTrie[it_cmds], key, "", 0) && (!g_hClientTrie[client][ct_ItemBlocked] || !GetTrieValue(g_hClientTrie[client][ct_ItemBlocked], key, x))) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
			if (menu_type == MC_MENU)
			{
				if (!menu) menu = CreateMenu(menu_CallBack);
				AddMenuItem(menu, key, text, ITEMDRAW_);
			}
			else
			{
				if (!menu) menu = CreatePanel();
				if (GetTrieValue(g_hItemTrie[it_pos], key, x)) SetPanelCurrentKey(menu, x);
				DrawPanelItem(menu, text, ITEMDRAW_);
			}
		}
	}
	
	if (!menu)
		return;
	
	// back
	x = 0;
	if (!(MC_flags & MC_FLAG_no_back))
	{
		if ((GetArrayString(g_hMenuArray[ma_back_cmds], g_MyLastMenuIndex[client], text, sizeof(text)) && text[0])
			|| (GetArrayString(g_hMenuArray[ma_back], g_MyLastMenuIndex[client], text, sizeof(text)) && text[0] && (!strcmp(text, PLAYER_LIST) || FindStringInArray(g_hMenuArray[ma_name], text) > -1)))
		{
			if (menu_type == MC_MENU)
				SetMenuExitBackButton(menu, true);
			else
			{
				x = 1;
				DrawPanelText(menu, " ");
				SetPanelCurrentKey(menu, PANEL_BACK);
				FormatEx(text, sizeof(text), "%T", "back", client);
				DrawPanelItem(menu, text);
			}
		}
	}
	
	// exit
	if (!(MC_flags & MC_FLAG_no_exit) && GetArrayCell(g_hMenuArray[ma_exit], g_MyLastMenuIndex[client]) == 1)
	{
		if (menu_type == MC_PANEL)
		{
			if (!x) DrawPanelText(menu, " ");
			SetPanelCurrentKey(menu, g_Engine == Engine_CSGO ? 9 : 10);
			FormatEx(text, sizeof(text), "%T", "exit", client);
			DrawPanelItem(menu, text);
		}
	}
	else if (menu_type == MC_MENU)
		SetMenuExitButton(menu, false);
	
	if (menu_type == MC_PANEL)
	{
		SendPanelToClient(menu, client, panel_CallBack, time);
		CloseHandle(menu);
		return;
	}
	
	if (bShowLastPage && g_hClientTrie[client][ct_LastPage] && GetTrieValue(g_hClientTrie[client][ct_LastPage], name, x))
		DisplayMenuAtItem(menu, client, x, time);
	else
		DisplayMenu(menu, client, time);
}

public menu_CallBack(Handle:menu, MenuAction:action, client, item)
{
	if (action == MenuAction_End)
		CloseHandle(menu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowBackMenu(client);

	else if (action == MenuAction_Select && GetMenuItem(menu, item, g_sMyLastKey[client], key_LENGTH))
	{
		//
		decl String:name[name_LENGTH];
		GetArrayString(g_hMenuArray[ma_name], g_MyLastMenuIndex[client], name, name_LENGTH);
		if (!g_hClientTrie[client][ct_LastPage]) g_hClientTrie[client][ct_LastPage] = CreateTrie();
		SetTrieValue(g_hClientTrie[client][ct_LastPage], name, GetMenuSelectionPosition(), true);
		//
		
		decl String:cmds[cmds_LENGTH];
		
		if (GetTrieString(g_hItemTrie[it_info], g_sMyLastKey[client], cmds, cmds_LENGTH) && cmds[0])
		{
			if (!g_hClientTrie[client][ct_ItemInfo]) g_hClientTrie[client][ct_ItemInfo] = CreateTrie();
			SetTrieString(g_hClientTrie[client][ct_ItemInfo], name, cmds, true);
		}
		
		if (GetTrieString(g_hItemTrie[it_cmds], g_sMyLastKey[client], cmds, cmds_LENGTH) && cmds[0])
		{
			wS_EditText(client, cmds, cmds_LENGTH);
			ServerCommand(cmds);
		}
	}
}

public panel_CallBack(Handle:panel, MenuAction:action, client, item)
{
	if (action != MenuAction_Select)
		return;
	
	if (item == PANEL_BACK)
	{
		ClientCommand(client, "playgamesound buttons/combine_button7.wav");
		ShowBackMenu(client);
		return;
	}
	
	if (item > PANEL_BACK)
	{
		ClientCommand(client, "playgamesound buttons/combine_button7.wav");
		return;
	}
	
	// Раз panel опция кликабельна, то у неё есть cmds.
	
	new item_count = GetArrayCell(g_hMenuArray[ma_item], g_MyLastMenuIndex[client]);
	if (item_count < 1)
		return; // wtf
	
	ClientCommand(client, "playgamesound buttons/button14.wav");
	new item_number = 1;
	
	decl String:name[name_LENGTH], String:key[key_LENGTH];
	GetArrayString(g_hMenuArray[ma_name], g_MyLastMenuIndex[client], name, name_LENGTH);
	
	if (item_count > 1)
	{
		// 1. Создали panel 2. Добавили text 3. Добавили item
		// Здесь item == 1, но нам нужен key "name_2", т.к. добавленный text это "name_1".
		
		// 1. Создали panel 2. Добавили text 3. Сместили опцию на 5 позицию 4. Добавили item
		// Здесь item == 5, но нам нужен key "name_2", т.к. добавленный text это "name_1".
		
		item_number = -1;
		
		for (new i = 1, valid_item = 0, pos; i <= item_count; i++)
		{
			FormatEx(key, key_LENGTH, "%s%d", name, i);
			
			if (!GetTrieString(g_hItemTrie[it_cmds], key, "", 0))
				continue;
			
			if (++valid_item == item) // valid_item = кликабельная опция с cmds
			{
				item_number = i;
				break;
			}
			
			if (GetTrieValue(g_hItemTrie[it_pos], key, pos) && pos == item) // возможно это она, просто была смещена
			{
				item_number = i;
				break;
			}
		}
		
		if (item_number == -1)
		{
			LogError("item_number == -1 (wtf)");
			return;
		}
	}
	
	FormatEx(g_sMyLastKey[client], key_LENGTH, "%s%d", name, item_number);
	decl String:cmds[cmds_LENGTH];
	
	if (GetTrieString(g_hItemTrie[it_info], g_sMyLastKey[client], cmds, cmds_LENGTH) && cmds[0])
	{
		if (!g_hClientTrie[client][ct_ItemInfo]) g_hClientTrie[client][ct_ItemInfo] = CreateTrie();
		SetTrieString(g_hClientTrie[client][ct_ItemInfo], name, cmds, true);
	}
	
	if (GetTrieString(g_hItemTrie[it_cmds], g_sMyLastKey[client], cmds, cmds_LENGTH) && cmds[0])
	{
		wS_EditText(client, cmds, cmds_LENGTH);
		ServerCommand(cmds);
	}
}

public PLAYER_LIST_CallBack(Handle:menu, MenuAction:action, client, item)
{
	if (action == MenuAction_End)
		CloseHandle(menu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowBackMenu(client, true);

	else if (action == MenuAction_Select)
	{
		if (g_hClientTrie[client][ct_PlayerList])
			SetTrieValue(g_hClientTrie[client][ct_PlayerList], "pos", GetMenuSelectionPosition(), true);
		
		decl String:sId[16];
		if (GetMenuItem(menu, item, sId, sizeof(sId)))
		{
			g_MyLastTargetId[client] = StringToInt(sId);
			new target = GetClientOfUserId(g_MyLastTargetId[client]);
			if (target > 0)
			{
				decl String:cmds[cmds_LENGTH];
				if (g_hClientTrie[client][ct_PlayerList] && GetTrieString(g_hClientTrie[client][ct_PlayerList], "cmds", cmds, sizeof(cmds)))
				{
					g_TargetCanBeInMenu[client][target] = false;
					wS_EditText(client, cmds, sizeof(cmds));
					ServerCommand(cmds);
					return;
				}
			}
			else
				PrintCenterText(client, "%T", "TargetExit", client);
		}
		
		ShowOldPlayerListMenu(client);
	}
}