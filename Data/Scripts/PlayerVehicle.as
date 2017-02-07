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

	String weelFrontLeftNodeName;
	String weelFrontRightNodeName;
	String weelRearLeftNodeName;
	String weelRearRightNodeName;

	private RigidBody2D@ bodySrcWFL;
	private RigidBody2D@ bodySrcWFR;
	private RigidBody2D@ bodySrcWRL;
	private RigidBody2D@ bodySrcWRR;

	private Node@ nodeWFL;
	private Node@ nodeWFR;
	private Node@ nodeWRL;
	private Node@ nodeWRR;

	private Vector3 spriteScaleOrigin;
	private Node@ cargoBoxNode;

	private float defaultLinearDamping = 4.0f;
	private float defaultAngularDamping = 0.0f;

	private float stopLinearDamping = 80.0f;
	private float forceDefault = 8.0f;

	private float strafe;
	private float force;

	private bool isReverse;


	private ConstraintRevolute2D@ constraintL;
	private ConstraintRevolute2D@ constraintR;
	private ConstraintRevolute2D@ constraintGL;
	private ConstraintRevolute2D@ constraintGU;

	private ConstraintPrismatic2D@ constraintWFL;
	private ConstraintPrismatic2D@ constraintWFR;
	private ConstraintRevolute2D@ constraintWRL;
	private ConstraintRevolute2D@ constraintWRR;


	void DelayedStart()
	{
		spriteScaleOrigin = node.GetChild(selfSpriteNode).scale;

		Node@ nodeDst = node;

		Node@ nodeSrcL = node.GetChild(selfGLeftNode);
		Node@ nodeSrcR = node.GetChild(selfGRightNode);
		Node@ nodeSrcGL = node.GetChild(selfNodeNameGet);
		Node@ nodeSrcGU = node.GetChild(selfNodeNameLock);

		nodeWFL = node.GetChild(weelFrontLeftNodeName);
		nodeWFR = node.GetChild(weelFrontRightNodeName);
		nodeWRL = node.GetChild(weelRearLeftNodeName);
		nodeWRR = node.GetChild(weelRearRightNodeName);

		bodySrcWFL = node.GetChild(weelFrontLeftNodeName).GetComponent("RigidBody2D");
		bodySrcWFR = node.GetChild(weelFrontRightNodeName).GetComponent("RigidBody2D");
		bodySrcWRL = node.GetChild(weelRearLeftNodeName).GetComponent("RigidBody2D");
		bodySrcWRR = node.GetChild(weelRearRightNodeName).GetComponent("RigidBody2D");

		bodySrcWFL.linearDamping = defaultLinearDamping;
		bodySrcWFR.linearDamping = defaultLinearDamping;
		bodySrcWRL.linearDamping = defaultLinearDamping;
		bodySrcWRR.linearDamping = defaultLinearDamping;

		bodySrcWFL.angularDamping = defaultAngularDamping;
		bodySrcWFR.angularDamping = defaultAngularDamping;
		bodySrcWRL.angularDamping = defaultAngularDamping;
		bodySrcWRR.angularDamping = defaultAngularDamping;


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


		constraintWFL = nodeDst.CreateComponent("ConstraintPrismatic2D");
		constraintWFL.otherBody = bodySrcWFL;
		constraintWFL.anchor = nodeWFL.worldPosition2D;
		constraintWFL.enableLimit = true;

		constraintWFR = nodeDst.CreateComponent("ConstraintPrismatic2D");
		constraintWFR.otherBody = bodySrcWFR;
		constraintWFR.anchor = nodeWFR.worldPosition2D;
		constraintWFR.enableLimit = true;

		constraintWRL = nodeDst.CreateComponent("ConstraintRevolute2D");
		constraintWRL.otherBody = bodySrcWRL;
		constraintWRL.anchor = nodeWRL.worldPosition2D;

		constraintWRR = nodeDst.CreateComponent("ConstraintRevolute2D");
		constraintWRR.otherBody = bodySrcWRR;
		constraintWRR.anchor = nodeWRR.worldPosition2D;


	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	}

	void Stop()
	{
		node.RemoveComponent(constraintL);
		node.RemoveComponent(constraintR);
		node.RemoveComponent(constraintGL);
		node.RemoveComponent(constraintGU);

		node.RemoveComponent(constraintWFL);
		node.RemoveComponent(constraintWFR);
		node.RemoveComponent(constraintWRL);
		node.RemoveComponent(constraintWRR);
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

	private Vector2 getWorldDirection2D(Node@ node_)
	{
		Vector3 vec = node_.worldRotation.rotationMatrix * Vector3(0, 1, 0);
		return Vector2(vec.x, vec.y);
	}

	private Vector2 getNewLinearVelocity(Node@ node_)
	{
		RigidBody2D@ body = node_.GetComponent("RigidBody2D");
		Vector2 velocity = body.linearVelocity;
		Vector2 direction = getWorldDirection2D(node_);
		return direction * velocity.DotProduct( direction );
	}

	void FixedUpdate(float timeStep)
	{
		force = input.keyDown[KEY_W] ? forceDefault : 0.0f;

		if (isReverse) force *= -1;

		if (input.keyPress[KEY_R]) isReverse = !isReverse;

		if (input.keyDown[KEY_S])
		{
			bodySrcWFL.linearDamping = stopLinearDamping;
			bodySrcWFR.linearDamping = stopLinearDamping;
		}
		else
		{
			bodySrcWFL.linearDamping = defaultLinearDamping;
			bodySrcWFR.linearDamping = defaultLinearDamping;
		}

			 if (input.keyDown[KEY_D]) strafe -= ( strafe > 0 ) ? 0.6f : 0.4f;
		else if (input.keyDown[KEY_A]) strafe += ( strafe < 0 ) ? 0.6f : 0.4f;
		else
		{
			if ( strafe < 0 ) strafe += 0.5f;
			if ( strafe > 0 ) strafe -= 0.5f;
		}

		if (strafe < -60.0f) strafe = -60.0f;
		if (strafe > 60.0f) strafe = 60.0f;

		nodeWRL.rotation = Quaternion(0,0,strafe);
		nodeWRR.rotation = Quaternion(0,0,strafe);

		bodySrcWFL.linearVelocity = getNewLinearVelocity(nodeWFL);
		bodySrcWFR.linearVelocity = getNewLinearVelocity(nodeWFR);
		bodySrcWRL.linearVelocity = getNewLinearVelocity(nodeWRL);
		bodySrcWRR.linearVelocity = getNewLinearVelocity(nodeWRR);

		Vector3 vecWRL_force = nodeWRL.worldRotation.rotationMatrix * Vector3(0, force, 0);
		Vector3 vecWRR_force = nodeWRR.worldRotation.rotationMatrix * Vector3(0, force, 0);

		bodySrcWRL.ApplyForceToCenter( Vector2(vecWRL_force.x, vecWRL_force.y), true );
		bodySrcWRR.ApplyForceToCenter( Vector2(vecWRR_force.x, vecWRR_force.y), true );
	}
}
