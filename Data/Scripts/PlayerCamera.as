class PlayerCamera : ScriptObject
{
	String playerNodeName;
	bool rotateEnable = false;

	float positionFactor = 1.0f;
	float rotationFactor = .01f;

    void FixedUpdate(float timeStep)
    {
    	Node@ nodePlayer = scene.GetChild(playerNodeName);

    	if (nodePlayer !is null)
    	{
			RigidBody2D@ body = node.GetComponent("RigidBody2D");
			body.ApplyForceToCenter( ( nodePlayer.position2D - node.position2D ) * positionFactor, true );

			if (rotateEnable)
			{
				float roll = 0;
				float rollA = node.rotation.roll;
				float rollB = nodePlayer.rotation.roll;
				
				if ( rollA < 0 ) rollA = rollA + 360;
				if ( rollB < 0 ) rollB = rollB + 360;

				roll = rollB - rollA;

				if ( ( 360 > roll) and (roll >  180) ) roll = roll - 360;
				if ( (-360 < roll) and (roll < -180) ) roll = roll + 360;

		        body.ApplyTorque( roll * rotationFactor, true );
		    }
		}
    }
}
