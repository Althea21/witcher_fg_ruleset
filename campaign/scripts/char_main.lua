-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onIntelligenceChanged()
	intelligence.setValue(intelligence_base.getValue()+intelligence_modifier.getValue());
end

function onReflexChanged()
	reflex.setValue(reflex_base.getValue()+reflex_modifier.getValue());
end

function onDexterityChanged()
	dexterity.setValue(dexterity_base.getValue()+dexterity_modifier.getValue());
end

function onBodyChanged()
	body.setValue(body_base.getValue()+body_modifier.getValue());
	
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
	speed.setValue(speed_base.getValue()+speed_modifier.getValue());

	run.setValue(speed.getValue()*3);
	leap.setValue(math.floor(run.getValue()/5));
end

function onEmpathyChanged()
	empathy.setValue(empathy_base.getValue()+empathy_modifier.getValue());
end

function onCraftingChanged()
	crafting.setValue(crafting_base.getValue()+crafting_modifier.getValue());
end

function onWillChanged()
	will.setValue(will_base.getValue()+will_modifier.getValue());
	
	local physical = math.floor((body.getValue() + will.getValue())/2);
	hit_pointsmax.setValue(physical*5);
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
	stun.setValue(physical);
end

function onVigorChanged()
	vigor.setValue(vigor_base.getValue()+vigor_modifier.getValue());
end