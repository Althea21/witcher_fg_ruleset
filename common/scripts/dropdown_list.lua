-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

Lookups = {};

function onInit()
    -- PJ Identit�
    Lookups.lkp_sexe = {"Masculin", "F�minin"};
    Lookups.lkp_yeux = {"Bleu", "Bleu gris", "Bleu azure", "Vert", "Vert �meraude", "Marron", "Gris", "Ambre", "Blanc", "Noir"};
    Lookups.lkp_cheveux = {"Blond", "Blond v�nitien", "Ch�tain", "Ch�tain clair", "Ch�tain fonc�", "Brun", "Gris", "Blanc", "Noir", "Roux"};
    Lookups.lkp_peau = {"Blanche", "Hal�e", "Brune", "Noire"};

    -- PJ Identit� 2
    Lookups.lkp_orig_geographique = {"Itin�rant", "Village", "Ville", "M�gapole"};
    Lookups.lkp_orig_sociale = {"D�favoris�e", "Ouvri�re", "Moyenne", "Sup�rieure"};
    Lookups.lkp_formation = {"Sans dipl�me", "Dip. Professionnel", "Dip. g�n. Litt�raire", "Dip. g�n. Scientifique",
                           "Dip. g�n. Technologique", "Et. sup. Litt�raire", "Et. sup. Scientifique", "Et. sup. Technologique",
                            "Form. Militaire base", "Form. Militaire sup.",};
    
    -- Item Identit�
    Lookups.lkp_equipement = {"Armes", "Armures", "Communications", "Drogues", "Dr�nes", "Equipement g�n�ral", "Equipement m�dical", "Vie quotidienne"};
    Lookups.lkp_disponibilite = {"N�ant", "Fr�quent", "Commun", "Rare", "Exceptionel", "March� noir"};
    Lookups.lkp_duree_location = {"Heure", "Jours", "Mois", "Ann�e"};
    Lookups.lkp_mode_tire = {"Coup par coup", "Rafale courte", "Rafale longue", "CC/RC", "CC/RL", "RC/RL", "CC/RC/RL"};
    
    -- Divers
    Lookups.lkp_calc_volume = {"Parall�l�pip�de", "Cylindre", "Sph�re"};
    Lookups.lkp_calc_surface = {"Parall�logramme", "Cercle"};
    
    -- Cit�e
    Lookups.lkp_citee = { "Village", "Village fortifi�", "Ville", "Ville fortifi�e", "Tour", "Ch�teau fort", "For�t", "Pont",
                          "Sous terrain", "Mine", "Cercle de pierres", "Grotte"};
    Lookups.lkp_nation = {"Humain", "Extra-terrestre"};

end
