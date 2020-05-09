-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerOptions();
end

function registerOptions()
	-- silver / meteorite management
	OptionsManager.registerOption2("MITN", false, "option_header_houserule", "option_label_MITN", "option_entry_cycler", 
		{ labels = "option_val_allmonsters|option_val_novels", values = "allmonsters|novels", baselabel = "option_val_allmonsters", baseval = "allmonsters", default = "allmonsters" });
	-- auto damage armor
	OptionsManager.registerOption2("ADA", false, "option_header_houserule", "option_label_ADA", "option_entry_cycler", 
	{ labels = "option_val_on|option_val_off", values = "on|off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- auto damage weapon
	OptionsManager.registerOption2("ADW", false, "option_header_houserule", "option_label_ADW", "option_entry_cycler", 
	{ labels = "option_val_on|option_val_off", values = "on|off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- CT options
	OptionsManager.registerOption2("SHPC", false, "option_header_combat", "option_label_SHPC", "option_entry_cycler", 
		{ labels = "option_val_on|option_val_off", values = "on|off", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("SHNPC", false, "option_header_combat", "option_label_SHNPC", "option_entry_cycler", 
		{ labels = "option_val_on|option_val_off", values = "on|off", baselabel = "option_val_off", baseval = "off", default = "off" });
end
