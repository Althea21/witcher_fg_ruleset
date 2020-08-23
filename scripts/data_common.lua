-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--rsname = "PFRPG";
--rsversion = 1;

--function isPFRPG()
--	return true;
--end

-- Abilities (database names)
abilities = {
	"intelligence",
	"reflex",
	"dexterity",
	"body",
	"empathy",
	"crafting",
	"will"
};

ability_ltos = {
	["intelligence"] = "INT",
	["reflex"] = "REF",
	["dexterity"] = "DEX",
	["body"] = "BOD",
	["empathy"] = "EMP",
	["crafting"] = "CRA",
	["will"] = "WIL"
};

ability_stol = {
	["INT"] = "intelligence",
	["REF"] = "reflex",
	["DEX"] = "dexterity",
	["BOD"] = "body",
	["EMP"] = "empathy",
	["CRA"] = "crafting",
	["WIL"] = "will"
};

-- Skill properties

skilldata = {
	["Physique"] = {
			stat = "Body"
		},
	["Endurance"] = {
			stat = "Body"
		},
	["Alchemy"] = {
			stat = "Craft"
		},
	["Crafting"] = {
			stat = "Craft"
		},
	["Disguise"] = {
			stat = "Craft"
		},
	["First Aid"] = {
			stat = "Craft"
		},		
	["Forgery"] = {
			stat = "Craft"
		},
	["Pick Lock"] = {
			stat = "Craft"
		},
	["Trap Crafting"] = {
			stat = "Craft"
		},
	["Archery"] = {
			stat = "Dexterity"
		},
	["Athletics"] = {
			stat = "Dexterity"
		},
	["Crossbow"] = {
			stat = "Dexterity"
		},	
	["Sleigh of Hand"] = {
			stat = "Dexterity"
		},
	["Stealth"] = {
			stat = "Dexterity"
		},
	["Charisma"] = {
			stat = "Empathy"
		},		
	["Deceit"] = {
			stat = "Empathy",
		},
	["Fine Arts"] = {
			stat = "Empathy"
		},
	["Gambling"] = {
			stat = "Empathy"
		},
    ["Grooming and Style"] = {
			stat = "Empathy"
		},
    ["Human Perception"] = {
			stat = "Empathy"
		},
    ["Leadership"] = {
			stat = "Empathy"
		},
    ["Persuasion"] = {
			stat = "Empathy"
		},
    ["Performance"] = {
			stat = "Empathy"
		},
    ["Seduction"] = {
			stat = "Empathy"
		},
    ["Awareness"] = {
			stat = "Intelligence"
		},
    ["Business"] = {
			stat = "Intelligence"
		},
    ["Deduction"] = {
			stat = "Intelligence"
		},
    ["Education"] = {
			stat = "Intelligence"
		},
    ["Common Speech"] = {
			stat = "Intelligence"
		},
    ["Elder Speech"] = {
			stat = "Intelligence"
		},
    ["Dwarven"] = {
			stat = "Intelligence"
		},
    ["Monster Lore"] = {
			stat = "Intelligence"
		},
    ["Social Etiquette"] = {
			stat = "Intelligence"
		},
    ["Streetwise"] = {
			stat = "Intelligence"
		},
    ["Tactics"] = {
			stat = "Intelligence"
		},
    ["Teaching"] = {
			stat = "Intelligence"
		},
    ["Wilderness Survival"] = {
			stat = "Intelligence"
		},
    ["Brawling"] = {
			stat = "Reflex"
		},
    ["Dodge/Escape"] = {
			stat = "Reflex"
		},
    ["Melee"] = {
			stat = "Reflex"
		},
    ["Riding"] = {
			stat = "Reflex"
		},
    ["Sailing"] = {
			stat = "Reflex"
		},
    ["Small Blades"] = {
			stat = "Reflex"
		},
    ["Staff/Spear"] = {
			stat = "Reflex"
		},
    ["Swordmanship"] = {
			stat = "Reflex"
		},
    ["Courage"] = {
			stat = "Will"
		},
    ["Hex Weaving"] = {
			stat = "Will"
		},
    ["Intimidation"] = {
			stat = "Will"
		},
    ["Spell Casting"] = {
			stat = "Will"
		},
    ["Resist Magic"] = {
			stat = "Will"
		},
    ["Resist Coercion"] = {
			stat = "Will"
		},
    ["Ritual Crafting"] = {
			stat = "Will",
		},
}

-- Conditions supported in effect conditionals and for token widgets
conditions = {
	"bleeding", 
	"blinded", 
	"fire",
	"frozen",
	"hallucination",
	"intoxicated",
	"nauseated",
	"poisonned",
	"prone",
	"staggered",
	"suffocating",
	"stunned"
};
