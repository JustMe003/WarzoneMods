require("Catan")
function Client_PresentConfigureUI(rootParent)
	config = Mod.Settings.Config;
    if config == nil then
        config = {};
        config.Recipes = initRecipes();
        config.StartInfantryPerVillage = 3;
        config.Modifiers = initModifiers();
        config.Techs = initDefaultTechs();
    end
end