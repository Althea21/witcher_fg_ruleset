-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onFilter(w)
	local f = getFilter(w);
	if f == "" then
		w.windowlist.window.grantedpower.setVisible(true);
		return true;
	end
		
	w.windowlist.window.grantedpower.setVisible(false);
	w.windowlist.setVisible(true);
	if string.find(string.lower(w.name.getValue()), f, 0, true) then
		return true;
	end
	
	return false;
end
