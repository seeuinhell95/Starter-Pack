const int MAX_LANG = 40;

Database db = null;

char configPath[PLATFORM_MAX_PATH];

ConVar g_Cvar_DBConnection;
char g_DBConnection[32];
char g_DBConnectionOld[32];

ConVar g_Cvar_TablePrefix;
char g_TablePrefix[10];

ConVar g_Cvar_ChatPrefix;
char g_ChatPrefix[32];

ConVar g_Cvar_FloatIncrementSize;
float g_fFloatIncrementSize;
int g_iFloatIncrementPercentage;

ConVar g_Cvar_EnableFloat;
int g_iEnableFloat;

ConVar g_Cvar_EnableWorldModel;
int g_iEnableWorldModel;

int g_iGroup[MAXPLAYERS+1][4];
int g_iGloves[MAXPLAYERS+1][4];
float g_fFloatValue[MAXPLAYERS+1][4];
char g_CustomArms[MAXPLAYERS+1][4][256];
int g_iTeam[MAXPLAYERS+1] = { 0, ... };
Handle g_FloatTimer[MAXPLAYERS+1] = { INVALID_HANDLE, ... };
int g_iSteam32[MAXPLAYERS+1] = { 0, ... };

char g_Language[MAX_LANG][32];
int g_iClientLanguage[MAXPLAYERS+1];
Menu menuGlovesGroup[MAX_LANG][4];
Menu menuGloves[MAX_LANG][4][8];

StringMap g_smGlovesGroupIndex;
StringMap g_smLanguageIndex;