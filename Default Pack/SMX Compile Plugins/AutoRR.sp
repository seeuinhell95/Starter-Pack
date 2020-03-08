#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colorvariables>

Handle kv;
bool g_bEnd;
ConVar cvar_end;
int g_iCount;
Handle timers;

public Plugin myinfo =
{
	name = "[CSGO] Automatic Round Restart",
	author = "Franc1sco | Edited: Atesz & somebody.",
	description = "Automatic Round Restart",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	LoadTranslations("AutoRR.phrases.txt");

	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd);

	cvar_end = FindConVar("mp_round_restart_delay");
}

public OnMapStart()
{
	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/AutoRR.cfg");

	if (kv != null) delete kv;

	kv = CreateKeyValues("AutoRR");
	FileToKeyValues(kv, sConfig);	

	char temp[128];
	if(KvGotoFirstSubKey(kv))
	{
		do
		{
			KvGetString(kv, "sound", temp, 128, "none");
	
			if (!StrEqual(temp, "none", false) && FileExists(temp))
			{
				AddFileToDownloadsTable(temp);
				ReplaceString(temp, 128, "sound/", "");
				PrecacheSound(temp);
			}
			
		} while (KvGotoNextKey(kv));
	}
	KvRewind(kv);

	ServerCommand("sm_reload_translations");

	g_bEnd = true;
}

public Action Timer_Check(Handle hTimer)
{
	if (g_bEnd)return;
	g_iCount++;

	int iRoundTime = GameRules_GetProp("m_iRoundTime");

	char input[64];
	Format(input, 64, "%i", iRoundTime-g_iCount);

	if(iRoundTime == 0)
		CS_TerminateRound(cvar_end!=null?GetConVarFloat(cvar_end):7.0, CSRoundEnd_Draw);

	KvRewind(kv);
	if (!KvJumpToKey(kv, input))return;

	char temp[128];
	KvGetString(kv, "sound", temp, 128, "none");

	if (!StrEqual(temp, "none", false) && FileExists(temp))
	{
		ReplaceString(temp, 128, "sound/", "");
		EmitSoundToAll(temp);
	}

	KvGetString(kv, "chat", temp, 128, "none");

	if (!StrEqual(temp, "none", false))
		CPrintToChatAll("%t", temp);
}

public Action Event_RoundFreezeEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (timers != null)KillTimer(timers);
	timers = CreateTimer(1.0, Timer_Check, _, TIMER_REPEAT);
	g_bEnd = false;
	g_iCount = 0;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast) 
{
	g_bEnd = true;
	g_iCount = 0;
}