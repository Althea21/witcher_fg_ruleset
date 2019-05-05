-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYDMG = "applydmg";
OOB_MSGTYPE_APPLYDMGSTATE = "applydmgstate";

function onInit()
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["damage"] = { sTargeting = "each", bUseModStack = true },
	
	-- Register modifier handler TODO
	--ActionsManager.registerModHandler("damage", onDamageModifier);
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("damage", onDamage);
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
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be completed later
	rRoll.sDesc = "["..Interface.getString("damage_roll_title");

	rRoll.sDesc = rRoll.sDesc.." "..Interface.getString("damage_for_label").." "..rAction.label;
	
	if rAction.range then
		rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range ..")";
		rRoll.range = rAction.range;
	end
	
	rRoll.sDesc = rRoll.sDesc.."]";

	-- Save the damage clauses in the roll structure
	rRoll.clauses = rAction.clauses;
	
	-- Add the dice and modifiers
	for _,vClause in pairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(rRoll.aDice, vDie);
		end
		rRoll.nMod = rRoll.nMod + vClause.modifier;
	end
	
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

-- Modifier handler : additional modifiers to apply to the roll
function onDamageModifier(rSource, rTarget, rRoll)
	-- Set up
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	local nMultBeforeArmor = 1;
	local nMultAfterArmor = 1;
	
	-- Build attack type filter
	local aAttackFilter = {};
	if rRoll.range == "R" then
		table.insert(aAttackFilter, "ranged");
	elseif rRoll.range == "M" then
		table.insert(aAttackFilter, "melee");
	end

	-- STRONG ATTACK -----------------------
	local bStrongAttack = false;
	
	-- check manual modifier
	if ModifierStack.getModifierKey("ATT_STRONG") then
		bStrongAttack = true;
	end

	-- Strong attack auto resolution
	-- TODO

	-- resolve strong attack consequences on damage
	if bStrongAttack then
		table.insert(aAddDesc, "["..Interface.getString("damage_label_strongattack").."]");
		nMultBeforeArmor = 2;
	end
	
	-- LOCATION -----------------------
	local sLocation = "";
	
	-- check manual modifier
	if ModifierStack.getModifierKey("AIM_HEAD") then
		sLocation = "head";
	elseif ModifierStack.getModifierKey("AIM_TORSO") then
		sLocation = "torso";
	elseif ModifierStack.getModifierKey("AIM_TAIL") then
		sLocation = "tail";
	elseif ModifierStack.getModifierKey("AIM_ARM") then
		sLocation = "arm";
	elseif ModifierStack.getModifierKey("AIM_LEG") then
		sLocation = "leg";
	elseif ModifierStack.getModifierKey("AIM_LIMB") then
		sLocation = "limb";
	end

	-- Location auto resolution
	-- TODO

	-- resolve location consequences on damage
	if sLocation ~= "" then
		local sLocDesc = "["..Interface.getString("damage_label_location_"..sLocation).." x";
		
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

	-- CRITICAL -----------------------
	local sCritical = "";
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

	-- critical auto resolution TODO
	-- if ActionAttack.isCrit(rSource, rTarget) then
	-- 	bCritical = true;
	-- end
	
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
	
	-- Add notes to roll description
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end

	rRoll.nMod = rRoll.nMod + nAddMod;
	rRoll.nMultBeforeArmor = nMultBeforeArmor;
	rRoll.nMultAfterArmor = nMultAfterArmor;
end

-- callback for ActionsManager, called after the dice have stopped rolling : resolve roll status and display chat message
function onDamage(rSource, rTarget, rRoll)
	-- Debug.chat("------- onDamage");
	-- Debug.chat("--rSource : ");
	-- Debug.chat(rSource);
	-- Debug.chat("--rTarget : ");
	-- Debug.chat(rTarget);
	-- Debug.chat("--rRoll : ");
	-- Debug.chat(rRoll);

	local rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	
	local rMessage = ActionsManager.createActionMessage(rActor, rRoll);
	-- rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");
	-- rMessage.text = string.gsub(rMessage.text, " %[MULT:[^]]*%]", "");

	local nTotal = ActionsManager.total(rRoll);
	
	-- Send the chat message
	local bShowMsg = true;
	-- if rTarget and rTarget.nOrder and rTarget.nOrder ~= 1 then
	-- 	bShowMsg = false;
	-- end
	if bShowMsg then
		Comm.deliverChatMessage(rMessage);
	end

	-- Apply damage to the PC or CT entry referenced
	--notifyApplyDamage(rSource, rTarget, rRoll.bTower, rRoll.sType, rMessage.text, nTotal);
end

