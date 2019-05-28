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
	
	updateStats();
end

function updateStats()
	onBodyChanged();
	onSpeedChanged();
	onWillChanged();
	onWoundThresholdStateChanged(getDatabaseNode());
end

-- derived stat functions
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
	hit_pointsmax.setValue(physical*5);
	woundthreshold.setValue(math.floor(hit_pointsmax.getValue()/5));
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
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
		hit_pointsmax.setValue(physical*5);
		woundthreshold.setValue(math.floor(hit_pointsmax.getValue()/5));
		staminamax.setValue(physical*5);
		recovery.setValue(physical);
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
		will.setValue(will_backup.getValue());
		dexterity.setValue(dexterity_backup.getValue());
		reflex.setValue(reflex_backup.getValue());
		intelligence.setValue(intelligence_backup.getValue());
		
		reflex.setFont("sheetnumber");
		dexterity.setFont("sheetnumber");
		intelligence.setFont("sheetnumber");
		will.setFont("sheetnumber");
	end
end