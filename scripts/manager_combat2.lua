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
function addPendingAttack(rSource, rTarget, nAtkValue, sLocation, bAimed)
	-- Debug.chat("---- addPendingAttack");
	-- Debug.chat(rSource);
	-- Debug.chat(rTarget);
	-- Debug.chat(nAtkValue);
	-- Debug.chat(sLocation);

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
	-- Debug.chat(sTargetCT);
	
	-- Debug.chat("aAttack");

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

	notifyAttack(sSourceCT, sTargetCT, aAttack);
end

-- Update pending attack in the queues
-- params :
--	* sSourceCT	: offender 
--	* sTargetCT	: defender 
--  * aAttack 	: array standing for the updated attack (see above for format)
function updatePendingAttack(sSourceCT, sTargetCT, aAttack)
	if aAttackQueueByOffender[sSourceCT] then
		if aAttackQueueByOffender[sSourceCT][sTargetCT] then
			aAttackQueueByOffender[sSourceCT][sTargetCT] = aAttack;
		end
	end
	if aAttackQueueByDefender[sTargetCT] then
		aAttackQueueByDefender[sTargetCT][1] = aAttack;
	end
end

-- Remove pending attack from the queues
-- params :
--	* sSourceCT	: offender 
--	* sTargetCT	: defender 
function removePendingAttack (sSourceCT, sTargetCT)
	if aAttackQueueByOffender[sSourceCT] then
		if aAttackQueueByOffender[sSourceCT][sTargetCT] then
			table.remove(aAttackQueueByOffender[sSourceCT][sTargetCT],1);
		end
	end
	if aAttackQueueByDefender[sTargetCT] then
		table.remove(aAttackQueueByDefender[sTargetCT],1);
	end
end

-- Remove all pending attacks from the queues
function resetPendingAttacks ()
	aAttackQueueByOffender = {};
	aAttackQueueByDefender = {};
	-- notify because players don't receive this event
end

-- Resolve attack vs defense
-- params :
--	* sTargetCT	: defender 
--	* nDefValue	: defense roll value 
function resolvePendingAttack(rTarget, nDefValue)
	-- Debug.chat("---- resolvePendingAttack");
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	if sTargetCT == "" then
		-- Debug.chat("no sTargetCT : resolve aborted");
		return;
	end
	-- Debug.chat(sTargetCT);

	local aAttack = {};
	if aAttackQueueByDefender[sTargetCT] then
		aAttack = aAttackQueueByDefender[sTargetCT][1];
	else
		-- Debug.chat("no pending attack : resolve aborted");
		return;
	end
	-- Debug.chat("-- aAttack");
	-- Debug.chat(aAttack);

	local message = ChatManager.createBaseMessage(rTarget, nil);
	
	-- compare attack roll vs defense roll
	if aAttack.nAtkValue <= nDefValue then
		-- defense win : delete pending attack and create message
		-- Debug.chat("defense win");
		removePendingAttack(aAttack.sSourceCT, sTargetCT);
		message.text = Interface.getString("defense_succeeded_message");
		message.icon = "roll_attack_miss";
	else
		-- attack win : update pending attack and create message
		-- Debug.chat("attack win");
		aAttack.nDefValue = nDefValue;
		updatePendingAttack(aAttack.sSourceCT, sTargetCT, aAttack);
		notifyDefense(aAttack.sSourceCT, sTargetCT, aAttack);
		message.text = string.format(Interface.getString("defense_failed_message"), ActorManager.getDisplayName(ActorManager.getActor("ct", aAttack.sSourceCT)));
		message.icon = "roll_attack_hit";
	end

	-- display message
	Comm.deliverChatMessage(message);
end

------------------------------------------------------------------------------------
-- OOB MESSAGES MANAGEMENT
------------------------------------------------------------------------------------

-- Notify attack to keep attack queues up to date between GM and players
function notifyAttack(sSourceCT, sTargetCT, aAttack)
	-- Debug.chat("---- notifyAttack");
	-- Debug.chat("-- aAttack");
	-- Debug.chat(aAttack);

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATTACK;
	msgOOB.sSourceCT = sSourceCT;
	msgOOB.sTargetCT = sTargetCT;
	msgOOB.sAttack = Json.stringify(aAttack);
	
	-- Debug.chat("-- msgOOB");
	-- Debug.chat(msgOOB);
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB attack notification to keep attack queues up to date between GM and players
function handleAttack(msgOOB)
	-- Debug.chat("---- handleAttack");
	-- Debug.chat("-- msgOOB");
	-- Debug.chat(msgOOB);

	local aAttack = Json.parse(msgOOB.sAttack)
	
	-- Debug.chat("-- aAttack");
	-- Debug.chat(aAttack);

	--updatePendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT, aAttack)
	if not aAttackQueueByOffender[msgOOB.sSourceCT] then
		aAttackQueueByOffender[msgOOB.sSourceCT] = {};
	end
	if not aAttackQueueByOffender[msgOOB.sSourceCT][msgOOB.sTargetCT] then
		aAttackQueueByOffender[msgOOB.sSourceCT][msgOOB.sTargetCT] = {};
	end
	table.insert(aAttackQueueByOffender[msgOOB.sSourceCT][msgOOB.sTargetCT], aAttack);

	if not aAttackQueueByDefender[msgOOB.sTargetCT] then
		aAttackQueueByDefender[msgOOB.sTargetCT] = {};
	end
	table.insert(aAttackQueueByDefender[msgOOB.sTargetCT], aAttack);
end

-- Notify defense to keep attack queues up to date between GM and players
function notifyDefense(sSourceCT, sTargetCT, aAttack)
	-- Debug.chat("---- notifyDefense");
	-- Debug.chat("-- aAttack");
	-- Debug.chat(aAttack);

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDEFENSE;
	msgOOB.sSourceCT = sSourceCT;
	msgOOB.sTargetCT = sTargetCT;
	msgOOB.sAttack = Json.stringify(aAttack);
	
	-- Debug.chat("-- msgOOB");
	-- Debug.chat(msgOOB);
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB defense notification to keep attack queues up to date between GM and players
function handleDefense(msgOOB)
	-- Debug.chat("---- handleDefense");
	-- Debug.chat("-- msgOOB");
	-- Debug.chat(msgOOB);

	local aAttack = Json.parse(msgOOB.sAttack)
	
	-- Debug.chat("-- aAttack");
	-- Debug.chat(aAttack);

	updatePendingAttack(msgOOB.sSourceCT, msgOOB.sTargetCT, aAttack);
end

-- Notify reset of pending attacks queues
function notifyResetAtttacks()
	Debug.chat("---- notifyResetAtttacks");

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_RESETATTACKS;
	
	-- deliver msgOOB to all connected clients
	Comm.deliverOOBMessage(msgOOB);
end

-- Handle OOB defense notification to keep attack queues up to date between GM and players
function handleResetAtttacks()
	Debug.chat("---- handleResetAtttacks");
	resetPendingAttacks();
end


-- retreive node from source ct name
-- local rSource = ActorManager.getActor("ct", msgOOB.sSourceNode);
