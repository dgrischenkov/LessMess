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
        cast<PhysicsWorld2D>(global_scene.GetComponent("PhysicsWorld2D")).DrawDebugGeometry();
}

// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions =
        "<patch>" +
        "    <remove sel=\"/element/element[./attribute[@name='Name' and @value='Button0']]/attribute[@name='Is Visible']\" />" +
        "    <replace sel=\"/element/element[./attribute[@name='Name' and @value='Button0']]/element[./attribute[@name='Name' and @value='Label']]/attribute[@name='Text']/@value\">Zoom In</replace>" +
        "    <add sel=\"/element/element[./attribute[@name='Name' and @value='Button0']]\">" +
        "        <element type=\"Text\">" +
        "            <attribute name=\"Name\" value=\"KeyBinding\" />" +
        "            <attribute name=\"Text\" value=\"PAGEUP\" />" +
        "        </element>" +
        "    </add>" +
        "    <remove sel=\"/element/element[./attribute[@name='Name' and @value='Button1']]/attribute[@name='Is Visible']\" />" +
        "    <replace sel=\"/element/element[./attribute[@name='Name' and @value='Button1']]/element[./attribute[@name='Name' and @value='Label']]/attribute[@name='Text']/@value\">Zoom Out</replace>" +
        "    <add sel=\"/element/element[./attribute[@name='Name' and @value='Button1']]\">" +
        "        <element type=\"Text\">" +
        "            <attribute name=\"Name\" value=\"KeyBinding\" />" +
        "            <attribute name=\"Text\" value=\"PAGEDOWN\" />" +
        "        </element>" +
        "    </add>" +
        "</patch>";
