-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- ItemManager.setCustomCharAdd(onCharItemAdd);
end

function updateEncumbrance(nodeChar)
	local nEncTotal = 0;

	local nCount, nWeight;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) ~= 0 then
			nCount = DB.getValue(vNode, "count", 0);
			if nCount < 1 then
				nCount = 1;
			end
			nWeight = DB.getValue(vNode, "weight", 0);
			
			nEncTotal = nEncTotal + (nCount * nWeight);
		end
	end

	DB.setValue(nodeChar, "encumbrance.load", "number", nEncTotal);
	DB.setValue(nodeChar, "attributs.encumbrance", "number", nEncTotal);
end

function onCharItemAdd(nodeItem)
	-- DB.setValue(nodeItem, "carried", "number", 1);
end

function onActionDrop(draginfo, nodeChar)
	-- if draginfo.isType("spellmove") then
	-- 	ChatManager.Message(Interface.getString("spell_error_dropclassmissing"));
	-- 	return true;
	-- elseif draginfo.isType("spelldescwithlevel") then
	-- 	ChatManager.Message(Interface.getString("spell_error_dropclassmissing"));
	-- 	return true;
	-- elseif draginfo.isType("shortcut") then
	-- 	local sClass, sRecord = draginfo.getShortcutData();
		
	-- 	if sClass == "spelldesc" or sClass == "spelldesc2" then
	-- 		ChatManager.Message(Interface.getString("spell_error_dropclasslevelmissing"));
	-- 		return true;
	-- 	elseif LibraryData.isRecordDisplayClass("item", sClass) and ItemManager2.isWeapon(sRecord) then
	-- 		return ItemManager.handleAnyDrop(nodeChar, draginfo);
	-- 	end
	-- end
end
--
-- weapon management
--
function getWeaponAttackRollStructures(nodeWeapon)
	if not nodeWeapon then
		return;
	end
	
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("", nodeChar);

	--create attack object
	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = DB.getValue(nodeWeapon, "name", "");
	
	-- effects (weapon + enhancements if any)
	local sWeaponEffects = getWeaponEffects(nodeWeapon);
	rAttack.effects = sWeaponEffects;
	if rAttack.effects ~= "" then
		rAttack.effects = (rAttack.effects).."\n";
	end

	-- melee (M) / range (R)
	local nType = DB.getValue(nodeWeapon, "type", 0);
	if nType == 2 then
		rAttack.range = "M";
	elseif nType == 1 then
		rAttack.range = "R";
	else
		rAttack.range = "M";
	end
	
	rAttack.errorMsg = "";
	-- stat
	rAttack.stat = DB.getValue(nodeWeapon, "attackstat", "");
	if rAttack.stat == "" then
		rAttack.errorMsg = "No stat defined for attack roll. \n";
	end
	-- skill
	rAttack.skill = DB.getValue(nodeWeapon, "attackskill", "");
	if rAttack.skill == "" then
		rAttack.errorMsg = rAttack.errorMsg.."No skill defined for attack roll.\n";
	end
	-- wa
	rAttack.weaponaccuracy = DB.getValue(nodeWeapon, "weapon_accuracy", 0);
	
	return rActor, rAttack;
end

function getWeaponDefenseRollStructures(nodeWeapon)
	--Debug.chat(nodeWeapon)
	if not nodeWeapon then
		return;
	end
	
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);

	--create attack object
	local rAttack = {};
	rAttack.type = "defense";
	rAttack.label = DB.getValue(nodeWeapon, "name", "");
	rAttack.sWeaponNodeId = nodeWeapon.getNodeName();
	
	-- effects (weapon + enhancements if any)
	-- weapon effects and enhancements
	local sWeaponEffects = getWeaponEffects(nodeWeapon);
	rAttack.effects = sWeaponEffects;
	if rAttack.effects ~= "" then
		rAttack.effects = (rAttack.effects).."\n";
	end
	
	-- melee (M) / range (R)
	local nType = DB.getValue(nodeWeapon, "type", 0);
	if nType == 2 then
		rAttack.range = "M";
	elseif nType == 1 then
		rAttack.range = "R";
	else
		rAttack.range = "M";
	end
	
	rAttack.errorMsg = "";
	-- stat
	rAttack.stat = DB.getValue(nodeWeapon, "attackstat", "");
	if rAttack.stat == "" then
		rAttack.errorMsg = "No stat defined for attack roll. \n";
	end
	-- skill
	rAttack.skill = DB.getValue(nodeWeapon, "attackskill", "");
	if rAttack.skill == "" then
		rAttack.errorMsg = rAttack.errorMsg.."No skill defined for attack roll.\n";
	end
	-- wa
	rAttack.weaponaccuracy = DB.getValue(nodeWeapon, "weapon_accuracy", 0);
	
	return rActor, rAttack;
end

-- Get weapon effects (natural + runes of the specified weapon)
-- param :
--  * nodeWeapon : the db node of the weapon
-- returns :
--  * effects as human readable string
function getWeaponEffects(nodeWeapon)
	--Debug.chat("------- _getWeaponEffects");
	--Debug.chat(nodeWeapon);
	
	local sWeaponEffects = "";
	
	if DB.getValue(nodeWeapon, "weffect_ablating_use", 0) == 1 then
		sWeaponEffects = Interface.getString("weapon_property_effect_ablating");
	end
	if DB.getValue(nodeWeapon, "weffect_armorpiercing_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_armorpiercing");
	end
	if DB.getValue(nodeWeapon, "weffect_balanced_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_balanced");
	end
	if DB.getValue(nodeWeapon, "weffect_bleeding_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_bleeding") .. "(" .. DB.getValue(nodeWeapon, "bleeding_amount", 0) .. "%)";
	end
	if DB.getValue(nodeWeapon, "weffect_brawling_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_brawling");
	end
	if DB.getValue(nodeWeapon, "weffect_concealment_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_concealment");
	end
	if DB.getValue(nodeWeapon, "weffect_focus_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_focus") .. "(" .. DB.getValue(nodeWeapon, "focus_amount", 0) .. ")";
	end
	if DB.getValue(nodeWeapon, "weffect_grappling_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_grappling");
	end
	if DB.getValue(nodeWeapon, "weffect_greaterfocus_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_greaterfocus");
	end
	if DB.getValue(nodeWeapon, "weffect_improvedarmorpiercing_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_improvedarmorpiercing");
	end
	if DB.getValue(nodeWeapon, "weffect_longreach_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_longreach");
	end
	if DB.getValue(nodeWeapon, "weffect_meteorite_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_meteorite");
	end
	if DB.getValue(nodeWeapon, "weffect_nonethal_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_nonethal");
	end
	if DB.getValue(nodeWeapon, "weffect_slowreload_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_slowreload");
	end
	if DB.getValue(nodeWeapon, "weffect_stun_use", 0) == 1 then
		if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
		sWeaponEffects = sWeaponEffects .. Interface.getString("weapon_property_effect_stun") .. "(" .. DB.getValue(nodeWeapon, "stun_amount", 0) .. ")";
	end
	
	local aEnhancementNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "enhancementlist"));
	for _,v in ipairs(aEnhancementNodes) do
		local sEffect = DB.getValue(v, "effect", "");
		if sEffect ~= "" then
			-- look if effects already exists
			local sEffectName, sEffectSign, sEffectValue = sEffect:match("(%a+)%s*%((%-*)(%d+)%%*%)");
			-- keep sign for later
			if sEffectSign == nil then sEffectSign = ""; end
			
			if sEffectValue ~= nil and sEffectValue ~= "" and sWeaponEffects:find(sEffectName) then
				--look if we already have a similar effect with a specific value => stack values
				local sSign, sEffectOldValue, sPercent = sWeaponEffects:match(sEffectName.."%s*%((%-*)(%d+)(%%*)%)");
				if sSign == nil then sSign = ""; end
				local sEffectNewValue = tonumber(sSign..sEffectOldValue) + tonumber(sEffectSign..sEffectValue);
				if sPercent ~= nil and sEffectNewValue > 100 then
					sEffectNewValue = 100;
				end
				-- replace existing effect with new value
				sWeaponEffects = sWeaponEffects:gsub(sEffectName .. "%s*%(%-*%d+%%*%)", sEffectName.." (".. tostring(sEffectNewValue) .. sPercent .. sPercent ..")")
			elseif sWeaponEffects:find(sEffect) then
				-- similar effect exists and has no specific value to stack => do nothing
			else
				-- new effect => add to the list
				if sWeaponEffects ~= "" then sWeaponEffects = sWeaponEffects .. ", "; end
				sWeaponEffects = sWeaponEffects .. sEffect;
			end
		end
	end
	
	return sWeaponEffects;
end


-- get character and damage info for damage roll
-- param :
--	* nodeWeapon : dbNode for source weapon
-- returns : 
--	* rActor	 : actor info retrieved by using ActorManager.resolveActor
--	* rDamage	 : object containing all needed info to resolve damage (range, type, label, clauses)
function getWeaponDamageRollStructures(nodeWeapon)
	-- Retreive rActor
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);
	
	-- construct rDamage
	local rDamage = {};
	
	-- range or melee
	local bRanged = (DB.getValue(nodeWeapon, "type", 0) == 1);
	if bRanged then
		rDamage.range = "R";
	else
		rDamage.range = "M";
	end

	rDamage.type = "damage";
	rDamage.label = DB.getValue(nodeWeapon, "name", "");
	rDamage.sEffects = getWeaponEffects(nodeWeapon);
	
	-- compile all weapon damage entries
	rDamage.clauses = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local sDmgType = DB.getValue(v, "type", "");
		local aDmgDice = DB.getValue(v, "dice", {});
		local nDmgMod = DB.getValue(v, "bonus", 0);
		
		local sDmgAbility = DB.getValue(v, "dmgbonusstat", "");
		if sDmgAbility == "meleebonusdamage" then
			nDmgMod = nDmgMod + DB.getValue(nodeChar, "attributs.meleebonusdamage", 0);
		elseif sDmgAbility == "punch" or sDmgAbility == "kick" then
			-- todo
		end
		
		table.insert(rDamage.clauses, {	dice = aDmgDice, 
										modifier = nDmgMod, 
										stat = sDmgAbility, 
										dmgtype = sDmgType, });
	end
	
	return rActor, rDamage;
end

-- get character and damage info for damage roll
-- param :
--	* nodeChar	: dbNode for character
--  * sType		: "punch" or "kick"
-- returns : 
--	* rActor	: actor info retrieved by using ActorManager.resolveActor
--	* rDamage	: object containing all needed info to resolve damage (range, type, label, clauses)
function getUnarmedDamageRollStructures(nodeChar, sType)
	-- Retreive rActor
	local rActor = ActorManager.getActor("pc", nodeChar);
	
	-- construct rDamage
	local rDamage = {};
	
	-- range or melee
	rDamage.range = "M";
	
	rDamage.type = "damage";
	rDamage.label = sType;
	
	-- compile all weapon damage entries
	rDamage.clauses = {};
	
	local unarmedNode = DB.getValue(nodeChar, "attributs."..sType, "");
	
	local sDmgType = "";
	local aDmgDice = DB.getValue(nodeChar, "attributs."..sType, "");
	local nDmgMod = DB.getValue(nodeChar, "attributs."..sType.."_modifier", 0);
	
	table.insert(rDamage.clauses, {	dice = aDmgDice, 
									modifier = nDmgMod, 
									stat = "", 
									dmgtype = sDmgType, });
	
	return rActor, rDamage;
end

-- get NPC skill value
-- params :
--  * nodeActor : npc node
--  * skillName : skill to retreive
-- returns : 
--	* value	: value for skill, else 0
function getNPCSkillValue(nodeActor, skillName)
	-- Debug.chat("---- getNPCSkillValue");
	-- Debug.chat(string.lower(skillName));
	-- Debug.chat(nodeActor);
	-- Debug.chat("----");
	local value = 0;
	skillName = string.lower(skillName);
	-- Get the comma-separated strings
	local sSkills =  DB.getValue(nodeActor, "skills", 0);
	local aClauses, aClauseStats = StringManager.split(sSkills, ",;\r", true);
	
	-- Check each comma-separated string 
	for i = 1, #aClauses do
		-- Debug.chat(aClauses[i]);
		local nStarts, nEnds, sLabel, sSign, sMod = string.find(aClauses[i], "([%w%s/\(\)]*[%w\(\)]+)%s*([%+%--]?)(%d*)");
		
		-- remove space and put to lower case
		sLabel = string.lower(sLabel);
		sLabel = string.gsub(sLabel, "%s+", "") -- remove spaces
		sLabel = string.gsub(sLabel, "/", "") -- remove /
		-- Debug.chat(sLabel);
		-- there's a hack here for dodge /escape that may not be recognized because of '/'
		if sLabel == skillName then
			if nStarts then
				-- Calculate modifier based on mod value and sign value, if any
				if sMod ~= "" then
					value = tonumber(sMod) or 0;
					if sSign == "-" then
						value = 0 - value;
					end
				end
			end
			break;
		end
	end

	return value;
end

-- get total equipped EV (work for PC / NPC)
-- if actor is a witcher from the bear school => -2
-- params :
--  * nodeActor : pc or npc node
-- returns : 
--	* value	: value for total EV, else 0
function getTotalEV(nodeActor)
	local nTotalEV = 0;
	local armorlist = nodeActor.getChild("armorlist");
	if armorlist then
		for _,v in pairs(nodeActor.getChild("armorlist").getChildren()) do
			--Debug.chat("armor "..DB.getValue(v, "name", "").." : Eq="..DB.getValue(v, "equipped", "").." EV="..DB.getValue(v, "ev", ""));
			if (DB.getValue(v, "equipped", "") == 1) then
				nTotalEV = nTotalEV + DB.getValue(v, "ev", 0);
			end
		end
	end

	-- test if bear witcher
	if DB.getValue(nodeActor, "identite.profession", "") == Interface.getString("list_profession_witcher") then
		if DB.getValue(nodeActor, "identite.witcher_school", "") == Interface.getString("list_witcherschool_bear") then
			nTotalEV = nTotalEV - 2 ;
			if nTotalEV < 0 then
				nTotalEV = 0
			end
			Debug.console("EV -2 because of bear school advantage");
		end
	end

	return nTotalEV;
end

-- get encumbrance malus if any (work for PC / NPC)
-- params :
--  * nodeActor : pc or npc node
-- returns : 
--	* value	: encumbrance malus if any, else 0
function getEncumbranceMalus(nodeActor)
	local nEncMalus = 0;

	local encumbranceMax = DB.getValue(nodeActor, "attributs.encumbranceMax", 0);
	local encumbrance = DB.getValue(nodeActor, "attributs.encumbrance", 0);

	if (encumbrance > encumbranceMax) then
		local supp = encumbrance - encumbranceMax;
		nEncMalus = supp % 5;
	end
	
	return nEncMalus;
end

-- get armor value of a character for a given location roll (pc or npc)
-- params :
--  * nodeActor : pc or npc node
--  * sLocation : location roll value or "AIM_xxx" string for aimed attack
-- returns : 
--	* value	: armor value for given location
function getArmorValueForLocationRoll(nodeActor, sLocation)
	Debug.console("getArmorValueForLocationRoll called for sLocation="..sLocation);
	local nArmorValue = 0;

	sLocation = string.lower(sLocation);
	local sArmorLocation = sLocation;
	
	if sLocation=="arm" then
		sArmorLocation = "leftarm";
	elseif sLocation=="leg" or sLocation=="limb" then
		sArmorLocation = "leftleg";
	elseif sLocation=="tail" then
		sArmorLocation = "tail";
	end
	
	for _,v in ipairs(UtilityManager.getSortedTable(DB.getChildren(nodeActor, "armorlist"))) do
		if DB.getValue(v, "location_"..sArmorLocation, 0) == 1 then
			nArmorValue = nArmorValue + DB.getValue(v, "sp", 0);
		end
	end
	
	return nArmorValue;
end

-- remove 1 SP to armor after receiving damage for a given location (pc or npc)
-- params :
--  * nodeActor : pc or npc node
--  * sLocation : location roll value or "AIM_xxx" string for aimed attack
function damageArmorByLocation(nodeActor, sLocation)
	Debug.console("----- damageArmorByLocation called for sLocation="..sLocation);
	
	-- check automate armor damaging option, if "off" do nothing
	local sOptionADA = OptionsManager.getOption("ADA");
	if sOptionADA == "off" then
		return;
	end

	sLocation = string.lower(sLocation);
	local sArmorLocation = sLocation;
	
	if sLocation=="arm" then
		sArmorLocation = "leftarm";
	elseif sLocation=="leg" or sLocation=="limb" then
		sArmorLocation = "leftleg";
	elseif sLocation=="tail" then
		sArmorLocation = "tail";
	end
	
	for _,v in ipairs(UtilityManager.getSortedTable(DB.getChildren(nodeActor, "armorlist"))) do
		if DB.getValue(v, "location_"..sArmorLocation, 0) == 1 then
			local nArmorValue = DB.getValue(v, "sp", 0);
			if nArmorValue > 0 then
				DB.setValue(v, "sp", "number", nArmorValue-1);
				break;
			end
		end
	end
end


-- get damage multiplier modifier for a given location
-- params :
--  * nodeActor : pc or npc node
--  * sLocation : location roll value or "AIM_xxx" string for aimed attack
-- returns : 
--	* value	: damage multiplier modifier
function getDamageLocationModifierForLocationRoll(nodeActor, sLocation)
	local nMultiplier = 1;

	sLocation = string.lower(sLocation);

	-- get string location from nLocation
	if string.find(sLocation, "head") then
		nMultiplier = 3;
	elseif string.find(sLocation, "torso") then
		nMultiplier = 1;
	elseif string.find(sLocation, "arm") or string.find(sLocation, "leg") or string.find(sLocation, "tail") or string.find(sLocation, "limb")then
		nMultiplier = 0.5;
	end

	return nMultiplier;
end

-- to know if nodeActor is a monster or not (work for PC / NPC)
-- params :
--  * nodeActor : pc or npc node
-- returns : 
--	* bool : true if node is a monster, else false
function isMonster(nodeActor)
	local type = DB.getValue(nodeActor, "npctype", "");
	if type == "" or string.lower(type) == "humanoid" then
		return false;
	end
	return true;
end

-- to know if nodeActor is a monster without anatomy (elementa or specter)
-- params :
--  * nodeActor : pc or npc node
-- returns : 
--	* bool 
function isWithoutAnatomy(nodeActor)
	local type = DB.getValue(nodeActor, "npctype", "");
	if string.lower(type) == "specter" or string.lower(type) == "elementa" then
		return true;
	end
	return false;
end

function isSilverVulnerable(nodeActor)
	local bVulnerable = false;

	local sOptionMITN = OptionsManager.getOption("MITN");
	-- get actor type, default set to humanoid for the case of PC
	local type = string.lower(DB.getValue(nodeActor, "npctype", "humanoid")); 
	if sOptionMITN=="allmonsters" and string.lower(type) ~= "humanoid" then
		bVulnerable = true;
	elseif sOptionMITN=="novels" and (type==string.lower(Interface.getString("npc_type_cursed")) or type==string.lower(Interface.getString("npc_type_elementa")) or type==string.lower(Interface.getString("npc_type_necrophage")) or type==string.lower(Interface.getString("npc_type_relict")) or type==string.lower(Interface.getString("npc_type_specter")) or type==string.lower(Interface.getString("npc_type_vampire"))) then
		bVulnerable = true;
	end

	return bVulnerable;
end

function isMeteoriteVulnerable(nodeActor)
	local bVulnerable = false;

	local sOptionMITN = OptionsManager.getOption("MITN");
	-- get actor type, default set to humanoid for the case of PC
	local type = string.lower(DB.getValue(nodeActor, "npctype", "humanoid"));
	if sOptionMITN=="novels" and (type==string.lower(Interface.getString("npc_type_beast")) or type==string.lower(Interface.getString("npc_type_hybrid")) or type==string.lower(Interface.getString("npc_type_draconid")) or type==string.lower(Interface.getString("npc_type_insectoid")) or type==string.lower(Interface.getString("npc_type_ogroid"))) then
		bVulnerable = true;
	end

	return bVulnerable;
end

function getVulnerabilities(nodeActor, actorType)
	local sVulnerabilities = "";

	-- TODO hanged man venom vulnerability
	sVulnerabilities = string.lower(DB.getValue(nodeActor, "vulnerabilities", "")); 
	
	return sVulnerabilities;
end

function getResistances(nodeActor, actorType)
	local sResistances = "";
	
	-- get resistances from armor
	local armorlist = nodeActor.getChild("armorlist");
	if armorlist then
		for _,v in pairs(nodeActor.getChild("armorlist").getChildren()) do
			local sArmorRes = DB.getValue(v, "resistances", "");
			Debug.chat("armor ''"..DB.getValue(v, "name", "").."'' : Res="..sArmorRes);
			if sArmorRes ~= "" then
				if sResistances ~= "" then sResistances = sResistances .. ", " end;
				sResistances = sResistances .. DB.getValue(v, "ev", 0);
			end
		end
	end

	-- get natural resistance for npc
	sResistances = sResistances .. string.lower(DB.getValue(nodeActor, "resistances", "")); 

	return sResistances;
end

function isResistantTo(nodeActor, actorType, sDamageTypes)
	-- split damage type (exclude silver)
	local aTypes={};
	for str in string.gmatch(sDamageTypes, "([^,]+)") do
		-- trim
		str = string.lower(StringManager.trim(str));
		if str ~= "silver" then
			aTypes[str] = 1;
		end
	end

	-- check resistances
	local sResistances = getResistances(nodeActor, actorType);
	if sResistances ~= "" then
		for str in string.gmatch(sResistances, "([^,]+)") do
			-- trim & lower
			str = string.lower(StringManager.trim(str));
			if str ~= "silver" and aTypes[str]==1 then
				return true;
			end
		end
	end
end

function isVulnerableTo(nodeActor, actorType, sDamageTypes)
	-- split damage type (exclude silver)
	local aTypes={};
	for str in string.gmatch(sDamageTypes, "([^,]+)") do
		-- trim
		str = string.lower(StringManager.trim(str));
		if str ~= "silver" then
			aTypes[str] = 1;
		end
	end

	-- check vulnerabilities
	local sVulnerabilities = getVulnerabilities(nodeActor, actorType);
	if sVulnerabilities ~= "" then
		for str in string.gmatch(sVulnerabilities, "([^,]+)") do
			-- trim & lower
			str = string.lower(StringManager.trim(str));
			if str ~= "silver" and aTypes[str]==1 then
				return true;
			end
		end
	end
end