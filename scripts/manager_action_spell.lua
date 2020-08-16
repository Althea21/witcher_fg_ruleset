-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for spell casting rolls
--

function onInit()
	-- Register modifier handler
	--ActionsManager.registerModHandler("spellcast", onSpellCastModifier);
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("spellcast", onSpellCastRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rSpell		: spell node
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rSpell)
	-- Debug.chat(rActor);
	-- Debug.chat(rSpell);
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "spellcast";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded later
	rRoll.sDesc = "[Spell casting] ";
	
	-- Add parameters for exploding dice management
	rRoll.sExplodeMode  = "none";	-- initial roll, will be "fumble" or "crit" on reroll
	rRoll.nTotalExplodeValue = 0; 	-- cumulative value of exploding rolls
	rRoll.sStoredDice = "";			-- store all dice for final display message
	rRoll.sSpellType = "" ; 		-- mage, priest, sign, hex, ritual
	
	-- NO LOCATION FOR TIME BEING, TODO
	-- Add parameters for damage location, may be modified by modifier (see OnAttackModifier) or by rolling location table
	-- rRoll.sDamageLocation = "";
	rRoll.sIsLocationRoll = "false";
	
	-- Debug.chat(rSpell);
	local parentNode = rSpell.getParent().getParent();
	if parentNode then
		local nSpellType = DB.getValue(parentNode, "type", -1);
		if (nSpellType == 0) then
			-- mage spell
			rRoll.sSpellType = "mage" ;
		elseif (nSpellType == 1) then
			-- hexes spell class
			rRoll.sSpellType = "hex" ;
		elseif (nSpellType == 2) then
			-- ritual spell class
			rRoll.sSpellType = "ritual" ;
		elseif (nSpellType == 3) then
			-- priest spell class
			rRoll.sSpellType = "priest" ;
		elseif (nSpellType == 4) then
			-- signs spell class
			rRoll.sSpellType = "sign" ;
		end
	end

	-- Look up actor / spell specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		local sRollDescription = "";
		local nRollMod = 0;
		
		sRollDescription = "[Cast "..DB.getValue(rSpell, "name", "").." (STA cost="..DB.getValue(rSpell, "stacost", "not found")..")]";

		-- stat modifier
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs.will", 0);
		
		-- skill modifier
		local sSkill = "";
		if rRoll.sSpellType == "mage" or rRoll.sSpellType == "priest" or rRoll.sSpellType == "sign" then
			sSkill = "spellCasting";
		elseif rRoll.sSpellType == "hex" then
			sSkill = "hexWeaving";
		elseif rRoll.sSpellType == "ritual" then
			sSkill = "ritualCrafting";
		end
		
		if nodeActor.getParent().getName()=="charsheet" then
			-- PC case
			for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
				if (DB.getValue(v, "id", "") == sSkill) then
					nRollMod = nRollMod + DB.getValue(v, "skill_value", 0);
					--sRollDescription = sRollDescription.."["..sSkill.." +"..DB.getValue(v, "skill_value", 0).."]"
					break;
				end
			end
		else
			-- NPC case
			nRollMod = nRollMod + CharManager.getNPCSkillValue(nodeActor, sSkill);
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
	
	-- update caster stats
	rRoll.sDesc = rRoll.sDesc .. _impactSpellCaster(nodeActor, rSpell);

	-- check effect and condition affecting Stat and skill
	local nCondMod, nCondDesc = CharManager.getConditionRollModifier(nodeActor, rWeapon.skill, rWeapon.stat, false);
	rRoll.sDesc = rRoll.sDesc .. nCondDesc;
	rRoll.nMod = rRoll.nMod + nCondMod;

	return rRoll;
end

-- method called to initiate attack roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rSpell		: spell node
function performRoll(draginfo, rSpell)
	-- retreive actor node 
	local nodeChar = rSpell.getChild(".....");
	local rActor = ActorManager.getActor("pc", nodeChar);
	
	-- first check if caster has enough Stamina
	local nCurrentSTA = tonumber(DB.getValue(nodeChar, "attributs.stamina", 0));
	local nSTACost = tonumber(DB.getValue(rSpell, "stacost", 0));
	if nSTACost > nCurrentSTA then
		local msg = ChatManager.createBaseMessage(rActor, nil);
		msg.text = Interface.getString("spellcasting_notenoughSTA");
		Comm.deliverChatMessage(msg);
	else
		-- STA cost for casting sign is 7 max
		if nSTACost > 7 then
			local parentNode = rSpell.getParent().getParent();
			if parentNode then
				local nSpellType = DB.getValue(parentNode, "type", -1);
				if (nSpellType == 4) then -- sign
					local msg = ChatManager.createBaseMessage(rActor, nil);
					msg.text = Interface.getString("spellcasting_signSTAmax");
					Comm.deliverChatMessage(msg);
					return;
				end
			end
		end
		-- get roll
		local rRoll = getRoll(rActor, rSpell);
			
		-- roll it !
		ActionsManager.performAction(draginfo, rActor, rRoll);
	end
end

-- HANDLERS --------------------------------------------------------

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onSpellCastRoll(rSource, rTarget, rRoll)
	-- Debug.chat("------- onSpellCastRoll");
	-- Debug.chat("--rSource : ");
	-- Debug.chat(rSource);
	-- Debug.chat("--rTarget : ");
	-- Debug.chat(rTarget);
	-- Debug.chat("--rRoll : ");
	-- Debug.chat(rRoll);
	
	-- Debug.chat(rRoll.aDice[1].result);
	
	local bDisplayFinalMessage = true;
	
	local rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	
	if (rRoll.sIsLocationRoll == "false") then
		-- Check for reroll
		local nDiceResult = tonumber(rRoll.aDice[1].result);
		if (nDiceResult == 1) then
			-- Debug.chat("rolled a 1 => check case");
			if rRoll.sExplodeMode == "none" then
				-- roll 1 on first roll => fumble => reroll
				rRoll.sExplodeMode = "fumble";
				_storeDieForFinalMessage(rRoll);
				-- reinit rRoll dice
				rRoll.aDice = { "d10" };
				-- reroll
				bDisplayFinalMessage = false;
				ActionsManager.performAction(nil, rActor, rRoll);
			else
				-- roll 1 on crit or fumble reroll
				_storeDieForFinalMessage(rRoll);
				rRoll.nTotalExplodeValue = tonumber(rRoll.nTotalExplodeValue) + tonumber(nDiceResult);
				bDisplayFinalMessage = true;
			end
		elseif (nDiceResult == 10) then
			-- Debug.chat("rolled a 10 => reroll");
			-- rolled a 10, reroll in any case
			if rRoll.sExplodeMode == "none" then
				rRoll.sExplodeMode = "crit";
			end
			rRoll.nTotalExplodeValue = tonumber(rRoll.nTotalExplodeValue) + nDiceResult;
			_storeDieForFinalMessage(rRoll);
			-- reinit rRoll dice
			rRoll.aDice = { "d10" };
			-- reroll
			bDisplayFinalMessage = false;
			ActionsManager.performAction(nil, rActor, rRoll);
		else
			-- Debug.chat("rolled between 2 and 9");
			_storeDieForFinalMessage(rRoll);
			if rRoll.sExplodeMode ~= "none" then
				rRoll.nTotalExplodeValue = tonumber(rRoll.nTotalExplodeValue) + tonumber(nDiceResult);
			end
			bDisplayFinalMessage = true;
		end
	else
		-- this roll was for location, this die is not to be stored as the others for main final result
		rRoll.sDamageLocation = tostring(rRoll.aDice[1].result);
		bDisplayFinalMessage = true;
	end
	
	-- NO LOCATION FOR TIME BEING, SEE LATER
	-- if no more reroll AND not aiming, roll for location
	-- if (bDisplayFinalMessage and rRoll.sDamageLocation == "") then
	-- 	rRoll.sIsLocationRoll = "true";
	-- 	-- reinit rRoll dice
	-- 	rRoll.aDice = { "d10" };
	-- 	-- roll for location
	-- 	bDisplayFinalMessage = false;
	-- 	ActionsManager.performAction(nil, rActor, rRoll);
	-- end
	
	if bDisplayFinalMessage then
		local bFumble = _restoreDiceBeforeFinalMessage(rRoll);
		
		-- Create the base message based of the source and the final rRoll record (includes dice results).
		local rMessage = ActionsManager.createActionMessage(rActor, rRoll);
		
		-- NO LOCATION FOR TIME BEING, SEE LATER
		-- update message for auto location
		-- local locMessage = "";
		-- if rRoll.sDamageLocation == "1" then
		-- 	-- head
		-- 	locMessage = Interface.getString("modifier_label_aimhead");
		-- elseif rRoll.sDamageLocation == "2" or rRoll.sDamageLocation == "3" or rRoll.sDamageLocation == "4" then
		-- 	-- torso
		-- 	locMessage = Interface.getString("modifier_label_aimtorso");
		-- elseif rRoll.sDamageLocation == "5" then
		-- 	-- human right arm or monster torso
		-- 	locMessage = Interface.getString("modifier_label_location_rightarm").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monstertorso");
		-- elseif rRoll.sDamageLocation == "6" then
		-- 	-- human left arm or monster right limb
		-- 	locMessage = Interface.getString("modifier_label_location_leftarm").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monsterrightlimb");
		-- elseif rRoll.sDamageLocation == "7" then
		-- 	-- human right leg or monster right limb
		-- 	locMessage = Interface.getString("modifier_label_location_rightleg").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monsterrightlimb");
		-- elseif rRoll.sDamageLocation == "8" then
		-- 	-- human right leg or monster left limb
		-- 	locMessage = Interface.getString("modifier_label_location_rightleg").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monsterleftlimb");
		-- elseif rRoll.sDamageLocation == "9" then
		-- 	-- human left leg or monster left limb
		-- 	locMessage = Interface.getString("modifier_label_location_leftleg").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monsterleftlimb");
		-- elseif rRoll.sDamageLocation == "10" then
		-- 	-- human left leg or monster tail/wing
		-- 	locMessage = Interface.getString("modifier_label_location_leftleg").." "..Interface.getString("modifier_label_location_or").." "..Interface.getString("modifier_label_location_monstertail");
		-- end
		-- if locMessage ~= "" then
		-- 	rMessage.text = rMessage.text .. "\n["..Interface.getString("modifier_label_location").." ("..rRoll.sDamageLocation..") "..locMessage.."]";
		-- end
		
		-- update rMessage in case of fumble
		if (bFumble) then
			rMessage.text = rMessage.text .. _buildFumbleMessage(rRoll.sSpellType, rRoll.nTotalExplodeValue);
		end
		
		-- Debug.chat(rMessage);
		
		-- Display the message in chat.
		Comm.deliverChatMessage(rMessage);
	end
end

-- Modifier handler : additional modifiers to apply to the roll
function onSpellCastModifier(rSource, rTarget, rRoll)
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


-- PRIVATE METHODS --------------------------------------------------------

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

-- build fumble message 
-- params :
--	* sSpellType			: mage, priest, sign, hex or ritual
--	* nTotalExplodeValue	: fumble amount
-- returns : 
--	* sMessage : fumble message
function _buildFumbleMessage(sSpellType, nTotalExplodeValue)
	local nFumbleValue = tonumber(nTotalExplodeValue);
	local sMessage = "\n[FUMBLE (".. nTotalExplodeValue ..") : ";
	-- check nTotalExplodeValue and spell type to resolve fumble
	if sSpellType == "mage" or sSpellType == "priest" or sSpellType == "sign" then
		if nFumbleValue <= 6 then
			sMessage = sMessage .. Interface.getString("fumble_magic_6");
		elseif nFumbleValue <= 9 then
			sMessage = sMessage .. Interface.getString("fumble_magic_9");
		else
			sMessage = sMessage .. Interface.getString("fumble_magic_over9");
		end
	elseif sSpellType == "hex" then
		sMessage = sMessage .. Interface.getString("fumble_hex");
	elseif sSpellType == "ritual" then
		sMessage = sMessage .. Interface.getString("fumble_ritual");
	end

	sMessage = sMessage .. "]";

	return sMessage;
end

-- Stamina, Overexertion management 
-- params :
--	* nodeActor : actor node
--	* nodeSpell : spell node
function _impactSpellCaster(nodeActor, nodeSpell)
	local sMessage = "";
	local nSTACost = tonumber(DB.getValue(nodeSpell, "stacost", 0));
	
	if nSTACost > 0 then
		-- STA cost
		local nCurrentSTA = tonumber(DB.getValue(nodeActor, "attributs.stamina", 0));
		if nCurrentSTA > 0 then
			DB.setValue(nodeActor, "attributs.stamina", "number", nCurrentSTA-nSTACost);
		end

		-- Check for overexertion
		local nCurrentVIG = tonumber(DB.getValue(nodeActor, "attributs.vigor", 0));
		local nCurrentFOC = tonumber(DB.getValue(nodeActor, "attributs.focus", 0));
		local nExcess = (nSTACost - nCurrentFOC) - nCurrentVIG;
		if nExcess > 0 then
			local nCurrentHP = tonumber(DB.getValue(nodeActor, "attributs.hit_points", 0));
			DB.setValue(nodeActor, "attributs.hit_points", "number", nCurrentHP-(nExcess*5));
			sMessage = sMessage .. string.format(Interface.getString("spellcasting_overexertion"), nExcess*5);
		end
	end
	return sMessage;
end