-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- ActionsManager.registerModHandler("skill", modSkill);
	ActionsManager.registerResultHandler("skill", onRoll);
end

function performPartySheetRoll(draginfo, rActor, sSkillName, nSkillMod)
    print("performPartySheetRoll");
    Debug.console(draginfo);
    Debug.console(rActor);
    Debug.console(sSkillName);
    Debug.console(nSkillMod);

	local rRoll = getRoll(rActor, sSkillName, nSkillMod);
					
	local nTargetDC = DB.getValue("partysheet.skilldc", 0);
	if nTargetDC == 0 then
		nTargetDC = nil;
	end
	rRoll.nTarget = nTargetDC;
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performPCRoll(draginfo, rActor, nodeSkill)
    print("performPCRoll");
    Debug.console(draginfo);
    Debug.console(rActor);
    Debug.console(nodeSkill);

	local sSkillName = DB.getValue(nodeSkill, "label", "");
	local sSubskillName = DB.getValue(nodeSkill, "sublabel", "");
	if sSubskillName ~= "" then
		sSkillName = sSkillName .. " (" .. sSubskillName .. ")";
	end

	local nSkillMod = DB.getValue(nodeSkill, "total", 0);
	local sSkillStat = DB.getValue(nodeSkill, "statname", "");
	
	performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat);
end

function performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat, sExtra)
   print("performRoll");
   Debug.console(draginfo);
   Debug.console(rActor);
   Debug.console(sSkillName);
   Debug.console(nSkillMod);
   Debug.console(sSkillStat);
   Debug.console(sExtra);

	local rRoll = getRoll(rActor, sSkillName, nSkillMod, sSkillStat, sExtra);
	
	if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, sSkillName, nSkillMod, sSkillStat, sExtra)
    print("getRoll");
    Debug.console(rActor);
    Debug.console(sSkillName);
    Debug.console(nSkillMod);
    Debug.console(sSkillStat);
    Debug.console(sExtra);

	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d10" };
	rRoll.nMod = nSkillMod or 0;
	rRoll.sDesc = "[SKILL] " .. sSkillName;
	--if sExtra then
	--	rRoll.sDesc = rRoll.sDesc .. " " .. sExtra;
	--end
	
	--if sSkillStat then
   	--local sAbilityEffect = sSkillStat;
   	--if sAbilityEffect then
   	--	rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
   	--end
	--end
	
	--if rActor and rActor.sType == "pc" then
		local sSkillLookup;
		local sSubSkill = nil;
		--if sSkillName:match("^Knowledge") then
		--	sSubSkill = sSkillName:sub(12, -2);
		--	sSkillLookup = "Knowledge";
		--else
			sSkillLookup = sSkillName;
		--end
		--_,bUntrained = CharManager.getSkillValue(rActor, sSkillLookup, sSubSkill);
		--if bUntrained then
		--	rRoll.sDesc = rRoll.sDesc .. " [UNTRAINED]";
		--end
	--end
	
	return rRoll;
end

function modSkill(rSource, rTarget, rRoll)
   print("modSkill");
   Debug.console(rSource);
   Debug.console(rTarget);
   Debug.console(rRoll);

	local bAssist = Input.isShiftPressed();
	if bAssist then
		rRoll.sDesc = rRoll.sDesc .. " [ASSIST]";
	end
	
	local nAddMod = 0;
	local aAddDice = {};

	if rSource then
		local bEffects = false;
		local sActorType, nodeActor = ActorManager.getTypeAndNode(rSource);

		-- Determine skill used
		local sSkillLower = "";
		local sSkill = string.match(rRoll.sDesc, "%[SKILL%] ([^[]+)");
		if sSkill then
			sSkillLower = string.lower(StringManager.trim(sSkill));
		end

		-- Determine ability used with this skill
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		else
			for k, v in pairs(DataCommon.skilldata) do
				if string.lower(k) == sSkillLower then
					sActionStat = v.stat;
				end
			end
		end

		-- Build effect filter for this skill
		local aSkillFilter = {};
		if sActionStat then
			table.insert(aSkillFilter, sActionStat);
		end
		local aSkillNameFilter = {};
		local aSkillWordsLower = StringManager.parseWords(sSkillLower);
		if #aSkillWordsLower > 0 then
			if #aSkillWordsLower == 1 then
				table.insert(aSkillFilter, aSkillWordsLower[1]);
			else
				table.insert(aSkillFilter, table.concat(aSkillWordsLower, " "));
				if aSkillWordsLower[1] == "knowledge" or aSkillWordsLower[1] == "perform" or aSkillWordsLower[1] == "craft" then
					table.insert(aSkillFilter, aSkillWordsLower[1]);
				end
			end
		end
		
		-- Get effect bonuses as bonus types - so that modifiers from conditions can be applied/stacked correctly.
		-- TODO - removing the EffectManagerPFRPG2.getEffectsBonus step removes having dice in the effect.  Add back in later!
		--local aAddDice, nAddMod, nEffectCount = EffectManagerPFRPG2.getEffectsBonus(rSource, {"SKILL"}, false, aSkillFilter);
		--local aSKILLEffectsUntyped, aSKILLEffectBonuses, aSKILLEffectPenalties, nEffectCount = EffectManagerPFRPG2.getEffectsBonusByType(rSource, {"SKILL"}, false, aSkillFilter, nil, nil, nil, true);		
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- PFRPG2 - we need to split effects out into existing bonuses and penalties - as bonuses and penalties of the same type do offset the total.
		-- "untyped" is a catch all - it's not a valid AC bonus type (stored in DataCommon.actypes) but is used to store unmatched (untyped) bonuses/penalties
		local aCurrentBonusesByType = { item=0, conditional=0, circumstance=0, proficiency=0, untyped=0 };
		local aCurrentPenaltiesByType = { item=0, conditional=0, circumstance=0, proficiency=0, untyped=0 };	
		for k, v in pairs(aSKILLEffectsUntyped) do
			if v.mod > 0 then
				aCurrentBonusesByType["untyped"] = aCurrentBonusesByType["untyped"] + v.mod;
			elseif v.mod < 0 then
				aCurrentPenaltiesByType["untyped"] = aCurrentPenaltiesByType["untyped"] + v.mod;
			end
		end
		for k, v in pairs(aSKILLEffectBonuses) do
			aCurrentBonusesByType[k] = ActorManager2.addBonusToType(aCurrentBonusesByType[k], v);	
		end	
		for k, v in pairs(aSKILLEffectPenalties) do
			aCurrentPenaltiesByType[k] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType[k], v);
		end		
		GlobalDebug.consoleObjects("SkillManager.modRoll - bonuses and penalties setup from attacker SKILL effects.  nEffectCount, aSKILLEffectsUntyped, aSKILLEffectBonuses, aSKILLEffectPenalties, aCurrentBonusesByType, aCurrentPenaltiesByType = ", nEffectCount, aSKILLEffectsUntyped, aSKILLEffectBonuses, aSKILLEffectPenalties, aCurrentBonusesByType, aCurrentPenaltiesByType);		
		
		-- Get condition modifiers
		-- Need to filter these based off the skill being used and also the bonus types.		
		
		-- Check for enervated value
		local nEnervatedValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Enervated"}, true, nil, rTarget);
		if nEnervatedValue > 0 then
			-- This is a PROF penalty - which impacts INIT.
			local nLevel = DB.getValue(nodeActor, "level", 0);
			GlobalDebug.consoleObjects("InitManager.modRoll - Enervated level, Actor level, nodeActor = ", nEnervatedValue, nLevel, nodeActor);
			-- Enervation is limited to level with a minimum of 1
			if nLevel < 1 then
				nLevel = 1;
			end
			if nLevel > 0 and nEnervatedValue <= nLevel then
				aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nEnervatedValue);
			elseif nLevel > 0 and nEnervatedValue > nLevel then
				aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nLevel);
			end
			bEffects = true;
		end	
		-- Check for Fascinated condition
		if EffectManagerPFRPG2.hasEffect(rSource, "Fascinated") then
			aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -2);	
			bEffects = true;
		end		
		-- Check for Frightened value
		local nFrightenedValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Frightened"}, true, nil, rTarget);
		if nFrightenedValue > 0 then
			-- This is a check penalty - which impacts Skill checks.
			aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nFrightenedValue);
			bEffects = true;
		end		
		-- Check for Sick value
		local nSickValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Sick"}, true, nil, rTarget);
		if nSickValue > 0 then
			-- This is a PROF penalty - which impacts Skill checks.
			aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nSickValue);
			bEffects = true;
		end			
		
		-- Handle conditions that impact a specific skill check
		if sSkillLower ~= "" then
			if sSkillLower == "perception" then 
				-- Check for conditions that impact perception checks.
				-- Check for Asleep or Blinded condition.  For Blinded assumed vision is the actor's only precise sense.
				-- TODO - check for other senses?
				if EffectManagerPFRPG2.hasEffect(rSource, "Asleep") or EffectManagerPFRPG2.hasEffect(rSource, "Blinded") then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -4);	
					bEffects = true;
				end	
				if EffectManagerPFRPG2.hasEffect(rSource, "Deafened") then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -2);	
					bEffects = true;
				end				
			
			end
		end
		
		-- Handle conditions that impact a specific ability
		if sActionStat then
			if sActionStat:lower() == "strength" then 
				-- Check for conditions that impact strength based checks.
				-- Check for Enfeebled value
				local nEnfeebledValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Enfeebled"}, true, nil, rTarget);
				if nEnfeebledValue > 0 then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nEnfeebledValue);
					bEffects = true;
				end			
			elseif sActionStat:lower() == "dexterity" then 
				-- Check for conditions that impact dexterity based checks.
				-- Check for Sluggish value
				local nSluggishValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Sluggish"}, true, nil, rTarget);
				if nSluggishValue > 0 then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nSluggishValue);
					bEffects = true;
				end	
			elseif sActionStat:lower() == "constitution" then 
				-- Check for conditions that impact constitution based checks.
				-- Check for Drained value
				local nDrainedValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Drained"}, true, nil, rTarget);
				if nDrainedValue > 0 then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nDrainedValue);
					bEffects = true;
				end	
			elseif sActionStat:lower() == "intelligence" or sActionStat:lower() == "wisdom" or sActionStat:lower() == "charisma" then 
				-- Check for Stupefied value
				local nStupefiedValue = EffectManagerPFRPG2.getConditionValue(rSource, {"Stupefied"}, true, nil, rTarget);
				if nStupefiedValue > 0 then
					aCurrentPenaltiesByType["conditional"] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType["conditional"], -nStupefiedValue);
					bEffects = true;
				end				
			end
		end		

		-- PROF effects - which impacts Skill checks.
		-- Need to cater for specific bonus types - with the possibility of having multiple bonuses and penalties of the same type all needing to be combined.
		local aProfEffectsUntyped, aProfEffectsBonuses, aProfEffectsPenalties, nProfEffectsCount = EffectManagerPFRPG2.getEffectsBonusByType(rSource, {"PROF"}, true, aAttackFilter, rTarget, nil, nil, true);
		if nProfEffectsCount and nProfEffectsCount > 0 then
			GlobalDebug.consoleObjects("modAttack: PROF Effects - aProfEffectsUntyped, aProfEffectsBonuses, aProfEffectsPenalties, nProfEffectsCount = ",  aProfEffectsUntyped, aProfEffectsBonuses, aProfEffectsPenalties, nProfEffectsCount);	
			for k, v in pairs(aProfEffectsUntyped) do
				if v.mod > 0 then
					aCurrentBonusesByType["untyped"] = aCurrentBonusesByType["untyped"] + v.mod;
				elseif v.mod < 0 then
					aCurrentPenaltiesByType["untyped"] = aCurrentPenaltiesByType["untyped"] + v.mod;
				end
			end
			for k, v in pairs(aProfEffectsBonuses) do
				aCurrentBonusesByType[k] = ActorManager2.addBonusToType(aCurrentBonusesByType[k], v);	
			end	
			for k, v in pairs(aProfEffectsPenalties) do
				aCurrentPenaltiesByType[k] = ActorManager2.addPenaltyToType(aCurrentPenaltiesByType[k], v);
			end	
			bEffects = true;			
		end	

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager2.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		GlobalDebug.consoleObjects("InitManager.modRoll: Completed processing effects and conditions.   = nAddMod, aCurrentBonusesByType, aCurrentPenaltiesByType = ", nAddMod, aCurrentBonusesByType, aCurrentPenaltiesByType);			
		
		-- At this point we should have all of the various maximum bonus and penalty for each type.  Run through them to calculate the overall effect modifier to INIT.
		for k, v in pairs(aCurrentBonusesByType) do
			if v > 0 then
				nAddMod = nAddMod + v;
			end
		end
		for k, v in pairs(aCurrentPenaltiesByType) do
			if v < 0 then
				nAddMod = nAddMod + v;
			end
		end			

		GlobalDebug.consoleObjects("modAttack: Final modifier nAddMod = ", nAddMod);		
		
		-- Get negative levels
--		local nNegLevelMod, nNegLevelCount = EffectManagerPFRPG2.getEffectsBonus(rSource, {"NLVL"}, true);
--		if nNegLevelCount > 0 then
--			bEffects = true;
--			nAddMod = nAddMod - nNegLevelMod;
--		end

		-- If effects, then add them
		if bEffects then
			for _,vDie in ipairs(aAddDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rRoll.nMod = rRoll.nMod + nAddMod;

			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
		end
	end
end

function onRoll(rSource, rTarget, rRoll)
    print("onRoll");
    Debug.console(rSource);
    Debug.console(rTarget);
    Debug.console(rRoll);
    
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

	if rRoll.nTarget then
		local nTotal = ActionsManager.total(rRoll);
		local nTargetDC = tonumber(rRoll.nTarget) or 0;
		
		rMessage.text = rMessage.text .. " (vs. DC " .. nTargetDC .. ")";
		if nTotal >= nTargetDC then
			rMessage.text = rMessage.text .. " [SUCCESS]";
		else
			rMessage.text = rMessage.text .. " [FAILURE]";
		end
	end
	
	local nTotal = ActionsManager.total(rRoll);
	Comm.deliverChatMessage(rMessage);
end
