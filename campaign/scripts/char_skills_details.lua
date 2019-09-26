-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
end

function onHeaderClickDown()
	--Debug.chat("onHeaderClickDown");
	return true;
end

function onHeaderClickRelease(listName)
	--Debug.chat("onHeaderClickRelease");
	if listName=="profession" then
		profession_details.setVisible(not profession_details.isVisible());
	elseif listName=="skills" then
		skilllist_details.setVisible(not skilllist_details.isVisible());
	end
	
	return true;
end

