class ProxyNode : ScriptObject
{
	String sourceXML;

	void copyMixinPart(ScriptObject@ newScriptObject, ScriptObject@ scriptObject)
	{
	}

	void DelayedStart()
	{
		XMLFile@ xmlfile = cache.GetResource("XMLFile", sourceXML);
		if (xmlfile is null) return;

		Node@ newNode = scene.CreateChild();

		if (newNode.LoadXML(xmlfile.GetRoot(), true))
		{
			copyMixinPart(newNode.scriptObject, node.scriptObject);
			log.Info("ProxyNode: load successful, filename \"" + sourceXML + "\"");
		}

		for (uint i = 0; i < node.vars.values.length; ++i)
		{
			StringHash shash = node.vars.keys[i];
			newNode.vars[shash] = node.vars.values[i];
		}

		node.vars["proxyFor"] = newNode;

		newNode.SetTransform(node.position, node.rotation);
		newNode.name = node.name;

		// newNode.temporary = true;
		scene.RemoveChild(node);
	}
}
