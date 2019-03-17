-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for attack rolls
--

function onInit()
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["attack"] = { bUseModStack = true };
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("attack", onRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rAttack		: weapon type (supported : "melee", "range")
--	* sAttackType	: attack type (supported : "fast", "strong", "normal"). 
--					  Unknown or missing value will be trated like a "normal" attack
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rAttack, sAttackType)
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
	
	-- Look up actor / weapon specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		local sRollDescription = "";
		local nRollMod = 0;
		
		if sAttackType == "fast" then
			sRollDescription = "[Fast attack with "..rAttack.label.."]";
		elseif sAttackType == "strong" then
			sRollDescription = "[Strong attack with "..rAttack.label.."]";
			nRollMod = nRollMod - 3;
		else
			sRollDescription = "[Attack with "..rAttack.label.."]";
		end
		
		-- stat modifier
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs."..rAttack.stat, 0);
		
		-- skill modifier
		nRollMod = nRollMod + DB.getValue(nodeActor, "skills.skillslist."..rAttack.skill, 0);
		
		-- weapon accuracy modifier
		nRollMod = nRollMod + rAttack.weaponaccuracy;
		
		rRoll.sDesc = sRollDescription;
		rRoll.nMod = nRollMod;
	end
	
	return rRoll;
end

-- method called to initiate attack roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* sAttackType	: attack type (supported : "fast", "strong", "normal"). 
--					  Unknown or missing value will be trated like a "normal" attack
function performRoll(draginfo, rWeapon, sAttackType)
	-- retreive attack info and actor node 
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(rWeapon);
	
	-- get roll
	local rRoll = getRoll(rActor, rAttack, sAttackType);
	
	-- roll it !
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onRoll(rSource, rTarget, rRoll)
	-- Create the base message based of the source and the final rRoll record (includes dice results).
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
end