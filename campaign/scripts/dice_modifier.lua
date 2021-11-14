-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local emptymodifierWidget = nil;
local modifierWidget = nil;
local modifierFieldNode = nil;

function getModifier()
	if not modifierFieldNode then
		return 0;
	end
	
	return modifierFieldNode.getValue();
end

function setModifier(value)
	if modifierFieldNode then
		modifierFieldNode.setValue(value);
	end
end

function setModifierDisplay(value)
	if value > 0 then
		modifierWidget.setText("+" .. value);
	else
		modifierWidget.setText(value);
	end
	
	if value == 0 then
		modifierWidget.setVisible(false);
		if showemptywidget then
			emptymodifierWidget.setVisible(true);
		else
			emptymodifierWidget.setVisible(false);
		end
	else
		modifierWidget.setVisible(true);
		emptymodifierWidget.setVisible(false);
	end
end

function updateModifier(source)
	if modifierFieldNode then
		setModifierDisplay(modifierFieldNode.getValue());
	end
end

function onInit()
	local widgetsize = "small";
	if modifiersize then
		widgetsize = modifiersize[1];
	end
	
	if widgetsize == "mini" then
		modifierWidget = addTextWidget("sheetlabelmini", "0");
		modifierWidget.setFrame("tempmodmini", 3, 1, 6, 3);
		modifierWidget.setPosition("topright", 3, 1);
		modifierWidget.setVisible(false);
	else
		modifierWidget = addTextWidget("sheettext-light", "0");
		modifierWidget.setFrame("tempmodbase", 6, 3, 8, 5);
		modifierWidget.setPosition("topright", 0, 0);
		modifierWidget.setVisible(false);
	end
	
	emptymodifierWidget = addBitmapWidget("tempmod");
	emptymodifierWidget.setPosition("topright", 0, 0);
	
	-- By default, the modifier is in a field named based on the parent control.
	local modifierFieldName = getName() .. "modifier";
	if modifierfield then
		-- Use a <modifierfield> override
		modifierFieldName = modifierfield[1];
	end
	
	modifierFieldNode = window.getDatabaseNode().createChild(modifierFieldName, "number");
	if modifierFieldNode then
		modifierFieldNode.onUpdate = updateModifier;
		addSource(modifierFieldName, "+");

		updateModifier(modifierFieldNode);
	end
	
	super.onInit();
end

function onWheel(notches)
	if not Input.isControlPressed() then
		return false;
	end

	setModifier(getModifier() + notches);
	return true;
end

function addSource(name, sType)
	if not sType then
		sType = "number";
	end
	local node = window.getDatabaseNode().createChild(name, sType);
	-- if node then
	--	sources[name] = node;
	--	node.onUpdate = sourceUpdate;
	--	hasSources = true;
	-- end
end
function addSourceWithOp(name, op)
	addSource(name, "number");
	ops[name] = op;
end

-- NOTE: Removed onDrop feature, since this was accidentally being done and the Control+Wheel option was not obvious
-- function onDrop(x, y, draginfo)
	-- if draginfo.getType() == "number" then
		-- setModifier(draginfo.getNumberData());
		-- return true;
	-- end
-- end
