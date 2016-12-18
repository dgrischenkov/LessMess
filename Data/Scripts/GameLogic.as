void GameLogic_sceneLoad(Scene@ scene, const String& sourceXML)
{
	scene.LoadXML(cache.GetFile(sourceXML));
    renderer.viewports[0] = Viewport(scene, scene.GetChild("PlayerCamera").GetComponent("Camera"));
}

class GameLogic
{
	void InnerEvent(StringHash eventType, VariantMap& eventData)
	{
	}
}
