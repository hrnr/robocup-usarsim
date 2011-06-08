//=============================================================================
// Dead Reckoning.
//=============================================================================
class DeadReckoning extends Object 
    config(USAR);

//-----------------------------------------------------------------------------
// Structurs.

struct DRMovement {
	var float DR_T;
	
	var vector DR_P;
	var vector DR_V;
	var vector DR_A;

	var rotator DR_RP;
	var rotator DR_RV;
	var rotator DR_RA;
};

struct Inf {
	var rotator RotationRate;
	var bool bRotateToDesired;
	var bool bRollToDesired;
	//var bool bCarriedItem;
	var float NetPriority;
};

//-----------------------------------------------------------------------------
// Variables.
var DRMovement start;
var DRMovement current;
var DRMovement cache;
var float deltatime;
var Inf oldInf;
var bool bRunning;
var bool bLFilter;
var bool bRFilter;
var Pawn owner;

var config int PreK;
var config int MaxErr;

var bool bNewBase;
var bool bLocked;
var bool bAutoTurn;

//-----------------------------------------------------------------------------
// Functions.

function Save(Pawn pawnOwner) {
	oldInf.RotationRate = pawnOwner.RotationRate;
	//oldInf.bRotateToDesired = owner.bRotateToDesired;
	//oldInf.bRollToDesired = owner.bRollToDesired;
	//oldInf.bCarriedItem = owner.bCarriedItem;
	oldInf.NetPriority = pawnOwner.NetPriority;
}

function Restore(Pawn pawnOwner) {
	pawnOwner.RotationRate = oldInf.RotationRate;
	//owner.bRotateToDesired = oldInf.bRotateToDesired;
	//owner.bRollToDesired = oldInf.bRollToDesired;
	//owner.bCarriedItem = oldInf.bCarriedItem;
	pawnOwner.NetPriority = oldInf.NetPriority;
}

function SetT(float time) {
	CurL(time);
	CurR(time);

	current.DR_P = owner.Location;
	start.DR_P = current.DR_P;
	start.DR_V = current.DR_V;
	start.DR_A = current.DR_A;
	current.DR_RP = owner.Rotation;
	start.DR_RP = current.DR_RP;
	start.DR_RV = current.DR_RV;
	start.DR_RA = current.DR_RA;
	start.DR_T = time;
	bNewBase=true;
	bLocked=false;
	if (current.DR_RV.Pitch==0 && current.DR_RV.Yaw==0 && current.DR_RV.Roll==0 &&
		current.DR_RA.Pitch==0 && current.DR_RA.Yaw==0 && current.DR_RA.Roll==0)
		bAutoTurn=true;
	//if(oldInf.NetPriority>0) owner.NetPriority = oldInf.NetPriority;
}

function SetDT(float dt) {
	deltatime = dt;
	//current.DR_V = current.DR_V + current.DR_A * dt * 0.5; // init
	//current.DR_RV = current.DR_RV + current.DR_RA * dt * 0.5; // init
}

function SetLP(vector p) {
	start.DR_P = p;
	current.DR_P = p;	
	bLFilter = true;
}

function SetLV(vector v) {
	start.DR_V = v;
	current.DR_V = v;	
}

function SetLA(vector a) {
	start.DR_A = a;
	current.DR_A = a;	
}

function SetRP(rotator p) {
	start.DR_RP = p;
	current.DR_RP = p;	
	bRFilter = false;
	bAutoTurn=false;
	//bRFilter = true;
}

function SetRV(rotator v) {
	start.DR_RV = v;
	current.DR_RV = v;	
	bAutoTurn=false;
}

function SetRA(rotator a) {
	start.DR_RA = a;
	current.DR_RA = a;	
	bAutoTurn=false;
}

function SetL(vector p, vector v, vector a) {
	start.DR_P = p;
	start.DR_V = v;
	start.DR_A = a;
	current.DR_P = p;
	current.DR_V = v;
	current.DR_A = a;
}

function SetR(rotator p, rotator v, rotator a) {
	start.DR_RP = p;
	start.DR_RV = v;
	start.DR_RA = a;
	current.DR_RP = p;
	current.DR_RV = v;
	current.DR_RA = a;
}

function bool setCache() {
	if (!bLocked) {
		cache.DR_P = current.DR_P;
		cache.DR_V = current.DR_V;
		cache.DR_A = current.DR_A;
		return true;
	}
	return false;
}

function bool Recover() {
	if (!bLocked) {
		current.DR_V = cache.DR_V;
		current.DR_A = cache.DR_A;
		return true;
	}
	return false;
}

function Locked() {
	bLocked=true;
}

function UnLocked() {
	bLocked=false;
}

function bool isLocked() {
	return bLocked;
}

function NewBase(bool b) {
	bNewBase=b;
}

function bool isNewBase() {
	return bNewBase;
}

function CurL(float t) {
	local float dt,tmp;
	dt = t - start.DR_T;
	tmp = dt*dt*0.5;
	current.DR_P = start.DR_P + start.DR_V * dt + start.DR_A * tmp;
	current.DR_V = start.DR_V + start.DR_A * dt;
}

function CurR(float t) {
	local float dt,tmp;
	dt = t - start.DR_T;
	tmp = dt*dt*0.5;
	current.DR_RP = start.DR_RP + start.DR_RV * dt + start.DR_RA * tmp;
	current.DR_RV = start.DR_RV + start.DR_RA * dt;
}

function vector PreLP(float t) {
	local float dt,tmp;
	dt = t - start.DR_T;
	tmp = dt*dt*0.5;
	return (start.DR_P + start.DR_V * dt + start.DR_A * tmp);
}

function rotator PreRP(float t) {
	local float dt,tmp;
	dt = t - start.DR_T;
	tmp = dt*dt*0.5;
	return (start.DR_RP + start.DR_RV * dt + start.DR_RA * tmp);
}

function GetL( ) {
	current.DR_V = current.DR_V + current.DR_A * deltatime;
	current.DR_P = current.DR_P + current.DR_V * deltatime;
}

function GetR( ) {
	current.DR_RV = current.DR_RV + current.DR_RA * deltatime;
	current.DR_RP = current.DR_RP + current.DR_RV * deltatime;
}

function vector FGetL( ) {
	local int i;
	local vector v,p;
	
	if (current.DR_V.x==0 && current.DR_V.y==0 && current.DR_V.z==0 &&
	    current.DR_A.x==0 && current.DR_A.y==0 && current.DR_A.z==0 ) // This means we need to forcely relocate a bot
		return current.DR_P;
		
	GetL();
	v = current.DR_V;
	p = current.DR_P;
	for (i=1;i<PreK;i++) {
		v += current.DR_A * deltatime;
		p += v * deltatime;
	}
	return (p-owner.Location)/PreK+owner.Location;
}

function rotator FGetR( ) {
	local int i;
	local rotator rv,rp;

	if (current.DR_RV.pitch==0 && current.DR_RV.yaw==0 && current.DR_RV.roll==0 &&
	    current.DR_RA.pitch==0 && current.DR_RA.yaw==0 && current.DR_RA.roll==0 ) // This means we need to forcely relocate a bot
		return current.DR_RP;

	GetR();
	rv = current.DR_RV;
	rp = current.DR_RP;
	for (i=1;i<PreK;i++) {
		rv += current.DR_RA * deltatime;
		rp += rv * deltatime;
	}
	return (rp-owner.Rotation)/PreK+owner.Rotation;
}


function bool Step(float dt) {
	LogInternal("Step()");
	if (bRunning) {
		deltatime = dt;
		GetR();
		owner.RotationRate=rot(0,0,0);
		owner.SetDesiredRotation(current.DR_RP);
		owner.SetRotation(current.DR_RP);
		GetL();
		return owner.SetLocation(current.DR_P);
	}
}

function bool IsRunning() {
//	LogInternal("DeadReckoning running:"$bRunning$" rp("$current.DR_RP$") rv("$current.DR_RV$") ra("$current.DR_RA$") p("$current.DR_P$") v("$current.DR_V$") a("$current.DR_A$")");
	return bRunning;
}

function init(Pawn act) {
	owner = act;
	SetL(act.Location,act.Velocity,act.Acceleration);
	SetRP(act.Rotation);
}

function Stop() {
	bRunning = false;
	bLFilter = false;
	bRFilter = false;
	// Reset all the args.
	SetL(owner.Location,vect(0,0,0),vect(0,0,0));
	SetR(owner.Rotation,rot(0,0,0),rot(0,0,0));
	Restore(owner);
}

function Begin() {
	bRunning = true;
	bAutoTurn=true;
	Save(owner);
	owner.RotationRate=rot(0,0,0);
	//owner.bRotateToDesired=true;
	//owner.bRollToDesired=true;
	//owner.NetPriority=2.0; // Because we can control remotebot from client, we set the NetPriority lower.
	owner.bCollideWorld=true; // Should I set this?
	// Hack 10JAN03
	//owner.bCarriedItem = true; // Disable replicate Location and Rotation between S/C
		/*
		Region.Zone.ZoneGravity.z=0;
		Region.Zone.ZoneGroundFriction=0;
		Region.Zone.ZoneFluidFriction=0;
		AirControl = 0;
		*/
}

function bool Correct(float time) {
	local rotator dr;
	CurR(time);
	dr = owner.Rotation-current.DR_RP;
	if (bRFilter&& (dr.pitch*dr.pitch+dr.yaw*dr.yaw+dr.roll*dr.roll)<MaxErr*MaxErr*10000) {
		bRFilter=false;
		owner.RotationRate=rot(0,0,0);
		owner.SetDesiredRotation(current.DR_RP);
		owner.SetRotation(current.DR_RP);
	}

	CurL(time);
	if (bLFilter&&VSize(owner.Location-current.DR_P)<MaxErr) {
		bLFilter=false;
		owner.SetLocation(current.DR_P);
	}

	if (VSize(owner.Location-current.DR_P)>1) return false;
	//bRunning=true;
	return true;
}

defaultproperties
{
     //PreK=15 // Moved to config file
     //MaxErr=20 // Moved to config file
}
