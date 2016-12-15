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
	        newNode.temporary = true;
	    }
	}

    void FixedUpdate(float timeStep)
    {
    	node.position = newNode.position;
    	node.rotation = newNode.rotation;
    	node.scale = newNode.scale;
	}
}
