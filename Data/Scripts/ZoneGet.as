class ZoneGet : ScriptObject
{
	String getBoxNodeName;

	private uint boxCount = 0;

	private Scene@ newScene; // TODO ???

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName )
		{
			++boxCount;
			log.Warning(boxCount);

			if (boxCount == 3)
			{
				newScene = Scene("Level02");
			    newScene.LoadXML(cache.GetFile("Scenes/Level02.xml"));
			    renderer.viewports[0] = Viewport(newScene, newScene.GetChild("PlayerCamera").GetComponent("Camera"));
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName ) { --boxCount; }
	}
}
