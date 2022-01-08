--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
function getItemIsIdentified(vRecord, vDefault)
	return LibraryData.getIDState("item", vRecord, true);
end

function getItemRecordDisplayClass(vNode)
	local sRecordDisplayClass = "item";
	if vNode then
		local sBasePath, sSecondPath = UtilityManager.getDataBaseNodePathSplit(vNode);
		if sBasePath == "reference" then
			if sSecondPath == "equipment" then
				local sTypeLower = StringManager.trim(DB.getValue(DB.getPath(vNode, "type"), ""):lower());
				if sTypeLower == "weapons" then
					sRecordDisplayClass = "reference_weapon";
				elseif sTypeLower == "armor" then
					sRecordDisplayClass = "reference_armor";
				else
					sRecordDisplayClass = "reference_equipment";
				end
			else
				sRecordDisplayClass = "reference_magicitem";
			end
		end
	end
	return sRecordDisplayClass;
end

function isItemIdentifiable(vNode)
	return (getItemRecordDisplayClass(vNode) == "item");
end

aRecordOverrides = {
	-- CoreRPG Overrides
	["item"] = {
		fIsIdentifiable = isItemIdentifiable,
		aDataMap = { "item", "reference.equipment", "reference.magicitemdata" },
		fRecordDisplayClass = getItemRecordDisplayClass,
		aRecordDisplayClasses = { "item", "reference_magicitem", "reference_armor", "reference_misc", "reference_cybernetics", "reference_weapon" },
		aGMListButtons = { "button_item_armor", "button_item_weapons" };
		aPlayerListButtons = { "button_item_armor", "button_item_weapons" };
		aCustomFilters = {
			["Type"] = { sField = "type" },
		},
	},
};

aListViews = {
	["item"] = {
		["armor"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "stoppingpower", sType = "number", sHeadingRes = "item_grouped_label_stoppingpower", sTooltipRes = "item_grouped_tooltip_stoppingpower", nWidth=40, bCentered=true, nSortOrder=1 },
				{ sName = "availability", sType = "string", sHeadingRes = "item_grouped_label_availability", sTooltipRes = "item_grouped_tooltip_availability", nWidth=70, bCentered=true },
				{ sName = "armorenhancement", sType = "number", sHeadingRes = "item_grouped_label_armorenhancement", sTooltipRes = "item_grouped_tooltip_armorenhancement", bCentered=true },
				{ sName = "effect", sType = "string", sHeadingRes = "item_grouped_label_effect", nWidth=150, bWrapped=true },
				{ sName = "encumbrancevalue", sType = "number", sHeadingRes = "item_grouped_label_encumbrancevalue", sTooltipRes = "item_grouped_tooltip_encumbrancevalue", nWidth=100, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_grouped_label_weight", sTooltipRes = "item_grouped_tooltip_weight", nWidth=30, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Armor" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Light Armor", "Medium Armor", "Heavy Armor", "Shield" },
		},
		["weapon"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "damagetype", sType = "string", sHeadingRes = "item_grouped_label_damagetype", nWidth=50, bCentered=true },
				{ sName = "weaponaccuracy", sType = "number", sHeadingRes = "item_grouped_label_wa", nWidth=40, bCentered=true },
				{ sName = "availability", sType = "string", sHeadingRes = "item_grouped_label_availability", nWidth=60, bCentered=true },
				{ sName = "damage", sType = "string", sHeadingRes = "item_grouped_label_damage", nWidth=60, bCentered=true },
				{ sName = "reliability", sType = "number", sHeadingRes = "item_grouped_label_reliability", nWidth=60, bCentered=true },
				{ sName = "hands", sType = "number", sHeadingRes = "item_grouped_label_hands", nWidth=50, bCentered=true },
				{ sName = "range", sType = "string", sHeadingRes = "item_grouped_label_range", nWidth=60, bCentered=true },
				{ sName = "effect", sType = "string", sHeadingRes = "item_grouped_label_effect", nWidth=150, bWrapped=true },
				{ sName = "concealment", sType = "string", sHeadingRes = "item_grouped_label_concealment", nWidth=50, bCentered=true },
				{ sName = "enhancements", sType = "number", sHeadingRes = "item_grouped_label_enhancements", nWidth=40, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_grouped_label_weight", sTooltipRes = "item_grouped_tooltip_weight", nWidth=30, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Weapon" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Swords", "Small Blades", "Axes", "Bludgeons", "Pole Arms", "Staves", "Thrown Weapons", "Bows", "Crossbows" },
		},
	},
};

function onInit()
	LibraryData.setCustomFilterHandler("item_isidentified", getItemIsIdentified);

	LibraryData.overrideRecordTypes(aRecordOverrides);
	LibraryData.setRecordViews(aListViews);
end







