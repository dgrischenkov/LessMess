#include "Scripts/ProxyNode.as"

mixin class ZoneSpawn_mx
{
	String spawnBoxXML = "Objects/CargoBox_XX.xml";
}

class ZoneSpawn_px : ProxyNode, ZoneSpawn_mx
{
	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
		cast<ZoneSpawn>(newScriptObject).spawnBoxXML = cast<ZoneSpawn_px>(scriptObject).spawnBoxXML;
	}
}

class ZoneSpawn : ScriptObject, ZoneSpawn_mx
{
	private Timer timer;
	private XMLFile@ xmlfile;
	private bool needSpawn = true;

	void DelayedStart()
	{
		xmlfile = cache.GetResource("XMLFile", spawnBoxXML);
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		if ( nodeA is node ) { needSpawn = false; }
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		if ( nodeA is node ) { needSpawn = true; }
	}

    void FixedUpdate(float timeStep)
    {
    	if ( timer.GetMSec(false) > 4000 )
    	{
    		timer.Reset();
		    if (needSpawn and (xmlfile !is null))
		    	doSpawn();
	    }
	}

	private void doSpawn()
	{
        Node@ newNode = scene.CreateChild();
        newNode.temporary = true;

        if (newNode.LoadXML(xmlfile.GetRoot(), true))
			newNode.SetTransform(node.position, node.rotation);
	}
}
