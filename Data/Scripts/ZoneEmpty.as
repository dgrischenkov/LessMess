#include "Scripts/ProxyNode.as"

class ZoneEmpty_px : ProxyNode
{
}

shared class ZoneEmpty : ScriptObject
{
	String cargoNodeName_base;
	String nodeNameLock;
	String selfNodeNameLock;

	private Node@ cargoBox;

	void DelayedStart()
	{
		SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA is node and nodeB.name.Contains(cargoNodeName_base))
			@cargoBox = @nodeB;

		if (nodeB.parent is node)
		{
			if (nodeB.name == selfNodeNameLock and nodeA.name == nodeNameLock and @cargoBox !is null)
			{
				scene.RemoveChild(cargoBox);
				@cargoBox = null;
			}
		}
	}
}
