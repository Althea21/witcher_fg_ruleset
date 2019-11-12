-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

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

function update()
	-- update locked/unlocked state (for npc only)
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sActorType ~= "pc" then
		local nodeRecord = getDatabaseNode();
		local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
		focus.setReadOnly(bReadOnly);
		stamina_combat.setReadOnly(bReadOnly);
		
		if magic_details.subwindow then
			magic_details.subwindow.update();
		end
	end
end