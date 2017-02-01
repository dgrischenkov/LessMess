#include "Scripts/ProxyNode.as"
#include "Scripts/CargoBox.as"
#include "Scripts/ZoneGet.as"

mixin class Mashine_mx
{
	float secondsPerProduct = 7.5f;

	Node@ zoneNode0;
	Node@ zoneNode1;
	Node@ zoneNode2;
	Node@ zoneNode3;

	Node@ zoneNode4;
	Node@ zoneNode5;
	Node@ zoneNode6;
	Node@ zoneNode7;
}

class Mashine_px : ProxyNode, Mashine_mx
{
	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
		cast<Mashine>(newScriptObject).secondsPerProduct = cast<Mashine_px>(scriptObject).secondsPerProduct;

		if ( cast<Mashine_px>(scriptObject).zoneNode0 !is null ) cast<Mashine>(newScriptObject).zoneNode0 = cast<Mashine_px>(scriptObject).zoneNode0.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode1 !is null ) cast<Mashine>(newScriptObject).zoneNode1 = cast<Mashine_px>(scriptObject).zoneNode1.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode2 !is null ) cast<Mashine>(newScriptObject).zoneNode2 = cast<Mashine_px>(scriptObject).zoneNode2.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode3 !is null ) cast<Mashine>(newScriptObject).zoneNode3 = cast<Mashine_px>(scriptObject).zoneNode3.vars["proxyFor"].GetPtr();

		if ( cast<Mashine_px>(scriptObject).zoneNode4 !is null ) cast<Mashine>(newScriptObject).zoneNode4 = cast<Mashine_px>(scriptObject).zoneNode4.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode5 !is null ) cast<Mashine>(newScriptObject).zoneNode5 = cast<Mashine_px>(scriptObject).zoneNode5.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode6 !is null ) cast<Mashine>(newScriptObject).zoneNode6 = cast<Mashine_px>(scriptObject).zoneNode6.vars["proxyFor"].GetPtr();
		if ( cast<Mashine_px>(scriptObject).zoneNode7 !is null ) cast<Mashine>(newScriptObject).zoneNode7 = cast<Mashine_px>(scriptObject).zoneNode7.vars["proxyFor"].GetPtr();
	}
}

class Mashine : ScriptObject, Mashine_mx
{
	private Array<ZoneGet@> zoneGetArray;
	private float currentSecondsPerProduct;

	void DelayedStart()
	{
		if (zoneNode0 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode0.scriptObject));
		if (zoneNode1 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode1.scriptObject));
		if (zoneNode2 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode2.scriptObject));
		if (zoneNode3 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode3.scriptObject));

		if (zoneNode4 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode4.scriptObject));
		if (zoneNode5 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode5.scriptObject));
		if (zoneNode6 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode6.scriptObject));
		if (zoneNode7 !is null) zoneGetArray.Push(cast<ZoneGet>(zoneNode7.scriptObject));
	}

	void Update(float timeStep)
	{
		if ( currentSecondsPerProduct > .0f )
			currentSecondsPerProduct -= timeStep;

		if ( currentSecondsPerProduct < .0f )
			currentSecondsPerProduct = .0f;

		if ( currentSecondsPerProduct == .0f )
		{
	    	VariantMap cargoMap;

	    	for (uint i = 0; i < zoneGetArray.length; ++i)
	    	{
	    		String cargoNodeName = zoneGetArray[i].cargoNodeName;

				if (not cargoMap.Contains(cargoNodeName))
					cargoMap[cargoNodeName] = 0;

				if ( zoneGetArray[i].cargoBox !is null )
				{
	    			CargoBox@ cargoBoxNew = cast<CargoBox>(zoneGetArray[i].cargoBox.scriptObject);

	    			if ( cargoBoxNew.capacityCurrent == 0 )
	    				zoneGetArray[i].changeCargo();

					if ( cargoMap[cargoNodeName] != 0 )
					{
						CargoBox@ cargoBoxOld = cast<CargoBox>(cargoMap[cargoNodeName].GetScriptObject());

		    			if ( cargoBoxOld.capacityCurrent < cargoBoxNew.capacityCurrent )
		    				cargoMap[cargoNodeName] = cargoBoxOld;
	
		    			if ( cargoBoxOld.capacityCurrent == 0 )
		    				cargoMap[cargoNodeName] = cargoBoxNew;
					}
					else cargoMap[cargoNodeName] = cargoBoxNew;
				}
	    	}

	    	bool doDecrase = true;
	    	for (uint i = 0; i < cargoMap.values.length; ++i )
	    	{
	    		if (cargoMap.values[i] == 0)
	    			{ doDecrase = false; break; }

	    		if ( cast<CargoBox>(cargoMap.values[i].GetScriptObject()).capacityCurrent == 0 )
	    			{ doDecrase = false; break; }
	    	}

	    	if (doDecrase)
	    	{
		    	for (uint i = 0; i < cargoMap.values.length; ++i )
		    		cast<CargoBox>(cargoMap.values[i].GetScriptObject()).capacityCurrent -= 1;

	    		currentSecondsPerProduct = secondsPerProduct;
	    	}
	    }

		Text3D@ t = node.GetComponents("Text3D")[0];
        t.text = "seconds: " + ((int( currentSecondsPerProduct * 100 )) / 10) + " / " + (secondsPerProduct * 10);
	}
}
