-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _sRecordType;
local _sClass;
local _sRecord;

function getRecordType()
	return _sRecordType;
end
function setRecordType(v)
	DesktopManager.setDockButtonSizeAndPadding(100, 60, -10)
	_sRecordType = v;
	
	-- setStateText(0, LibraryData.getDisplayText(_sRecordType));
	setStateText(0, " ", " ", " ");
	sButtonName = "button_"..v;
	sButtonDownName = sButtonName.."_down";
	sButtonHoverName = sButtonName.."_down";
	setIcons(sButtonName, sButtonDownName, sButtonHoverName);
	setTooltipText(LibraryData.getDisplayText(_sRecordType));

end

function setData(sText, sClass, sRecord)
	_sClass = sClass;
	_sRecord = sRecord;
	setStateText(0, sText);
	setTooltipText(sText);
	
	sButtonName = "button_"..sClass:lower();
	sButtonDownName = sButtonName.."_down";
	sButtonHoverName = sButtonName.."_down";
	
	setIcons(sButtonName, sButtonDownName, sButtonHoverName);
end

function onButtonPress()
	if _sRecordType then
		DesktopManager.toggleIndex(_sRecordType);
	elseif _sClass then
		Interface.toggleWindow(_sClass, _sRecord);
	end
end

function onDragStart(button, x, y, draginfo)
	if _sRecordType then
		draginfo.setType("shortcut");
		draginfo.setIcon("button_link");
		local sClass, sRecord = DesktopManager.getListLink(_sRecordType);
		draginfo.setShortcutData(sClass, sRecord);
		draginfo.setDescription(getTooltipText());
		return true;
	elseif _sClass then
		draginfo.setType("shortcut");
		draginfo.setIcon("button_link");
		draginfo.setShortcutData(_sClass, _sRecord);
		draginfo.setDescription(getTooltipText());
		return true;
	end
end
