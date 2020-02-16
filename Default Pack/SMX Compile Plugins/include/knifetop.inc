/*
 * Knifetop - .inc file
 * by: shavit
 *
 * This file is part of Knifetop.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
*/

// code mostly taken from my previous plugin, the timer
// https://github.com/Shavitush/bhoptimer

#if defined _knifetop_included
	#endinput
#endif
#define _knifetop_included

stock bool IsValidClient(int client, bool bAlive = false) // when bAlive is false = technical checks, when it's true = gameplay checks
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client) && (!bAlive || IsPlayerAlive(client)));
}

/**
 * Called when a knife kill gets count to stats.
 *
 * @param client					Client index.
 * @param newkills					Amount of knife kills after 
 * @noreturn
 */
forward void Knifetop_OnKnifeKill(int client, int newkills);

/**
 * Gets the amount of knife kills from a player. 
 *
 * @param client					Client index.
 * @return							Amount of knife kills. 0 if never killed with a knife.
 */
native int Knifetop_GetKnifeKills(int client);

public SharedPlugin __pl_knifetop = 
{
	name = "knifetop",
	file = "knifetop.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
