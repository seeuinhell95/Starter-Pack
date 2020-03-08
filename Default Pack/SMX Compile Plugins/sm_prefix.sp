#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[CSGO] SM Prefix Changer",
	author = "Bacardi | Edited: somebody.",
	description = "SM Prefix Changer",
	version = "1.0",
	url = "http://sourcemod.net"
};

public OnPluginStart()
{
	if(GetUserMessageType() == UM_Protobuf)
	{
		HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true);
	}
}

public Action: TextMsg(UserMsg:msg_id, Handle:pb, players[], playersNum, bool:reliable, bool:init)
{
	if(!reliable || PbReadInt(pb, "msg_dst") != 3)
	{
		return Plugin_Continue;
	}

	new String:buffer[256];
	PbReadString(pb, "params", buffer, sizeof(buffer), 0);

	if(StrContains(buffer, "[SM] ") == 0)
	{
		new Handle:pack;
		CreateDataTimer(0.0, new_output, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, playersNum);
		for(new i = 0; i < playersNum; i++)
		{
			WritePackCell(pack, players[i]);
		}
		WritePackCell(pack, strlen(buffer));
		WritePackString(pack, buffer);
		ResetPack(pack);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action: new_output(Handle:timer, Handle:pack)
{
	new playersNum = ReadPackCell(pack);
	new players[playersNum];
	new player, players_count;

	for(new i = 0; i < playersNum; i++)
	{
		player = ReadPackCell(pack);

		if(IsClientInGame(player))
		{
			players[players_count++] = player;
		}
	}

	playersNum = players_count;

	if(playersNum < 1)
	{
		return;
	}

	new Handle:pb = StartMessage("TextMsg", players, playersNum, USERMSG_BLOCKHOOKS);
	PbSetInt(pb, "msg_dst", 3);

	new buffer_size = ReadPackCell(pack)+15;
	new String:buffer[buffer_size];
	ReadPackString(pack, buffer, buffer_size);

	Format(buffer, buffer_size, " \x09[\x06SM\x09]\x02%s", buffer[4]);

	PbAddString(pb, "params", buffer);
	PbAddString(pb, "params", NULL_STRING);
	PbAddString(pb, "params", NULL_STRING);
	PbAddString(pb, "params", NULL_STRING);
	PbAddString(pb, "params", NULL_STRING);
	EndMessage();
}