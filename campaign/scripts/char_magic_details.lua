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
	if selection == 3 then
		addSpellClass();
	end
end

function addSpellClass()
	local w = spellclasslist.createWindow();
	-- if w then
	-- 	w.name.setFocus();
	-- end
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

-- function onHeaderClickDown()
-- 	--Debug.chat("onHeaderClickDown");
-- 	return true;
-- end

-- function onHeaderClickRelease(listName)
-- 	--Debug.chat("onHeaderClickRelease");
-- 	if listName=="weapon" then
-- 		weaponlist.setVisible(not weaponlist.isVisible());
-- 	elseif listName=="armor" then
-- 		armorlist.setVisible(not weaponlist.isVisible());
-- 	end
	
-- 	return true;
-- end


-- function onUnarmedDamageAction(draginfo, sType)
-- 	local rActor, rDamage = CharManager.getUnarmedDamageRollStructures(getDatabaseNode(), sType);
	
-- 	ActionDamage.performRoll(draginfo, rActor, rDamage);
-- 	return true;
-- end