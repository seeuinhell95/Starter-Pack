#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define CSGO_MAP_COUNT 54

char csgoMapName[CSGO_MAP_COUNT][] =
{
	"ar_baggage",
	"ar_dizzy",
	"ar_lunacy",
	"ar_monastery",
	"ar_shoots",
	"coop_kasbah",
	"cs_agency",
	"cs_assault",
	"cs_downtown",
	"cs_insertion",
	"cs_italy",
	"cs_militia",
	"cs_motel",
	"cs_office",
	"cs_rush",
	"cs_siege",
	"cs_thunder",
	"de_ali",
	"de_aztec",
	"de_bank",
	"de_blackgold",
	"de_breach",
	"de_cache",
	"de_canals",
	"de_cbble",
	"de_chinatown",
	"de_dust",
	"de_dust2",
	"de_favela",
	"de_gwalior",
	"de_inferno",
	"de_lake",
	"de_mirage",
	"de_mist",
	"de_nuke",
	"de_overgrown",
	"de_overpass",
	"de_ruins",
	"de_safehouse",
	"de_seaside",
	"de_shortdust",
	"de_shortnuke",
	"de_shorttrain",
	"de_stmarc",
	"de_studio",
	"de_sugarcane",
	"de_train",
	"de_vertigo",
	"dz_blacksite",
	"dz_junglety",
	"dz_sirocco",
	"gd_cbble",
	"gd_rialto",
	"training1"
};

ConVar g_DeleteMap[CSGO_MAP_COUNT];

public Plugin myinfo =
{
	name = "[CSGO] Automatic Delete Default Maps",
	author = "SpirT & StickZ | Edited: somebody.",
	description = "Automatic Delete Default Maps",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	for (int i = 0; i < CSGO_MAP_COUNT; i++)
	{
		char cvarName[32];
		Format(cvarName, sizeof(cvarName), "mapdel_%s", csgoMapName[i]);

		char cvarDesc[64];
		Format(cvarDesc, sizeof(cvarDesc), "Deletes all %s files", csgoMapName[i]);

		g_DeleteMap[i] = CreateConVar(cvarName, "1", cvarDesc, _, true, 0.0, true, 1.0);
	}

	AutoExecConfig(true, "mapdelete");
}

public void OnMapStart()
{
	DeleteAllMaps();
	return;
}

void DeleteAllMaps()
{
	char fileExt[3][] =
	{
		"bsp",
		"nav",
		"jpg"
	};

	for (int i = 0; i < CSGO_MAP_COUNT; i++)
	{
		if (g_DeleteMap[i].BoolValue)
		{
			for (int f = 0; f < 3; f++)
			{
				char fileName[32];
				Format(fileName, sizeof(fileName), "maps/%s.%s", csgoMapName[i], fileExt[f]);

				if (FileExists(fileName))
					DeleteFile(fileName);
			}
		}
	}
}