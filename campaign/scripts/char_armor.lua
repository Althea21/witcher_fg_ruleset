-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_deletearmor"), "delete", 5);
	registerMenuItem(Interface.getString("list_menu_deletearmorconfirm"), "delete", 5, 4);
	
	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

-- radial menu : delete armor
function onMenuSelection(selection, subselection)
	if selection == 5 and subselection == 4 then
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

function onDataChanged()
	onLocationChanged();
end

function onLocationChanged()
	local nodeArmor = getDatabaseNode();
	local nodeChar = nodeArmor.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	
	
	local aLocation = {};
	if (DB.getValue(nodeArmor, "location_head", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_head_short"));
	end
	if (DB.getValue(nodeArmor, "location_torso", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_torso_short"));
	end
	if (DB.getValue(nodeArmor, "location_rightarm", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_rightarm_short"));
	end
	if (DB.getValue(nodeArmor, "location_leftarm", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_leftarm_short"));
	end
	if (DB.getValue(nodeArmor, "location_rightleg", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_rightleg_short"));
	end
	if (DB.getValue(nodeArmor, "location_leftleg", 0) == 1) then
		table.insert(aLocation, Interface.getString("char_armor_label_location_leftleg_short"));
	end
	
	locationview.setValue(table.concat(aLocation, " | "));
end

