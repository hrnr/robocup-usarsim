class SmokeGlobal extends HeightFog
                              implements(SmokeInterface);   

var(Smoke) float SmokeDensity;
//var HeightFogComponent hfc;

event PostBeginPlay()
{
	SetTimer(1.0, true);
}

simulated
function Timer()
{

}

function float GetDensity(optional vector hitLocation)
{
    return SmokeDensity;
}

function bool IsInsideSmoke( actor a )
{
    return false;
}

function bool SmokeAlwaysBlock()
{
    return false;
}

defaultproperties
{
}
