#include "Scripts/ProxyNode.as"

class ZoneGet_px : ProxyNode
{
	int zoneSpriteNumber;
	String cargoNodeName_postfix;

	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
		cast<ZoneGet>(newScriptObject).zoneSpriteNumber = cast<ZoneGet_px>(scriptObject).zoneSpriteNumber;
		cast<ZoneGet>(newScriptObject).cargoNodeName_postfix = cast<ZoneGet_px>(scriptObject).cargoNodeName_postfix;
	}
}

const int SPRITE_YES = 5;
const int SPRITE_NOT = 6;
const int SPRITE_ON  = 7;
const int SPRITE_OFF = 8;

shared class ZoneGet : ScriptObject
{
	int zoneSpriteNumber;
	String cargoNodeName_base;
	String cargoNodeName_postfix;
	String nodeNameLock;
	String selfNodeNameLock;
	String canGetVarName;

	private bool locked;
	private Node@ realCargoBox;

	Node@ cargoBox
	{
		get const { return locked ? realCargoBox : null; }
		set { log.Error("cargoBox read only!"); }
	}

	String cargoNodeName
	{
		get const { return cargoNodeName_base + cargoNodeName_postfix; }
		set { log.Error("cargoNodeName read only!"); }
	}

	void DelayedStart()
	{
		SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
		SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");

		node.GetComponents("StaticSprite2D")[zoneSpriteNumber].enabled = true;
	}

	private void lockEnabled(bool val)
	{
		node.GetChild(selfNodeNameLock).GetComponent("RigidBody2D").enabled = val;
	}

	void changeCargo()
	{
		lockEnabled(false);
		cargoBox.vars[canGetVarName] = true;
		node.GetComponents("StaticSprite2D")[SPRITE_ON].enabled = false;
		node.GetComponents("StaticSprite2D")[SPRITE_OFF].enabled = true;
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		if (locked) return;

		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA is node and nodeB.name.Contains(cargoNodeName_base))
		{
			if (nodeB.name == cargoNodeName)
			{
				node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = true;
				lockEnabled(true);
				@realCargoBox = @nodeB;
			}
			else
			{
				node.GetComponents("StaticSprite2D")[SPRITE_NOT].enabled = true;
				lockEnabled(false);
			}
		}

		if (nodeB.parent is node)
		{
			if (nodeB.name == selfNodeNameLock and nodeA.name == nodeNameLock and @realCargoBox !is null)
			{
				node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = false;
				node.GetComponents("StaticSprite2D")[SPRITE_ON].enabled = true;
				locked = true;
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA is node and nodeB.name.Contains(cargoNodeName_base))
		{
			if (nodeB.name == cargoNodeName)
			{
				if (locked)
				{
					node.GetComponents("StaticSprite2D")[SPRITE_OFF].enabled = false;
					cargoBox.name = cargoNodeName_base;
					locked = false;
				}
				else
				{
					node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = false;
				}

				@realCargoBox = null;
			}
			else
			{
				if (!locked)
				{
					node.GetComponents("StaticSprite2D")[SPRITE_NOT].enabled = false;
				}
			}
		}
	}
}
