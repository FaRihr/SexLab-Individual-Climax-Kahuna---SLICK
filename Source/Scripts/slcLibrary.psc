Scriptname slcLibrary extends Quest
{Library and helper functions}

slcConfig Property Config Auto

; Statics for Skyrim GetSex() function
Int Property SEX_NONE = -1 AutoReadOnly Hidden
Int Property SEX_MALE = 0 AutoReadOnly Hidden
Int Property SEX_FEMALE = 1 AutoReadOnly Hidden
; additions by Sexlab P+ GetSex()
Int Property SEX_FUTA = 2 AutoReadOnly Hidden
Int Property SEX_CRTMALE = 3 AutoReadOnly Hidden
Int Property SEX_CRTFEMALE = 4 AutoReadOnly Hidden

; Mathematical constants
Float Property MATH_PI = 3.14159265359 AutoReadOnly Hidden
Float Property MATH_E = 2.71828182846 AutoReadOnly Hidden

; Breadth-first search for a stage in given scene that has the given array of tags
; asStart defines stage to start search from, empty string or none for first scene stage
String Function BFS(String asID, String[] asTags, String asStart="")
    If (!SexlabRegistry.SceneExists(asID) || !SexlabRegistry.IsSceneEnabled(asID))
        Debug.TraceStack("Given scene ID doesn't exist or is disabled!" + asID, 1)
        return ""
    EndIf

    String[] queue = Utility.CreateStringArray(SexlabRegistry.GetNumStages(asID))
    String[] seen = Utility.CreateStringArray(queue.Length)
    String cur = ""

    If (!asStart || asStart == "" || SexlabRegistry.GetAllStages(asID).Find(asStart) < 0)
        Debug.TraceStack("Stage '" + asStart + "' given for scene " + asID + " is invalid, starting search with start anim")
        asStart = SexlabRegistry.GetStartAnimation(asID)
    EndIf

    queue[0] = asStart
    seen[0] = asStart
    Int i = 1
    While (i > 0)
        cur = queue[i - 1]
        queue[i - 1] = ""
        If (SexlabRegistry.IsStageTagA(asID, cur, asTags))
            return cur
        EndIf

        int k = 0
        int num = SexlabRegistry.GetNumBranches(asID, cur)
        While (k < num)
            String child = SexlabRegistry.BranchTo(asID, cur, k)
            If (seen.Find(child) == -1)
                Int index = queue.Find("")
                queue[index] = child
                index = seen.Find("")
                seen[index] = child
            EndIf
            k += 1
        EndWhile

        i = queue.Find("")
    EndWhile

    return ""
EndFunction

; TODO: integrate functioning DFS algo for SL scenes
; Depth-first search for a stage in given scene that has the given tag
; asStart defines stage to start search from, empty string or none for first scene stage
String Function DFS(String asID, String asTag, String asStart="")
    If (!SexlabRegistry.SceneExists(asID) || !SexlabRegistry.IsSceneEnabled(asID))
        Debug.TraceStack("Given scene ID doesn't exist or is disabled!" + asID, 1)
        return ""
    EndIf

    String[] queue = Utility.CreateStringArray(SexlabRegistry.GetNumStages(asID))

    If (!asStart || asStart == "" || SexlabRegistry.GetAllStages(asID).Find(asStart) < 0)
        Debug.TraceStack("Stage '" + asStart + "' given for scene " + asID + " is invalid, starting search with start anim")
        asStart = SexlabRegistry.GetStartAnimation(asID)
    EndIf

    If (SexlabRegistry.IsStageTag(asID, asStart, asTag))
        return asStart
    EndIf


    return ""
EndFunction

Function log(String msg, Int iSev=0, Bool Stack=false)
    If (!Config.DoDebug)
        return
    EndIf

    Debug.OpenUserLog("SLICK")
    If (Stack)
        Debug.TraceStack("[SLICK] " + msg, iSev)
    Else
        Debug.Trace("[SLICK] " + msg, iSev)
    EndIf
    Debug.TraceUser("SLICK", msg, iSev)
EndFunction

Actor[] Function GetClimaxingActors(SexLabThread akThread)
    If (akThread.GetStatus() != akThread.STATUS_INSCENE)
        return None
    EndIf

    String curScene = akThread.GetActiveScene()
    String curStage = akThread.GetActiveStage()
    String[] climaxStages = SexlabRegistry.GetClimaxStages(curScene)

    ; no need for any checks if no orgasm happens
    If (climaxStages.Find(curStage) < 0)
        return None
    EndIf
    log("Stage" + curStage + " in scene " + curScene + " identified as orgasm stage")

    ; check which actors would have an orgasm
    ; Scrab stated, that GetPositions() and the climaxing array share the same order. Yay!
    int[] climaxIDs = SexLabRegistry.GetClimaxingActors(curScene, curStage)
    Actor[] positions = akThread.GetPositions()
    Actor[] climaxing = PapyrusUtil.ActorArray(climaxIDs.Length)

    int i = 0
    While (i < climaxIDs.Length)
        climaxing[i] = positions[climaxIDs[i]]
        i += 1
    EndWhile

    return climaxing
EndFunction