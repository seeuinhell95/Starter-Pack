#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required 

bool usethisshit;
bool ctwin;
bool twin;

public Plugin myinfo =
{
	name = "[CSGO] MG Swag Range Fix",
	author = "Cherry | Edited: somebody.",
	description = "MG Swag Range Fix",
	version = "1.0",
	url = "http://sourcemod.net"
}

public void OnMapStart()
{
	usethisshit = false;
	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	if (StrEqual(mapname, "mg_swag_multigames_v7", true))
    {
        usethisshit = true;
    }
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(usethisshit && StrContains(classname, "func_breakable", false) >= 0)
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		twin = false;
		ctwin = false;
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (usethisshit && IsPlayerAlive(attacker) && IsValidEntity(victim)) 
		{ 
			char buffer2[32];
			GetEntPropString(victim, Prop_Data, "m_iName", buffer2, sizeof(buffer2));
			if(strcmp(buffer2, "range_break10") == 0)
			{ 
				if(twin)
				{
					SetEntProp(victim,Prop_Data,"m_iHealth", 999999);
				}
				int lolo = GetEntProp(victim,Prop_Data,"m_iHealth");
				if (lolo <= 40 )
				{
					PrintToChatAll(" \x0C[SWAG] \x05Terrorelhárító Győzelem!");
					ctwin = true;
					int index2 = -1;
					char buffer3[32];
					while ((index2 = FindEntityByClassname(index2, "func_breakable")) != -1)
					{
						if(IsValidEntity(index2))
						{
				  			GetEntPropString(index2, Prop_Data, "m_iName", buffer3, sizeof(buffer3));
				  			if(strcmp(buffer3, "range_break10") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
				  			if(strcmp(buffer3, "range_break11") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
							if(strcmp(buffer3, "range_break12") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
				  			if(strcmp(buffer3, "range_break13") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
						}
					}
				}
			} 
			if(strcmp(buffer2, "range_break3") == 0)
			{ 
				int lolo = GetEntProp(victim,Prop_Data,"m_iHealth");
				if(ctwin)
				{
					SetEntProp(victim,Prop_Data,"m_iHealth", 999999);
				}
				if (lolo <= 40)
				{
					PrintToChatAll(" \x02[SWAG] \x05Terrorista Győzelem!");
					twin = true;
					int index2 = -1;
					char buffer3[32];
					while ((index2 = FindEntityByClassname(index2, "func_breakable")) != -1)
					{
						if(IsValidEntity(index2))
						{
				  			GetEntPropString(index2, Prop_Data, "m_iName", buffer3, sizeof(buffer3));
				  			if(strcmp(buffer3, "range_break3") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
				  			if(strcmp(buffer3, "range_break4") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
							if(strcmp(buffer3, "range_break5") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
				  			if(strcmp(buffer3, "range_break6") == 0)
							{
								AcceptEntityInput(index2, "Break");
							}
						}
					}
				}
			} 
		} 
	return Plugin_Continue; 
}