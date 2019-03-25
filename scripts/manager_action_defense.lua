-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for defense rolls
--

function onInit()
	-- Register defense actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["defense"] = { bUseModStack = true };
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("defense", onDefenseRoll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rWeapon		: weapon node
--	* sDefenseType	: defense type (supported : "block", "parry"). 
--					  Unknown or missing value will generate error chat message
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rWeapon, sDefenseType)
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "defense";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded later
	rRoll.sDesc = "[Defense] ";
	
	-- Add parameters for exploding dice management
	rRoll.sExplodeMode  = "none";	-- initial roll, will be "fumble" or "crit" on reroll
	rRoll.nTotalExplodeValue = 0; 	-- cumulative value of exploding rolls
	rRoll.sStoredDice = "";			-- store all dice for final display message
	rRoll.sWeaponType = "" ; 		-- range, melee, unarmed (used for fumble resolution)
	
	-- Debug.chat(rWeapon);
	
	if (rWeapon.range == "R") then
		rRoll.sWeaponType = "range";
	elseif (rWeapon.range == "M") then
		rRoll.sWeaponType = "melee";
	else
		rRoll.sWeaponType = "unarmed";
	end
	
	-- Look up actor / weapon specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		local sRollDescription = "";
		local nRollMod = 0;
		
		if sDefenseType == "block" then
			sRollDescription = "[Block with "..rWeapon.label.."]";
		elseif sDefenseType == "parry" then
			sRollDescription = "[Parry with "..rWeapon.label.." (-3)]";
			nRollMod = nRollMod - 3;
		else
			local rMessage = {};
			rMessage.text = Interface.getString("defense_errormsg_unknowndefense")
			Comm.deliverChatMessage(rMessage);
		end
		
		-- stat modifier
		-- Debug.chat("stat modifier ("..("attributs."..rWeapon.stat).."): "..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0));
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0);
		sRollDescription = sRollDescription.."["..rWeapon.stat.." +"..DB.getValue(nodeActor, "attributs."..rWeapon.stat, 0).."]"
		
		-- skill modifier
		for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
			if (DB.getValue(v, "name", "") == rWeapon.skill) then
				--Debug.chat("skill modifier ("..rWeapon.skill.."): "..DB.getValue(v, "skill_value", 0));
				nRollMod = nRollMod + DB.getValue(v, "skill_value", 0);
				sRollDescription = sRollDescription.."["..rWeapon.skill.." +"..DB.getValue(v, "skill_value", 0).."]"
				break;
			end
		end
		
		-- TODO : ARMOR ENCUMBRANCE VALUE TO SUB
		
		rRoll.sDesc = sRollDescription;
		rRoll.nMod = nRollMod;
	end
	
	return rRoll;
end

-- method called to initiate defense roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* rWeapon		: weapon node (actor node if unarmed defense)
--	* sDefenseType	: defense type (supported : "block", "parry", "punchblock", "kickblock"). 
--					  Unknown or missing value will generate error chat message
function performRoll(draginfo, rWeapon, sDefenseType)
	-- retreive attack info and actor node 
	local rActor;
	
	if (string.find(sDefenseType, "punch") or string.find(sDefenseType, "kick")) then
		-- unarmed defense
		rActor = rWeapon;
		rWeapon = {};
		rWeapon.range = "U";
		if (string.find(sDefenseType, "punch"))then
			rWeapon.label = Interface.getString("char_label_punchlabel");
		elseif (string.find(sDefenseType, "kick"))then
			rWeapon.label = Interface.getString("char_label_kicklabel");
		end
		rWeapon.stat = "reflex";
		rWeapon.skill= "Brawling";
		
		sDefenseType = string.gsub(sDefenseType, "punch", "");
		sDefenseType = string.gsub(sDefenseType, "kick", "");
	else
		-- weapon attack
		rActor, rWeapon = CharManager.getWeaponDefenseRollStructures(rWeapon);
	end
	
	-- get roll
	local rRoll = getRoll(rActor, rWeapon, sDefenseType);
	
	-- roll it !
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onDefenseRoll(rSource, rTarget, rRoll)
	-- Debug.chat("------- onDefenseRoll");
	-- Debug.chat("--rSource : ");
	-- Debug.chat(rSource);
	-- Debug.chat("--rTarget : ");
	-- Debug.chat(rTarget);
	-- Debug.chat("--rRoll : ");
	-- Debug.chat(rRoll);
	
	-- Debug.chat(rRoll.aDice[1].result);
	
	local bDisplayFinalMessage = true;
	
	local rActor;
	if (rSource.sType=="pc") then
		rActor = ActorManager.resolveActor(DB.findNode(rSource.sCreatureNode));
	end
	
	-- Check for reroll
	local nDiceResult = rRoll.aDice[1].result;
	if (nDiceResult == 1) then
		-- Debug.chat("rolled a 1 => check case");
		if rRoll.sExplodeMode == "none" then
			-- roll 1 on first roll => fumble => reroll
			rRoll.sExplodeMode = "fumble";
			bDisplayFinalMessage = false;
			-- store dice for final message
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				--Debug.chat("rRoll.sStoredDice="..rRoll.sStoredDice);
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			rRoll.sStoredDice = Json.stringify(aStoredDiceTmp);
			-- reinit rRoll dice
			rRoll.aDice = { "d10" };
			-- reroll
			ActionsManager.performAction(nil, rActor, rRoll);
		else
			-- roll 1 on crit or fumble reroll
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
			-- restore dice for final display
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			-- Debug.chat(aStoredDiceTmp);
			rRoll.aDice = aStoredDiceTmp;
			bDisplayFinalMessage = true;
		end
	elseif (nDiceResult == 10) then
		-- Debug.chat("rolled a 10 => reroll");
		bDisplayFinalMessage = false;
		rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
		
		if rRoll.sExplodeMode == "none" then
			rRoll.sExplodeMode = "crit";
		end
		
		-- store dice for final message
		local aStoredDiceTmp = {};
		if rRoll.sStoredDice ~= "" then
			--Debug.chat("rRoll.sStoredDice="..rRoll.sStoredDice);
			aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
		end
		aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
		rRoll.sStoredDice = Json.stringify(aStoredDiceTmp);
		
		-- reinit rRoll dice
		rRoll.aDice = { "d10" };
		
		-- reroll
		ActionsManager.performAction(nil, rActor, rRoll);
	else
		-- Debug.chat("rolled between 2 and 9");
		if rRoll.sExplodeMode ~= "none" then
			rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
			-- restore dice for final display
			local aStoredDiceTmp = {};
			if rRoll.sStoredDice ~= "" then
				aStoredDiceTmp = Json.parse(rRoll.sStoredDice);
			end
			aStoredDiceTmp[#aStoredDiceTmp+1]=rRoll.aDice;
			-- Debug.chat(aStoredDiceTmp);
			rRoll.aDice = aStoredDiceTmp;
		end
		bDisplayFinalMessage = true;
	end
	
	if bDisplayFinalMessage then
		-- rearrange rRoll.aDice if needed (serialization seems to mess up array) and color exploding dice
		local bFumble = false;
		if rRoll.sExplodeMode ~= "none" then
			local aNewDices = {};
			for i = 1, #(rRoll.aDice) do
				local aDice = rRoll.aDice[i];
				for j=1,#(aDice) do
					local aNewDice = aDice[j];
					if tonumber(aNewDice.result)==10 then
						aNewDice.type="g10";
					end
					if i==1 and tonumber(aNewDice.result)==1 then
						bFumble = true;
						aNewDice.type="r10";
					elseif bFumble then
						aNewDice.result = 0-tonumber(aNewDice.result)
					end
					table.insert(aNewDices, aNewDice);
				end
			end
			rRoll.aDice = aNewDices;
		end
		
		-- Create the base message based of the source and the final rRoll record (includes dice results).
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		
		-- update rMessage in case of fumble
		if (bFumble) then
			rMessage.text = rMessage.text .. "\n[FUMBLE (".. rRoll.nTotalExplodeValue ..") : ";
			-- check nTotalExplodeValue and attack type to resolve fumble
			if (rRoll.nTotalExplodeValue <=5) then
				rMessage.text = rMessage.text .. Interface.getString("fumble_none");
			end
				
			if (rRoll.sWeaponType == "melee") then
				if (rRoll.nTotalExplodeValue == 6) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_6");
				elseif (rRoll.nTotalExplodeValue == 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_7");
				elseif (rRoll.nTotalExplodeValue == 8) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_8");
				elseif (rRoll.nTotalExplodeValue == 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_armeddefense_over9");
				end
			elseif (rRoll.sWeaponType == "unarmed") then
				if (rRoll.nTotalExplodeValue == 6) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_6");
				elseif (rRoll.nTotalExplodeValue == 7) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_7");
				elseif (rRoll.nTotalExplodeValue == 8) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_8");
				elseif (rRoll.nTotalExplodeValue == 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_9");
				elseif (rRoll.nTotalExplodeValue > 9) then
					rMessage.text = rMessage.text .. Interface.getString("fumble_unarmed_over9");
				end
			end

			rMessage.text = rMessage.text .. "]";
		end
		
		-- Debug.chat(rMessage);
		
		-- Display the message in chat.
		Comm.deliverChatMessage(rMessage);
	end
end
