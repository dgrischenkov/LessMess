#include "GameLogic.as"

class GameLogicMenu : GameLogic
{
	private Scene@ scene_;

	private UIElement@ uielement_;
	private UIElement@ buttonPlay_;
	private UIElement@ buttonExit_;
	private Text@ textScoreCount_;
	private Text@ textTimeCount_;

	private uint boxCount_;
	private uint boxNeed_;
	private float timeCount_;
	private uint currentLevel_;


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

			XMLFile@ xmlfile = cache.GetResource("XMLFile", "Data/UI/ScoreBar.xml");
			XMLFile@ xmlfileStyle = cache.GetResource("XMLFile", "Data/UI/DefaultStyle.xml");
			uielement_ = ui.LoadLayout(xmlfile, xmlfileStyle);
			ui.root.AddChild(uielement_);

			textScoreCount_ = uielement_.GetChild("TextScoreCount", true);
			textTimeCount_ = uielement_.GetChild("TextTimeCount", true);

			GameLogic_sceneLoad(scene_, "Scenes/Level01.xml");
			boxCount_ = 0;
			boxNeed_ = 64;
			timeCount_ = 300.0f;
			currentLevel_ = 1;
		}

		if (edit is buttonExit_)
		{
			engine.Exit();
		}
	}

	void InnerEvent(StringHash eventType, VariantMap& eventData)
	{
		if (eventData.Contains("boxCount"))
		{
			boxCount_ += eventData["boxCount"].GetUInt();

			if (boxCount_ >= boxNeed_)
			{
				scene_.RemoveAllComponents();
				scene_.RemoveAllChildren();

				if (currentLevel_ == 1)
				{
					GameLogic_sceneLoad(scene_, "Scenes/Level02.xml");
					boxCount_ = 0;
					boxNeed_ = 64;
					timeCount_ = 500.0f;
					currentLevel_ = 2;
				}
			}

			textScoreCount_.text = boxCount_;
		}

		if (eventData.Contains("timeCount"))
		{
			timeCount_ -= eventData["timeCount"].GetFloat();

			if (timeCount_ < 1.0f)
			{
				timeCount_ = 1.0f;
			}

			textTimeCount_.text = uint(timeCount_ * 10);
		}
	}
}
