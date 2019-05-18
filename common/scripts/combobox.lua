-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bReadOnly = false;

local bActive = false;
local aItems = {};
local aOrderedItems = {};

local sButtonIcon = "combobox_button";
local sButtonIconActive = "combobox_button_active";
local nButtonW = 15;
local nButtonH = 10;
local offsetButton = { x = 0, y = 0 };
local ctrlButton = nil;

local sListDirection = nil;
local DEFAULT_LIST_OFFSET_Y = 5;
local offsetList = { x = 0, y = DEFAULT_LIST_OFFSET_Y };
local sListFont = "combobox";
local sListSelectedFont = "comboboxselected";
local sListFrame = "";
local sListSelectedFrame = "rowshade";
local nListMaxSize = 0;
local ctrlList = nil;

local ctrlScroll = nil;

local wListItemSelected = nil;

function onInit()
	-- Read button parameters
	if buttonoffset then
		local sOffset = buttonoffset[1];
		local nComma = string.find(sOffset, ",");
		if nComma then
			offsetButton.x = tonumber(string.sub(sOffset, 1, nComma-1)) or 0;
			offsetButton.y = tonumber(string.sub(sOffset, nComma+1)) or 0;
		end
	end
	
	-- Read list parameters
	if listdirection and listdirection[1] == "up" then
		sListDirection = "up";
	end
	if listdirection and listdirection[1] == "down" then
		sListDirection = "down";
	end
	if listoffset then
		local sPosition = listoffset[1];
		local nComma = string.find(sPosition, ",");
		if nComma then
			offsetList.x = tonumber(string.sub(sPosition, 1, nComma-1)) or 0;
			offsetList.y = tonumber(string.sub(sPosition, nComma+1)) or DEFAULT_LIST_OFFSET_Y;
		else
			offsetList.y = tonumber(string.sub(sPosition, nComma+1)) or DEFAULT_LIST_OFFSET_Y;
		end
	end
	if listfonts then
		sListFont = listfonts[1].normal[1] or "";
		if type(sListFont) ~= "string" then sListFont = ""; end
		sListSelectedFont = listfonts[1].selected[1] or "";
		if type(sListSelectedFont) ~= "string" then sListSelectedFont = ""; end
	end
	if listframes then
		sListFrame = listframes[1].normal[1] or "";
		if type(sListFrame) ~= "string" then sListFrame = ""; end
		sListSelectedFrame = listframes[1].selected[1] or "";
		if type(sListSelectedFrame) ~= "string" then sListSelectedFrame = ""; end
	end
	if listmaxsize then
		nListMaxSize = tonumber(listmaxsize[1]) or 0;
	end
	
	-- Initialize button icon
	local sName = getName() or "";
	if (sName or "") ~= "" then
		local sButton = sName .. "_cbbutton";
		ctrlButton = window.createControl("combobox_button", sButton);
		ctrlButton.setTarget(sName);
		ctrlButton.setAnchor("right", sName, "right", "absolute", offsetButton.x);
		ctrlButton.setAnchor("top", sName, "center", "absolute", -(math.floor(nButtonH/2)) + offsetButton.y);
		ctrlButton.setIcon(sButtonIcon);
		ctrlButton.setVisible(isVisible());
	end

	-- Determine if underlying node is read only (only applies to stringfield version)
	local node = getDatabaseNode();
	if node and (node.isReadOnly() or not node.isOwner()) then
		setComboBoxReadOnly(true);
	else
		refreshDisplay();
	end
end

function onDestroy()
	if ctrlButton then
		ctrlButton.destroy();
		ctrlButton = nil;
	end
	if ctrlList then
		ctrlList.destroy();
		ctrlList = nil;
	end
	if ctrlScroll then
		ctrlScroll.destroy();
		ctrlScroll = nil;
	end
end

function onClickDown(...)
	if not bReadOnly then
		return true;
	end
end

function onClickRelease(button, x, y)
	if not bReadOnly then
		return activate(button);
	end
end

function activate(button)
	if button == 1 or bActive then
		toggle();
	end
	return true;
end

function isComboBoxReadOnly()
	return bReadOnly;
end

function setComboBoxReadOnly(bState)
	if bReadOnly == bState then
		return;
	end
	
	bReadOnly = bState;
	if bReadOnly and bActive then
		toggle();
	end
	refreshDisplay();
end

function setComboBoxVisible(bState)
	if bState == isVisible() then
		return;
	end
	
	setVisible(bState);
	refreshDisplay();
end

function refreshDisplay()
	local bVisible = isVisible();
	
	if not bVisible and bActive then
		hideList();
	end
	
	if ctrlButton then
		ctrlButton.setVisible(not bReadOnly and bVisible);
	end
	
	if frame and frame[1] and type(frame[1]) == "table" and frame[1].hidereadonly and frame[1].name and frame[1].name[1] then
		if bReadOnly then
			setFrame("");
		else
			local aOffsets = {};
			if frame[1].offset and frame[1].offset[1] then
				aOffsets = StringManager.split(frame[1].offset[1], ",", true);				
			end
			if #aOffsets == 4 then
				setFrame(frame[1].name[1], aOffsets[1], aOffsets[2], aOffsets[3], aOffsets[4]);
			else
				setFrame(frame[1].name[1]);
			end
		end
	end
end

function toggle(button)
	if bActive then
		hideList();
	else
		showList();
	end
	refresh();
end

function showList()
	-- Create the list if it does not exist
	local sName = getName() or "";
	if not ctrlList and (sName or "") ~= "" then
		local sList = sName .. "_cblist";
		local sListScroll = sName .. "_cblistscroll";
		local w,h = getSize();
		
		-- Create the list control
		if unsorted then
			ctrlList = window.createControl("combobox_list", sList);
		else
			ctrlList = window.createControl("combobox_list_sorted", sList);
		end
		ctrlList.setTarget(sName);
		ctrlList.setAnchor("left", sName, "left", "absolute", -(offsetList.x));
		ctrlList.setAnchor("right", sName, "right", "absolute", offsetList.x);
		if sListDirection == "up" then
			ctrlList.setAnchor("bottom", sName, "top", "absolute", -(offsetList.y));
			ctrlList.resetAnchor("top");
		else
			ctrlList.setAnchor("top", sName, "bottom", "absolute", offsetList.y);
			ctrlList.resetAnchor("bottom");
		end
		
		-- Set the list parameters
		ctrlList.setFonts(sListFont, sListSelectedFont);
		ctrlList.setFrames(sListFrame, sListSelectedFrame);
		ctrlList.setMaxRows(nListMaxSize);
		
		-- Populate the list
		for _,v in ipairs(aOrderedItems) do
			ctrlList.add(v, aItems[v]);
		end
		aOrderedItems = {};
		aItems = {};
		
		-- Create list scroll bar
		ctrlScroll = window.createControl("combobox_scrollbar", sListScroll);
		ctrlScroll.setAnchor("left", sList, "right", "absolute", -10);
		ctrlScroll.setAnchor("top", sList, "top");
		ctrlScroll.setAnchor("bottom", sList, "bottom");
		ctrlScroll.setTarget(sList);
	end

	-- Show the list if it exists
	if ctrlList then
		bActive = true;
		ctrlList.setVisible(true);
		ctrlList.setFocus(true);

		-- Scroll to the target value
		local sValue = getValue();
		setListValue(sValue);
		ctrlList.applySort(true);
		if wListItemSelected then
			ctrlList.scrollToWindow(wListItemSelected);
		end
	end
end

function hideList()
	bActive = false;

	if ctrlList then
		ctrlList.setVisible(false);
	end
end

function refresh(bActiveParam)
	if ctrlButton then
		if bActive or bActiveParam then
			ctrlButton.setIcon(sButtonIconActive);
		else
			ctrlButton.setIcon(sButtonIcon);
		end
	end
end

function setListValue(sValue)
	if ctrlList then
		local wNewSelection = nil;
		for _,w in ipairs(ctrlList.getWindows()) do
			if w.Value.getValue() == sValue then
				wNewSelection = w;
				break;
			end
		end
		selectItem(wNewSelection);
	end
end

function getListValue()
	if wListItemSelected then
		return wListItemSelected.Value.getValue();
	end
	return "";
end

function selectItem(wNewSelection)
	if not ctrlList then
		return;
	end
	if wListItemSelected == wNewSelection then
		return;
	end
	
	if wListItemSelected then
		wListItemSelected.setSelected(false);
	end
	
	if wNewSelection then
		wNewSelection.setSelected(true);
	end
	wListItemSelected = wNewSelection;
	
	local sListValue = getListValue();
	if getValue() ~= sListValue then
		setValue(sListValue);
	end
end

function add(sValue, sText)
	if not sValue then
		return;
	end
	if type(sText) ~= "string" then 
		sText = sValue 
	end
	
	if type(sValue) == "string" then
		if ctrlList then
			ctrlList.add(sValue, sText);
		else
			if not aItems[sValue] then
				table.insert(aOrderedItems, sValue);
				aItems[sValue] = sText;
			end
		end
	end
end

function addItems(aList)
	for _,sValue in ipairs(aList) do
		add(sValue);
	end
end

function hasValue(sValue)
	if ctrlList then
		for _,w in ipairs(ctrlList.getWindows()) do
			if w.Value.getValue() == sValue then
				return true;
			end
		end
	else
		if aItems[sValue] then
			return true;
		end
	end
	return false;
end

function clear()
	if ctrlList then
		ctrlList.clear();
	end
	wListItemSelected = nil;
	aOrderedItems = {};
	aItems = {};
end

function getItems()
	if ctrlList then
		local aListItems = {};
		for _,w in pairs(ctrlList.getWindows()) do
			table.insert(aListItems, w.Value.getValue());
		end
		return aListItems;
	end
	return aItems;
end

function optionClicked(wNewSelection)
	if wNewSelection and wNewSelection.setSelected then
		selectItem(wNewSelection);
	end
	
	bActive = false;
	hideList();
	refresh();
end

