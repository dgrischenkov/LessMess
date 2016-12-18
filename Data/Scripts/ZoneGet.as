#include "Scripts/GameLogicEventFunc.as"
#include "Scripts/GameLogicMenuFunc.as"

class ZoneGet : ScriptObject
{
	String getBoxNodeName;

	private uint boxCount = 0;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
		GameLogicMenuFunc_updateBoxCount(0);
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName )
		{
			GameLogicMenuFunc_updateBoxCount(++boxCount);

			if (boxCount == 4)
			{
				GameLogicEventFunc_nextLevel();
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName )
		{
			GameLogicMenuFunc_updateBoxCount(--boxCount);
		}
	}
}
