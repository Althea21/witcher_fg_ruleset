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

function onDodgeAction(draginfo)
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	
	local sStat = DB.getValue(v, "skill_stat", "reflex");
	local nStat = DB.getValue(nodeActor, "attributs."..sStat, 0);

	if sActorType == "pc" then
		for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
			if (DB.getValue(v, "id", "") == "dodgeEscape") then
				ActionSkill.performRoll(draginfo, rActor, DB.getValue(v, "name", ""), DB.getValue(v, "skill_value", "") + nStat, sStat);
			end
		end
	else
		-- npc 
		ActionSkill.performRoll(draginfo, rActor, Interface.getString("char_skill_dodgeEscape_label"), CharManager.getNPCSkillValue(nodeActor, "dodgeEscape") + nStat, sStat);
	end
end

function onRepositionAction(draginfo)
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	
	local sStat = DB.getValue(v, "skill_stat", "dexterity");
	local nStat = DB.getValue(nodeActor, "attributs."..sStat, 0);

	if sActorType == "pc" then
		for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
			if (DB.getValue(v, "id", "") == "athletics") then
				ActionSkill.performRoll(draginfo, rActor, DB.getValue(v, "name", ""), DB.getValue(v, "skill_value", "") + nStat, sStat);
			end
		end
	else
		-- npc
		ActionSkill.performRoll(draginfo, rActor, Interface.getString("char_skill_athletics_label"), CharManager.getNPCSkillValue(nodeActor, "athletics") + nStat, sStat);
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