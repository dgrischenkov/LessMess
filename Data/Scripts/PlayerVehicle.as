class PlayerVehicle : ScriptObject
{
	uint forceToMove = 1;
	uint forceToRotate = 1;

	private float force;
	private float strafe;
	private float elivate = -0.5f;
	private Vector3 gSpriteScaleOrigin;

	void DelayedStart()
	{
		gSpriteScaleOrigin = node.GetChild("G_Sprite").scale;

		Node@ nodeSrcL = node.GetChild("G_Left");
		Node@ nodeSrcR = node.GetChild("G_Right");
		Node@ nodeDst = node;

		ConstraintRevolute2D@ constraintL;
		ConstraintRevolute2D@ constraintR;

		constraintR = nodeSrcL.CreateComponent("ConstraintRevolute2D");
		constraintR.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintR.anchor = Vector2(1.0f, -1.0f);
		constraintR.lowerAngle = -.1f;
		constraintR.upperAngle =  .0f;
		constraintR.enableLimit = true;

		constraintL = nodeSrcR.CreateComponent("ConstraintRevolute2D");
		constraintL.otherBody = nodeDst.GetComponent("RigidBody2D");
		constraintL.anchor = Vector2(1.0f, -1.0f);
		constraintL.lowerAngle = .0f;
		constraintL.upperAngle = .1f;
		constraintL.enableLimit = true;
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

		bodyL.ApplyForceToCenter( Vector2(vecSideL.x,vecSideL.y) * elivate, true );
		bodyR.ApplyForceToCenter( Vector2(vecSideR.x,vecSideR.y) * elivate, true );

		//body.ApplyForceToCenter( Vector2(vecForward.x,vecForward.y), true );
		//body.ApplyForce( Vector2(vecStrafe.x,vecStrafe.y),
			//Vector2(node.position.x - vecOffset.x, node.position.y - vecOffset.y), true );

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

		if (input.keyDown[KEY_R])
		{
			elivate = -0.5;
			node.GetChild("G_Sprite").scale = gSpriteScaleOrigin;
		}

		if (input.keyDown[KEY_Y])
		{
			elivate = 0.5;
			node.GetChild("G_Sprite").scale = Vector3(1.0f,1.0f,1.0f);
		}
	}
}
