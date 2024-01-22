Scriptname slcCalcEffect extends ActiveMagicEffect
{A magic effect applied by spell to all participants of a Sexlab scene.
Calculates all relevant data of satisfaction and exhaustion for that participant}

SexLabFramework Property Sexlab Auto
slcConfig Property Config Auto
slcLibrary Property Lib Auto

SexLabThread Thread
Actor theTarget

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Lib.log("Calc effect on actor " + akTarget + " started")
    theTarget = akTarget
    Thread = Sexlab.GetThreadByActor(akTarget)
    RegisterForSingleUpdate(0.1)
    RegisterForModEvent("HookOrgasmStart", "OnOrgasmStart")
EndEvent

; TODO: recalculate stats periodically
Event OnUpdate()

    RegisterForSingleUpdate(Config.fUpdateInterval)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    Lib.log("Calc effect on actor " + akTarget + " finished")
    Thread = None
    UnregisterForUpdate()
    UnRegisterForModEvent("HookOrgasmStart")
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