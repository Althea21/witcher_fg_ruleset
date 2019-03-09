-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for save rolls
--

function onInit()
	-- Register the save action.  We'll allow use of the modifier stack for this action type.
	GameSystem.actions["save"] = { bUseModStack = true },
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("save", onRoll);
end

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

function performRoll(draginfo, rActor, sSave)
	local rRoll = getRoll(rActor, sSave);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

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