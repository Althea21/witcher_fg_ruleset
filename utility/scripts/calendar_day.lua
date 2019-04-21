-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function setState(bCurrDay, bSelDay, bHoliday, nodeEvent)
	if bCurrDay then
		setBackColor("98856C");
		label_day.setColor("000000");
	else
		setBackColor();
		if bHoliday then
			label_day.setColor("b88455");
		else
			label_day.setColor("98856C");
		end
	end
	if bSelDay then
		setFrame("calendarhighlight");
	else
		setFrame(nil);
	end
	if bHoliday then
		label_day.setFont("calendarday-bi");
		label_day.setUnderline(true);
	else
		label_day.setFont("calendarday");
		label_day.setUnderline(false);
	end
	if nodeEvent then
		local sText = DB.getText(nodeEvent, "logentry");
		local bText = (sText ~= "");
		local sGMText = DB.getText(nodeEvent, "gmlogentry");
		local bGMText = (sGMText ~= "");
		
		if User.isHost() then
			icon_event.setVisible(bText);
			if bText then
				icon_gmevent.setVisible(bGMText);
			else
				icon_gmevent.setVisible(true);
			end
		else
			icon_event.setVisible(bText);
		end

		if User.isHost() then
			resetMenuItems();
			registerMenuItem(Interface.getString("calendar_menu_eventdelete"), "delete", 6);
			registerMenuItem(Interface.getString("calendar_menu_eventdeleteconfirm"), "delete", 6, 7);
		end
	else
		icon_gmevent.setVisible(false);
		icon_event.setVisible(false);
		resetMenuItems();
	end
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		local nDay = day.getValue();
		if nDay > 0 then
			local nMonth = windowlist.window.month.getValue();
			windowlist.window.windowlist.window.removeLogEntry(nMonth, nDay);
		end
	end
end
