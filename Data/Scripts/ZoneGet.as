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
	String nodeNameLock0;
	String nodeNameLock1;
	String selfNodeNameLock0;
	String selfNodeNameLock1;

	private Node@ realCargoBox, valideCargoBox;
	private bool lock0, lock1, isChangeCargo;

	Node@ cargoBox
	{
		get const { return realCargoBox; }
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
		node.GetChild(selfNodeNameLock0).GetComponent("RigidBody2D").enabled = val;
	}

	void changeCargo()
	{
		isChangeCargo = true;

		node.GetComponents("StaticSprite2D")[SPRITE_ON].enabled = false;
		node.GetComponents("StaticSprite2D")[SPRITE_OFF].enabled = true;

		lockEnabled(false);
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (isChangeCargo) return;

		if (nodeB.parent is node)
		{
			if (nodeB.name == selfNodeNameLock0 and nodeA.name == nodeNameLock0) lock0 = true;
			if (nodeB.name == selfNodeNameLock1 and nodeA.name == nodeNameLock1) lock1 = true;

			if (lock0 and lock1 and (valideCargoBox !is null))
			{
				node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = false;
				node.GetComponents("StaticSprite2D")[SPRITE_ON].enabled = true;

				@realCargoBox = @valideCargoBox;
			}
		}

		if (nodeA !is node) return;
		if (!nodeB.name.Contains(cargoNodeName_base)) return;

		if (nodeB.name == cargoNodeName)
		{
			node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = true;
			lockEnabled(true);

			@valideCargoBox = @nodeB;
		}
		else
		{
			node.GetComponents("StaticSprite2D")[SPRITE_NOT].enabled = true;
			lockEnabled(false);

			@valideCargoBox = null;
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA.name == selfNodeNameLock0 and nodeB.name == nodeNameLock0) lock0 = false;
		if (nodeA.name == selfNodeNameLock1 and nodeB.name == nodeNameLock1) lock1 = false;

		if (nodeA !is node) return;
		if (!nodeB.name.Contains(cargoNodeName_base)) return;

		node.GetComponents("StaticSprite2D")[SPRITE_YES].enabled = false;
		node.GetComponents("StaticSprite2D")[SPRITE_NOT].enabled = false;
		node.GetComponents("StaticSprite2D")[SPRITE_ON].enabled = false;
		node.GetComponents("StaticSprite2D")[SPRITE_OFF].enabled = false;

		@realCargoBox = null;
		@valideCargoBox = null;

		isChangeCargo = false;
	}
}
