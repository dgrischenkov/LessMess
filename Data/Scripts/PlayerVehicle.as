class PlayerVehicle : ScriptObject
{
	uint forceToMove = 1;
	uint forceToRotate = 1;

	private float force;
	private float strafe;
	private Vector3 gSpriteScaleOrigin;

	private bool lock0;
	private bool lock1;
	private Node@ cargoBoxNode;

	void DelayedStart()
	{
		gSpriteScaleOrigin = node.GetChild("G_Sprite").scale;

		Node@ nodeSrcL = node.GetChild("G_Left");
		Node@ nodeSrcR = node.GetChild("G_Right");
		Node@ nodeSrcGL = node.GetChild("G_Trigger_Load");
		Node@ nodeSrcGU = node.GetChild("G_Trigger_UnLoad");
		Node@ nodeDst = node;

		ConstraintRevolute2D@ constraintL;
		ConstraintRevolute2D@ constraintR;
		ConstraintRevolute2D@ constraintGL;
		ConstraintRevolute2D@ constraintGU;

		constraintR = nodeSrcL.CreateComponent("ConstraintRevolute2D");
		constraintR.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintR.anchor = Vector2(1.0f, -1.0f);
		constraintR.enableLimit = true;

		constraintL = nodeSrcR.CreateComponent("ConstraintRevolute2D");
		constraintL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintL.anchor = Vector2(1.0f, -1.0f);
		constraintL.enableLimit = true;

		constraintGL = nodeSrcGL.CreateComponent("ConstraintRevolute2D");
		constraintGL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintGL.anchor = Vector2(1.0f, -1.0f);
		constraintGL.enableLimit = true;

		constraintGL = nodeSrcGU.CreateComponent("ConstraintRevolute2D");
		constraintGL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintGL.anchor = Vector2(1.0f, -1.0f);
		constraintGL.enableLimit = true;

	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");

		//RigidBody2D@ bodyR = node.GetChild("G_Right").GetComponent("RigidBody2D");
		//bodyR.bodyType = BT_STATIC;
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA.name == "G_Trigger_Load"   and nodeB.name == "ZoneGet_Lock0") lock0 = true;
		if (nodeA.name == "G_Trigger_UnLoad" and nodeB.name == "ZoneGet_Lock1") lock1 = true;

		if (lock0 and lock1 and ( cargoBoxNode !is null ) )
		{
			RigidBody2D@ body = cargoBoxNode.GetComponent("RigidBody2D");
			body.bodyType = BT_STATIC;

			cargoBoxNode.RemoveComponent("ConstraintRevolute2D");
			@cargoBoxNode = null;

			node.GetChild("G_Sprite").scale = gSpriteScaleOrigin;
		}
		else if ( !lock0 and !lock1 and ( cargoBoxNode is null ) and nodeA.name == "G_Trigger_Load" and nodeB.name.Contains("CargoBox"))
		{
			cargoBoxNode = nodeB;
			RigidBody2D@ body = cargoBoxNode.GetComponent("RigidBody2D");
			body.bodyType = BT_DYNAMIC;

			node.GetChild("G_Sprite").scale = Vector3(1.0f,1.0f,1.0f);

			ConstraintRevolute2D@ constraint;
			constraint = cargoBoxNode.CreateComponent("ConstraintRevolute2D");
			constraint.otherBody = node.GetComponent("RigidBody2D");
			constraint.enableLimit = true;
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if (nodeA.name == "G_Trigger_Load"   and nodeB.name == "ZoneGet_Lock0") lock0 = false;
		if (nodeA.name == "G_Trigger_UnLoad" and nodeB.name == "ZoneGet_Lock1") lock1 = false;
	}

	void FixedUpdate(float timeStep)
	{
		RigidBody2D@ body = node.GetComponent("RigidBody2D");
		RigidBody2D@ bodyL = node.GetChild("G_Left").GetComponent("RigidBody2D");
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

		if (input.keyDown[KEY_T])
		{
			Vector3 vec = node.rotation.rotationMatrix * Vector3(0,forceToMove,0);
			body.ApplyForceToCenter( Vector2(vec.x,vec.y), true );
		}

		if (input.keyDown[KEY_G])
		{
			Vector3 vec = node.rotation.rotationMatrix * Vector3(0,-forceToMove,0);
			body.ApplyForceToCenter( Vector2(vec.x,vec.y), true );
		}

		if (input.keyDown[KEY_F])
		{
			body.ApplyTorque( forceToRotate, true );
		}

		if (input.keyDown[KEY_H])
		{
			body.ApplyTorque( -forceToRotate, true );
		}
	}
}
