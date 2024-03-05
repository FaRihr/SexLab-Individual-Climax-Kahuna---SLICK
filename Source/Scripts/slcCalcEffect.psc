Scriptname slcCalcEffect extends ActiveMagicEffect
{A magic effect applied by spell to all participants of a Sexlab scene.
Calculates all relevant data of satisfaction and exhaustion for that participant}

SexLabFramework Property Sexlab Auto
slcConfig Property Config Auto
slcLibrary Property Lib Auto
slaFrameworkScr Property Arousal Auto

SexLabThread Thread
Actor theTarget
Bool firstRun

Event OnEffectStart(Actor akTarget, Actor akCaster)

    theTarget = akTarget
    Thread = Sexlab.GetThreadByActor(akTarget)
    firstRun = true

    RegisterForModEvent("HookOrgasmStart", "OnOrgasmStart")
    RegisterForSingleUpdate(0.2)

    Lib.log("Calc effect on actor " + akTarget + " started")
EndEvent

Event OnUpdate()
    If (firstRun)
        firstRun = false
        SetFirstValues()
        return
    EndIf

    ; TODO: recalculate stats periodically

    RegisterForSingleUpdate(Config.fUpdateInterval)
EndEvent

; garbage collection
Event OnEffectFinish(Actor akTarget, Actor akCaster)
    StorageUtil.UnsetFloatValue(theTarget, Config.sModId+".satisfaction")
    StorageUtil.UnsetFloatValue(theTarget, Config.sModId+".exhaustion")
    theTarget = None
    Thread = None
    Lib.log("Calc effect on actor " + akTarget + " finished")
EndEvent

; TODO: apply proper orgasm event handling
Event OnOrgasmStart(int aiThreadID, bool abHasPlayer)
    Lib.log("Calc effect received SL orgasm event")
    If (!Thread || Sexlab.GetThread(aiThreadID) != Thread)
        return
    EndIf

    ; String curScene = Thread.GetActiveScene()
    ; String curStage = Thread.GetActiveStage()

    Actor[] climaxing = Lib.GetClimaxingActors(Thread)

    int i = 0
    While (i < climaxing.Length)
        If (climaxing[i] == theTarget)
            Lib.log("Target of calc effect is climaxing")

            ; partial SLSO backwards compatibility
            Int handle = ModEvent.Create("SexlabOrgasmSeparate")
            If (handle)
                ModEvent.PushForm(handle, theTarget)
                ModEvent.PushInt(handle, aiThreadID)
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

;  set initial values for satisfaction and exhaustion based on external stats
Function SetFirstValues()
    ; set initial satisfaction
    If (!Thread.IsConsent() && Thread.GetSubmissive(theTarget) && !Sexlab.IsLewd(theTarget))
        ; zero satisfaction if getting raped and not being lewd
        StorageUtil.SetFloatValue(theTarget, Config.sModId+".satisfaction", 0.0)
    Else
        ; calculate satisfaction based on arousal and days since last sex
        Float CurAr = theTarget.GetFactionRank(Arousal.slaArousal) as Float
        If (CurAr < 10.0)
            CurAr = 10.0
        EndIf
        Float fTimeSinceSex = Utility.GetCurrentGameTime() - Sexlab.LastSexGameTime(theTarget)

        ; logistic function with G=100, k=0.003, t=days since last sex, f(0)=current arousal
        ; with min arousal(=10) it takes ~30 in-game days since last sex to reach 99.9 satisfaction
        ; f(t) = G / [1 + e^(-k*G*t) * (G/f(0) - 1)]
        Float fFirstSat = 100 / (1 + Math.pow(Lib.MATH_E,(-0.3 * fTimeSinceSex)*(100 / CurAr - 1)))
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

    ; start update loop
    self.RegisterForSingleUpdate(0.1)
EndFunction