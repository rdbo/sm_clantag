#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define ADMFLAG_CLANTAG ADMFLAG_GENERIC

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
bool   g_Changed[MAXPLAYERS + 1];

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
            if (g_Changed[client])
            {
                PrintToChat(client, "[SM] You cannot change your clan tag");
                return Plugin_Handled;
            }
            
            g_Changed[client] = true;
            
            char admin_tag[64];
            char player_tag[64];
            
            g_cvAdminTag.GetString(admin_tag, sizeof(admin_tag));
            g_cvPlayerTag.GetString(player_tag, sizeof(player_tag));
            
            
            if (GetUserFlagBits(client))
            {
                CS_SetClientClanTag(client, admin_tag);
            }
            
            else
            {
                char cur_tag[64];
                
                CS_GetClientClanTag(client, cur_tag, sizeof(cur_tag));
                
                if (!strlen(player_tag) && !StrEqual(cur_tag, admin_tag))
                    return Plugin_Continue;
                
                CS_SetClientClanTag(client, player_tag);
            }
            
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}
