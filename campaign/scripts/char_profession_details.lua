-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onProfessionValueChanged(sVal)
    if not sVal then
        return;
    end

    local id = getIdFromLabel(sVal);

    local sSkill;
    local sAbility = "";
    local sStat = "";
    
    if (sVal == Interface.getString("list_profession_custom")) then
        setProfessionEditable(true);
    elseif not ProfessionTable.tbl_professions[id] then
        return;
    else
        setProfessionEditable(false);
        -- init defining skill
        sSkill = ProfessionTable.tbl_professions[id]["definingSkill"];
        definingSkill_name.setValue(Interface.getString("char_label_definingSkill_"..sSkill[1]));
        definingSkill_desc.setValue(Interface.getString("char_prof_skill_"..sSkill[1].."_desc"));
        definingSkill_stat.setStringValue(sSkill[2]);
        --Debug.chat(self["branch1_label"]);
        -- branch init
        local branchNumber = 0
        for k,v in pairs(ProfessionTable.tbl_professions[id]) do
            if k~="definingSkill" then
                branchNumber = branchNumber + 1;
                self["branch"..branchNumber.."_label"].setValue((Interface.getString("char_label_branch_"..k)));
                local aBranch = ProfessionTable.tbl_professions[id][k];
                for i=1, #aBranch do
                    local branchSkill = aBranch[i];
                    self["branch"..branchNumber.."_ability"..i.."_desc"].setValue((Interface.getString("char_prof_skill_"..branchSkill[1].."_desc")));
                    self["branch"..branchNumber.."_ability"..i.."_name"].setValue((Interface.getString("char_prof_skill_"..branchSkill[1].."_label")));
                    self["branch"..branchNumber.."_ability"..i.."_stat"].setStringValue(branchSkill[2]);
                end
            end
        end
    end
end

function performProfessionSkillRoll(branchNumber, skillNumber)
    local rActor = ActorManager.resolveActor(getDatabaseNode());
    local sStat, nStat = getAssociatedStat(rActor, self["branch"..branchNumber.."_ability"..skillNumber.."_stat"].getStringValue());
    local sName = self["branch"..branchNumber.."_ability"..skillNumber.."_name"].getValue();
    local sValue = self["branch"..branchNumber.."_ability"..skillNumber.."_value"].getValue();
    
	ActionSkill.performRoll(draginfo, rActor, sName, sValue + nStat, sStat);
	
	return true;
end

--------------------------------------------------------------------------
-- Transform a string (label) into a valid id
-- An id :
--  * start by a lower case letter
--  * has no whitespace
--  * don't change the string internal case 
--------------------------------------------------------------------------
function getIdFromLabel (label)
    local id = "";
    
    local aWords = StringManager.parseWords(label);
    id = aWords[1]:lower();
    for k = 2, #aWords do
        id = id .. aWords[k];
    end

    return id;
end

--------------------------------------------------------------------------
-- Retreive the value of a specified stat
--------------------------------------------------------------------------
function getAssociatedStat(rActor, sStat)
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	local nStat = DB.getValue(nodeActor, "attributs."..sStat, 0);

	return sStat,nStat;
end

--------------------------------------------------------------------------
-- Set the enable/disable status of all labels and stat cyler
--------------------------------------------------------------------------
function setProfessionEditable(bEditable)
    -- defining skill
    definingSkill_name.setEnabled(bEditable);
    definingSkill_stat.setEnabled(bEditable);
    definingSkill_editablewidget.setVisible(bEditable);
    
    -- branch
    for i=1, 3 do
        self["branch"..i.."_label"].setEnabled(bEditable);
        self["branch"..i.."_editablewidget"].setVisible(bEditable);
        for j=1, 3 do
            self["branch"..i.."_ability"..j.."_name"].setEnabled(bEditable);
            self["branch"..i.."_ability"..j.."_stat"].setEnabled(bEditable);
            self["branch"..i.."_ability"..j.."_editablewidget"].setVisible(bEditable);
        end
    end
end