class PlayerVehicle : ScriptObject
{
	uint forceToMove = 1;
	uint forceToRotate = 1;

	String cargoNodeName_base;
	String nodeNameLock;
	String selfNodeNameLock;
	String selfNodeNameGet;
	String selfSpriteNode;
	String selfGLeftNode;
	String selfGRightNode;
	String canGetVarName;

	private Vector3 spriteScaleOrigin;
	private Node@ cargoBoxNode;

	void DelayedStart()
	{
		spriteScaleOrigin = node.GetChild(selfSpriteNode).scale;

		Node@ nodeDst = node;
		Node@ nodeSrcL = node.GetChild(selfGLeftNode);
		Node@ nodeSrcR = node.GetChild(selfGRightNode);
		Node@ nodeSrcGL = node.GetChild(selfNodeNameGet);
		Node@ nodeSrcGU = node.GetChild(selfNodeNameLock);

		ConstraintRevolute2D@ constraintL;
		ConstraintRevolute2D@ constraintR;
		ConstraintRevolute2D@ constraintGL;
		ConstraintRevolute2D@ constraintGU;

		constraintR = nodeSrcL.CreateComponent("ConstraintRevolute2D");
		constraintR.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintR.anchor = Vector2(node.position.x, node.position.y);
		constraintR.enableLimit = true;

		constraintL = nodeSrcR.CreateComponent("ConstraintRevolute2D");
		constraintL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintL.anchor = Vector2(node.position.x, node.position.y);
		constraintL.enableLimit = true;

		constraintGL = nodeSrcGL.CreateComponent("ConstraintRevolute2D");
		constraintGL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintGL.anchor = Vector2(node.position.x, node.position.y);
		constraintGL.enableLimit = true;

		constraintGU = nodeSrcGU.CreateComponent("ConstraintRevolute2D");
		constraintGU.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintGU.anchor = Vector2(node.position.x, node.position.y);
		constraintGU.enableLimit = true;

	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( cargoBoxNode is null )
		{
			if ( nodeA.name == selfNodeNameGet and nodeB.name.Contains(cargoNodeName_base) and nodeB.vars[canGetVarName].GetBool() )
			{
				node.GetChild(selfSpriteNode).scale = Vector3(1.0f,1.0f,1.0f);

				RigidBody2D@ body = nodeB.GetComponent("RigidBody2D");
				body.bodyType = BT_DYNAMIC;

				ConstraintRevolute2D@ constraint;
				constraint = nodeB.CreateComponent("ConstraintRevolute2D");
				constraint.otherBody = node.GetComponent("RigidBody2D");
				constraint.anchor = Vector2(node.position.x, node.position.y);
				constraint.enableLimit = true;

				@cargoBoxNode = @nodeB;
			}
		}
		else
		{
			if ( nodeA.name == selfNodeNameLock and nodeB.name == nodeNameLock )
			{
				node.GetChild(selfSpriteNode).scale = spriteScaleOrigin;

				RigidBody2D@ body = cargoBoxNode.GetComponent("RigidBody2D");
				body.bodyType = BT_STATIC;

				cargoBoxNode.RemoveComponent("ConstraintRevolute2D");
				cargoBoxNode.vars[canGetVarName] = false;

				@cargoBoxNode = null;
			}
		}
	}

	void FixedUpdate(float timeStep)
	{
		RigidBody2D@ body = node.GetComponent("RigidBody2D");
/*		RigidBody2D@ bodyL = node.GetChild("G_Left").GetComponent("RigidBody2D");
		RigidBody2D@ bodyR = node.GetChild("G_Right").GetComponent("RigidBody2D");

		Quaternion quatForward = node.rotation;
		Quaternion quatStrafe(0,0,quatForward.eulerAngles.z + strafe);
		Quaternion quatSideL(0,0,quatForward.eulerAngles.z + 90);
		Quaternion quatSideR(0,0,quatForward.eulerAngles.z - 90);

		Vector3 vecForward = quatForward.rotationMatrix * Vector3(0,force,0);
		Vector3 vecOffset  = quatForward.rotationMatrix * Vector3(0,.2f,0);
		Vector3 vecStrafe  = quatStrafe. rotationMatrix * Vector3(0,force,0);
		Vector3 vecSideL   = quatSideL.  rotationMatrix * Vector3(0,20,0);
		Vector3 vecSideR   = quatSideR.  rotationMatrix * Vector3(0,20,0);
*/
		if (input.keyDown[KEY_W])
		{
			Vector3 vec = node.rotation.rotationMatrix * Vector3(0,forceToMove,0);
			body.ApplyForceToCenter( Vector2(vec.x,vec.y), true );
		}

		if (input.keyDown[KEY_S])
		{
			Vector3 vec = node.rotation.rotationMatrix * Vector3(0,-forceToMove,0);
			body.ApplyForceToCenter( Vector2(vec.x,vec.y), true );
		}

		if (input.keyDown[KEY_A])
		{
			body.ApplyTorque( forceToRotate, true );
		}

		if (input.keyDown[KEY_D])
		{
			body.ApplyTorque( -forceToRotate, true );
		}
	}
}
