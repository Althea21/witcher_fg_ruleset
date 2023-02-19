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
	
	-- Store weapon effects
	rRoll.sEffects = rAction.sEffects;

	-- Save the damage clauses in the roll structure
	rRoll.clauses = rAction.clauses;
	
	-- Add the dice and modifiers
	for _,vClause in pairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			if string.find(string.lower(vClause.dmgtype), "silver") and vDie== "d6" then
				table.insert(rRoll.aDice, "s6");
			else
				table.insert(rRoll.aDice, vDie);
			end
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

-- callback for ActionsManager, called after the dice have stopped rolling : resolve roll status and display chat message
function onDamageRoll(rSource, rTarget, rRoll)
	-- Debug.console("------- onDamageRoll");
	-- Debug.console(rTarget);
	-- Debug.console(rRoll);

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
	if rTarget then
		applyDamage(rSource, rTarget, rRoll.bTower, nTotal, rRoll);
	end
end

------------------------------------------------------------------------------------
-- PROCESSING FUNCTIONS
------------------------------------------------------------------------------------
function applyConditionDamage(rTarget, sCondition)
	local nDamage = 0;
	local sMessage = "";
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	local sDamageType = "";

	-- check condition to compute damage
	if sCondition == "fire" then
		-- 5 points of damage to every body location. Armor soaks the damage, but fire does 1 point of damage to armor and weapons every turn.
		sDamageType = "fire";
		sMessage = Interface.getString("effect_damagemessage_fire");

		-- check armor
		local headArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "head");
		local leftarmArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "leftarm");
		local rightarmArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "rightarm");
		local leftlegArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "leftleg");
		local rightlegArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "rightleg");
		local torsoArmor = CharManager.getArmorValueForLocationRoll(nodeTarget, "torso");
		
		if (headArmor < 5) then
			nDamage = nDamage + 5 - headArmor;
		end
		if (leftarmArmor < 5) then
			nDamage = nDamage + 5 - leftarmArmor;
		end
		if (rightarmArmor < 5) then
			nDamage = nDamage + 5 - rightarmArmor;
		end
		if (leftlegArmor < 5) then
			nDamage = nDamage + 5 - leftlegArmor;
		end
		if (rightlegArmor < 5) then
			nDamage = nDamage + 5 - rightlegArmor;
		end
		if (torsoArmor < 5) then
			nDamage = nDamage + 5 - torsoArmor;
		end

		-- equipement damage
		CharManager.damageArmorByLocation(nodeTarget, "head");
		CharManager.damageArmorByLocation(nodeTarget, "leftarm");
		CharManager.damageArmorByLocation(nodeTarget, "rightarm");
		CharManager.damageArmorByLocation(nodeTarget, "leftleg");
		CharManager.damageArmorByLocation(nodeTarget, "rightleg");
		CharManager.damageArmorByLocation(nodeTarget, "torso");

	elseif sCondition == "poisonned" then
		-- 3 points of damage every turn which armor does not negate.
		sDamageType = "poison";
		sMessage = Interface.getString("effect_damagemessage_poisonned");
		nDamage = 3;
	elseif sCondition == "bleeding" then
		-- 2 points of damage each turn until the bleeding is stopped.
		sDamageType = "bleed";
		sMessage = Interface.getString("effect_damagemessage_bleeding");
		nDamage = 2;
	elseif sCondition == "suffocating" then
		-- 3 damage which armor does not negate.
		sMessage = Interface.getString("effect_damagemessage_suffocating");
		nDamage = 3;
	end

	-- check vulnerabilities, resistances
	if sDamageType ~= "" and CharManager.isResistantTo(nodeTarget, sTargetType, sDamageType, "all") then
		sMessage = sMessage .. " (" .. nDamage .. ") / 2 {resistance}";
		nDamage = math.floor(nDamage/2);
		-- Debug.console("target is resistant, damage after resistance : ", nDamage);
	elseif sDamageType ~= "" and CharManager.isVulnerableTo(nodeTarget, sTargetType, sDamageType) then
		sMessage = sMessage .. " (" .. nDamage .. ") x 2 {vulnerable}";
		nDamage = nDamage * 2;
		-- Debug.console("target is vulnerable, damage after bVulnerability : ", nDamage);
	elseif sDamageType == "fire" then
		sMessage = sMessage .. " (" .. nDamage .. ")";
	end

	-- effective apply damage 
	local nCurrentHP = DB.getValue(nodeTarget, "attributs.hit_points", 0);
	DB.setValue(nodeTarget, "attributs.hit_points", "number", nCurrentHP - nDamage);

	-- construct message
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.sender = "";
	rMessage.icon = "roll_damage";
	rMessage.font = "msgfont";
	rMessage.text = sMessage;

	-- Send the chat message
	Comm.deliverChatMessage(rMessage);
end

function applyDamage(rSource, rTarget, bSecret, nTotal, rRoll)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("Apply Damage ");
	
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	
	local nFinalDamage = 0;
	local sFinalLocation = "";
	local sFinalDamageMessage = "";

	local aPendingAttackDmgMod, bValidDmgModifier = CombatManager2.getPendingAttackDamageModifier(rSource, rTarget);
	-- Debug.console("returned aPendingAttackDmgMod : ");
	-- Debug.console(aPendingAttackDmgMod);
	-- Debug.console(bValidDmgModifier);
	if aPendingAttackDmgMod == nil and not bValidDmgModifier then
		return;
	end
	

	-- get rolled damage (= weapon + stat bonus + silver bonus if needed)
	nFinalDamage = nFinalDamage + tonumber(nTotal);
	-- Debug.console("rolled damage (= weapon + stat bonus + silver bonus if needed) : ", nFinalDamage);

	-- Decode damage description
	local rDamageOutput = decodeDamageText(nFinalDamage, rRoll.sDesc);
	-- SILVER ?
	local bIsSilverVulnerable = CharManager.isSilverVulnerable(nodeTarget);
	local nSilverDamage = 0;
	for k,v in pairs(rDamageOutput.aDamageTypes) do
		if string.find(string.lower(k), "silver") then
			nSilverDamage = nSilverDamage + v;
		end
	end
	if not bIsSilverVulnerable and nSilverDamage > 0 then
		-- don't count silver damage
		nFinalDamage = nFinalDamage - nSilverDamage;
		-- Debug.console("target is NOT silver vulnerable but weapon is silver = don't count silver damage : ", nFinalDamage);
	end

	sFinalDamageMessage = sFinalDamageMessage .. tonumber(nFinalDamage);

	-- STRONG ATTACK ?
	if (bValidDmgModifier and aPendingAttackDmgMod.sIsStrongAttack == "true") or (ModifierStack.getModifierKey("ATT_STRONG")) then
		-- check manual modifier
		nFinalDamage = nFinalDamage*2;
		sFinalDamageMessage = "(" .. sFinalDamageMessage .. "x2)";
		-- Debug.console("after strong attack multiplier : ", nFinalDamage);
	else
		-- Debug.console("no strong attack multiplier : ", nFinalDamage);
	end

	-- LOCATION ?
	local sLocation = "";
	local sIsAimed = "false";
	-- location from pending attack
	if bValidDmgModifier then
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

	-- Debug.console("location : ", sLocation);

	-- CRITICAL ?
	-- must be done here because it may affect location
	local sCriticalLevel = "none";
	if bValidDmgModifier then
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
	processCriticalDamageAndLocation(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, rRoll.sDesc, rRoll.sEffects, nFinalDamage, sFinalDamageMessage);
	
end

function applyDamage2(sSourceCT, sTargetCT, sLocation, sDamageText, sWeaponEffects, nCritDamage, nFinalDamage, sFinalDamageMessage)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("Apply Damage 2 : ");
	-- Debug.console("sSourceCT : "..sSourceCT);
	-- Debug.console("sTargetCT : "..sTargetCT);
	-- Debug.console("sLocation : "..sLocation);
	-- Debug.console("sDamageText : "..sDamageText);
	-- Debug.console("nFinalDamage : "..nFinalDamage);
	-- Debug.console("sWeaponEffects : "..sWeaponEffects);

	local rTarget = ActorManager.resolveActor(sTargetCT);
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	
	-- Decode damage description
	local rDamageOutput = decodeDamageText(nFinalDamage, sDamageText);
	
	-- ARMOR
	local nArmorValue = 0;
	
	-- check armor piercing (negates the damage resistance of any armor) 
	-- and imp. armor piercing (negates the damage resistance of any armor and also halve the SP value) 
	local bArmorPiercing = false;
	local bImprovedArmorPiercing = false;
	if sWeaponEffects:find(Interface.getString("weapon_property_effect_improvedarmorpiercing"), 1, true) then
		bImprovedArmorPiercing = true;
	elseif sWeaponEffects:find(Interface.getString("weapon_property_effect_armorpiercing"), 1, true) then
		bArmorPiercing = true;
	end
	
	-- check soft spot
	local bSoftSpot = false;
	if ModifierStack.getModifierKey("DMG_SOFTSPOT") then
		bSoftSpot = true;
	end
	if bSoftSpot then
		local sVulnerabilities = CharManager.getVulnerabilities(nodeTarget, sTargetType);
		if sVulnerabilities:find("soft spot") then
			nArmorValue = tonumber(sVulnerabilities:match("soft spot%s*(%d)"));
			-- Debug.console("soft spot found, new SP is : ", nArmorValue);
		else
			bSoftSpot = false;
		end
	end

	if not bSoftSpot then
		nArmorValue = CharManager.getArmorValueForLocationRoll(nodeTarget, sLocation);
	end

	-- Debug.console("armor sp of target for location : ", nArmorValue);
	
	if bImprovedArmorPiercing then
		nArmorValue = math.floor(nArmorValue/2);
		-- Debug.console("weapon effect Imp. Armor piercing (half SP) : new SP = ", nArmorValue);
	end
	-- substract SP
	nFinalDamage = nFinalDamage - nArmorValue;
	if nFinalDamage < 0 then
		nFinalDamage = 0;
	end
	if nArmorValue > 0 then
		sFinalDamageMessage = sFinalDamageMessage .. " - " .. nArmorValue;
		if bImprovedArmorPiercing then
			sFinalDamageMessage = sFinalDamageMessage .. Interface.getString("damage_desc_halfarmor");
		else
			sFinalDamageMessage = sFinalDamageMessage .. Interface.getString("damage_desc_fullarmor");
		end

		-- if damages are done, armor is also damaged
		if nFinalDamage > 0 then
			-- Debug.console("remove 1 SP from armor at : ", sLocation);
			CharManager.damageArmorByLocation(nodeTarget, sLocation);
		end
	end
	-- Debug.console("damage after armor : ", nFinalDamage);
	
	-- SILVER susceptibility
	local bIsSilverVulnerable = CharManager.isSilverVulnerable(nodeTarget);
	local nSilverDamage = 0;
	for k,v in pairs(rDamageOutput.aDamageTypes) do
		if string.find(string.lower(k), "silver") then
			nSilverDamage = nSilverDamage + v;
		end
	end
	if bIsSilverVulnerable and nSilverDamage <= 0 then
		-- target is silver vulnerable but weapon is not silver : half damage 
		nFinalDamage = math.floor(nFinalDamage/2);
		sFinalDamageMessage = "(" .. sFinalDamageMessage .. ") / 2 {silver}";
		-- Debug.console("target is silver vulnerable but weapon is NOT silver : ", nFinalDamage);
	end

	-- METEORITE susceptibility
	local bIsMeteoriteVulnerable = CharManager.isMeteoriteVulnerable(nodeTarget);
	local bIsWeaponMeteorite = (sWeaponEffects:find(Interface.getString("weapon_property_effect_meteorite"), 1, true) ~= nil);
	if bIsMeteoriteVulnerable and not bIsWeaponMeteorite then
		-- target is meteorite vulnerable but weapon is not meteorite : half damage 
		nFinalDamage = math.floor(nFinalDamage/2);
		sFinalDamageMessage = "(" .. sFinalDamageMessage .. ") / 2 {meteorite}";
		-- Debug.console("target is meteorite vulnerable but weapon is NOT meteorite : ", nFinalDamage);
	end

	-- resistance (x0.5)
	-- soft spot, armor piercing and improved armor piercing negate resistance
	if not bSoftSpot and not bArmorPiercing and not bImprovedArmorPiercing then
		local bResistant = false;
		for k,v in pairs(rDamageOutput.aDamageTypes) do
			if CharManager.isResistantTo(nodeTarget, sTargetType, k, sLocation) then
				bResistant = true;
				break;
			end
		end
		if bResistant then
			nFinalDamage = math.floor(nFinalDamage/2);
			sFinalDamageMessage = "(" .. sFinalDamageMessage .. ") / 2 {resistance}";
			-- Debug.console("target is resistant, damage after resistance : ", nFinalDamage);
		end
	else
		-- Debug.console("by-pass resistance : ", bSoftSpot, bArmorPiercing, bImprovedArmorPiercing);		
	end
	
	-- vulnerability (x2)
	local bVulnerable = false;
	for k,v in pairs(rDamageOutput.aDamageTypes) do
		if CharManager.isVulnerableTo(nodeTarget, sTargetType, k) then
			bVulnerable = true;
			break;
		end
	end
	if bVulnerable then
		nFinalDamage = nFinalDamage * 2;
		sFinalDamageMessage = "(" .. sFinalDamageMessage .. ") x 2 {vulnerable}";
		-- Debug.console("target is vulnerable, damage after bVulnerability : ", nFinalDamage);
	end

	-- location multiplier
	local nLocationMultiplier = CharManager.getDamageLocationModifierForLocationRoll(nodeTarget, sLocation);
	-- Debug.console("location multiplier : ", nLocationMultiplier);
	nFinalDamage = math.floor(nFinalDamage*nLocationMultiplier);
	if nLocationMultiplier ~= 1 then
		sFinalDamageMessage = "(" .. sFinalDamageMessage .. ") x " .. nLocationMultiplier .. "{location}";
	end
	-- Debug.console("damage after location : ", nFinalDamage);
	
	if nCritDamage > 0 then
		sFinalDamageMessage = sFinalDamageMessage .. " + " .. nCritDamage .. "{crit}"
	end

	-- Lethal / Non-lethal damage
	local bLethal = true;
	if ModifierStack.getModifierKey("DMG_NONLETHAL") then
		bLethal = false;
		-- Debug.console("non-lethal modifier activated");
	elseif sWeaponEffects:find(Interface.getString("weapon_property_effect_nonethal"), 1, true) then
		bLethal = false;
		-- Debug.console("weapon has non-lethal effect");
	end

	-- Output results
	local sDamageType = Interface.getString("damage_desc_normaldamage");
	if not bLethal then
		sDamageType = Interface.getString("damage_desc_nonlethaldamage");
	end
	messageDamage(rSource, rTarget, bSecret, sDamageType, sDamage, nCritDamage, nFinalDamage, sFinalDamageMessage);

	-- update hit_point 
	notifyApplyDamage(sTargetCT, nFinalDamage + nCritDamage, bLethal);

	CombatManager2.removePendingAttack(sSourceCT, sTargetCT, false);
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
	
	if rTarget then
		msgLong.text = msgLong.text .. "] ->";
		msgShort.text = msgShort.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgShort.text = msgShort.text .. "\n" .. sExtraResult;
		msgLong.text = msgLong.text .. "\n" .. sExtraResult;
	end
	
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

------------------------------------------------------------------------------------
-- CRITICAL MANAGEMENT
------------------------------------------------------------------------------------
function processCriticalDamageAndLocation(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, sWeaponEffects, nFinalDamage, sFinalDamageMessage)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("processCriticalDamageAndLocation : ");
	-- Debug.console("sWeaponEffects : "..sWeaponEffects);
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

	local rRoll = getCriticalLocationRoll(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, nExtraDamage, nFinalDamage, sFinalDamageMessage);
	rRoll.sWeaponEffects = sWeaponEffects;

	local rTarget = ActorManager.resolveActor(sTargetCT);
	
	if sCriticalLevel == "none" then
		-- no critical, we must roll for simple location
		if sIsAimed == "true" then
			outputCriticalMessage(sSourceCT, sTargetCT, 0, sCriticalLevel, sLocation, sDamageText, sWeaponEffects, nExtraDamage, nFinalDamage, sFinalDamageMessage);
		else
			ActionsManager.performAction(nil, rTarget, rRoll);
		end
	else
		-- balanced weapon effect : roll 2d6+2 for the critical. If the attack was aimed, roll 1d6+1 instead of 1d6
		local bBalanced = false;
		if string.find(sWeaponEffects, Interface.getString("weapon_property_effect_balanced"), 1, true) then
			bBalanced = true;
		end

		-- pin point aim ? (add their Pin Point Aim value to their critical roll. These points only affect the location value of the Critical Wound) 
		if ModifierStack.getModifierKey("DMG_PINPOINTAIM") then
			local ppaValue =  CharManager.getProfessionSkillValue(ActorManager.resolveActor(sSourceCT), "pinPointAim")
			-- Debug.console("[processCriticalDamageAndLocation]Add pin point roll to crit location : "..ppaValue);
			rRoll.nMod = ppaValue;
		end

		-- was the attack aimed ?
		if sIsAimed == "true" then
			if sLocation == "head" or sLocation == "torso" then
				-- head or torso roll 1D6 (if weapon balanced : 1D6+1 instead))
				if (bBalanced) then
					rRoll.nMod = rRoll.nMod + 1;
					-- Debug.console("weapon balanced : crit roll 1D6+1 instead");
				end
				ActionsManager.performAction(nil, rTarget, rRoll);
			elseif sLocation == "arm" then
				outputCriticalMessage(sSourceCT, sTargetCT, 4, sCriticalLevel, sLocation, sDamageText, sWeaponEffects, nExtraDamage, nFinalDamage, sFinalDamageMessage);
			elseif sLocation == "leg" or sLocation == "limb" or sLocation == "tail" then
				outputCriticalMessage(sSourceCT, sTargetCT, 2, sCriticalLevel, sLocation, sDamageText, sWeaponEffects, nExtraDamage, nFinalDamage, sFinalDamageMessage);
			else
				-- Debug.console("[processCriticalDamageAndLocation error ]Attack aimed with no location specified");
			end
		else
			-- roll 2D6 (if weapon balanced : 2d6+2)
			if (bBalanced) then
				rRoll.nMod = rRoll.nMod + 2;
				-- Debug.console("weapon balanced : crit roll 2D6+2 instead");
			end
			ActionsManager.performAction(nil, rTarget, rRoll);
		end
	end

	return nExtraDamage;
end

function getCriticalLocationRoll(sSourceCT, sTargetCT, sCriticalLevel, sIsAimed, sLocation, sDamageText, nExtraDamage, nFinalDamage, sFinalDamageMessage)
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
	rRoll.sFinalDamageMessage = sFinalDamageMessage;
	rRoll.sWeaponEffects = "";

	return rRoll;
end

-- callback for ActionsManager, called after the dice have stopped rolling : resolve roll status and display chat message
-- rSource is the character receiving damage
function onCriticalLocationRoll(rSource, rTarget, rRoll)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("onCriticalLocationRoll");
	-- Debug.console(rRoll);

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
		elseif nResult >= 10 then
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
		elseif nResult >= 11 then
			rRoll.sLocation = "head";
		end
	end

	outputCriticalMessage(rRoll.sSourceCT, rRoll.sTargetCT, nResult, rRoll.sCriticalLevel, rRoll.sLocation, rRoll.sDamageText, rRoll.sWeaponEffects, tonumber(rRoll.sExtraDamage), tonumber(rRoll.sFinalDamage), rRoll.sFinalDamageMessage);
end

function outputCriticalMessage(sSourceCT, sTargetCT, nResult, sCriticalLevel, sLocation, sDamageText, sWeaponEffects, nExtraDamage, nFinalDamage, sFinalDamageMessage)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("outputCriticalMessage");
	-- Debug.console("nResult = "..tostring(nResult));
	
	local rTarget = ActorManager.resolveActor(sTargetCT);
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
		rMessage.text = "[".. Interface.getString("damage_label_critical_"..sCriticalLevel);
		rMessage.text = rMessage.text.." ("..nResult..") ]";
		rMessage.text = rMessage.text .. "[".. Interface.getString("damage_label_location_"..sLocation) .."]\n";
	
		local sLabelId = "critical_label_".. sCriticalLevel .. "_" .. sLocation;
		local sDescId = "critical_desc_".. sCriticalLevel .. "_" .. sLocation;
		
		if nResult >= 12 or nResult == 10 or nResult == 9 then
			sLabelId = sLabelId .. "_greater";
			sDescId = sDescId .. "_greater";
		elseif nResult == 11 or nResult == 8 or nResult == 7 or nResult == 6 then
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
	applyDamage2(sSourceCT, sTargetCT, sLocation, sDamageText, sWeaponEffects, sBonusDamage, nFinalDamage, sFinalDamageMessage)
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
		-- Debug.console("Total mismatch in damage type totals");
	end
	
	return rDamageOutput;
end

------------------------------------------------------------------------------------
-- OOB MESSAGES MANAGEMENT
------------------------------------------------------------------------------------

-- Notify damage / heal roll
function notifyApplyDamage(sTargetCT, nTotalDamage, bLethal)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("notifyApplyDamage - nTotalDamage : ");
	-- Debug.console(nTotalDamage);
	
	if sTargetCT == "" then
		-- Debug.console("notifyApplyDamage without legit rTarget : abort");
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	msgOOB.sTargetCT = sTargetCT;
	msgOOB.sLethal = "true";
	if not bLethal then
		msgOOB.sLethal = "false";
	end
	
	-- total damage rolled
	msgOOB.nTotal = nTotalDamage;

	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB damage / heal roll notification
function handleDamage(msgOOB)
	-- Debug.console("--------------------------------------------");
	-- Debug.console("Handle Damage - msgOOB : ");
	-- Debug.console(msgOOB);
	
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetCT);
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	if msgOOB.sLethal == "true" then
		local nCurrentHP = DB.getValue(nodeTarget, "attributs.hit_points", 0);
		DB.setValue(nodeTarget, "attributs.hit_points", "number", nCurrentHP - msgOOB.nTotal);
	else
		local nCurrentSTA = DB.getValue(nodeTarget, "attributs.stamina", 0);
		DB.setValue(nodeTarget, "attributs.stamina", "number", nCurrentSTA - msgOOB.nTotal);
	end
end

