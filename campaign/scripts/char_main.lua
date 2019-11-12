-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	update();
end

function update()
	onIntelligenceChanged();
	onReflexChanged();
	onDexterityChanged();
	onBodyChanged();
	onSpeedChanged();
	onEmpathyChanged();
	onCraftingChanged();
	onWillChanged();
	onVigorChanged();
	-- onWoundThresholdStateChanged(getDatabaseNode());
	onToxicityChanged();
	onHPChanged();
	onEncumbranceChanged();
end

function onIntelligenceChanged()
	-- local v = intelligence_base.getValue()+intelligence_modifier.getValue();
	-- if v < 1 then
	-- 	v=1;
	-- end
	-- intelligence.setValue(v);
	applyStatMalus();
end

function onReflexChanged()
	-- local v = reflex_base.getValue()+reflex_modifier.getValue();
	-- if v < 1 then
	-- 	v=1;
	-- end
	-- reflex.setValue(v);
	applyStatMalus();
end

function onDexterityChanged()
	-- local v = dexterity_base.getValue()+dexterity_modifier.getValue();
	-- if v < 1 then
	-- 	v=1;
	-- end
	-- dexterity.setValue(v);
	applyStatMalus();
end

function onBodyChanged()
	local v = body_base.getValue()+body_modifier.getValue();
	if v < 1 then
		v=1;
	end
	body.setValue(v);
	
	-- change derived stat only if not under woundthreshold_state
	local woundthreshold_state = woundthreshold_state.getValue();
	if (woundthreshold_state==0) then
		local bodyValue = body.getValue();
		
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
		
		encumbrancemax.setValue(bodyValue*10);
		onEncumbranceChanged();
		
		local physical = math.floor((bodyValue + will.getValue())/2);
		hit_pointsmax.setValue(physical*5);
		woundthreshold.setValue(math.floor(hit_pointsmax.getValue()/5));
		staminamax.setValue(physical*5);
		recovery.setValue(physical);
		stun.setValue(physical);
		onHPChanged();
	end
	
	
end

function onSpeedChanged()
	-- local v = speed_base.getValue()+speed_modifier.getValue();
	-- if v < 1 then
	-- 	v=1;
	-- end
	-- speed.setValue(v);
	applyStatMalus();

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
	-- local v = will_base.getValue()+will_modifier.getValue();
	-- if v < 1 then
	-- 	v=1;
	-- end
	-- will.setValue(v);
	applyStatMalus();
	
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
	--Debug.chat("onWoundThresholdStateChanged");
	applyStatMalus();
end

function onToxicityChanged()
	local value = toxicity.getValue();
	
	if value < 100 then
		toxicity.setFont("sheetnumber");
	elseif value == 100 then
		toxicity.setFont("sheetnumber_warning");
	else
		toxicity.setFont("sheetnumber_critical");
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

function onHPChanged()
	--Debug.chat("onHPChanged");
	local node = getDatabaseNode();
	local hpMax = hit_pointsmax.getValue();
	local wt = woundthreshold.getValue();
	
	
	if hit_points.getValue() <= 0 then
		hit_points.setFont("sheetnumber_dead");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 1);
	elseif hit_points.getValue() < wt then
		hit_points.setFont("sheetnumber_critical");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 1);
	elseif hit_points.getValue() < (hpMax/2) then
		hit_points.setFont("sheetnumber_warning");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	else
		hit_points.setFont("sheetnumber");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	end
end

function onEncumbranceChanged()
	local encMax = encumbrancemax.getValue();
	local enc = encumbrance.getValue();
	
	if enc > encMax then
		encumbrance.setFont("sheetnumber_critical");
		applyStatMalus();
	else
		encumbrance.setFont("sheetnumber");
		applyStatMalus();
	end
end

-- Apply stat malus if needed.  Centralized to avoid conflict.
-- Following malus are applied in this order :
-- 	* Wound Threshold
-- 	* Encumbrance
function applyStatMalus()
	--Debug.chat("applyStatMalus");
	-- normal stats
	local ref = reflex_base.getValue() + reflex_modifier.getValue();
	if ref < 1 then 
		ref = 1;
	end
	local dex = dexterity_base.getValue() + dexterity_modifier.getValue();
	if dex < 1 then 
		dex = 1;
	end
	local spd = speed_base.getValue() + speed_modifier.getValue();
	if spd < 1 then 
		spd = 1;
	end
	local int = intelligence_base.getValue() + intelligence_modifier.getValue();
	if int < 1 then 
		int = 1;
	end
	local wil = will_base.getValue() + will_modifier.getValue();
	if wil < 1 then 
		wil = 1;
	end
	
	-- wound threshold status
	local bWoundThresholdStatus = woundthreshold_state.getValue() > 0;
	--Debug.chat(bWoundThresholdStatus);
	if (bWoundThresholdStatus) then
		-- Activate : halve REF, DEX, INT, and WILL
		if ref > 1 then
			reflex.setValue(math.floor(ref/2));
		end
		reflex.setFont("sheetnumber_critical");
		ref = reflex.getValue();
	
		if dex > 1 then
			dexterity.setValue(math.floor(dex/2));
		end
		dexterity.setFont("sheetnumber_critical");
		dex = dexterity.getValue();
	
		if int > 1 then
			intelligence.setValue(math.floor(int/2));
		end
		intelligence.setFont("sheetnumber_critical");

		if wil > 1 then
			will.setValue(math.floor(wil/2));
		end
		will.setFont("sheetnumber_critical");
	else
		-- Desactivate : restore REF, DEX, INT, and WILL
		reflex.setValue(ref);
		reflex.setFont("sheetnumber");

		dexterity.setValue(dex);
		dexterity.setFont("sheetnumber");

		intelligence.setValue(int);
		intelligence.setFont("sheetnumber");

		will.setValue(wil);
		will.setFont("sheetnumber");
	end
	
	-- encumbrance status
	local nEncExcess = encumbrance.getValue() - encumbrancemax.getValue();
	local bOverburdened = false;
	local nOverburdenedMalus = 0
	if (nEncExcess > 0) then
		bOverburdened = true;
		nOverburdenedMalus = math.floor(nEncExcess / 5);
		if nOverburdenedMalus <= 0 then
			nOverburdenedMalus = 1;
		end
	end
	--Debug.chat("nOverburdenedMalus="..nOverburdenedMalus);
	
	ref_overburdened.setVisible(bOverburdened);
	dex_overburdened.setVisible(bOverburdened);
	spd_overburdened.setVisible(bOverburdened);
	
	if (bOverburdened) then
		-- Overburdened : REF, DEX, and SPD impacted
		if ref > nOverburdenedMalus then
			reflex.setValue(ref-nOverburdenedMalus);
		else
			reflex.setValue(1);
		end
		reflex.setFont("sheetnumber_critical");
		
		if dex > nOverburdenedMalus then
			dexterity.setValue(dex-nOverburdenedMalus);
		else
			dexterity.setValue(1);
		end
		dexterity.setFont("sheetnumber_critical");
		
		if spd > nOverburdenedMalus then
			speed.setValue(spd-nOverburdenedMalus);
		else
			speed.setValue(1);
		end
		speed.setFont("sheetnumber_critical");
	else
		-- restore REF, DEX, SPD
		reflex.setValue(ref);
		if not bWoundThresholdStatus then
			reflex.setFont("sheetnumber");
		end
		
		dexterity.setValue(dex);
		if not bWoundThresholdStatus then
			dexterity.setFont("sheetnumber");
		end
		
		speed.setValue(spd);
		speed.setFont("sheetnumber");
	end

end

