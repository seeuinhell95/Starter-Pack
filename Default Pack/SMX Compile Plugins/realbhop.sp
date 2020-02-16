#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new bool:AfterJumpFrame[MAXPLAYERS + 1];
new FloorFrames[MAXPLAYERS + 1];
new bool:PlayerOnGround[MAXPLAYERS + 1];
new Float:AirSpeed[MAXPLAYERS + 1][3];
new BaseVelocity;

new Handle:CvarPluginEnabled;
new bool:PluginEnabled;

new Handle:CvarMaxBhopFrames;
new MaxBhopFrames;

new Handle:CvarFramePenalty;
new Float:FramePenalty;

new bool:PlayerInTriggerPush[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name = "[CSGO] Real Bhop",
    author = "SeriTools | Edited: somebody.",
    description = "Real Bhop",
    version = "1.0",
    url = "http://sourcemod.net"
}

public OnPluginStart()
{
    BaseVelocity = FindSendPropInfo("CBasePlayer","m_vecBaseVelocity");

    CvarPluginEnabled = CreateConVar("sm_realbhop_enabled", "1", "Sets whether RealBhop is enabled", FCVAR_NOTIFY);
    HookConVarChange(CvarPluginEnabled, OnPluginEnabledChange);

    CvarMaxBhopFrames = CreateConVar("sm_realbhop_maxbhopframes", "12", "Sets the maximum number of frames the bhop calculation is active after touching the ground.", FCVAR_NOTIFY, true, 1.0, false);
    HookConVarChange(CvarMaxBhopFrames, OnMaxBhopFramesChange);

    CvarFramePenalty = CreateConVar("sm_realbhop_framepenalty", "0.975", "Sets the velocity penalty multiplier per frame the player jumped too late. (1.0 = no penalty)", FCVAR_NOTIFY, true, 0.0, false);
    HookConVarChange(CvarFramePenalty, OnFramePenaltyChange);

    AutoExecConfig(true, "realbhop");

    PluginEnabled = GetConVarBool(CvarPluginEnabled);
    MaxBhopFrames = GetConVarInt(CvarMaxBhopFrames);
    FramePenalty = GetConVarFloat(CvarFramePenalty);

    HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);

    for (new i = 0; i <= MaxClients; i++)
	{
        ResetValues(i);
    }
}

public OnClientPutInServer(client)
{
    ResetValues(client);
}

public OnGameFrame()
{
    if (PluginEnabled)
	{
        for (new i = 1; i <= MaxClients; i++)
		{
            if(IsClientConnected(i) && !IsFakeClient(i) && IsClientInGame(i) && !IsClientObserver(i) && !PlayerInTriggerPush[i])
			{
                if(GetEntityFlags(i) & FL_ONGROUND)
				{
                    if (!PlayerOnGround[i])
					{

                        PlayerOnGround[i] = true;

                        FloorFrames[i] = 0;
                    }
                    else
					{
                        if (FloorFrames[i] <= MaxBhopFrames)
						{
                            FloorFrames[i]++;
                        }
                    }
                }
                else
				{
                    if (AfterJumpFrame[i])
					{
                        if (FloorFrames[i] <= MaxBhopFrames)
						{
                            new Float:finalvec[3];

                            GetEntPropVector(i, Prop_Data, "m_vecVelocity", finalvec);

                            finalvec[0] = (AirSpeed[i][0] - finalvec[0]) * Pow(FramePenalty, float(FloorFrames[i]));
                            finalvec[1] = (AirSpeed[i][1] - finalvec[1]) * Pow(FramePenalty, float(FloorFrames[i]));
                            finalvec[2] = 0.0;

                            SetEntDataVector(i, BaseVelocity, finalvec, true);
                        }
                        AfterJumpFrame[i] = false;
                    }

                    if (PlayerOnGround[i])
					{
                        PlayerOnGround[i] = false;
                        AfterJumpFrame[i] = true;
                    }
                    else
					{
                        GetEntPropVector(i, Prop_Data, "m_vecVelocity", AirSpeed[i]);
                    }
                }
            }
        }
    }
}

public OnPluginEnabledChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    PluginEnabled = GetConVarBool(cvar);
}

ResetValues(client)
{
    FloorFrames[client] = MaxBhopFrames + 1;
    AirSpeed[client][0] = 0.0;
    AirSpeed[client][1] = 0.0;
    AfterJumpFrame[client] = false;
    PlayerInTriggerPush[client] = false;
}

public OnMaxBhopFramesChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    MaxBhopFrames = StringToInt(newVal) - 1;
}

public OnFramePenaltyChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    FramePenalty = StringToFloat(newVal);
}

public OnMapStart()
{
    HookTriggerPushes();
}

public Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    HookTriggerPushes();
}

HookTriggerPushes()
{
    new index = -1;
    while ((index = FindEntityByClassname2(index, "trigger_push")) != -1)
	{
        SDKHook(index, SDKHook_StartTouch, Event_EntityOnStartTouch);
        SDKHook(index, SDKHook_EndTouch, Event_EntityOnEndTouch);
    }
}

FindEntityByClassname2(startEnt, const String:classname[])
{
    while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;

    return FindEntityByClassname(startEnt, classname);
}

public Event_EntityOnStartTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client))
		{
        PlayerInTriggerPush[client] = true;
    }
}

public Event_EntityOnEndTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client))
		{
		PlayerInTriggerPush[client] = false;
	}
}