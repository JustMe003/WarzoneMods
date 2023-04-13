function Server_Created(game, settings)
	s = settings;
    s.MultiAttack = true;
    s.AllowPercentageAttacks = true;
    settings = s;
end