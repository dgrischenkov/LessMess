class ProxyNode : ScriptObject
{
	String sourceXML;
	private Node@ newNode;

	void DelayedStart()
	{
	    XMLFile@ xmlfile = cache.GetResource("XMLFile", sourceXML);
	    if (xmlfile !is null)
	    {
	        newNode = scene.CreateChild();
	        if (newNode.LoadXML(xmlfile.GetRoot(), true))
	        {
	            newNode.SetTransform(node.position, node.rotation);
	            log.Info("ProxyNode: load successful, filename \"" + sourceXML + "\"");
	        }
	    }

	    for (uint i = 0; i < node.vars.values.length; ++i)
	    {
	    	StringHash shash = node.vars.keys[i];
	    	newNode.vars[shash] = node.vars.values[i];
	    }

	    newNode.name = node.name;

	    scene.RemoveChild(node);
	}
}
