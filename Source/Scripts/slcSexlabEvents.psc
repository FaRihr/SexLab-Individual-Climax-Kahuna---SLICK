Scriptname slcSexlabEvents extends SexLabThreadHook
{The blocking hook to track Sexlab thread events}

slcMain Property Main Auto
slcLibrary Property Lib Auto
slcConfig Property Config Auto
SexLabFramework Property Sexlab Auto
slaFrameworkScr Property Arousal Auto

Actor Property PlayerRef Auto

; Called when all of the threads data is set, before the active animation is chosen
Function OnAnimationStarting(SexLabThread akThread)
    Lib.log("Hooking into animation start")
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef) || Lib.HasCreatures(akThread))
        Lib.log("Ignoring animation due to missing player setting")
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

        ; Add calculation spell to all participants
        If (participant.HasSpell(Main.Calculation))
            Lib.log(participant + " still had calc spell for some reason!", 1)
            participant.RemoveSpell(Main.Calculation) ; safety for proper setup
        EndIf
        participant.AddSpell(Main.Calculation)

        i += 1
    EndWhile
EndFunction

; TODO: find out if this blocks before or after sending OnOrgasm() event
; Called whenever a new stage is picked, including the very first one
Function OnStageStart(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef) || Lib.HasCreatures(akThread))
        Lib.log("Ignoring animation due to missing player setting")
        return
    EndIf
    
    Actor[] climaxing = Lib.GetClimaxingActors(akThread)

    If (!climaxing[0])
        return
    EndIf

    ; TODO: check if orgasm stage needs to be skipped
EndFunction

; Called whenever a stage ends, including the very last one
Function OnStageEnd(SexLabThread akThread)
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef) || Lib.HasCreatures(akThread))
        Lib.log("Ignoring animation due to missing player setting")
        return
    EndIf
    ; manipulate scene based on calculated satisfaction and exhaustion

    Actor[] climaxing = Lib.GetClimaxingActors(akThread)

    If (!climaxing[0])
        return
    EndIf

    Bool isCon = akThread.IsConsent()
    Bool allHappy = true
    int i = 0

    ; TODO: check for scene types whether all are happy
    While (i < climaxing.Length && allHappy)
        Actor climax = climaxing[i]
        Float sat = StorageUtil.GetFloatValue(climax, Config.sModId+".satisfaction", 0)

        ; TODO: check whether the scene may end or if someone wants more
        If (!isCon && !akThread.GetSubmissive(climax))
            ; TODO: is aggressor satisified after orgasm?
            If (sat < Config.fMinSatisfaction)
                allHappy = false
            EndIf
        ElseIf (isCon && sat < Config.fMinSatisfaction && Utility.RandomFloat(0.0, 99.999) < Config.fChangeToNoncon)
            ; TODO: is consensual partner satisifed
            allHappy = false
        EndIf

        i += 1
    EndWhile

    If (!allHappy && !akThread.HasContext("SLICKUnsatisfied"))
        Lib.log("Added unsatisfied context to scene" + akThread.GetActiveScene() + " to search for next anim on scene end")
        akThread.AddContext("SLICKUnsatisfied")
        akThread.SetConsent(false) ; change to rape
    EndIf
EndFunction

; Called once the animation has ended
Function OnAnimationEnd(SexLabThread akThread)
    Lib.log("Hooking into animation end")
    If (Config.bPlayerOnly && !akThread.HasActor(self.PlayerRef) || Lib.HasCreatures(akThread))
        Lib.log("Ignoring animation due to missing player setting")
        return
    EndIf

    If (!Config.bSatisfactionNeeded || akThread.IsConsent())
        Lib.log("Ignoring animation due to satisfaction settings or consent")
        return
    EndIf

    ; if an aggressive actor is unsatisified in the end, start another round
    If (akThread.HasContext("SLICKUnsatisfied"))
        Lib.log("Aggressor was unsatisfied, searching for new anim as the show must go on!")
        akThread.RemoveContext("SLICKUnsatisfied")
        ; TODO: refine tags to search for, based on unsatisfied aggressor
        ; https://www.loverslab.com/blogs/entry/19902-sexlab-p-tagging-guide/
        String[] threadScenes = akThread.GetPlayingScenes()
        String[] penetrationScenes = SexlabRegistry.LookupScenesA(akThread.GetPositions(), "!Aggressive", akThread.GetSubmissives(), 1, none)
        String[] possibleScenes = PapyrusUtil.GetMatchingString(threadScenes, penetrationScenes)

        If (possibleScenes.Length <= 0)
            return
        EndIf

        Int num = Utility.RandomInt(0, possibleScenes.Length - 1)
        String nextScene = possibleScenes[num]

        String[] asTags = new String[1]
        asTags[0] = "!Aggressive"
        ; asTags[1] = ""

        String PenStage = Lib.BFS(nextScene, asTags)
        Lib.log("Found new scene " + nextScene + ", starting at penetration stage " + PenStage)
        ; has to wait until Scrab adds that back to the new API
        ; akThread.ResetScene(nextScene)
        akThread.SkipTo(PenStage)
    EndIf
EndFunction