void GameLogicEventFunc_nextLevel()
{
	VariantMap vmap;
	vmap["next_level"] = true;
	SendEvent("innerEvent", vmap);
}
