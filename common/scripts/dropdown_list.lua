-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

Lookups = {};

function onInit()
    -- PJ Identité
    Lookups.lkp_sexe = {"Masculin", "Féminin"};
    Lookups.lkp_yeux = {"Bleu", "Bleu gris", "Bleu azure", "Vert", "Vert émeraude", "Marron", "Gris", "Ambre", "Blanc", "Noir"};
    Lookups.lkp_cheveux = {"Blond", "Blond vénitien", "Châtain", "Châtain clair", "Châtain foncé", "Brun", "Gris", "Blanc", "Noir", "Roux"};
    Lookups.lkp_peau = {"Blanche", "Halée", "Brune", "Noire"};

    -- PJ Identité 2
    Lookups.lkp_orig_geographique = {"Itinérant", "Village", "Ville", "Mégapole"};
    Lookups.lkp_orig_sociale = {"Défavorisée", "Ouvrière", "Moyenne", "Supérieure"};
    Lookups.lkp_formation = {"Sans diplôme", "Dip. Professionnel", "Dip. gén. Littéraire", "Dip. gén. Scientifique",
                           "Dip. gén. Technologique", "Et. sup. Littéraire", "Et. sup. Scientifique", "Et. sup. Technologique",
                            "Form. Militaire base", "Form. Militaire sup.",};
    
    -- Item Identité
    Lookups.lkp_equipement = {"Armes", "Armures", "Communications", "Drogues", "Drônes", "Equipement général", "Equipement médical", "Vie quotidienne"};
    Lookups.lkp_disponibilite = {"Néant", "Fréquent", "Commun", "Rare", "Exceptionel", "Marché noir"};
    Lookups.lkp_duree_location = {"Heure", "Jours", "Mois", "Année"};
    Lookups.lkp_mode_tire = {"Coup par coup", "Rafale courte", "Rafale longue", "CC/RC", "CC/RL", "RC/RL", "CC/RC/RL"};
    
    -- Divers
    Lookups.lkp_calc_volume = {"Parallélépipède", "Cylindre", "Sphère"};
    Lookups.lkp_calc_surface = {"Parallélogramme", "Cercle"};
    
    -- Citée
    Lookups.lkp_citee = { "Village", "Village fortifié", "Ville", "Ville fortifiée", "Tour", "Château fort", "Forêt", "Pont",
                          "Sous terrain", "Mine", "Cercle de pierres", "Grotte"};
    Lookups.lkp_nation = {"Humain", "Extra-terrestre"};

end
