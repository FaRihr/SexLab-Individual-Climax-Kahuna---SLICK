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

Float Property fChangeToNoncon = 5.0 Auto Hidden

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
    If (DoDebug &&(!Load(sConfigFile) || GetErrors(sConfigFile)))
        ShowMessage("Errors while loading config file!\n" + GetErrors(sConfigFile), false)
        return false
    EndIf

    return true
EndFunction

Event OnConfigClose()
    SaveSettings()
EndEvent

;/ //////////////////////////////////////////////////
 / MCM menu pages setup
 ///////////////////////////////////////////////////;

Event OnConfigInit()
    Pages = new String[2]
    Pages[0] = "$SLC_Page_Main"
    Pages[1] = "$SLC_Page_Autopilot"
EndEvent

Event OnPageReset(String Page)
    If (Page == "" || Page == Pages[0])
        AddHeaderOption("$SLC_Header_MainOptions")
        AddEmptyOption()
        AddToggleOptionST("PlayerOnlyState", "$SLC_Short_PlayerOnly", self.bPlayerOnly)
    ElseIf (Page == Pages[1])
        AddHeaderOption("$SLC_Header_GeneralAutopilot")
        AddEmptyOption()
        AddSliderOptionST("UpdateIntervalState", "$SLC_Short_UpdateInterval", self.fUpdateInterval, "{1}s")
        AddEmptyOption()
        AddSliderOptionST("MinSatisfactionState", "$SLC_Short_MinSatisfaction", self.fMinSatisfaction, "{1}%")
        AddSliderOptionST("ChangeToNonconState", "$SLC_Short_ChangeToNoncon", self.fChangeToNoncon, "{1}%")

        AddHeaderOption("$SLC_Header_Consensual")
        AddEmptyOption()
        AddTextOption("Will be done", "soon [TM]", OPTION_FLAG_DISABLED)
        ; autopilot options for consensual scenes

        AddHeaderOption("$SLC_Header_NonCon")
        AddEmptyOption()
        AddToggleOptionST("SatisfactionNeededState", "$SLC_Short_SatisfactionNeeded", self.bSatisfactionNeeded)
    EndIf
EndEvent

;/ //////////////////////////////////////////////////
 / Settings stages
 ///////////////////////////////////////////////////;
State PlayerOnlyState
    Event OnSelectST()
        self.bPlayerOnly = !self.bPlayerOnly
        SetToggleOptionValueST(self.bPlayerOnly)
    EndEvent

    Event OnDefaultST()
        self.bPlayerOnly = false
        SetToggleOptionValueST(self.bPlayerOnly)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$SLC_Info_PlayerOnly")
    EndEvent
EndState

State UpdateIntervalState
    Event OnSliderOpenST()
        SetSliderDialogStartValue(self.fUpdateInterval)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(0.1, 30.0)
		SetSliderDialogInterval(0.1)
    EndEvent

    Event OnSliderAcceptST(float value)
        self.fUpdateInterval = value
        SetSliderOptionValueST(self.fUpdateInterval, "{1}s")
    EndEvent

    Event OnDefaultST()
        self.fUpdateInterval = 3.0
        SetSliderOptionValueST(self.fUpdateInterval, "{1}s")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$SLC_Info_UpdateInterval")
    EndEvent
EndState

State SatisfactionNeededState
    Event OnSelectST()
        self.bSatisfactionNeeded = !self.bSatisfactionNeeded
        SetToggleOptionValueST(self.bSatisfactionNeeded)
    EndEvent

    Event OnDefaultST()
        self.bSatisfactionNeeded = false
        SetToggleOptionValueST(self.bSatisfactionNeeded)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$SLC_Info_SatisfactionNeeded")
    EndEvent
EndState

State MinSatisfactionState
    Event OnSliderOpenST()
        SetSliderDialogStartValue(self.fMinSatisfaction)
		SetSliderDialogDefaultValue(85.0)
		SetSliderDialogRange(0.1, 100.0)
		SetSliderDialogInterval(0.1)
    EndEvent

    Event OnSliderAcceptST(float value)
        self.fMinSatisfaction = value
        SetSliderOptionValueST(self.fMinSatisfaction, "{1}%")
    EndEvent

    Event OnDefaultST()
        self.fMinSatisfaction = 85.0
        SetSliderOptionValueST(self.fMinSatisfaction, "{1}%")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$SLC_Info_MinSatisfaction")
    EndEvent
EndState

State ChangeToNonconState
    Event OnSliderOpenST()
        SetSliderDialogStartValue(self.fChangeToNoncon)
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.1)
    EndEvent

    Event OnSliderAcceptST(float value)
        self.fChangeToNoncon = value
        SetSliderOptionValueST(self.fChangeToNoncon, "{1}%")
    EndEvent

    Event OnDefaultST()
        self.fChangeToNoncon = 5.0
        SetSliderOptionValueST(self.fChangeToNoncon, "{1}%")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$SLC_Info_ChangeToNoncon")
    EndEvent
EndState