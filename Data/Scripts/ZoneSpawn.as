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
	String canGetVarName;
	String cargoNodeName_base;

	private Timer timer;
	private XMLFile@ xmlfile;
	private int countObjects;
	private Node@ cargoNode;
	private int nextPause = 500;

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

		if (nodeA !is node and nodeB !is node) return;
		++countObjects;
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA !is node and nodeB !is node) return;
		--countObjects;

		if (countObjects == 0) timer.Reset();

		if (cargoNode !is null)
			if (nodeA is cargoNode.vars["proxyFor"].GetPtr() or nodeB is cargoNode.vars["proxyFor"].GetPtr())
				@cargoNode = null;
	}

	void Update(float timeStep)
	{
		if (countObjects == 0 and timer.GetMSec(false) > nextPause and cargoNode is null) doSpawn();
	}

	private void doSpawn()
	{
		Node@ newNode = scene.CreateChild();
		newNode.temporary = true;

		if (newNode.LoadXML(xmlfile.GetRoot(), true))
		{
			newNode.SetTransform(node.position, node.rotation);
			newNode.vars[canGetVarName] = true;
			@cargoNode = @newNode;
		}

		nextPause = RandomInt(3000,6000);
	}
}
