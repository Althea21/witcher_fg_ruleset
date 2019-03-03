-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onIntelligenceChanged()
end

function onReflexChanged()
end

function onDexterityChanged()
end

function onBodyChanged()
	local bodyValue = body.getValue();
	encumbrancemax.setValue(bodyValue*10);
	
	if bodyValue <= 2 then
		meleebonusdamage.setValue(-4);
	elseif bodyValue <= 4 then
		meleebonusdamage.setValue(-2);
	elseif bodyValue <= 6 then
		meleebonusdamage.setValue(0);
	elseif bodyValue <= 8 then
		meleebonusdamage.setValue(2);
	elseif bodyValue <= 10 then
		meleebonusdamage.setValue(4);
	elseif bodyValue <= 12 then
		meleebonusdamage.setValue(6);
	elseif bodyValue <= 14 then
		meleebonusdamage.setValue(8);
	end
	
	local physical = math.floor((bodyValue + will.getValue())/2);
	hit_pointsmax.setValue(physical*5);
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
	stun.setValue(physical);
end

function onSpeedChanged()
	run.setValue(speed.getValue()*3);
	leap.setValue(math.floor(run.getValue()/5));
end

function onEmpathyChanged()
end

function onCraftingChanged()
end

function onWillChanged()
	local physical = math.floor((body.getValue() + will.getValue())/2);
	hit_pointsmax.setValue(physical*5);
	staminamax.setValue(physical*5);
	recovery.setValue(physical);
	stun.setValue(physical);
end