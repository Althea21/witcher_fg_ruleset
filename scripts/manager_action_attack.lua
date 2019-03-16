-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for attack rolls
--

function onInit()
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["attack"] = { bUseModStack = true , sTargeting = "each"};
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("attack", onRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* draginfo	: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* weaponType: weapon type (supported : "melee", "range")
--	* attackType: attack type (supported : "fast", "strong")
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, weaponType, attackType)
	-- Initialise a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "attack";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded upon the save type later
	rRoll.sDesc = "[Attack] ";
	
	-- Look up actor specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if weaponType == "melee" then
			rRoll.sDC = DB.getValue(nodeActor, "attributs.stun", 0);
			rRoll.sDesc = "[STUN SAVE] ";
		end
	end
	
	return rRoll;
end

-- method called to initiate save roll
-- params :
--	* draginfo	: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rActor	: actor info retrieved by using ActorManager.resolveActor
--	* weaponType: weapon type (supported : "melee", "range")
--	* attackType: attack type (supported : "fast", "strong")
function performRoll(draginfo, rActor, weaponType, attackType)
	local rRoll = getRoll(rActor, sSave, weaponType, attackType);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onRoll(rSource, rTarget, rRoll)
	-- Create the base message based off the source and the final rRoll record (includes dice results).
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	if rRoll.sDC then
		local nTotal = ActionsManager.total(rRoll);
		local nDC = tonumber(rRoll.sDC) or 0;
		
		if nDC > 0 then
			rMessage.text = rMessage.text .. " (vs. DC " .. nDC .. ")";
		end
		
		if nTotal < nDC then
			rMessage.text = rMessage.text .. " [SUCCESS]";
		else
			rMessage.text = rMessage.text .. " [FAILURE]";
		end
	end
	
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
end