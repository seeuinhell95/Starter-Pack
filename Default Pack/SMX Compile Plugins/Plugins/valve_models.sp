#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Precache Valve Models",
	author = "Er!k | Edited: somebody.",
	description = "Precache Valve Models",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnMapStart()
{
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variantf.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_variantg.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_fbi_varianth.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_gign.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gign_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gign_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gign_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gign_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_gsg9.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gsg9_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gsg9_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gsg9_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_gsg9_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_idf.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_idf_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_idf_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_idf_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_idf_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_idf_variantf.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_sas.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_sas_variantf.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_st6.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantg.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_varianti.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantk.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_st6_variantm.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_swat.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_swat_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_swat_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_swat_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/ctm_swat_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_anarchist.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_anarchist_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_anarchist_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_anarchist_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_anarchist_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_balkan_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantf.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantg.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_varianth.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_varianti.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_balkan_variantj.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_leet_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variante.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variantf.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_variantg.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_varianth.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_leet_varianti.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_phoenix.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_variantd.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_variantf.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_variantg.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_varianth.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_pirate.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_pirate_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_pirate_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_pirate_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_pirate_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_professional.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_professional_var1.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_professional_var2.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_professional_var3.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_professional_var4.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_separatist.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_separatist_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_separatist_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_separatist_variantc.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_separatist_variantd.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_varianta.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_variantb.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_variantc.mdl", true);

	PrecacheModel("models/player/custom_player/legacy/ctm_heavy.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl", true);

	PrecacheModel("models/weapons/ct_arms.mdl", true);
	PrecacheModel("models/weapons/ct_arms_fbi.mdl", true);
	PrecacheModel("models/weapons/ct_arms_gign.mdl", true);
	PrecacheModel("models/weapons/ct_arms_gsg9.mdl", true);
	PrecacheModel("models/weapons/ct_arms_idf.mdl", true);
	PrecacheModel("models/weapons/ct_arms_sas.mdl", true);
	PrecacheModel("models/weapons/ct_arms_st6.mdl", true);
	PrecacheModel("models/weapons/ct_arms_swat.mdl", true);

	PrecacheModel("models/weapons/t_arms.mdl", true);
	PrecacheModel("models/weapons/t_arms_anarchist.mdl", true);
	PrecacheModel("models/weapons/t_arms_balkan.mdl", true);
	PrecacheModel("models/weapons/t_arms_leet.mdl", true);
	PrecacheModel("models/weapons/t_arms_phoenix.mdl", true);
	PrecacheModel("models/weapons/t_arms_pirate.mdl", true);
	PrecacheModel("models/weapons/t_arms_professional.mdl", true);
	PrecacheModel("models/weapons/t_arms_separatist.mdl", true);
	PrecacheModel("models/weapons/t_arms_workbench_leet.mdl", true);

	PrecacheModel("models/weapons/v_models/arms/fbi/v_sleeve_fbi.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/fbi/v_sleeve_fbi_dark.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/fbi/v_sleeve_fbi_gray.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/fbi/v_sleeve_fbi_green.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/st6/v_sleeve_flektarn.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/st6/v_sleeve_green.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/st6/v_sleeve_st6.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/st6/v_sleeve_usaf.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/sas/v_sleeve_sas.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/sas/v_sleeve_sas_ukmtp.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/swat/v_sleeve_swat.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/gign/v_sleeve_gign.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/gsg9/v_sleeve_gsg9.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/idf/v_sleeve_idf.mdl", true);

	PrecacheModel("models/weapons/v_models/arms/anarchist/v_sleeve_anarchist.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/balkan/v_sleeve_balkan.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/professional/v_sleeve_professional.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/separatist/v_sleeve_separatist.mdl", true);

	PrecacheModel("models/weapons/v_models/arms/wristband/v_sleeve_wristband.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/pirate/v_pirate_watch.mdl", true);

	PrecacheModel("models/weapons/v_models/arms/jumpsuit/v_sleeve_jumpsuit.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/bare/v_bare_hands.mdl", true);

	PrecacheModel("models/weapons/v_models/arms/anarchist/v_glove_anarchist.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_bloodhound/v_glove_bloodhound.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_bloodhound/v_glove_bloodhound_hydra.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_fingerless/v_glove_fingerless.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_fullfinger/v_glove_fullfinger.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_handwrap_leathery/v_glove_handwrap_leathery.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_hardknuckle/v_glove_hardknuckle.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_hardknuckle/v_glove_hardknuckle_black.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_hardknuckle/v_glove_hardknuckle_blue.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_motorcycle/v_glove_motorcycle.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_slick/v_glove_slick.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_specialist/v_glove_specialist.mdl", true);
	PrecacheModel("models/weapons/v_models/arms/glove_sporty/v_glove_sporty.mdl", true);

	PrecacheModel("models/weapons/w_models/arms/w_glove_anarchist_hands.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_bloodhound.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_bloodhound_hydra.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_fingerless.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_fullfinger.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_handwrap_leathery.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_hardknuckle.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_motorcycle.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_pirate_hands.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_slick.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_specialist.mdl", true);
	PrecacheModel("models/weapons/w_models/arms/w_glove_sporty.mdl", true);
}