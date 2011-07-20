class AirRobotCamera extends USARCamera config(USAR);

// this is just to override USARCamera default properties

defaultproperties
{	
	bCollideActors=false
	bCollideWhenPlacing=false
	bCollideWorld=false

	Components.Add(MyLightEnvironment) // if this is missing the camera mesh will be all black
	
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'AirRobot.Camera'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object
}
