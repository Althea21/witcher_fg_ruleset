-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Management for attack rolls
--

function onInit()
	-- Register attack actions.  We'll allow use of the modifier stack for those actions.
	GameSystem.actions["attack"] = { bUseModStack = true };
	
	-- Register the result handler - called after the dice have stopped rolling
	ActionsManager.registerResultHandler("attack", onAttackRoll);
	ActionsManager.registerResultHandler("fumblereroll", onFumbleReroll);
end

-- method called by performAction to initiate the roll object which will be given 
-- to high level ActionsManager to actually perform roll
-- params :
--	* rActor		: actor info retrieved by using ActorManager.resolveActor
--	* rAttack		: weapon type (supported : "melee", "range")
--	* sAttackType	: attack type (supported : "fast", "strong", "normal"). 
--					  Unknown or missing value will be trated like a "normal" attack
-- returns : 
--	* rRoll	: roll object
function getRoll(rActor, rAttack, sAttackType)
	-- Initialize a blank rRoll record
	local rRoll = {};
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
	rRoll.sType = "attack";
	-- the dice to roll.
	rRoll.aDice = { "d10" };
	-- A modifier to apply to the roll, will be overloaded later.
	rRoll.nMod = 0;
	-- The description to show in the chat window, will be overloaded later
	rRoll.sDesc = "[Attack] ";
	
	-- Add parameters for exploding dice management
	rRoll.sExplodeMode  = "none";	-- initial roll, will be "fumble" or "crit" on reroll
	rRoll.nTotalExplodeValue = 0; 	-- cumulative value of exploding rolls
	rRoll.sStoredDice = "";			-- store all dice for final display message
	
	-- Look up actor / weapon specific information
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		local sRollDescription = "";
		local nRollMod = 0;
		
		if sAttackType == "fast" then
			sRollDescription = "[Fast attack with "..rAttack.label.."]";
		elseif sAttackType == "strong" then
			sRollDescription = "[Strong attack with "..rAttack.label.."][Strong -3]";
			nRollMod = nRollMod - 3;
		else
			sRollDescription = "[Attack with "..rAttack.label.."]";
		end
		
		-- stat modifier
		--Debug.chat("stat modifier ("..("attributs."..rAttack.stat).."): "..DB.getValue(nodeActor, "attributs."..rAttack.stat, 0));
		nRollMod = nRollMod + DB.getValue(nodeActor, "attributs."..rAttack.stat, 0);
		sRollDescription = sRollDescription.."["..rAttack.stat.." +"..DB.getValue(nodeActor, "attributs."..rAttack.stat, 0).."]"
		
		-- skill modifier
		for _,v in pairs(nodeActor.getChild("skills.skillslist").getChildren()) do
			if (DB.getValue(v, "name", "") == rAttack.skill) then
				--Debug.chat("skill modifier ("..rAttack.skill.."): "..DB.getValue(v, "skill_value", 0));
				nRollMod = nRollMod + DB.getValue(v, "skill_value", 0);
				sRollDescription = sRollDescription.."["..rAttack.skill.." +"..DB.getValue(v, "skill_value", 0).."]"
				break;
			end
		end
		
		-- weapon accuracy modifier
		--Debug.chat("weapon accuracy modifier : "..rAttack.weaponaccuracy);
		nRollMod = nRollMod + rAttack.weaponaccuracy;
		sRollDescription = sRollDescription.."[WA +"..rAttack.weaponaccuracy.."]"
		
		-- TODO : ARMOR ENCUMBRANCE VALUE TO SUB
		
		rRoll.sDesc = sRollDescription;
		rRoll.nMod = nRollMod;
	end
	
	return rRoll;
end

-- method called to initiate attack roll
-- params :
--	* draginfo		: info given when rolling from onDragStart event (nil if other event trigger the roll)
--	* sAttackType	: attack type (supported : "fast", "strong", "normal"). 
--					  Unknown or missing value will be trated like a "normal" attack
function performRoll(draginfo, rWeapon, sAttackType)
	-- retreive attack info and actor node 
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(rWeapon);
	
	-- get roll
	local rRoll = getRoll(rActor, rAttack, sAttackType);
	
	-- roll it !
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- callback for ActionsManager called after the dice have stopped rolling : resolve roll status and display chat message
function onAttackRoll(rSource, rTarget, rRoll)
	-- Debug.chat("------- onAttackRoll");
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
		if rRoll.sExplodeMode == "none" then
			rRoll.sExplodeMode = "crit";
		end
		rRoll.nTotalExplodeValue = rRoll.nTotalExplodeValue + nDiceResult;
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
					end
					table.insert(aNewDices, aNewDice);
				end
			end
			rRoll.aDice = aNewDices;
		end
		
		-- Create the base message based of the source and the final rRoll record (includes dice results).
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		
		-- update rMessage.diemodifier in case of fumble
		if (fumble) then
			-- total will be calculated as dice sum + modifier it's ok in standard case and crit case
			-- but fumble total is : modifier - nTotalExplodeValue
			-- TODO
		end
		
		-- Debug.chat(rMessage);
		
		-- Display the message in chat.
		Comm.deliverChatMessage(rMessage);
	end
end
