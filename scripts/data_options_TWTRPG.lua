-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerOptions();
end

function registerOptions()
	OptionsManager.registerOption2("MITN", false, "option_header_houserule", "option_label_MITN", "option_entry_cycler", 
			{ labels = "option_val_allmonsters|option_val_novels", values = "allmonsters|novels", baselabel = "option_val_allmonsters", baseval = "allmonsters", default = "allmonsters" });
end
