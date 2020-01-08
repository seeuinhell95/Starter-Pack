#pragma semicolon 1

#include <sourcemod>
#include <umc-core>

public Plugin myinfo =
{
    name        = "[CSGO] UMC - Map Weight",
    author      = "Steell, PowerLord & Mr. Silence | Edited: somebody.",
    description = "UMC - Map Weight",
    version     = "1.0",
    url         = "http://sourcemod.net"
};

#define WEIGHT_KEY_MAP   "weight"
#define WEIGHT_KEY_GROUP "group_weight"

public Action:UMC_OnDetermineMapExclude(Handle:kv, const String:map[], const String:group[], bool:isNom, bool:forMapChange)
{
    if (kv == INVALID_HANDLE)
    {
        return Plugin_Continue;
    }
    
    KvRewind(kv);
    
    if (KvJumpToKey(kv, group))
    {
        if (KvJumpToKey(kv, map))
        {
            if (KvGetFloat(kv, WEIGHT_KEY_MAP, 1.0) == 0.0)
            {
                KvGoBack(kv);
                KvGoBack(kv);
                return Plugin_Stop;
            }
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    return Plugin_Continue;
}

public UMC_OnReweightMap(Handle:kv, const String:map[], const String:group[])
{
    if (kv == INVALID_HANDLE)
    {
        return;
    }
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        if (KvJumpToKey(kv, map))
        {
            UMC_AddWeightModifier(KvGetFloat(kv, WEIGHT_KEY_MAP, 1.0));
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
}

public UMC_OnReweightGroup(Handle:kv, const String:group[])
{
    if (kv == INVALID_HANDLE)
    {
        return;
    }
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        UMC_AddWeightModifier(KvGetFloat(kv, WEIGHT_KEY_GROUP, 1.0));
        KvGoBack(kv);
    }
}