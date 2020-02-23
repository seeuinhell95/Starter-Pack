stock wS_EditText(client, String:text[], const text_size)
{
	if (!text[0])
		return;
	
	new i = FindCharInString(text, '#', false);
	if (i < 0 || text[i+1] == '#')
	{
		wS_Replace(client, text, text_size);
		return;
	}
	
	decl String:s[text_size];
	if (!strcopy(s, text_size, text[i+1]) || (i = FindCharInString(s, '#', false)) < 0 || s[i+1] == '#')
	{
		wS_Replace(client, text, text_size);
		return;
	}
	
	s[i] = 0;
	
	decl String:phrase[phrase_LENGTH];
	strcopy(phrase, sizeof(phrase), s);
	
	//
	
	static String:A[MAX_ARGS][64];
	new args = 0, end_i;
	
	for (new arg = 1, char; arg <= MAX_ARGS; arg++)
	{
		if (arg > 10)
			break;
		
		FormatEx(s, text_size, "arg%d", arg);
		if ((i = StrContains(text, s, true)) < 0)
			break;
		
		i += arg < 10 ? 4 : 5;
		
		if (text[i] != '{' || (end_i = FindCharInString(text[i], '}', false)) < 0)
			break;
		
		if (text[i+1] == '!') // обычный текст
		{
			text[i+end_i] = 0;
			strcopy(A[args++], sizeof(A[]), text[i+2]);
			text[i+end_i] = '}';
		}
		else // Аргумент типа {map}, который нужно заменить на нужное значение.
		{
			char = text[i+end_i+1];
			text[i+end_i+1] = 0;
			strcopy(A[args], sizeof(A[]), text[i]);
			text[i+end_i+1] = char;
			wS_Replace(client, A[args], sizeof(A[]));
			args++;
		}
	}
	
	if (!args)
	{
		wS_Replace(client, text, text_size);
		FormatEx(s, text_size, "%T", phrase, client);
	}
	else
	{
		s[0] = 0;
		
		switch (args)
		{
			case 1 : FormatEx(s, text_size, "%T", phrase, client, A[0]);
			case 2 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1]);
			case 3 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2]);
			case 4 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3]);
			case 5 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4]);
			case 6 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4], A[5]);
			case 7 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4], A[5], A[6]);
			case 8 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7]);
			case 9 : FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8]);
			case 10: FormatEx(s, text_size, "%T", phrase, client, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9]);
		}
		
		decl String:sArg[12];
		FormatEx(sArg, sizeof(sArg), "arg%d", args);
		
		if ((end_i = StrContains(text, sArg, true)) > -1 && (i = FindCharInString(text[end_i], '}', false)) > -1)
		{
			if (text[end_i+i+1]) // после аргументов есть какой-то текст
			{
				decl String:text_end[text_size];
				strcopy(text_end, text_size, text[end_i+i+1]);
				wS_Replace(client, text_end, text_size);
				
				i = args == 1 ? end_i : StrContains(text, "arg1", true);
				if (i > -1)
				{
					while (text[i])
						text[i++] = 0;
				}
				
				wS_Replace(client, text, text_size);
				Format(phrase, sizeof(phrase), "#%s#", phrase);
				ReplaceString(text, text_size, phrase, s, true);
				Format(text, text_size, "%s%s", text, text_end);
				
				return;
			}
			else // очищаем весь текст, связанный с аргументами arg{}
			{
				i = args == 1 ? end_i : StrContains(text, "arg1", true);
				if (i > -1)
				{
					while (text[i])
						text[i++] = 0;
				}
			}
		}
	}
	
	wS_Replace(client, text, text_size);
	Format(phrase, sizeof(phrase), "#%s#", phrase);
	ReplaceString(text, text_size, phrase, s, true);
}

static wS_Replace(client, String:text[], text_size)
{
	decl String:s[text_size], String:phrase[phrase_LENGTH], i, end_i, x;
	
	/////
	// алиасы и "INFO_name"
	
	static Handle:hAr_phrase = INVALID_HANDLE;
	static Handle:hAr_info	 = INVALID_HANDLE;
	
	if (hAr_phrase)
	{
		ClearArray(hAr_phrase);
		ClearArray(hAr_info);
	}
	else
	{
		hAr_phrase = CreateArray(phrase_LENGTH);
		hAr_info   = CreateArray(cmds_LENGTH);
	}
	
	new symbols = strlen(text);
	new bool:bNeedReplace = false;
	
	for (i = 0; i < symbols; i++)
	{
		if (!text[i]) break;
		if (text[i] != '{') continue;
		
		for (end_i = i+1; end_i < symbols; end_i++)
		{
			if (!text[end_i] || text[end_i] == '{')
				break;
			
			if (text[end_i] == '}')
			{
				text[end_i] = 0;
				s[0] = 0;
				bNeedReplace = true;
				
				if (!GetTrieString(g_hTrie_alias, text[i+1], s, text_size) || !s[0])
				{
					if (g_hClientTrie[client][ct_ItemInfo] && StrContains(text[i+1], "INFO_", true) == 0)
						GetTrieString(g_hClientTrie[client][ct_ItemInfo], text[i+6], s, text_size);
					
					else if (StrContains(text[i+1], "RANDOM:", true) == 0 && (x = FindCharInString(text[i+8], '-', false)) > -1) // "{RANDOM:x-6}"
					{
						new max = text[i+8+x+1] == 'x' ? (g_LastRandomNumber + 1) : StringToInt(text[i+8+x+1]);
						text[i+8+x] = 0;
						new min = text[i+8	] == 'x' ? (g_LastRandomNumber + 1) : StringToInt(text[i+8]);
						text[i+8+x] = '-';
						if (max > min)
							IntToString((g_LastRandomNumber = GetRandomInt(min, max)), s, text_size);
					}
				}
				
				text[end_i] = '}';
				
				if (s[0])
				{
					x = text[end_i+1];
					text[end_i+1] = 0;
					strcopy(phrase, sizeof(phrase), text[i]);
					text[end_i+1] = x;
					
					if (phrase[0] == '{' && phrase[strlen(phrase)-1] == '}')
					{
						PushArrayString(hAr_phrase, phrase);
						PushArrayString(hAr_info, s);
					}
				}
				
				i = end_i;
				break;
			}
		}
	}
	
	if ((i = GetArraySize(hAr_phrase)))
	{
		while (--i > -1)
		{
			GetArrayString(hAr_phrase, i, phrase, sizeof(phrase));
			GetArrayString(hAr_info, i, s, text_size);
			ReplaceString(text, text_size, phrase, s, true);
		}
	}
	
	if (!bNeedReplace)
		return;
	
	/////
	
	if (client)
	{
		if (StrContains(text, "{client}", true) > -1)
		{
			IntToString(client, s, text_size);
			ReplaceString(text, text_size, "{client}", s, true);
		}
		
		if (StrContains(text, "{userid}", true) > -1)
		{
			IntToString(GetClientUserId(client), s, text_size);
			ReplaceString(text, text_size, "{userid}", s, true);
		}
		
		if (StrContains(text, "{ip}", true) > -1 && GetClientIP(client, s, text_size, true))
			ReplaceString(text, text_size, "{ip}", s, true);
		
		if (StrContains(text, "{name}", true) > -1 && GetClientName(client, s, text_size))
			ReplaceString(text, text_size, "{name}", s, true);
		
		if (StrContains(text, "{steam_s}", true) > -1 && GetClientAuthId(client, AuthId_Steam2	 , s, text_size, true))
			ReplaceString(text, text_size, "{steam_s}", s, true);
		
		if (StrContains(text, "{steam_u}", true) > -1 && GetClientAuthId(client, AuthId_Steam3	 , s, text_size, true))
			ReplaceString(text, text_size, "{steam_u}", s, true);
		
		if (StrContains(text, "{steam_c}", true) > -1 && GetClientAuthId(client, AuthId_SteamID64, s, text_size, true))
			ReplaceString(text, text_size, "{steam_c}", s, true);
		
		/////
		
		new target = GetClientOfUserId(g_MyLastTargetId[client]);
		if (target > 0)
		{
			if (StrContains(text, "{Tclient}", true) > -1)
			{
				IntToString(target, s, text_size);
				ReplaceString(text, text_size, "{Tclient}", s, true);
			}
			
			if (StrContains(text, "{Tuserid}", true) > -1)
			{
				IntToString(g_MyLastTargetId[client], s, text_size);
				ReplaceString(text, text_size, "{Tuserid}", s, true);
			}
			
			if (StrContains(text, "{Tip}", true) > -1 && GetClientIP(target, s, text_size, true))
				ReplaceString(text, text_size, "{Tip}", s, true);
			
			if (StrContains(text, "{Tname}", true) > -1 && GetClientName(target, s, text_size))
				ReplaceString(text, text_size, "{Tname}", s, true);
			
			if (StrContains(text, "{Tsteam_s}", true) > -1 && GetClientAuthId(target, AuthId_Steam2	  , s, text_size, true))
				ReplaceString(text, text_size, "{Tsteam_s}", s, true);
			
			if (StrContains(text, "{Tsteam_u}", true) > -1 && GetClientAuthId(target, AuthId_Steam3	  , s, text_size, true))
				ReplaceString(text, text_size, "{Tsteam_u}", s, true);
			
			if (StrContains(text, "{Tsteam_c}", true) > -1 && GetClientAuthId(target, AuthId_SteamID64, s, text_size, true))
				ReplaceString(text, text_size, "{Tsteam_c}", s, true);
		}
	}
	
	/////
	
	if (StrContains(text, "{map}", true) > -1)
	{
		GetCurrentMap(s, text_size);
		ReplaceString(text, text_size, "{map}", s, true);
	}
	
	if (StrContains(text, "{timeleft}", true) > -1)
	{
		i = 0;
		GetMapTimeLeft(i);
		if (i > 0) FormatEx(s, text_size, "%02d:%02d", (i / 60 % 60), (i % 60));
		else strcopy(s, text_size, "00:00");
		ReplaceString(text, text_size, "{timeleft}", s, true);
	}
	
	if (StrContains(text, "{time}", true) > -1)
	{
		FormatTime(s, text_size, "%H:%M", GetTime());
		ReplaceString(text, text_size, "{time}", s, true);
	}
	
	if (StrContains(text, "{players}", true) > -1)
	{
		i = 0;
		for (x = 1; x <= MaxClients; x++)
		{
			if (IsClientInGame(x) && !IsFakeClient(x))
				i++;
		}
		IntToString(i, s, text_size);
		ReplaceString(text, text_size, "{players}", s, true);
	}
	
	if (StrContains(text, "{admins}", true) > -1)
	{
		i = 0;
		for (x = 1; x <= MaxClients; x++)
		{
			if (IsClientInGame(x) && !IsFakeClient(x) && (((end_i = GetUserFlagBits(x)) & ADMFLAG_BAN) || (end_i & ADMFLAG_ROOT)))
				i++;
		}
		IntToString(i, s, text_size);
		ReplaceString(text, text_size, "{admins}", s, true);
	}
	
	if (StrContains(text, "{n}", true) > -1) ReplaceString(text, text_size, "{n}", "\n", true);
	if (StrContains(text, "{q}", true) > -1) ReplaceString(text, text_size, "{q}", "\"", true);
	if (StrContains(text, "{r}", true) > -1) ReplaceString(text, text_size, "{r}", "#" , true);
}

stock wS_CloseHandle(&Handle:h)
{
	if (h != INVALID_HANDLE)
	{
		CloseHandle(h);
		h = INVALID_HANDLE;
	}
}

stock ShowMsg(client, String:text[], text_size, msg_type)
{
	if (!text[0]) return;
	wS_EditText(client, text, text_size);
	switch (msg_type)
	{
		case MSG_CONSOLE: PrintToConsole (client, text);
		case MSG_CHAT	: wS_ChatMsg(client, text, text_size);
		case MSG_CENTER	: PrintCenterText(client, text);
	}
}

stock wS_ChatMsg(client, String:text[], text_size)
{
	if (FindCharInString(text, '{', false) > -1)
	{
		ReplaceString		 (text, text_size, "{default}"		, "\x01", true);
						
		switch (g_Engine)
		{
			case Engine_CSGO:
			{
				ReplaceString(text, text_size, "{lightblue}"	, "\x0B", true);
				ReplaceString(text, text_size, "{darkblue}"		, "\x0C", true);
				ReplaceString(text, text_size, "{purple}"		, "\x0E", true);
				ReplaceString(text, text_size, "{darkred}"		, "\x02", true);
				ReplaceString(text, text_size, "{lightred}"		, "\x07", true);
				ReplaceString(text, text_size, "{gray}"			, "\x08", true);
				ReplaceString(text, text_size, "{orange}"		, "\x09", true);
				ReplaceString(text, text_size, "{pink}"			, "\x03", true);
				ReplaceString(text, text_size, "{yellowgreen}"	, "\x05", true);
				ReplaceString(text, text_size, "{darkgreen}"	, "\x04", true);
				ReplaceString(text, text_size, "{lightgreen}"	, "\x06", true);
			}
			case Engine_CSS:
			{
				ReplaceString(text, text_size, "{lightgreen}"	, "\x03", true);
				ReplaceString(text, text_size, "{green}"		, "\x04", true);
				
				ReplaceString(text, text_size, "{darkgreen}"	, "\x05", true);
				ReplaceString(text, text_size, "{HEX}"			, "\x07", true);
			}
			default:
			{
				ReplaceString(text, text_size, "{lightgreen}"	, "\x03", true);
				ReplaceString(text, text_size, "{green}"		, "\x04", true);
			}
		}
		
		if (StrContains(text, "{team}", true) > -1)
		{
			if (g_Engine == Engine_CSGO)
			{
				switch (GetClientTeam(client))
				{
					case 2	: ReplaceString(text, text_size, "{team}", "\x09", true); // {orange}    \x09 t
					case 3	: ReplaceString(text, text_size, "{team}", "\x0B", true); // {lightblue} \x0B ct
					default : ReplaceString(text, text_size, "{team}", "\x02", true); // {darkred}   \x02 spec
				}
			}
			else
			{
				ReplaceString			   (text, text_size, "{team}", "\x03", true);
				
				new Handle:hMsg = StartMessageOne("SayText2", client);
				if (hMsg)
				{
					BfWriteByte  (hMsg, client);
					BfWriteByte  (hMsg, true);
					BfWriteString(hMsg, text);
					EndMessage();
					return;
				}
			}
		}
	}
	PrintToChat(client, text);
}

stock ShowBackMenu(client, bool:PlayerList = false)
{
	decl String:s[cmds_LENGTH];
	
	if (PlayerList)
	{
		if (g_hClientTrie[client][ct_PlayerList] && GetTrieString(g_hClientTrie[client][ct_PlayerList], "back", s, sizeof(s)))
			ShowMenuByName(client, s, true);
		return;
	}
	
	if (GetArrayString(g_hMenuArray[ma_back_cmds], g_MyLastMenuIndex[client], s, sizeof(s)) && s[0])
	{
		wS_EditText(client, s, sizeof(s));
		ServerCommand(s);
		ServerExecute();
	}
	
	if (GetArrayString(g_hMenuArray[ma_back], g_MyLastMenuIndex[client], s, sizeof(s)) && s[0])
		ShowMenuByName(client, s, true);
}

stock ShowOldPlayerListMenu(client)
{
	if (!g_hClientTrie[client][ct_PlayerList])
		return;
	
	new Handle:menu = CreateMenu(PLAYER_LIST_CallBack);
	decl String:s[title_LENGTH];
	
	if (GetTrieString(g_hClientTrie[client][ct_PlayerList], "back", s, sizeof(s)))
		SetMenuExitBackButton(menu, true);
	
	if (GetTrieString(g_hClientTrie[client][ct_PlayerList], "title", s, sizeof(s)))
	{
		wS_EditText(client, s, sizeof(s));
		SetMenuTitle(menu, "%s\n \n", s);	
	}
	
	new x = 0;
	GetTrieValue(g_hClientTrie[client][ct_PlayerList], "flags", x);
	AddPlayersToMenu(client, menu, "", x);
	
	x = 0;
	GetTrieValue(g_hClientTrie[client][ct_PlayerList], "pos", x);
	DisplayMenuAtItem(menu, client, x, 0);
}

#define no_t		(1 << 0)
#define no_ct		(1 << 1)
#define no_spec		(1 << 2)
#define no_bot		(1 << 3)
#define no_human	(1 << 4)
#define no_admin	(1 << 5)
#define no_user		(1 << 6)
#define no_self		(1 << 7)
#define no_alive	(1 << 8)
#define no_dead		(1 << 9)
#define no_immunity	(1 << 10)
#define no_select	(1 << 11)

stock AddPlayersToMenu(client, Handle:menu, const String:sFlags[], flags = 0)
{
	decl i;
	
	if (!flags && sFlags[0] && strcmp(sFlags, "0") != 0 && strcmp(sFlags, "no_flags") != 0)
	{
		decl String:b[12][64];
		if ((i = ExplodeString(sFlags, "|", b, sizeof(b), sizeof(b[]))) > 0)
		{
			while (--i > -1)
			{
				if (!TrimString(b[i]))
					continue;
				
				if (!strcmp(b[i], "no_t"))
				{
					if (!(flags & no_ct) || !(flags & no_spec))
						flags |= no_t;
				}	
				else if (!strcmp(b[i], "no_ct"))
				{
					if (!(flags & no_t) || !(flags & no_spec))
						flags |= no_ct;
				}	
				else if (!strcmp(b[i], "no_spec"))
				{
					if (!(flags & no_t) || !(flags & no_ct))
						flags |= no_spec;
				}
				else if (!strcmp(b[i], "no_bot"))
				{
					if (!(flags & no_human))
						flags |= no_bot;
				}
				else if (!strcmp(b[i], "no_human"))
				{
					if (!(flags & no_bot))
						flags |= no_human;
				}
				else if (!strcmp(b[i], "no_admin"))
				{
					if (!(flags & no_user))
						flags |= no_admin;
				}
				else if (!strcmp(b[i], "no_user"))
				{
					if (!(flags & no_admin))
						flags |= no_user;
				}
				else if (!strcmp(b[i], "no_self"))
					flags |= no_self;
				else if (!strcmp(b[i], "no_alive"))
				{
					if (!(flags & no_dead))
						flags |= no_alive;
				}
				else if (!strcmp(b[i], "no_dead"))
				{
					if (!(flags & no_alive))
						flags |= no_dead;
				}
				else if (!strcmp(b[i], "no_immunity"))
					flags |= no_immunity;
				else if (!strcmp(b[i], "no_select"))
					flags |= no_select;
			}
		}
	}
	
	decl String:sId[16], String:sNick[MAX_NAME_LENGTH], x;
	sId[0] = 0;
	
	if (flags > 0)
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (!g_TargetCanBeInMenu[client][i] || !IsClientInGame(i))
				continue;
			
			if (i == client)
			{
				if (flags & no_self)
					continue;
			}
			else if (!(flags & no_immunity) && !CanUserTarget(client, i))
				continue;
			
			x = 1;
			switch (GetClientTeam(i))
			{
				case 2:
				{
					if (flags & no_t	) x = 0;
				}
				case 3:
				{
					if (flags & no_ct	) x = 0;
				}
				default:
				{
					if (flags & no_spec	) x = 0;
				}
			}
			if (!x)
				continue;
			
			if ((flags & no_bot && IsFakeClient(i)) || (flags & no_human && !IsFakeClient(i)))
				continue;
			
			x = GetUserFlagBits(i);
			if ((flags & no_admin && (x & ADMFLAG_BAN || x & ADMFLAG_ROOT)) || (flags & no_user && !(x & ADMFLAG_BAN) && !(x & ADMFLAG_ROOT)))
				continue;
			
			if ((flags & no_alive && IsPlayerAlive(i)) || (flags & no_dead && !IsPlayerAlive(i)))
				continue;
			
			IntToString(GetClientUserId(i), sId, sizeof(sId));
			sNick[0] = 0;
			GetClientName(i, sNick, sizeof(sNick));
			AddMenuItem(menu, sId, sNick, (flags & no_select) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}
	}
	else
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (g_TargetCanBeInMenu[client][i] && IsClientInGame(i) && (i == client || CanUserTarget(client, i)))
			{
				IntToString(GetClientUserId(i), sId, sizeof(sId));
				sNick[0] = 0;
				GetClientName(i, sNick, sizeof(sNick));
				AddMenuItem(menu, sId, sNick, ITEMDRAW_DEFAULT);
			}
		}
	}
	
	if (!sId[0])
	{
		decl String:s[64];
		FormatEx(s, sizeof(s), "%T", "NoTarget", client);
		AddMenuItem(menu, "", s, ITEMDRAW_DISABLED);
	}
	
	return flags ? flags : -1;
}

stock bool:KeyReserved(const String:s[])
{
	if (!strcmp(s, "show")) 		return true;
	if (!strcmp(s, "msg")) 			return true;
	if (!strcmp(s, "block_item")) 	return true;
	if (!strcmp(s, "unblock_item"))	return true;
	if (!strcmp(s, "create")) 		return true;
	if (!strcmp(s, "cmd")) 			return true;
	if (!strcmp(s, "back")) 		return true;
	if (!strcmp(s, "noexit")) 		return true;
	if (!strcmp(s, "pos")) 			return true;
	if (!strcmp(s, "add")) 			return true;
	if (!strcmp(s, "alias")) 		return true;
	if (!strcmp(s, "PLAYER_LIST")) 	return true;
	if (!strcmp(s, "client")) 		return true;
	if (!strcmp(s, "userid")) 		return true;
	if (!strcmp(s, "ip")) 			return true;
	if (!strcmp(s, "name"))			return true;
	if (!strcmp(s, "steam_s")) 		return true;
	if (!strcmp(s, "steam_u")) 		return true;
	if (!strcmp(s, "steam_c")) 		return true;
	if (!strcmp(s, "Tclient")) 		return true;
	if (!strcmp(s, "Tuserid"))		return true;
	if (!strcmp(s, "Tip"))			return true;
	if (!strcmp(s, "Tname"))		return true;
	if (!strcmp(s, "Tsteam_s"))		return true;
	if (!strcmp(s, "Tsteam_u"))		return true;
	if (!strcmp(s, "Tsteam_c"))		return true;
	if (!strcmp(s, "map"))			return true;
	if (!strcmp(s, "timeleft"))		return true;
	if (!strcmp(s, "time"))			return true;
	if (!strcmp(s, "players"))		return true;
	if (!strcmp(s, "admins"))		return true;
	if (!strcmp(s, "q"))			return true;
	if (!strcmp(s, "r"))			return true;
	if (!strcmp(s, "n"))			return true;
	if (!strcmp(s, "team"))			return true;
	if (!strcmp(s, "lightblue"))	return true;
	if (!strcmp(s, "darkblue"))		return true;
	if (!strcmp(s, "darkred"))		return true;
	if (!strcmp(s, "lightred"))		return true;
	if (!strcmp(s, "gray"))			return true;
	if (!strcmp(s, "orange"))		return true;
	if (!strcmp(s, "pink"))			return true;
	if (!strcmp(s, "yellowgreen"))	return true;
	if (!strcmp(s, "darkgreen"))	return true;
	if (!strcmp(s, "lightgreen"))	return true;
	if (!strcmp(s, "green"))		return true;
	return false;
}

stock Action:stop(const String:error[] = "", any:...)
{
	decl String:s[256];
	if (error[0])
	{
		VFormat(s, sizeof(s), error, 2);
		LogError(s);
	}
	GetCmdArgString(s, sizeof(s));
	if (TrimString(s) && StripQuotes(s)) TrimString(s);
	SetFailState("\"mc %s\"", s);
	return Plugin_Handled;
}