-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	CombatManager.setCustomSort(CombatManager.sortfuncStandard);
	
	CombatManager.setCustomAddNPC(addNPC);

	--CombatManager.setCustomRoundStart(onRoundStart);
	--CombatManager.setCustomTurnStart(onTurnStart);
	--CombatManager.setCustomTurnEnd(onTurnEnd);

	CombatManager.setCustomCombatReset(resetInit);
end

--
-- ACTIONS
--

function resetInit()
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "initresult", "number", 0);
	end
end

--
-- TURN FUNCTIONS
--

function onRoundStart(nCurrent)
	if OptionsManager.isOption("HRIR", "on") then
		rollInit();
	end
end

function onTurnStart(nodeEntry)
	-- TODO 
end

function onTurnEnd(nodeEntry)
	-- TODO
end

function rollEntryInit(nodeEntry)
	if not nodeEntry then
		return;
	end
	
	local rActor = ActorManager.getActorFromCT(nodeEntry);
	ActionInit.performRoll(null, rActor);
	DB.setValue(nodeEntry, "initresult", "number", nInitResult);
end

function rollInit(sType)
	CombatManager.rollTypeInit(sType, rollEntryInit);
end


--
-- NPC
--
function addNPC(sClass, nodeNPC, sName)
	-- Debug.chat(nodeNPC);
	-- Debug.chat(nodeNPC.getPath());

	local nodeEntry, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);

	-- HP
	local nHP = DB.getValue(nodeNPC, "attributs.hit_pointsmax", 0);
	DB.setValue(nodeEntry, "hit_points", "number", nHP);

	-- Stamina
	local nSta = DB.getValue(nodeNPC, "attributs.staminamax", 0);
	DB.setValue(nodeEntry, "stamina", "number", nSta);

	return nodeEntry;
end

--
-- COMBAT RESOLUTION
--

-- Queue for tracking pending Attacks for defense, then damage resolution (FIFO)
-- Each item must be formatted like :
--	* sSourceCT : offender (obtained by ActorManager.getCreatureNodeName(rSource) )
--	* sTargetCT : defender (obtained by ActorManager.getCTNodeName(rTarget) )
--	* nAtkValue : value of attack roll (total with modifier, reroll etc...)
--	* nDefValue : value of defense roll (total with modifier, reroll etc...)
-- Item must be cleared after damage resolution
aAttackQueue = {};

-- Add pengin attack to the queue
-- params :
--	* rSource	: offender 
--	* rTarget	: defender 
--	* nAtkValue : value of attack roll (total with modifier, reroll etc...)
--	* sLocation : only if attack was aimed
function addPendingAttack(rSource, rTarget, nAtkValue, sLocation)
	Debug.chat(rSource);
	Debug.chat(rTarget);
	Debug.chat(nAtkValue);
	Debug.chat(sLocation);

	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	Debug.chat(sSourceCT);
	
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	Debug.chat(sTargetCT);
	
	local att = {nAtkValue, sLocation};
	
	if not aAttackQueue[sSourceCT] then
		aAttackQueue[sSourceCT] = {};
	end
	if not aAttackQueue[sSourceCT][sTargetCT] then
		aAttackQueue[sSourceCT][sTargetCT] = {};
	end

	table.insert(aAttackQueue[sSourceCT][sTargetCT], att);
end