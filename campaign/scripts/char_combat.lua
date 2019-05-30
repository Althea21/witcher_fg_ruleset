-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	Update();
end

function Update()
	onHPChanged();
end

function onRecoverAction()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local msg = ChatManager.createBaseMessage(rActor, nil);
	msg.text = string.format(Interface.getString("char_recoveryaction"), recovery_combat.getValue())
	Comm.deliverChatMessage(msg);
	
	stamina_combat.setValue(stamina_combat.getValue()+recovery_combat.getValue());
	if stamina_combat.getValue() > staminamax_combat.getValue() then
		stamina_combat.setValue(staminamax_combat.getValue());
	end
end

function onHPChanged()
	local node = getDatabaseNode();
	local hpMax = hit_pointsmax_combat.getValue();
	local wt = DB.getValue(node, "attributs.woundthreshold", 0);
	
	
	if hit_points_combat.getValue() < wt then
		hit_points_combat.setFont("sheetnumber_critical");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 1);
		--Debug.chat(DB.getValue(node, "attributs.woundthreshold_state", -2));
	elseif hit_points_combat.getValue() < (hpMax/2) then
		hit_points_combat.setFont("sheetnumber_warning");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	else
		hit_points_combat.setFont("sheetnumber");
		DB.setValue(node, "attributs.woundthreshold_state", "number", 0);
	end
end