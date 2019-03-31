-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--rsname = "PFRPG";
--rsversion = 1;

--function isPFRPG()
--	return true;
-end

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

-- Saves
save_ltos = {
	["fortitude"] = "FORT",
	["reflex"] = "REF",
	["will"] = "WILL"
};

save_stol = {
	["FORT"] = "fortitude",
	["REF"] = "reflex",
	["WILL"] = "will"
};

-- Values for wound comparison
healthstatushalf = "bloodied";
healthstatuswounded = "wounded";

-- Values for alignment comparison
alignment_lawchaos = {
	["lawful"] = 1,
	["chaotic"] = 3,
	["lg"] = 1,
	["ln"] = 1,
	["le"] = 1,
	["cg"] = 3,
	["cn"] = 3,
	["ce"] = 3,
};
alignment_goodevil = {
	["good"] = 1,
	["evil"] = 3,
	["lg"] = 1,
	["le"] = 3,
	["ng"] = 1,
	["ne"] = 3,
	["cg"] = 1,
	["ce"] = 3,
};
alignment_neutral = "n";

-- Values for size comparison
creaturesize = {
	["fine"] = -4,
	["diminutive"] = -3,
	["tiny"] = -2,
	["small"] = -1,
	["medium"] = 0,
	["large"] = 1,
	["huge"] = 2,
	["gargantuan"] = 3,
	["colossal"] = 4,
	["f"] = -4,
	["d"] = -3,
	["t"] = -2,
	["s"] = -1,
	["m"] = 0,
	["l"] = 1,
	["h"] = 2,
	["g"] = 3,
	["c"] = 4,
};

-- Values for creature type comparison
creaturedefaulttype = "humanoid";
creaturehalftype = "half-";
creaturehalftypesubrace = "human";
creaturetype = {
	"aberration",
	"animal",
	"construct",
	"dragon",
	"fey",
	"humanoid",
	"magical beast",
	"monstrous humanoid",
	"ooze",
	"outsider",
	"plant",
	"undead",
	"vermin",
};
creaturesubtype = {
	"adlet",
	"aeon",
	"agathion",
	"air",
	"angel",
	"aquatic",
	"archon",
	"asura",
	"augmented",
	"azata",
	"behemoth",
	"catfolk",
	"chaotic",
	"clockwork",
	"cold",
	"colossus",
	"daemon",
	"dark folk",
	"demodand",
	"demon",
	"devil",
	"div",
	"dwarf",
	"earth",
	"elemental",
	"elf",
	"evil",
	"extraplanar",
	"fire",
	"giant",
	"gnome",
	"goblinoid",
	"godspawn",
	"good",
	"great old one",
	"halfling",
	"herald",
	"human",
	"incorporeal",
	"inevitable",
	"kaiju",
	"kami",
	"kasatha",
	"kitsune",
	"kyton",
	"lawful",
	"leshy",
	"living construct",
	"mythic",
	"native",
	"nightshade",
	"oni",
	"orc",
	"protean",
	"psychopomp",
	"qlippoth",
	"rakshasa",
	"ratfolk",
	"reptilian",
	"robot",
	"samsaran",
	"sasquatch",
	"shapechanger",
	"swarm",
	"troop",
	"udaeus",
	"unbreathing",
	"vanara",
	"vishkanya",
	"water",
};

-- Values supported in effect conditionals
conditionaltags = {
};

-- Conditions supported in effect conditionals and for token widgets
-- TODO - Added :1 of :XX to indicate that the condition has a numerical value.  How does this effect code that runs off this for conditional and widgets?
conditions = {
	"accelerated:XX",
	"asleep",
	"blinded", 
	"broken",
	"climbing",
	"concealed",
	"confused",
	"dazzled",
	"dead",
	"deafened",
	"drained:1",
	"dying:1",
	"encumbered",
	"enervated:1",
	"enfeebled:1",
	"entangled", 
	"fascinated",
	"fatigued:1",
	"flat-footed",
	"fleeing",
	"friendly",
	"frightened:1", 
	"grabbed",
	"hampered:XX",
	"helpful",
	"hostile",
	"immobile",
	"indifferent", 
	"paralyzed",
	"petrified",
	"prone", 
	"quick",
	"restrained",
	"sensed",
	"sick:1", 
	"slowed:1", 
	"sluggish:1",
	"stunned",
	"stupefied:1",
	"unconscious",
	"unfriendly",
	"unseen",
	"wounded:1"
};

-- Bonus/penalty effect types for token widgets
bonuscomps = {
	"INIT",
	"ABIL",
	"AC",
	"ATK",
	"CMB",
	"CMD",
	"DMG",
	"DMGS",
	"HEAL",
	"SAVE",
	"SKILL",
	"STR",
	"CON",
	"DEX",
	"INT",
	"WIS",
	"CHA",
	"FORT",
	"REF",
	"WILL"
};

-- Condition effect types for token widgets
-- Code for PFRPG2
condcomps = {
	["blinded"] = "cond_blinded",
	["confused"] = "cond_confused",
	["cowering"] = "cond_cowering",
	["dazed"] = "cond_dazed",
	["dazzled"] = "cond_dazzled",
	["deafened"] = "cond_deafened",
	["entangled"] = "cond_entangled",
	["exhausted"] = "cond_exhausted",
	["fascinated"] = "cond_fascinated",
	["fatigued"] = "cond_fatigued",
	["flatfooted"] = "cond_flatfooted",
	["frightened"] = "cond_frightened",
	["grappled"] = "cond_grappled",
	["helpless"] = "cond_helpless",
	["incorporeal"] = "cond_incorporeal",
	["invisible"] = "cond_invisible",
	["nauseated"] = "cond_nauseated",
	["panicked"] = "cond_panicked",
	["paralyzed"] = "cond_paralyzed",
	["petrified"] = "cond_petrified",
	["pinned"] = "cond_pinned",
	["prone"] = "cond_prone",
	["rebuked"] = "cond_rebuked",
	["shaken"] = "cond_shaken",
	["sickened"] = "cond_sickened",
	["slowed"] = "cond_slowed",
	["stunned"] = "cond_stunned",
	["turned"] = "cond_turned",
	["unconscious"] = "cond_unconscious"
};

-- Other visible effect types for token widgets
othercomps = {
	["CONC"] = "cond_conceal",
	--["TCONC"] = "cond_conceal",
	["SENSED"] = "cond_conceal",
	["PCOVER"] = "cond_cover",
	["COVER"] = "cond_cover",
	["SCOVER"] = "cond_cover",
	["NLVL"] = "cond_nlvl",
	["IMMUNE"] = "cond_immune",
	["RESIST"] = "cond_resist",
	["VULN"] = "cond_vuln",
	["REGEN"] = "cond_regen",
	["FHEAL"] = "cond_fheal",
	["DMGO"] = "cond_ongoing",
	["PERS"] = "cond_ongoing"
};

-- Effect components which can be targeted
targetableeffectcomps = {
	"CONC",
	"SENSED",
	"UNSEEN",
	"SCREENED",
	"COVER",
	"TCOVER",
	"AC",
	"CMD",
	"SAVE",
	"ATK",
	"CMB",
	"DMG",
	"IMMUNE",
	"VULN",
	"RESIST",
	"WEAK"
};

connectors = {
	"and",
	"or"
};

-- Range types supported
rangetypes = {
	"melee",
	"ranged"
};

-- Damage types supported
energytypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative"
};

-- TODO - normalize similar immunities in code.  For example: 	"paralysis" and "paralyzed"
immunetypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"water",
	"nonlethal",	-- SPECIAL DAMAGE TYPES
	"critical",
	"poison",		-- OTHER IMMUNITY TYPES
	"sleep",
	"paralysis",
	"paralyzed",
	"petrification",
	"charm",
	"sleep",
	"fear",
	"disease",
	"mind-affecting",
	"confused",
	-- Added for PFRPG2
	"asleep",
	"death",	-- Covers "death" and "death effects"
	"stun",
	"visual",
	"magic",
	"magical",		-- Used for magical weapons - auto set when weapon added to PC inventory if weapon has a bonus of 1 or more.
	"nonmagical",	-- Covers nonmagical attacks.
	"bleed",
	"polymorph",
	"possession"
};

dmgtypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"water",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative",
	"adamantine", 	-- WEAPON PROPERTY DAMAGE TYPES
	"bludgeoning",
	"cold iron",
	"epic",
	"magic",
	"magical",
	"piercing",
	"silver",
	"slashing",
	"chaotic",		-- ALIGNMENT DAMAGE TYPES
	"evil",
	"good",
	"lawful",
	"nonlethal",	-- MISC DAMAGE TYPE
	"spell",
	"critical",
	"precision",
	"poison",
	"mental", 
	"area",
	"splash",
	"bleed",
	"ghost touch",	-- This is needed for avoiding incorporeal resistances.  Is there a better way to do this?
	"physical",
	"nonmagical"
};

specialdmgtypes = {
	"nonlethal",
	"spell",
	"critical",
	"precision",
	"nonmagical",
	"physical"
};

-- Bonus types supported in power descriptions
bonustypes = {
	"circumstance",
	"conditional",
	"item",
};

savetypes = {
	"fortitude",
	"reflex",
	"will",
};

-- Used to provide a spell school type filter for the Spells campaign data list
-- Also used to match with a save trait to determine if the effect is magical
spellschooltypes = {
	"abjuration",
	"conjuration",
	"divination",
	"enchantment",
	"evocation",
	"illusion",	
	"necromancy",
	"transmutation"
};

-- Magic tradition - matches with a save trait to determine if the effect is magical. spellschooltypes also used.
magictraditions = {
	"arcane",
	"divine",
	"occult",
	"primal"
}

stackablebonustypes = {
--	"circumstance",
--	"dodge"
};

-- Armor class bonus types
-- (Map text types to internal types)
actypes = {
	["dex"] = "dex",
--	["armor"] = "armor",
--	["shield"] = "shield",
--	["natural"] = "natural",
--	["dodge"] = "dodge",
--	["deflection"] = "deflection",
--	["size"] = "size",
	["circumstance"] = "circumstance",
	["conditional"] = "conditional",
	["item"] = "item",
};
acarmormatch = {
	"padded",
	"padded armor",
	"padded barding",
	"leather",
	"leather armor",
	"leather barding",
	"studded leather",
	"studded leather armor",
	"studded leather barding",
	"chain shirt",
	"chain shirt barding",
	"hide",
	"hide armor",
	"hide barding",
	"scale mail",
	"scale mail barding",
	"chainmail",
	"chainmail barding",
	"breastplate",
	"breastplate barding",
	"splint mail",
	"splint mail barding",
	"banded mail",
	"banded mail barding",
	"half-plate",
	"half-plate armor",
	"half-plate barding",
	"full plate",
	"full plate armor",
	"full plate barding",
	"plate barding",
	"bracers of armor",
	"mithral chain shirt",
};
acshieldmatch = {
	"buckler",
	"light shield",
	"light wooden shield",
	"light steel shield",
	"heavy shield",
	"heavy wooden shield",
	"heavy steel shield",
	"tower shield",
};
acdeflectionmatch = {
--	"ring of protection"
};

-- Spell effects supported in spell descriptions.  Base PFRPG2 conditions added.
-- TODO - fine tune for PFRPG2.
spelleffects = {
	"accelerated",
	"asleep",
	"blinded",
	"confused",
	"dazzled",
	"deafened",
	"drained",
	"encumbered",
	"enervated",
	"enfeebled",
	"entangled",
	"fascinated",
	"fatigued",
	"frightened",
	"hampered",
	"paralyzed",
	"petrified",
	"quick";
	"sick",
	"slowed",
	"sluggish",
	"stunned",
	"stupefied",
	"unconscious",
	"flat-footed"
};

-- NPC damage properties
weapondmgtypes = {
	["axe"] = "slashing",
	["battleaxe"] = "slashing",
	["bolas"] = "bludgeoning,nonlethal",
	["chain"] = "piercing",
	["club"] = "bludgeoning",
	["crossbow"] = "piercing",
	["dagger"] = "piercing,slashing",
	["dart"] = "piercing",
	["falchion"] = "slashing",
	["flail"] = "bludgeoning",
	["glaive"] = "slashing",
	["greataxe"] = "slashing",
	["greatclub"] = "bludgeoning",
	["greatsword"] = "slashing",
	["guisarme"] = "slashing",
	["halberd"] = "piercing,slashing",
	["hammer"] = "bludgeoning",
	["handaxe"] = "slashing",
	["javelin"] = "piercing",
	["kama"] = "slashing",
	["kukri"] = "slashing",
	["lance"] = "piercing",
	["longbow"] = "piercing",
	["longspear"] = "piercing",
	["longsword"] = "slashing",
	["mace"] = "bludgeoning",
	["morningstar"] = "bludgeoning,piercing",
	["nunchaku"] = "bludgeoning",
	["pick"] = "piercing",
	["quarterstaff"] = "bludgeoning",
	["ranseur"] = "piercing",
	["rapier"] = "piercing",
	["sai"] = "bludgeoning",
	["sap"] = "bludgeoning,nonlethal",
	["scimitar"] = "slashing",
	["scythe"] = "piercing,slashing",
	["shortbow"] = "piercing",
	["shortspear"] = "piercing",
	["shuriken"] = "piercing",
	["siangham"] = "piercing",
	["sickle"] = "slashing",
	["sling"] = "bludgeoning",
	["spear"] = "piercing",
	["sword"] = {["short"] = "piercing", ["*"] = "slashing"},
	["trident"] = "piercing",
	["urgrosh"] = "piercing,slashing",
	["waraxe"] = "slashing",
	["warhammer"] = "bludgeoning",
	["whip"] = "slashing"
}

naturaldmgtypes = {
	["arm"] = "bludgeoning",
	["bite"] = "piercing,slashing,bludgeoning",
	["butt"] = "bludgeoning",
	["claw"] =  "bludgeoning,slashing",
	["foreclaw"] =  "bludgeoning,slashing",
	["gore"] = "piercing",
	["hoof"] = "bludgeoning",
	["hoove"] = "bludgeoning",
	["horn"] = "piercing",
	["pincer"] = "bludgeoning",
	["quill"] = "piercing",
	["ram"] = "bludgeoning",
	["rock"] = "bludgeoning",
	["slam"] = "bludgeoning",
	["snake"] = "piercing,slashing,bludgeoning",
	["spike"] = "piercing",
	["stamp"] = "bludgeoning",
	["sting"] = "piercing",
	["swarm"] = "piercing,slashing,bludgeoning",
	["tail"] = "bludgeoning",
	["talon"] =  "slashing",
	["tendril"] = "bludgeoning",
	["tentacle"] = "bludgeoning",
	["wing"] = "bludgeoning",
}

-- Skill properties
sensesdata = {
	["Perception"] = {
			stat = "wisdom"
		},	
}

skilldata = {
	["Acrobatics"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Arcana"] = {
			stat = "intelligence"
		},
	["Athletics"] = {
			stat = "strength",
			armorcheckmultiplier = 1
		},
	["Crafting"] = {
			stat = "intelligence"
		},
	["Deception"] = {
			stat = "charisma"
		},
	["Diplomacy"] = {
			stat = "charisma"
		},		
	["Intimidation"] = {
			stat = "charisma"
		},
	["Lore"] = {
			sublabeling = true,
			stat = "intelligence"
		},
	["Medicine"] = {
			stat = "wisdom"
		},
	["Nature"] = {
			stat = "wisdom"
		},
	["Occultism"] = {
			stat = "intelligence"
		},
	["Perception"] = {
			stat = "wisdom"
		},	
	["Performance"] = {
			stat = "charisma"
		},
	["Religion"] = {
			stat = "wisdom"
		},	
	["Society"] = {
			stat = "intelligence"
		},		
	["Stealth"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Survival"] = {
			stat = "wisdom"
		},
	["Thievery"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		}
}

-- Coin labels
currency = { "PP", "GP", "SP", "CP" };

-- Party sheet drop down list data
psabilitydata = {
	"Strength",
	"Dexterity",
	"Constitution",
	"Intelligence",
	"Wisdom",
	"Charisma"
};

pssavedata = {
	"Fortitude",
	"Reflex",
	"Will"
};

psskilldata = {
	"Acrobatics",
	"Bluff",
	"Climb",
	"Diplomacy",
	"Heal",
	"Intimidate",
	"Knowledge (Arcana)",
	"Knowledge (Dungeoneering)",
	"Knowledge (Local)",
	"Knowledge (Nature)",
	"Knowledge (Planes)",
	"Knowledge (Religion)",
	"Perception",
	"Sense Motive",
	"Stealth",
	"Survival"
};

-- PC/NPC Class properties

class_stol = {
	["brb"] = "barbarian",
	["brd"] = "bard",
	["clr"] = "cleric",
	["drd"] = "druid",
	["ftr"] = "fighter",
	["mnk"] = "monk",
	["pal"] = "paladin",
	["rgr"] = "ranger",
	["rog"] = "rogue",
	["sor"] = "sorcerer",
	["wiz"] = "wizard",
};

classdata = {
	-- Core
	["barbarian"] = {
		hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Knowledge (nature) (Int), Perception (Wis), Ride (Dex), Survival (Wis), and Swim (Str)",
	},
	["bard"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 6,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (all) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Spellcraft (Int), Stealth (Dex), and Use Magic Device (Cha)",
	},
	["cleric"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Appraise (Int), Craft (Int), Diplomacy (Cha), Heal (Wis), Knowledge (arcana) (Int), Knowledge (history) (Int), Knowledge (nobility) (Int), Knowledge (planes) (Int), Knowledge (religion) (Int), Linguistics (Int), Profession (Wis), Sense Motive (Wis), and Spellcraft (Int)",
	},
	["druid"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Climb (Str), Craft (Int), Fly (Dex), Handle Animal (Cha), Heal (Wis), Knowledge (geography) (Int), Knowledge (nature) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Spellcraft (Int), Survival (Wis), and Swim (Str)",
	},
	["fighter"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (engineering) (Int), Profession (Wis), Ride (Dex), Survival (Wis), and Swim (Str)",
	},
	["monk"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "good", will = "good", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Escape Artist (Dex), Intimidate (Cha), Knowledge (history) (Int), Knowledge (religion) (Int), Perception (Wis), Perform (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Stealth (Dex), and Swim (Str)",
	},
	["paladin"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Knowledge (nobility) (Int), Knowledge (religion) (Int), Profession (Wis), Ride (Dex), Sense Motive (Wis), and Spellcraft (Int)",
	},
	["ranger"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 6,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Heal (Wis), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (geography) (Int), Knowledge (nature) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Spellcraft (Int), Stealth (Dex), Survival (Wis), and Swim (Str)",
	},
	["rogue"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 8,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (local) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), Swim (Str), and Use Magic Device (Cha)",
	},
	["sorcerer"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Appraise (Int), Bluff (Cha), Craft (Int), Fly (Dex), Intimidate (Cha), Knowledge (arcana) (Int), Profession (Wis), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	["wizard"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Appraise (Int), Craft (Int), Fly (Dex), Knowledge (all) (Int), Linguistics (Int), Profession (Wis), and Spellcraft (Int)",
	},
	-- NPC
	["adept"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Handle Animal (Cha), Heal (Wis), Knowledge (all skills taken individually) (Int), Profession (Wis), Spellcraft (Int), and Survival (Wis)",
	},
	["aristocrat"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Appraise (Int), Bluff (Cha), Craft (Int), Diplomacy (Cha), Disguise (Cha), Handle Animal (Cha), Intimidate (Cha), Knowledge (all skills taken individually) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Swim (Str), and Survival (Wis)",
	},
	["commoner"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Perception (Wis), Profession (Wis), Ride (Dex), and Swim (Str)",
	},
	["expert"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 6,
		skills = "Any 10",
	},
	["warrior"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Profession (Wis), Ride (Dex), and Swim (Str)",
	},
	-- Base
	["alchemist"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Appraise (Int), Craft (any) (Int), Disable Device (Dex), Fly (Dex), Heal (Wis), Knowledge (arcana) (Int), Knowledge (nature) (Int), Perception (Wis), Profession (Wis), Sleight of Hand (Dex), Spellcraft (Int), Survival (Wis), Use Magic Device (Cha)",
	},
	["cavalier"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Intimidate (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), and Swim (Str)",
	},
	["gunslinger"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Bluff (Cha), Climb (Str), Craft (Int), Handle Animal (Cha), Heal (Wis), Intimidate (Cha), Knowledge (engineering) (Int), Knowledge (local) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Sleight of Hand (Dex), Survival (Wis), and Swim (Str)",
	},
	["inquisitor"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 6,
		skills = "Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disguise (Cha), Heal (Wis), Intimidate (Cha), Knowledge (arcana) (Int), Knowledge (dungeoneering) (Int), Knowledge (nature) (Int), Knowledge (planes) (Int), Knowledge (religion) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), Stealth (Dex), Survival (Wis), and Swim (Str)",
	},
	["magus"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Fly (Dex), Intimidate (Cha), Knowledge (arcana) (Int), Knowledge (dungeoneering) (Int), Knowledge (planes) (Int), Profession (Wis), Ride (Dex), Spellcraft (Int), Swim (Str), and Use Magic Device (Cha)",
	},
	["oracle"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Craft (Int), Diplomacy (Cha), Heal (Wis), Knowledge (history) (Int), Knowledge (planes) (Int), Knowledge (religion) (Int), Profession (Wis), Sense Motive (Wis), and Spellcraft (Int)",
	},
	["summoner"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Fly (Dex), Handle Animal (Cha), Knowledge (all) (Int), Linguistics (Int), Profession (Wis), Ride (Dex), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	["vigilante"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 6,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (engineering) (Int), Knowledge (local) (Int), Perception (Wis), Perform (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), Survival (Wis), Swim (Str), and Use Magic Device (Cha)",
	},
	["witch"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Fly (Dex), Heal (Wis), Intimidate (Cha), Knowledge (arcana) (Int), Knowledge (history) (Int), Knowledge (nature) (Int), Knowledge (planes) (Int), Profession (Wis), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	-- ALternate
	["antipaladin"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Bluff (Cha), Craft (Int), Disguise (Cha), Handle Animal (Cha), Intimidate (Cha), Knowledge (religion) (Int), Profession (Wis), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), and Stealth (Dex)",
	},
	["ninja"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 8,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (local) (Int), Knowledge (nobility) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), Swim (Str), and Use Magic Device (Cha)",
	},
	["samurai"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Intimidate (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), and Swim (Str)",
	},
	-- Hybrid
	["arcanist"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Appraise (Int), Craft (Int), Fly (Dex), Knowledge (all) (Int), Linguistics (Int), Profession (Wis), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	["bloodrager"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Knowledge (arcana) (Int), Perception (Wis), Ride (Dex), Spellcraft (Int), Survival (Wis), and Swim (Str)",
	},
	["brawler"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Escape Artist (Dex), Handle Animal (Cha), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (local) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Sense Motive (Wis), and Swim (Str)",
	},
	["hunter"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "good", will = "bad", skillranks = 6,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Heal (Wis), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (geography) (Int), Knowledge (nature) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Spellcraft (Int), Stealth (Dex), Survival (Wis), and Swim (Str)",
	},
	["investigator"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 6,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Heal (Wis), Intimidate (Cha), Knowledge (all) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Spellcraft (Int), Stealth (Dex), and Use Magic Device (Cha)",
	},
	["shaman"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Craft (Int), Diplomacy (Cha), Fly (Dex), Handle Animal (Cha), Heal (Wis), Knowledge (nature) (Int), Knowledge (planes) (Int), Knowledge (religion) (Int), Profession (Wis), Ride (Dex), Spellcraft (Int), and Survival (Wis)",
	},
	["skald"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Escape Artist (Dex), Handle Animal (Cha), Intimidate (Cha), Knowledge (all) (Int), Linguistics (Int), Perception (Wis), Perform (oratory, percussion, sing, string, wind) (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), Swim (Str), and Use Magic Device (Cha)",
	},
	["slayer"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 6,
		skills = "Acrobatics (Dex), Bluff (Cha), Climb (Str), Craft (Int), Disguise (Cha), Heal (Wis), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (geography) (Int), Knowledge (local) (Int), Perception (Wis), Profession (Wis), Ride (Dex), Sense Motive (Wis), Stealth (Dex), Survival (Wis), and Swim (Str)",
	},
	["swashbuckler"] = {
		hd = "d10", bab = "fast", fort = "bad", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (local) (Int), Knowledge (nobility) (Int), Perception (Wis), Perform (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Sleight of Hand (Dex), and Swim (Str)",
	},
	["warpriest"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Intimidate (Cha), Knowledge (engineering) (Int), Knowledge (religion) (Int), Profession (Wis), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), Survival (Wis), and Swim (Str)",
	},
	-- Unchained
	["unchained barbarian"] = {
		hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Knowledge (nature) (Int), Perception (Wis), Ride (Dex), Survival (Wis), and Swim (Str)",
	},
	["unchained monk"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Climb (Str), Craft (Int), Escape Artist (Dex), Intimidate (Cha), Knowledge (history) (Int), Knowledge (religion) (Int), Perception (Wis), Perform (Cha), Profession (Wis), Ride (Dex), Sense Motive (Wis), Stealth (Dex), and Swim (Str)",
	},
	["unchained rogue"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 8,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Craft (Int), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (dungeoneering) (Int), Knowledge (local) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), Swim (Str), and Use Magic Device (Cha)",
	},
	["unchained summoner"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Fly (Dex), Handle Animal (Cha), Knowledge (all) (Int), Linguistics (Int), Profession (Wis), Ride (Dex), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	-- Prestige Core
	["arcane archer"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Perception (Wis), Ride (Dex), Stealth (Dex), and Survival (Wis)",
	},
	["arcane trickster"] = {
		bPrestige = true, hd = "d6", bab = "slow", fort = "bad", ref = "good", will = "good", skillranks = 4,
		skills = "Acrobatics (Dex), Appraise (Int), Bluff (Cha), Climb (Str), Diplomacy (Cha), Disable Device (Int), Disguise (Cha), Escape Artist (Dex), Knowledge (Int), Perception (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Spellcraft (Int), Stealth (Dex), and Swim (Str)",
	},
	["assassin"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Bluff (Cha), Climb (Str), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Linguistics (Int), Perception (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), Swim (Str), and Use Magic Device (Cha)",
	},
	["dragon disciple"] = {
		bPrestige = true, hd = "d12", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Diplomacy (Cha), Escape Artist (Dex), Fly (Dex), Knowledge (all skills taken individually) (Int), Perception (Wis), and Spellcraft (Int)",
	},
	["duelist"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "bad", ref = "good", will = "bad", skillranks = 4,
		skills = "Acrobatics (Dex), Bluff (Cha), Escape Artist (Dex), Perception (Wis), Perform (Cha), and Sense Motive (Wis)",
	},
	["eldritch knight"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Knowledge (arcana) (Int), Knowledge (nobility) (Int), Linguistics (Int), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), and Swim (Str)",
	},
	["loremaster"] = {
		bPrestige = true, hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Appraise (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Knowledge (all skills taken individually) (Int), Linguistics (Int), Perform (Cha), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	["mystic theurge"] = {
		bPrestige = true, hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Knowledge (arcana) (Int), Knowledge (religion) (Int), Sense Motive (Wis), and Spellcraft (Int)",
	},
	["pathfinder chronicler"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 8,
		skills = "Appraise (Int), Bluff (Cha), Diplomacy (Cha), Disguise (Cha), Escape Artist (Dex), Intimidate (Cha), Knowledge (all skills, taken individually) (Int), Linguistics (Int), Perception (Wis), Perform (Cha), Ride (Dex), Sense Motive (Wis), Sleight of Hand (Dex), Survival (Wis), and Use Magic Device (Cha)",
	},
	["shadowdancer"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 6,
		skills = "Acrobatics (Dex), Bluff (Cha), Diplomacy (Cha), Disguise (Cha), Escape Artist (Dex), Perception (Wis), Perform (Cha), Sleight of Hand (Dex), and Stealth (Dex)",
	},
	-- Prestige APG
	["battle herald"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Bluff (Cha), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Intimidate (Cha), Knowledge (engineering) (Int), Knowledge (history) (Int), Knowledge (local) (Int), Knowledge (nobility) (Int), Perception ( Wis), Profession (Wis), Ride (Dex), and Sense Motive (Wis)",
	},
	["holy vindicator"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Climb (Str), Heal (Wis), Intimidate (Cha), Knowledge (planes) (Int), Knowledge (religion) (Int), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), and Swim (Str)",
	},
	["horizon walker"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 6,
		skills = "Climb (Str), Diplomacy (Cha), Handle Animal (Cha), Knowledge (geography) (Int), Knowledge (nature) (Int), Knowledge (the planes) (Int), Linguistics (Int), Perception (Wis), Stealth (Dex), Survival (Wis), and Swim (Str)",
	},
	["master chymist"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 2,
		skills = "Acrobatics (Dex), Climb (Str), Escape Artist (Dex), Intimidate (Cha), Knowledge (dungeoneering) (Int), Sense Motive (Wis), Stealth (Dex), and Swim (Str)",
	},
	["master spy"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 6,
		skills = "Bluff (Cha), Diplomacy (Cha), Disable Device (Dex), Disguise (Cha), Escape Artist (Dex), Knowledge (all) (Int), Linguistics (Int), Perception (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Stealth (Dex), and Use Magic Device (Cha)",
	},
	["nature warden"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Climb (Str), Handle Animal (Cha), Heal (Wis), Knowledge (geography) (Int), Knowledge (nature) (Int), Perception (Wis), Ride (Dex), Sense Motive (Wis), Survival (Wis), and Swim (Str)",
	},
	["rage prophet"] = {
		bPrestige = true, hd = "d10", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Climb (Str), Heal (Wis), Intimidate (Cha), Knowledge (history) (Int), Knowledge (religion) (Int), Sense Motive (Wis), Spellcraft (Int), and Swim (Str)",
	},
	["stalwart defender"] = {
		bPrestige = true, hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Acrobatics (Dex), Climb (Str), Intimidate (Cha), Perception (Wis), and Sense Motive (Wis)",
	},
};
