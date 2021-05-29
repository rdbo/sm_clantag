#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name        = "SM Clan Tag",
    author      = "rdbo",
    description = "Force Players Clan Tag",
    version     = "1.0.0",
    url         = ""
};

ConVar g_cvClanTagEnabled;
ConVar g_cvPlayerTag;
ConVar g_cvAdminTag;
char   g_sAdminTag[64];
char   g_sPlayerTag[64];

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
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
    if (!g_cvClanTagEnabled.BoolValue)
        return Plugin_Continue;
    
    char sCmd[64] = { 0 };
    if (kv.GetSectionName(sCmd, sizeof(sCmd)))
    {
        if (StrEqual(sCmd, "ClanTagChanged"))
        {
            g_cvAdminTag.GetString(g_sAdminTag, sizeof(g_sAdminTag));
            g_cvPlayerTag.GetString(g_sPlayerTag, sizeof(g_sPlayerTag));
            
            if (GetUserFlagBits(client))
            {
                CS_SetClientClanTag(client, g_sAdminTag);
                return Plugin_Handled;
            }
            
            RequestFrame(HandlePlayerTag, client);
        }
    }
    
    return Plugin_Continue;
}

public void HandlePlayerTag(int client)
{
    if (!client || !IsClientConnected(client))
        return;
        
    char sCurTag[64];
    
    CS_GetClientClanTag(client, sCurTag, sizeof(sCurTag));
    
    if (strlen(g_sPlayerTag) || (StrEqual(sCurTag, g_sAdminTag) && !StrEqual(g_sAdminTag, g_sPlayerTag)))
    {
        CS_SetClientClanTag(client, g_sPlayerTag);
    }
}
