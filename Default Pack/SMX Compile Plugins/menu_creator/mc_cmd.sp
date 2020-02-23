public Action:mc_cmd(client, args)
{
	if (args < 1)
		return Plugin_Handled;
	
	decl String:s[128];
	GetCmdArg(1, s, sizeof(s));
	
	if (!strcmp(s, "create")) // mc create menu/panel "name" ["title"]
	{
		if (args != 3 && args != 4)
			return stop(ERROR_SYNTAX);
		
		//
		new menu_type;
		GetCmdArg(2, s, sizeof(s));
		
		if (!strcmp(s, "menu"))
			menu_type = MC_MENU;
		
		else if (!strcmp(s, "panel"))
		{
			menu_type = MC_PANEL;
			g_pos = 0;
			g_panel_item_count = 0;
		}
		else
			return stop("Must be \"menu\" or \"panel\"");
		//
		
		if (GetCmdArg(3, s, sizeof(s)) < 1 || TrimString(s) < 1) return stop("Invalid \"name\"");
		if (FindStringInArray(g_hMenuArray[ma_name], s) > -1) return stop("name \"%s\" already exist", s);
		if (GetTrieString(g_hTrie_alias, s, "", 0)) return stop("You can't, because exist alias with name \"%s\"", s);
		if (KeyReserved(s)) return stop("name \"%s\" reserved (use other name)", s);
		
		PushArrayString	(g_hMenuArray[ma_name ], s);
		
		s[0] = 0;
		if (args == 4 && GetCmdArg(4, s, sizeof(s))) TrimString(s);
		PushArrayString	(g_hMenuArray[ma_title], s);
		
		PushArrayCell	(g_hMenuArray[ma_type ], menu_type);
		PushArrayCell	(g_hMenuArray[ma_item ], 0);
		
		s[0] = 0;
		PushArrayString	(g_hMenuArray[ma_back ], s);
		PushArrayString	(g_hMenuArray[ma_back_cmds], s);
		
		PushArrayCell	(g_hMenuArray[ma_exit ], 1);
		
		g_MenuCount++;
	}
	else if (!strcmp(s, "cmd")) // mc cmd "cmd" ["admin flag"]
	{
		if (args != 2 && args != 3) return stop(ERROR_SYNTAX);
		if (!g_MenuCount) return stop(ERROR_NOMENU);
		
		new bool:ok = false;
		
		if (args == 3)
		{
			GetCmdArg(3, s, sizeof(s));
			if (TrimString(s))
			{
				decl AdminFlag:flag;
				if (FindFlagByChar(s[0], flag))
				{
					GetCmdArg(2, s, sizeof(s));
					if (TrimString(s))
					{
						if (CommandExists(s)) return stop("cmd \"%s\" already exist", s);
						RegAdminCmd(s, cmd_CallBack, FlagToBit(flag));
						ok = true;
					}
				}
				else
					return stop("Invalid flag \"%c\"", s[0]);
			}
		}
		else
		{
			GetCmdArg(2, s, sizeof(s));
			if (TrimString(s))
			{
				if (CommandExists(s)) return stop("cmd \"%s\" already exist", s);
				RegConsoleCmd(s, cmd_CallBack);
				ok = true;
			}
		}
		
		if (!ok)
			return stop();
		
		decl String:name[name_LENGTH];
		GetArrayString(g_hMenuArray[ma_name], (g_MenuCount-1), name, name_LENGTH);
		SetTrieString(g_hTrie_cmd, s, name, true); // "cmd" -> "name"
	}
	else if (!strcmp(s, "back")) // mc back "name" ["cmds"]
	{
		if (args != 2 && args != 3) return stop(ERROR_SYNTAX);
		if (!g_MenuCount) return stop(ERROR_NOMENU);
		GetCmdArg(2, s, sizeof(s));
		if (TrimString(s))
		{
			decl String:name[name_LENGTH];
			GetArrayString(g_hMenuArray[ma_name], (g_MenuCount-1), name, name_LENGTH);
			if (!strcmp(name, s)) return stop("You can not return to the same menu");
			SetArrayString(g_hMenuArray[ma_back], (g_MenuCount-1), s);
		}
		if (args > 2)
		{
			decl String:cmds[cmds_LENGTH];
			if (GetCmdArg(3, cmds, sizeof(cmds)) && TrimString(cmds))
				SetArrayString(g_hMenuArray[ma_back_cmds], (g_MenuCount-1), cmds);
		}
	}
	else if (!strcmp(s, "no_exit")) // mc no_exit
	{
		if (!g_MenuCount) return stop(ERROR_NOMENU);
		SetArrayCell(g_hMenuArray[ma_exit], (g_MenuCount-1), 0);
	}
	else if (!strcmp(s, "pos")) // mc pos "от 1 до 7"
	{
		if (args != 2) return stop(ERROR_SYNTAX);
		if (!g_MenuCount) return stop(ERROR_NOMENU);
		if (GetArrayCell(g_hMenuArray[ma_type], (g_MenuCount-1)) != MC_PANEL) return stop("\"pos\" only for panel");
		GetCmdArg(2, s, sizeof(s));
		if (s[0] == '{') wS_EditText(client, s, sizeof(s));
		new pos = StringToInt(s);
		if (pos < 1 || pos > 7) return stop("\"pos\" must be 1-7");
		if (pos <= g_panel_item_count || pos < g_pos) return stop("invalid \"pos\"");
		g_pos = pos;
	}
	else if (!strcmp(s, "add"))
	{
		if (!g_MenuCount)
			return stop(ERROR_NOMENU);
		
		decl String:name[name_LENGTH], String:key[key_LENGTH], String:text[text_LENGTH];
		GetArrayString(g_hMenuArray[ma_name], (g_MenuCount-1), name, name_LENGTH);
		
		new item_number = GetArrayCell(g_hMenuArray[ma_item], (g_MenuCount-1)) + 1;
		SetArrayCell(g_hMenuArray[ma_item], (g_MenuCount-1), item_number);
		
		FormatEx(key, key_LENGTH, "%s%d", name, item_number);
		
		new admin_flag_arg;
		GetCmdArg(2, s, sizeof(s));
		
		if (!strcmp(s, "text")) // mc add text "text" ["flag"]
		{
			if (args != 3 && args != 4) return stop(ERROR_SYNTAX);
			admin_flag_arg = 4;
			SetTrieValue(g_hItemTrie[it_type], key, IT_TEXT, true);
			if (GetCmdArg(3, text, text_LENGTH) && text[0]) SetTrieString(g_hItemTrie[it_text], key, text, true);
		}
		else if (!strcmp(s, "item")) // mc add item "" "text" "cmds" ["flag"]
		{
			if (args != 5 && args != 6) return stop(ERROR_SYNTAX);
			admin_flag_arg = 6;
			SetTrieValue(g_hItemTrie[it_type], key, IT_ITEM, true);
			if (GetCmdArg(4, text, text_LENGTH) && text[0]) SetTrieString(g_hItemTrie[it_text], key, text, true);
			
			if (GetArrayCell(g_hMenuArray[ma_type], (g_MenuCount-1)) == MC_PANEL)
			{
				if (++g_panel_item_count > 7) return stop("Limit items in panel: 7");
				if (g_pos) SetTrieValue(g_hItemTrie[it_pos], key, g_pos++, true);
			}
			
			decl String:cmds[cmds_LENGTH];
			
			if (GetCmdArg(3, cmds, cmds_LENGTH) && TrimString(cmds)) SetTrieString(g_hItemTrie[it_info], key, cmds, true);
			if (GetCmdArg(5, cmds, cmds_LENGTH) && TrimString(cmds)) SetTrieString(g_hItemTrie[it_cmds], key, cmds, true);
		}
		else
			return stop("Must be \"text\" or \"menu\"");
		
		if (args == admin_flag_arg && GetCmdArg(admin_flag_arg, s, sizeof(s)) && TrimString(s))
		{
			decl AdminFlag:flag;
			if (FindFlagByChar(s[0], flag))
				SetTrieValue(g_hItemTrie[it_flag], key, FlagToBit(flag), true);
			else
				return stop("Invalid flag \"%c\"", s[0]);
		}
	}
	else if (!strcmp(s, "show"))
	{
		if (args > 2
			&& GetCmdArg(2, s, sizeof(s))
			&& (client = StringToInt(s)) > 0 && client <= MaxClients
			&& GetCmdArg(3, s, sizeof(s)) && TrimString(s))
		{
			if (!strcmp(s, PLAYER_LIST, true))
			{
				g_MyLastTargetId[client] = 0;
				
				if (args == 3) // mc show {client} PLAYER_LIST
				{
					ShowOldPlayerListMenu(client);
					return Plugin_Handled;
				}
				
				if (args != 7) // mc show client PLAYER_LIST title flags BackMenuOrPanel "cmds"
					return Plugin_Handled;
				
				decl String:cmds[cmds_LENGTH];
				if (GetCmdArg(7, cmds, sizeof(cmds)) < 1 || TrimString(cmds) < 1)
					return Plugin_Handled;
				
				new Handle:menu = CreateMenu(PLAYER_LIST_CallBack);
				
				for (new target = 1; target <= MaxClients; target++) g_TargetCanBeInMenu[client][target] = true;
				if (!g_hClientTrie[client][ct_PlayerList]) g_hClientTrie[client][ct_PlayerList] = CreateTrie();
				
				// cmds
				SetTrieString(g_hClientTrie[client][ct_PlayerList], "cmds", cmds, true); // wS_EditText пока не делаем
				
				// back menu/panel
				if (GetCmdArg(6, s, sizeof(s)) && TrimString(s) && strcmp(s, "0") != 0)
				{
					SetTrieString(g_hClientTrie[client][ct_PlayerList], "back", s, true);
					SetMenuExitBackButton(menu, true);
				}
				else
					RemoveFromTrie(g_hClientTrie[client][ct_PlayerList], "back");
				
				// title
				if (GetCmdArg(4, s, sizeof(s)))
				{
					SetTrieString(g_hClientTrie[client][ct_PlayerList], "title", s, true);
					wS_EditText(client, s, sizeof(s));
					SetMenuTitle(menu, "%s\n \n", s);	
				}
				else
					RemoveFromTrie(g_hClientTrie[client][ct_PlayerList], "title");
				
				// flags
				s[0] = 0;
				GetCmdArg(5, s, sizeof(s));
				SetTrieValue(g_hClientTrie[client][ct_PlayerList], "flags", AddPlayersToMenu(client, menu, s), true);
				
				DisplayMenu(menu, client, 0);
			}
			else // mc show <client> "name" ["time"] ["flags"]
			{
				decl String:name[name_LENGTH];
				strcopy(name, sizeof(name), s);
				
				new time = 0;
				if (args > 3 && GetCmdArg(4, s, sizeof(s)) && (time = StringToInt(s)) < 0) time = 0;
				
				
				new flags = 0;
				if (args > 4 && GetCmdArg(5, s, sizeof(s)))
				{
					if (StrContains(s, "no_title") > -1) flags |= MC_FLAG_no_title;
					if (!(flags & MC_FLAG_no_item) && StrContains(s, "no_text") > -1) flags |= MC_FLAG_no_text;
					if (!(flags & MC_FLAG_no_text) && StrContains(s, "no_item") > -1) flags |= MC_FLAG_no_item;
					if (StrContains(s, "no_back" ) > -1) flags |= MC_FLAG_no_back;
					if (StrContains(s, "no_exit" ) > -1) flags |= MC_FLAG_no_exit;
				}
				
				ShowMenuByName(client, name, _, time, flags);
			}
		}
	}
	else if (!strcmp(s, "client_join_cmd")) // mc client_join_cmd "delay" "cmds"
	{
		if (args != 3 || GetCmdArg(3, g_client_join_cmd, sizeof(g_client_join_cmd)) < 1 || TrimString(g_client_join_cmd) < 1) return stop(ERROR_SYNTAX);
		GetCmdArg(2, s, sizeof(s));
		g_JoinCmdDelay = StringToInt(s);
	}
	else if (!strcmp(s, "map_start_cmd")) // mc map_start_cmd "cmds"
	{
		if (args != 2 || GetCmdArg(2, g_map_start_cmd, sizeof(g_map_start_cmd)) < 1 || TrimString(g_map_start_cmd) < 1)
			return stop(ERROR_SYNTAX);
	}
	else if (!strcmp(s, "msg")) // mc msg "console/chat/center" "{client}/all" "text"
	{
		if (args >= 4 && GetCmdArg(2, s, sizeof(s)) && (!strcmp(s, "console") || !strcmp(s, "chat") || !strcmp(s, "center")))
		{
			new msg_type = s[1] == 'o' ? MSG_CONSOLE : (s[1] == 'h' ? MSG_CHAT : MSG_CENTER);
			client = 0;
			if (GetCmdArg(3, s, sizeof(s)) && (!strcmp(s, "all") || ((client = StringToInt(s)) > 0 && client <= MaxClients)))
			{
				decl String:text[text_LENGTH], item;
				text[0] = 0;
				
				if (args == 4)
					GetCmdArg(4, text, sizeof(text));
				else
				{
					GetCmdArgString(text, sizeof(text));
					StripQuotes(text);
					if (client) FormatEx(s, sizeof(s), " %d ", client);
					else FormatEx(s, sizeof(s), " all ", client);
					if ((item = StrContains(text, s, true)) > -1)
						strcopy(text, sizeof(text), text[item+3]);
				}
				
				if (!text[0])
					return Plugin_Handled;
				
				if (client && msg_type == MSG_CONSOLE && (item = FindStringInArray(g_hMenuArray[ma_name], text)) > -1) // it's menu/panel
				{
					new item_count = GetArrayCell(g_hMenuArray[ma_item], item);
					if (item_count > 0)
					{
						decl String:name[name_LENGTH], String:key[key_LENGTH], x;
						strcopy(name, name_LENGTH, text);
						
						new flags = GetUserFlagBits(client);
						
						//
						text[0] = 0;
						if (GetArrayString(g_hMenuArray[ma_title], g_MyLastMenuIndex[client], text, sizeof(text)))
							ShowMsg(client, text, sizeof(text), msg_type);
						//
						
						for (item = 1; item <= item_count; item++)
						{
							FormatEx(key, key_LENGTH, "%s%d", name, item);
							
							if (GetTrieValue(g_hItemTrie[it_flag], key, x) && (!(flags & x) && !(flags & ADMFLAG_ROOT)))
								continue;
							
							if (GetTrieString(g_hItemTrie[it_text], key, text, sizeof(text)))
								ShowMsg(client, text, sizeof(text), msg_type);
						}
					}
				}
				else if (client)
					ShowMsg(client, text, sizeof(text), msg_type);
				
				else // for all
				{
					decl String:text_copy[text_LENGTH];
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsClientInGame(i) && !IsFakeClient(i))
						{
							strcopy(text_copy, sizeof(text_copy), text);
							wS_EditText(i, text_copy, sizeof(text_copy));
							switch (msg_type)
							{
								case MSG_CONSOLE: PrintToConsole (i, text);
								case MSG_CHAT	: wS_ChatMsg(i, text, sizeof(text));
								case MSG_CENTER	: PrintCenterText(i, text);
							}
						}
					}
				}
			}
		}
	}				// {darkred}   \x02 spec
	else if (!strcmp(s, "block_item") || !strcmp(s, "hide_item")) // mc block_item {client} [name - заблокировать все опции в menu/panel, name3 - одну, all - все. Если не указать, то блокируется последняя.]
	{
		new ClientTrie:ct_ = s[0] == 'b' ? ct_ItemBlocked : ct_ItemHidden;
		if ((args == 2 || args == 3) && g_MenuCount && GetCmdArg(2, s, sizeof(s)) && (client = StringToInt(s)) > 0 && client <= MaxClients)
		{
			if (!g_hClientTrie[client][ct_])
				g_hClientTrie[client][ct_] = CreateTrie();
			
			if (args == 2)
			{
				if (g_sMyLastKey[client][0])
					SetTrieValue(g_hClientTrie[client][ct_], g_sMyLastKey[client], 1, true);
			}
			else if (GetCmdArg(3, s, sizeof(s)) && TrimString(s))
			{
				new item_count, x;
				new item = FindStringInArray(g_hMenuArray[ma_name], s);
				if (item > -1) // it's menu/panel
				{
					if ((item_count = GetArrayCell(g_hMenuArray[ma_item], item)) > 0)
					{
						decl String:key[key_LENGTH];
						for (item = 1; item <= item_count; item++)
						{
							FormatEx(key, key_LENGTH, "%s%d", s, item);
							if (ct_ != ct_ItemBlocked || (GetTrieValue(g_hItemTrie[it_type], key, x) && x == IT_ITEM))
								SetTrieValue(g_hClientTrie[client][ct_], key, 1, true);
						}
					}
				}
				else if (!strcmp(s, "all", false))
				{
					decl String:name[name_LENGTH], String:key[key_LENGTH];
					for (new i = 0; i < g_MenuCount; i++)
					{
						if ((item_count = GetArrayCell(g_hMenuArray[ma_item], i)) > 0)
						{
							GetArrayString(g_hMenuArray[ma_name], i, name, name_LENGTH);
							for (item = 1; item <= item_count; item++)
							{
								FormatEx(key, key_LENGTH, "%s%d", name, item);
								if (ct_ != ct_ItemBlocked || (GetTrieValue(g_hItemTrie[it_type], key, x) && x == IT_ITEM))
									SetTrieValue(g_hClientTrie[client][ct_], key, 1, true);
							}
						}
					}
				}
				else
					SetTrieValue(g_hClientTrie[client][ct_], s, 1, true);
			}
		}
	}
	else if (!strcmp(s, "unblock_item") || !strcmp(s, "unhide_item")) // mc unblock_item {client} "name - разблокировать все опции в menu/panel | name3 - одну | all - все опции во всех menu/panel"
	{
		new ClientTrie:ct_ = s[2] == 'b' ? ct_ItemBlocked : ct_ItemHidden;
		if (args == 3
			&& GetCmdArg(2, s, sizeof(s))
			&& (client = StringToInt(s)) > 0
			&& client <= MaxClients
			&& g_hClientTrie[client][ct_]
			&& GetTrieSize(g_hClientTrie[client][ct_])
			&& GetCmdArg(3, s, sizeof(s))
			&& TrimString(s))
		{
			new item = FindStringInArray(g_hMenuArray[ma_name], s);
			if (item > -1) // it's menu/panel
			{
				new item_count = GetArrayCell(g_hMenuArray[ma_item], item);
				if (item_count > 0)
				{
					decl String:key[key_LENGTH];
					for (item = 1; item <= item_count; item++)
					{
						FormatEx(key, key_LENGTH, "%s%d", s, item);
						RemoveFromTrie(g_hClientTrie[client][ct_], key);
					}
				}
			}
			else if (!strcmp(s, "all", false))
				ClearTrie(g_hClientTrie[client][ct_]);
			else
				RemoveFromTrie(g_hClientTrie[client][ct_], s);
		}
	}
	else if (!strcmp(s, "alias")) // mc alias "key" "info"
	{
		if (args != 3 || GetCmdArg(2, s, sizeof(s)) < 1 || TrimString(s) < 1) return stop(ERROR_SYNTAX);
		if (FindStringInArray(g_hMenuArray[ma_name], s) > -1) return stop("You can't, because exist menu/panel with name \"%s\"", s);
		if (KeyReserved(s)) return stop("key \"%s\" reserved (use other key)", s);
		decl String:info[cmds_LENGTH];
		if (GetCmdArg(3, info, sizeof(info)) < 1 || TrimString(info) < 1) return stop(ERROR_SYNTAX);
		if (!SetTrieString(g_hTrie_alias, s, info, false)) return stop("alias \"%s\" already exist", s);
	}
	else if (!strcmp(s, "force_cmd")) // mc force_cmd {client} "cmds"
	{
		if (args == 3 && GetCmdArg(2, s, sizeof(s)) && (client = StringToInt(s)) > 0 && client <= MaxClients)
		{
			decl String:cmds[cmds_LENGTH];
			if (GetCmdArg(3, cmds, sizeof(cmds)) && TrimString(cmds))
				FakeClientCommand(client, cmds);
		}
	}
	else if (!strcmp(s, "return_target")) // mc return_target {client} {Tclient}
	{
		decl target;
		if (args == 3
			&& GetCmdArg(2, s, sizeof(s))
			&& (client = StringToInt(s)) > 0
			&& client <= MaxClients
			&& GetCmdArg(3, s, sizeof(s))
			&& (target = StringToInt(s)) > 0
			&& target <= MaxClients)
		{
			g_TargetCanBeInMenu[client][target] = true;
		}
	}
	else if (!strcmp(s, "http") || !strcmp(s, "https")) // mc <http/https> <client> "site.ru/..."
	{
		decl String:sClient[8];
		if (args == 3 && GetCmdArg(2, sClient, sizeof(sClient)) && (client = StringToInt(sClient)) > 0 && client <= MaxClients)
		{
			decl String:t[cmds_LENGTH];
			if (GetCmdArg(3, t, sizeof(t)) && TrimString(t))
			{
				Format(t, sizeof(t), "%s://%s", s, t);
				wS_EditText(client, t, sizeof(t));
				ShowMOTDPanel(client, "", t, MOTDPANEL_TYPE_URL);
			}
		}
	}
	else if (!strcmp(s, "reload")) // mc reload
	{
		decl String:t[256];
		t[0] = 0;
		GetPluginFilename(GetMyHandle(), t, sizeof(t));
		if (t[0]) ServerCommand("sm plugins reload \"%s\"", t);
	}
	return Plugin_Handled;
}