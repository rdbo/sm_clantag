#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define ADMFLAG_ADM (ADMFLAG_GENERIC | ADMFLAG_ROOT)
#define ADMFLAG_VIP ADMFLAG_RESERVATION

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
ConVar g_cvVipTag;
char   g_sAdminTag[64];
char   g_sPlayerTag[64];
char   g_sVipTag[64];

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
    g_cvVipTag = CreateConVar("sm_clantag_vip", "[VIP]", "VIP Custom Clan Tag");
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
            g_cvVipTag.GetString(g_sVipTag, sizeof(g_sVipTag));
            
            int flag = GetUserFlagBits(client);
            
            if (flag & ADMFLAG_ADM)
            {
                CS_SetClientClanTag(client, g_sAdminTag);
                return Plugin_Handled;
            }
            
            if (flag & ADMFLAG_VIP)
            {
                CS_SetClientClanTag(client, g_sVipTag);
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
    
    if (!strlen(sCurTag) || (StrEqual(sCurTag, g_sAdminTag) && !StrEqual(g_sAdminTag, g_sPlayerTag)) || (StrEqual(sCurTag, g_sVipTag) && !StrEqual(g_sVipTag, g_sPlayerTag)))
    {
        CS_SetClientClanTag(client, g_sPlayerTag);
    }
}
