#if defined _marquee_included_
  #endinput
#endif
#define _marquee_included_

public SharedPlugin:__pl_marquee =
{
	name = "Marquee",
	file = "marquee.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

native bool:Marquee_Start(const clients[], numClients, const String:message[], bool:intercept=true);

native bool:Marquee_StartOne(client, const String:message[], bool:intercept=true);

native bool:Marquee_StartAll(const String:message[], bool:intercept=true);

native Marquee_Stop(client);

native bool:Marquee_IsRunning(client);

forward Action:Marquee_OnStart(client, const String:sMessage[]);