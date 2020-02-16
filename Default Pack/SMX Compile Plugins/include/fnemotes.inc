#if defined _fnemotes_included_
#endinput
#endif
#define _fnemotes_included_

native bool fnemotes_IsClientEmoting(int client);

forward void fnemotes_OnEmote(int client);

public void __pl_fnemotes_SetNTVOptional()
{
	MarkNativeAsOptional("fnemotes_IsClientEmoting");
}