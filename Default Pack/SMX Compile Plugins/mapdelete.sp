#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>

int baggage;
int dizzy;
int lunacy;
int monastery;
int shoots;
int kasbah;
int agency;
int assault;
int downtown;
int insertion;
int italy;
int militia;
int motel;
int office;
int rush;
int siege;
int thunder;
int ali;
int aztec;
int bank;
int blackgold;
int breach;
int cache;
int canals;
int de_cbble;
int chinatown;
int dust;
int dust2;
int favela;
int gwalior;
int inferno;
int lake;
int mirage;
int mist;
int nuke;
int overgrown;
int overpass;
int ruins;
int safehouse;
int seaside;
int shortdust;
int shortnuke;
int shorttrain;
int stmarc;
int studio;
int sugarcane;
int train;
int vertigo;
int blacksite;
int junglety;
int sirocco;
int cbble;
int rialto;
int training;

ConVar g_baggage;
ConVar g_dizzy;
ConVar g_lunacy;
ConVar g_monastery;
ConVar g_shoots;
ConVar g_kasbah;
ConVar g_agency;
ConVar g_assault;
ConVar g_downtown;
ConVar g_insertion;
ConVar g_italy;
ConVar g_militia;
ConVar g_motel;
ConVar g_office;
ConVar g_rush;
ConVar g_siege;
ConVar g_thunder;
ConVar g_ali;
ConVar g_aztec;
ConVar g_bank;
ConVar g_blackgold;
ConVar g_breach;
ConVar g_cache;
ConVar g_canals;
ConVar g_decbble;
ConVar g_chinatown;
ConVar g_dust;
ConVar g_dust2;
ConVar g_favela;
ConVar g_gwalior;
ConVar g_inferno;
ConVar g_lake;
ConVar g_mirage;
ConVar g_mist;
ConVar g_nuke;
ConVar g_overgrown;
ConVar g_overpass;
ConVar g_ruins;
ConVar g_safehouse;
ConVar g_seaside;
ConVar g_shortdust;
ConVar g_shortnuke;
ConVar g_shorttrain;
ConVar g_stmarc;
ConVar g_studio;
ConVar g_sugarcane;
ConVar g_train;
ConVar g_vertigo;
ConVar g_blacksite;
ConVar g_junglety;
ConVar g_sirocco;
ConVar g_cbble;
ConVar g_rialto;
ConVar g_training;

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Automatic Delete Default Maps",
	author = "SpirT | Edited: somebody.",
	description = "Automatic Delete Default Maps",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnPluginStart()
{
	g_baggage = CreateConVar("mapdel_baggage", "1", "Deletes all ar_baggage files");
	g_dizzy = CreateConVar("mapdel_dizzy", "1", "Deletes all ar_dizzy files");
	g_lunacy = CreateConVar("mapdel_lunacy", "1", "Deletes all ar_lunacy files");
	g_monastery = CreateConVar("mapdel_monastery", "1", "Deletes all ar_monastery files");
	g_shoots = CreateConVar("mapdel_shoots", "1", "Deletes all ar_shoots files");
	g_kasbah = CreateConVar("mapdel_kasbah", "1", "Deletes all coop_kasbah files");
	g_agency = CreateConVar("mapdel_agency", "1", "Deletes all cs_agency files");
	g_assault = CreateConVar("mapdel_assault", "1", "Deletes all cs_assault files");
	g_downtown = CreateConVar("mapdel_downtown", "1", "Deletes all cs_downtown files");
	g_insertion = CreateConVar("mapdel_insertion", "1", "Deletes all cs_insertion files");
	g_italy = CreateConVar("mapdel_italy", "1", "Deletes all cs_italy files");
	g_militia = CreateConVar("mapdel_militia", "1", "Deletes all cs_militia files");
	g_motel = CreateConVar("mapdel_motel", "1", "Deletes all cs_motel files");
	g_office = CreateConVar("mapdel_office", "1", "Deletes all cs_office files");
	g_rush = CreateConVar("mapdel_rush", "1", "Deletes all cs_rush files");
	g_siege = CreateConVar("mapdel_siege", "1", "Deletes all cs_siege files");
	g_thunder = CreateConVar("mapdel_thunder", "1", "Deletes all cs_thunder files");
	g_ali = CreateConVar("mapdel_ali", "1", "Deletes all de_ali files");
	g_aztec = CreateConVar("mapdel_aztec", "1", "Deletes all de_aztec files");
	g_bank = CreateConVar("mapdel_bank", "1", "Deletes all de_bank files");
	g_blackgold = CreateConVar("mapdel_blackgold", "1", "Deletes all de_blackgold files");
	g_breach = CreateConVar("mapdel_breach", "1", "Deletes all de_breach files");
	g_cache = CreateConVar("mapdel_cache", "1", "Deletes all de_cache files");
	g_canals = CreateConVar("mapdel_canals", "1", "Deletes all de_canals files");
	g_decbble = CreateConVar("mapdel_cbble", "1", "Deletes all de_cbble files");
	g_chinatown = CreateConVar("mapdel_chinatown", "1", "Deletes all de_chinatown files");
	g_dust = CreateConVar("mapdel_dust", "1", "Deletes all de_dust files");
	g_dust2 = CreateConVar("mapdel_dust2", "1", "Deletes all de_dust2 files");
	g_favela = CreateConVar("mapdel_favela", "1", "Deletes all de_favela files");
	g_gwalior = CreateConVar("mapdel_gwalior", "1", "Deletes all de_gwalior files");
	g_inferno = CreateConVar("mapdel_inferno", "1", "Deletes all de_inferno files");
	g_lake = CreateConVar("mapdel_lake", "1", "Deletes all de_lake files");
	g_mirage = CreateConVar("mapdel_mirage", "1", "Deletes all de_mirage files");
	g_mist = CreateConVar("mapdel_mist", "1", "Deletes all de_mist files");
	g_nuke = CreateConVar("mapdel_nuke", "1", "Deletes all de_nuke files");
	g_overgrown = CreateConVar("mapdel_overgrown", "1", "Deletes all de_overgrown files");
	g_overpass = CreateConVar("mapdel_overpass", "1", "Deletes all de_overpass files");
	g_ruins = CreateConVar("mapdel_ruins", "1", "Deletes all de_ruins files");
	g_safehouse = CreateConVar("mapdel_safehouse", "1", "Deletes all de_safehouse files");
	g_seaside = CreateConVar("mapdel_seaside", "1", "Deletes all de_seaside files");
	g_shortdust = CreateConVar("mapdel_shortdust", "1", "Deletes all de_shortdust files");
	g_shortnuke = CreateConVar("mapdel_shortnuke", "1", "Deletes all de_shortnuke files");
	g_shorttrain = CreateConVar("mapdel_shorttrain", "1", "Deletes all de_shorttrain files");
	g_stmarc = CreateConVar("mapdel_stmarc", "1", "Deletes all de_stmarc files");
	g_studio = CreateConVar("mapdel_studio", "1", "Deletes all de_studio files");
	g_sugarcane = CreateConVar("mapdel_sugarcane", "1", "Deletes all de_sugarcane files");
	g_train = CreateConVar("mapdel_train", "1", "Deletes all de_train files");
	g_vertigo = CreateConVar("mapdel_vertigo", "1", "Deletes all de_vertigo files");
	g_blacksite = CreateConVar("mapdel_blacksite", "1", "Deletes all dz_blacksite files");
	g_junglety = CreateConVar("mapdel_junglety", "1", "Deletes all dz_junglety files");
	g_sirocco = CreateConVar("mapdel_sirocco", "1", "Deletes all dz_sirocco files");
	g_cbble = CreateConVar("mapdel_cbble", "1", "Deletes all gd_cbble files");
	g_rialto = CreateConVar("mapdel_rialto", "1", "Deletes all gd_rialto files");
	g_training = CreateConVar("mapdel_training", "1", "Deletes all training1 files");

	AutoExecConfig(true, "mapdelete");
}

void cvars()
{
	baggage = GetConVarInt(g_baggage);
	dizzy = GetConVarInt(g_dizzy);
	lunacy = GetConVarInt(g_lunacy);
	monastery = GetConVarInt(g_monastery);
	shoots = GetConVarInt(g_shoots);
	kasbah = GetConVarInt(g_kasbah);
	agency = GetConVarInt(g_agency);
	assault = GetConVarInt(g_assault);
	downtown = GetConVarInt(g_downtown);
	insertion = GetConVarInt(g_insertion);
	italy = GetConVarInt(g_italy);
	militia = GetConVarInt(g_militia);
	motel = GetConVarInt(g_motel);
	office = GetConVarInt(g_office);
	rush = GetConVarInt(g_rush);
	siege = GetConVarInt(g_siege);
	thunder = GetConVarInt(g_thunder);
	ali = GetConVarInt(g_ali);
	aztec = GetConVarInt(g_aztec);
	bank = GetConVarInt(g_bank);
	blackgold = GetConVarInt(g_blackgold);
	breach = GetConVarInt(g_breach);
	cache = GetConVarInt(g_cache);
	canals = GetConVarInt(g_canals);
	de_cbble = GetConVarInt(g_decbble);
	chinatown = GetConVarInt(g_chinatown);
	dust = GetConVarInt(g_dust);
	dust2 = GetConVarInt(g_dust2);
	favela = GetConVarInt(g_favela);
	gwalior = GetConVarInt(g_gwalior);
	inferno = GetConVarInt(g_inferno);
	lake = GetConVarInt(g_lake);
	mirage = GetConVarInt(g_mirage);
	mist = GetConVarInt(g_mist);
	nuke = GetConVarInt(g_nuke);
	overgrown = GetConVarInt(g_overgrown);
	overpass = GetConVarInt(g_overpass);
	ruins = GetConVarInt(g_ruins);
	safehouse = GetConVarInt(g_safehouse);
	seaside = GetConVarInt(g_seaside);
	shortdust = GetConVarInt(g_shortdust);
	shortnuke = GetConVarInt(g_shortnuke);
	shorttrain = GetConVarInt(g_shorttrain);
	stmarc = GetConVarInt(g_stmarc);
	studio = GetConVarInt(g_studio);
	sugarcane = GetConVarInt(g_sugarcane);
	train = GetConVarInt(g_train);
	vertigo = GetConVarInt(g_vertigo);
	blacksite = GetConVarInt(g_blacksite);
	junglety = GetConVarInt(g_junglety);
	sirocco = GetConVarInt(g_sirocco);
	cbble = GetConVarInt(g_cbble);
	rialto = GetConVarInt(g_rialto);
	training = GetConVarInt(g_training);
}

public void OnMapStart()
{
	DeleteAllMaps();
	return;
}

void DeleteAllMaps()
{
	cvars();
	
	if(baggage == 1)
	{
		char bsp[] = "maps/ar_baggage.bsp";
		char nav[] = "maps/ar_baggage.nav";
		char jpg[] = "maps/ar_baggage.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(dizzy == 1)
	{
		char bsp[] = "maps/ar_dizzy.bsp";
		char nav[] = "maps/ar_dizzy.nav";
		char jpg[] = "maps/ar_dizzy.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(lunacy == 1)
	{
		char bsp[] = "maps/ar_lunacy.bsp";
		char nav[] = "maps/ar_lunacy.nav";
		char jpg[] = "maps/ar_lunacy.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(monastery == 1)
	{
		char bsp[] = "maps/ar_monastery.bsp";
		char nav[] = "maps/ar_monastery.nav";
		char jpg[] = "maps/ar_monastery.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(shoots == 1)
	{
		char bsp[] = "maps/ar_shoots.bsp";
		char nav[] = "maps/ar_shoots.nav";
		char jpg[] = "maps/ar_shoots.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(kasbah == 1)
	{
		char bsp[] = "maps/coop_kasbah.bsp";
		char nav[] = "maps/coop_kasbah.nav";
		char jpg[] = "maps/coop_kasbah.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(agency == 1)
	{
		char bsp[] = "maps/cs_agency.bsp";
		char nav[] = "maps/cs_agency.nav";
		char jpg[] = "maps/cs_agency.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(assault == 1)
	{
		char bsp[] = "maps/cs_assault.bsp";
		char nav[] = "maps/cs_assault.nav";
		char jpg[] = "maps/cs_assault.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(downtown == 1)
	{
		char bsp[] = "maps/cs_downtown.bsp";
		char nav[] = "maps/cs_downtown.nav";
		char jpg[] = "maps/cs_downtown.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(insertion == 1)
	{
		char bsp[] = "maps/cs_insertion.bsp";
		char nav[] = "maps/cs_insertion.nav";
		char jpg[] = "maps/cs_insertion.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(italy == 1)
	{
		char bsp[] = "maps/cs_italy.bsp";
		char nav[] = "maps/cs_italy.nav";
		char jpg[] = "maps/cs_italy.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(militia == 1)
	{
		char bsp[] = "maps/cs_militia.bsp";
		char nav[] = "maps/cs_militia.nav";
		char jpg[] = "maps/cs_militia.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(motel == 1)
	{
		char bsp[] = "maps/cs_motel.bsp";
		char nav[] = "maps/cs_motel.nav";
		char jpg[] = "maps/cs_motel.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(office == 1)
	{
		char bsp[] = "maps/cs_office.bsp";
		char nav[] = "maps/cs_office.nav";
		char jpg[] = "maps/cs_office.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(rush == 1)
	{
		char bsp[] = "maps/cs_rush.bsp";
		char nav[] = "maps/cs_rush.nav";
		char jpg[] = "maps/cs_rush.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(siege == 1)
	{
		char bsp[] = "maps/cs_siege.bsp";
		char nav[] = "maps/cs_siege.nav";
		char jpg[] = "maps/cs_siege.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(thunder == 1)
	{
		char bsp[] = "maps/cs_thunder.bsp";
		char nav[] = "maps/cs_thunder.nav";
		char jpg[] = "maps/cs_thunder.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(ali == 1)
	{
		char bsp[] = "maps/de_ali.bsp";
		char nav[] = "maps/de_ali.nav";
		char jpg[] = "maps/de_ali.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(aztec == 1)
	{
		char bsp[] = "maps/de_aztec.bsp";
		char nav[] = "maps/de_aztec.nav";
		char jpg[] = "maps/de_aztec.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(bank == 1)
	{
		char bsp[] = "maps/de_bank.bsp";
		char nav[] = "maps/de_bank.nav";
		char jpg[] = "maps/de_bank.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(blackgold == 1)
	{
		char bsp[] = "maps/de_blackgold.bsp";
		char nav[] = "maps/de_blackgold.nav";
		char jpg[] = "maps/de_blackgold.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(breach == 1)
	{
		char bsp[] = "maps/de_breach.bsp";
		char nav[] = "maps/de_breach.nav";
		char jpg[] = "maps/de_breach.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(cache == 1)
	{
		char bsp[] = "maps/de_cache.bsp";
		char nav[] = "maps/de_cache.nav";
		char jpg[] = "maps/de_cache.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(canals == 1)
	{
		char bsp[] = "maps/de_canals.bsp";
		char nav[] = "maps/de_canals.nav";
		char jpg[] = "maps/de_canals.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(de_cbble == 1)
	{
		char bsp[] = "maps/de_cbble.bsp";
		char nav[] = "maps/de_cbble.nav";
		char jpg[] = "maps/de_cbble.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(chinatown == 1)
	{
		char bsp[] = "maps/de_chinatown.bsp";
		char nav[] = "maps/de_chinatown.nav";
		char jpg[] = "maps/de_chinatown.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(dust == 1)
	{
		char bsp[] = "maps/de_dust.bsp";
		char nav[] = "maps/de_dust.nav";
		char jpg[] = "maps/de_dust.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(dust2 == 1)
	{
		char bsp[] = "maps/de_dust2.bsp";
		char nav[] = "maps/de_dust2.nav";
		char jpg[] = "maps/de_dust2.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(favela == 1)
	{
		char bsp[] = "maps/de_favela.bsp";
		char nav[] = "maps/de_favela.nav";
		char jpg[] = "maps/de_favela.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(gwalior == 1)
	{
		char bsp[] = "maps/de_gwalior.bsp";
		char nav[] = "maps/de_gwalior.nav";
		char jpg[] = "maps/de_gwalior.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(inferno == 1)
	{
		char bsp[] = "maps/de_inferno.bsp";
		char nav[] = "maps/de_inferno.nav";
		char jpg[] = "maps/de_inferno.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(lake == 1)
	{
		char bsp[] = "maps/de_lake.bsp";
		char nav[] = "maps/de_lake.nav";
		char jpg[] = "maps/de_lake.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(mirage == 1)
	{
		char bsp[] = "maps/de_mirage.bsp";
		char nav[] = "maps/de_mirage.nav";
		char jpg[] = "maps/de_mirage.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(mist == 1)
	{
		char bsp[] = "maps/de_mist.bsp";
		char nav[] = "maps/de_mist.nav";
		char jpg[] = "maps/de_mist.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(nuke == 1)
	{
		char bsp[] = "maps/de_nuke.bsp";
		char nav[] = "maps/de_nuke.nav";
		char jpg[] = "maps/de_nuke.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(overgrown == 1)
	{
		char bsp[] = "maps/de_overgrown.bsp";
		char nav[] = "maps/de_overgrown.nav";
		char jpg[] = "maps/de_overgrown.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(overpass == 1)
	{
		char bsp[] = "maps/de_overpass.bsp";
		char nav[] = "maps/de_overpass.nav";
		char jpg[] = "maps/de_overpass.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(ruins == 1)
	{
		char bsp[] = "maps/de_ruins.bsp";
		char nav[] = "maps/de_ruins.nav";
		char jpg[] = "maps/de_ruins.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(safehouse == 1)
	{
		char bsp[] = "maps/de_safehouse.bsp";
		char nav[] = "maps/de_safehouse.nav";
		char jpg[] = "maps/de_safehouse.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(seaside == 1)
	{
		char bsp[] = "maps/de_seaside.bsp";
		char nav[] = "maps/de_seaside.nav";
		char jpg[] = "maps/de_seaside.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(shortdust == 1)
	{
		char bsp[] = "maps/de_shortdust.bsp";
		char nav[] = "maps/de_shortdust.nav";
		char jpg[] = "maps/de_shortdust.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(shortnuke == 1)
	{
		char bsp[] = "maps/de_shortnuke.bsp";
		char nav[] = "maps/de_shortnuke.nav";
		char jpg[] = "maps/de_shortnuke.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(shorttrain == 1)
	{
		char bsp[] = "maps/de_shorttrain.bsp";
		char nav[] = "maps/de_shorttrain.nav";
		char jpg[] = "maps/de_shorttrain.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(stmarc == 1)
	{
		char bsp[] = "maps/de_stmarc.bsp";
		char nav[] = "maps/de_stmarc.nav";
		char jpg[] = "maps/de_stmarc.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(studio == 1)
	{
		char bsp[] = "maps/de_studio.bsp";
		char nav[] = "maps/de_studio.nav";
		char jpg[] = "maps/de_studio.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(sugarcane == 1)
	{
		char bsp[] = "maps/de_sugarcane.bsp";
		char nav[] = "maps/de_sugarcane.nav";
		char jpg[] = "maps/de_sugarcane.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(train == 1)
	{
		char bsp[] = "maps/de_train.bsp";
		char nav[] = "maps/de_train.nav";
		char jpg[] = "maps/de_train.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(vertigo == 1)
	{
		char bsp[] = "maps/de_vertigo.bsp";
		char nav[] = "maps/de_vertigo.nav";
		char jpg[] = "maps/de_vertigo.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(blacksite == 1)
	{
		char bsp[] = "maps/dz_blacksite.bsp";
		char nav[] = "maps/dz_blacksite.nav";
		char jpg[] = "maps/dz_blacksite.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(junglety == 1)
	{
		char bsp[] = "maps/dz_junglety.bsp";
		char nav[] = "maps/dz_junglety.nav";
		char jpg[] = "maps/dz_junglety.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(sirocco == 1)
	{
		char bsp[] = "maps/dz_sirocco.bsp";
		char nav[] = "maps/dz_sirocco.nav";
		char jpg[] = "maps/dz_sirocco.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(cbble == 1)
	{
		char bsp[] = "maps/gd_cbble.bsp";
		char nav[] = "maps/gd_cbble.nav";
		char jpg[] = "maps/gd_cbble.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(rialto == 1)
	{
		char bsp[] = "maps/gd_rialto.bsp";
		char nav[] = "maps/gd_rialto.nav";
		char jpg[] = "maps/gd_rialto.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
	if(training == 1)
	{
		char bsp[] = "maps/training1.bsp";
		char nav[] = "maps/training1.nav";
		char jpg[] = "maps/training1.jpg";
		
		if(FileExists(bsp))
		{
			DeleteFile(bsp);
		}
		if(FileExists(nav))
		{
			DeleteFile(nav);
		}
		if(FileExists(jpg))
		{
			DeleteFile(jpg);
		}
	}
}