Handle RepeatTimer;
int laiks;

int LastSound = 0;

public void Sounds_OnBuildTimeStart()
{
	RepeatTimer = CreateTimer(0.1, BB_RepeatTimer, _, TIMER_REPEAT);
	EmitSoundToAll("sourcemod/basebuilder/phase_build.mp3");
}

public void Sounds_OnPrepTimeStart()
{
	EmitSoundToAll("sourcemod/basebuilder/phase_prep.mp3");
}

public Action BB_RepeatTimer(Handle tmr)
{
	laiks = g_iCountdown;

	if(laiks == 120 && LastSound != 120)
	{
		EmitSoundToAll("sourcemod/basebuilder/2min.mp3");
		LastSound = laiks;	
	}

	else if(laiks == 60 && LastSound != 60)
	{
		EmitSoundToAll("sourcemod/basebuilder/1min.mp3");
		LastSound = laiks;
	}

	else if(laiks == 30 && LastSound != 30)
	{
		EmitSoundToAll("sourcemod/basebuilder/30sec.mp3");
		LastSound = laiks;	
	}

	else if(laiks == 10 && LastSound != 10)
	{
		EmitSoundToAll("sourcemod/basebuilder/10sec.mp3");
		LastSound = laiks;	
	}

	else if(laiks == 5 && LastSound != 5)
	{
		EmitSoundToAll("sourcemod/basebuilder/5sec.mp3");
		LastSound = laiks;	
	}

	if(laiks == 0)
	{
		if (RepeatTimer != null)
		{
			KillTimer(RepeatTimer);
			RepeatTimer = null;
		}	
	}
}

public void Sounds_OnPrepTimeEnd()
{
	int random = GetRandomInt(1, 2);
	if(random == 1)
		EmitSoundToAll("sourcemod/basebuilder/round_start.mp3");
	else
		EmitSoundToAll("sourcemod/basebuilder/round_start2.mp3");
}

public void Sounds_OnPlayerDeath(int client, int attacker)
{
	if(GetClientTeam(client) == BUILDERS && GetClientTeam(attacker) == ZOMBIES && !IsBuildTime() && !IsPrepTime())
		EmitSoundToAll("sourcemod/basebuilder/zombie_kill.mp3", attacker);
}

public void Sounds_RoundEnd(int winner_team)
{
	if(winner_team == BUILDERS)
		EmitSoundToAll("sourcemod/basebuilder/win_builders.mp3");
	else if(winner_team == ZOMBIES)
		EmitSoundToAll("sourcemod/basebuilder/win_zombies.mp3");
}

public void Sounds_PlayerHurt(int attacker)
{
	if(GetClientTeam(attacker) == ZOMBIES && !IsBuildTime() && !IsPrepTime())
		EmitSoundToClient(attacker, "sourcemod/basebuilder/hit.mp3");
}

public void Sounds_TookBlock(int client)
{
	EmitSoundToClient(client, "sourcemod/basebuilder/block_grab.mp3");
}

public void Sounds_DropBlock(int client)
{
	EmitSoundToClient(client, "sourcemod/basebuilder/block_drop.mp3");
}