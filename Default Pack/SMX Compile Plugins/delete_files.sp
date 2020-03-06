#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CSGO] Automatic Delete Default Files",
	author = "SpirT, StickZ & Ilusion9 | Edited: somebody.",
	description = "Automatic Delete Default Files",
	version = "1.0",
	url = "http://sourcemod.net"
};

public void OnMapStart()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/delete_files.cfg");

	KeyValues kv = new KeyValues("Delete Files");
	if (!kv.ImportFromFile(path))
	{
		delete kv;
		LogError("The configuration file could not be read.");
		return;
	}

	if (!kv.JumpToKey("Configs"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Configs\" section could not be found).");
		return;
	}

	char buffer[PLATFORM_MAX_PATH];
	if (kv.GotoFirstSubKey(false))
	{
		do
		{
			if (!kv.GetSectionName(buffer, sizeof(buffer)))
			{
				continue;
			}

			DeleteConfigFile(buffer);

		} while (kv.GotoNextKey(false));
	}

	kv.Rewind();
	if (!kv.JumpToKey("Maps"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Maps\" section could not be found).");
		return;
	}

	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	if (kv.GotoFirstSubKey(false))
	{
		do
		{
			if (!kv.GetSectionName(buffer, sizeof(buffer)))
			{
				continue;
			}

			if (StrEqual(buffer, currentMap, false))
			{
				continue;
			}

			DeleteMapFiles(buffer);

		} while (kv.GotoNextKey(false));
	}

	delete kv;
}

void DeleteConfigFile(const char[] cfg)
{
	char file[PLATFORM_MAX_PATH];		
	Format(file, sizeof(file), "cfg/%s.cfg", cfg);

	if (FileExists(file))
	{
		DeleteFile(file);
	}
}

void DeleteMapFiles(const char[] map)
{
	char file[PLATFORM_MAX_PATH];		

	Format(file, sizeof(file), "maps/%s.bsp", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}

	Format(file, sizeof(file), "maps/%s.nav", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}

	Format(file, sizeof(file), "maps/%s.jpg", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}

	Format(file, sizeof(file), "maps/%s.txt", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}

	Format(file, sizeof(file), "maps/%s_story.txt", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}

	Format(file, sizeof(file), "maps/%s_cameras.txt", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}
}