Scriptname slcLibrary extends Quest
{Library and helper functions}

slcConfig Property Config Auto

; Breadth-first search for a stage in given scene that has the given tag
String Function BFS(String asID, String asTag, String asStart="")
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
        i = queue.Find("")
        cur = queue[i - 1]
        queue[i - 1] = ""
        If (SexlabRegistry.IsStageTag(asID, cur, asTag))
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
    EndWhile

    return ""
EndFunction

; TODO: integrate functioning DFS algo for SL scenes
String Function DFS(String asID, String asTag, String asStart="")
    If (!SexlabRegistry.SceneExists(asID) || !SexlabRegistry.IsSceneEnabled(asID))
        Debug.TraceStack("Given scene ID doesn't exist or is disabled!" + asID, 1)
        return ""
    EndIf

    String[] queue = Utility.CreateStringArray(SexlabRegistry.GetNumStages(asID))

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