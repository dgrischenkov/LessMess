#include "Scripts/ProxyNode.as"

mixin class CargoBox_mx
{
	String cargoName;
	int cargoSpriteNumber;
	int capacityTotal;
	int capacityCurrent;
}

class CargoBox_px : ProxyNode, CargoBox_mx
{
	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
		cast<CargoBox>(newScriptObject).cargoName = cast<CargoBox_px>(scriptObject).cargoName;
		cast<CargoBox>(newScriptObject).cargoSpriteNumber = cast<CargoBox_px>(scriptObject).cargoSpriteNumber;
		cast<CargoBox>(newScriptObject).capacityTotal = cast<CargoBox_px>(scriptObject).capacityTotal;
		cast<CargoBox>(newScriptObject).capacityCurrent = cast<CargoBox_px>(scriptObject).capacityCurrent;
	}
}

shared class CargoBox : ScriptObject, CargoBox_mx
{
	String cargoEmptyName;

	void DelayedStart()
	{
		node.GetComponents("StaticSprite2D")[cargoSpriteNumber].enabled = true;
	}

	void Update(float timeStep)
	{
		Text3D@ t = node.GetComponents("Text3D")[0];
		t.text = cargoName + ": " + capacityCurrent + " / " + capacityTotal;

		if (capacityCurrent == 0)
		{
			cargoName = cargoEmptyName;
			node.GetComponents("StaticSprite2D")[cargoSpriteNumber].enabled = false;
			capacityTotal = 0;
		}
	}
}
