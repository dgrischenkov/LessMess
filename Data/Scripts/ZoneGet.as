#include "Scripts/ProxyNode.as"

mixin class ZoneGet_mx
{
	String cargoNodeName = "CargoBox_XX";
	int zoneSpriteNumber;
}

class ZoneGet_px : ProxyNode, ZoneGet_mx
{
	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
		cast<ZoneGet>(newScriptObject).cargoNodeName = cast<ZoneGet_px>(scriptObject).cargoNodeName;
		cast<ZoneGet>(newScriptObject).zoneSpriteNumber = cast<ZoneGet_px>(scriptObject).zoneSpriteNumber;
	}
}

shared class ZoneGet : ScriptObject, ZoneGet_mx
{
	private Node@ cargoBox;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");

		node.GetComponents("StaticSprite2D")[zoneSpriteNumber].enabled = true;

		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = cargoNodeName;
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();
		if (nodeA is node and nodeB.name == cargoNodeName) @cargoBox = @nodeB;
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		if (nodeA is node) @cargoBox = null;
	}

	Node@ getCargoBox()
	{
		return cargoBox;
	}
}
