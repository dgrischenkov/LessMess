class PlayerVehicle : ScriptObject
{
	uint forceToMove = 1;
	uint forceToRotate = 1;

    void FixedUpdate(float timeStep)
    {
		RigidBody2D@ body = node.GetComponent("RigidBody2D");

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

	    }

	    if (input.keyDown[KEY_Y])
	    {

	    }
    }
}
