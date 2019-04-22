-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);
end

function onListChanged()
	DB.removeHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);

	update();
end

function onChildAdded()
	update();
end

function update()
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function onDrop(x, y, draginfo)
	--Debug.chat("spellclasslist onDrop");
	local winLevel = getWindowAt(x, y);
	if not winLevel then
		return false;
	end

	if draginfo.isType("spelldesc") then
		local node = winLevel.getDatabaseNode();
		
		if node then
			local nodeSource = draginfo.getDatabaseNode();
			if DB.getValue(node, "type") ==DB.getValue(nodeSource, "type") then
				local nodeNew = addSpell(nodeSource, node);
			else
				ChatManager.SystemMessage(Interface.getString("spell_droptargeterror"));
			end
		end
		
		return true;
	end
	
	return CharManager.onActionDrop(draginfo, window.getDatabaseNode());
end

function addSpell(nodeSource, nodeSpellClass)
	-- Validate
	if not nodeSource or not nodeSpellClass then
		return nil;
	end
	
	-- Create the new spell entry
	local nodeTarget  = nodeSpellClass.getChild("spelllist");
	if not nodeTarget then
		return nil;
	end
	local nodeNewSpell = nodeTarget.createChild();
	if not nodeNewSpell then
		return nil;
	end
	
	-- Copy the spell details over
	DB.copyNode(nodeSource, nodeNewSpell);
	
	return nodeNewSpell;
end