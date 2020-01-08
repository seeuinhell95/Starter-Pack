#if defined _collisionhook_included
 #endinput
#endif
#define _collisionhook_included

forward Action: CH_ShouldCollide(ent1, ent2, &bool:result);
forward Action: CH_PassFilter(ent1, ent2, &bool:result);

public Extension:__ext_collisionhook =
{
	name = "CollisionHook",
	file = "collisionhook.ext",

#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};