Scriptname slcLibrary extends Quest
{Library and helper functions}

String Function BFS(String asID, String asTag, String asStart="")
    If (!SexlabRegistry.SceneExists(asID) || !SexlabRegistry.IsSceneEnabled(asID))
        return ""
    EndIf
    String[] queue = Utility.CreateStringArray(SexlabRegistry.GetNumStages(asID))
    String[] seen = Utility.CreateStringArray(queue.Length)
    String cur = ""

    If (!asStart || asStart == "")
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