-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("skill", onSkillModifier);
	ActionsManager.registerResultHandler("skill", onSkillRoll);
end

function performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat)
   --print("performRoll");
   --Debug.console(draginfo);
   --Debug.console(rActor);
   --Debug.console(sSkillName);
   --Debug.console(nSkillMod);
   --Debug.console(sSkillStat);

	local rRoll = getRoll(rActor, sSkillName, nSkillMod, sSkillStat);
	
	if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, sSkillName, nSkillMod, sSkillStat)
    --print("getRoll");
    --Debug.console(rActor);
    --Debug.console(sSkillName);
    --Debug.console(nSkillMod);
    --Debug.console(sSkillStat);
    --Debug.console(sExtra);

	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d10" };
	rRoll.nMod = nSkillMod or 0;
	rRoll.sDesc = "[SKILL] " .. sSkillName;
	if sExtra then
		rRoll.sDesc = rRoll.sDesc .. " " .. sExtra;
	end
	
	if sSkillStat then
   	local sAbilityEffect = sSkillStat;
   	if sAbilityEffect then
   		rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
   	end
	end
		
	return rRoll;
end

-- Modifier handler : additional modifiers to apply to the roll
function onSkillModifier(rSource, rTarget, rRoll)
    --print("onSkillModifier");
    --Debug.console(rSource);
    --Debug.console(rTarget);
    --Debug.console(rRoll);
    --Debug.console(rRoll.sDesc);

	local aAddDesc = {};
	local nAddMod = 0;
	
	-- Check modifiers

	local bLightLevelModifier = "daylight";
	if ModifierStack.getModifierKey("LGT_BRI") then
		bLightLevelModifier = "bright";
	elseif ModifierStack.getModifierKey("LGT_DIM") then
		bLightLevelModifier = "dim";
	elseif ModifierStack.getModifierKey("LGT_DRK") then
		bLightLevelModifier = "darkness";
	end
	
	if string.match(rRoll.sDesc, "Awareness") == "Awareness" then
   	if bLightLevelModifier == "bright" then
   		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_bright").." -3]");
   		nAddMod = nAddMod - 3;
   	elseif bLightLevelModifier == "dim" then
   		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_dim").." -2]");
   		nAddMod = nAddMod - 2;
   	elseif bLightLevelModifier == "darkness" then
   		table.insert(aAddDesc, "["..Interface.getString("modifier_label_light_dark").." -4]");
   		nAddMod = nAddMod - 4;
   	end
    end
	
	if rSource then
		-- TODO : Get condition modifiers
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	
	rRoll.nMod = rRoll.nMod + nAddMod;
end

function onSkillRoll(rSource, rTarget, rRoll)
    --print("onSkillRoll");
    --Debug.console(rSource);
    --Debug.console(rTarget);
    --Debug.console(rRoll);
    
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

	if rRoll.nTarget then
		local nTotal = ActionsManager.total(rRoll);
		local nTargetDC = tonumber(rRoll.nTarget) or 0;
		
		rMessage.text = rMessage.text .. " (vs. DC " .. nTargetDC .. ")";
		if nTotal >= nTargetDC then
			rMessage.text = rMessage.text .. " [SUCCESS]";
		else
			rMessage.text = rMessage.text .. " [FAILURE]";
		end
	end
	
	local nTotal = ActionsManager.total(rRoll);
	Comm.deliverChatMessage(rMessage);
end
