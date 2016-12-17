#include "Utils.as"

class GameLogicEvent
{
	private Scene@ scene_;
	private Node@ node_;

	GameLogicEvent(Scene@ scene, Node@ node)
	{
		scene_ = scene;
		node_ = node;

	    SubscribeToEvent("innerEvent", "HandleInnerEvent");
	}

	void HandleInnerEvent(StringHash eventType, VariantMap& eventData)
	{
	    if (eventData["next_level"].GetBool())
	    {
	        Utils_sceneLoad(scene_, node_, "Scenes/Level02.xml");
	    }
	}
}
