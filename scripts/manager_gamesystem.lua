-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	["attack"]	= { sTargeting = "each", bUseModStack = true },
	-- Register damage actions.  We'll allow use of the modifier stack for those actions.
	["damage"] = { bUseModStack = true, sTargeting = "each" },
	["criticaldamage"] = { bUseModStack = true},
	-- Register defense actions.  We'll allow use of the modifier stack for those actions.
	["defense"] = { bUseModStack = true },
	-- Register the save action.  We'll allow use of the modifier stack for this action type.
	["save"] = { bUseModStack = true },
	-- Register spell actions.  We'll allow use of the modifier stack for those actions.
	["spellcast"] = { sTargeting = "each", bUseModStack = true },
	-- triggered
	["attackreroll"]	= { bUseModStack = false },
	["attacklocation"]	= { bUseModStack = false }
	
};

targetactions = {
	"effect",
};

languages = {
};

function getCharSelectDetailHost(nodeChar)
	return "";
end

function requestCharSelectDetailClient()
	return "name";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails, "";
end

function getCharSelectDetailLocal(nodeLocal)
	return DB.getValue(nodeLocal, "name", ""), "";
end

function getDistanceUnitsPerGrid()
	return 1;
end
