-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bParsed = false;
local aComponents = {};

-- The nDragMod and sDragLabel fields keep track of the entry under the cursor
local sDragLabel = nil;
local nDragMod = nil;
local bDragging = false;

function getCompletion(s)
	-- Find a matching completion for the given string
	for k,_ in pairs(DataCommon.skilldata) do
		if string.lower(s) == string.lower(string.sub(k, 1, #s)) then
			return string.sub(k, #s + 1);
		end
	end
	
	return "";
end

function parseComponents()
	aComponents = {};
	
	-- Get the comma-separated strings
	local aClauses, aClauseStats = StringManager.split(getValue(), ",;\r", true);
	
	-- Check each comma-separated string for a potential skill roll or auto-complete opportunity
	for i = 1, #aClauses do
		local nStarts, nEnds, sLabel, sSign, sMod = string.find(aClauses[i], "([%w%s/\(\)]*[%a\(\)]+)%s*([%+%--]?)(%d*)");
		if nStarts then
			-- Calculate modifier based on mod value and sign value, if any
			local nAllowRoll = 0;
			local nMod = 0;
			if sMod ~= "" then
				nAllowRoll = 1;
				nMod = tonumber(sMod) or 0;
				if sSign == "-" or sSign == "-" then
					nMod = 0 - nMod;
				end
			end

			-- Insert the possible skill into the skill list
			table.insert(aComponents, {nStart = aClauseStats[i].startpos, nLabelEnd = aClauseStats[i].startpos + nEnds, nEnd = aClauseStats[i].endpos, sLabel = sLabel, nMod = nMod, nAllowRoll = nAllowRoll });
		end
	end
	
	bParsed = true;
end

function onChar(nKeyCode)
	bParsed = false;
	
	local nCursor = getCursorPosition();
	local sValue = getValue();
	local sCompletion;
	
	-- If alpha character, then build a potential autocomplete
	if ((nKeyCode >= 65) and (nKeyCode <= 90)) or ((nKeyCode >= 97) and (nKeyCode <= 122)) then
		-- Parse the value string
		parseComponents();

		-- Build auto-complete for the current string
		for i = 1, #aComponents, 1 do
			if nCursor == aComponents[i].nLabelEnd then
				sCompletion = getCompletion(aComponents[i].sLabel);
				if sCompletion ~= "" then
					local sNewValue = sValue:sub(1, getCursorPosition()-1) .. sCompletion .. sValue:sub(getCursorPosition());
					setValue(sNewValue);
					setSelectionPosition(nCursor + #sCompletion);
				end

				return;
			end
		end

	-- Or else if space character, then finish the autocomplete
	else
		if ((nKeyCode == 32) and (nCursor >= 2)) then
			-- Parse the value string
			parseComponents();
			
			-- Find any string we may have just auto-completed
			local nLastCursor = nCursor - 1;
			for i = 1, #aComponents, 1 do
				if nCursor - 1 == aComponents[i].nLabelEnd then
					sCompletion = getCompletion(aComponents[i].sLabel);
					if sCompletion ~= "" then
						local sNewValue = string.sub(sValue, 1, nLastCursor - 1) .. sCompletion .. string.sub(sValue, nLastCursor);
						setValue(sNewValue);
						setCursorPosition(nCursor + #sCompletion);
						setSelectionPosition(nCursor + #sCompletion);
					end

					return;
				end
			end
		end
	end
end

-- Reset selection when the cursor leaves the control
function onHover(bOnControl)
	if bDragging or bOnControl then
		return;
	end

	sDragLabel = nil;
	nDragMod = nil;
	setSelectionPosition(0);
end

-- Hilight skill hovered on
function onHoverUpdate(x, y)
	if bDragging then
		return;
	end

	if not bParsed then
		parseComponents();
	end
	local nMouseIndex = getIndexAt(x, y);

	for i = 1, #aComponents, 1 do
		if aComponents[i].nAllowRoll == 1 then
			if aComponents[i].nStart <= nMouseIndex and aComponents[i].nEnd > nMouseIndex then
				setCursorPosition(aComponents[i].nStart);
				setSelectionPosition(aComponents[i].nEnd);

				sDragLabel = aComponents[i].sLabel;
				nDragMod = aComponents[i].nMod;
				setHoverCursor("hand");
				return;
			end
		end
	end
	
	sDragLabel = nil;
	nDragMod = nil;
	setHoverCursor("arrow");
end

function action(draginfo)
	if sDragLabel then
		local rActor = ActorManager.getActor("npc", window.getDatabaseNode());
		local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
		
		local sStat = "";
		local nStatMod = "";
		
		-- retreive associated stat
		for k,v in pairs(DataCommon.skilldata) do
			if string.lower(sDragLabel) == string.lower(k) then
				sStat = v.stat;
				break;
			end
		end
		
		-- retreive stat modifier
		if sStat == "Body" then
			nStatMod = DB.getValue(nodeActor, "attributs.body", 0);
		elseif sStat == "Craft" then
			nStatMod = DB.getValue(nodeActor, "attributs.crafting", 0);
		elseif sStat == "Empathy" then
			nStatMod = DB.getValue(nodeActor, "attributs.empathy", 0);
		elseif sStat == "Intelligence" then
			nStatMod = DB.getValue(nodeActor, "attributs.intelligence", 0);
		elseif sStat == "Reflex" then
			nStatMod = DB.getValue(nodeActor, "attributs.reflex", 0);
		elseif sStat == "Will" then
			nStatMod = DB.getValue(nodeActor, "attributs.will", 0);
		elseif sStat == "Dexterity" then
			nStatMod = DB.getValue(nodeActor, "attributs.dexterity", 0);
		else
			local msg = ChatManager.createBaseMessage(rActor, nil);
			msg.text = string.format(Interface.getString("npc_unknownskill_errormessage"), sDragLabel)
			Comm.deliverChatMessage(msg);
			return;
		end

		sDragLabel = sDragLabel .. " ("..sStat..")";
		nDragMod = nDragMod + nStatMod;
		ActionSkill.performRoll(draginfo, rActor, sDragLabel, nDragMod, sStat);
	end
end

function onDoubleClick(x, y)
	action();
	return true;
end

function onDragStart(button, x, y, draginfo)
	action(draginfo);

	bDragging = true;
	setCursorPosition(0);
	
	return true;
end

function onDragEnd(draginfo)
	bDragging = false;
end

-- Suppress default processing to support dragging
function onClickDown(button, x, y)
	return true;
end

-- On mouse click, set focus, set cursor position and clear selection
function onClickRelease(button, x, y)
	setFocus();
	
	local n = getIndexAt(x, y);
	setSelectionPosition(n);
	setCursorPosition(n);
	
	return true;
end
