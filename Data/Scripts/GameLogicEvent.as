#include "GameLogic.as"

class GameLogicEvent : GameLogic
{
	private Scene@ scene_;
	private int currentLevel = 1;

	GameLogicEvent(Scene@ scene)
	{
		scene_ = scene;
	}

	void InnerEvent(StringHash eventType, VariantMap& eventData)
	{
		if (eventData.Contains("next_level"))
		{
			++currentLevel;

		    if (eventData["next_level"].GetBool())
	    	{
		        GameLogic_sceneLoad(scene_, "Scenes/Level0" + currentLevel + ".xml");
	    	}
	    }
	}
}
