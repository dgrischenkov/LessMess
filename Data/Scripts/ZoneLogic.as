#include "Scripts/GameLogicEventFunc.as"
#include "Scripts/GameLogicMenuFunc.as"

const String Color_Red = "box_red";
const String Color_Green = "box_green";
const String Color_Blue = "box_blue";

const String CargoName_A = "A";
const String CargoName_B = "B";

class Dispetcher
{
	VariantMap notesCargo;

	bool canIGetThisBox(int ZoneType, int ZoneMashineNumber)
	{
		String cargoStr = ZoneType + "-" + ZoneMashineNumber;

		if (notesCargo[cargoStr].GetFloat() <= 100.0f)
		{
			notesCargo[cargoStr] = notesCargo[cargoStr].GetFloat() + 100.0f;
			return true;
		}

		return false;
	}

	float getCargoState(int ZoneType, int ZoneMashineNumber)
	{
		String cargoStr = ZoneType + "-" + ZoneMashineNumber;
		return notesCargo[cargoStr].GetFloat();
	}

	void updateCargoState(int ZoneType, int ZoneMashineNumber, float deltaState)
	{
		String cargoStr = ZoneType + "-" + ZoneMashineNumber;
		notesCargo[cargoStr] = notesCargo[cargoStr].GetFloat() - deltaState;

		if (notesCargo[cargoStr].GetFloat() < .0f)
			notesCargo[cargoStr] = .0f;
	}

	void loseBox(int ZoneType, int ZoneMashineNumber)
	{
		String cargoStr = ZoneType + "-" + ZoneMashineNumber;
		notesCargo[cargoStr] = notesCargo[cargoStr].GetFloat() - 100.0f;

		if (notesCargo[cargoStr].GetFloat() < .0f)
			notesCargo[cargoStr] = .0f;
	}
}

Dispetcher dispetcher;

uint boxCount = 0;

class ZoneGet : ScriptObject
{
	String getBoxNodeName;

	private int zoneType = 0;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
		GameLogicMenuFunc_updateBoxCount(0);

		zoneType = node.vars["ZoneType"].GetInt();

		node.GetComponents("StaticSprite2D")[zoneType].enabled = true;
	}

	void Update(float timeStep)
	{
		dispetcher.updateCargoState(node.vars["ZoneType"].GetInt(), node.vars["ZoneMashineNumber"].GetInt(), timeStep * 5.0f);
		float cargoState = dispetcher.getCargoState(node.vars["ZoneType"].GetFloat(), node.vars["ZoneMashineNumber"].GetInt());

		Node@ nodeProgress = node.GetChild("ZoneGetProgress");
		nodeProgress.scale2D = Vector2(cargoState / 100.f, 0.2);
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();
		if (nodeA !is node) return;

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName and nodeA.vars["ZoneType"].GetInt() == nodeB.vars["boxType"].GetInt() )
		{
			if (dispetcher.canIGetThisBox(nodeA.vars["ZoneType"].GetInt(), nodeA.vars["ZoneMashineNumber"].GetInt()))
			{
				GameLogicMenuFunc_updateBoxCount(++boxCount);

				if (boxCount == 400)
				{
					GameLogicEventFunc_nextLevel();
				}
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();
		if (nodeA !is node) return;

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName and nodeA.vars["ZoneType"].GetInt() == nodeB.vars["boxType"].GetInt() )
		{
			dispetcher.loseBox(nodeA.vars["ZoneType"].GetInt(), nodeA.vars["ZoneMashineNumber"].GetInt());
			GameLogicMenuFunc_updateBoxCount(--boxCount);
		}
	}
}

class ZoneSpawn : ScriptObject
{
	String spawnBoxXML;
	String spawnBoxNodeName;

	// setup this as node vars:
	// String spawnBoxColor;
	// String spawnBoxCargoName;

	private Timer timer;
	private XMLFile@ xmlfile;
	private bool doSpawn = true;

	void DelayedStart()
	{
		xmlfile = cache.GetResource("XMLFile", spawnBoxXML);
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == spawnBoxNodeName ) { doSpawn = false; }
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == spawnBoxNodeName ) { doSpawn = true; }
	}

    void FixedUpdate(float timeStep)
    {
    	if ( timer.GetMSec(false) > 5000 )
    	{
    		timer.Reset();
		    if (doSpawn and (xmlfile !is null))
		    {
		        Node@ newNode = scene.CreateChild();
		        if (newNode.LoadXML(xmlfile.GetRoot(), true))
		        {
					newNode.SetTransform(node.position, node.rotation);
					cast<CargoBox>(newNode.scriptObject).setProperties(
						node.vars["spawnBoxColor"].ToString(),
						node.vars["spawnBoxCargoName"].ToString());
		        }
		        newNode.temporary = true;
	    	}
	    }
	}
}

class CargoBox : ScriptObject
{
	private String boxColor;
	private String boxCargoName;
	private int portions = 0;

	void DelayedStart()
	{
		if (boxColor == Color_Red) portions = 10;
		else if (boxColor == Color_Green) portions = 20;
		else if (boxColor == Color_Blue) portions = 6;
	}

	void setProperties(String boxColor_, String boxCargoName_)
	{

		boxColor = boxColor_;
		boxCargoName = boxCargoName_;

		int boxType = 0;

		if (boxColor == Color_Red) boxType = 0;
		else if (boxColor == Color_Green) boxType = 1;
		else if (boxColor == Color_Blue) boxType = 2;

		node.GetComponents("StaticSprite2D")[boxType].enabled = true;

		if (boxCargoName == CargoName_A) boxType = 3;
		else if (boxCargoName == CargoName_B) boxType = 4;

		node.GetComponents("StaticSprite2D")[boxType].enabled = true;
		node.GetComponents("StaticSprite2D")[boxType].enabled = true;
	}

	bool isEmpty()
	{
		return portions == 0 ? true : false;
	}

	void decrasePortions()
	{
		--portions;
	}

	String getColor()
	{
		return boxColor;
	}

	String getCargoName()
	{
		return boxCargoName;
	}
}
