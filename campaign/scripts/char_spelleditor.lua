-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local sSpellType = "";
	local parentNode = getDatabaseNode().getParent().getParent();
	if not parentNode then
		-- link from spell module
		parentNode = getDatabaseNode();
	end

	local nSpellType = DB.getValue(parentNode, "type", -1);

	if (nSpellType == 0) then
		sSpellType = "mage";
	elseif (nSpellType == 1) then
		sSpellType = "hex";
	elseif (nSpellType == 2) then
		sSpellType = "ritual";
	elseif (nSpellType == 3) then
		sSpellType = "priest";
	elseif (nSpellType == 4) then
		sSpellType = "sign";
	end

	if (sSpellType == "mage") then
		level.setVisible(true);
		levellabel.setVisible(true);
		element.setVisible(true);
		elementlabel.setVisible(true);
		range.setVisible(true);
		rangelabel.setVisible(true);
		duration.setVisible(true);
		durationlabel.setVisible(true);
		defense.setVisible(true);
		defenselabel.setVisible(true);
		preptime.setVisible(false);
		preptimelabel.setVisible(false);
		dc.setVisible(false);
		dclabel.setVisible(false);
		components.setVisible(false);
		componentslabel.setVisible(false);
		danger.setVisible(false);
		dangerlabel.setVisible(false);
		reqlift.setVisible(false);
		reqliftlabel.setVisible(false);
	elseif (sSpellType == "hex") then
		level.setVisible(false);
		levellabel.setVisible(false);
		element.setVisible(false);
		elementlabel.setVisible(false);
		range.setVisible(false);
		rangelabel.setVisible(false);
		duration.setVisible(false);
		durationlabel.setVisible(false);
		defense.setVisible(false);
		defenselabel.setVisible(false);
		preptime.setVisible(false);
		preptimelabel.setVisible(false);
		dc.setVisible(false);
		dclabel.setVisible(false);
		components.setVisible(false);
		componentslabel.setVisible(false);
		danger.setVisible(true);
		dangerlabel.setVisible(true);
		reqlift.setVisible(true);
		reqliftlabel.setVisible(true);
	elseif (sSpellType == "ritual") then
		level.setVisible(true);
		levellabel.setVisible(true);
		element.setVisible(false);
		elementlabel.setVisible(false);
		range.setVisible(false);
		rangelabel.setVisible(false);
		duration.setVisible(true);
		durationlabel.setVisible(true);
		defense.setVisible(false);
		defenselabel.setVisible(false);
		preptime.setVisible(true);
		preptimelabel.setVisible(true);
		dc.setVisible(true);
		dclabel.setVisible(true);
		components.setVisible(true);
		componentslabel.setVisible(true);
		danger.setVisible(false);
		dangerlabel.setVisible(false);
		reqlift.setVisible(false);
		reqliftlabel.setVisible(false);
	elseif (sSpellType == "priest") then
		level.setVisible(true);
		levellabel.setVisible(true);
		element.setVisible(false);
		elementlabel.setVisible(false);
		range.setVisible(true);
		rangelabel.setVisible(true);
		duration.setVisible(true);
		durationlabel.setVisible(true);
		defense.setVisible(true);
		defenselabel.setVisible(true);
		preptime.setVisible(false);
		preptimelabel.setVisible(false);
		dc.setVisible(false);
		dclabel.setVisible(false);
		components.setVisible(false);
		componentslabel.setVisible(false);
		danger.setVisible(false);
		dangerlabel.setVisible(false);
		reqlift.setVisible(false);
		reqliftlabel.setVisible(false);
	elseif (sSpellType == "sign") then
		level.setVisible(false);
		levellabel.setVisible(false);
		element.setVisible(true);
		elementlabel.setVisible(true);
		range.setVisible(true);
		rangelabel.setVisible(true);
		duration.setVisible(true);
		durationlabel.setVisible(true);
		defense.setVisible(true);
		defenselabel.setVisible(true);
		preptime.setVisible(false);
		preptimelabel.setVisible(false);
		dc.setVisible(false);
		dclabel.setVisible(false);
		components.setVisible(false);
		componentslabel.setVisible(false);
		danger.setVisible(false);
		dangerlabel.setVisible(false);
		reqlift.setVisible(false);
		reqliftlabel.setVisible(false);
	end
end

function onClose()
	
end

function onDrop(x, y, draginfo)
	local sDragType = draginfo.getType();
	
	if sDragType == "dice" then
		local w = list.addEntry(true);
		for _, vDie in ipairs(draginfo.getDieList()) do
			w.dice.addDie(vDie.type);
		end
		return true;
	elseif sDragType == "number" then
		local w = list.addEntry(true);
		w.bonus.setValue(draginfo.getNumberData());
		return true;
	end
end

