-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	CombatManager.setCustomSort(CombatManager.sortfuncStandard);
	
	CombatManager.setCustomRoundStart(onRoundStart);
	CombatManager.setCustomTurnStart(onTurnStart);
	CombatManager.setCustomTurnEnd(onTurnEnd);

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
