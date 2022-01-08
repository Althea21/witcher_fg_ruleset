--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
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

function onInit()
	LibraryData.overrideRecordTypes(aRecordOverrides);
end
