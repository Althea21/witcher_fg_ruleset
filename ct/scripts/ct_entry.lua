-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- Register the deletion menu item for the host
	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);

	-- Set the displays to what should be shown
	setTargetingVisible();
	setSpacingVisible();
	setEffectsVisible();

	-- Acquire token reference, if any
	linkToken();
	
	-- Update the displays
	onLinkChanged();
	onFactionChanged();
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		nonid_name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		nonid_name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onMenuSelection(selection, subselection)
	-- GM only
	if not User.isHost() then
		return;
	end

	if selection == 6 and subselection == 7 then
		delete();
	end
end

function delete()
	-- GM only
	if not User.isHost() then
		return;
	end

	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getNodeName();
	
	-- Clear any effects and wounds first, so that rolls aren't triggered when initiative advanced
	effects.reset(false);
	
	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	node.delete();

	-- Update list information (global subsection toggles)
	windowlist.onVisibilityToggle();
	windowlist.onEntrySectionToggle();
end

function onLinkChanged()
	-- GM only
	if not User.isHost() then
		return;
	end

	-- Set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	
	
	if sClass == "charsheet" then
		-- PC case
		linkPCFields();
		name.setLine(false);
	else
		-- NPC case
		linkNPCFields();
	end
	onIDChanged();
end

function onIDChanged()
	-- GM only
	if not User.isHost() then
		return;
	end
	
	local nodeRecord = getDatabaseNode();
	local sClass = DB.getValue(nodeRecord, "link", "", "");
	if sClass == "npc" then
		local bID = LibraryData.getIDState("npc", nodeRecord, true);
		name.setVisible(bID);
		nonid_name.setVisible(not bID);
		isidentified.setVisible(true);
	else
		name.setVisible(true);
		nonid_name.setVisible(false);
		isidentified.setVisible(false);
	end
end

function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end

	updateHealthDisplay();
end

function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

function linkPCFields()
	-- GM only
	if not User.isHost() then
		return;
	end

	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		hit_points.setLink(nodeChar.createChild("attributs.hit_points", "number"), false);
		stamina.setLink(nodeChar.createChild("attributs.stamina", "number"), false);
	end
end

function linkNPCFields()
	-- GM only
	if not User.isHost() then
		return;
	end

	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		hit_points.setLink(nodeChar.createChild("attributs.hit_points", "number"), false);
		stamina.setLink(nodeChar.createChild("attributs.stamina", "number"), false);
	end
end

function updateHPDisplay()
	local node = getDatabaseNode();
	local sClass = DB.getValue(nodeRecord, "link", "", "");
	
	if not (sClass == "npc") then
		node  = link.getTargetDatabaseNode();
	end

	local hpMax = DB.getValue(node, "attributs.hit_pointsmax", 0);
	local wt = DB.getValue(node, "attributs.woundthreshold", 0);
	
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
--
-- SECTION VISIBILITY FUNCTIONS
--

function setTargetingVisible()
	-- GM only
	if not User.isHost() then
		return;
	end

	local v = false;

	if activatetargeting.getValue() == 1 then
		v = true;
	end

	targetingicon.setVisible(v);
	sub_targeting.setVisible(v);
	frame_targeting.setVisible(v);
	target_summary.onTargetsChanged();
end

function setSpacingVisible()
	-- GM only
	if not User.isHost() then
		return;
	end

	local v = false;
	
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	space.setVisible(v);
	spacelabel.setVisible(v);
	reach.setVisible(v);
	reachlabel.setVisible(v);
	
	frame_spacing.setVisible(v);
end

function setEffectsVisible()
	-- GM only
	if not User.isHost() then
		return;
	end

	local v = false;
	
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effecticon.setVisible(v);
	
	effects.setVisible(v);
	effects_iadd.setVisible(v);
	for _,w in pairs(effects.getWindows()) do
		w.idelete.setValue(0);
	end

	frame_effects.setVisible(v);

	effect_summary.onEffectsChanged();
end

function updateHealthDisplay()
	-- Players only
	if not User.isHost() then
		local sOption;
		if friendfoe.getStringValue() == "friend" then
			sOption = OptionsManager.getOption("SHPC");
		else
			sOption = OptionsManager.getOption("SHNPC");
		end
		
		if sOption == "on" then
			hit_points.setVisible(true);
			stamina.setVisible(true);
		else
			hit_points.setVisible(false);
			stamina.setVisible(false);
		end
	end
end
