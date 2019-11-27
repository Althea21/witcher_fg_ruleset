-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- OOB Message types for damage resolution
OOB_MSGTYPE_APPLYDMG = "applydmg";

function onInit()
	-- Register modifier handler
	--ActionsManager.registerModHandler("damage", onDamageModifier);
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("damage", onDamageRoll);
	ActionsManager.registerResultHandler("criticallocation", onCriticalLocationRoll);

	-- OOB Handlers
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMG, handleDamage);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor	: actor info retrieved by using ActorManager.resolveActor
--	* rAction	: rDamage object containing all needed info to resolve damage (range, type, label, clauses)
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rAction)
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "damage";
	-- the dice to roll.
	rRoll.aDice = {};
	-- A modifier to apply to the roll.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be completed later
	rRoll.sDesc = "["..Interface.getString("damage_roll_title");
	rRoll.sDesc = rRoll.sDesc.." "..Interface.getString("damage_for_label").." "..rAction.label;
	if rAction.range then
		rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range ..")";
		rRoll.range = rAction.range;
	end
	rRoll.sDesc = rRoll.sDesc.."]";

	-- other info needed later
	rRoll.sIsStrongAttack = "false";
	rRoll.sIsAimed = "false";
	rRoll.sLocation = "";
	rRoll.sCriticalLevel = "none";
	rRoll.sDamageType = "";

	-- Save the damage clauses in the roll structure
	rRoll.clauses = rAction.clauses;
	
	-- Add the dice and modifiers TODO : DON'T ADD SILVER DAMAGE IF TARGET NOT MONSTER
	for _,vClause in pairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(rRoll.aDice, vDie);
		end
		rRoll.nMod = rRoll.nMod + vClause.modifier;
		if vClause.dmgtype ~= "" then
			if rRoll.sDamageType ~= "" then 
				rRoll.sDamageType = rRoll.sDamageType .. ",";
			end
			rRoll.sDamageType = rRoll.sDamageType .. vClause.dmgtype;
		end
	end
	
	-- Encode the damage types
	encodeDamageTypes(rRoll);

	return rRoll;
end

-- method called to initiate damage roll
-- params :
--	* draginfo	: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rActor	: actor info retrieved by using ActorManager.resolveActor or previous call of CharManager.getWeaponDamageRollStructures
--	* rAction	: damage information given by previous call of CharManager.getWeaponDamageRollStructures
function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- HANDLERS --------------------------------------------------------

-- DEPRECATED Modifier handler : get the modifier relevant for damage
function onDamageModifier(rSource, rTarget, rRoll)
	Debug.console("--------------------------------------------");
	Debug.console("Compiling damage modifiers");
	
	-- Set up
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	local nMultBeforeArmor = 1;
	local nMultAfterArmor = 1;

	local aPendingAttackDmgMod = CombatManager2.getPendingAttackDamageModifier(rSource, rTarget);
	Debug.console("aPendingAttackDmgMod :");
	Debug.console(aPendingAttackDmgMod);

	-- STRONG ATTACK -----------------------
	local bStrongAttack = false;
	if aPendingAttackDmgMod and aPendingAttackDmgMod.sIsStrongAttack == "true" then
		-- strong attack from pending attack
		bStrongAttack = true;
	else
		-- check manual modifier
		if ModifierStack.getModifierKey("ATT_STRONG") then
			bStrongAttack = true;
		end
	end
	-- resolve strong attack consequences on damage
	if bStrongAttack then
		table.insert(aAddDesc, "["..Interface.getString("damage_label_strongattack").."]");
		rRoll.sIsStrongAttack = "true";
		rRoll.nMultBeforeArmor = 2;
	else
		rRoll.sIsStrongAttack = "false";
		rRoll.nMultBeforeArmor = 1;
	end
	Debug.console("- Strong Attack : "..rRoll.sIsStrongAttack);

	-- LOCATION -----------------------
	local sLocation = "";
	local sIsAimed = "false";
	-- location from pending attack
	if aPendingAttackDmgMod then
		sLocation = aPendingAttackDmgMod.sLocation;
		sIsAimed = aPendingAttackDmgMod.sIsAimed;
	else
		-- check manual modifier
		if ModifierStack.getModifierKey("AIM_HEAD") then
			sLocation = "AIM_HEAD";
		elseif ModifierStack.getModifierKey("AIM_TORSO") then
			sLocation = "AIM_TORSO";
		elseif ModifierStack.getModifierKey("AIM_TAIL") then
			sLocation = "AIM_TAIL";
		elseif ModifierStack.getModifierKey("AIM_ARM") then
			sLocation = "AIM_ARM";
		elseif ModifierStack.getModifierKey("AIM_LEG") then
			sLocation = "AIM_LEG";
		elseif ModifierStack.getModifierKey("AIM_LIMB") then
			sLocation = "AIM_LIMB";
		end
	end
	-- resolve location consequences on damage
	if sLocation ~= "" then
		local sLocDesc = "["..Interface.getString("damage_label_location_")..sLocation.." x";
		
		if sLocation=="head" then
			nMultAfterArmor = 3;
			sLocDesc = sLocDesc.."3";
		elseif sLocation=="torso" then
			nMultAfterArmor = 1;
			sLocDesc = sLocDesc.."1";
		elseif sLocation=="tail" or sLocation=="arm" or sLocation=="leg" or sLocation=="limb" then
			nMultAfterArmor = 0.5;
			sLocDesc = sLocDesc.."0.5";
		end
		sLocDesc = sLocDesc.." "..Interface.getString("damage_afterarmor_label").."]";
		table.insert(aAddDesc, sLocDesc);
	end
	rRoll.sLocation = sLocation;
	rRoll.sIsAimed = sIsAimed;
	Debug.console("- Location : "..rRoll.sLocation.." (aimed="..rRoll.sIsAimed..")");

	-- CRITICAL -----------------------
	local sCritical = "none";
	if aPendingAttackDmgMod then
		local successMargin = tonumber(aPendingAttackDmgMod.sSuccessMargin);
		if successMargin >= 15 then
			sCritical = "deadly";
		elseif successMargin >= 13 then
			sCritical = "difficult";
		elseif successMargin >= 10 then
			sCritical = "complex";
		elseif successMargin >= 7 then
			sCritical = "simple";
		end
	else
		-- check manual modifier
		if ModifierStack.getModifierKey("DMG_CRTSIM") then
			sCritical = "simple";
		elseif ModifierStack.getModifierKey("DMG_CRTDIF") then
			sCritical = "difficult";
		elseif ModifierStack.getModifierKey("DMG_CRTCOM") then
			sCritical = "complex";
		elseif ModifierStack.getModifierKey("DMG_CRTDEA") then
			sCritical = "deadly";
		end
	end
	-- resolve critical consequences on damage
	if sCritical ~= "" then
		local sCritDesc = "["..Interface.getString("damage_label_critical_"..sCritical).." +";

		if sCritical == "simple" then
			--nAddMod = nAddMod + 3;
			sCritDesc = sCritDesc.."3";
		elseif sCritical == "complex" then
			--nAddMod = nAddMod + 5; 
			sCritDesc = sCritDesc.."5";
		elseif sCritical == "difficult" then
			--nAddMod = nAddMod + 8; 
			sCritDesc = sCritDesc.."8";
		elseif sCritical == "deadly" then
			--nAddMod = nAddMod + 10; 
			sCritDesc = sCritDesc.."10";
		end

		sCritDesc = sCritDesc.."]";
		table.insert(aAddDesc, sCritDesc);
	end
	rRoll.sCriticalLevel = sCritical;
	Debug.console("- Critical level : "..rRoll.sCriticalLevel);
	
	-- WEAPON EFFECTS
	local sWeaponEffects = "";
	if aPendingAttackDmgMod then
		sWeaponEffects = aPendingAttackDmgMod.sWeaponEffects;
	end
	rRoll.sWeaponEffects = sWeaponEffects
	Debug.console("- Weapon effects : "..rRoll.sWeaponEffects);

	-- TARGET VULNERABILITIES
	local sTgtVulnerabilities = "";
	if aPendingAttackDmgMod then
		sTgtVulnerabilities = aPendingAttackDmgMod.sTgtVulnerabilities;
	end
	rRoll.sTgtVulnerabilities = sTgtVulnerabilities
	Debug.console("- Target vulnerabilities : "..rRoll.sTgtVulnerabilities);

	-- Add notes to roll description
	-- if #aAddDesc > 0 then
	-- 	rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	-- end

end

-- callback for ActionsManager, called after the dice have stopped rolling : resolve roll status and display chat message
function onDamageRoll(rSource, rTarget, rRoll)
	Debug.console("------- onDamageRoll");
	Debug.console(rRoll);

	-- Decode damage types
	decodeDamageTypes(rRoll, true);

	-- Encode the damage results for damage application and readability
	encodeDamageText(rRoll);

	local rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	local rMessage = ActionsManager.createActionMessage(rActor, rRoll);
	local nTotal = ActionsManager.total(rRoll);
	
	-- Send the chat message
	Comm.deliverChatMessage(rMessage);
	
	-- Apply damage to the PC or CT entry referenced
	--notifyApplyDamage(rSource, rTarget, rRoll.bTower, nTotal, rRoll);
	applyDamage(rSource, rTarget, rRoll.bTower, nTotal, rRoll);
end

------------------------------------------------------------------------------------
-- PROCESSING FUNCTIONS
------------------------------------------------------------------------------------
function applyDamage(rSource, rTarget, bSecret, nTotal, rRoll)
	Debug.console("--------------------------------------------");
	Debug.console("Apply Damage ");
	
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	
	local nFinalDamage = 0;
	local sFinalLocation = "";

	local aPendingAttackDmgMod = CombatManager2.getPendingAttackDamageModifier(rSource, rTarget);
	Debug.console("returned aPendingAttackDmgMod : ");
	Debug.console(aPendingAttackDmgMod);

	-- get rolled damage (= weapon + stat bonus + silver bonus if needed)
	nFinalDamage = nFinalDamage + tonumber(nTotal);
	Debug.console("rolled damage (= weapon + stat bonus + silver bonus if needed) : ", nFinalDamage);

	-- Decode damage description
	local rDamageOutput = decodeDamageText(nFinalDamage, rRoll.sDesc);

	-- SILVER ?
	local bIsSilverVulnerable = CharManager.isSilverVulnerable(nodeTarget);
	local bIsWeaponSilver = (rDamageOutput.aDamageTypes["silver"] ~= nil);
	if not bIsSilverVulnerable and bIsWeaponSilver then
		-- don't count silver damage
		nFinalDamage = nFinalDamage - rDamageOutput.aDamageTypes["silver"];
		Debug.console("target is NOT silver vulnerable but weapon is silver = don't count silver damage : ", nFinalDamage);
	end

	-- STRONG ATTACK ?
	if (aPendingAttackDmgMod and aPendingAttackDmgMod.sIsStrongAttack == "true") or (ModifierStack.getModifierKey("ATT_STRONG")) then
		-- check manual modifier
		nFinalDamage = nFinalDamage*2;
		Debug.console("after strong attack multiplier : ", nFinalDamage);
	else
		Debug.console("no strong attack multiplier : ", nFinalDamage);
	end

	-- LOCATION ?
	local sLocation = "";
	local sIsAimed = "false";
	-- location from pending attack
	if aPendingAttackDmgMod then
		sIsAimed = aPendingAttackDmgMod.sIsAimed;
		sLocation = aPendingAttackDmgMod.sLocation;
		if string.find(sLocation, "AIM_") then
			sLocation = string.lower(string.match(sLocation, "AIM_(%a+)"));
		end
	else
		-- check manual modifier
		if ModifierStack.getModifierKey("AIM_HEAD") then
			sLocation = "head";
			sIsAimed = "true";
		elseif ModifierStack.getModifierKey("AIM_TORSO") then
			sLocation = "torso";
			sIsAimed = "true";
		elseif ModifierStack.getModifierKey("AIM_TAIL") then
			sLocation = "tail";
			sIsAimed = "true";
		elseif ModifierStack.getModifierKey("AIM_ARM") then
			sLocation = "arm";
			sIsAimed = "true";
		elseif ModifierStack.getModifierKey("AIM_LEG") then
			sLocation = "leg";
			sIsAimed = "true";
		elseif ModifierStack.getModifierKey("AIM_LIMB") then
			sLocation = "limb";
			sIsAimed = "true";
		end
	end

	Debug.console("location : ", sLocation);

	-- CRITICAL ?
	-- must be done here because it may affect location
	local sCriticalLevel = "none";
	if aPendingAttackDmgMod then
		local successMargin = tonumber(aPendingAttackDmgMod.sSuccessMargin);
		if successMargin >= 15 then
			sCriticalLevel = "deadly";
		elseif successMargin >= 13 then
			sCriticalLevel = "difficult";
		elseif successMargin >= 10 then
			sCriticalLevel = "complex";
		elseif successMargin >= 7 then
			sCriticalLevel = "simple";
		end
	else
		-- check manual modifier
		if ModifierStack.getModifierKey("DMG_CRTSIM") then
			sCriticalLevel = "simple";
		elseif ModifierStack.getModifierKey("DMG_CRTDIF") then
			sCriticalLevel = "difficult";
		elseif ModifierStack.getModifierKey("DMG_CRTCOM") then
			sCriticalLevel = "complex";
		elseif ModifierStack.getModifierKey("DMG_CRTDEA") then
			sCriticalLevel = "deadly";
		end
	end
	
	local sSourceCT = ActorManager.getCTNodeName(rSource);
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	processCriticalDamageAndLocation(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, rRoll.sDesc, nFinalDamage);
	
end

function applyDamage2(sSourceCT, sTargetCT, sLocation, sDamageText, nCritDamage, nFinalDamage)
	Debug.console("--------------------------------------------");
	Debug.console("Apply Damage 2 : ");
	Debug.console("sSourceCT "..sSourceCT);
	Debug.console("sTargetCT "..sTargetCT);
	Debug.console("sLocation "..sLocation);
	Debug.console("sDamageText "..sDamageText);
	Debug.console("nFinalDamage "..nFinalDamage);

	local rTarget = ActorManager.getActor("ct", sTargetCT);
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	
	-- Decode damage description
	local rDamageOutput = decodeDamageText(nFinalDamage, sDamageText);
	
	-- ARMOR
	local nArmorValue = CharManager.getArmorValueForLocationRoll(nodeTarget, sLocation);
	Debug.console("armor sp of target for location : ", nArmorValue);
	nFinalDamage = nFinalDamage - nArmorValue;
	Debug.console("damage after armor : ", nFinalDamage);
	
	-- resistance (x0.5)
	-- TODO
	local bIsSilverVulnerable = CharManager.isSilverVulnerable(nodeTarget);
	local bIsWeaponSilver = (rDamageOutput.aDamageTypes["silver"] ~= nil);
	
	if bIsSilverVulnerable and not bIsWeaponSilver then
		-- target is silver vulnerable but weapon is not silver : half damage 
		nFinalDamage = math.floor(nFinalDamage/2);
		Debug.console("target is silver vulnerable but weapon is NOT silver : ", nFinalDamage);
	end

	-- vulnerability (x2)
	-- TODO

	-- location multiplier
	local nLocationMultiplier = CharManager.getDamageLocationModifierForLocationRoll(nodeTarget, sLocation);
	Debug.console("location multiplier : ", nLocationMultiplier);
	nFinalDamage = math.floor(nFinalDamage*nLocationMultiplier);
	Debug.console("damage after location : ", nFinalDamage);
	
	-- Output results
	messageDamage(rSource, rTarget, bSecret, "damage", sDamage, nCritDamage, nFinalDamage, "");

	-- update hit_point 
	notifyApplyDamage(sTargetCT, nFinalDamage + nCritDamage);

	CombatManager2.removePendingAttack(sSourceCT, sTargetCT);
end

function messageDamage(rSource, rTarget, bSecret, sDamageType, sDamageDesc, nExtraDamage, sTotal, sExtraResult)
	if not (rTarget or sExtraResult ~= "") then
		return;
	end
	
	local msgShort = {};
	local msgLong = {};

	if sDamageType == "Heal" or sDamageType == "Temporary hit points" then
		msgShort.icon = "roll_heal";
		msgLong.icon = "roll_heal";
	else
		msgShort.icon = "roll_damage";
		msgLong.icon = "roll_damage";
	end

	msgShort.text = sDamageType .. " ->";
	msgLong.text = sDamageType .. " [" .. sTotal 
	if nExtraDamage > 0 then
		msgLong.text = msgLong.text .. " + " .. nExtraDamage;	
	end
	msgLong.text = msgLong.text .. "] ->";
	
	if rTarget then
		msgShort.text = msgShort.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sExtraResult;
	end
	
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

------------------------------------------------------------------------------------
-- CRITICAL MANAGEMENT
------------------------------------------------------------------------------------
function processCriticalDamageAndLocation(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, nFinalDamage)
	local nExtraDamage = 0;
	if sCriticalLevel == "simple" then
		nExtraDamage = 3;
	elseif sCriticalLevel == "complex" then
		nExtraDamage = 5;
	elseif sCriticalLevel == "difficult" then
		nExtraDamage = 8;
	elseif sCriticalLevel == "deadly" then
		nExtraDamage = 10;
	end

	local rRoll = getCriticalLocationRoll(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, nExtraDamage, nFinalDamage);
	local rTarget = ActorManager.getActor("ct", sTargetCT);
	
	if sCriticalLevel == "none" then
		-- no critical, we must roll for simple location
		if sIsAimed == "true" then
			outputCriticalMessage(sSourceCT, sTargetCT, 0, sCriticalLevel, sLocation, sDamageText, nExtraDamage, nFinalDamage);
		else
			ActionsManager.performAction(nil, rTarget, rRoll);
		end
	else
		-- was the attack aimed ?
		if sIsAimed == "true" then
			if sLocation == "head" or sLocation == "torso" then
				-- head or torso roll 1D6
				ActionsManager.performAction(nil, rTarget, rRoll);
			elseif sLocation == "arm" then
				outputCriticalMessage(sSourceCT, sTargetCT, 4, sCriticalLevel, sLocation, sDamageText, nExtraDamage, nFinalDamage);
			elseif sLocation == "leg" or sLocation == "limb" or sLocation == "tail" then
				outputCriticalMessage(sSourceCT, sTargetCT, 2, sCriticalLevel, sLocation, sDamageText, nExtraDamage, nFinalDamage);
			else
				Debug.console("[processCriticalDamageAndLocation error ]Attack aimed with no location specified");
			end
		else
			-- roll 2D6
			ActionsManager.performAction(nil, rTarget, rRoll);
		end
	end

	return nExtraDamage;
end

function getCriticalLocationRoll(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, nExtraDamage, nFinalDamage)
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "criticallocation";
	-- the dice to roll.
	rRoll.aDice = {};
	if sCriticalLevel == "none" then
		rRoll.aDice = {"d10"};
	elseif sIsAimed == "true" then
		rRoll.aDice = {"d6"};
	elseif sIsAimed == "false" then
		rRoll.aDice = {"d6", "d6"};
	end
	-- A modifier to apply to the roll.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be completed later
	rRoll.sDesc = "";
	
	-- other info needed later
	rRoll.sSourceCT = sSourceCT;
	rRoll.sTargetCT = sTargetCT;
	rRoll.sCriticalLevel = sCriticalLevel;
	rRoll.sIsAimed = sIsAimed;
	rRoll.sLocation = sLocation;
	rRoll.sDamageText = sDamageText;
	rRoll.sExtraDamage = tostring(nExtraDamage);
	rRoll.sFinalDamage = tostring(nFinalDamage);
	
	return rRoll;
end

-- callback for ActionsManager, called after the dice have stopped rolling : resolve roll status and display chat message
-- rSource is the character receiving damage
function onCriticalLocationRoll(rSource, rTarget, rRoll)
	Debug.console("------- onCriticalLocationRoll");
	Debug.console(rRoll);

	local sSourceType, nodeSource = ActorManager.getTypeAndNode(rSource);
	local bIsMonster = CharManager.isMonster(nodeSource);

	local nResult = ActionsManager.total(rRoll);

	if rRoll.sCriticalLevel == "none" then
		-- basic autolocation
		if nResult == 1 then
			rRoll.sLocation = "head";
		elseif (nResult <= 4) or (nResult == 5 and bIsMonster) then
			rRoll.sLocation = "torso";
		elseif nResult == 5 then
			rRoll.sLocation = "rightarm";
		elseif nResult == 6 then
			-- human left arm or monster right limb
			if bIsMonster then
				rRoll.sLocation = "monsterrightlimb";
			else
				rRoll.sLocation = "leftarm";
			end
		elseif nResult == 7 then
			-- human right leg or monster right limb
			if bIsMonster then
				rRoll.sLocation = "monsterrightlimb";
			else
				rRoll.sLocation = "rightleg";
			end
		elseif nResult == 8 then
			-- human right leg or monster left limb
			if bIsMonster then
				rRoll.sLocation = "monsterleftlimb";
			else
				rRoll.sLocation = "rightleg";
			end
		elseif nResult == 9 then
			-- human left leg or monster left limb
			if bIsMonster then
				rRoll.sLocation = "monsterleftlimb";
			else
				rRoll.sLocation = "leftleg";
			end
		elseif nResult == 10 then
			-- human left leg or monster tail/wing
			if bIsMonster then
				rRoll.sLocation = "monstertail";
			else
				rRoll.sLocation = "leftleg";
			end
		end
	elseif rRoll.sIsAimed == "true" then
		-- only 1D6 rolled : 1-4 is lesser 5-6 is greater
		if nResult < 5 then
			if rRoll.sLocation == "head" then
				nResult = 11;
			elseif rRoll.sLocation == "torso" then
				nResult = 8;
			end
		else
			if rRoll.sLocation == "head" then
				nResult = 12;
			elseif rRoll.sLocation == "torso" then
				nResult = 10;
			end
		end
	else
		-- not aimed 2D6 rolled for critical location
		if nResult <= 3 then
			rRoll.sLocation = "leg";
		elseif nResult <= 5 then
			rRoll.sLocation = "arm";
		elseif nResult <= 10 then
			rRoll.sLocation = "torso";
		elseif nResult <= 12 then
			rRoll.sLocation = "head";
		end
	end

	outputCriticalMessage(rRoll.sSourceCT, rRoll.sTargetCT, nResult, rRoll.sCriticalLevel, rRoll.sLocation, rRoll.sDamageText, tonumber(rRoll.sExtraDamage), tonumber(rRoll.sFinalDamage));
end

function outputCriticalMessage(sSourceCT, sTargetCT, nResult, sCriticalLevel, sLocation, sDamageText, nExtraDamage, nFinalDamage)
	Debug.console("------- outputCriticalMessage");
	Debug.console("nResult = "..tostring(nResult));
	
	local rTarget = ActorManager.getActor("ct", sTargetCT);
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	local bIsMonster = CharManager.isMonster(nodeTarget);
	local bIsTargetWithoutAnatomy = CharManager.isWithoutAnatomy(nodeTarget);
	local sBonusDamage = 0;

	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.sender = "";
	
	if sCriticalLevel == "none" then
		rMessage.icon = "roll_effect";
		rMessage.text = "[" .. Interface.getString("modifier_label_location");
			if nResult > 0 then
				rMessage.text = rMessage.text.." ("..nResult..") ";
			else
				rMessage.text = rMessage.text.." ";
			end
		rMessage.text = rMessage.text .. Interface.getString("modifier_label_location_"..sLocation) .."]";
	else
		rMessage.icon = "roll_damage";
		rMessage.font = "msgfont";
		rMessage.text = "[".. Interface.getString("damage_label_critical_"..sCriticalLevel) .."]";
		rMessage.text = rMessage.text .. "[".. Interface.getString("damage_label_location_"..sLocation) .."]\n";
	
		local sLabelId = "critical_label_".. sCriticalLevel .. "_" .. sLocation;
		local sDescId = "critical_desc_".. sCriticalLevel .. "_" .. sLocation;
		
		if nResult == 12 or nResult == 10 or nResult == 9 then
			sLabelId = sLabelId .. "_greater";
			sDescId = sDescId .. "_greater";
		elseif nResult == 11 or nResult == 8 or nResult == 6 then
			sLabelId = sLabelId .. "_lesser";
			sDescId = sDescId .. "_lesser";
		end

		if bIsTargetWithoutAnatomy == "true" then
			if sLabelId == "critical_label_simple_torso_lesser" then
				sLabelId = "critical_label_without_anatomy";
				sDescId = "critical_desc_without_anatomy";
				sBonusDamage = 5;
			elseif sLabelId == "critical_label_complex_torso_greater" then
				sLabelId = "critical_label_without_anatomy";
				sDescId = "critical_desc_without_anatomy";
				sBonusDamage = 10;
			elseif sLabelId == "critical_label_difficult_torso_greater" or sLabelId == "critical_label_difficult_torso_lesser" then
				sLabelId = "critical_label_without_anatomy";
				sDescId = "critical_desc_without_anatomy";
				sBonusDamage = 15;
			elseif sLabelId == "critical_label_deadly_torso_lesser" then
				sLabelId = "critical_label_without_anatomy";
				sDescId = "critical_desc_without_anatomy";
				sBonusDamage = 20;
			end
		end
		sBonusDamage = sBonusDamage + nExtraDamage;
		
		rMessage.text = rMessage.text .. "[".. Interface.getString("damage_label_critical_extradamage") .. sBonusDamage .."]\n";

		rMessage.text = rMessage.text .. Interface.getString(sLabelId) .. " : " .. Interface.getString(sDescId);
	
		-- if sBonusDamage > 0 then
		-- 	rMessage.text = rMessage.text .. sBonusDamage;
			
		-- 	-- apply bonus damage
		-- 	local sType, node = ActorManager.getTypeAndNode(rSource);
		-- 	local nCurrentHP = DB.getValue(node, "attributs.hit_points", 0);
		-- 	DB.setValue(node, "attributs.hit_points", "number", nCurrentHP - sBonusDamage);
		-- end
	end
	
	-- Send the chat message
	Comm.deliverChatMessage(rMessage);

	-- Continue damage resolution
	applyDamage2(sSourceCT, sTargetCT, sLocation, sDamageText, sBonusDamage, nFinalDamage)
end

------------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
------------------------------------------------------------------------------------
-- Type format = [TYPE: typestring (diceformula) (statbonus)]
function encodeDamageTypes(rRoll)
	for _,vClause in ipairs(rRoll.clauses) do
		local sDice = StringManager.convertDiceToString(vClause.dice, vClause.modifier);
		rRoll.sDesc = rRoll.sDesc .. string.format(" [TYPE: %s (%s) (%s)]", vClause.dmgtype, sDice, vClause.stat or "");
	end
end

function decodeDamageTypes(rRoll, bFinal)
	-- Process each type clause in the damage description as encoded previously
	local nMainDieIndex = 0;
	rRoll.clauses = {};
	for sDmgType, sDmgDice, sDmgStat in string.gmatch(rRoll.sDesc, "%[TYPE: ([^(]*) %(([^)]*)%) %(([^)]*)%)%]") do
		local rClause = {};
		rClause.dmgtype = StringManager.trim(sDmgType);
		rClause.dice, rClause.modifier = StringManager.convertStringToDice(sDmgDice);
		rClause.stat = sDmgStat;
		rClause.nTotal = rClause.modifier;
		
		for _,vDie in ipairs(rClause.dice) do
			nMainDieIndex = nMainDieIndex + 1;
			rClause.nTotal = rClause.nTotal + (rRoll.aDice[nMainDieIndex].result or 0);
		end
		
		table.insert(rRoll.clauses, rClause);
	end
	
	-- Remove damage type information from roll description
	rRoll.sDesc = string.gsub(rRoll.sDesc, " %[TYPE:[^]]*%]", "");
	
	if bFinal then
		-- Capture any manual modifiers and adjust damage types accordingly
		-- NOTE: Positive values are added to first damage clause, Negative values reduce damage clauses until none remain
		local nFinalTotal = ActionsManager.total(rRoll);
		local nClausesTotal = 0;
		for _,vClause in ipairs(rRoll.clauses) do
			nClausesTotal = nClausesTotal + vClause.nTotal;
		end
		if nFinalTotal ~= nClausesTotal then
			local nRemainder = nFinalTotal - nClausesTotal;
			if nRemainder > 0 then
				if #(rRoll.clauses) == 0 then
					table.insert(rRoll.clauses, { dmgtype = "", stat = "", dice = {}, modifier = nRemainder, nTotal = nRemainder})
				else
					rRoll.clauses[1].modifier = rRoll.clauses[1].modifier + nRemainder;
					rRoll.clauses[1].nTotal = rRoll.clauses[1].nTotal + nRemainder;
				end
			else
				for _,vClause in ipairs(rRoll.clauses) do
					if vClause.nTotal >= -nRemainder then
						vClause.modifier = vClause.modifier + nRemainder;
						vClause.nTotal = vClause.nTotal + nRemainder;
						break;
					else
						vClause.modifier = vClause.modifier - vClause.nTotal;
						nRemainder = nRemainder + vClause.nTotal;
						vClause.nTotal = 0;
					end
				end
			end
		end
	end
end

function getDamageTypesFromString(sDamageTypes)
	local sLower = string.lower(sDamageTypes);
	local aSplit = StringManager.split(sLower, ",", true);
	
	local aDamageTypes = {};
	for k, v in ipairs(aSplit) do
		if StringManager.contains(DataCommon.dmgtypes, v) then
			table.insert(aDamageTypes, v);
		end
	end
	
	return aDamageTypes;
end

function getDamageStrings(clauses)
	local aOrderedTypes = {};
	local aDmgTypes = {};
	for _,vClause in ipairs(clauses) do
		local rDmgType = aDmgTypes[vClause.dmgtype];
		if not rDmgType then
			rDmgType = {};
			rDmgType.aDice = {};
			rDmgType.nMod = 0;
			rDmgType.nTotal = 0;
			rDmgType.sType = vClause.dmgtype;
			aDmgTypes[vClause.dmgtype] = rDmgType;
			table.insert(aOrderedTypes, rDmgType);
		end

		for _,vDie in ipairs(vClause.dice) do
			table.insert(rDmgType.aDice, vDie);
		end
		rDmgType.nMod = rDmgType.nMod + vClause.modifier;
		rDmgType.nTotal = rDmgType.nTotal + (vClause.nTotal or 0);
	end
	
	return aOrderedTypes;
end

function encodeDamageText(rRoll)
	local aDamage = getDamageStrings(rRoll.clauses);
	for _, rDamage in ipairs(aDamage) do
		local sDmgTypeOutput = rDamage.sType;
		if sDmgTypeOutput == "" then
			sDmgTypeOutput = "unknown";
		end
		
		if #rDamage.aDice == 0 then
			rRoll.sDesc = rRoll.sDesc .. string.format(" [TYPE: %s (%d)]", sDmgTypeOutput, rDamage.nTotal);
		else
			local sDice = StringManager.convertDiceToString(rDamage.aDice, rDamage.nMod);
			rRoll.sDesc = rRoll.sDesc .. string.format(" [TYPE: %s (%s=%d)]", sDmgTypeOutput, sDice, rDamage.nTotal);
		end
	end
end

function decodeDamageText(nDamage, sDamageDesc)
	local rDamageOutput = {};
	rDamageOutput.sOriginal = sDamageDesc;
	
	rDamageOutput.sType = "damage";
	rDamageOutput.sTypeOutput = "Damage";
	rDamageOutput.sVal = string.format("%01d", nDamage);
	rDamageOutput.nVal = nDamage;

	-- Determine damage energy types
	rDamageOutput.aDamageTypes = {};
	local nDamageRemaining = nDamage;
	for sDamageType in sDamageDesc:gmatch("%[TYPE: ([^%]]+)%]") do
		local sDmgType = StringManager.trim(sDamageType:match("^([^(%]]+)"));
		local sDice, sTotal = sDamageType:match("%(([%d%+%-Dd]+)%=(%d+)%)");
		if not sDice then
			sTotal = sDamageType:match("%((%d+)%)")
		end
		local nDmgTypeTotal = tonumber(sTotal) or nDamageRemaining;

		sDmgType = string.lower(sDmgType);

		if rDamageOutput.aDamageTypes[sDmgType] then
			rDamageOutput.aDamageTypes[sDmgType] = rDamageOutput.aDamageTypes[sDmgType] + nDmgTypeTotal;
		else
			rDamageOutput.aDamageTypes[sDmgType] = nDmgTypeTotal;
		end
		if not rDamageOutput.sFirstDamageType then
			rDamageOutput.sFirstDamageType = sDmgType;
		end

		nDamageRemaining = nDamageRemaining - nDmgTypeTotal;
	end
	if nDamageRemaining > 0 then
		rDamageOutput.aDamageTypes[""] = nDamageRemaining;
	elseif nDamageRemaining < 0 then
		ChatManager.SystemMessage("Total mismatch in damage type totals");
	end
	
	return rDamageOutput;
end

------------------------------------------------------------------------------------
-- OOB MESSAGES MANAGEMENT
------------------------------------------------------------------------------------

-- Notify damage / heal roll
function notifyApplyDamage(sTargetCT, nTotalDamage)
	Debug.console("--------------------------------------------");
	Debug.console("notifyApplyDamage - nTotalDamage : ");
	Debug.console(nTotalDamage);
	
	if sTargetCT == "" then
		Debug.console("notifyApplyDamage without legit rTarget : abort");
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	msgOOB.sTargetCT = sTargetCT;
	
	-- total damage rolled
	msgOOB.nTotal = nTotalDamage;

	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB damage / heal roll notification
function handleDamage(msgOOB)
	Debug.console("--------------------------------------------");
	Debug.console("Handle Damage - msgOOB : ");
	Debug.console(msgOOB);
	
	local rTarget = ActorManager.getActor("ct", msgOOB.sTargetCT);
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	local nCurrentHP = DB.getValue(nodeTarget, "attributs.hit_points", 0);
	DB.setValue(nodeTarget, "attributs.hit_points", "number", nCurrentHP - msgOOB.nTotal);
end

