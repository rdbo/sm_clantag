#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name        = "Force Clan Tag",
    author      = "rdbo",
    description = "Force Players Clan Tag",
    version     = "1.0.0",
    url         = ""
};

ConVar g_cvClanTagEnabled;
ConVar g_cvPlayerTag;
ConVar g_cvAdminTag;

public void OnPluginStart()
{
    EngineVersion g_Game = GetEngineVersion();
    if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
    {
        PrintToServer("[SM] Force Clan Tag Error (Invalid Game Engine)");
        return;
    }
    
    PrintToServer("[SM] Force Clan Tag Loaded");
    g_cvClanTagEnabled = CreateConVar("sm_clantag_enabled", "1", "Enable Custom Clan Tags");
    g_cvAdminTag = CreateConVar("sm_clantag_admin", "[ADMIN]", "Admin Custom Clan Tag");
    g_cvPlayerTag = CreateConVar("sm_clantag_player", "[PLAYER]", "Player Custom Clan Tag");
    HookEvent("player_team", HkPlayerTeam);
}

public void HkPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!g_cvClanTagEnabled.BoolValue || !client)
        return;
    
    ConVar cvTag = g_cvPlayerTag;
    
    if (GetUserFlagBits(client))
    {
        cvTag = g_cvAdminTag;
    }
    
    char tag[64] = { 0 };
    char player_tag[64] = { 0 };
    char admin_tag[64] = { 0 };
    
    CS_GetClientClanTag(client, player_tag, sizeof(player_tag));
    cvTag.GetString(tag, sizeof(tag));
    g_cvAdminTag.GetString(admin_tag, sizeof(admin_tag));
    
    if (!strlen(tag) && !StrEqual(player_tag, admin_tag))
        return;
    
    CS_SetClientClanTag(client, tag);
}
