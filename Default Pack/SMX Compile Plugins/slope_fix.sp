#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Slope Boost Fix",
	author = "Blacky, Mev & LazaRev | Edited: somebody.",
	description = "Slope Boost Fix",
	version = "1.0",
	url = "http://sourcemod.net"
}

enum (+= 4)
{
    m_bFirstRunOfFunctions = 0,
    m_nPlayerHandle,
    m_nImpulseCommand,
    m_vecViewAngles, m_vecViewAngles_X = m_vecViewAngles,
        m_vecViewAngles_Y,
        m_vecViewAngles_Z,
    m_vecAbsViewAngles, m_vecAbsViewAngles_X = m_vecAbsViewAngles,
        m_vecAbsViewAngles_Y,
        m_vecAbsViewAngles_Z,
    m_nButtons,
    m_nOldButtons,
    m_flForwardMove,
    m_flSideMove,
    m_flUpMove,
    m_flMaxSpeed,
    m_flClientMaxSpeed,
    m_vecVelocity, m_vecVelocity_X = m_vecVelocity,
        m_vecVelocity_Y,
        m_vecVelocity_Z,
    m_vecAngles, m_vecAngles_X = m_vecAngles,
        m_vecAngles_Y,
        m_vecAngles_Z,
    m_vecOldAngles,
        m_vecOldAngles_X = m_vecOldAngles,
        m_vecOldAngles_Y,
        m_vecOldAngles_Z,
    m_outStepHeight,
    m_outWishVel, m_outWishVel_X = m_outWishVel,
        m_outWishVel_Y,
        m_outWishVel_Z,
    m_outJumpVel, m_outJumpVel_X = m_outJumpVel,
        m_outJumpVel_Y,
        m_outJumpVel_Z,
    m_vecConstraintCenter, m_vecConstraintCenter_X = m_vecConstraintCenter,
        m_vecConstraintCenter_Y,
        m_vecConstraintCenter_Z,
    m_flConstraintRadius,
    m_flConstraintWidth,
    m_flConstraintSpeedFactor,
    m_flUnknown_0,
    m_flUnknown_1,
    m_flUnknown_2,
    m_flUnknown_3,
    m_flUnknown_4,
    m_vecAbsOrigin, m_vecAbsOrigin_X = m_vecAbsOrigin,
        m_vecAbsOrigin_Y,
        m_vecAbsOrigin_Z
};

enum (+= 4) 
{
    tr_vecStartPos, tr_vecStartPos_X = tr_vecStartPos,
        tr_vecStartPos_Y,
        tr_vecStartPos_Z,
    tr_vecEndPos, tr_vecEndPos_X = tr_vecEndPos,
        tr_vecEndPos_Y,
        tr_vecEndPos_Z,
    tr_vecPlaneNormal, tr_vecPlaneNormal_X = tr_vecPlaneNormal,
        tr_vecPlaneNormal_Y,
        tr_vecPlaneNormal_Z
};

Handle g_hProcessMovement;
Handle g_hSetGroundEntity;

int g_iMoveClientIndex;

ConVar sm_slope_fix;

public void OnPluginStart()
{
    sm_slope_fix = CreateConVar("sm_slope_fix", "1", "Fix speed when landing on walkable slopes");

    Handle gameConfig = LoadGameConfigFile("slope_fix.games");

    if (!gameConfig)
        SetFailState("slope_fix.games.txt file missing");

    StartPrepSDKCall(SDKCall_Static);

    if (!PrepSDKCall_SetFromConf(gameConfig, SDKConf_Signature, "CreateInterface"))
    {
        SetFailState("Failed to get CreateInterface");
        delete gameConfig;
    }

    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

    char ifaceName[32];

    if (!GameConfGetKeyValue(gameConfig, "IGameMovement", ifaceName, sizeof(ifaceName)))
    {
        SetFailState("Failed to get IGameMovement interface name");
        delete gameConfig;
    }

    Handle call = EndPrepSDKCall();
    Address addr = SDKCall(call, ifaceName, 0);
    delete call;

    if (!addr)
    {
        SetFailState("Failed to get IGameMovement ptr");
        delete gameConfig;
    }

    int offset = GameConfGetOffset(gameConfig, "ProcessMovement");

    if (offset == -1)
    {
        SetFailState("IGameMovement::ProcessMovement offset was not found");
        delete gameConfig;    
    }

    g_hProcessMovement = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, OnCGameMovementProcessMovement_Pre);
    DHookAddParam(g_hProcessMovement, HookParamType_CBaseEntity);
    DHookAddParam(g_hProcessMovement, HookParamType_ObjectPtr);
    DHookRaw(g_hProcessMovement, false, addr);

    offset = GameConfGetOffset(gameConfig, "SetGroundEntity");

    if (offset == -1)
    {
        SetFailState("IGameMovement::SetGroundEntity offset was not found");
        delete gameConfig;
    }

    g_hSetGroundEntity = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Address, OnCGameMovementSetGroundEntity_Pre);
    DHookAddParam(g_hSetGroundEntity, HookParamType_ObjectPtr);
    DHookRaw(g_hSetGroundEntity, false, addr);

    delete gameConfig;
}

public MRESReturn OnCGameMovementProcessMovement_Pre(Handle hParams)
{
    if (DHookIsNullParam(hParams, 1))
        return MRES_Ignored;

    g_iMoveClientIndex = DHookGetParam(hParams, 1);

    return MRES_Ignored;
}

public MRESReturn OnCGameMovementSetGroundEntity_Pre(Address pThis, Handle hParams)
{
    if (!sm_slope_fix.BoolValue || DHookIsNullParam(hParams, 1))
        return MRES_Ignored;

    int client = g_iMoveClientIndex;

    Address mv = pThis + view_as<Address>(8);
    mv = view_as<Address>(LoadFromAddress(mv, NumberType_Int32));

    if (mv != Address_Null)
    {
        float velocity[3];
        velocity[0] = view_as<float>(LoadFromAddress(mv + view_as<Address>(m_vecVelocity_X), NumberType_Int32));
        velocity[1] = view_as<float>(LoadFromAddress(mv + view_as<Address>(m_vecVelocity_Y), NumberType_Int32));
        velocity[2] = view_as<float>(LoadFromAddress(mv + view_as<Address>(m_vecVelocity_Z), NumberType_Int32));

        if (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1)
        {
            float planeNormal[3];
            DHookGetParamObjectPtrVarVector(hParams, 1, tr_vecPlaneNormal, ObjectValueType_Vector, planeNormal);

            if (planeNormal[2] > 0.7 && planeNormal[2] < 1.0)
            {
                ClipVelocity(mv, velocity, planeNormal, 1.0);

                StoreToAddress(mv + view_as<Address>(m_vecVelocity_X), view_as<int>(velocity[0]), NumberType_Int32);
                StoreToAddress(mv + view_as<Address>(m_vecVelocity_Y), view_as<int>(velocity[1]), NumberType_Int32);
                StoreToAddress(mv + view_as<Address>(m_vecVelocity_Z), view_as<int>(velocity[2]), NumberType_Int32);
            }
        }
    }

    return MRES_Ignored;
}

stock void ClipVelocity(Address mv, float velocity[3], float planeNormal[3], float overbounce)
{
    float out[3];
    out = velocity;

    float backoff = GetVectorDotProduct(out, planeNormal) * overbounce;

    for (int i = 0; i < 3; i++)
        out[i] -= planeNormal[i] * backoff;

    float adjust = GetVectorDotProduct(out, planeNormal);

    if (adjust < 0.0)
    {
        for (int i = 0; i < 3; i++)
            out[i] -= planeNormal[i] * adjust;
    }

    float in_len = SquareRoot(velocity[0] * velocity[0] + velocity[1] * velocity[1]);
    float out_len = SquareRoot(out[0] * out[0] + out[1] * out[1]);

    if (out_len > in_len)
        velocity = out;
}