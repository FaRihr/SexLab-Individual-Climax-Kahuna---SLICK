Scriptname slcBaseConfig extends SKI_ConfigBase
{The main configuration for SLICK for both, mod and user end}

import JSONUtil

;/ //////////////////////////////////////////////////
 / Internal Mod Setup and settings
 ///////////////////////////////////////////////////;
Int Function GetVersion()
    return 1
EndFunction

Float Property ModVersion = 0.10 AutoReadOnly Hidden
String Property sModId = "IndependentClimaxKahuna" AutoReadOnly Hidden

Int Property SatIdx = 0 AutoReadOnly Hidden
Int Property ExhIdx = 1 AutoReadOnly Hidden


; relative to data/skse/plugins/StorageUtilData/
String Property sConfigFile = "../../../MCM/Settings/SLICK" AutoReadOnly Hidden

;/ //////////////////////////////////////////////////
 / MCM user settings
 ///////////////////////////////////////////////////;
Bool Property bPlayerOnly = false Auto Hidden

;/ //////////////////////////////////////////////////
 / Internal Functions related to settings
 ///////////////////////////////////////////////////;
Bool Function SaveSettings()
    SetIntValue(sConfigFile, "iMCMVersion", GetVersion())

    return Save(sConfigFile)
EndFunction

Bool Function LoadSettings()
    If (!Load(sConfigFile) || GetErrors(sConfigFile))
        ShowMessage("Errors while loading config file!\n" + GetErrors(sConfigFile), false)
        return false
    EndIf

    return true
EndFunction