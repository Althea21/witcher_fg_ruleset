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
	local nodeRecord = getDatabaseNode().getParent().getParent().getParent().getParent();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	if not bReadOnly then
		if selection == 5 and subselection == 3 then
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
 end