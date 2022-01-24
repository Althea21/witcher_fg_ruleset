--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
function getItemIsIdentified(vRecord, vDefault)
	local sFred = LibraryData.getIDState("item", vRecord, true);
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
				elseif sTypeLower:find("armor") then
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
		-- aGMListButtons = { "button_item_armor", "button_item_weapons" };
		-- aPlayerListButtons = { "button_item_armor", "button_item_weapons" };
		aGMListButtons = { "button_item_armor", "button_item_weapons", "button_item_crafting_components", "button_item_crafting_diagrams", "button_item_substances" };
		aPlayerListButtons = { "button_item_armor", "button_item_weapons", "button_item_crafting_components", "button_item_crafting_diagrams", "button_item_substances" };
		aCustomFilters = {
			["Type"] = { sField = "type" },
			["SubType"] = { sField = "subtype" },
		},
	},
};

aListViews = {
	["item"] = {
		["armor"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "stoppingpower", sType = "number", sHeadingRes = "item_grouped_label_sp", sTooltipRes = "item_grouped_tooltip_sp", nWidth=30, bCentered=true, nSortOrder=1 },
				{ sName = "availability", sType = "string", sHeadingRes = "item_grouped_label_availability", sTooltipRes = "item_grouped_tooltip_availability", nWidth=70, bCentered=true },
				{ sName = "armorenhancement", sType = "number", sHeadingRes = "item_grouped_label_ae", sTooltipRes = "item_grouped_tooltip_ae", nWidth=30, bCentered=true },
				{ sName = "effect", sType = "string", sHeadingRes = "item_grouped_label_effect", nWidth=150, bWrapped=true },
				{ sName = "cover", sType = "string", sHeadingRes = "item_grouped_label_cover", nWidth=125, bWrapped=true },
				{ sName = "encumbrancevalue", sType = "number", sHeadingRes = "item_grouped_label_ev", sTooltipRes = "item_grouped_tooltip_ev", nWidth=30, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_grouped_label_weight", sTooltipRes = "item_grouped_tooltip_weight", nWidth=30, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Armor" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Light Armor", "Elderfolk Light Armor", "Medium Armor", "Elderfolk Medium Armor", "Heavy Armor", "Elderfolk Heavy Armor", "Light Shields", "Elderfolk Light Shields", "Medium Shields", "Elderfolk Medium Shields", "Heavy Shields", "Elderfolk Heavy Shields" },
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
			aGroupValueOrder = { "Swords", "Elderfolk Swords", "Witcher's Swords", "Small Blades", "Elderfolk Small Blades", "Axes", "Elderfolk Axes", "Bludgeons", "Elderfolk Bludgeons", "Pole Arms", "Elderfolk Pole Arms", "Staves", "Elderfolk Staves", "Thrown Weapons", "Elderfolk Thrown Weapons", "Bows", "Elderfolk Bows", "Crossbows", "Elderfolk Crossbows" },
		},
		["crafting_components"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "rarity", sType = "string", sHeadingRes = "item_grouped_label_rarity", sTooltipRes = "item_grouped_tooltip_rarity", nWidth=60, bCentered=true },
				{ sName = "componentlocation", sType = "string", sHeadingRes = "item_grouped_label_location", sTooltipRes = "item_grouped_tooltip_location", nWidth=140, bCentered=true },
				{ sName = "quantity", sType = "string", sHeadingRes = "item_grouped_label_quantity", sTooltipRes = "item_grouped_tooltip_quantity", nWidth=80, bCentered=true },
				{ sName = "foragedc", sType = "string", sHeadingRes = "item_grouped_label_foragedc", sTooltipRes = "item_grouped_tooltip_foragedc", nWidth=60, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_grouped_label_weight", sTooltipRes = "item_grouped_tooltip_weight", nWidth=30, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Crafting Components" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Crafting Materials", "Hides & Animal Parts", "Alchemical Treatments", "Ingots & Minerals" },
		},
		["crafting_diagrams"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "craftingdc", sType = "number", sHeadingRes = "item_grouped_label_craftingdc", sTooltipRes = "item_grouped_tooltip_craftingdc", nWidth=65, bCentered=true },
				{ sName = "time", sType = "string", sHeadingRes = "item_grouped_label_time", sTooltipRes = "item_grouped_tooltip_time", nWidth=60, bCentered=true },
				{ sName = "components", sType = "string", sHeadingRes = "item_grouped_label_components", sTooltipRes = "item_grouped_tooltip_components", nWidth=200, bWrapped=true },
				{ sName = "investment", sType = "number", sHeadingRes = "item_grouped_label_investment", sTooltipRes = "item_grouped_tooltip_investment", nWidth=65, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Crafting Diagrams" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Ingredient Diagrams - Novice Diagrams", "Ingredient Diagrams - Journeyman Diagrams", "Ingredient Diagrams - Master Diagrams", "Weapon Diagrams - Novice Diagrams", "Weapon Diagrams - Journeyman Diagrams", "Weapon Diagrams - Master Diagrams", "Armor Diagrams - Novice Diagrams", "Armor Diagrams - Journeyman Diagrams", "Armor Diagrams - Master Diagrams", "Elderfolk Weapon Diagrams - Master Diagrams", "Elderfolk Weapon Diagrams - Grand Master Diagrams", "Elderfolk Ammunition Diagrams - Master Diagrams", "Elderfolk Armor Diagrams - Master Diagrams", "Elderfolk Armor Diagrams - Grand Master Diagrams", "Elderfolk Armor Enhancement Diagrams - Novice Diagrams", "Elderfolk Armor Enhancement Diagrams - Journeyman Diagrams", "Elderfolk Armor Enhancement Diagrams - Master Diagrams" },
		},
		["substances"] = {
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "rarity", sType = "string", sHeadingRes = "item_grouped_label_rarity", sTooltipRes = "item_grouped_tooltip_rarity", nWidth=60, bCentered=true },
				{ sName = "componentlocation", sType = "string", sHeadingRes = "item_grouped_label_location", sTooltipRes = "item_grouped_tooltip_location", nWidth=140, bCentered=true },
				{ sName = "quantity", sType = "string", sHeadingRes = "item_grouped_label_quantity", sTooltipRes = "item_grouped_tooltip_quantity", nWidth=80, bCentered=true },
				{ sName = "foragedc", sType = "string", sHeadingRes = "item_grouped_label_foragedc", sTooltipRes = "item_grouped_tooltip_foragedc", nWidth=60, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_grouped_label_weight", sTooltipRes = "item_grouped_tooltip_weight", nWidth=30, bCentered=true },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = {
				{ sDBField = "type", vFilterValue = "Substances" },
				{ sCustom = "item_isidentified" }
			},
			aGroups = { { sDBField = "subtype" } },
			aGroupValueOrder = { "Vitriol", "Rebis", "Aether", "Quebrith", "Hydragenum", "Vermilion", "Sol", "Caelum", "Fulgur" },
		},

	},
};

function onInit()
	LibraryData.setCustomFilterHandler("item_isidentified", getItemIsIdentified);

	LibraryData.overrideRecordTypes(aRecordOverrides);
	LibraryData.setRecordViews(aListViews);
end







