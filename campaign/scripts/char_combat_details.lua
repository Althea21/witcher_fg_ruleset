-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_addweapon"), "insert", 3);
	registerMenuItem(Interface.getString("menu_addarmor"), "insert", 4);
	
	updateAbility();
	update();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "attributs"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "armorlist"), "onChildUpdate", updateAbility);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "attributs"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "armorlist"), "onChildUpdate", updateAbility);
end

function onMenuSelection(selection)
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	if not bReadOnly then
		if selection == 3 then
			addWeapon();
		elseif selection == 4 then
			addArmor();
		end
	else
		-- TODO message in chat box
	end
end

function addWeapon()
	local w = weaponlist.createWindow();
	if w then
		w.name.setFocus();
	end
end

function addArmor()
	local w = armorlist.createWindow();
	if w then
		w.name.setFocus();
	end
end

local bUpdateLock = false;
function updateAbility()
	if bUpdateLock then
		return;
	end
	bUpdateLock = true;
	for _,v in pairs(weaponlist.getWindows()) do
		v.onDataChanged();
	end
	bUpdateLock = false;
end

function update()
	weaponlist.update();
	armorlist.update();
end

function getEditMode()
	return (parentcontrol.window.actions_iedit.getValue() == 1);
end

function onHeaderClickDown()
	--Debug.chat("onHeaderClickDown");
	return true;
end

function onHeaderClickRelease(listName)
	--Debug.chat("onHeaderClickRelease");
	if listName=="weapon" then
		weaponlist.setVisible(not weaponlist.isVisible());
	elseif listName=="armor" then
		armorlist.setVisible(not armorlist.isVisible());
	end
	
	return true;
end


function onUnarmedDamageAction(draginfo, sType)
	local rActor, rDamage = CharManager.getUnarmedDamageRollStructures(getDatabaseNode(), sType);
	
	ActionDamage.performRoll(draginfo, rActor, rDamage);
	return true;
end