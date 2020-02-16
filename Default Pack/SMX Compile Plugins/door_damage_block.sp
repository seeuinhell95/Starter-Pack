#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] Door Damage Block",
	author = "Cherry | Edited: somebody.",
	description = "Door Damage Block",
	version = "1.0",
	url = "http://sourcemod.net"
}

new String:doorlist[][32] =
{
	
	"func_door",
	"func_rotating",
	"func_door_rotating",
	"func_movelinear",
	"prop_door",
	"func_tracktrain",
	"func_elevator",
	"\0"
};

public OnPluginStart()
{

}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Event_TakeDamage); 
}

public Action:Event_TakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	new String:classname[32];
	GetEdictClassname(attacker, classname, sizeof(classname));
	for(new i=0;i<sizeof(doorlist);++i)
	{
		if(strcmp(classname, doorlist[i])==0)
		{
			if(GetEntPropFloat(attacker, Prop_Data, "m_flBlockDamage") == 0.0)
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}