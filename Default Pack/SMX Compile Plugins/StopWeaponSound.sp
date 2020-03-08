#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

new g_iStopSound[MAXPLAYERS+1], bool:g_bHooked, bool:g_bSilenceSound[MAXPLAYERS+1];
new Handle:g_hClientCookie = INVALID_HANDLE;

new String:sSoundPath[PLATFORM_MAX_PATH];
ConVar sm_stopsound_silenced_sound;
float fVolume = 1.0;
ConVar sm_stopsound_silenced_volume;

public Plugin myinfo =
{
	name = "[CSGO] Stop Weapon Sounds",
	author = "GoD-Tony & SHUFEN | Edited: somebody.",
	description = "Stop Weapon Sounds",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
        LoadTranslations("StopSound.phrases");

        g_hClientCookie = RegClientCookie("ps_stopsound", "Toggle hearing weapon sounds", CookieAccess_Private);
        SetCookieMenuItem(StopSoundCookieHandler, g_hClientCookie, "Fegyver hangok");

        sm_stopsound_silenced_sound = CreateConVar("sm_stopsound_silenced_sound", "weapons/usp/usp1.wav", "");
        char buffer[PLATFORM_MAX_PATH];
        sm_stopsound_silenced_sound.GetString(buffer, sizeof(buffer));
        if(buffer[0])
		{
                FormatEx(sSoundPath, sizeof(sSoundPath), "~)%s", buffer);
        }
        sm_stopsound_silenced_sound.AddChangeHook(OnConVarChange);

        sm_stopsound_silenced_volume = CreateConVar("sm_stopsound_silenced_volume", "0.5", "", _, true, 0.0, true, 1.0);
        fVolume = sm_stopsound_silenced_volume.FloatValue;
        sm_stopsound_silenced_volume.AddChangeHook(OnConVarChange);

        AddTempEntHook("Shotgun Shot", CSS_Hook_ShotgunShot);
        AddNormalSoundHook(Hook_NormalSound);

        RegConsoleCmd("sm_stopweaponsounds", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopweaponsound", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopweapons", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopweapon", Command_StopSound, "Toggle hearing weapon sounds");

        RegConsoleCmd("sm_stopsounds", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopsound", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_sounds", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_sound", Command_StopSound, "Toggle hearing weapon sounds");

        RegConsoleCmd("sm_stopgunsounds", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopgunsound", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopguns", Command_StopSound, "Toggle hearing weapon sounds");
        RegConsoleCmd("sm_stopgun", Command_StopSound, "Toggle hearing weapon sounds");

        for (new i = 1; i <= MaxClients; ++i)
        {
                if (!AreClientCookiesCached(i))
                {
                        continue;
                }
                OnClientCookiesCached(i);
        }
}

public OnMapStart()
{
        if(sSoundPath[0])
                PrecacheSound(sSoundPath, true);
}

public void OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
        if (convar == sm_stopsound_silenced_sound) {
                char buffer[PLATFORM_MAX_PATH];
                convar.GetString(buffer, sizeof(buffer));
                if(buffer[0]) {
                        FormatEx(sSoundPath, sizeof(sSoundPath), "~)%s", buffer);
                        PrecacheSound(sSoundPath, true);
                }
        }
        if (convar == sm_stopsound_silenced_volume) {
                fVolume = convar.FloatValue;
        }
}

public StopSoundCookieHandler(client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
        switch (action)
        {
                case CookieMenuAction_DisplayOption:
                {
                }
              
                case CookieMenuAction_SelectOption:
                {
                        if(CheckCommandAccess(client, "sm_stopsound", 0))
                        {
                                PrepareMenu(client);
                        }
                        else
                        {
                                ReplyToCommand(client, "[SM] Nincs engedélyed a parancs használatához!");
                        }
                }
        }
}

PrepareMenu(client)
{
        new Handle:menu = CreateMenu(YesNoMenu, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem|MenuAction_DisplayItem|MenuAction_Display);
        SetMenuTitle(menu, "Fegyver hangok beállításai");
        AddMenuItem(menu, "0", "Disable");
        AddMenuItem(menu, "1", "Stop Sound");
        AddMenuItem(menu, "2", "Replace to Silenced Sound");
        SetMenuExitBackButton(menu, true);
        DisplayMenu(menu, client, 20);
}

public YesNoMenu(Handle:menu, MenuAction:action, param1, param2)
{
        switch(action)
        {
                case MenuAction_DrawItem:
                {
                        if(_:g_iStopSound[param1] == param2)
                        {
                                return ITEMDRAW_DISABLED;
                        }
                }
                case MenuAction_DisplayItem:
                {
                        new String:dispBuf[50];
                        GetMenuItem(menu, param2, "", 0, _, dispBuf, sizeof(dispBuf));
                        Format(dispBuf, sizeof(dispBuf), "%T", dispBuf, param1);
                        return RedrawMenuItem(dispBuf);
                }
                case MenuAction_Display:
                {
                        new String:buffer[256];
                        new String:title[][] = {
                                "1",
                                "2",
                                "3"
                        };
                        GetMenuTitle(menu, buffer, sizeof(buffer));
                        Format(buffer, sizeof(buffer), "%s\n%T", buffer, title[g_iStopSound[param1]], param1);
                        SetMenuTitle(menu, buffer);
                }
                case MenuAction_Select:
                {
                        new String:info[50];
                        if(GetMenuItem(menu, param2, info, sizeof(info)))
                        {
                                SetClientCookie(param1, g_hClientCookie, info);
                                g_iStopSound[param1] = StringToInt(info);
                                if(StringToInt(info) == 2) {
                                        g_bSilenceSound[param1] = true;
                                        ReplyToCommand(param1, " \x04[STOP] \x02Fegyver hangok: \x04Hangtompítós\x01.");
                                }
                                else {
                                        g_bSilenceSound[param1] = false;
                                        ReplyToCommand(param1, " \x04[STOP] \x02Fegyver hangok: \x04%s\x01.", g_iStopSound[param1] != 0 ? "Bekapcsolva" : "Kikapcsolva");
                                }
                                CheckHooks();
                                PrepareMenu(param1);
                        }
                }
                case MenuAction_Cancel:
                {
                        if( param2 == MenuCancel_ExitBack )
                        {
                                ShowCookieMenu(param1);
                        }
                }
                case MenuAction_End:
                {
                        CloseHandle(menu);
                }
        }

        return 0;
}

public OnClientCookiesCached(client)
{
        new String:sValue[8];
        GetClientCookie(client, g_hClientCookie, sValue, sizeof(sValue));
        if (sValue[0] == '\0') {
                SetClientCookie(client, g_hClientCookie, "0");
                strcopy(sValue, sizeof(sValue), "0");
        }
        g_iStopSound[client] = (StringToInt(sValue));
        g_bSilenceSound[client] = StringToInt(sValue) > 1;
        CheckHooks();
}

public Action:Command_StopSound(client, args)
{
        if(AreClientCookiesCached(client))
        {
                PrepareMenu(client);
        }
        else
        {
                ReplyToCommand(client, "[SM] A beállításaid még nem töltődtek be. Kérlek várj még egy kicsit...");
        }
      
        return Plugin_Handled;
}

public OnClientDisconnect_Post(client)
{
        g_iStopSound[client] = 0;
        g_bSilenceSound[client] = false;
        CheckHooks();
}

CheckHooks()
{
        new bool:bShouldHook = false;
      
        for (new i = 1; i <= MaxClients; i++)
        {
                if (g_iStopSound[i] > 0)
                {
                        bShouldHook = true;
                        break;
                }
        }

        g_bHooked = bShouldHook;
}

public Action:Hook_NormalSound(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
        if (!g_bHooked || StrEqual(sample, sSoundPath, false) || !(strncmp(sample, "weapons", 7, false) == 0 || strncmp(sample[1], "weapons", 7, false) == 0 || strncmp(sample[2], "weapons", 7, false) == 0))
                return Plugin_Continue;
      
        decl i, j;
      
        for (i = 0; i < numClients; i++)
        {
                if (g_iStopSound[clients[i]] > 0)
                {
                        for (j = i; j < numClients-1; j++)
                        {
                                clients[j] = clients[j+1];
                        }
                      
                        numClients--;
                        i--;
                }
        }
      
        return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
}

public Action:CSS_Hook_ShotgunShot(const String:te_name[], const Players[], numClients, Float:delay)
{
        if (!g_bHooked)
                return Plugin_Continue;

        decl newClients[MaxClients], client, i;
        new newTotal = 0;

        int clientlist[MAXPLAYERS+1];
        int clientcount = 0;

        for (i = 0; i < numClients; i++)
        {
                client = Players[i];
              
                if (g_iStopSound[client] <= 0)
                {
                        newClients[newTotal++] = client;
                }
                else if(sSoundPath[0])
                {
                        if(g_bSilenceSound[client])
                        {
                                clientlist[clientcount++] = client;
                        }
                }
        }

        if (newTotal == numClients)
                return Plugin_Continue;

        new player = TE_ReadNum("m_iPlayer");
        if(sSoundPath[0]) {
                new entity = player + 1;
                for (new j = 0; j < clientcount; j++)
                {
                        if (entity == clientlist[j])
                        {
                                for (new k = j; k < clientcount-1; k++)
                                {
                                        clientlist[k] = clientlist[k+1];
                                }
                              
                                clientcount--;
                                j--;
                        }
                }
                EmitSound(clientlist, clientcount, sSoundPath, entity, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, fVolume);
        }

        else if (newTotal == 0)
                return Plugin_Stop;

        decl Float:vTemp[3];
        TE_Start("Shotgun Shot");
        TE_ReadVector("m_vecOrigin", vTemp);
        TE_WriteVector("m_vecOrigin", vTemp);
        TE_WriteFloat("m_vecAngles[0]", TE_ReadFloat("m_vecAngles[0]"));
        TE_WriteFloat("m_vecAngles[1]", TE_ReadFloat("m_vecAngles[1]"));
        TE_WriteNum("m_weapon", TE_ReadNum("m_weapon"));
        TE_WriteNum("m_iMode", TE_ReadNum("m_iMode"));
        TE_WriteNum("m_iSeed", TE_ReadNum("m_iSeed"));
        TE_WriteNum("m_iPlayer", player);
        TE_WriteFloat("m_fInaccuracy", TE_ReadFloat("m_fInaccuracy"));
        TE_WriteFloat("m_fSpread", TE_ReadFloat("m_fSpread"));
        TE_Send(newClients, newTotal, delay);

        return Plugin_Stop;
}