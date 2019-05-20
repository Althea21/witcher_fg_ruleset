-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onIntelligenceChanged()
	local v = intelligence_base.getValue()+intelligence_modifier.getValue();
	if v < 1 then
		v=1;
	end
	intelligence.setValue(v);
end

function onReflexChanged()
	local v = reflex_base.getValue()+reflex_modifier.getValue();
	if v < 1 then
		v=1;
	end
	reflex.setValue(v);
end

function onDexterityChanged()
	local v = dexterity_base.getValue()+dexterity_modifier.getValue();
	if v < 1 then
		v=1;
	end
	dexterity.setValue(v);
end

function onBodyChanged()
	local v = body_base.getValue()+body_modifier.getValue();
	if v < 1 then
		v=1;
	end
	body.setValue(v);
	
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
	local v = speed_base.getValue()+speed_modifier.getValue();
	if v < 1 then
		v=1;
	end
	speed.setValue(v);

	run.setValue(speed.getValue()*3);
	leap.setValue(math.floor(run.getValue()/5));
end

function onEmpathyChanged()
	local v = empathy_base.getValue()+empathy_modifier.getValue();
	if v < 1 then
		v=1;
	end
	empathy.setValue(v);
end

function onCraftingChanged()
	local v = crafting_base.getValue()+crafting_modifier.getValue();
	if v < 1 then
		v=1;
	end
	crafting.setValue(v);
end

function onWillChanged()
	local v = will_base.getValue()+will_modifier.getValue();
	if v < 1 then
		v=1;
	end
	will.setValue(v);
	
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

function onVigorChanged()
	local v = vigor_base.getValue()+vigor_modifier.getValue();
	if v < 0 then
		v=0;
	end
	vigor.setValue(v);
end

function onWoundThresholdStateChanged(nodeActor)
	local state = DB.getValue(nodeActor, "attributs.woundthreshold_state", -1);
	if (state==1) then
		-- Activate : halve REF, DEX, INT, and WILL
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
		local v = reflex_base.getValue()+reflex_modifier.getValue();
		if v < 1 then
			v=1;
		end
		reflex.setValue(v);
		reflex.setFont("sheetnumber");

		v = dexterity_base.getValue()+dexterity_modifier.getValue();
		if v < 1 then
			v=1;
		end
		dexterity.setValue(v);
		dexterity.setFont("sheetnumber");

		v = intelligence_base.getValue()+intelligence_modifier.getValue();
		if v < 1 then
			v=1;
		end
		intelligence.setValue(v);
		intelligence.setFont("sheetnumber");

		v = will_base.getValue()+will_modifier.getValue();
		if v < 1 then
			v=1;
		end
		will.setValue(v);
		will.setFont("sheetnumber");
	end
end

function onRecoverAction()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local msg = ChatManager.createBaseMessage(rActor, nil);
	msg.text = string.format(Interface.getString("char_recoveryaction"), recovery.getValue())
	Comm.deliverChatMessage(msg);
	
	stamina.setValue(stamina.getValue()+recovery.getValue());
	if stamina.getValue() > staminamax.getValue() then
		stamina.setValue(staminamax.getValue());
	end
end
