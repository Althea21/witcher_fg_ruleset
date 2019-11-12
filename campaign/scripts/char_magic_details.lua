-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_addspellclass"), "insert", 3);
	
	updateAbility();
	update();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "attributs"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "spellclasslist"), "onChildUpdate", updateAbility);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "attributs"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "spellclasslist"), "onChildUpdate", updateAbility);
end

function onMenuSelection(selection)
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	if not bReadOnly then
		if selection == 3 then
			addSpellClass();
		end
	end
end

function addSpellClass()
	local w = spellclasslist.createWindow();
end

local bUpdateLock = false;
function updateAbility()
	if bUpdateLock then
		return;
	end
	bUpdateLock = true;
	for _,v in pairs(spellclasslist.getWindows()) do
		v.onDataChanged();
	end
	bUpdateLock = false;
end

function update()
	spellclasslist.update();
end

function getEditMode()
	return (parentcontrol.window.actions_iedit.getValue() == 1);
end
