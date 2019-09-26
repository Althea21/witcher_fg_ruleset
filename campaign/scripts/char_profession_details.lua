-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onProfessionValueChanged(sVal)
    -- Debug.chat("onProfessionValueChanged");
    -- Debug.chat(sVal);
    
    if not sVal then
        return;
    end

    --local sVal = getValue();
    local sSkill = "";
    local sAbility = "";
    local sStat = "";
    
    sSkill = ProfessionTable.tbl_profession[sVal]["root"]["skill"];
    root_skills_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal]["root"]["stat"];
    root_skills_bs.setValue(sStat);
        
    sAbility = ProfessionTable.tbl_profession[sVal]["ability"]["branch1"];
    a1_label_ss.setValue(sAbility);
    
    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill1"];
    a1_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat1"];
    a1_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill2"];
    a2_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat2"];
    a2_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill3"];
    a3_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat3"];
    a3_ability_bs.setValue(sStat);

    
    sAbility = ProfessionTable.tbl_profession[sVal]["ability"]["branch2"];
    a2_label_ss.setValue(sAbility);
    
    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill1"];
    b1_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat1"];
    b1_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill2"];
    b2_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat2"];
    b2_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill3"];
    b3_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat3"];
    b3_ability_bs.setValue(sStat);
    
    sAbility = ProfessionTable.tbl_profession[sVal]["ability"]["branch3"];
    a3_label_ss.setValue(sAbility);
    
    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill1"];
    c1_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat1"];
    c1_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill2"];
    c2_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat2"];
    c2_ability_bs.setValue(sStat);

    sSkill = ProfessionTable.tbl_profession[sVal][sAbility]["skill3"];
    c3_ability_st.setValue(sSkill);
    sStat = ProfessionTable.tbl_profession[sVal][sAbility]["stat3"];
    c3_ability_bs.setValue(sStat);
end

