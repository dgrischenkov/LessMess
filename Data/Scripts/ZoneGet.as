#include "Scripts/ZoneCommon.as"

class ZoneGet : ScriptObject
{
	String ZoneColor;
	String ZoneCargoName;

	private CargoBox@ cargoBox;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");

		ZoneColor = node.vars["ZoneColor"].ToString();
		ZoneCargoName = node.vars["ZoneCargoName"].ToString();

		int zoneType = 0;

		if (ZoneColor == Color_Red) zoneType = 0;
		else if (ZoneColor == Color_Green) zoneType = 1;
		else if (ZoneColor == Color_Blue) zoneType = 2;

		node.GetComponents("StaticSprite2D")[zoneType].enabled = true;

		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = node.name;
	}

	void Update(float timeStep)
	{
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();
		if (nodeA !is node) return;

		if (nodeA.name == node.name)
		{
			CargoBox@ cargoBox_tmp = cast<CargoBox>(nodeB.scriptObject);
			if ( cargoBox_tmp !is null )
				if ( cargoBox_tmp.getColor() == ZoneColor and cargoBox_tmp.getCargoName() == ZoneCargoName )
					@cargoBox = @cargoBox_tmp;
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		if (nodeA.name == node.name) @cargoBox = null;
	}

	CargoBox@ getCargoBox()
	{
		if (cargoBox is null) return null;
		return cargoBox.isEmpty() ? null : cargoBox;
	}
}
