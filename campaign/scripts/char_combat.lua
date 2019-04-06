-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onRecoverAction()
	stamina_combat.setValue(stamina_combat.getValue()+recovery_combat.getValue());
	if stamina_combat.getValue() > staminamax_combat.getValue() then
		stamina_combat.setValue(staminamax_combat.getValue());
	end
end

-- function onHeaderClickDown()
-- 	return true;
-- end

-- function onHeaderClickRelease(listName)
-- 	if listName=="weapon" then
-- 		weaponlist.setVisible(not weaponlist.isVisible());
-- 	end
	
-- 	return true;
-- end
