#include "GameLogic.as"

class GameLogicMenu : GameLogic
{
	private Scene@ scene_;

	private UIElement@ uielement_;
	private UIElement@ buttonPlay_;
	private UIElement@ buttonExit_;

	GameLogicMenu(Scene@ scene)
	{
		scene_ = scene;

	    input.mouseVisible = true;

	    XMLFile@ xmlfile = cache.GetResource("XMLFile", "Data/UI/MainMenu.xml");
	    XMLFile@ xmlfileStyle = cache.GetResource("XMLFile", "Data/UI/DefaultStyle.xml");

	    uielement_ = ui.LoadLayout(xmlfile, xmlfileStyle);
	    ui.root.AddChild(uielement_);

	    buttonPlay_ = uielement_.GetChild("Button_play", true);
	    buttonExit_ = uielement_.GetChild("Button_exit", true);

	    SubscribeToEvent(buttonPlay_, "Pressed", "HandlePressed");
	    SubscribeToEvent(buttonExit_, "Pressed", "HandlePressed");
	}

	void HandlePressed(StringHash eventType, VariantMap& eventData)
	{
	    UIElement@ edit = eventData["Element"].GetPtr();

	    if (edit is null) return;

	    if (edit is buttonPlay_)
	    {
	        input.mouseVisible = false;
	        ui.root.RemoveChild(uielement_);
			GameLogic_sceneLoad(scene_, "Scenes/Level01.xml");
	    }

	    if (edit is buttonExit_)
	    {
	        engine.Exit();
	    }
	}
}
