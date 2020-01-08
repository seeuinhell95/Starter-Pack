#if defined _gloves_included_
  #endinput
#endif
#define _gloves_included_

native bool Gloves_IsClientUsingGloves(int client);

native void Gloves_RegisterCustomArms(int client, const char[] armsModel);

native void Gloves_SetArmsModel(int client, const char[] armsModel);

native void Gloves_GetArmsModel(int client, char[] armsModel, int size);