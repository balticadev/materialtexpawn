/*
 ___________________________________________________________________
|                                                                  |
|                   Dynamic Material Text v2.0 System By                |
|               ____            ____         ___                   |
|               |___ U N K Y      |  HE     |  __ R E A T          |
|               |                 |         |___|                  |
|__________________________________________________________________|*/
 
#define FILTERSCRIPT
 
#include <a_samp>
#include <YSI\y_ini>
#include <zcmd>
#include <streamer>
#include <foreach>
#include <sscanf2>
// *** Defines *** ///
 
#define MPATH "Materials/%d.txt"    // Path where the Material saves.
#define MAX_FONT_NAME 30            // The limit of Max font name !
#define MAX_TEXT 50                 // The limit of Max text, That can be used !
#define MAX_MATERIALS 69            // Max amount of Materials
#define MAT_DEFAULT_OBJECT 19480    // The default object of material (when created)
#define MATERIAL_DEFAULT_INDEX 0    // The default index to set material text (when created)
#define dValue 100                  // Dialog value - starting from this Number.
 
/// ******************** ///
#define MYRED "{FF0000}"
#define MYBLUE "{0000FF}"
#define MYYELLOW "{FFFF00}"
#define MYORANGE "{FFA500}"
#define MYPURPLE "{800080}"
#define MYGREEN "{008000}"
#define MYLBLUE "{0080FF}"
#define MYWHITE "{FFFFFF}"
#define MYBLACK "{000000}"
#define MYCYAN "{00FFFF}"
#define MYPINK "{FF00FF}"
#define MYBROWN "{6A0000}"
#define MYLPURPLE "{8080C0}"
#define MYLGREEN "{00FF00}"
#define MYGREY "{676767}"
 
#define MRED 0xFFFF0000
#define MBLUE 0xFF0000FF
#define MYELLOW 0xFFFFFF00
#define MORANGE 0xFFFF8000
#define MPURPLE 0xFF400080
#define MGREEN 0xFF008000
#define MLBLUE 0xFF0080FF
#define MWHITE 0xFFFFFFFF
#define MBLACK 0xFF000000
#define MCYAN 0xFF00FFFF
#define MPINK 0xFFFF00FF
#define MBROWN 0xFF6A0000
#define MLPURPLE 0xFF8080C0
#define MLGREEN 0xFF00FF00
#define MGRAY 0xFF676767
 
enum MaterialInfo
{
    Float:MatX,
    Float:MatY,
    Float:MatZ,
    Float:MatRX,
    Float:MatRY,
    Float:MatRZ,
    MatText[MAX_TEXT],
    MatObj,
    MatSize,
    MatBGC,
    MatALG,
    MatFont[MAX_FONT_NAME],
    MatColor,
    MatBold,
    MatRes,
    MatObjectID,
    MatIndex,
}
new matInfo[MAX_MATERIALS][MaterialInfo];
 
new Iterator:MatsItr<MAX_MATERIALS>;
new SOID[MAX_PLAYERS];
forward CreateMat(type,id,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz);
 
#define DIALOG_MATS dValue+2
#define DIALOG_TEXT dValue+3
#define DIALOG_FONT dValue+4
#define DIALOG_DELETE dValue+5
#define DIALOG_FONTCOLOR dValue+6
#define DIALOG_FONTSIZE dValue+7
#define DIALOG_BGCOLOR dValue+8
#define DIALOG_ALLIGNMENT dValue+9
#define DIALOG_RESOLUTION dValue+10
#define DIALOG_CHANGEOBJECT dValue+11
#define DIALOG_CHANGEINDEX dValue+12
 
enum FontInformation
{
    FontName[MAX_FONT_NAME],
};
new FontInfo[][FontInformation] = // All the fonts, You can also add new one, Check example below.
{
    {"Lucida Console"},
    {"Verdana"},
    {"Webdings"},
    {"Wingdings"},
    {"Times New Roman"},
    {"Microsoft Sans Serif"},
    {"GTAWEAPON3"},
    {"Impact"},
    {"Georgia"},
    {"Arial"},
    {"Arial Black"},
    {"Comic Sans MS"},
    {"Trebuchet MS"}
//  {"YOUR FONT NAME"}
};
public OnFilterScriptInit()
{
    print("\n===================================");
    print("|  Dynamic Material Text System v2.0 |");
    print("|  By FuNkYTheGreat [LOADED]         |");
    print("=====================================\n");
    new string[25];
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
        format(string, sizeof(string), MPATH, i);
        if(fexist(string))
        {
            INI_ParseFile(string, "loadmat", .bExtra = true, .extra = i);
            CreateMat(2,i,matInfo[i][MatX],matInfo[i][MatY],matInfo[i][MatZ],matInfo[i][MatRX],matInfo[i][MatRY],matInfo[i][MatRZ]);
        }
    }
    return 1;
}
public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
        if(Iter_Contains(MatsItr,i))
        {
            SaveMat(i);
            DeleteMat(i);
        }
    }
    return 1;
}
CMD:createmat(playerid,params[])
{
    new string[90];
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
    if(Iter_Count(MatsItr) > MAX_MATERIALS) return SendClientMessage(playerid, -1 , ""MYRED"[MATERIAL]"MYWHITE" You've reached the total amount of Materials, Max Materials: "#MAX_MATERIALS");
    new id = Iter_Free(MatsItr);
    format(string, sizeof(string), ""MYRED"[MATERIAL]"MYWHITE" Material created succesfully, The Material id is %d", id);
    SendClientMessage(playerid, -1 , string);
    SetPVarInt(playerid,"matID",id);
    format(matInfo[id][MatText],30,"NEW MATERIAL");
    format(matInfo[id][MatFont],30,"Arial");
    matInfo[id][MatColor] = MRED;
    matInfo[id][MatObjectID] = MAT_DEFAULT_OBJECT;
    CreateMat(1,id,x,y,z,0,0,a);
    EditDynamicObject(playerid,matInfo[id][MatObj]);
    return 1;
}
CMD:nearmat(playerid, params[])
{
    new string[128],count = 0;
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 15.0, matInfo[i][MatX], matInfo[i][MatY], matInfo[i][MatZ]))
        {
            count = 1;
            SendClientMessage(playerid,-1,""MYRED" _________________________________Material Info _________________________________");
            format(string, sizeof(string), ""MYWHITE"ID: %d , Text: %s , Font Size: %d , Font Name: %s", i, matInfo[i][MatText] , matInfo[i][MatSize],matInfo[i][MatFont]);
            SendClientMessage(playerid,-1,string);
            SendClientMessage(playerid,-1,""MYRED"_________________________________________________________________________________");
            return 1;
        }
    }
    if(count == 0) return SendClientMessage(playerid,-1,""MYRED"[MATERIAL]"MYWHITE" You are not near any Material");
    return 1;
}
CMD:editmat(playerid, params[])
{
    new ID;
    if(sscanf(params, "i",ID)) return SendClientMessage(playerid, -1, ""MYRED"[MATERIAL]"MYWHITE" /editmat(erial) [id]");
    if(!Iter_Contains(MatsItr,ID)) return SendClientMessage(playerid, -1, ""MYRED"[MATERIAL]"MYWHITE" Material ID doesn't exists");
    ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
    SOID[playerid] = ID;
    return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new string[356];
    new ID = SOID[playerid];
    if(dialogid == DIALOG_MATS)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: ShowPlayerDialog(playerid, DIALOG_TEXT , DIALOG_STYLE_INPUT, "Material System - Change Text", "Please input the text", "Select", "Back");
            case 1:
            {
                for(new a=0; a<sizeof(FontInfo); a++)
                {
                    format(string, sizeof(string), "%s%s\n", string, FontInfo[a][FontName]);
                }
                ShowPlayerDialog(playerid, DIALOG_FONT , DIALOG_STYLE_LIST, "Material System - Choose Font", string, "Select", "Back");
            }
            case 2: ShowPlayerDialog(playerid, DIALOG_FONTCOLOR , DIALOG_STYLE_LIST, "Material System - Choose Color", ""MYRED"Red\n"MYBLUE"Blue\n"MYYELLOW"Yellow\n"MYORANGE"Orange\n"MYPURPLE"Purple\n"MYGREEN"Green\n"MYLBLUE"Light Blue\n"MYWHITE"White\n"MYBLACK"Black\n"MYCYAN"Cyan\n"MYPINK"Pink\n"MYBROWN"Brown\n"MYLPURPLE"Light Purple\n"MYLGREEN"Light Green\n"MYGREY"Gray", "Select", "Back");
            case 3: ShowPlayerDialog(playerid, DIALOG_FONTSIZE , DIALOG_STYLE_INPUT, "Material System - Font Size","Please enter a font size for your Material\nMust be Numeric.", "Enter", "Back");
            case 4: ShowPlayerDialog(playerid, DIALOG_BGCOLOR , DIALOG_STYLE_LIST, "Material System - Background Color",""MYRED"Red\n"MYBLUE"Blue\n"MYYELLOW"Yellow\n"MYORANGE"Orange\n"MYPURPLE"Purple\n"MYGREEN"Green\n"MYLBLUE"Light Blue\n"MYWHITE"White\n"MYBLACK"Black\n"MYCYAN"Cyan\n"MYPINK"Pink\n"MYBROWN"Brown\n"MYLPURPLE"Light Purple\n"MYLGREEN"Light Green\n"MYGREY"Gray\nNo Background", "Select", "Back");
            case 5: ShowPlayerDialog(playerid, DIALOG_ALLIGNMENT , DIALOG_STYLE_LIST, "Material System - Choose Allignment", "Left Allignment\nCenter Allignment\nRight Allignment", "Select", "Back");
            case 6:
            {
                format(string, sizeof(string), ""MYRED"[MATERIAL]"MYWHITE" Material Text %s", (matInfo[ID][MatBold] == 1) ? ("Un-Bolded") : ("Bolded"));
                SendClientMessage(playerid,-1,string);
                matInfo[ID][MatBold] =! matInfo[ID][MatBold];
                SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes], matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
                ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
            }
            case 7: ShowPlayerDialog(playerid, DIALOG_RESOLUTION , DIALOG_STYLE_LIST, "Material System - Choose Resolution", "32x32\n64x32\n64x64\n128x32\n128x64\n128x128\n256x32\n256x64\n256x128\n256x256\n512x64\n512x128\n512x256\n512x512", "Select", "Back");
            case 8:
            {
                EditDynamicObject(playerid,matInfo[ID][MatObj]);
                SetPVarInt(playerid,"matID",ID);
            }
            case 9:
            {
                new id = Iter_Free(MatsItr);
                matInfo[id][MatX] = matInfo[ID][MatX];
                matInfo[id][MatY] = matInfo[ID][MatY];
                matInfo[id][MatZ] = matInfo[ID][MatZ];
                matInfo[id][MatRX] = matInfo[ID][MatRX];
                matInfo[id][MatRY] = matInfo[ID][MatRY];
                matInfo[id][MatRZ] = matInfo[ID][MatRZ];
                matInfo[id][MatSize] = matInfo[ID][MatSize];
                matInfo[id][MatBGC] = matInfo[ID][MatBGC];
                matInfo[id][MatALG] = matInfo[ID][MatALG];
                matInfo[id][MatBold] = matInfo[ID][MatBold];
                matInfo[id][MatRes] = matInfo[ID][MatRes];
                matInfo[id][MatColor] = matInfo[ID][MatColor];
                matInfo[id][MatObjectID] = matInfo[ID][MatObjectID];
                matInfo[id][MatIndex] = matInfo[ID][MatIndex];
                SetPVarInt(playerid,"matID",id);
                format(matInfo[id][MatText],30,matInfo[ID][MatText]);
                format(matInfo[id][MatFont],30,matInfo[ID][MatFont]);
                CreateMat(2,id,matInfo[ID][MatX],matInfo[ID][MatY],matInfo[ID][MatZ],matInfo[ID][MatRX],matInfo[ID][MatY],matInfo[ID][MatZ]);
                EditDynamicObject(playerid,matInfo[id][MatObj]);
                format(string,sizeof(string),""MYRED"[MATERIAL]"MYWHITE" Material ID %d has been duplicated on ID: %d !",ID,id);
                SendClientMessage(playerid,-1,string);
            }
            case 10:
            {
                DeleteMat(ID);
                format(string,sizeof(string),""MYRED"[MATERIAL]"MYWHITE" Material ID: %d has been deleted !",ID);
                SendClientMessage(playerid,-1,string);
                format(string, sizeof(string), MPATH, ID);
                fremove(string);
            }
            case 11: ShowPlayerDialog(playerid, DIALOG_CHANGEOBJECT , DIALOG_STYLE_INPUT, "Material System - Object ID","Please enter an object ID to change!.", "Enter", "Back");
            case 12: ShowPlayerDialog(playerid, DIALOG_CHANGEINDEX , DIALOG_STYLE_INPUT, "Material System - Material Index","Please enter an material index to set the Text on, (0 to 15)!.", "Enter", "Back");
        }
    }
    if(dialogid == DIALOG_TEXT)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        if(strlen(inputtext) >= MAX_TEXT || strlen(inputtext) <= 0 ) return SendClientMessage(playerid, -1 ,""MYRED"[MATERIAL]"MYWHITE" Text may not be less than 0 or more than "#MAX_TEXT"!");
 
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , inputtext , matInfo[ID][MatRes]  , matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
        format(matInfo[ID][MatText],128,inputtext);
        ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
    }
    if(dialogid == DIALOG_ALLIGNMENT)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        matInfo[ID][MatALG] = listitem;
        ShowPlayerDialog(playerid, DIALOG_ALLIGNMENT , DIALOG_STYLE_LIST, "Material System - Choose Allignment", "Left Allignment\nCenter Allignment\nRight Allignment", "Select", "Back");
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes], matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
    }
    if(dialogid == DIALOG_RESOLUTION)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        matInfo[ID][MatRes] = (listitem+1) * 10;
        ShowPlayerDialog(playerid, DIALOG_RESOLUTION , DIALOG_STYLE_LIST, "Material System - Choose Resolution", "32x32\n64x32\n64x64\n128x32\n128x64\n128x128\n256x32\n256x64\n256x128\n256x256\n512x64\n512x128\n512x256\n512x512", "Select", "Back");
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes], matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
    }
    if(dialogid == DIALOG_FONTSIZE)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        if(!isnumeric(inputtext)) return ShowPlayerDialog(playerid, DIALOG_FONTSIZE , DIALOG_STYLE_INPUT, "Material System - Font Size","Enter a Font Size\nMust be numeric", "Enter", "Close");
        matInfo[ID][MatSize] = strval(inputtext);
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes] ,matInfo[ID][MatFont], matInfo[ID][MatSize] , matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
        ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
    }
    if(dialogid == DIALOG_FONT)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes],inputtext, matInfo[ID][MatSize], matInfo[ID][MatBold], matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
        format(matInfo[ID][MatFont],128,inputtext);
        for(new a=0; a<sizeof(FontInfo); a++)
        {
            format(string, sizeof(string), "%s%s\n", string, FontInfo[a][FontName]);
        }
        ShowPlayerDialog(playerid, DIALOG_FONT , DIALOG_STYLE_LIST, "Material System - Choose Font", string, "Select", "Back");
    }
    if(dialogid == DIALOG_FONTCOLOR)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        switch(listitem)
        {
            case 0: matInfo[ID][MatColor]  = MRED;
            case 1: matInfo[ID][MatColor]  = MBLUE;
            case 2: matInfo[ID][MatColor]  = MYELLOW;
            case 3: matInfo[ID][MatColor]  = MORANGE;
            case 4: matInfo[ID][MatColor]  = MPURPLE;
            case 5: matInfo[ID][MatColor]  = MGREEN;
            case 6: matInfo[ID][MatColor]  = MLBLUE;
            case 7: matInfo[ID][MatColor]  = MWHITE;
            case 8: matInfo[ID][MatColor]  = MBLACK;
            case 9: matInfo[ID][MatColor]  = MCYAN;
            case 10: matInfo[ID][MatColor] = MPINK;
            case 11: matInfo[ID][MatColor] = MBROWN;
            case 12: matInfo[ID][MatColor] = MLPURPLE;
            case 13: matInfo[ID][MatColor] = MLGREEN;
            case 14: matInfo[ID][MatColor] = MGRAY;
        }
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes],matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold],matInfo[ID][MatColor], matInfo[ID][MatBGC],matInfo[ID][MatALG]);
        ShowPlayerDialog(playerid, DIALOG_FONTCOLOR , DIALOG_STYLE_LIST, "Material System - Choose Color", ""MYRED"Red\n"MYBLUE"Blue\n"MYYELLOW"Yellow\n"MYORANGE"Orange\n"MYPURPLE"Purple\n"MYGREEN"Green\n"MYLBLUE"Light Blue\n"MYWHITE"White\n"MYBLACK"Black\n"MYCYAN"Cyan\n"MYPINK"Pink\n"MYBROWN"Brown\n"MYLPURPLE"Light Purple\n"MYLGREEN"Light Green\n"MYGREY"Gray", "Select", "Back");
    }
    if(dialogid == DIALOG_BGCOLOR)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        switch(listitem)
        {
            case 0: matInfo[ID][MatBGC]  = MRED;
            case 1: matInfo[ID][MatBGC]  = MBLUE;
            case 2: matInfo[ID][MatBGC]  = MYELLOW;
            case 3: matInfo[ID][MatBGC]  = MORANGE;
            case 4: matInfo[ID][MatBGC]  = MPURPLE;
            case 5: matInfo[ID][MatBGC]  = MGREEN;
            case 6: matInfo[ID][MatBGC]  = MLBLUE;
            case 7: matInfo[ID][MatBGC]  = MWHITE;
            case 8: matInfo[ID][MatBGC]  = MBLACK;
            case 9: matInfo[ID][MatBGC]  = MCYAN;
            case 10: matInfo[ID][MatBGC] = MPINK;
            case 11: matInfo[ID][MatBGC] = MBROWN;
            case 12: matInfo[ID][MatBGC] = MLPURPLE;
            case 13: matInfo[ID][MatBGC] = MLGREEN;
            case 14: matInfo[ID][MatBGC] = MGRAY;
            case 15: matInfo[ID][MatBGC] = 0;
        }
        ShowPlayerDialog(playerid, DIALOG_BGCOLOR , DIALOG_STYLE_LIST, "Material System - Background Color",""MYRED"Red\n"MYBLUE"Blue\n"MYYELLOW"Yellow\n"MYORANGE"Orange\n"MYPURPLE"Purple\n"MYGREEN"Green\n"MYLBLUE"Light Blue\n"MYWHITE"White\n"MYBLACK"Black\n"MYCYAN"Cyan\n"MYPINK"Pink\n"MYBROWN"Brown\n"MYLPURPLE"Light Purple\n"MYLGREEN"Light Green\n"MYGREY"Gray\nNo Background", "Select", "Back");
        SetDynamicObjectMaterialText(matInfo[ID][MatObj] , matInfo[ID][MatIndex] , matInfo[ID][MatText] , matInfo[ID][MatRes],matInfo[ID][MatFont], matInfo[ID][MatSize], matInfo[ID][MatBold] ,matInfo[ID][MatColor], matInfo[ID][MatBGC] ,matInfo[ID][MatALG]);
    }
    if(dialogid == DIALOG_CHANGEOBJECT)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        if(!isnumeric(inputtext)) return ShowPlayerDialog(playerid, DIALOG_CHANGEOBJECT , DIALOG_STYLE_INPUT, "Material System - Object ID","Please enter an object ID to change!\n{FF0000}ERROR: Must be numeric", "Enter", "Back");
 
        DestroyDynamicObject(matInfo[ID][MatObj]);
        matInfo[ID][MatObjectID] = strval(inputtext);
        CreateMat(0,ID,matInfo[ID][MatX],matInfo[ID][MatY],matInfo[ID][MatZ],matInfo[ID][MatRX],matInfo[ID][MatRY],matInfo[ID][MatRZ]);
        ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
    }
    if(dialogid == DIALOG_CHANGEINDEX)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
        if(!isnumeric(inputtext)) return ShowPlayerDialog(playerid, DIALOG_CHANGEINDEX , DIALOG_STYLE_INPUT, "Material System - Material Index","Please enter an material index to set the Text on, (0 to 15)!\n{FF0000}ERROR: Must be numeric.", "Enter", "Back");
        if(strval(inputtext) > 15 || strval(inputtext) < 0) return ShowPlayerDialog(playerid, DIALOG_CHANGEINDEX , DIALOG_STYLE_INPUT, "Material System - Material Index","Please enter an material index to set the Text on, (0 to 15)!\n{FF0000}ERROR: Material index ranges from 0 to 15.", "Enter", "Back");
        DestroyDynamicObject(matInfo[ID][MatObj]);
        matInfo[ID][MatIndex] = strval(inputtext);
        CreateMat(0,ID,matInfo[ID][MatX],matInfo[ID][MatY],matInfo[ID][MatZ],matInfo[ID][MatRX],matInfo[ID][MatRY],matInfo[ID][MatRZ]);
        ShowPlayerDialog(playerid, DIALOG_MATS , DIALOG_STYLE_LIST, "Material System - v2.0 by FuNkY", "Change Text\nChange Font\nChange Color\nChange Font Size\nChange Background Color\nChange Allignment\nBold Text\nChange Resolution\nEdit Material Pos\nDuplicate Material\nDelete Material\nChange Object ID\nChange Material Index", "Select", "Close");
    }
    return 0;
}
 
public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
    new string[100];
    new editing = GetPVarInt(playerid,"matID");
 
    if(response == EDIT_RESPONSE_UPDATE)
    {
        SetDynamicObjectPos(objectid, x, y, z);
        SetDynamicObjectRot(objectid, rx, ry, rz);
    }
    if(response == EDIT_RESPONSE_CANCEL)
    {
        if(editing >= 0)
        {
            SendClientMessage(playerid, -1 , ""MYRED"[MATERIAL]"MYWHITE" Material editing canceled !");
            DeletePVar(playerid, "matID");
        }
    }
    if(response == EDIT_RESPONSE_FINAL)
    {
        SetDynamicObjectPos(objectid, x, y, z);
        SetDynamicObjectRot(objectid, rx, ry, rz);
        if(editing >= 0)
        {
            matInfo[editing][MatX] = x;
            matInfo[editing][MatY] = y;
            matInfo[editing][MatZ] = z;
            matInfo[editing][MatRX] = rx;
            matInfo[editing][MatRY] = ry;
            matInfo[editing][MatRZ] = rz;
            format(string, sizeof(string), ""MYRED"[MATERIAL]"MYWHITE" You have succesfully edited ID: %d's Material", editing);
            SendClientMessage(playerid, -1, string);
            DeletePVar(playerid, "matID");
            SetDynamicObjectPos(objectid, x, y, z);
            SetDynamicObjectRot(objectid, rx, ry, rz);
        }
    }
    return 1;
}
forward loadmat(idx,name[], value[]);
public loadmat(idx,  name[], value[])
{
    INI_Float("MatX", matInfo[idx][MatX]);
    INI_Float("MatY", matInfo[idx][MatY]);
    INI_Float("MatZ", matInfo[idx][MatZ]);
    INI_Float("MatRX", matInfo[idx][MatRX]);
    INI_Float("MatRY", matInfo[idx][MatRY]);
    INI_Float("MatRZ", matInfo[idx][MatRZ]);
    INI_String("MatText", matInfo[idx][MatText],MAX_TEXT);
    INI_String("MatFont", matInfo[idx][MatFont],MAX_FONT_NAME);
    INI_Int("MatColor", matInfo[idx][MatColor]);
    INI_Int("MatSize", matInfo[idx][MatSize]);
    INI_Int("MatBGC", matInfo[idx][MatBGC]);
    INI_Int("MatALG", matInfo[idx][MatALG]);
    INI_Int("MatBold", matInfo[idx][MatBold]);
    INI_Int("MatRes", matInfo[idx][MatRes]);
    INI_Int("MatObjectID", matInfo[idx][MatObjectID]);
    INI_Int("MatIndex", matInfo[idx][MatIndex]);
    return 1;
}
SaveMat(id)
{
    new string[25];
    format(string, sizeof(string), MPATH, id);
    new INI:file = INI_Open(string);
    INI_WriteFloat(file,"MatX", matInfo[id][MatX]);
    INI_WriteFloat(file,"MatY", matInfo[id][MatY]);
    INI_WriteFloat(file,"MatZ", matInfo[id][MatZ]);
    INI_WriteFloat(file,"MatRX", matInfo[id][MatRX]);
    INI_WriteFloat(file,"MatRY", matInfo[id][MatRY]);
    INI_WriteFloat(file,"MatRZ", matInfo[id][MatRZ]);
    INI_WriteString(file,"MatText", matInfo[id][MatText]);
    INI_WriteString(file,"MatFont", matInfo[id][MatFont]);
    INI_WriteInt(file,"MatColor", matInfo[id][MatColor]);
    INI_WriteInt(file,"MatSize", matInfo[id][MatSize]);
    INI_WriteInt(file,"MatBGC", matInfo[id][MatBGC]);
    INI_WriteInt(file,"MatALG", matInfo[id][MatALG]);
    INI_WriteInt(file,"MatBold", matInfo[id][MatBold]);
    INI_WriteInt(file,"MatRes", matInfo[id][MatRes]);
    INI_WriteInt(file,"MatObjectID", matInfo[id][MatObjectID]);
    INI_WriteInt(file,"MatIndex", matInfo[id][MatIndex]);
    INI_Close(file);
    return 1;
}
DeleteMat(i)
{
    matInfo[i][MatX] = 0;
    matInfo[i][MatY] = 0;
    matInfo[i][MatZ] = 0;
    matInfo[i][MatRX] = 0;
    matInfo[i][MatRY] = 0;
    matInfo[i][MatRZ] = 0;
    matInfo[i][MatText] = 0;
    DestroyDynamicObject(matInfo[i][MatObj]);
    matInfo[i][MatObj] = 0;
    matInfo[i][MatSize] = 0;
    matInfo[i][MatFont] = 0;
    matInfo[i][MatColor] = 0;
    matInfo[i][MatBGC] = 0;
    matInfo[i][MatALG] = 0;
    matInfo[i][MatBold] = 0;
    matInfo[i][MatRes] = 0;
    matInfo[i][MatObjectID] = 0;
    matInfo[i][MatIndex] = MATERIAL_DEFAULT_INDEX;
    Iter_Remove(MatsItr,i);
    return 1;
}
public CreateMat(type,id,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    if(type == 1)
    {
        matInfo[id][MatX] = x;
        matInfo[id][MatY] = y;
        matInfo[id][MatZ] = z;
        matInfo[id][MatRX] = rx;
        matInfo[id][MatRY] = ry;
        matInfo[id][MatRZ] = rz;
        matInfo[id][MatSize] = 25;
        matInfo[id][MatBGC] = MBLUE;
        matInfo[id][MatALG] = 1;
        matInfo[id][MatBold] = 0;
        matInfo[id][MatRes] = 90;
        matInfo[id][MatIndex] = MATERIAL_DEFAULT_INDEX;
    }
    matInfo[id][MatObj] = CreateDynamicObject(matInfo[id][MatObjectID], matInfo[id][MatX] , matInfo[id][MatY], matInfo[id][MatZ], matInfo[id][MatRX], matInfo[id][MatRY], matInfo[id][MatRZ], -1);
    SetDynamicObjectMaterialText(matInfo[id][MatObj] , matInfo[id][MatIndex] , matInfo[id][MatText] , matInfo[id][MatRes],matInfo[id][MatFont], matInfo[id][MatSize], matInfo[id][MatBold] , matInfo[id][MatColor],matInfo[id][MatBGC],matInfo[id][MatALG]);
    Iter_Add(MatsItr,id);
    SaveMat(id);
}