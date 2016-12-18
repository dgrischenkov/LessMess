void GameLogicMenuFunc_updateBoxCount(uint boxCount)
{
	VariantMap vmap;
	vmap["boxCount"] = boxCount;
	SendEvent("innerEvent", vmap);
}
