void CheckConfig()
{
	char file[PLATFORM_MAX_PATH];
	char map[64];
	char pref[10];
	
	GetCurrentMapEx(map, sizeof(map));
	BuildPath(Path_SM, file, sizeof(file), "configs/WeaponRestrict/%s.cfg", map);
	
	if(!RunFile(file))
	{
		SplitString(map, "_", pref, sizeof(pref));
		BuildPath(Path_SM, file, sizeof(file), "configs/WeaponRestrict/%s_.cfg", pref);
		RunFile(file);
	}
}