Scriptname slcConfigMenu extends slcConfig
{The mod configuration menu for user config}

Event OnConfigInit()
    Pages = new String[2]
    Pages[0] = "$SLC_Page_Main"
    Pages[1] = "$SLC_Page_Game"
EndEvent

Event OnPageReset(String Page)
    If (Page == "" || Page == Pages[0])
        AddHeaderOption("$SLC_Header_MainOptions")
        AddEmptyOption()
        AddToggleOptionST("PlayerOnlyState", "$SLC_Short_PlayerOnly", self.bPlayerOnly)
    ElseIf (Page == Pages[1])
        ; code
    EndIf
EndEvent

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