stock void GetRandomSkin(int client, int team, char[] output, int outputSize, int group = -1)
{
	int max;
	int random;
	if(group != -1)
	{
		char groupStr[10];
		IntToString(group, groupStr, sizeof(groupStr));
		g_smGlovesGroupIndex.GetValue(groupStr, random);
	}
	else
	{
		max = menuGlovesGroup[g_iClientLanguage[client]][team].ItemCount - 1;
		random = GetRandomInt(2, max) - 1;
	}

	max = menuGloves[g_iClientLanguage[client]][team][random].ItemCount - 1;
	int random2 = GetRandomInt(1, max);
	menuGloves[g_iClientLanguage[client]][team][random].GetItem(random2, output, outputSize);
}

stock bool IsValidClient(int client)
{
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
    {
        return false;
    }
    return true;
}

stock void FirstCharUpper(char[] string)
{
	if (strlen(string) > 0)
	{
		string[0] = CharToUpper(string[0]);
	}
}

stock void FixCustomArms(int client)
{
	char temp[2];
	GetEntPropString(client, Prop_Send, "m_szArmsModel", temp, sizeof(temp));
	if(temp[0])
	{
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
	}
}