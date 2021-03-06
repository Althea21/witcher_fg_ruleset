-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for save rolls
--

function onInit()
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("save", onRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor	: actor info retrieved by using ActorManager.resolveActor
--	* sSave		: save type (supported : "stun")
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, sSave)
	-- Initialise a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "save";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded upon the save type later
	rRoll.sDesc = "[UNKNOWN SAVE] ";

	-- Look up actor specific information
	local sSaveDC = nil;
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sSave == "stun" then
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
--	* sSave		: save type (supported : "stun")
function performRoll(draginfo, rActor, sSave)
	local rRoll = getRoll(rActor, sSave);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onRoll(rSource, rTarget, rRoll)
	local rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	-- Create the base message based off the source and the final rRoll record (includes dice results).
	local rMessage = ActionsManager.createActionMessage(rActor, rRoll);
	
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