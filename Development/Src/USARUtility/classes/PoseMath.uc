class PoseMath extends Object;
struct Pose{
var quat rot;
var vector tran;
};

static final function  Pose PoseInvert(Pose matIn)
{
	local Pose retValue;
	
	retValue.rot = QuatInvert(matIn.rot);
	retValue.tran = QuatRotateVector(retValue.rot, -matIn.tran);
	return retValue;
}

static final function  Pose PosePoseMult( Pose m1, Pose m2 )
{
	local Pose retValue;
	
	retValue.rot = QuatProduct(m1.rot, m2.rot);
	retValue.tran = QuatRotateVector(m1.rot, m2.tran);
	retValue.tran += m1.tran;
	return retValue;
}
