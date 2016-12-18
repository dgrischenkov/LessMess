#include "Scripts/GameLogicEventFunc.as"
#include "Scripts/GameLogicMenuFunc.as"

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

		log.Warning(notesCargo[cargoStr].GetFloat() + " " + deltaState);

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
		        int boxType = RandomInt(3);
		        if (newNode.LoadXML(xmlfile.GetRoot(), true))
		        {
					newNode.SetTransform(node.position, node.rotation);		        	
					newNode.GetComponents("StaticSprite2D")[boxType].enabled = true;
					newNode.vars["boxType"] = boxType;
		        }
		        newNode.temporary = true;
	    	}
	    }
	}
}
