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

class Mashine : ScriptObject
{
	float secondsPerProduct = 7.5f;

	int powerRed = 1;
	int powerGreen = 1;
	int powerBlue = 1;

	String zoneNodeName0;
	String zoneNodeName1;
	String zoneNodeName2;
	String zoneNodeName3;
	String zoneNodeName4;
	String zoneNodeName5;
	String zoneNodeName6;
	String zoneNodeName7;

	private Array<Node@> zoneNodes;
	private float currentSecondsPerProduct;

	void DelayedStart()
	{
		secondsPerProduct = node.vars["secondsPerProduct"].GetFloat();
		powerRed = node.vars["powerRed"].GetInt();
		powerGreen = node.vars["powerGreen"].GetInt();
		powerBlue = node.vars["powerBlue"].GetInt();

		zoneNodeName0 = node.vars["zoneNodeName0"].ToString();
		zoneNodeName1 = node.vars["zoneNodeName1"].ToString();
		zoneNodeName2 = node.vars["zoneNodeName2"].ToString();
		zoneNodeName3 = node.vars["zoneNodeName3"].ToString();
		zoneNodeName4 = node.vars["zoneNodeName4"].ToString();
		zoneNodeName5 = node.vars["zoneNodeName5"].ToString();
		zoneNodeName6 = node.vars["zoneNodeName6"].ToString();
		zoneNodeName7 = node.vars["zoneNodeName7"].ToString();

		Node@ node0 = scene.GetChild(zoneNodeName0);
		Node@ node1 = scene.GetChild(zoneNodeName1);
		Node@ node2 = scene.GetChild(zoneNodeName2);
		Node@ node3 = scene.GetChild(zoneNodeName3);
		Node@ node4 = scene.GetChild(zoneNodeName4);
		Node@ node5 = scene.GetChild(zoneNodeName5);
		Node@ node6 = scene.GetChild(zoneNodeName6);
		Node@ node7 = scene.GetChild(zoneNodeName7);

		if (node0 !is null) zoneNodes.Push(node0);
		if (node1 !is null) zoneNodes.Push(node1);
		if (node2 !is null) zoneNodes.Push(node2);
		if (node3 !is null) zoneNodes.Push(node3);
		if (node4 !is null) zoneNodes.Push(node4);
		if (node5 !is null) zoneNodes.Push(node5);
		if (node6 !is null) zoneNodes.Push(node6);
		if (node7 !is null) zoneNodes.Push(node7);
	}

	void Update(float timeStep)
	{
		currentSecondsPerProduct -= timeStep;

		if ( currentSecondsPerProduct < .0f )
			currentSecondsPerProduct = .0f;

		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = node.name + "\n" + "powerRed: " + powerRed + "\n" + "powerGreen: " + powerGreen + "\n" + "powerBlue: " + powerBlue + "\n" +
        	"seconds: " + ((int( currentSecondsPerProduct * 100 )) / 10) + " / " + (secondsPerProduct * 10) + "\n" +
        	(cast<ZoneGet>((zoneNodes[0]).scriptObject).getCargoBox() is null ? "-" : "+") + " | " +
        	(cast<ZoneGet>((zoneNodes[1]).scriptObject).getCargoBox() is null ? "-" : "+") + " | " +
        	(cast<ZoneGet>((zoneNodes[2]).scriptObject).getCargoBox() is null ? "-" : "+");

		if ( currentSecondsPerProduct == .0f )
		{
	    	Array<CargoBox@> cargoBoxS;
	    	for (int i = 0; i < zoneNodes.length; ++i)
	    	{
	    		if (zoneNodes[i] is null) continue;
	    		CargoBox@ cargoBox = cast<ZoneGet>(zoneNodes[i].scriptObject).getCargoBox();
	    		if (cargoBox is null)
	    		{
	    			cargoBoxS.Clear();
	    			break;
	    		}
	    		cargoBoxS.Push(cargoBox);
	    	}

	    	for (int i = 0; i < cargoBoxS.length; ++i)
	    	{
	    		int power = 0;

				if (cargoBoxS[i].getColor() == Color_Red) power = powerRed;
				else if (cargoBoxS[i].getColor() == Color_Green) power = powerGreen;
				else if (cargoBoxS[i].getColor() == Color_Blue) power = powerBlue;

	    		cargoBoxS[i].decrasePortions(power);
	    	}

			if ( cargoBoxS.length > 0 )
				currentSecondsPerProduct = secondsPerProduct;
		}
	}
}

class ZoneGet : ScriptObject
{
	String ZoneColor;
	String ZoneCargoName;

	private CargoBox@ cargoBox;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");

		ZoneColor = node.vars["ZoneColor"].ToString();
		ZoneCargoName = node.vars["ZoneCargoName"].ToString();

		int zoneType = 0;

		if (ZoneColor == Color_Red) zoneType = 0;
		else if (ZoneColor == Color_Green) zoneType = 1;
		else if (ZoneColor == Color_Blue) zoneType = 2;

		node.GetComponents("StaticSprite2D")[zoneType].enabled = true;

		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = node.name;
	}

	void Update(float timeStep)
	{
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();
		if (nodeA !is node) return;

		if (nodeA.name == node.name)
		{
			CargoBox@ cargoBox_tmp = cast<CargoBox>(nodeB.scriptObject);
			if ( cargoBox_tmp !is null )
				if ( cargoBox_tmp.getColor() == ZoneColor and cargoBox_tmp.getCargoName() == ZoneCargoName )
					@cargoBox = @cargoBox_tmp;
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		if (nodeA.name == node.name) @cargoBox = null;
	}

	CargoBox@ getCargoBox()
	{
		if (cargoBox is null) return null;
		return cargoBox.isEmpty() ? null : cargoBox;
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
    	if ( timer.GetMSec(false) > 2000 )
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
	private int portionsCurrent = 0;

	void DelayedStart()
	{
		if (boxColor == Color_Red) portionsCurrent = portions = 10;
		else if (boxColor == Color_Green) portionsCurrent = portions = 20;
		else if (boxColor == Color_Blue) portionsCurrent = portions = 6;
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

    void Update(float timeStep)
    {
		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = boxColor + " / " + boxCargoName + "\n" + portionsCurrent + " / " + portions;
    }

	bool isEmpty()
	{
		return portionsCurrent <= 0 ? true : false;
	}

	void decrasePortions(int power)
	{
		portionsCurrent -= power;
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
