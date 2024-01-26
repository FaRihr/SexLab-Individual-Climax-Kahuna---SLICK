Scriptname slcCalcEffect extends ActiveMagicEffect
{A magic effect applied by spell to all participants of a Sexlab scene.
Calculates all relevant data of satisfaction and exhaustion for that participant}

SexLabFramework Property Sexlab Auto
slcConfig Property Config Auto
slcLibrary Property Lib Auto
slaFrameworkScr Property Arousal Auto

SexLabThread Thread
Actor theTarget

Event OnEffectStart(Actor akTarget, Actor akCaster)
    RegisterForModEvent("HookOrgasmStart", "OnOrgasmStart")

    theTarget = akTarget
    Thread = Sexlab.GetThreadByActor(akTarget)

    Lib.log("Calc effect on actor " + akTarget + " started")

    ; set initial values for satisfaction and exhaustion based on external stats
    ; set initial satisfaction
    If (!Thread.IsConsent() && Thread.GetSubmissive(theTarget) && !Sexlab.IsLewd(theTarget))
        ; zero satisfaction if getting raped and not being lewd
        StorageUtil.SetFloatValue(theTarget, Config.sModId+".satisfaction", 0.0)
    Else
        ; initial satisfaction as random fraction of arousal -> 20 to 33%
        Float fFirstSat = theTarget.GetFactionRank(Arousal.slaArousal) / Utility.RandomFloat(3.0, 5.0)
        StorageUtil.SetFloatValue(theTarget, Config.sModId+".satisfaction", fFirstSat)
    EndIf
    Lib.log("Initial satisfaction of " + theTarget + " = " + StorageUtil.GetFloatValue(theTarget, Config.sModId+".satisfaction"))

    ; TODO: get algorithm to calculate a fitting starting value based on the following two numbers
    ; more time difference -> less starting exhaustion
    Float fDifTimeSinceSex = Utility.GetCurrentGameTime() - Sexlab.LastSexGameTime(theTarget)
    ; more current stamina -> less starting exhaustion
    Float fCurStamina = theTarget.GetActorValuePercentage("Stamina")
    If (fCurStamina == 0)
        fCurStamina = 0.01
    EndIf

    ; TODO: change fDifTimeSinceSex with proper algo. Hyperbolic function? Have to play with numbers...
    ; Float fFirstExh = fDifTimeSinceSex / fCurStamina
    Float fFirstExh = 1 / (fDifTimeSinceSex / fCurStamina)
    ; set initial exhaustion based on current stamina and time since last sex
    StorageUtil.SetFloatValue(theTarget, Config.sModId+".exhaustion", fFirstExh)

    Lib.log("Initial exhaustion of " + theTarget + " = " + StorageUtil.GetFloatValue(theTarget, Config.sModId+".exhaustion"))

    RegisterForSingleUpdate(1.0)
EndEvent

; TODO: recalculate stats periodically
Event OnUpdate()

    RegisterForSingleUpdate(Config.fUpdateInterval)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    Lib.log("Calc effect on actor " + akTarget + " finished")
    Thread = None
    UnregisterForUpdate()
    UnregisterForModEvent("HookOrgasmStart")
EndEvent

; TODO: apply proper orgasm event handling
Event OnOrgasmStart(int aiThreadID, bool abHasPlayer)
    Lib.log("Calc effect received SL orgasm event")
    If (!Thread || Sexlab.GetThread(aiThreadID) != Thread)
        return
    EndIf

    String curScene = Thread.GetActiveScene()
    String curStage = Thread.GetActiveStage()
    ; String[] climaxStages = SexlabRegistry.GetClimaxStages(curScene)

    ; check which actors had an orgasm
    ; Scrab stated, that GetPositions() and the climaxing array share the same order. Yay!
    int[] climaxing = SexLabRegistry.GetClimaxingActors(curScene, curStage)
    Actor[] positions = Thread.GetPositions()

    int i = 0
    While (i < climaxing.Length)
        Lib.log("Climaxing actor: " + positions[climaxing[i]])
        If (positions[climaxing[i]] == theTarget)
            Lib.log("Target of calc effect is climaxing")

            ; partial SLSO backwards compatibility
            Int handle = ModEvent.Create("SexlabOrgasmSeparate")
            If (handle)
                ModEvent.PushForm(handle, theTarget)
                ModEvent.PushInt(handle, Thread.GetThreadID())
            EndIf

            ; TODO: adjust satisfaction and exhaustion in case of an orgasm
            Int sex = theTarget.GetLeveledActorBase().GetSex()
            Float fCurExh = StorageUtil.GetFloatValue(theTarget, Config.sModId+".exhaustion")
            If (sex == Lib.SEX_MALE || sex == Lib.SEX_FUTA) ; penis - penalty, harder to chain orgasms
                StorageUtil.SetFloatValue(theTarget, Config.sModId+".exhaustion", fCurExh * 1.2)
            ElseIf (sex == Lib.SEX_FEMALE) ; no penis - bonus, easier to chain orgasms
                StorageUtil.SetFloatValue(theTarget, Config.sModId+".exhaustion", fCurExh / 1.2)
            EndIf
        EndIf

        i += 1
    EndWhile
EndEvent