#if defined _basecomm_included
 #endinput
#endif
#define _basecomm_included

forward void BaseComm_OnClientMute(int client, bool muteState);

forward void BaseComm_OnClientGag(int client, bool gagState);

native bool BaseComm_IsClientGagged(int client);

native bool BaseComm_IsClientMuted(int client);

native bool BaseComm_SetClientGag(int client, bool gagState);

native bool BaseComm_SetClientMute(int client, bool muteState);

public SharedPlugin __pl_basecomm =
{
	name = "basecomm_edited",
	file = "basecomm_edited.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_basecomm_SetNTVOptional()
{
	MarkNativeAsOptional("BaseComm_IsClientGagged");
	MarkNativeAsOptional("BaseComm_IsClientMuted");
	MarkNativeAsOptional("BaseComm_SetClientGag");
	MarkNativeAsOptional("BaseComm_SetClientMute");
}
#endif