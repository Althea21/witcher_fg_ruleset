-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);

	local bSection1 = false;
	if User.isHost() then
		if updateControl("nonid_name", bReadOnly) then 
			bSection1 = true; 
		end
	else
		updateControl("nonid_name", bReadOnly, true);
	end
	divider.setVisible(bSection1);
	
	-- update locked/unlocked state
	nonid_name.setReadOnly(bReadOnly);
	npctype.setReadOnly(bReadOnly);
	threat1.setReadOnly(bReadOnly);
	threat2.setReadOnly(bReadOnly);
	vulnerabilities.setReadOnly(bReadOnly);
	abilities.setReadOnly(bReadOnly);
	--hit_points.setReadOnly(bReadOnly);
	stamina.setReadOnly(bReadOnly);
	intelligence.setReadOnly(bReadOnly);
	reflex.setReadOnly(bReadOnly);
	dexterity.setReadOnly(bReadOnly);
	body.setReadOnly(bReadOnly);
	speed.setReadOnly(bReadOnly);
	empathy.setReadOnly(bReadOnly);
	crafting.setReadOnly(bReadOnly);
	will.setReadOnly(bReadOnly);
	vigor.setReadOnly(bReadOnly);
	luck.setReadOnly(bReadOnly);
	skills.setReadOnly(bReadOnly);
	height.setReadOnly(bReadOnly);
	weight.setReadOnly(bReadOnly);
	environment.setReadOnly(bReadOnly);
	intelligencelevel.setReadOnly(bReadOnly);
	organization.setReadOnly(bReadOnly);
	loot.setReadOnly(bReadOnly);
	bounty.setReadOnly(bReadOnly);

	onToggleManualHP(nodeRecord);

	updateStats();
end

function updateStats()
	onBodyChanged();
	onSpeedChanged();
	onWillChanged();
	--onWoundThresholdStateChanged(getDatabaseNode());
end

function isHPAuto(nodeActor)
	local state = DB.getValue(nodeActor, "attributs.hp_auto", -1);
	return (state == 0);
end

-- derived stat functions
function onToggleManualHP(nodeActor)
	-- hp mode
	local bHpMaxReadOnly = isHPAuto(nodeActor);
	--record read-only ?
	local bRecordReadOnly = WindowManager.getReadOnlyState(nodeActor);
	
	local bFinalRO = (bHpMaxReadOnly or bRecordReadOnly);
	hit_pointsmax.setReadOnly(bFinalRO);
	updateStats();
end

function onBodyChanged()
	local bodyValue = body.getValue();
	encumbrancemax.setValue(bodyValue*10);
	
	if bodyValue <= 2 then
		meleebonusdamage.setValue(-4);
		punch.setDice({"d6"});
		punch.setModifier(-4);
		kick.setDice({"d6"});
		kick.setModifier(0);
	elseif bodyValue <= 4 then
		meleebonusdamage.setValue(-2);
		punch.setDice({"d6"});
		punch.setModifier(-2);
		kick.setDice({"d6"});
		kick.setModifier(2);
	elseif bodyValue <= 6 then
		meleebonusdamage.setValue(0);
		punch.setDice({"d6"});
		punch.setModifier(0);
		kick.setDice({"d6"});
		kick.setModifier(4);
	elseif bodyValue <= 8 then
		meleebonusdamage.setValue(2);
		punch.setDice({"d6"});
		punch.setModifier(2);
		kick.setDice({"d6"});
		kick.setModifier(6);
	elseif bodyValue <= 10 then
		meleebonusdamage.setValue(4);
		punch.setDice({"d6"});
		punch.setModifier(4);
		kick.setDice({"d6"});
		kick.setModifier(8);
	elseif bodyValue <= 12 then
		meleebonusdamage.setValue(6);
		punch.setDice({"d6"});
		punch.setModifier(6);
		kick.setDice({"d6"});
		kick.setModifier(10);
	elseif bodyValue >= 13 then
		meleebonusdamage.setValue(8);
		punch.setDice({"d6"});
		punch.setModifier(8);
		kick.setDice({"d6"});
		kick.setModifier(12);
	end
	
	local physical = math.floor((bodyValue + will.getValue())/2);
	if hp_auto.getValue()==0 then
		hit_pointsmax.setValue(physical*5);
	end
	woundthreshold.setValue(math.floor(hit_pointsmax.getValue()/5));
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
	if physical > 10 then
		physical = 10;
	end
	stun.setValue(physical);
end

function onSpeedChanged()
	run.setValue(speed.getValue()*3);
	leap.setValue(math.floor(run.getValue()/5));
end

function onWillChanged()
	local woundthreshold_state = woundthreshold_state.getValue();
	
	if (woundthreshold_state==0) then
		-- change derived stat only if not under woundthreshold_state
		local physical = math.floor((body.getValue() + will.getValue())/2);
		if hp_auto.getValue()==0 then
			hit_pointsmax.setValue(physical*5);
		end
		woundthreshold.setValue(math.floor(hit_pointsmax.getValue()/5));
		staminamax.setValue(physical*5);
		recovery.setValue(physical);
		if physical > 10 then
			physical = 10;
		end
		stun.setValue(physical);
	end
end

function onWoundThresholdStateChanged(nodeActor)
	local state = DB.getValue(nodeActor, "attributs.woundthreshold_state", -1);
	if (state==1) then
		-- Activate 
		-- backup stat to restore later
		will_backup.setValue(will.getValue());
		dexterity_backup.setValue(dexterity.getValue());
		reflex_backup.setValue(reflex.getValue());
		intelligence_backup.setValue(intelligence.getValue());

		-- halve REF, DEX, INT, and WILL
		reflex.setValue(math.floor(reflex.getValue()/2));
		reflex.setFont("sheetnumber_critical");
		dexterity.setValue(math.floor(dexterity.getValue()/2));
		dexterity.setFont("sheetnumber_critical");
		intelligence.setValue(math.floor(intelligence.getValue()/2));
		intelligence.setFont("sheetnumber_critical");
		will.setValue(math.floor(will.getValue()/2));
		will.setFont("sheetnumber_critical");
	elseif (state==0) then
		-- Desactivate : restore REF, DEX, INT, and WILL
		if (will_backup.getValue() > 0) then
			will.setValue(will_backup.getValue());
		end
		if dexterity_backup.getValue() > 0 then
			dexterity.setValue(dexterity_backup.getValue());
		end
		if reflex_backup.getValue() > 0 then
			reflex.setValue(reflex_backup.getValue());
		end
		if intelligence_backup.getValue() > 0 then
			intelligence.setValue(intelligence_backup.getValue());
		end
		
		reflex.setFont("sheetnumber");
		dexterity.setFont("sheetnumber");
		intelligence.setFont("sheetnumber");
		will.setFont("sheetnumber");
	end
end

function onHPChanged()
	local node = getDatabaseNode();
	local hpMax = hit_pointsmax.getValue();
	local wt = DB.getValue(node, "attributs.woundthreshold", 0);
	
	
	if hit_points.getValue() <= 0 then
		hit_points.setFont("sheetnumber_dead");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 1);
	elseif hit_points.getValue() < wt then
		hit_points.setFont("sheetnumber_critical");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 1);
		--Debug.chat(DB.getValue(node, "attributs.woundthreshold_state", -2));
	elseif hit_points.getValue() < (hpMax/2) then
		hit_points.setFont("sheetnumber_warning");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	else
		hit_points.setFont("sheetnumber");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	end
end