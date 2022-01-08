--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function isArmor(vRecord)
	local bIsArmor = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end

	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

	if (sTypeLower == "armor") then
		bIsArmor = true;
	end

	return bIsArmor, sTypeLower, sSubtypeLower;
end

function isWeapon(vRecord)
	local bIsWeapon = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end

	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

	if (sTypeLower == "weapon") or (sSubtypeLower == "weapon") then
		bIsWeapon = true;
	end
	if sSubtypeLower == "ammunition" then
		bIsWeapon = false;
	end

	return bIsWeapon, sTypeLower, sSubtypeLower;
end

function isRefBaseItemClass(sClass)
	return StringManager.contains({"reference_armor", "reference_weapon", "reference_equipment", "reference_mountsandotheranimals", "reference_waterbornevehicles", "reference_vehicle"}, sClass);
end

function addItemToList2(sClass, nodeSource, nodeTarget, nodeTargetList)
	if LibraryData.isRecordDisplayClass("item", sClass) then
		if sClass == "reference_equipment" and DB.getChildCount(nodeSource, "subitems") > 0 then
			local bFound = false;
			for _,v in pairs(DB.getChildren(nodeSource, "subitems")) do
				local sSubClass, sSubRecord = DB.getValue(v, "link", "", "");
				local nSubCount = DB.getValue(v, "count", 1);
				if LibraryData.isRecordDisplayClass("item", sSubClass) then
					local nodeNew = ItemManager.addItemToList(nodeTargetList, sSubClass, sSubRecord);
					if nodeNew then
						bFound = true;
						if nSubCount > 1 then
							DB.setValue(nodeNew, "count", "number", DB.getValue(nodeNew, "count", 1) + nSubCount - 1);
						end
					end
				end
			end
			if bFound then
				return false;
			end
		end

		DB.copyNode(nodeSource, nodeTarget);
		DB.setValue(nodeTarget, "locked", "number", 1);

		-- Set the identified field
		if sClass == "reference_magicitem" then
			DB.setValue(nodeTarget, "isidentified", "number", 0);
		else
			DB.setValue(nodeTarget, "isidentified", "number", 1);
		end

		return true;
	end

	return false;
end

