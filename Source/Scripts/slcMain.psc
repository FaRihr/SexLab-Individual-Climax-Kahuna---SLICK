Scriptname slcMain extends Quest
{The main functionality to update values and widgets}

slcBaseConfig Property Config Auto
SexLabFramework Property Sexlab Auto
slaFrameworkScr Property Arousal Auto

Actor Property PlayerRef Auto
Spell Property VoiceControl Auto
Spell Property Calculation Auto

Event OnInit()
    GameLoaded()
EndEvent

Function GameLoaded()
    RegisterForModEvent("HookAnimationStart", "OnSexlabStart")
    RegisterForModEvent("HookStageStart", "OnSLStageStart")
    RegisterForModEvent("HookAnimationEnd", "OnSexlabEnd")
EndFunction

Event OnSexlabStart(int aiThreadID, bool abHasPlayer)
    If (Config.bPlayerOnly && !abHasPlayer)
        return
    EndIf
EndEvent

Event OnSLStageStart(int aiThreadID, bool abHasPlayer)
    If (Config.bPlayerOnly && !abHasPlayer)
        return
    EndIf
EndEvent

Event OnSexlabEnd(int aiThreadID, bool abHasPlayer)
    ; remove control spells at end, no need to block thread for that
    Actor[] participants = Sexlab.GetThread(aiThreadID).GetPositions()

    int i = 0
    While (i < participants.Length)
        participants[i].RemoveSpell(self.VoiceControl)
        participants[i].RemoveSpell(self.Calculation)
        i += 1
    EndWhile
EndEvent