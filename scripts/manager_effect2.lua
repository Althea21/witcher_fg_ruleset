-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- EffectManager.registerEffectVar("sUnits", { sDBType = "string", sDBField = "unit", bSkipAdd = true });
	-- EffectManager.registerEffectVar("sApply", { sDBType = "string", sDBField = "apply", sDisplay = "[%s]" });
	-- EffectManager.registerEffectVar("sTargeting", { sDBType = "string", bClearOnUntargetedDrop = true });
	
	EffectManager.setCustomOnEffectAddStart(onEffectAddStart);
	
	EffectManager.setCustomOnEffectRollEncode(onEffectRollEncode);
	EffectManager.setCustomOnEffectTextEncode(onEffectTextEncode);
	EffectManager.setCustomOnEffectTextDecode(onEffectTextDecode);

	EffectManager.setCustomOnEffectActorStartTurn(onEffectActorStartTurn);
end

--
-- EFFECT MANAGER OVERRIDES
--

function onEffectAddStart(rEffect)
    -- Debug.chat("------------------------------------------")
    -- Debug.chat("onEffectAddStart")
    -- Debug.chat(rEffect)
    
    rEffect.nDuration = rEffect.nDuration or 1;
	-- if rEffect.sUnits == "minute" then
	-- 	rEffect.nDuration = rEffect.nDuration * 10;
	-- elseif rEffect.sUnits == "hour" or rEffect.sUnits == "day" then
	-- 	rEffect.nDuration = 0;
	-- end
	-- rEffect.sUnits = "";
end

function onEffectRollEncode(rRoll, rEffect)
    -- Debug.chat("------------------------------------------")
    -- Debug.chat("onEffectRollEncode")
    -- Debug.chat(rRoll)
    -- Debug.chat(rEffect)

    -- if rEffect.sTargeting and rEffect.sTargeting == "self" then
	-- 	rRoll.bSelfTarget = true;
	-- end
end

function onEffectTextEncode(rEffect)
    -- Debug.chat("------------------------------------------")
    -- Debug.chat("onEffectTextEncode")
    -- Debug.chat(rEffect)
    
    --local aMessage = {};
	
	-- if rEffect.sUnits and rEffect.sUnits ~= "" then
	-- 	local sOutputUnits = nil;
	-- 	if rEffect.sUnits == "minute" then
	-- 		sOutputUnits = "MIN";
	-- 	elseif rEffect.sUnits == "hour" then
	-- 		sOutputUnits = "HR";
	-- 	elseif rEffect.sUnits == "day" then
	-- 		sOutputUnits = "DAY";
	-- 	end

	-- 	if sOutputUnits then
	-- 		table.insert(aMessage, "[UNITS " .. sOutputUnits .. "]");
	-- 	end
	-- end
	-- if rEffect.sTargeting and rEffect.sTargeting ~= "" then
	-- 	table.insert(aMessage, "[" .. rEffect.sTargeting:upper() .. "]");
	-- end
	-- if rEffect.sApply and rEffect.sApply ~= "" then
	-- 	table.insert(aMessage, "[" .. rEffect.sApply:upper() .. "]");
	-- end
	
    -- return table.concat(aMessage, " ");
    return "";
end

function onEffectTextDecode(sEffect, rEffect)
    -- Debug.chat("------------------------------------------")
    -- Debug.chat("onEffectTextDecode")
    -- Debug.chat(sEffect)
    -- Debug.chat(rEffect)
    
    -- local s = sEffect;
	
	-- local sUnits = s:match("%[UNITS ([^]]+)]");
	-- if sUnits then
	-- 	s = s:gsub("%[UNITS ([^]]+)]", "");
	-- 	if sUnits == "MIN" then
	-- 		rEffect.sUnits = "minute";
	-- 	elseif sUnits == "HR" then
	-- 		rEffect.sUnits = "hour";
	-- 	elseif sUnits == "DAY" then
	-- 		rEffect.sUnits = "day";
	-- 	end
	-- end
	-- if s:match("%[SELF%]") then
	-- 	s = s:gsub("%[SELF%]", "");
	-- 	rEffect.sTargeting = "self";
	-- end
	-- if s:match("%[ACTION%]") then
	-- 	s = s:gsub("%[ACTION%]", "");
	-- 	rEffect.sApply = "action";
	-- elseif s:match("%[ROLL%]") then
	-- 	s = s:gsub("%[ROLL%]", "");
	-- 	rEffect.sApply = "roll";
	-- elseif s:match("%[SINGLE%]") then
	-- 	s = s:gsub("%[SINGLE%]", "");
	-- 	rEffect.sApply = "single";
	-- end
	
    -- return s;
    return sEffect;
end

function onEffectActorStartTurn(nodeActor, nodeEffect)
    -- Debug.console("------------------------------------------")
    -- Debug.console("onEffectActorStartTurn")
    -- Debug.console(nodeActor)
    -- Debug.console(nodeEffect)

    local sEffName = DB.getValue(nodeEffect, "label", "");
    sEffName = sEffName:lower();

    if sEffName=="fire" or sEffName=="bleeding" or sEffName=="poisonned" or sEffName=="suffocating" then
        local rTarget = ActorManager.resolveActor(nodeActor);
        ActionDamage.applyConditionDamage(rTarget, sEffName);
    end

    -- local sEffName = DB.getValue(nodeEffect, "label", "");
	-- local aEffectComps = EffectManager.parseEffect(sEffName);
	-- for _,sEffectComp in ipairs(aEffectComps) do
	-- 	local rEffectComp = parseEffectComp(sEffectComp);
	-- 	-- Conditionals
	-- 	if rEffectComp.type == "IFT" then
	-- 		break;
	-- 	elseif rEffectComp.type == "IF" then
	-- 		local rActor = ActorManager.resolveActor(nodeActor);
	-- 		if not checkConditional(rActor, nodeEffect, rEffectComp.remainder) then
	-- 			break;
	-- 		end
		
	-- 	-- Ongoing damage, fast healing and regeneration
	-- 	elseif rEffectComp.type == "DMGO" or rEffectComp.type == "FHEAL" or rEffectComp.type == "REGEN" then
	-- 		local nActive = DB.getValue(nodeEffect, "isactive", 0);
	-- 		if nActive == 2 then
	-- 			DB.setValue(nodeEffect, "isactive", "number", 1);
	-- 		else
	-- 			applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp);
	-- 		end
	-- 	end
	-- end
end

--
-- CUSTOM FUNCTIONS
--

function parseEffectComp(s)
	local sType = nil;
	local aDice = {};
	local nMod = 0;
	local aRemainder = {};
	local nRemainderIndex = 1;
	
	local aWords, aWordStats = StringManager.parseWords(s, "%[%]%(%):");
	if #aWords > 0 then
		sType = aWords[1]:match("^([^:]+):");
		if sType then
			nRemainderIndex = 2;
			
			local sValueCheck = aWords[1]:sub(#sType + 2);
			if sValueCheck ~= "" then
				table.insert(aWords, 2, sValueCheck);
				table.insert(aWordStats, 2, { startpos = aWordStats[1].startpos + #sType + 1, endpos = aWordStats[1].endpos });
				aWords[1] = aWords[1]:sub(1, #sType + 1);
				aWordStats[1].endpos = #sType + 1;
			end
			
			if #aWords > 1 then
				if StringManager.isDiceString(aWords[2]) then
					aDice, nMod = StringManager.convertStringToDice(aWords[2]);
					nRemainderIndex = 3;
				end
			end
		end
		
		if nRemainderIndex <= #aWords then
			while nRemainderIndex <= #aWords and aWords[nRemainderIndex]:match("^%[%d?%a+%]$") do
				table.insert(aRemainder, aWords[nRemainderIndex]);
				nRemainderIndex = nRemainderIndex + 1;
			end
		end
		
		if nRemainderIndex <= #aWords then
			local sRemainder = s:sub(aWordStats[nRemainderIndex].startpos);
			local nStartRemainderPhrase = 1;
			local i = 1;
			while i < #sRemainder do
				local sCheck = sRemainder:sub(i, i);
				if sCheck == "," then
					local sRemainderPhrase = sRemainder:sub(nStartRemainderPhrase, i - 1);
					if sRemainderPhrase and sRemainderPhrase ~= "" then
						sRemainderPhrase = StringManager.trim(sRemainderPhrase);
						table.insert(aRemainder, sRemainderPhrase);
					end
					nStartRemainderPhrase = i + 1;
				elseif sCheck == "(" then
					while i < #sRemainder do
						if sRemainder:sub(i, i) == ")" then
							break;
						end
						i = i + 1;
					end
				elseif sCheck == "[" then
					while i < #sRemainder do
						if sRemainder:sub(i, i) == "]" then
							break;
						end
						i = i + 1;
					end
				end
				i = i + 1;
			end
			local sRemainderPhrase = sRemainder:sub(nStartRemainderPhrase, #sRemainder);
			if sRemainderPhrase and sRemainderPhrase ~= "" then
				sRemainderPhrase = StringManager.trim(sRemainderPhrase);
				table.insert(aRemainder, sRemainderPhrase);
			end
		end
	end

	return  {
		type = sType or "", 
		mod = nMod, 
		dice = aDice, 
		remainder = aRemainder, 
		original = StringManager.trim(s)
	};
end

function rebuildParsedEffectComp(rComp)
	if not rComp then
		return "";
	end
	
	local aComp = {};
	if rComp.type ~= "" then
		table.insert(aComp, rComp.type .. ":");
	end
	local sDiceString = StringManager.convertDiceToString(rComp.dice, rComp.mod);
	if sDiceString ~= "" then
		table.insert(aComp, sDiceString);
	end
	if #(rComp.remainder) > 0 then
		table.insert(aComp, table.concat(rComp.remainder, ","));
	end
	return table.concat(aComp, " ");
end

function applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp)
	if #(rEffectComp.dice) == 0 and rEffectComp.mod == 0 then
		return;
	end
	
	local aResults = {};
	if rEffectComp.type == "FHEAL" then
		if DB.getValue(nodeActor, "wounds", 0) == 0 and DB.getValue(nodeActor, "nonlethal", 0) == 0 then
			return;
		end
		table.insert(aResults, "[FHEAL] Fast Heal");

	elseif rEffectComp.type == "REGEN" then
		local bPFMode = DataCommon.isPFRPG();
		if bPFMode then
			if DB.getValue(nodeActor, "wounds", 0) == 0 and DB.getValue(nodeActor, "nonlethal", 0) == 0 then
				return;
			end
		else
			if DB.getValue(nodeActor, "nonlethal", 0) == 0 then
				return;
			end
		end
		table.insert(aResults, "[REGEN] Regeneration");

	else
		table.insert(aResults, "[DAMAGE] Ongoing Damage");
		if #(rEffectComp.remainder) > 0 then
			table.insert(aResults, "[TYPE: " .. table.concat(rEffectComp.remainder, ","):lower() .. "]");
		end
	end

	local rTarget = ActorManager.resolveActor(nodeActor);
	local rRoll = { sType = "damage", sDesc = table.concat(aResults, " "), aDice = rEffectComp.dice, nMod = rEffectComp.mod };
	if EffectManager.isGMEffect(nodeActor, nodeEffect) then
		rRoll.bSecret = true;
	end
	ActionsManager.roll(nil, rTarget, rRoll);
end

function evalAbilityHelper(rActor, sEffectAbility, nodeSpellClass)
	local sSign, sModifier, sShortAbility = sEffectAbility:match("^%[([%+%-]?)([H%d]?)([A-Z][A-Z][A-Z]?)%]$");

	local nAbility = nil;
	if sShortAbility == "STR" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "strength");
	elseif sShortAbility == "DEX" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "dexterity");
	elseif sShortAbility == "CON" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "constitution");
	elseif sShortAbility == "INT" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "intelligence");
	elseif sShortAbility == "WIS" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "wisdom");
	elseif sShortAbility == "CHA" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "charisma");
	elseif sShortAbility == "LVL" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "level");
	elseif sShortAbility == "BAB" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "bab");
	elseif sShortAbility == "CL" then
		if nodeSpellClass then
			nAbility = DB.getValue(nodeSpellClass, "cl", 0);
		end
	end
	
	if nAbility then
		if sSign == "-" then
			nAbility = 0 - nAbility;
		end
		if sModifier == "H" then
			if nAbility > 0 then
				nAbility = math.floor(nAbility / 2);
			else
				nAbility = math.ceil(nAbility / 2);
			end
		elseif sModifier then
			nAbility = nAbility * (tonumber(sModifier) or 1);
		end
	end
	
	return nAbility;
end

function evalEffect(rActor, s, nodeSpellClass)
	if not s then
		return "";
	end
	if not rActor then
		return s;
	end
	
	local aNewEffectComps = {};
	local aEffectComps = EffectManager.parseEffect(s);
	for _,sComp in ipairs(aEffectComps) do
		local rEffectComp = parseEffectComp(sComp);
		for i = #(rEffectComp.remainder), 1, -1 do
			if rEffectComp.remainder[i]:match("^%[([%+%-]?)([H%d]?)([A-Z][A-Z][A-Z]?)%]$") then
				local nAbility = evalAbilityHelper(rActor, rEffectComp.remainder[i], nodeSpellClass);
				if nAbility then
					rEffectComp.mod = rEffectComp.mod + nAbility;
					table.remove(rEffectComp.remainder, i);
				end
			end
		end
		table.insert(aNewEffectComps, rebuildParsedEffectComp(rEffectComp));
	end
	local sOutput = EffectManager.rebuildParsedEffect(aNewEffectComps);
	
	return sOutput;
end

function getEffectsByType(rActor, sEffectType, aFilter, rFilterActor, bTargetedOnly)
	if not rActor then
		return {};
	end
	local results = {};
	
	-- Set up filters
	local aRangeFilter = {};
	local aOtherFilter = {};
	if aFilter then
		for _,v in pairs(aFilter) do
			if type(v) ~= "string" then
				table.insert(aOtherFilter, v);
			elseif StringManager.contains(DataCommon.rangetypes, v) then
				table.insert(aRangeFilter, v);
			else
				table.insert(aOtherFilter, v);
			end
		end
	end
	
	-- Determine effect type targeting
	local bTargetSupport = StringManager.isWord(sEffectType, DataCommon.targetableeffectcomps);
	
	-- Iterate through effects
	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		-- Check active
		local nActive = DB.getValue(v, "isactive", 0);
		if (nActive ~= 0) then
			-- Check targeting
			local bTargeted = EffectManager.isTargetedEffect(v);
			if not bTargeted or EffectManager.isEffectTarget(v, rFilterActor) then
				local sLabel = DB.getValue(v, "label", "");
				local aEffectComps = EffectManager.parseEffect(sLabel);
				
				-- Look for type/subtype match
				local nMatch = 0;
				for kEffectComp, sEffectComp in ipairs(aEffectComps) do
					local rEffectComp = parseEffectComp(sEffectComp);
					-- Handle conditionals
					if rEffectComp.type == "IF" then
						if not checkConditional(rActor, v, rEffectComp.remainder) then
							break;
						end
					elseif rEffectComp.type == "IFT" then
						if not rFilterActor then
							break;
						end
						if not checkConditional(rFilterActor, v, rEffectComp.remainder, rActor) then
							break;
						end
						bTargeted = true;
					
					-- Compare other attributes
					else
						-- Strip energy/bonus types for subtype comparison
						local aEffectRangeFilter = {};
						local aEffectOtherFilter = {};
						
						local aComponents = {};
						for _,vPhrase in ipairs(rEffectComp.remainder) do
							local nTempIndexOR = 0;
							local aPhraseOR = {};
							repeat
								local nStartOR, nEndOR = vPhrase:find("%s+or%s+", nTempIndexOR);
								if nStartOR then
									table.insert(aPhraseOR, vPhrase:sub(nTempIndexOR, nStartOR - nTempIndexOR));
									nTempIndexOR = nEndOR;
								else
									table.insert(aPhraseOR, vPhrase:sub(nTempIndexOR));
								end
							until nStartOR == nil;
							
							for _,vPhraseOR in ipairs(aPhraseOR) do
								local nTempIndexAND = 0;
								repeat
									local nStartAND, nEndAND = vPhraseOR:find("%s+and%s+", nTempIndexAND);
									if nStartAND then
										local sInsert = StringManager.trim(vPhraseOR:sub(nTempIndexAND, nStartAND - nTempIndexAND));
										table.insert(aComponents, sInsert);
										nTempIndexAND = nEndAND;
									else
										local sInsert = StringManager.trim(vPhraseOR:sub(nTempIndexAND));
										table.insert(aComponents, sInsert);
									end
								until nStartAND == nil;
							end
						end
						local j = 1;
						while aComponents[j] do
							if StringManager.contains(DataCommon.dmgtypes, aComponents[j]) or 
									StringManager.contains(DataCommon.bonustypes, aComponents[j]) or
									aComponents[j] == "all" then
								-- Skip
							elseif StringManager.contains(DataCommon.rangetypes, aComponents[j]) then
								table.insert(aEffectRangeFilter, aComponents[j]);
							else
								table.insert(aEffectOtherFilter, aComponents[j]);
							end
							
							j = j + 1;
						end
					
						-- Check for match
						local comp_match = false;
						if rEffectComp.type == sEffectType then

							-- Check effect targeting
							if bTargetedOnly and not bTargeted then
								comp_match = false;
							else
								comp_match = true;
							end
						
							-- Check filters
							if #aEffectRangeFilter > 0 then
								local bRangeMatch = false;
								for _,v2 in pairs(aRangeFilter) do
									if StringManager.contains(aEffectRangeFilter, v2) then
										bRangeMatch = true;
										break;
									end
								end
								if not bRangeMatch then
									comp_match = false;
								end
							end
							if #aEffectOtherFilter > 0 then
								local bOtherMatch = false;
								for _,v2 in pairs(aOtherFilter) do
									if type(v2) == "table" then
										local bOtherTableMatch = true;
										for k3, v3 in pairs(v2) do
											if not StringManager.contains(aEffectOtherFilter, v3) then
												bOtherTableMatch = false;
												break;
											end
										end
										if bOtherTableMatch then
											bOtherMatch = true;
											break;
										end
									elseif StringManager.contains(aEffectOtherFilter, v2) then
										bOtherMatch = true;
										break;
									end
								end
								if not bOtherMatch then
									comp_match = false;
								end
							end
						end

						-- Match!
						if comp_match then
							nMatch = kEffectComp;
							if nActive == 1 then
								table.insert(results, rEffectComp);
							end
						end
					end
				end -- END EFFECT COMPONENT LOOP

				-- Remove one shot effects
				if nMatch > 0 then
					if nActive == 2 then
						DB.setValue(v, "isactive", "number", 1);
					else
						local sApply = DB.getValue(v, "apply", "");
						if sApply == "action" then
							EffectManager.notifyExpire(v, 0);
						elseif sApply == "roll" then
							EffectManager.notifyExpire(v, 0, true);
						elseif sApply == "single" then
							EffectManager.notifyExpire(v, nMatch, true);
						end
					end
				end
			end -- END TARGET CHECK
		end  -- END ACTIVE CHECK
	end  -- END EFFECT LOOP
	
	return results;
end

function getEffectsBonusByType(rActor, aEffectType, bAddEmptyBonus, aFilter, rFilterActor, bTargetedOnly)
	if not rActor or not aEffectType then
		return {}, 0;
	end
	
	-- MAKE BONUS TYPE INTO TABLE, IF NEEDED
	if type(aEffectType) ~= "table" then
		aEffectType = { aEffectType };
	end
	
	-- PER EFFECT TYPE VARIABLES
	local results = {};
	local bonuses = {};
	local penalties = {};
	local nEffectCount = 0;
	
	for k, v in pairs(aEffectType) do
		-- LOOK FOR EFFECTS THAT MATCH BONUSTYPE
		local aEffectsByType = getEffectsByType(rActor, v, aFilter, rFilterActor, bTargetedOnly);

		-- ITERATE THROUGH EFFECTS THAT MATCHED
		for k2,v2 in pairs(aEffectsByType) do
			-- LOOK FOR ENERGY OR BONUS TYPES
			local dmg_type = nil;
			local mod_type = nil;
			for _,v3 in pairs(v2.remainder) do
				if StringManager.contains(DataCommon.dmgtypes, v3) or StringManager.contains(DataCommon.immunetypes, v3) or v3 == "all" then
					dmg_type = v3;
					break;
				elseif StringManager.contains(DataCommon.bonustypes, v3) then
					mod_type = v3;
					break;
				end
			end
			
			-- IF MODIFIER TYPE IS UNTYPED, THEN APPEND MODIFIERS
			-- (SUPPORTS DICE)
			if dmg_type or not mod_type then
				-- ADD EFFECT RESULTS 
				local new_key = dmg_type or "";
				local new_results = results[new_key] or {dice = {}, mod = 0, remainder = {}};

				-- BUILD THE NEW RESULT
				for _,v3 in pairs(v2.dice) do
					table.insert(new_results.dice, v3); 
				end
				if bAddEmptyBonus then
					new_results.mod = new_results.mod + v2.mod;
				else
					new_results.mod = math.max(new_results.mod, v2.mod);
				end
				for _,v3 in pairs(v2.remainder) do
					table.insert(new_results.remainder, v3);
				end

				-- SET THE NEW DICE RESULTS BASED ON ENERGY TYPE
				results[new_key] = new_results;

			-- OTHERWISE, TRACK BONUSES AND PENALTIES BY MODIFIER TYPE 
			-- (IGNORE DICE, ONLY TAKE BIGGEST BONUS AND/OR PENALTY FOR EACH MODIFIER TYPE)
			else
				local bStackable = StringManager.contains(DataCommon.stackablebonustypes, mod_type);
				if v2.mod >= 0 then
					if bStackable then
						bonuses[mod_type] = (bonuses[mod_type] or 0) + v2.mod;
					else
						bonuses[mod_type] = math.max(v2.mod, bonuses[mod_type] or 0);
					end
				elseif v2.mod < 0 then
					if bStackable then
						penalties[mod_type] = (penalties[mod_type] or 0) + v2.mod;
					else
						penalties[mod_type] = math.min(v2.mod, penalties[mod_type] or 0);
					end
				end

			end
			
			-- INCREMENT EFFECT COUNT
			nEffectCount = nEffectCount + 1;
		end
	end

	-- COMBINE BONUSES AND PENALTIES FOR NON-ENERGY TYPED MODIFIERS
	for k2,v2 in pairs(bonuses) do
		if results[k2] then
			results[k2].mod = results[k2].mod + v2;
		else
			results[k2] = {dice = {}, mod = v2, remainder = {}};
		end
	end
	for k2,v2 in pairs(penalties) do
		if results[k2] then
			results[k2].mod = results[k2].mod + v2;
		else
			results[k2] = {dice = {}, mod = v2, remainder = {}};
		end
	end

	return results, nEffectCount;
end

function getEffectsBonus(rActor, aEffectType, bModOnly, aFilter, rFilterActor, bTargetedOnly)
	if not rActor or not aEffectType then
		if bModOnly then
			return 0, 0;
		end
		return {}, 0, 0;
	end
	
	-- MAKE BONUS TYPE INTO TABLE, IF NEEDED
	if type(aEffectType) ~= "table" then
		aEffectType = { aEffectType };
	end
	
	-- START WITH AN EMPTY MODIFIER TOTAL
	local aTotalDice = {};
	local nTotalMod = 0;
	local nEffectCount = 0;
	
	-- ITERATE THROUGH EACH BONUS TYPE
	local masterbonuses = {};
	local masterpenalties = {};
	for k, v in pairs(aEffectType) do
		-- GET THE MODIFIERS FOR THIS MODIFIER TYPE
		local effbonusbytype, nEffectSubCount = getEffectsBonusByType(rActor, v, true, aFilter, rFilterActor, bTargetedOnly);
		
		-- ITERATE THROUGH THE MODIFIERS
		for k2, v2 in pairs(effbonusbytype) do
			-- IF MODIFIER TYPE IS UNTYPED, THEN APPEND TO TOTAL MODIFIER
			-- (SUPPORTS DICE)
			if k2 == "" or StringManager.contains(DataCommon.dmgtypes, k2) then
				for k3, v3 in pairs(v2.dice) do
					table.insert(aTotalDice, v3);
				end
				nTotalMod = nTotalMod + v2.mod;
			
			-- OTHERWISE, WE HAVE A NON-ENERGY MODIFIER TYPE, WHICH MEANS WE NEED TO INTEGRATE
			-- (IGNORE DICE, ONLY TAKE BIGGEST BONUS AND/OR PENALTY FOR EACH MODIFIER TYPE)
			else
				if v2.mod >= 0 then
					masterbonuses[k2] = math.max(v2.mod, masterbonuses[k2] or 0);
				elseif v2.mod < 0 then
					masterpenalties[k2] = math.min(v2.mod, masterpenalties[k2] or 0);
				end
			end
		end

		-- ADD TO EFFECT COUNT
		nEffectCount = nEffectCount + nEffectSubCount;
	end

	-- ADD INTEGRATED BONUSES AND PENALTIES FOR NON-ENERGY TYPED MODIFIERS
	for k,v in pairs(masterbonuses) do
		nTotalMod = nTotalMod + v;
	end
	for k,v in pairs(masterpenalties) do
		nTotalMod = nTotalMod + v;
	end
	
	if bModOnly then
		return nTotalMod, nEffectCount;
	end
	return aTotalDice, nTotalMod, nEffectCount;
end

function hasEffectCondition(rActor, sEffect)
	return hasEffect(rActor, sEffect, nil, false, true);
end

function hasEffect(rActor, sEffect, rTarget, bTargetedOnly, bIgnoreEffectTargets)
	if not sEffect or not rActor then
		return false;
	end
	local sLowerEffect = sEffect:lower();
	
	-- Iterate through each effect
	local aMatch = {};
	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		local nActive = DB.getValue(v, "isactive", 0);
		if nActive ~= 0 then
			-- Parse each effect label
			local sLabel = DB.getValue(v, "label", "");
			local bTargeted = EffectManager.isTargetedEffect(v);
			local aEffectComps = EffectManager.parseEffect(sLabel);

			-- Iterate through each effect component looking for a type match
			local nMatch = 0;
			for kEffectComp, sEffectComp in ipairs(aEffectComps) do
				local rEffectComp = parseEffectComp(sEffectComp);
				-- Check conditionals
				if rEffectComp.type == "IF" then
					if not checkConditional(rActor, v, rEffectComp.remainder) then
						break;
					end
				elseif rEffectComp.type == "IFT" then
					if not rTarget then
						break;
					end
					if not checkConditional(rTarget, v, rEffectComp.remainder, rActor) then
						break;
					end
				
				-- Check for match
				elseif rEffectComp.original:lower() == sLowerEffect then
					if bTargeted and not bIgnoreEffectTargets then
						if EffectManager.isEffectTarget(v, rTarget) then
							nMatch = kEffectComp;
						end
					elseif not bTargetedOnly then
						nMatch = kEffectComp;
					end
				end
				
			end
			
			-- If matched, then remove one-off effects
			if nMatch > 0 then
				if nActive == 2 then
					DB.setValue(v, "isactive", "number", 1);
				else
					table.insert(aMatch, v);
					local sApply = DB.getValue(v, "apply", "");
					if sApply == "action" then
						EffectManager.notifyExpire(v, 0);
					elseif sApply == "roll" then
						EffectManager.notifyExpire(v, 0, true);
					elseif sApply == "single" then
						EffectManager.notifyExpire(v, nMatch, true);
					end
				end
			end
		end
	end
	
	if #aMatch > 0 then
		return true;
	end
	return false;
end

function checkConditional(rActor, nodeEffect, aConditions, rTarget, aIgnore)
	local bReturn = true;
	
	if not aIgnore then
		aIgnore = {};
	end
	table.insert(aIgnore, nodeEffect.getNodeName());
	
	for _,v in ipairs(aConditions) do
		local sLower = v:lower();
		if sLower == DataCommon.healthstatusfull then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded > 0 then
				bReturn = false;
			end
		elseif sLower == DataCommon.healthstatushalf then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded < .5 then
				bReturn = false;
			end
		elseif sLower == DataCommon.healthstatuswounded then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded == 0 then
				bReturn = false;
			end
		elseif StringManager.contains(DataCommon.conditions, sLower) then
			if not checkConditionalHelper(rActor, sLower, rTarget, aIgnore) then
				bReturn = false;
			end
		elseif StringManager.contains(DataCommon.conditionaltags, sLower) then
			if not checkConditionalHelper(rActor, sLower, rTarget, aIgnore) then
				bReturn = false;
			end
		else
			local sAlignCheck = sLower:match("^align%s*%(([^)]+)%)$");
			local sSizeCheck = sLower:match("^size%s*%(([^)]+)%)$");
			local sTypeCheck = sLower:match("^type%s*%(([^)]+)%)$");
			local sCustomCheck = sLower:match("^custom%s*%(([^)]+)%)$");
			if sAlignCheck then
				if not ActorManager2.isAlignment(rActor, sAlignCheck) then
					bReturn = false;
				end
			elseif sSizeCheck then
				if not ActorManager2.isSize(rActor, sSizeCheck) then
					bReturn = false;
				end
			elseif sTypeCheck then
				if not ActorManager2.isCreatureType(rActor, sTypeCheck) then
					bReturn = false;
				end
			elseif sCustomCheck then
				if not checkConditionalHelper(rActor, sCustomCheck, rTarget, aIgnore) then
					bReturn = false;
				end
			end
		end
	end
	
	table.remove(aIgnore);
	
	return bReturn;
end

function checkConditionalHelper(rActor, sEffect, rTarget, aIgnore)
	if not rActor then
		return false;
	end
	
	local bReturn = false;
	
	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		local nActive = DB.getValue(v, "isactive", 0);
		if nActive ~= 0 and not StringManager.contains(aIgnore, v.getNodeName()) then
			-- Parse each effect label
			local sLabel = DB.getValue(v, "label", "");
			local bTargeted = EffectManager.isTargetedEffect(v);
			local aEffectComps = EffectManager.parseEffect(sLabel);

			-- Iterate through each effect component looking for a type match
			local nMatch = 0;
			for kEffectComp, sEffectComp in ipairs(aEffectComps) do
				local rEffectComp = parseEffectComp(sEffectComp);
				--Check conditionals
				if rEffectComp.type == "IF" then
					if not checkConditional(rActor, v, rEffectComp.remainder, nil, aIgnore) then
						break;
					end
				elseif rEffectComp.type == "IFT" then
					if not rTarget then
						break;
					end
					if not checkConditional(rTarget, v, rEffectComp.remainder, rActor, aIgnore) then
						break;
					end
				
				-- Check for match
				elseif rEffectComp.original:lower() == sEffect then
					if bTargeted then
						if EffectManager.isEffectTarget(v, rTarget) then
							bReturn = true;
						end
					else
						bReturn = true;
					end
				end
			end
		end
	end
	
	return bReturn;
end

