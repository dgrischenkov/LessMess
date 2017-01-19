#include "Scripts/ZoneCommon.as"

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
