-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
end

function onSkillValueChanged()
	skill_value.setValue(skill_bonus.getValue() + skill_rank.getValue());
end

function performSkillRoll()
	local rActor = ActorManager.resolveActor(windowlist.window.getDatabaseNode());
	local sStat, nStat = getAssociatedStat(rActor);
	
	ActionSkill.performRoll(draginfo, rActor, name.getValue(), skill_value.getValue() + nStat, sStat);
	
	return true;
end

function getAssociatedStat(rActor)
	local sStat = skill_stat.getStringValue();
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	local nStat = DB.getValue(nodeActor, "attributs."..sStat, 0);

	return sStat,nStat;
end

function onIsClassSkillChanged()
	if (isClassSkill.getValue()==1) then
		name.setFont("sheettext-alt");--sheettextbold
	else
		name.setFont("sheettext");
	end
end