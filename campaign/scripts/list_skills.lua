-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sFocus = "name";

function onInit()
	addSkillsRoot();
end
	
function addSkillsRoot()
	local listattribut = {};

	for i, j in pairs(getWindows()) do
		local sLabel = j.name.getValue(); 
		local nType = j.type.getValue();    
        if nType == 0 then
            if not listattribut[sLabel] then
				listattribut[sLabel] = { j };
			else
				table.insert(listattribut[sLabel], j);
			end
		end
    end

	for k, t in pairs(SkillsTable.tbl_skills_root) do
		local matches = listattribut[t];

		if not matches then
			local newwin = createWindow();
			newwin.name.setValue(t);
			newwin.type.setValue(0);
			matches = { newwin };
			addSkills(t);
		end
	end
end

function addSkills(sCategorie)
	local listskill = {};

    for i, j in pairs(getWindows()) do
		local label = j.name.getValue(); 
		if SkillsTable.tbl_skills[sCategorie][label] then
			if not listskill[label] then
				listskill[label] = { j };
			else
				table.insert(listskill[label], j);
			end
		end
	end
	for k, t in pairs(SkillsTable.tbl_skills[sCategorie]) do
		local matches = listskill[k];
		if not matches then
			local newwin = createWindow();
			newwin.name.setValue(t);
			newwin.type.setValue(1);
			matches = { newwin };
		end
	end

end
