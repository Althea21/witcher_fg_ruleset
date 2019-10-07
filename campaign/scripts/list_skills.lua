-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sFocus = "name";

function onInit()
	addSkills();
	initSkills();
end
	
-- DEPRECATED
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

function addSkills()
	local effectiveSkillNumber = 52;
	local listskill = {};

	local rActor = ActorManager.resolveActor(window.getDatabaseNode());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	local class = DB.getValue(nodeActor, "identite.profession", "");
	
	-- existing skills in character record
	local count = 0;
	for k, v in pairs(getWindows()) do
		local id = v.id.getValue();
		
		if (id and SkillsTable.tbl_flat_skills[id]) then
			if not listskill[id] then
				listskill[id] = v;
				count = count + 1;
			end
		else
			-- old node delete
			v.getDatabaseNode().delete();
		end
	end
	
	for k, v in pairs(SkillsTable.tbl_flat_skills) do
		local newwin;
		local matches = listskill[k];
		if not matches then
			-- add missing skills if needed
			newwin = createWindow();
			newwin.id.setValue(k);
			newwin.skill_stat.setStringValue(v[1]);
		else
			newwin = matches;
		end

		local localeId = "char_skill_"..k.."_label";
		newwin.name.setValue(Interface.getString(localeId));

		localeId = "char_skill_"..k.."_desc";
		newwin.skill_desc.setValue(Interface.getString(localeId));
		
		if v[2] then
			newwin.isDoubleIP.setValue(1);
		else
			newwin.isDoubleIP.setValue(0);
		end

		if v[3] then
			newwin.isArmorImpacted.setValue(1);
		else
			newwin.isArmorImpacted.setValue(0);
		end

		local classSkillFor = v[4];
		if string.match(classSkillFor, class) then
			newwin.isClassSkill.setValue(1);
		else
			newwin.isClassSkill.setValue(0);
		end

	end
end

function initSkills()
	for k, v in pairs(getWindows()) do
		-- double IP
		if (v.isDoubleIP.getValue()==1) then
			v.skill_doubleIPLabel.setVisible(true);
		end

		-- Armor EV impacted
		if (v.isArmorImpacted.getValue()==1) then
			v.skill_armorwidget.setIcon("char_armorcheck");
			v.skill_armorwidget.setTooltipText(Interface.getString("char_tooltip_skillarmorimpacted"));
		else
			v.skill_armorwidget.setIcon(nil);
			v.skill_armorwidget.setTooltipText("");
		end

		-- class Skill
		if (v.isClassSkill.getValue()==1) then
			v.name.setFont("sheettext-alt");--sheettextbold
		end
	end
end

function onSortCompare(w1, w2)
	local criteria = window.skilllist_sortCriteria.getValue();
	local s1 = "";
	local s2 = "";

	if (criteria == "stat_asc" or criteria == "stat_desc") then
		-- string to compare = stat + name
		s1 = w1.skill_stat.getValue()..w1.name.getValue();
		s2 = w2.skill_stat.getValue()..w2.name.getValue();
	else
		-- string to compare = name
		s1 = w1.name.getValue();
		s2 = w2.name.getValue();
	end

	if s1 == "" then
		if s2 == "" then
			return nil;
		end
		return true;
	elseif s2 == "" then
		return false;
	elseif s1 ~= s2 then
		if (criteria == "name_desc" or criteria == "stat_desc") then
			return s1 < s2;
		else
			return s1 > s2;
		end
	end
end