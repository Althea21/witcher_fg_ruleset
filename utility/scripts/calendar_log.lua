-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local aEvents = {};
local nSelMonth = 0;
local nSelDay = 0;

function onInit()
	DB.addHandler("calendar.log", "onChildUpdate", onEventsChanged);
	buildEvents();
	
	nSelMonth = currentmonth.getValue();
	nSelDay = currentday.getValue();

	onDateChanged();
end								

function onClose()
	DB.removeHandler("calendar.log", "onChildUpdate", onEventsChanged);
end

function buildEvents()
	aEvents = {};
	
	for _,v in pairs(DB.getChildren("calendar.log")) do
		local nYear = DB.getValue(v, "year", 0);
		local nMonth = DB.getValue(v, "month", 0);
		local nDay = DB.getValue(v, "day", 0);
		
		if not aEvents[nYear] then
			aEvents[nYear] = {};
		end
		if not aEvents[nYear][nMonth] then
			aEvents[nYear][nMonth] = {};
		end
		aEvents[nYear][nMonth][nDay] = v;
	end
end

local bEnableBuild = true;
function onEventsChanged(bListChanged)
	if bListChanged then
		if bEnableBuild then
			buildEvents();
			updateDisplay();
		end
	end
end

function setSelectedDate(nMonth, nDay)
	nSelMonth = nMonth;
	nSelDay = nDay;

	updateDisplay();
	list.scrollToCampaignDate();
end

function addLogEntryToSelected()
	addLogEntry(nSelMonth, nSelDay);
end

function addLogEntry(nMonth, nDay)
	local nYear = CalendarManager.getCurrentYear();
	
	local nodeEvent;
	if aEvents[nYear] and aEvents[nYear][nMonth] and aEvents[nYear][nMonth][nDay] then
		nodeEvent = aEvents[nYear][nMonth][nDay];
	elseif User.isHost() then
		local nodeLog = DB.createNode("calendar.log");
		bEnableBuild = false;
		nodeEvent = nodeLog.createChild();
		
		DB.setValue(nodeEvent, "epoch", "string", DB.getValue("calendar.current.epoch", ""));
		DB.setValue(nodeEvent, "year", "number", nYear);
		DB.setValue(nodeEvent, "month", "number", nMonth);
		DB.setValue(nodeEvent, "day", "number", nDay);
		bEnableBuild = true;

		onEventsChanged();
	end

	if nodeEvent then
		Interface.openWindow("advlogentry", nodeEvent);
	end
end

function removeLogEntry(nMonth, nDay)
	local nYear = CalendarManager.getCurrentYear();
	
	if aEvents[nYear] and aEvents[nYear][nMonth] and aEvents[nYear][nMonth][nDay] then
		local nodeEvent = aEvents[nYear][nMonth][nDay];
		
		local bDelete = false;
		if User.isHost() then
			bDelete = true;
		end
		
		if bDelete then
			nodeEvent.delete();
		end
	end
end

function onSetButtonPressed()
	if User.isHost() then
		CalendarManager.setCurrentDay(nSelDay);
		CalendarManager.setCurrentMonth(nSelMonth);
	end
end

function onDateChanged()
	updateDisplay();
	list.scrollToCampaignDate();
end

function onYearChanged()
	list.rebuildCalendarWindows();
	onDateChanged();
end

function onCalendarChanged()
	list.rebuildCalendarWindows();
	setSelectedDate(currentmonth.getValue(), currentday.getValue());
end

function updateDisplay()
	local sCampaignEpoch = currentepoch.getValue();
	local nCampaignYear = currentyear.getValue();
	local nCampaignMonth = currentmonth.getValue();
	local nCampaignDay = currentday.getValue();
	
	local sDate = CalendarManager.getDateString(sCampaignEpoch, nCampaignYear, nCampaignMonth, nCampaignDay, true, true);
	viewdate.setValue(sDate);

	if aEvents[nCampaignYear] and 
			aEvents[nCampaignYear][nSelMonth] and 
			aEvents[nCampaignYear][nSelMonth][nSelDay] then
		button_view.setVisible(true);
		button_addlog.setVisible(false);
	else
		button_view.setVisible(false);
		button_addlog.setVisible(true);
	end
	
	for _,v in pairs(list.getWindows()) do
		local nMonth = v.month.getValue();

		local bCampaignMonth = false;
		local bLogMonth = false;
		if nMonth == nCampaignMonth then
			bCampaignMonth = true;
		end
		if nMonth == nSelMonth then
			bLogMonth = true;
		end
			
		if bCampaignMonth then
			v.label_period.setColor("b88455");
		else
			v.label_period.setColor("98856C");
		end
		
		for _,y in pairs(v.list_days.getWindows()) do
			local nDay = y.day.getValue();
			if nDay > 0 then
				local nodeEvent = nil;
				if aEvents[nCampaignYear] and aEvents[nCampaignYear][nMonth] and aEvents[nCampaignYear][nMonth][nDay] then
					nodeEvent = aEvents[nCampaignYear][nMonth][nDay];
				end
				
				local bHoliday = CalendarManager.isHoliday(nMonth, nDay);
				local bCurrDay = (bCampaignMonth and nDay == nCampaignDay);
				local bSelDay = (bLogMonth and nDay == nSelDay);
				
				y.setState(bCurrDay, bSelDay, bHoliday, nodeEvent);
			end
		end
	end
end
