-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_addspell"), "insert", 4);
	registerMenuItem(Interface.getString("menu_deletespellclass"), "delete", 5);
	registerMenuItem(Interface.getString("menu_deletespellclassconfirm"), "delete", 5, 3);
	
	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

function update()
	-- update locked/unlocked state (for npc only)
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sActorType ~= "pc" then
		local nodeRecord = getDatabaseNode();
		local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
		type.setEnabled(not bReadOnly);
		spelllist.update();
	end
end
-- radial menu : delete weapon
function onMenuSelection(selection, subselection)
	local nodeRecord = getDatabaseNode().getParent().getParent();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	if not bReadOnly then
		if selection == 4 then
			addSpell();
		elseif selection == 5 and subselection == 3 then
			local node = getDatabaseNode();
			if node then
				node.delete();
			else
				close();
			end
		end
	end
end

local m_sClass = "";
local m_sRecord = "";

function addSpell()
	local w = spelllist.createWindow();
end

function onDataChanged()
	local nType = (type.getValue());
	if nType==0 then
		-- mage spell class
		label_spellclass.setValue(Interface.getString("char_spellclass_mage"));
	elseif nType==1 then
		-- hexes spell class
		label_spellclass.setValue(Interface.getString("char_spellclass_hexes"));
	elseif nType==2 then
		-- ritual spell class
		label_spellclass.setValue(Interface.getString("char_spellclass_rituals"));
	elseif nType==3 then
		-- priest spell class
		label_spellclass.setValue(Interface.getString("char_spellclass_priest"));
	elseif nType==4 then
		-- signs spell class
		label_spellclass.setValue(Interface.getString("char_spellclass_signs"));
	end
end

