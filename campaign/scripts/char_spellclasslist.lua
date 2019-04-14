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
	return CharManager.onActionDrop(draginfo, window.getDatabaseNode());
end
