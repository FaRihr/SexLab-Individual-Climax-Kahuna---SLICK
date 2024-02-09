Scriptname SlickLegacySLSO extends sslActorAlias
{The wrapper API to provide backwards compatibility for old SLSO functions with the new SL p+ 2.x}

; -----------------------------------------------------------------------------
;       _   _  _____        __  _____ ___    ____   _  _____ ____ _   _
;      | | | |/ _ \ \      / / |_   _/ _ \  |  _ \ / \|_   _/ ___| | | |
;      | |_| | | | \ \ /\ / /    | || | | | | |_) / _ \ | || |   | |_| |
;      |  _  | |_| |\ V  V /     | || |_| | |  __/ ___ \| || |___|  _  |
;      |_| |_|\___/  \_/\_/      |_| \___/  |_| /_/   \_\_| \____|_| |_|
; 
; In the old version, participants of an act were transferred in the type <sslActorAlias>. However, SexLab p+ from 
; version 2 encapsulates this script for internal use and only allows the API to be used to access the data.
; 
; This legacy API therefore offers the option of continuing to use the SLSO functions for participants of type 
; <sslActorAlias>. To achieve this, however, the function calls must be updated in the following way:
; 
; OLD
; <participant>.GetFullEnjoyment()
; 
; NEW
; (<participant> as SlickLegacySLSO).GetFullEnjoyment()
; 
; Due to the fact that this API is an extension of sslActorAlias, no type conversion is required. This is performed by
; the API in order to remain compliant with the new SL p+ standard.
; -----------------------------------------------------------------------------

SexLabThread Function GetThreadByAlias()
	return Sexlab.GetThreadByActor(self.GetReference() as Actor)
EndFunction

Actor Function GetActorByAlias()
	return self.GetReference() as Actor
EndFunction

bool function IsCreature()
	return SexlabRegistry.GetRaceID(self.GetReference() as Actor) > 0
endFunction

;  ___ _   _ _____ _____ ____  _   _    _    _     
; |_ _| \ | |_   _| ____|  _ \| \ | |  / \  | |    
;  | ||  \| | | | |  _| | |_) |  \| | / _ \ | |    
;  | || |\  | | | | |___|  _ <| |\  |/ ___ \| |___ 
; |___|_| \_| |_| |_____|_| \_\_| \_/_/   \_\_____|
                                                 

SexLabFramework Property Sexlab Auto

; SLSO shit

Faction slaArousal
Faction slaExhibitionist
Bool bslaExhibitionist
Bool SLSOGetEnjoymentCheck1
Bool SLSOGetEnjoymentCheck2
Bool EstrusForcedEnjoymentMods
;Int AllowNonAggressorOrgasm
Int slaExhibitionistNPCCount
int BonusEnjoyment
int ActorFullEnjoyment
float sl_enjoymentrate
float MasturbationMod
float slaActorArousalMod
float ExhibitionistMod
float GenderMod
Keyword zadDeviousBelt


function SLSO_Initialize()
	;SLSO
	; Flags
	EstrusForcedEnjoymentMods = false
	bslaExhibitionist	 = false
	; Integers
	BonusEnjoyment		= 0
	ActorFullEnjoyment		= 0
	slaExhibitionistNPCCount	  = 0
	; Floats
	MasturbationMod		= 1.0
	slaActorArousalMod	= 1.0
	ExhibitionistMod	= 1.0
	GenderMod	  = 1.0
	; Factions
	slaArousal			 = None
	slaExhibitionist	 = None
	; Keywords
	zadDeviousBelt = None
	thread.Set_minimum_aggressor_orgasm_Count(-1)
endFunction

;SLSO enjoyment calc
int function GetFullEnjoyment()
	return ActorFullEnjoyment
endFunction

float function GetFullEnjoymentMod()
	return	100*MasturbationMod/ExhibitionistMod/GenderMod*slaActorArousalMod
endFunction

int function CalculateFullEnjoyment()
	;this can be very script heavy, don't call it unless you absolutely have to, use GetFullEnjoyment()
	int slaActorArousal = 0
	String File = "/SLSO/Config.json"

	if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 2
		if slaArousal != none
			slaActorArousal = ActorRef.GetFactionRank(slaArousal)
		endIf
		if slaActorArousal < 0
			slaActorArousal = 0
		endIf
	endIf
	if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 3
		if slaArousal != none
			slaActorArousalMod = (ActorRef.GetFactionRank(slaArousal) as float) * 2 / 100
		endIf
		if slaActorArousalMod < 0
			slaActorArousalMod = 1
		endIf
		;set agressor arousal modifier to 100% so we dont get stuck in loop if animation requires aggressor orgasm to finish
	endIf

	; realtime exhibitionism detection, very script heavy
	if !IsCreature
		if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 2
			Cell akTargetCell = ActorRef.GetParentCell()
			int iRef = 0
			slaExhibitionistNPCCount = 0
			while iRef <= akTargetCell.getNumRefs(43) && slaExhibitionistNPCCount < 6 ;GetType() 62-char,44-lvchar,43-npc
				Actor aNPC = akTargetCell.getNthRef(iRef, 43) as Actor
				If aNPC!= none && aNPC.GetDistance(ActorRef) < 1000 && aNPC != ActorRef && aNPC.HasLOS(ActorRef)
					slaExhibitionistNPCCount += 1
				EndIf
				iRef = iRef + 1
			endWhile
			if bslaExhibitionist || OwnSkills[Stats.kLewd] > 5
				slaExhibitionistNPCCount = PapyrusUtil.ClampInt(slaExhibitionistNPCCount, 0, 7)
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (3 - 0.4 * slaExhibitionistNPCCount)) as int+"]")
				;ExhibitionistMod = (3 - 0.4 * slaExhibitionistNPCCount)
				ExhibitionistMod =	(1.6 - 0.2 * slaExhibitionistNPCCount)
			elseif slaExhibitionistNPCCount > 1 && !IsAggressor
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + 0.2 * slaExhibitionistNPCCount)) as int+"]")
				ExhibitionistMod = (1 + 0.2 * slaExhibitionistNPCCount)
			endif
		endif
	endif
	if IsAggressor && JsonUtil.GetIntValue(File, "condition_aggressor_orgasm") == 1
		if slaActorArousalMod < 1
			slaActorArousalMod = 1
		endIf
		if ExhibitionistMod < 1
			ExhibitionistMod = 1
		endIf
	endIf
	
	int SLSO_FullEnjoyment = GetEnjoyment()
	;Log("SLSO_CalculateFullEnjoyment:")
	;Log("SLSO_FullEnjoyment ["+SLSO_FullEnjoyment+"] SL FullEnjoyment ["+FullEnjoyment+"] BaseEnjoyment["+BaseEnjoyment+"] SLArousal["+slaActorArousal+"]"+"] BonusEnjoyment["+BonusEnjoyment+"]")
	;Log("Modifiers: MasturbationMod["+MasturbationMod+" ExhibitionistMod ["+ExhibitionistMod+"] GenderMod["+GenderMod+"] sl_enjoymentrate["+sl_enjoymentrate+"]"+"] slaActorArousalMod["+slaActorArousalMod+"]")

	SLSO_FullEnjoyment = SLSO_FullEnjoyment + slaActorArousal + BonusEnjoyment

	if	EstrusForcedEnjoymentMods
		ActorFullEnjoyment = (SLSO_FullEnjoyment * JsonUtil.GetFloatValue(File, "sl_estrusforcedenjoyment")) as int
	else
		ActorFullEnjoyment = (SLSO_FullEnjoyment * MasturbationMod / ExhibitionistMod / GenderMod * sl_enjoymentrate * slaActorArousalMod) as int
	endIf
	
	;Log("SLSO_ActorFullEnjoyment with modifiers ["+ActorFullEnjoyment+"] = (SLSO_FullEnjoyment ["+SLSO_FullEnjoyment+"] * Modifiers ["+MasturbationMod / ExhibitionistMod / GenderMod * sl_enjoymentrate * slaActorArousalMod+"])")
	return ActorFullEnjoyment
endFunction

int function SLSO_GetEnjoyment()
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "GetEnjoyment()")
		FullEnjoyment = 0
		return 0
	elseif !IsSkilled
		;run default sexlab enjoyment if: enabled in slso mcm, more than 2 actors, thread has no player or npc_game(), game() disabled
		if SLSOGetEnjoymentCheck1
			if SLSOGetEnjoymentCheck2
				FullEnjoyment = (PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0) + ((Stage as float / StageCount as float) * 60.0)) as int
			else
				FullEnjoyment = (PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0)) as int
			endIf
		endIf
	else
		if Position == 0
			Thread.RecordSkills()
			Thread.SetBonuses()
		endIf
		if SLSOGetEnjoymentCheck1
			if SLSOGetEnjoymentCheck2
				FullEnjoyment = BaseEnjoyment + CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), Stage, StageCount)
			else
				FullEnjoyment = BaseEnjoyment + CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), 1, StageCount)
			endIf
			if FullEnjoyment < 0
				FullEnjoyment = 0
			;elseIf FullEnjoyment > 100
			;	FullEnjoyment = 100
			endIf
		endIf
	endIf
	int SLSO_Enjoyment = FullEnjoyment - QuitEnjoyment
	;int SLSO_Enjoyment = FullEnjoyment - BaseEnjoyment
	;Log("SLSO_GetEnjoyment: SLSO_Enjoyment["+SLSO_Enjoyment+"] / FullEnjoyment["+FullEnjoyment+"] / QuitEnjoyment["+QuitEnjoyment+"] / BaseEnjoyment["+BaseEnjoyment+"]")
	if SLSO_Enjoyment > 0
		return SLSO_Enjoyment
	endIf
	return 0
	;return SLSO_Enjoyment - BaseEnjoyment
endFunction

function BonusEnjoyment(actor Ref = none, int fixedvalue = 0)
	if self.GetState() == "Animating"
		if Ref == none || Ref == ActorRef
			if Ref == none 
				;Log("Ref is none, setting to self")
				Ref = ActorRef
			endif
			
			if fixedvalue != 0
				;reduce enjoyment by fixed value
				if fixedvalue < 0
					BonusEnjoyment += fixedvalue
					
				;increase enjoyment by fixed value
				else
					BonusEnjoyment += fixedvalue
				endif
				
				;Log("change [" +Ref.GetDisplayName()+ "] BonusEnjoyment[" +BonusEnjoyment+ "] by fixed value[" +fixedvalue+ "]")
				
			;increase enjoyment based on arousal
			else
				;Log("change [" +Ref.GetDisplayName()+ "]")
				int slaActorArousal = 0
				String File = "/SLSO/Config.json"
				if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 1
					if slaArousal != none
						slaActorArousal = ActorRef.GetFactionRank(slaArousal)
					endIf
					if slaActorArousal < 0
						slaActorArousal = 0
					endIf
				endIf
				
				slaActorArousal = PapyrusUtil.ClampInt(slaActorArousal/20, 1, 5)
				;Log("change [" +Ref.GetDisplayName()+ "] enjoyment by [" +slaActorArousal+ "] arousal mod")
				if BaseSex == 0
					BonusEnjoyment +=slaActorArousal
				elseif JsonUtil.GetIntValue(File, "condition_female_orgasm_bonus") != 1
					BonusEnjoyment +=slaActorArousal
				else
				Log("female [" +Ref.GetDisplayName()+ "] bonus enjoyment [" +GetOrgasmCount()+ "]")
					BonusEnjoyment +=slaActorArousal + GetOrgasmCount()
				endif
			endIf
		
		;increase target enjoyment
		elseif Thread.ActorAlias(Ref) != none
			;Log("change target [" +Ref.GetDisplayName()+ "] enjoyment by [" +fixedvalue+ "]")
			Thread.ActorAlias(Ref).BonusEnjoyment(Ref, fixedvalue)
		endIf
	endIf
endFunction

;orgasm stuff
function Orgasm(float experience = 0.0)
	if experience == -2
		LastOrgasm = Math.Abs(RealTime[0] - 11)
		DoOrgasm(true)
	elseif ActorFullEnjoyment >= 90
		if experience == -1
			LastOrgasm = Math.Abs(RealTime[0] - 11)
		endIf
		if Math.Abs(RealTime[0] - LastOrgasm) > 10.0
			OrgasmEffect()
		endIf
	endIf
endFunction

function HoldOut(float experience = 0.0)
	if Position == 0
		if	IsFemale 
			if (Animation.HasTag("Vaginal" || Animation.HasTag("Fisting") || Animation.HasTag("69")))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + OwnSkills[Stats.kVaginal] + experience)
				BonusEnjoyment(ActorRef, (- 1 - OwnSkills[Stats.kVaginal]) as int)
			elseif(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + OwnSkills[Stats.kAnal] + experience)
				BonusEnjoyment(ActorRef, (-1 - OwnSkills[Stats.kAnal]) as int)
			else
				LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
				BonusEnjoyment(ActorRef, -1)
			endIf
		elseif IsMale || IsFuta
			if (Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + OwnSkills[Stats.kAnal] + experience)
				BonusEnjoyment(ActorRef, (-1 - OwnSkills[Stats.kAnal]) as int)
			else
				LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
				BonusEnjoyment(ActorRef, -1)
			endIf
		endIf
	elseif Position == 1
		LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
		BonusEnjoyment(ActorRef, -1)
	endIf
endFunction

int function GetOrgasmCount()
	if !ActorRef
		Orgasms = 0
	endIf
	return Orgasms
endFunction

function SetOrgasmCount(int SetOrgasms = 0)
	if SetOrgasms >=0
		Orgasms = SetOrgasms
	endIf
endFunction

;Sexlab "patching", for interaluse only
int function SLSO_DoOrgasm_Conditions(bool Forced)
	String File = "/SLSO/Config.json"
	if LeadIn && JsonUtil.GetIntValue(File, "condition_leadin_orgasm") == 0
		Log(ActorName + " Orgasm blocked, orgasms disabled at LeadIn/Foreplay Stage")
		return -1
	endIf
	if IsPlayer && (JsonUtil.GetIntValue(File, "condition_player_orgasm") == 0)
		Log("Orgasm blocked, player is forbidden to orgasm")
		return -2
	endIf
	if JsonUtil.GetIntValue(File, "condition_ddbelt_orgasm") == 0
		if zadDeviousBelt != none
			if ActorRef.WornHasKeyword(zadDeviousBelt)
				Log("Orgasm blocked, " + ActorName + " has DD belt prevent orgasming")
				return -3
			EndIf
		endIf
	endIf
	if !Animation.HasTag("Estrus")
		if IsVictim
			if JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 0
				Log("Orgasm blocked, " + ActorName + " is victim, victim forbidden to orgasm")
				return -4
			elseif JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 2
				if (OwnSkills[Stats.kLewd]*10) as int < Utility.RandomInt(0, 100)
					Log("Orgasm blocked, " + ActorName + " is victim, victim didn't pass lewd check to orgasm")
					return -5
				endIf
			endIf
		endIf
		if !IsAggressor
			if !(Animation.HasTag("69") || Animation.HasTag("Masturbation")) || Thread.Positions.Length == 2
				if	!IsCreature && BaseRef.GetSex() != Gender || IsFuta
					if	JsonUtil.GetIntValue(File, "condition_futa_orgasm") == 1
						if Position == 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Lesbian"))
							Log(ActorName + " Orgasm blocked, futa female pos 0, conditions not met, no HasTag(Vaginal,Anal,Cunnilingus,Fisting)")
							return -11
						elseif Position != 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Boobjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Handjob") || Animation.HasTag("Footjob"))
							Log(ActorName + " Orgasm blocked, futa male pos > 0, conditions not met, no HasTag(Vaginal,Anal,Boobjob,Blowjob,Handjob,Footjob)")
							return -12
						endIf
					endIf
				elseif IsFemale
					if JsonUtil.GetIntValue(File, "condition_female_orgasm") == 1
						if Position == 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Lesbian"))
							Log(ActorName + " Orgasm blocked, female pos 0, conditions not met, no HasTag(Vaginal,Anal,Cunnilingus,Fisting)")
							return -6
						endIf
					endIf
				elseif IsMale
					if JsonUtil.GetIntValue(File, "condition_male_orgasm") == 1
						if Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
							Log(ActorName + " Orgasm blocked, male pos 0, conditions not met, no HasTag(Anal,Fisting)")
							return -7
						elseif Position != 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Boobjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Handjob") || Animation.HasTag("Footjob"))
							Log(ActorName + " Orgasm blocked, male pos > 0, conditions not met, no HasTag(Vaginal,Anal,Boobjob,Blowjob,Handjob,Footjob)")
							return -8
						endIf
					endIf
				endIf
			endIf
		endIf
		if StorageUtil.GetIntValue(ActorRef, "slso_forbid_orgasm") == 1
			Log("Orgasm blocked, " + ActorName + " is forbidden to orgasm (by other mod)")
			return -9
		endIf
	endIf
	if StorageUtil.GetIntValue(ActorRef, "slso_forbid_orgasm") == 1
		int Seid = ModEvent.Create("SexLabOrgasmSeparateDenied")
		if Seid
			ModEvent.PushForm(Seid, ActorRef)
			ModEvent.PushInt(Seid, Thread.tid)
			ModEvent.Send(Seid)
		endif
		Log("Orgasm blocked, " + ActorName + " is forbidden to orgasm")
		return -10
	endIf
	return 0
endFunction

function SLSO_DoOrgasm_Multiorgasm()
	String File = "/SLSO/Config.json"

	if BaseSex == 0
		if JsonUtil.GetIntValue(File, "condition_male_orgasm_penalty") == 1
			;male wont be able to orgasm 2nd time if slso game() and sla disabled
			;Log("male FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + GetOrgasmCount()*2)) as int+"]")
			if (Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))) || Position != 0
				if (!IsAggressor || IsPlayer)
					GenderMod = (1 + GetOrgasmCount()*2)
				endif
			endif
		endif
	endif
	;if (Utility.RandomInt(0, 100) > (JsonUtil.GetIntValue(File, "sl_multiorgasmchance") + ((OwnSkills[Stats.kLewd]*10) as int) - 10 * Orgasms)) || BaseSex != 1
	if (Utility.RandomInt(0, 100) > (JsonUtil.GetIntValue(File, "sl_multiorgasmchance") + ((OwnSkills[Stats.kLewd] * JsonUtil.GetIntValue(File, "sl_multiorgasmchance_curve")) as int) - 10 * Orgasms)) || BaseSex != 1
		;orgasm
		LastOrgasm = Math.Abs(SexLabUtil.GetCurrentGameRealTime())
		; Reset enjoyment build up, if using separate orgasms option
		if IsSkilled
			if IsVictim
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(5, 10)
			else
				if IsAggressor
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(5, 10)
				endIf
			endIf
		else
			if IsVictim
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(5, 10)
			else
				if IsAggressor
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(5, 10)
				endIf
			endIf
		endIf
		;reset slso enjoyment build up
		BonusEnjoyment = 0
	else
		;slso multiorgasm for females (rnd + lewdness), reset timer
		LastOrgasm = Math.Abs(SexLabUtil.GetCurrentGameRealTime() - 9)
	endIf
endFunction

function SLSO_DoOrgasm_SexLabOrgasmSeparate()
	if SeparateOrgasms
		String File = "/SLSO/Config.json"
		if !IsPlayer && (IsAggressor || (!IsAggressor && JsonUtil.GetIntValue(File, "condition_consensual_orgasm") == 1))
			if JsonUtil.GetIntValue(File, "game_enabled") == 1
				if GetOrgasmCount() == Thread.Get_minimum_aggressor_orgasm_Count()
					if Utility.RandomInt(0, 100) < JsonUtil.GetIntValue(File, "condition_chance_minimum_aggressor_orgasm_increase")
						Thread.Set_minimum_aggressor_orgasm_Count(Thread.Get_minimum_aggressor_orgasm_Count() + 1)
						Log("Aggressor - " + ActorName + " increased required orgasms to: " + Thread.Get_minimum_aggressor_orgasm_Count())
					endif
				endif
			endif
		endif
		int Seid = ModEvent.Create("SexLabOrgasmSeparate")
		if Seid
			ModEvent.PushForm(Seid, ActorRef)
			ModEvent.PushInt(Seid, Thread.tid)
			ModEvent.Send(Seid)
		endif
	endif
endFunction

function SLSO_StartAnimating()
	String File = "/SLSO/Config.json"
	BonusEnjoyment = 0
	if Game.GetModByName("SexLabAroused.esm") != 255
		slaArousal = Game.GetFormFromFile(0x3FC36, "SexLabAroused.esm") As Faction
	endIf
	if Game.GetModByName("Devious Devices - Assets.esm") != 255
		zadDeviousBelt = Game.GetFormFromFile(0x3330, "Devious Devices - Assets.esm") As Keyword
	endif
	
	bool SLSO_GAME_enabled = (JsonUtil.GetIntValue(File, "game_enabled") == 1 && Thread.HasPlayer) || (JsonUtil.GetIntValue(File, "game_npc_enabled", 0) == 1 && !Thread.HasPlayer)

;GetEnjoyment() condi checks
;to enable default sexlab enjoyment gains if true
	if JsonUtil.GetIntValue(File, "sl_passive_enjoyment") == 1 || !SLSO_GAME_enabled
		SLSOGetEnjoymentCheck1 = true
	else
		SLSOGetEnjoymentCheck1 = false
	endIf
	
	if JsonUtil.GetIntValue(File, "sl_stage_enjoyment") == 1 || !SLSO_GAME_enabled
		SLSOGetEnjoymentCheck2 = true
	else
		SLSOGetEnjoymentCheck2 = false
	endIf

;CalculateFullEnjoyment() checks
	ExhibitionistMod = 1
	bslaExhibitionist = false
	slaExhibitionistNPCCount = 0
	if !IsCreature
	;Check if actor sla exhibitionist
		if Game.GetModByName("SexLabAroused.esm") != 255
			slaExhibitionist = Game.GetFormFromFile(0x713DA, "SexLabAroused.esm") As Faction
			if slaExhibitionist != none
				if ActorRef.GetFactionRank(slaExhibitionist) >= 0
					bslaExhibitionist = true
				endif
			endif
		endIf
	;check npcs nearby for exhibitionist modifier
		if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 1
			Cell akTargetCell = ActorRef.GetParentCell()
			int iRef = 0
			while iRef <= akTargetCell.getNumRefs(43) && slaExhibitionistNPCCount < 6 ;GetType() 62-char,44-lvchar,43-npc
				Actor aNPC = akTargetCell.getNthRef(iRef, 43) as Actor
				If aNPC!= none && aNPC.GetDistance(ActorRef) < 1000 && aNPC != ActorRef && aNPC.HasLOS(ActorRef)
					slaExhibitionistNPCCount += 1
				EndIf
				iRef = iRef + 1
			endWhile
		endif
	;apply modifier 
		if JsonUtil.GetIntValue(File, "sl_exhibitionist") > 0
			if bslaExhibitionist || OwnSkills[Stats.kLewd] > 5
				slaExhibitionistNPCCount = PapyrusUtil.ClampInt(slaExhibitionistNPCCount, 0, 7)
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (3 - 0.4 * slaExhibitionistNPCCount)) as int+"]")
				;ExhibitionistMod = (3 - 0.4 * slaExhibitionistNPCCount)
				ExhibitionistMod =	(1.6 - 0.2 * slaExhibitionistNPCCount)
			elseif slaExhibitionistNPCCount > 1 && !IsAggressor
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + 0.2 * slaExhibitionistNPCCount)) as int+"]")
				ExhibitionistMod = (1 + 0.2 * slaExhibitionistNPCCount)
			endif
		endif
	endif
	
;Estrus, force enjoyment modifiers to 1+
	bool EstrusAnim = false
	if (Animation.HasTag("Estrus") || Animation.HasTag("Machine") || Animation.HasTag("Slime") || Animation.HasTag("Ooze"))
		EstrusAnim = true
	endif
	
	if EstrusAnim && JsonUtil.GetFloatValue(File, "sl_estrusforcedenjoyment") > 0
		EstrusForcedEnjoymentMods = true
	endif
	
;apply masturbation modifier 
	MasturbationMod = 1
	if Thread.ActorCount == 1 && JsonUtil.GetIntValue(File, "sl_masturbation") == 1

		;Log("masturbation_penalty FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment * (1 - 1 * (OwnSkills[Stats.kLewd]) / 10)) as int+"]")
		;Estrus, increase enjoyment with lewdness
		if EstrusAnim == true
			MasturbationMod = 1 + 1 * (OwnSkills[Stats.kLewd]) / 10
		;normal, reduce enjoyment with lewdness
		else
			MasturbationMod = 1 - 1 * (OwnSkills[Stats.kLewd]) / 10
		endif
		MasturbationMod = PapyrusUtil.ClampFloat(MasturbationMod, 0.1, 2.0)
	endif

;apply arousal modifier, 1=100%
	slaActorArousalMod = 1

;apply gender modifier 
	GenderMod = 1
	if BaseSex == 0
		sl_enjoymentrate = JsonUtil.GetFloatValue(File, "sl_enjoymentrate_male", missing = 1)
		if JsonUtil.GetIntValue(File, "condition_male_orgasm_penalty") == 1
			;male wont be able to orgasm 2nd time if slso game() and sla disabled
			;Log("male FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + GetOrgasmCount()*2)) as int+"]")
			
			;can probably be broken(not refreshed) by manually changing position/animation
			; probably no one will notice so w/e
			if (Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))) || Position != 0
				GenderMod = (1 + GetOrgasmCount()*2)
			endif
		endif
	else
		sl_enjoymentrate = JsonUtil.GetFloatValue(File, "sl_enjoymentrate_female", missing = 1)
	endif
		
	;OrgasmEffect() Orgasm condi checks
	;check if non aggressor actor meets orgasm conditions
	;can probably be broken by manually changing position/animation
	;perfomance decrease probably not worth it 
;		AllowNonAggressorOrgasm = 0
;		if !IsAggressor
;			if !(Animation.HasTag("69") || Animation.HasTag("Masturbation")) || Thread.Positions.Length == 2
;				if	IsFemale && JsonUtil.GetIntValue(File, "condition_female_orgasm") == 1
;					if Position == 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Lesbian"))
;						AllowNonAggressorOrgasm = 1
;					endIf
;				elseif IsMale && JsonUtil.GetIntValue(File, "condition_male_orgasm") == 1
;					if Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
;						AllowNonAggressorOrgasm = 2
;					elseif Position != 0 && && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Boobjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Handjob") || Animation.HasTag("Footjob"))
;						AllowNonAggressorOrgasm = 3
;					endIf
;				endIf
;			endIf
;		endIf
endFunction

Function SLSO_Animating_Moan()
	String File = "/SLSO/Config.json"
	if !IsSilent
		if !IsFemale
			Voice.PlayMoan(ActorRef, ActorFullEnjoyment, IsVictim, UseLipSync)
			;Log("	!IsFemale " + ActorName)
		elseif ((JsonUtil.GetIntValue(File, "sl_voice_player") == 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") == 0 && !IsPlayer))
			Voice.PlayMoan(ActorRef, ActorFullEnjoyment, IsVictim, UseLipSync)
			;Log("	IsFemale " + ActorName)
		endIf
	endIf
endFunction

Function SLSO_DoOrgasm_Moan()
	String File = "/SLSO/Config.json"
	if !IsSilent
		if !IsFemale
			PlayLouder(Voice.GetSound(100, false), ActorRef, Config.VoiceVolume)
		;replace SL actor voice with SLSO, if voice options enabled in SLSO
		elseif ((JsonUtil.GetIntValue(File, "sl_voice_player") == 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") == 0 && !IsPlayer))
			PlayLouder(Voice.GetSound(100, false), ActorRef, Config.VoiceVolume)
		endIf
	endIf
	PlayLouder(OrgasmFX, MarkerRef, Config.SFXVolume)
endFunction

