void Utils_sceneLoad(Scene@ scene, Node@ node, const String& sourceXML)
{
	scene.LoadXML(cache.GetFile(sourceXML));
	scene.AddChild(node);
    renderer.viewports[0] = Viewport(scene, scene.GetChild("PlayerCamera").GetComponent("Camera"));
}
