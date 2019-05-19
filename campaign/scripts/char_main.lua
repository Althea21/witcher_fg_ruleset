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
	elseif bodyValue <= 14 then
		meleebonusdamage.setValue(8);
		punch.setDice({"d6"});
		punch.setModifier(8);
		kick.setDice({"d6"});
		kick.setModifier(12);
	end
	
	local physical = math.floor((bodyValue + will.getValue())/2);
	hit_pointsmax.setValue(physical*5);
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
	
	local physical = math.floor((body.getValue() + will.getValue())/2);
	hit_pointsmax.setValue(physical*5);
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
	stun.setValue(physical);
end

function onVigorChanged()
	local v = vigor_base.getValue()+vigor_modifier.getValue();
	if v < 0 then
		v=0;
	end
	vigor.setValue(v);
end