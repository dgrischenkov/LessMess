#include "Scripts/ZoneCommon.as"

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