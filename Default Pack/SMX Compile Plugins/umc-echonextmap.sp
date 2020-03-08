#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <umc-core>
#include <umc_utils>

public Plugin myinfo =
{
    name        = "[CSGO] UMC - Echo NextMap",
    author      = "Steell, PowerLord & Mr. Silence | Edited: somebody.",
    description = "UMC - Echo NextMap",
    version     = "1.0",
    url         = "http://sourcemod.net"
};

new Handle:cvar_center  = INVALID_HANDLE;
new Handle:cvar_hint    = INVALID_HANDLE;
new Handle:cvar_display = INVALID_HANDLE;

public OnPluginStart()
{
    cvar_display = CreateConVar(
        "sm_umc_echonextmap_display",
        "0",
        "If enabled, the displayed map name will be the real name of the map, not the name taken from the map's \"display\" setting.",
        0, true, 0.0, true, 1.0
    );

    cvar_center = CreateConVar(
        "sm_umc_echonextmap_center",
        "1",
        "If enabled, a message will be displayed in the center of the screen when the next map is set.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_hint = CreateConVar(
        "sm_umc_exchonextmap_hint",
        "0",
        "If enabled, a message will be displayed in the hint box when the next map is set.",
        0, true, 0.0, true, 1.0
    );

    AutoExecConfig(true, "umc/umc-echonextmap");

    LoadTranslations("ultimate-mapchooser.phrases");
}

public UMC_OnNextmapSet(Handle:kv, const String:map[], const String:group[], const String:display[])
{
    new bool:disp = !GetConVarBool(cvar_display);

    if (GetConVarBool(cvar_center))
    {
        new String:msg[256];
        if (disp && strlen(display) > 0)
        {
            Format(msg, sizeof(msg), "%t", "Next Map", display);
        }
        else
        {
            Format(msg, sizeof(msg), "%t", "Next Map", map);
        }
        DisplayServerMessage(msg, "C");
    }
    if (GetConVarBool(cvar_hint))
    {
        if (disp && strlen(display) > 0)
        {
            PrintHintTextToAll("%t", "Next Map", display);
        }
        else
        {
            PrintHintTextToAll("%t", "Next Map", map);
        }
    }
}