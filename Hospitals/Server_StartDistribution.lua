require("DistributeStructures");

function Server_StartDistribution(game, standing)
	standing = distributeStructure(game, standing, Mod.Settings.numberOfHospitals, WL.StructureType.Hospital);
end