class SmokeVolumeConstantDensityInfo extends FogVolumeConstantDensityInfo;

/* Attach this density information object to all FogVolumes. */
event PostBeginPlay()
{
    local int i;
    local SmokeRegional rsm;
	Super.PostBeginPlay();
		
    for(i=0; i < DensityComponent.FogVolumeActors.Length; i++)
    {
		rsm = SmokeRegional(DensityComponent.FogVolumeActors[i]);
		if (rsm != none) {
			rsm.DensityInfo = self;
		}
    }
}
