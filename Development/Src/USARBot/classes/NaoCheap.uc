/*
 * Aldebaran Nao robot.
 * 
 * This version uses a simple (cheap) box collision model.
 * 
 */

class NaoCheap extends Nao config(USAR);


defaultproperties
{
	Begin Object Name=BodyItem
		Mesh=StaticMesh'Nao.MeshLo.naobody'
	End Object

	Begin Object Name=Head
		Mesh=StaticMesh'Nao.MeshLo.naohead'
	End Object

	Begin Object Name=LUpperArm
		Mesh=StaticMesh'Nao.MeshLo.naolupperarm'
	End Object

	Begin Object Name=RUpperArm
		Mesh=StaticMesh'Nao.MeshLo.naorupperarm'
	End Object

	Begin Object Name=LLowerArm
		Mesh=StaticMesh'Nao.MeshLo.naollowerarm'
	End Object

	Begin Object Name=RLowerArm
		Mesh=StaticMesh'Nao.MeshLo.naorlowerarm'
	End Object

	Begin Object Name=LThigh
		Mesh=StaticMesh'Nao.MeshLo.naolthigh'
	End Object

	Begin Object Name=RThigh
		Mesh=StaticMesh'Nao.MeshLo.naorthigh'
	End Object

	Begin Object Name=LShank
		Mesh=StaticMesh'Nao.MeshLo.naolshank'
	End Object

	Begin Object Name=RShank
		Mesh=StaticMesh'Nao.MeshLo.naorshank'
	End Object

	Begin Object Name=LFoot
		Mesh=StaticMesh'Nao.MeshLo.naolfoot'
	End Object
	PartList.Add(LFoot)

	Begin Object Name=RFoot
		Mesh=StaticMesh'Nao.MeshLo.naorfoot'
	End Object
}