void GameLogicMenuFunc_updateBoxCount(uint boxCount)
{
	VariantMap vmap;
	vmap["boxCount"] = boxCount;
	SendEvent("innerEvent", vmap);
}

void GameLogicMenuFunc_updateTimeCount(float timeCount)
{
	VariantMap vmap;
	vmap["timeCount"] = timeCount;
	SendEvent("innerEvent", vmap);
}
