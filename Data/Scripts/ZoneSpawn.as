#include "Scripts/ZoneCommon.as"


class ZoneSpawn : ScriptObject
{
	String spawnBoxXML;
	String spawnBoxNodeName;
	String spawnBoxCargoName;

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
