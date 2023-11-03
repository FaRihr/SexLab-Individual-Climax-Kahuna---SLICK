Scriptname slcConfig extends SKI_ConfigBase
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

; relative to data/skse/plugins/StorageUtilData/
String Property sConfigFile = "../../../MCM/Settings/SLICK" AutoReadOnly Hidden

Bool _Debug
Bool Property DoDebug Hidden
    Bool Function Get()
        return _Debug
    EndFunction
EndProperty

;/ //////////////////////////////////////////////////
 / MCM user settings
 ///////////////////////////////////////////////////;
Bool Property bPlayerOnly = false Auto Hidden
Float Property fUpdateInterval = 3.0 Auto Hidden
Bool Property bSatisfactionNeeded = false Auto Hidden
Float Property fMinSatisfaction = 85.0 Auto Hidden

;/ //////////////////////////////////////////////////
 / Internal Functions related to settings
 ///////////////////////////////////////////////////;
Event OnGameReload()
	parent.OnGameReload() ; Don't forget to call the parent!
	
    _Debug = Utility.GetINIBool("bEnableLogging:Papyrus")
EndEvent

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