-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


-- OOB Message types for combat resolution
OOB_MSGTYPE_APPLYATTACK = "applyattack";
OOB_MSGTYPE_RESETATTACKS = "resetattacks";
OOB_MSGTYPE_APPLYDEFENSE = "applydefense";


function onInit()
	-- set custom 
	CombatManager.setCustomSort(CombatManager.sortfuncStandard);
	CombatManager.setCustomAddNPC(addNPC);
	CombatManager.setCustomCombatReset(resetInit);
	CombatManager.setCustomRoundStart(onRoundStart);
	CombatManager.setCustomTurnStart(onTurnStart);
	CombatManager.setCustomTurnEnd(onTurnEnd);

	-- OOB Handlers
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATTACK, handleAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDEFENSE, handleDefense);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_RESETATTACKS, handleResetAtttacks);
end

--
-- INIT
--

-- reset all initiative (=set to 0)
function resetInit()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "initresult", "number", 0);
	end
end

function rollEntryInit(nodeEntry)
	if not nodeEntry then
		return;
	end
	
	local rActor = ActorManager.getActorFromCT(nodeEntry);
	ActionInit.performRoll(null, rActor);
	DB.setValue(nodeEntry, "initresult", "number", nInitResult);
end

-- roll init for ct entries
-- params :
--  * sType : "npc" to roll for NPC only
--			  "pc" to roll for PC only
--			  nil to roll for everyone
function rollInit(sType)
	CombatManager.rollTypeInit(sType, rollEntryInit);
end

--
-- TURN FUNCTIONS
--

function onRoundStart(nCurrent)
end

function onTurnStart(nodeEntry)
	resetPendingAttacks();
	notifyResetAtttacks();
end

function onTurnEnd(nodeEntry)
	resetPendingAttacks();
	notifyResetAtttacks();
end

--
-- NPC
--
function addNPC(sClass, nodeNPC, sName)
	local nodeEntry, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);

	-- HP
	local nHP = DB.getValue(nodeNPC, "attributs.hit_pointsmax", 0);
	DB.setValue(nodeEntry, "hit_points", "number", nHP);

	-- Stamina
	local nSta = DB.getValue(nodeNPC, "attributs.staminamax", 0);
	DB.setValue(nodeEntry, "stamina", "number", nSta);

	return nodeEntry;
end

------------------------------------------------------------------------------------
-- COMBAT RESOLUTION
------------------------------------------------------------------------------------

-- Queues for tracking pending Attacks for defense, then damage resolution (FIFO)
-- Each item must be formatted like :
--	* sSourceCT : offender (obtained by ActorManager.getCTNodeName(rSource) )
--	* sTargetCT : defender (obtained by ActorManager.getCTNodeName(rTarget) )
--	* nAtkValue : value of attack roll (total with modifier, reroll etc...)
--	* nDefValue : value of defense roll (total with modifier, reroll etc...)
--	* sLocation : strike location
--	* bAimed 	: if attack was aimed
-- Item must be cleared after damage resolution or if attack is missed.

-- Queue sorted by offender : aAttackQueueByOffender[sSourceCT][sTargetCT] = {}
aAttackQueueByOffender = {};
-- Queue sorted by defender : aAttackQueueByOffender[sTargetCT] = {}
aAttackQueueByDefender = {};

-- Add pending attack to the queues
-- params :
--	* rSource	: offender 
--	* rTarget	: defender 
--	* nAtkValue : value of attack roll (total with modifier, reroll etc...)
--	* sLocation : strike location
--	* sIsAimed 	: if attack was aimed or not ("true"/"false")
function addPendingAttack(sSourceCT, sTargetCT, nAtkValue, sLocation, sIsAimed)
	Debug.console("Add pending attack of "..sSourceCT.." vs "..sTargetCT.." (attack value="..nAtkValue..")");
	-- Debug.chat("---- addPendingAttack");
	-- Debug.chat(sSourceCT);
	-- Debug.chat(rTarget);
	-- Debug.chat(nAtkValue);
	-- Debug.chat(sLocation);
	-- Debug.chat(bAimed);

	if sTargetCT == "" then
		return;
	end
	
	local aAttack = {};
	aAttack.sSourceCT = sSourceCT;
	aAttack.sTargetCT = sTargetCT;
	aAttack.nAtkValue = nAtkValue;
	aAttack.nDefValue = -1;
	aAttack.sLocation = sLocation;
	aAttack.sIsAimed = sIsAimed;
	
	-- Debug.chat(aAttack);

	if not aAttackQueueByOffender[sSourceCT] then
		aAttackQueueByOffender[sSourceCT] = {};
	end
	if not aAttackQueueByOffender[sSourceCT][sTargetCT] then
		aAttackQueueByOffender[sSourceCT][sTargetCT] = {};
	end
	table.insert(aAttackQueueByOffender[sSourceCT][sTargetCT], aAttack);

	if not aAttackQueueByDefender[sTargetCT] then
		aAttackQueueByDefender[sTargetCT] = {};
	end
	table.insert(aAttackQueueByDefender[sTargetCT], aAttack);
	-- Debug.chat(aAttackQueueByDefender[sTargetCT]);
	--notifyAttack(sSourceCT, sTargetCT, aAttack);
end

-- Update pending attack in the queues
-- params :
--	* sSourceCT	: offender 
--	* sTargetCT	: defender 
--  * aAttack 	: array standing for the updated attack (see above for format)
function updatePendingAttack(sSourceCT, sTargetCT, aAttack)
	Debug.console("Update pending attack of "..sSourceCT.." vs "..sTargetCT);
	-- Debug.chat("---- updatePendingAttack")
	if aAttackQueueByOffender[sSourceCT] then
		if aAttackQueueByOffender[sSourceCT][sTargetCT] then
			aAttackQueueByOffender[sSourceCT][sTargetCT] = aAttack;
		end
	end
	-- Debug.chat("--- Before update")
	-- Debug.chat(aAttackQueueByDefender[sTargetCT]);
	
	if aAttackQueueByDefender[sTargetCT] then
		aAttackQueueByDefender[sTargetCT][1] = aAttack;
	end

	-- Debug.chat("--- After update")
	-- Debug.chat(aAttackQueueByDefender[sTargetCT]);
end

-- Remove pending attack from the queues
-- params :
--	* sSourceCT	: offender 
--	* sTargetCT	: defender 
function removePendingAttack (sSourceCT, sTargetCT)
	Debug.console("Remove pending attack of "..sSourceCT.." vs "..sTargetCT);
	if aAttackQueueByOffender[sSourceCT] then
		if aAttackQueueByOffender[sSourceCT][sTargetCT] then
			table.remove(aAttackQueueByOffender[sSourceCT][sTargetCT],1);
		end
	end
	-- Debug.chat("--- Before remove")
	-- Debug.chat(aAttackQueueByDefender[sTargetCT]);
	if aAttackQueueByDefender[sTargetCT] then
		table.remove(aAttackQueueByDefender[sTargetCT],1);
	end
	-- Debug.chat("--- After remove")
	-- Debug.chat(aAttackQueueByDefender[sTargetCT]);
end

-- Remove all pending attacks from the queues
function resetPendingAttacks ()
	Debug.console("Reset all pending attacks.");
	aAttackQueueByOffender = {};
	aAttackQueueByDefender = {};
	-- notify because players don't receive this event
end

-- Resolve attack vs defense
-- params :
--	* sTargetCT	: defender 
--	* nDefValue	: defense roll value 
function resolvePendingAttack(rTarget, nDefValue)
	Debug.console("--------------------------------------------");
	Debug.console("Resolve pending attack");
	
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	if sTargetCT == "" then
		-- Debug.chat("no sTargetCT : resolve aborted");
		Debug.console("No defender : resolve aborted");
		return;
	end
	-- Debug.chat(sTargetCT);
	Debug.console("Defender = "..sTargetCT);

	local aAttack = {};
	if aAttackQueueByDefender[sTargetCT] and aAttackQueueByDefender[sTargetCT][1] then
		aAttack = aAttackQueueByDefender[sTargetCT][1];
	else
		Debug.console("No pending attack : resolve aborted");
		return;
	end

	Debug.console("Attack information = ", aAttack);

	local rMessage = ChatManager.createBaseMessage(rTarget, nil);
	rMessage.sender = "";
	
	-- compare attack roll vs defense roll
	if aAttack.nAtkValue <= nDefValue then
		-- defense win : delete pending attack and create message
		Debug.console("Defense win");
		--removePendingAttack(aAttack.sSourceCT, sTargetCT);
		notifyDefense(aAttack.sSourceCT, sTargetCT, nil, "true");
		rMessage.text = Interface.getString("defense_succeeded_message");
		rMessage.icon = "roll_attack_miss";
	else
		-- attack win : update pending attack and create message
		Debug.console("Attack win");
		aAttack.nDefValue = nDefValue;
		--updatePendingAttack(aAttack.sSourceCT, sTargetCT, aAttack);
		notifyDefense(aAttack.sSourceCT, sTargetCT, aAttack, "false");
		rMessage.text = Interface.getString("defense_failed_message") .. "\n";
		
		-- check for critical
		local successMargin = aAttack.nAtkValue - nDefValue;
		Debug.console("Success Margin", successMargin);
		if successMargin >= 15 then
			-- Deadly crit
			rMessage.text = rMessage.text .. string.format(Interface.getString("deadly_crit_message"), successMargin);
			rMessage.icon = "roll_attack_crit";
		elseif successMargin >= 13 then
			-- Difficult crit
			rMessage.text = rMessage.text .. string.format(Interface.getString("difficult_crit_message"), successMargin);
			rMessage.icon = "roll_attack_crit";
		elseif successMargin >= 10 then
			-- Complex crit
			rMessage.text = rMessage.text .. string.format(Interface.getString("complex_crit_message"), successMargin);
			rMessage.icon = "roll_attack_crit";
		elseif successMargin >= 7 then
			-- Simple crit
			rMessage.text = rMessage.text .. string.format(Interface.getString("simple_crit_message"), successMargin);
			rMessage.icon = "roll_attack_crit";
		else
			-- Hit
			rMessage.text = rMessage.text .. string.format(Interface.getString("no_crit_message"), successMargin);
			rMessage.icon = "roll_attack_hit";
		end
		rMessage.text = rMessage.text .. " " .. string.format(Interface.getString("rollfordamage_message"), ActorManager.getDisplayName(ActorManager.getActor("ct", aAttack.sSourceCT)));
	end

	-- display message
	Comm.deliverChatMessage(rMessage);
	Debug.console("--------------------------------------------");
end

------------------------------------------------------------------------------------
-- OOB MESSAGES MANAGEMENT
------------------------------------------------------------------------------------

-- Notify attack to keep attack queues up to date between GM and players
function notifyAttack(rSource, rTarget, nAtkValue, sLocation, sIsAimed)
	local msgOOB = {};
	
	local sSourceCT = ActorManager.getCTNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	-- Debug.chat(sSourceCT);
	
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	if sTargetCT == "" then
		return;
	end
	
	
	msgOOB.type = OOB_MSGTYPE_APPLYATTACK;
	msgOOB.sSourceCT = sSourceCT;
	msgOOB.sTargetCT = sTargetCT;
	msgOOB.sAtkValue = nAtkValue;
	msgOOB.sLocation = sLocation;
	msgOOB.sIsAimed = sIsAimed;
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB attack notification to keep attack queues up to date between GM and players
function handleAttack(msgOOB)
	-- Debug.chat("---- handleAttack")
	addPendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT, tonumber(msgOOB.sAtkValue), msgOOB.sLocation, msgOOB.sIsAimed)
end

-- Notify defense to keep attack queues up to date between GM and players
function notifyDefense(sSourceCT, sTargetCT, aAttack, sRemove)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDEFENSE;
	msgOOB.sSourceCT = sSourceCT;
	msgOOB.sTargetCT = sTargetCT;
	
	if not aAttack then
		msgOOB.sAttack = "";
	else
		msgOOB.sAttack = Json.stringify(aAttack);
	end
	msgOOB.sRemove = sRemove;
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB defense notification to keep attack queues up to date between GM and players
function handleDefense(msgOOB) 
	-- Debug.chat("---- handleDefense")
	if (msgOOB.sRemove == "true") then
		-- Debug.chat("removePendingAttack")
		removePendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT);
	else
		-- Debug.chat("updatePendingAttack")
		local aAttack = Json.parse(msgOOB.sAttack)
		
		-- temporary delete pending attack until damage resolution is done (TODO)
		removePendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT);
		--updatePendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT, aAttack);
	end
end

-- Notify reset of pending attacks queues
function notifyResetAtttacks()
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_RESETATTACKS;
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB defense notification to keep attack queues up to date between GM and players
function handleResetAtttacks()
	resetPendingAttacks();
end


-- retreive node from source ct name
-- local rSource = ActorManager.getActor("ct", msgOOB.sSourceNode);
