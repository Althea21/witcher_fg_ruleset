-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() then
		-- Initiative menu entries
		registerMenuItem(Interface.getString("ct_menu_init"), "turn", 7);
		registerMenuItem(Interface.getString("ct_menu_initall"), "shuffle", 7, 8);
		registerMenuItem(Interface.getString("ct_menu_initnpc"), "mask", 7, 7);
		registerMenuItem(Interface.getString("ct_menu_initpc"), "portrait", 7, 6);
		registerMenuItem(Interface.getString("ct_menu_initclear"), "pointer_circle", 7, 4);

		-- Clear NPC menu entries
		registerMenuItem(Interface.getString("ct_menu_itemdelete"), "delete", 3);
		registerMenuItem(Interface.getString("ct_menu_itemdeletenonfriendly"), "delete", 3, 1);
		registerMenuItem(Interface.getString("ct_menu_itemdeletefoe"), "delete", 3, 3);

		-- Reset pending attacks
		registerMenuItem(Interface.getString("ct_menu_resetpendingattacks"), "erase", 5);
		
	end
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if button == 1 then
		Interface.openRadialMenu();
		return true;
	end
end

function onMenuSelection(selection, subselection, subsubselection)
	if User.isHost() then
		if selection == 7 then
			if subselection == 4 then
				CombatManager.resetInit();
			elseif subselection == 8 then
				CombatManager2.rollInit();
			elseif subselection == 7 then
				CombatManager2.rollInit("npc");
			elseif subselection == 6 then
				CombatManager2.rollInit("pc");
			end
		elseif selection == 3 then
			if subselection == 1 then
				clearNPCs();
			elseif subselection == 3 then
				clearNPCs(true);
			end
		elseif selection == 5 then
			CombatManager2.resetPendingAttacks();
		end
	end
end

function clearNPCs(bDeleteOnlyFoe)
	for _, vChild in pairs(window.list.getWindows()) do
		local sFaction = vChild.friendfoe.getStringValue();
		if bDeleteOnlyFoe then
			if sFaction == "foe" then
				vChild.delete();
			end
		else
			if sFaction ~= "friend" then
				vChild.delete();
			end
		end
	end
end
