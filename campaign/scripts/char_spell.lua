-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_deletespell"), "delete", 5);
	registerMenuItem(Interface.getString("menu_deletespellconfirm"), "delete", 5, 3);
	
	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

-- radial menu : delete spell
function onMenuSelection(selection, subselection)
	if selection == 5 and subselection == 3 then
		local node = getDatabaseNode();
		if node then
			node.delete();
		else
			close();
		end
	end
end

local m_sClass = "";
local m_sRecord = "";

-- function onLinkChanged()
	-- local node = getDatabaseNode();
	-- local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	-- if sClass ~= m_sClass or sRecord ~= m_sRecord then
		-- m_sClass = sClass;
		-- m_sRecord = sRecord;
		
		-- local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		-- if sRecord:sub(1, #sInvList) == sInvList then
			-- carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		-- end
	-- end
-- end

function onDataChanged()
	--onLinkChanged();
	--onDamageChanged();
	
-- 	local bRanged = (type.getValue() == 1);
-- 	-- Ranged specific fields
-- 	label_range.setVisible(bRanged);
-- 	rangeincrement.setVisible(bRanged);
-- 	label_ammo.setVisible(bRanged);
-- 	maxammo.setVisible(bRanged);
-- 	ammocounter.setVisible(bRanged);
-- 	-- Attack actions
-- 	button_melee_strongattack.setVisible(not bRanged);
-- 	button_melee_fastattack.setVisible(not bRanged);
-- 	button_melee_attack.setVisible(not bRanged);
-- 	button_range_strongattack.setVisible(bRanged);
-- 	button_range_fastattack.setVisible(bRanged);
-- 	button_range_attack.setVisible(bRanged);
-- 	-- Defense actions
-- 	button_melee_parry.setVisible(not bRanged);
-- 	button_melee_block.setVisible(not bRanged);
-- 	spacer_for_ranged_defense.setVisible(bRanged);
 end

-- function onDamageChanged()
-- 	local nodeWeapon = getDatabaseNode();
-- 	local nodeChar = nodeWeapon.getChild("...")
-- 	local rActor = ActorManager.getActor("pc", nodeChar);
-- 	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	
	
-- 	local aDamage = {};
-- 	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
-- 	for _,v in ipairs(aDamageNodes) do
-- 		local aDice = DB.getValue(v, "dice", {});
-- 		local nMod = DB.getValue(v, "bonus", 0);

-- 		local sAbility = DB.getValue(v, "dmgbonusstat", "");
-- 		if (sAbility == "meleebonusdamage") then
-- 			nMod = nMod + DB.getValue(nodeActor, "attributs.meleebonusdamage", 0);
-- 		elseif (sAbility == "punch") then
-- 			-- todo get punch bonus modifier
-- 		elseif (sAbility == "kick") then
-- 			-- todo get kick bonus modifier
-- 		end
		
-- 		if #aDice > 0 or nMod ~= 0 then
-- 			local sDamage = StringManager.convertDiceToString(DB.getValue(v, "dice", {}), nMod);
-- 			local sType = DB.getValue(v, "type", "");
-- 			if sType ~= "" then
-- 				sDamage = sDamage .. " " .. sType;
-- 			end
-- 			table.insert(aDamage, sDamage);
-- 		end
-- 	end

-- 	damageview.setValue(table.concat(aDamage, "\n+ "));
-- end

-- function onDamageAction(draginfo)
-- 	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(getDatabaseNode());
	
-- 	ActionDamage.performRoll(draginfo, rActor, rDamage);
-- 	return true;
-- end
