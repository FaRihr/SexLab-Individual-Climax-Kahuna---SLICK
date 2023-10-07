Scriptname slcSexlabEvents extends SexLabThreadHook
{The blocking hook to track Sexlab thread events}

slcMain Property Main Auto
slcBaseConfig Property Config Auto
SexLabFramework Property Sexlab Auto
slaFrameworkScr Property Arousal Auto

Actor Property PlayerRef Auto

Bool skipNextStage

; Called when all of the threads data is set, before the active animation is chosen
Function OnAnimationStarting(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
    Actor[] participants = akThread.GetPositions()

    int i = 0
    While (i < participants.Length)
        ; add voice control at beginning
        participants[i].RemoveSpell(Main.VoiceControl) ; safety for proper setup
        participants[i].AddSpell(Main.VoiceControl)

        ; TODO: set initial values for satisfaction and exhaustion based on external stats
        ; set initial satisfaction
        If (!akThread.IsConsent() && akThread.GetSubmissive(participants[i]) && !Sexlab.IsLewd(participants[i]))
            ; zero satisfaction if getting raped and not being lewd
            StorageUtil.SetFloatValue(participants[i], Config.sModId+".satisfaction", 0)
        Else
            ; initial satisfaction as random fraction of current arousal (33.3 to 50 for arousal=100)
            Float fFirstSat = Arousal.GetActorArousal(participants[i]) / Utility.RandomFloat(2.0, 3.0)
            StorageUtil.SetFloatValue(participants[i], Config.sModId+".satisfaction", fFirstSat)
        EndIf

        ; TODO: set initial exhaustion based on current stamina and time since last sex
            StorageUtil.SetFloatValue(participants[i], Config.sModId+".exhaustion", 0)

        i += 1
    EndWhile
EndFunction

; Called whenever a new stage is picked, including the very first one
Function OnStageStart(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
EndFunction

; Called whenever a stage ends, including the very last one
Function OnStageEnd(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
    ; manipulate scene based on calculated satisfaction and exhaustion

    String curScene = akThread.GetActiveScene()
    String curStage = akThread.GetActiveStage()
    String[] climaxStages = SexlabRegistry.GetClimaxStages(curScene)

    If (climaxStages.Find(curStage) < 0)
        ; TODO: check if we need to skip to climax based on satisfaction
        return
    Else
        ; check which actors had an orgasm and send event for each
        ; Scrab stated, that GetPositions() and the climaxing array share the same order. Yay!
        int[] climaxing = SexLabRegistry.GetClimaxingActors(curScene, curStage)
        Actor[] positions = akThread.GetPositions()

        int i = 0
        While (i < climaxing.Length)
            Actor climax = positions[climaxing[i]]
            Int handle = ModEvent.Create("SLICKClimaxingActor")
            If (handle)
                ModEvent.PushForm(handle, akThread)
                ModEvent.PushForm(handle, climax)
                ModEvent.PushFloat(handle, StorageUtil.GetFloatValue(climax, Config.sModId+".satisfaction"))
                ModEvent.PushFloat(handle, StorageUtil.GetFloatValue(climax, Config.sModId+".exhaustion"))
                ModEvent.Send(handle)
            EndIf
            i += 1
        EndWhile
    EndIf
EndFunction

; Called once the animation has ended
Function OnAnimationEnd(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
EndFunction

