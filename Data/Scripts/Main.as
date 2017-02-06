#include "common.as"

#include "Scripts/GameLogicMenu.as"
#include "Scripts/GameLogicEvent.as"

Scene@ global_scene;

GameLogicMenu@ gameLogicMenu;
GameLogicEvent@ gameLogicEvent;

void Start()
{
    log.Open("log.txt");

    SampleStart();

    global_scene = Scene();
    gameLogicMenu = GameLogicMenu(global_scene);
    gameLogicEvent = GameLogicEvent(global_scene);

    SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
    SubscribeToEvent("innerEvent", "HandleInnerEvent");
}

void HandleInnerEvent(StringHash eventType, VariantMap& eventData)
{
    gameLogicMenu.InnerEvent(eventType, eventData);
    gameLogicEvent.InnerEvent(eventType, eventData);
}

void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
{
    if (input.keyDown[KEY_SPACE])
    {
        PhysicsWorld2D@ physicsWorld2D = global_scene.GetComponent("PhysicsWorld2D");
        if (physicsWorld2D !is null) physicsWorld2D.DrawDebugGeometry();
    }
}
