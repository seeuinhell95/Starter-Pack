void LR_PrintMessage(int iClient, bool bPrefix, bool bNative, const char[] sFormat, any ...)
{
	if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		static char sMessage[2048];

		static const char sColorsBefore[][] =
		{
			"{DEFAULT}",
			"{TEAM}",
			"{GREEN}",
			"{RED}",
			"{LIME}",
			"{LIGHTGREEN}",
			"{LIGHTRED}",
			"{GRAY}",
			"{LIGHTOLIVE}",
			"{OLIVE}",
			"{LIGHTBLUE}",
			"{BLUE}",
			"{PURPLE}",
			"{BRIGHTRED}"
		},

		sColors[][] = {"\x01", "\x03", "\x04", "\x02", "\x05", "\x06", "\x07", "\x08", "\x09", "\x10", "\x0B", "\x0C", "\x0E", "\x0F"};

		if(bNative)
		{
			FormatNativeString(0, 3, 4, sizeof(sMessage), _, sMessage);
		}
		else
		{
			VFormat(sMessage, sizeof(sMessage), sFormat, 5);
		}
		
		if(sMessage[0])
		{
			if(bPrefix)
			{
				Format(sMessage, sizeof(sMessage), g_iEngine == Engine_CSGO ? " %T %s" : "%T %s", "Prefix", iClient, sMessage);
			}
			else if(g_iEngine == Engine_CSGO)
			{
				Format(sMessage, sizeof(sMessage), " %s", sMessage);
			}

			if(g_iEngine != Engine_SourceSDK2006)
			{
				ReplaceString(sMessage, sizeof(sMessage), "{WHITE}", "{DEFAULT}");
			}

			switch(g_iEngine)
			{
				case Engine_CSGO:
				{
					for(int i = 0; i != sizeof(sColorsBefore); i++)
					{
						ReplaceString(sMessage, sizeof(sMessage), sColorsBefore[i], sColors[i]);
					}
				}

				case Engine_CSS:
				{
					static const int iColorsCSSOB[] = {0xFFFFFF, 0x000000, 0x00AD00, 0xFF0000, 0x00FF00, 0x99FF99, 0xFF4040, 0xCCCCCC, 0xFFBD6B, 0xFA8B00, 0x99CCFF, 0x3D46FF, 0xFA00FA, 0xFF6055};

					static char sColor[16];

					static const char sFormatColor[] = "\x07%06X";

					int iLen = StrContains(sMessage, sColorsBefore[1], false);

					if(iLen != -1)
					{
						static const int iColorTeamCSSOB[] = {0xFFFFFF, 0xCCCCCC, 0xFF4040, 0x99CCFF};

						FormatEx(sColor, sizeof(sColor), sFormatColor, iColorTeamCSSOB[GetClientTeam(iClient)]);
						ReplaceString(sMessage[iLen], sizeof(sMessage) - iLen, sColorsBefore[1], sColor);
					}

					for(int i = 0; i != sizeof(sColorsBefore); i++)
					{
						if((iLen = StrContains(sMessage, sColorsBefore[i], false)) != -1)
						{
							FormatEx(sColor, sizeof(sColor), sFormatColor, iColorsCSSOB[i]);
							ReplaceString(sMessage[iLen], sizeof(sMessage) - iLen, sColorsBefore[i], sColor);
						}
					}
				}

				case Engine_SourceSDK2006:
				{
					for(int j = 0; j != 3; j++)
					{
						ReplaceString(sMessage, sizeof(sMessage), sColorsBefore[j], sColors[j]);
					}
				}
			}

			Handle hMessage = StartMessageOne("SayText", iClient, USERMSG_RELIABLE);

			if(hMessage)
			{
				if(GetUserMessageType() == UM_Protobuf)
				{
					Protobuf hProtobuf = view_as<Protobuf>(hMessage);

					hProtobuf.SetInt("ent_idx", 0);
					hProtobuf.SetString("text", sMessage);
					hProtobuf.SetBool("chat", true);
				}
				else
				{
					BfWrite hMessageStack = view_as<BfWrite>(hMessage);

					hMessageStack.WriteByte(0);
					hMessageStack.WriteString(sMessage);
					hMessageStack.WriteByte(true);
				}

				EndMessage();
			}
		}
	}
}

int GetAccountID(const char[] sSteamID2)
{
	return StringToInt(sSteamID2[10]) << 1 | sSteamID2[8] - '0';
}

int GetMaxPlayers()
{
	int iSlots = GetMaxHumanPlayers();

	return (iSlots < MaxClients + 1 ? iSlots : MaxClients) + 1;
}

char[] GetPlayerName(int iClient)
{
	static char sName[65];

	GetClientName(iClient, sName, 32);
	g_hDatabase.Escape(sName, sName, sizeof(sName));

	return sName;
}

char[] GetSignValue(int iValue)
{
	bool bPlus = iValue > 0;

	static char sValue[16];

	if(bPlus)
	{
		sValue[0] = '+';
	}

	IntToString(iValue, sValue[int(bPlus)], sizeof(sValue) - int(bPlus));

	return sValue;
}

char[] GetSteamID2(int iAccountID)
{
	static char sSteamID2[22] = "STEAM_";

	if(!sSteamID2[6])
	{
		sSteamID2[6] = '0' + int(g_iEngine == Engine_CSGO);
		sSteamID2[7] = ':';
	}

	FormatEx(sSteamID2[8], 14, "%i:%i", iAccountID & 1, iAccountID >>> 1);

	return sSteamID2;
}

bool NotifClient(int iClient, int iValue, const char[] sTitlePhrase, bool bAllow = false)
{
	if(CheckStatus(iClient) && (bAllow || (g_bAllowStatistic && g_bRoundAllowExp && g_bRoundEndGiveExp && iValue)))
	{
		int iExpBuffer = 0,
			iOldExp = g_iPlayerInfo[iClient].iStats[ST_EXP];

		if(g_Settings[LR_TypeStatistics])
		{
			iExpBuffer = 400;
		}

		if((g_iPlayerInfo[iClient].iStats[ST_EXP] += iValue) < iExpBuffer)
		{
			g_iPlayerInfo[iClient].iStats[ST_EXP] = iExpBuffer;
		}

		g_iPlayerInfo[iClient].iRoundExp += iExpBuffer = g_iPlayerInfo[iClient].iStats[ST_EXP] - iOldExp;
		g_iPlayerInfo[iClient].iSessionStats[ST_EXP] += iExpBuffer;

		CheckRank(iClient);

		if(g_Settings[LR_ShowUsualMessage] == 1)
		{
			LR_PrintMessage(iClient, true, false, "%T", sTitlePhrase, iClient, g_iPlayerInfo[iClient].iStats[ST_EXP], GetSignValue(iValue));
		}

		return true;
	}

	return false;
}

bool CheckStatus(int iClient)
{
	return (iClient && IsClientAuthorized(iClient) && !IsFakeClient(iClient) && g_iPlayerInfo[iClient].bInitialized) || (g_iPlayerInfo[iClient].bInitialized = false);
}

void CheckRank(int iClient, bool bActive = true)
{
	if(CheckStatus(iClient))
	{
		int iExp = g_iPlayerInfo[iClient].iStats[ST_EXP],
			iMaxRanks = g_hRankExp.Length,
			iRank = iMaxRanks + 1, 
			iOldRank = g_iPlayerInfo[iClient].iStats[ST_RANK];

		static char sRank[192];

		while(--iRank && g_hRankExp.Get(iRank - 1) > iExp) {}

		if(iRank != iOldRank)
		{
			g_iPlayerInfo[iClient].iStats[ST_RANK] = iRank;

			if(bActive)
			{
				if(GetForwardFunctionCount(g_hForward_Hook[LR_OnLevelChangedPre]))
				{
					int iNewRank = iRank;

					CallForward_OnLevelChanged(iClient, iNewRank, iOldRank);

					if(0 < iNewRank < iMaxRanks && iNewRank != iOldRank)
					{
						g_iPlayerInfo[iClient].iStats[ST_RANK] = iRank = iNewRank;
					}
					else
					{
						LogError("%i - invalid number rank.", iNewRank);
					}
				}

				bool bUp = iRank > iOldRank;

				g_iPlayerInfo[iClient].iSessionStats[ST_RANK] += iRank - iOldRank;

				g_hRankNames.GetString(iRank - 1, sRank, sizeof(sRank));

				FormatEx(sRank, sizeof(sRank), "%T", sRank, iClient);
				LR_PrintMessage(iClient, true, false, "%T", bUp ? "LevelUp" : "LevelDown", iClient, sRank);

				if(IsClientInGame(iClient) && g_Settings[LR_IsLevelSound])
				{
					EmitSoundToClient(iClient, bUp ? g_sSoundUp : g_sSoundDown, SOUND_FROM_PLAYER, 80);
				}

				if(g_Settings[LR_ShowLevelUpMessage + int(bUp)])
				{
					for(int i = GetMaxPlayers(); --i;)
					{
						if(g_iPlayerInfo[i].bInitialized && i != iClient)
						{
							LR_PrintMessage(i, true, false, "%T", bUp ? "LevelUpAll" : "LevelDownAll", i, iClient, sRank);
						}
					}
				}

				CallForward_OnLevelChanged(iClient, iRank, iOldRank, false);
			}

			SaveDataPlayer(iClient);		// in database.sp
		}
	}
}

void ResetPlayerData(int iClient)
{
	g_iPlayerInfo[iClient].iStats = g_iInfoNULL.iStats;
	g_iPlayerInfo[iClient].iSessionStats = g_iInfoNULL.iSessionStats;
	g_iPlayerInfo[iClient].iKillStreak = 0;
	
	g_iPlayerInfo[iClient].iStats[ST_PLAYTIME] = g_iPlayerInfo[iClient].iSessionStats[ST_PLAYTIME] -= GetTime();
	g_iPlayerInfo[iClient].iStats[ST_EXP] = g_Settings[LR_TypeStatistics] ? 1000 : 0;
}

void ResetPlayerStats(int iClient)
{
	ResetPlayerData(iClient);

	CheckRank(iClient, false);

	CallForward_OnResetPlayerStats(iClient, g_iPlayerInfo[iClient].iAccountID);
}