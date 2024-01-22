Scriptname slcSexlabEvents extends SexLabThreadHook
{The blocking hook to track Sexlab thread events}

slcMain Property Main Auto
slcLibrary Property Lib Auto
slcConfig Property Config Auto
SexLabFramework Property Sexlab Auto
slaFrameworkScr Property Arousal Auto

Actor Property PlayerRef Auto

; TODO: DRY out orgasm stage and actor identification

; Called when all of the threads data is set, before the active animation is chosen
Function OnAnimationStarting(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
    Actor[] participants = akThread.GetPositions()

    int i = 0
    While (i < participants.Length)
        Actor participant = participants[i]
        ; ; add voice control at beginning
        ; If (participant.HasSpell(Main.VoiceControl))
        ;     participant.RemoveSpell(Main.VoiceControl) ; safety for proper setup
        ; EndIf
        ; participant.AddSpell(Main.VoiceControl)

        ; set initial values for satisfaction and exhaustion based on external stats
        ; set initial satisfaction
        If (!akThread.IsConsent() && akThread.GetSubmissive(participant) && !Sexlab.IsLewd(participant))
            ; zero satisfaction if getting raped and not being lewd
            StorageUtil.SetFloatValue(participant, Config.sModId+".satisfaction", 0.0)
        Else
            ; initial satisfaction as random fraction of current arousal
            Float fFirstSat = Arousal.GetActorArousal(participant) / Utility.RandomFloat(3.0, 5.0)
            StorageUtil.SetFloatValue(participant, Config.sModId+".satisfaction", fFirstSat)
        EndIf

        ; TODO: get algorithm to calculate a fitting starting value based on the following two numbers
        ; more time difference -> less starting exhaustion
        Float fDifTimeSinceSex = Utility.GetCurrentGameTime() - Sexlab.LastSexGameTime(participant)
        ; more current stamina -> less starting exhaustion
        Float fCurStamina = participant.GetActorValuePercentage("Stamina")
        If (fCurStamina == 0)
            fCurStamina = 0.01
        EndIf

        ; TODO: change fDifTimeSinceSex with proper algo. Hyperbolic function? Have to play with numbers...
        ; Float fFirstExh = fDifTimeSinceSex / fCurStamina
        Float fFirstExh = 1 / (fDifTimeSinceSex / fCurStamina)
        ; TODO: set initial exhaustion based on current stamina and time since last sex
        StorageUtil.SetFloatValue(participant, Config.sModId+".exhaustion", fFirstExh)

        ; Add calculation spell to all participants
        If (participant.HasSpell(Main.Calculation))
            participant.RemoveSpell(Main.Calculation) ; safety for proper setup
        EndIf
        participant.AddSpell(Main.Calculation)

        i += 1
    EndWhile
EndFunction

; TODO: find out if this blocks before or after sending OnOrgasm() event
; Called whenever a new stage is picked, including the very first one
Function OnStageStart(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
    String curScene = akThread.GetActiveScene()
    String curStage = akThread.GetActiveStage()
    String[] climaxStages = SexlabRegistry.GetClimaxStages(curScene)

    ; no need for any checks if no orgasm happens
    If (climaxStages.Find(curStage) < 0)
        return
    EndIf

    ; check which actors would have an orgasm
    ; Scrab stated, that GetPositions() and the climaxing array share the same order. Yay!
    int[] climaxing = SexLabRegistry.GetClimaxingActors(curScene, curStage)
    Actor[] positions = akThread.GetPositions()

    int i = 0
    While (i < climaxing.Length)
        Actor climax = positions[climaxing[i]]
        
        ; code

        i += 1
    EndWhile

    ; TODO: check if we skip orgasm based on data
EndFunction

; Called whenever a stage ends, including the very last one
Function OnStageEnd(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf
    ; manipulate scene based on calculated satisfaction and exhaustion

    String curScene = akThread.GetActiveScene()
    String curStage = akThread.GetActiveStage()
    Bool isCon = akThread.IsConsent()
    String[] climaxStages = SexlabRegistry.GetClimaxStages(curScene)

    If (climaxStages.Find(curStage) < 0)
        return
    EndIf

    ; check which actors had an orgasm
    ; Scrab stated, that GetPositions() and the climaxing array share the same order. Yay!
    int[] climaxing = SexLabRegistry.GetClimaxingActors(curScene, curStage)
    Actor[] positions = akThread.GetPositions()
    Actor climax = none

    Bool allHappy = true
    int i = 0
    ; TODO: check for scene types whether all are happy
    While (i < climaxing.Length && allHappy)
        climax = positions[climaxing[i]]
        Float sat = StorageUtil.GetFloatValue(climax, Config.sModId+".satisfaction", 0)

        ; TODO: check whether the scene may end or if someone wants more
        If (!isCon && !akThread.GetSubmissive(climax))
            ; TODO: is aggressor satisified after orgasm?
            If (sat < Config.fMinSatisfaction)
                allHappy = false
            EndIf
        ElseIf (isCon && sat < Config.fMinSatisfaction)
            ; TODO: is consensual partner satisifed
            allHappy = false
        EndIf

        i += 1
    EndWhile

    If (!allHappy && !akThread.HasContext("SLICKUnsatisfied"))
        akThread.AddContext("SLICKUnsatisfied")
    EndIf
EndFunction

; Called once the animation has ended
Function OnAnimationEnd(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef))
        return
    EndIf

    If (!Config.bSatisfactionNeeded || akThread.IsConsent())
        return
    EndIf

    ; if one actor is unsatisified in the end, start another round
    If (akThread.HasContext("SLICKUnsatisfied"))
        akThread.RemoveContext("SLICKUnsatisfied")
        String[] threadScenes = akThread.GetPlayingScenes()
        String[] penetrationScenes = SexlabRegistry.LookupScenesA(akThread.GetPositions(), "Penetration", akThread.GetSubmissives(), 1, none)
        String[] possibleScenes = PapyrusUtil.GetMatchingString(threadScenes, penetrationScenes)

        If (possibleScenes.Length <= 0)
            return
        EndIf

        Int num = Utility.RandomInt(0, possibleScenes.Length - 1)
        String nextScene = possibleScenes[num]

        String[] asTags = new String[1]
        asTags[0] = "Penetration"

        String PenStage = Lib.BFS(nextScene, asTags)
        akThread.SkipTo(PenStage)
    EndIf
EndFunction