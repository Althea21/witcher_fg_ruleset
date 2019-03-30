-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for attack rolls
--

-- Queue for tracking pending Attack for defense, then damage resolution (FIFO)
-- Each item must be formatted like :
--	* sSourceCT : offender (obtained by ActorManager.getCreatureNodeName(rSource) )
--	* sTargetCT : defender (obtained by ActorManager.getCTNodeName(rTarget) )
--	* nAtkValue : value of attack roll (total with modifier, reroll etc...)
--	* nDefValue : value of defense roll (total with modifier, reroll etc...)
-- Item must be cleared after damage resolution
aAttackQueue = {}

function onInit()
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["attack"] = { bUseModStack = true };
	
	-- Register modifier handler
	ActionsManager.registerModHandler("attack", onAttackModifier);
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("attack", onAttackRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rWeapon		: weapon node
--	* sAttackType	: attack type (supported : "fast", "strong", "normal"). 
--					  Unknown or missing value will be trated like a "normal" attack
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rWeapon, sAttackType)
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "attack";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded later
	rRoll.sDesc = "[Attack] ";
	
	-- Add parameters for exploding dice management
	rRoll.sExplodeMode  = "none";	-- initial roll, will be "fumble" or "crit" on reroll
	rRoll.nTotalExplodeValue = 0; 	-- cumulative value of exploding rolls
	rRoll.sStoredDice = "";			-- store all dice for final display message
	rRoll.sWeaponType = "" ; 		-- range, melee, unarmed (used for fumble resolution)
	
	-- Add parameter for damage location, may be modified by modifier (see OnAttackModifier) or by rolling location table
	rRoll.sDamageLocation = "";
	
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
		
		if sAttackType == "fast" then
			sRollDescription = "[Fast attack with "..rWeapon.label.."]";
		elseif sAttackType == "strong" then
			sRollDescription = "[Strong attack with "..rWeapon.label.."][Strong -3]"; -- changing this may affect onAttackModifier function below
			nRollMod = nRollMod - 3;
		else
			sRollDescription = "[Attack with "..rWeapon.label.."]";
		end
		
		-- stat modifier
		--Debug.chat("stat modifier ("..("attributs."..rWeapon.stat).."): "..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0));
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0);
		sRollDescription = sRollDescription.."["..rWeapon.stat.." +"..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0).."]"
		
		-- skill modifier
		for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
			if (DB.getValue(v, "name", "") == rWeapon.skill) then
				--Debug.chat("skill modifier ("..rWeapon.skill.."): "..DB.getValue(v, "skill_value", 0));
				nRollMod = nRollMod + DB.getValue(v, "skill_value", 0);
				sRollDescription = sRollDescription.."["..rWeapon.skill.." +"..DB.getValue(v, "skill_value", 0).."]"
				break;
			end
		end
		
		-- weapon accuracy modifier
		if (rWeapon.range ~= "U") then
			--Debug.chat("weapon accuracy modifier : "..rWeapon.weaponaccuracy);
			nRollMod = nRollMod + rWeapon.weaponaccuracy;
			sRollDescription = sRollDescription.."[WA +"..rWeapon.weaponaccuracy.."]"
		end
		
		-- TODO : ARMOR ENCUMBRANCE VALUE TO SUB
		
		rRoll.sDesc = sRollDescription;
		rRoll.nMod = nRollMod;
	end
	
	return rRoll;
end

-- method called to initiate attack roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rWeapon		: weapon node (actor node if unarmed attack)
--	* sAttackType	: attack type (supported : "fast", "strong", "normal", "punchfast", "punchstrong", "punchnormal", "kickfast", "kickstrong", "kicknormal"). 
--					  Unknown or missing value will be treated like a "normal" attack
function performRoll(draginfo, rWeapon, sAttackType)
	-- retreive attack info and actor node 
	local rActor; 
	
	if (string.find(sAttackType, "punch") or string.find(sAttackType, "kick")) then
		-- unarmed attack
		rActor = rWeapon;
		rWeapon = {};
		rWeapon.range = "U";
		if (string.find(sAttackType, "punch"))then
			rWeapon.label = Interface.getString("char_label_punchlabel");
		elseif (string.find(sAttackType, "kick"))then
			rWeapon.label = Interface.getString("char_label_kicklabel");
		end
		rWeapon.stat = "reflex";
		rWeapon.skill= "Brawling";
		
		sAttackType = string.gsub(sAttackType, "punch", "");
		sAttackType = string.gsub(sAttackType, "kick", "");
		
	else
		-- weapon attack
		rActor, rWeapon = CharManager.getWeaponAttackRollStructures(rWeapon);
	end
	
	-- get roll
	local rRoll = getRoll(rActor, rWeapon, sAttackType);
	
	-- roll it !
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onAttackRoll(rSource, rTarget, rRoll)
	-- Debug.chat("------- onAttackRoll");
	-- Debug.chat("--rSource : ");
	-- Debug.chat(rSource);
	-- Debug.chat("--rTarget : ");
	-- Debug.chat(rTarget);
	-- Debug.chat("--rRoll : ");
	-- Debug.chat(rRoll);
	
	-- Debug.chat(rRoll.aDice[1].result);
	
	local bDisplayFinalMessage = true;
	
	local rActor;
	if (rSource.sType=="pc") then
		rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	end
	
	-- Check for reroll
	local nDiceResult = rRoll.aDice[1].result;
	if (nDiceResult == 1) then
		-- Debug.chat("rolled a 1 => check case");
		if rRoll.sExplodeMode == "none" then
			-- roll 1 on first roll => fumble => reroll
			rRoll.sExplodeMode = "fumble";
			bDisplayFinalMessage = false;
			-- store dice for final message
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				--Debug.chat("rRoll.sStoredDice="..rRoll.sStoredDice);
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			rRoll.sStoredDice = Json.stringify(aStoredDiceTmp);
			-- reinit rRoll dice
			rRoll.aDice = { "d10" };
			-- reroll
			ActionsManager.performAction(nil, rActor, rRoll);
		else
			-- roll 1 on crit or fumble reroll
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
			-- restore dice for final display
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			-- Debug.chat(aStoredDiceTmp);
			rRoll.aDice = aStoredDiceTmp;
			bDisplayFinalMessage = true;
		end
	elseif (nDiceResult == 10) then
		-- Debug.chat("rolled a 10 => reroll");
		bDisplayFinalMessage = false;
		if rRoll.sExplodeMode == "none" then
			rRoll.sExplodeMode = "crit";
		end
		rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
		-- store dice for final message
		local aStoredDiceTmp = {};
		if rRoll.sStoredDice ~= "" then
			--Debug.chat("rRoll.sStoredDice="..rRoll.sStoredDice);
			aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
		end
		aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
		rRoll.sStoredDice = Json.stringify(aStoredDiceTmp);
		-- reinit rRoll dice
		rRoll.aDice = { "d10" };
		-- reroll
		ActionsManager.performAction(nil, rActor, rRoll);
	else
		-- Debug.chat("rolled between 2 and 9");
		if rRoll.sExplodeMode ~= "none" then
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
			-- restore dice for final display
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			-- Debug.chat(aStoredDiceTmp);
			rRoll.aDice = aStoredDiceTmp;
		end
		bDisplayFinalMessage = true;
	end
	
	if bDisplayFinalMessage then
		-- rearrange rRoll.aDice if needed (serialization seems to mess up array) and color exploding dice
		local bFumble = false;
		if rRoll.sExplodeMode ~= "none" then
			local aNewDices = {};
			for i = 1, #(rRoll.aDice) do
				local aDice = rRoll.aDice[i];
				for j=1,#(aDice) do
					local aNewDice = aDice[j];
					if tonumber(aNewDice.result)==10 then
						aNewDice.type="g10";
					end
					if i==1 and tonumber(aNewDice.result)==1 then
						bFumble = true;
						aNewDice.type="r10";
					elseif bFumble then
						aNewDice.result = 0-tonumber(aNewDice.result)
					end
					table.insert(aNewDices, aNewDice);
				end
			end
			rRoll.aDice = aNewDices;
		end
		
		-- Create the base message based of the source and the final rRoll record (includes dice results).
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		
		-- update rMessage in case of fumble
		if (bFumble) then
			rMessage.text = rMessage.text .. "\n[FUMBLE (".. rRoll.nTotalExplodeValue ..") : ";
			-- check nTotalExplodeValue and attack type to resolve fumble
			if (rRoll.nTotalExplodeValue <=5) then
				rMessage.text = rMessage.text .. Interface.getString("fumble_none");
			end
				
			if (rRoll.sWeaponType == "range") then
				if (rRoll.nTotalExplodeValue >= 6 and rRoll.nTotalExplodeValue <= 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_range_6to7");
				elseif (rRoll.nTotalExplodeValue >= 8 and rRoll.nTotalExplodeValue <= 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_range_8to9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_range_over9");
				end
			elseif (rRoll.sWeaponType == "melee") then
				if (rRoll.nTotalExplodeValue == 6) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_melee_6");
				elseif (rRoll.nTotalExplodeValue == 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_melee_7");
				elseif (rRoll.nTotalExplodeValue == 8) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_melee_8");
				elseif (rRoll.nTotalExplodeValue == 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_melee_9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_range_over9");
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
	end
end

-- Modifier handler : additional modifiers to apply to the roll
function onAttackModifier(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local nAddMod = 0;
	
	-- Check modifiers
	local bFastDraw = ModifierStack.getModifierKey("ATT_FSTDRAW");
	local bStrongAttack = ModifierStack.getModifierKey("ATT_STRONG");
	local bTargetSilhouetted = ModifierStack.getModifierKey("ATT_SILTGT");
	local bAmbush = ModifierStack.getModifierKey("ATT_AMB");
	local bTargetPinned = ModifierStack.getModifierKey("ATT_TGTPINNED");
	local bTargetActiveDodge = ModifierStack.getModifierKey("ATT_TGTACTDODGE");
	local bMovingTarget = ModifierStack.getModifierKey("ATT_MOVTGT");
	local bRicochetShot = ModifierStack.getModifierKey("ATT_RIC");
	local bLightLevelModifier = "daylight";
	if ModifierStack.getModifierKey("LGT_BRI") then
		bLightLevelModifier = "bright";
	elseif ModifierStack.getModifierKey("LGT_DIM") then
		bLightLevelModifier = "dim";
	elseif ModifierStack.getModifierKey("LGT_DRK") then
		bLightLevelModifier = "darkness";
	end
	
	-- Aiming modifier. If aiming, this info must be stored for later damage resolution.
	local sAimingModifier = "";
	if ModifierStack.getModifierKey("AIM_HEAD") then
		rRoll.sDamageLocation = "AIM_HEAD";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimhead").. " -6]");
		nAddMod = nAddMod - 6;
	elseif ModifierStack.getModifierKey("AIM_TORSO") then
		rRoll.sDamageLocation = "AIM_TORSO";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimtorso").. " -1]");
		nAddMod = nAddMod - 1;
	elseif ModifierStack.getModifierKey("AIM_TAIL") then
		rRoll.sDamageLocation = "AIM_TAIL";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimtail").. " -2]");
		nAddMod = nAddMod - 2;
	elseif ModifierStack.getModifierKey("AIM_ARM") then
		rRoll.sDamageLocation = "AIM_ARM";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimarm").. " -3]");
		nAddMod = nAddMod - 3;
	elseif ModifierStack.getModifierKey("AIM_LEG") then
		rRoll.sDamageLocation = "AIM_LEG";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimleg").. " -2]");
		nAddMod = nAddMod - 2;
	elseif ModifierStack.getModifierKey("AIM_LIMB") then
		rRoll.sDamageLocation = "AIM_LIMB";
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_aiming").." : "..Interface.getString("modifier_label_aimlimb").. " -3]");
		nAddMod = nAddMod - 3;
	end
	
	-- if needed check range modifiers
	local sRangeModifier = "";
	if (rRoll.sWeaponType == "range") then
		if ModifierStack.getModifierKey("RNG_PB") then
			sRangeModifier = "pointblank";
		elseif ModifierStack.getModifierKey("RNG_MED") then
			sRangeModifier = "medium";
		elseif ModifierStack.getModifierKey("DMG_LNG") then
			sRangeModifier = "long";
		elseif ModifierStack.getModifierKey("DMG_EXT") then
			sRangeModifier = "extreme";
		end
	end
	
	
	if bFastDraw then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_fstdraw").." -3]");
		nAddMod = nAddMod - 3;
	end
	if bStrongAttack then
		if not string.match(rRoll.sDesc, "%[Strong attack") then
			table.insert(aAddDesc, "["..Interface.getString("modifier_label_atkstrong").." -3]");
			nAddMod = nAddMod - 3;
		end
	end
	if bTargetSilhouetted then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_silhouettedtarget").." +2]");
		nAddMod = nAddMod + 2;
	end
	if bAmbush then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_ambush").." +5]");
		nAddMod = nAddMod + 5;
	end
	if bTargetPinned then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_targetpinned").." +4]");
		nAddMod = nAddMod + 4;
	end
	if bTargetActiveDodge then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_targetactdodge").." -2]");
		nAddMod = nAddMod - 2;
	end
	if bMovingTarget then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_movtarget").." -3]");
		nAddMod = nAddMod - 3;
	end
	if bRicochetShot then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_ricshot").." -5]");
		nAddMod = nAddMod - 5;
	end
	if bLightLevelModifier == "bright" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_bright").." -3]");
		nAddMod = nAddMod - 3;
	elseif bLightLevelModifier == "darkness" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_dark").." -2]");
		nAddMod = nAddMod - 2;
	end
	if sRangeModifier == "pointblank" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_range_pointblank").." +5]");
		nAddMod = nAddMod + 5;
	elseif sRangeModifier == "medium" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_range_medium").." -2]");
		nAddMod = nAddMod - 2;
	elseif sRangeModifier == "long" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_range_long").." -4]");
		nAddMod = nAddMod - 4;
	elseif sRangeModifier == "extreme" then
		table.insert(aAddDesc, "["..Interface.getString("modifier_label_range_extreme").." -6]");
		nAddMod = nAddMod - 6;
	end
	
	if rSource then
		-- TODO : Get condition modifiers
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	
	rRoll.nMod = rRoll.nMod + nAddMod;
end