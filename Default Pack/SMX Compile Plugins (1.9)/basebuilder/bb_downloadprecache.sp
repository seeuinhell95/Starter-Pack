public void OnMapStart()
{
	PrecacheSound("sourcemod/basebuilder/1min.mp3");
	PrecacheSound("sourcemod/basebuilder/2min.mp3");
	PrecacheSound("sourcemod/basebuilder/5sec.mp3");
	PrecacheSound("sourcemod/basebuilder/10sec.mp3");
	PrecacheSound("sourcemod/basebuilder/30sec.mp3");
	PrecacheSound("sourcemod/basebuilder/block_drop.mp3");
	PrecacheSound("sourcemod/basebuilder/block_grab.mp3"); 
	PrecacheSound("sourcemod/basebuilder/hit.mp3");
	PrecacheSound("sourcemod/basebuilder/phase_build.mp3");
	PrecacheSound("sourcemod/basebuilder/phase_prep.mp3");
	PrecacheSound("sourcemod/basebuilder/round_start.mp3");
	PrecacheSound("sourcemod/basebuilder/round_start2.mp3");
	PrecacheSound("sourcemod/basebuilder/win_builders.mp3");
	PrecacheSound("sourcemod/basebuilder/win_zombies.mp3");
	PrecacheSound("sourcemod/basebuilder/zombie_kill.mp3");

	PrecacheSound(SOUND_FREEZE);
	PrecacheSound(SOUND_FREEZE);
	PrecacheSound(SOUND_FREEZE_EXPLODE);
	PrecacheSound(SOUND_FREEZE_EXPLODE);

	PrecacheModel("materials/models/player/custom_player/zombie/mummy/mummy.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/mummy/mummy.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/mummy/mummy_n.vtf");
	PrecacheModel("models/player/custom_player/zombie/mummy/mummy.dx90.vtx");
	PrecacheModel("models/player/custom_player/zombie/mummy/mummy.mdl");
	PrecacheModel("models/player/custom_player/zombie/mummy/mummy.phy");
	PrecacheModel("models/player/custom_player/zombie/mummy/mummy.vvd");

	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadhead_d.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadhead_d.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadhead_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadhead_s.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadtorso_d.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadtorso_d.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadtorso_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/crimsonhead/crimsonheadtorso_s.vtf");
	PrecacheModel("models/player/custom_player/zombie/crimsonhead/crimsonhead.dx90.vtx");
	PrecacheModel("models/player/custom_player/zombie/crimsonhead/crimsonhead.mdl");
	PrecacheModel("models/player/custom_player/zombie/crimsonhead/crimsonhead.phy");
	PrecacheModel("models/player/custom_player/zombie/crimsonhead/crimsonhead.vvd");

	PrecacheModel("materials/models/player/custom_player/zombie/revenant/body.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/body.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/body_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/body_s.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/hat.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/hat.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/hat_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/hat_s.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/head.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/head.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/head_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/head_s.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/revenant/head_glow.vtf");
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.mdl");
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.dx90.vtx");
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.phy");
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.vvd");

	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/cloth.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/cloth_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/cloth.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/face.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/face_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/face.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hair.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hair_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hair.vmt");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hands.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hands_n.vtf");
	PrecacheModel("materials/models/player/custom_player/zombie/romeo_zombie/hands.vmt");
	PrecacheModel("models/player/custom_player/zombie/romeo_zombie/romeo_zombie.dx90.vtx");
	PrecacheModel("models/player/custom_player/zombie/romeo_zombie/romeo_zombie.mdl");
	PrecacheModel("models/player/custom_player/zombie/romeo_zombie/romeo_zombie.phy");
	PrecacheModel("models/player/custom_player/zombie/romeo_zombie/romeo_zombie.vvd");

	PrecacheModel("materials/models/player/custom_player/kodua/doom2016/hellknight/d.vtf");
	PrecacheModel("materials/models/player/custom_player/kodua/doom2016/hellknight/e.vtf");
	PrecacheModel("materials/models/player/custom_player/kodua/doom2016/hellknight/n.vtf");
	PrecacheModel("materials/models/player/custom_player/kodua/doom2016/hellknight/hkt_main_d.vmt");
	PrecacheModel("models/player/custom_player/kodua/doom2016/hellknight.mdl");
	PrecacheModel("models/player/custom_player/kodua/doom2016/hellknight.phy");
	PrecacheModel("models/player/custom_player/kodua/doom2016/hellknight.vvd");
	PrecacheModel("models/player/custom_player/kodua/doom2016/hellknight.dx90.vtx");

	g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");

	BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheModel("materials/overlays/white.vtf", true);
	PrecacheModel("materials/overlays/white.vmt", true);
	PrecacheModel("materials/overlays/friends2.vtf", true);
	PrecacheModel("materials/overlays/friends2.vmt", true);
}