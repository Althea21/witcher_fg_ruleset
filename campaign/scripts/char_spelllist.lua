-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);

	onModeChanged();
end

function onListChanged()
	DB.removeHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);

	update();
end

function onChildAdded()
	onModeChanged();
	update();
end

function onModeChanged()
end

function update()
	local nodeRecord = window.getDatabaseNode().getParent().getParent();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	for _,w in ipairs(getWindows()) do
		w.shortdescription.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
		--w.activatedetail.setEnabled(not bReadOnly);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function onDrop(x, y, draginfo)
	--Debug.chat("spelllist onDrop");
	return CharManager.onActionDrop(draginfo, window.getDatabaseNode());
end

