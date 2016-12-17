#include "common.as"
#include "Utils.as"

Scene@ global_scene;
Node@ nodeLogic;

void Start()
{
    log.Open("log.txt");

    SampleStart();

    global_scene = Scene();

    {
        nodeLogic = global_scene.CreateChild("GameLogic");
        ScriptInstance@ scriptInstance = nodeLogic.CreateComponent("ScriptInstance");
        scriptInstance.CreateObject(cache.GetResource("ScriptFile", "Scripts/GameLogic.as"), "GameLogic");
    }

    SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
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
