#include "Scripts/GameLogicMenu.as"
#include "Scripts/GameLogicEvent.as"
#include "Scripts/GameLogicEventFunc.as"

class GameLogic : ScriptObject
{
	GameLogicMenu@ gameLogicMenu;
	GameLogicEvent@ gameLogicEvent;

	void Start()
	{
		gameLogicMenu = GameLogicMenu(scene, node);
		gameLogicEvent = GameLogicEvent(scene, node);
	}
}
