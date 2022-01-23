--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	update();
end

function VisDataCleared()
	update();
end

function InvisDataAdded()
	update();
end

function updateControl(sControl, bReadOnly, bID)
	if not self[sControl] then
		return false;
	end

	if not bID then
		return self[sControl].update(bReadOnly, true);
	end

	return self[sControl].update(bReadOnly);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("item", nodeRecord);

	local bWeapon, sTypeLower, sSubtypeLower = ItemManager2.isWeapon(nodeRecord);
	local bArmor = ItemManager2.isArmor(nodeRecord);
	local bArcaneFocus = (sTypeLower == "rod") or (sTypeLower == "staff") or (sTypeLower == "wand");
	local bAmmunition = sSubtypeLower == "ammunition";
	local bAlchemical = sTypeLower == "alchemical items";
	local bToolKits = sTypeLower == "tool kits";
	local bGeneral = sTypeLower == "general gear";
	local bCrafting = sTypeLower == "crafting";
	local bCraftingDiagrams = false;
	local bCrafting = sTypeLower:match("crafting");
	local bSubstances = sTypeLower == "substances";
	local bFormulae = sTypeLower == "formulae";
	local bServicesOrLodging = false;
	local bArmorEnhancements = sTypeLower == "armor enhancements";
	local bMount = false;

	if bGeneral then
		if sSubtypeLower == "services" or sSubtypeLower == "lodging" then
			bServicesOrLodging = true;
		end
	end

	if sSubtypeLower == "saddles" or sSubtypeLower == "blinders" or sSubtypeLower == "saddlebags" or sSubtypeLower == "barding" then
		bMount = true;
	end

	if bCrafting then
		if sSubtypeLower:find("diagrams") then
			bCrafting = false;
			bCraftingDiagrams = true;
		end
	end

	if bArmorEnhancements then
		bArmor = false;
	end

	local bSection1 = false;
	if Session.IsHost then
		if updateControl("nonid_name", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_name", false);
	end
	if (Session.IsHost or not bID) then
		if updateControl("nonidentified", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonidentified", false);
	end

	local bSection2 = false;
	if updateControl("type", bReadOnly, bID) then bSection2 = true; end
	if updateControl("subtype", bReadOnly, bID) then bSection2 = true; end

	local bSection3 = false;
	if updateControl("damagetype", bReadOnly, bID and (bWeapon or bAmmunition)) then bSection3 = true; end
	if updateControl("weaponaccuracy", bReadOnly, bID and (bWeapon)) then bSection3 = true; end
	if updateControl("availability", bReadOnly, bID and not (bGeneral or bToolKits)) then bSection3 = true; end
	if updateControl("damage", bReadOnly, bID and bWeapon) then bSection3 = true; end
	if updateControl("reliability", bReadOnly, bID and (bWeapon or bAmmunition)) then bSection3 = true; end
	if updateControl("hands", bReadOnly, bID and bWeapon) then bSection3 = true; end
	if updateControl("range", bReadOnly, bID and bWeapon) then bSection3 = true; end
	if updateControl("stoppingpower", bReadOnly, bID and (bArmor or bArmorEnhancements)) then bSection3 = true; end
	if updateControl("armorenhancement", bReadOnly, bID and (bArmor)) then bSection3 = true; end

	if updateControl("rarity", bReadOnly, bID and bCrafting or bSubstances) then bSection3 = true; end
	if updateControl("location", bReadOnly, bID and bCrafting or bSubstances) then bSection3 = true; end
	if updateControl("quantity", bReadOnly, bID and bCrafting) then bSection3 = true; end
	if updateControl("foragedc", bReadOnly, bID and bCrafting or bSubstances) then bSection3 = true; end

	if updateControl("craftingdc", bReadOnly, bID and bCraftingDiagrams or bFormulae) then bSection3 = true; end
	if updateControl("time", bReadOnly, bID and (bCraftingDiagrams or bFormulae)) then bSection3 = true; end
	if updateControl("components", bReadOnly, bID and bCraftingDiagrams or bFormulae) then bSection3 = true; end
	if updateControl("investment", bReadOnly, bID and bCraftingDiagrams) then bSection3 = true; end

	local bSection4 = false;
	if updateControl("effect", bReadOnly, bID and (bWeapon or bArmor or bAmmunition or bAlchemical or bToolKits or bArmorEnhancements or bMount)) then bSection4 = true; end
	if updateControl("resistances", bReadOnly, bID and (bArmorEnhancements)) then bSection4 = true; end
	if updateControl("cover", bReadOnly, bID and bArmor) then bSection4 = true; end
	if updateControl("concealment", bReadOnly, bID and (bWeapon or bAmmunition or bToolKits)) then bSection4 = true; end
	if updateControl("enhancements", bReadOnly, bID and (bWeapon)) then bSection4 = true; end

	if updateControl("encumbrancevalue", bReadOnly, bID and bArmor) then bSection5 = true; end
	if updateControl("weight", bReadOnly, bID and not (bServicesOrLodging or bCraftingDiagrams or bFormulae)) then bSection5 = true; end
	if updateControl("cost", bReadOnly, bID) then bSection5 = true; end

	local bSection6 = bID;
	description.setVisible(bID);
	description.setReadOnly(bReadOnly);

	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	divider3.setVisible((bSection1 or bSection2 or bSection3) and bSection4);
	divider4.setVisible((bSection1 or bSection2 or bSection3 or bSection4 or bSection5) and bSection6);
end
