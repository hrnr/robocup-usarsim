Interface SmokeInterface;

function float GetDensity(optional vector hitLocation);
function bool IsInsideSmoke( actor a );
function bool SmokeAlwaysBlock();
