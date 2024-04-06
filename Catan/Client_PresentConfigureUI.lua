require("Catan")
function Client_PresentConfigureUI(rootParent)
	config = Mod.Settings.Config;
    if config == nil then
        config = {};
        config.Recipes = initRecipes();
        config.WarriorsPerVillage = 5;
    end
end