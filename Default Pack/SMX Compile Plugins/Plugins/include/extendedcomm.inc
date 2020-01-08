#if defined _extendedcomm_included
  #endinput
#endif
#define _extendedcomm_included

public SharedPlugin:__pl_extendecomm =
{
	name = "ExtendedComm",
	file = "extendedcomm.smx",
	required = 0
};

public __pl_extendecomm_SetNTVOptional()
{
	MarkNativeAsOptional("ExtendedComm_GetMuteType");
	MarkNativeAsOptional("ExtendedComm_GetMuteLength");
	MarkNativeAsOptional("ExtendedComm_GetMuteStart");
	MarkNativeAsOptional("ExtendedComm_GetMuteExpire");
	MarkNativeAsOptional("ExtendedComm_GetGagType");
	MarkNativeAsOptional("ExtendedComm_GetGagLength");
	MarkNativeAsOptional("ExtendedComm_GetGagStart");
	MarkNativeAsOptional("ExtendedComm_GetGagExpire");
}

native ExtendedComm_GetMuteType(client);

native ExtendedComm_GetMuteLength(client);

native ExtendedComm_GetMuteStart(client);

native ExtendedComm_GetMuteExpire(client);

native ExtendedComm_GetGagType(client);

native ExtendedComm_GetGagLength(client);

native ExtendedComm_GetGagStart(client);

native ExtendedComm_GetGagExpire(client);