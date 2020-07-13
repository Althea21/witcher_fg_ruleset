-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for defense rolls
--

function onInit()
	-- Register modifier handler
	ActionsManager.registerModHandler("defense", onDefenseModifier);
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("defense", onDefenseRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rWeapon		: weapon node
--	* sDefenseType	: defense type (supported : "block", "parry"). 
--					  Unknown or missing value will generate error chat message
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rWeapon, sDefenseType)
	--Debug.chat(rWeapon);
	
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "defense";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded later
	rRoll.sDesc = "[Defense] ";
	
	-- Add parameters for exploding dice management
	rRoll.sExplodeMode  = "none";	-- initial roll, will be "fumble" or "crit" on reroll
	rRoll.nTotalExplodeValue = 0; 	-- cumulative value of exploding rolls
	rRoll.sStoredDice = "";			-- store all dice for final display message
	rRoll.sWeaponType = "" ; 		-- range, melee, unarmed (used for fumble resolution)
	rRoll.sBlockedWithWeapon = "";	-- used after resolution for damaging weapon reliability
	
	-- Debug.chat(rWeapon);
	
	if (rWeapon.range == "R") then
		rRoll.sWeaponType = "range";
	elseif (rWeapon.range == "M") then
		rRoll.sWeaponType = "melee";
	else
		rRoll.sWeaponType = "unarmed";
	end
	
	-- Look up actor / weapon specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		local sRollDescription = "";
		local nRollMod = 0;
		
		if sDefenseType == "block" then
			sRollDescription = "[Block with "..rWeapon.label.."]";
			if rRoll.sWeaponType ~= "unarmed" then
				rRoll.sBlockedWithWeapon = rWeapon.sWeaponNodeId;
			end
		elseif sDefenseType == "parry" then
			sRollDescription = "[Parry with "..rWeapon.label.." (-3)]";
			nRollMod = nRollMod - 3;
		else
			local rMessage = {};
			rMessage.text = Interface.getString("defense_errormsg_unknowndefense")
			Comm.deliverChatMessage(rMessage);
		end
		
		-- stat modifier
		-- Debug.chat("stat modifier ("..("attributs."..rWeapon.stat).."): "..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0));
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0);
		--sRollDescription = sRollDescription.."["..rWeapon.stat.." +"..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0).."]"
		
		-- skill modifier
		if nodeActor.getParent().getName()=="charsheet" then
			-- PC case
			for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
				if (DB.getValue(v, "id", "") == rWeapon.skill) then
					--Debug.chat("skill modifier ("..rWeapon.skill.."): "..DB.getValue(v, "skill_value", 0));
					nRollMod = nRollMod + DB.getValue(v, "skill_value", 0);
					--sRollDescription = sRollDescription.."["..rWeapon.skill.." +"..DB.getValue(v, "skill_value", 0).."]"
					break;
				end
			end
			
		else
			-- NPC case
			nRollMod = nRollMod + CharManager.getNPCSkillValue(nodeActor, rWeapon.skill);
		end

		-- Substract equipped armor part EV
		local nTotalEV = CharManager.getTotalEV(nodeActor);
		if (nTotalEV > 0) then
			nRollMod = nRollMod - nTotalEV;
			--sRollDescription = sRollDescription.."["..Interface.getString("rolldescription_totalev").." -"..nTotalEV.."]"
		end
		
		rRoll.sDesc = sRollDescription;
		rRoll.nMod = nRollMod;
	end
	
	return rRoll;
end

-- method called to initiate defense roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rWeapon		: weapon node (actor node if unarmed defense)
--	* sDefenseType	: defense type (supported : "block", "parry", "punchblock", "kickblock"). 
--					  Unknown or missing value will generate error chat message
function performRoll(draginfo, rWeapon, sDefenseType)
	-- retreive attack info and actor node 
	local rActor;
	
	if (string.find(sDefenseType, "punch") or string.find(sDefenseType, "kick")) then
		-- unarmed defense
		rActor = rWeapon;
		rWeapon = {};
		rWeapon.range = "U";
		if (string.find(sDefenseType, "punch"))then
			rWeapon.label = Interface.getString("char_label_punchlabel");
		elseif (string.find(sDefenseType, "kick"))then
			rWeapon.label = Interface.getString("char_label_kicklabel");
		end
		rWeapon.stat = "reflex";
		rWeapon.skill= "brawling";
		
		sDefenseType = string.gsub(sDefenseType, "punch", "");
		sDefenseType = string.gsub(sDefenseType, "kick", "");
	else
		-- weapon attack
		rActor, rWeapon = CharManager.getWeaponDefenseRollStructures(rWeapon);
	end
	
	-- get roll
	local rRoll = getRoll(rActor, rWeapon, sDefenseType);
	
	-- roll it !
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- HANDLERS -----------------------------------------------------------------------------------

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onDefenseRoll(rSource, rTarget, rRoll)
	-- Debug.chat("------- onDefenseRoll");
	-- Debug.chat("--rSource : ");
	-- Debug.chat(rSource);
	-- Debug.chat("--rTarget : ");
	-- Debug.chat(rTarget);
	-- Debug.chat("--rRoll : ");
	-- Debug.chat(rRoll);
	
	-- Debug.chat(rRoll.aDice[1].result);
	
	local bDisplayFinalMessage = true;
	
	local rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	
	-- Check for reroll
	local nDiceResult = rRoll.aDice[1].result;
	if (nDiceResult == 1) then
		-- Debug.chat("rolled a 1 => check case");
		if rRoll.sExplodeMode == "none" then
			-- roll 1 on first roll => fumble => reroll
			rRoll.sExplodeMode = "fumble";
			-- store dice for final message
			_storeDieForFinalMessage(rRoll);
			-- reinit rRoll dice
			rRoll.aDice = { "d10" };
			-- reroll
			bDisplayFinalMessage = false;
			ActionsManager.performAction(nil, rActor, rRoll);
		else
			-- roll 1 on crit or fumble reroll
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
			-- store dice for final message
			_storeDieForFinalMessage(rRoll);
			bDisplayFinalMessage = true;
		end
	elseif (nDiceResult == 10) then
		-- Debug.chat("rolled a 10 => reroll");
		-- rolled a 10, reroll in any case
		rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
		
		if rRoll.sExplodeMode == "none" then
			rRoll.sExplodeMode = "crit";
		end
		
		-- store dice for final message
		_storeDieForFinalMessage(rRoll);
		
		-- reinit rRoll dice
		rRoll.aDice = { "d10" };
		
		-- reroll
		bDisplayFinalMessage = false;
		ActionsManager.performAction(nil, rActor, rRoll);
	else
		-- Debug.chat("rolled between 2 and 9");
		-- store dice for final message
		_storeDieForFinalMessage(rRoll);
		if rRoll.sExplodeMode ~= "none" then
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
		end
		bDisplayFinalMessage = true;
	end
	
	if bDisplayFinalMessage then
		local bFumble = _restoreDiceBeforeFinalMessage(rRoll);
		
		-- Create the base message based of the source and the final rRoll record (includes dice results).
		local rMessage = ActionsManager.createActionMessage(rActor, rRoll);
		
		-- update rMessage in case of fumble
		if (bFumble) then
			rMessage.text = rMessage.text .. "\n[FUMBLE (".. rRoll.nTotalExplodeValue ..") : ";
			-- check nTotalExplodeValue and attack type to resolve fumble
			if (rRoll.nTotalExplodeValue <=5) then
				rMessage.text = rMessage.text .. Interface.getString("fumble_none");
			end
				
			if (rRoll.sWeaponType == "melee") then
				if (rRoll.nTotalExplodeValue == 6) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_6");
				elseif (rRoll.nTotalExplodeValue == 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_7");
				elseif (rRoll.nTotalExplodeValue == 8) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_8");
				elseif (rRoll.nTotalExplodeValue == 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_over9");
				end
			elseif (rRoll.sWeaponType == "unarmed") then
				if (rRoll.nTotalExplodeValue == 6) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_6");
				elseif (rRoll.nTotalExplodeValue == 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_7");
				elseif (rRoll.nTotalExplodeValue == 8) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_8");
				elseif (rRoll.nTotalExplodeValue == 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_over9");
				end
			end

			rMessage.text = rMessage.text .. "]";
		end
		
		-- Debug.chat(rMessage);
		
		-- Display the message in chat.
		Comm.deliverChatMessage(rMessage);

		---- Resolve Defense
		local nDefValue = ActionsManager.total(rRoll);
		if nDefValue < 0 then
			nDefValue = 0;
		end
		CombatManager2.resolvePendingAttack(rSource, nDefValue, rRoll.sBlockedWithWeapon);
	end
end

-- Modifier handler : additional modifiers to apply to the roll
function onDefenseModifier(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local nAddMod = 0;
	
	-- Check modifiers
	local bLightLevelModifier = "daylight";
	if ModifierStack.getModifierKey("LGT_BRI") then
		bLightLevelModifier = "bright";
	elseif ModifierStack.getModifierKey("LGT_DIM") then
		bLightLevelModifier = "dim";
	elseif ModifierStack.getModifierKey("LGT_DRK") then
		bLightLevelModifier = "darkness";
	end
	
	if bLightLevelModifier == "bright" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_bright").." -3]");
		nAddMod = nAddMod - 3;
	elseif bLightLevelModifier == "darkness" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_dark").." -2]");
		nAddMod = nAddMod - 2;
	end
	
	if rSource then
		-- TODO : Get condition modifiers
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	
	rRoll.nMod = rRoll.nMod + nAddMod;
end

-- PRIVATE ------------------------------------------------------------------------------------
-- store aDice in sStoredDice for final message
-- params :
--	* rRoll : roll to work on
function _storeDieForFinalMessage(rRoll)
	-- Debug.chat("--------------------- _storeDieForFinalMessage");
	-- Debug.chat(rRoll.sStoredDice);
	-- Debug.chat(rRoll.aDice);
	
	local aStoredDiceTmp = {};
	
	-- get previously stored dice if any
	if rRoll.sStoredDice ~= "" then
		aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
	end
	
	-- store last die rolled
	table.insert(aStoredDiceTmp, rRoll.aDice);
	
	-- store for later
	rRoll.sStoredDice = Json.stringify(aStoredDiceTmp);
	
	-- Debug.chat("after :");
	-- Debug.chat(rRoll.sStoredDice);
end

-- restore sStoredDice in aDice before final message 
-- params :
--	* rRoll : roll to work on
-- returns : 
--	* bFumble : true if roll was a fumble false if not
function _restoreDiceBeforeFinalMessage(rRoll)
	-- Debug.chat("--------------------- _restoreDiceBeforeFinalMessage");
	-- Debug.chat(rRoll.sStoredDice);
	-- Debug.chat(rRoll.aDice);
	
	local bFumble = false;
	
	-- get previously stored dice
	local aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
	
	-- restore in aDice;
	rRoll.aDice = aStoredDiceTmp;
	
	-- rearrange rRoll.aDice if needed (has reroll or location roll) as serialization seems to mess up array
	-- and color exploding dice
	
	local aNewDice = {};
	
	for i, k in pairs (rRoll.aDice) do -- FGU compatibility : change loops "for i=1, # ..." in "for i,k in pairs ..."
		local aDiceTmp = rRoll.aDice[i];
		for j,l in pairs (aDiceTmp) do -- FGU compatibility : change loops "for j=1, # ..." in "for j,l in pairs ..."
			local aDieTmp = aDiceTmp[j];
			
			if j ~= "expr" then -- FGU compatibility : don't propagate "expr" in aDice array
				-- 10 is always rerolled => set it green
				if tonumber(aDieTmp.result)==10 then
					aDieTmp.type="g10";
				end
				
				if i==1 and tonumber(aDieTmp.result)==1 then
					-- first die was a 1 => fumble, set ir red
					bFumble = true;
					aDieTmp.type="r10";
				elseif bFumble then
					-- any result between 1 and 9 => get die as it is
					aDieTmp.result = 0-tonumber(aDieTmp.result)
				end

				table.insert(aNewDice, aDieTmp);
			end
		end
	end

	rRoll.aDice = aNewDice;

	-- Debug.chat("after :");
	-- Debug.chat(rRoll.aDice);
	
	return bFumble;
end