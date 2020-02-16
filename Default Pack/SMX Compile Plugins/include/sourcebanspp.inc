#if defined _sourcebanspp_included
#endinput
#endif
#define _sourcebanspp_included

public SharedPlugin __pl_sourcebanspp =
{
	name = "sourcebans++",
	file = "sbpp_main.smx",
	#if defined REQUIRE_PLUGIN
	required = 1
	#else
	required = 0
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_sourcebanspp_SetNTVOptional()
{
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SBPP_BanPlayer");
	MarkNativeAsOptional("SBPP_ReportPlayer");
}
#endif

#pragma deprecated Use SBPP_BanPlayer() instead.

native void SBBanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);

native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);

native void SBPP_ReportPlayer(int iReporter, int iTarget, const char[] sReason);

forward void SBPP_OnBanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);

forward void SBPP_OnReportPlayer(int iReporter, int iTarget, const char[] sReason);