Scriptname slcCalcEffect extends ActiveMagicEffect
{A magic effect applied by spell to all participants of a Sexlab scene.
Calculates all relevant data of satisfaction and exhaustion for that participant}

SexLabFramework Property Sexlab Auto
slcConfig Property Config Auto

SexLabThread Thread

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Thread = Sexlab.GetThreadByActor(akTarget)
    RegisterForSingleUpdate(0.1)
    RegisterForModEvent("SLICKClimaxingActor", "OnSlickClimax")
EndEvent

; TODO: recalculate stats periodically
Event OnUpdate()

    RegisterForSingleUpdate(Config.fUpdateInterval)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    UnregisterForUpdate()
    UnregisterForModEvent("SLICKClimaxingActor")
    Thread = None
EndEvent

Event OnSlickClimax(Form akThread, Form akActor, Float fSatisfaction, Float fExhaustion)
    If (akThread as SexLabThread != Thread)
        return
    EndIf
    Actor Climaxing = akActor as Actor

    ; TODO: adjust satisfaction and exhaustion in case of an orgasm
    Int sex = Climaxing.GetActorBase().GetSex()
    If (sex == 0) ; male
        ; code
    ElseIf (sex == 1) ; female
        ; code
    EndIf
EndEvent