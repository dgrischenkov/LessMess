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
	private bool needSpawn;

	void DelayedStart()
	{
		xmlfile = cache.GetResource("XMLFile", spawnBoxXML);
		SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
		doSpawn();
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA is node and nodeB.name.Contains(cargoNodeName_base))
		{
			needSpawn = true;
			timer.Reset();
		}
	}

	void Update(float timeStep)
	{
		if ( needSpawn and timer.GetMSec(false) > 4000 )
		{
			needSpawn = false;
			doSpawn();
		}
	}

	private void doSpawn()
	{
		Node@ newNode = scene.CreateChild();
		newNode.temporary = true;

		if (newNode.LoadXML(xmlfile.GetRoot(), true))
		{
			newNode.SetTransform(node.position, node.rotation);
			newNode.vars[canGetVarName] = true;
		}
	}
}
