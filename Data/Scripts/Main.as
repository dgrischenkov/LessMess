#include "common.as"
#include "Scripts/PlayerVehicle.as"

Scene@ oldScene;
UIElement@ uielement;
UIElement@ Button_play;
UIElement@ Button_exit;

void Start()
{
    log.Open("log.txt");

    SampleStart();

    input.mouseVisible = true;

    XMLFile@ xmlfile = cache.GetResource("XMLFile", "Data/UI/MainMenu.xml");
    XMLFile@ xmlfileStyle = cache.GetResource("XMLFile", "Data/UI/DefaultStyle.xml");

    uielement = ui.LoadLayout(xmlfile, xmlfileStyle);
    ui.root.AddChild(uielement);

    Button_play = uielement.GetChild("Button_play", true);
    Button_exit = uielement.GetChild("Button_exit", true);

    SubscribeToEvents();
}

void SubscribeToEvents()
{
    SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
    SubscribeToEvent("innerEvent", "HandleInnerEvent");

    SubscribeToEvent(Button_play, "Pressed", "HandleWheelButtons");
    SubscribeToEvent(Button_exit, "Pressed", "HandleWheelButtons");
}

void HandleWheelButtons(StringHash eventType, VariantMap& eventData) 
{
    UIElement@ edit = eventData["Element"].GetPtr();

    if (edit is null) return;

    if (edit is Button_play) 
    {
        input.mouseVisible = false;
        ui.root.RemoveChild(uielement);
        
	    oldScene = Scene("Level01");
	    oldScene.LoadXML(cache.GetFile("Scenes/Level01.xml"));
	    renderer.viewports[0] = Viewport(oldScene, oldScene.GetChild("PlayerCamera").GetComponent("Camera"));
    }


    if (edit is Button_exit) 
    {
        engine.Exit();
    }
}

void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
{
    if (input.keyDown[KEY_SPACE])
        cast<PhysicsWorld2D>(oldScene.GetComponent("PhysicsWorld2D")).DrawDebugGeometry();
}

void HandleInnerEvent(StringHash eventType, VariantMap& eventData)
{
	if (eventData["next_level"].GetBool())
	{
	    oldScene.LoadXML(cache.GetFile("Scenes/Level02.xml"));
	    renderer.viewports[0] = Viewport(oldScene, oldScene.GetChild("PlayerCamera").GetComponent("Camera"));
	}
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
