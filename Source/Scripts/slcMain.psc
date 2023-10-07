Scriptname slcMain extends Quest
{The main functionality to update values and widgets}

slcBaseConfig Property Config Auto
SexLabFramework Property Sexlab Auto
slaFrameworkScr Property Arousal Auto

Actor Property PlayerRef Auto
Spell Property VoiceControl Auto

Event OnInit()
    GameLoaded()
EndEvent

Function GameLoaded()
    RegisterForModEvent("HookAnimationStart", "OnSexlabStart")
    RegisterForModEvent("HookStageStart", "OnSLStageStart")
    RegisterForModEvent("HookAnimationEnd", "OnSexlabEnd")
    RegisterForModEvent("SLICKClimaxingActor", "OnSlickClimax")
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
    ; calculate satisfaction and exhaustion asynchronously for each stage
    ; blocking hook takes care at the end of the stage
    SexLabThread Thread = Sexlab.GetThread(aiThreadID)
    Actor[] participants = Thread.GetPositions()
    Int sat
    Int exh

    int i = 0
    While (i < participants.Length)
        
        i += 1
    EndWhile
EndEvent

Event OnSexlabEnd(int aiThreadID, bool abHasPlayer)
    If (Config.bPlayerOnly && !abHasPlayer)
        return
    EndIf

    ; remove voice control at end
    Actor[] participants = Sexlab.GetThread(aiThreadID).GetPositions()

    int i = 0
    While (i < participants.Length)
        participants[i].RemoveSpell(self.VoiceControl)
        i += 1
    EndWhile
EndEvent

Event OnSlickClimax(Form akThread, Form akActor, Float fSatisfaction, Float fExhaustion)
    SexLabThread Thread = akThread as SexLabThread
    Actor Climaxing = akActor as Actor

    ; TODO: adjust satisfaction and exhaustion in case of an orgasm
    Int sex = Climaxing.GetActorBase().GetSex()
    If (sex == 0) ; male
        ; code
    ElseIf (sex == 1) ; female
        ; code
    EndIf
EndEvent