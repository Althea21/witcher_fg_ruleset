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

-- radial menu : delete weapon
function onMenuSelection(selection, subselection)
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

function addSpell()
	local w = spelllist.createWindow();
	-- if w then
	-- 	w.name.setFocus();
	-- end
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

