//#exec OBJ LOAD FILE=..\Textures\USARSim_Objects_Textures.utx

class VicColActor extends StaticMeshActor config(USAR);

var String boneName;
var FileLog BumpLog;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
}

function fLog(string x, string RobotName)
{
    local string filename;
    filename = RobotName$"-VictimBumps";

    if(BumpLog == None)
    {
        BumpLog = spawn(class'FileLog');
        if(BumpLog != None)
        {
            BumpLog.OpenLog(filename);
            BumpLog.Logf(x);
        }
        else
        {
            LogInternal(x);
        }
    }
    else
    {
        BumpLog.Logf(x);
    }
}

function Touch( actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
   local Actor CurParent, OldParent;
   local string RobotName;
   local USARVehicle touchingRobot;
   local BotDeathMatch UsarGame;
   UsarGame = BotDeathMatch(WorldInfo.Game);

   if (UsarGame!=None && UsarGame.bLogVictimRobotCol) {
      CurParent = Other.Owner;

      // Bug Fix: the projected light is counted as a touch, when it should not be
      if(Other.IsA('USARHeadLight'))
          return;

      while ( ( CurParent !=  None ) && ( ! CurParent.IsA('USARVehicle') ) ) {
      	 OldParent = CurParent;
    	 CurParent = CurParent.Owner;
      }

   	  touchingRobot = USARVehicle(CurParent);

      if ( ( touchingRobot == None ) || ( touchingRobot.Controller == None )  ) {
        return;
      }

      //RobotName = USARRemoteBot(touchingRobot.Controller).RobotName; dropped USARRemoteBot in the port

      //fLog("Touch:"@Owner.Class@" "@boneName@" "@RobotName@" "@Other.Class@" "@Level.TimeSeconds, RobotName);
   }
}

function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
   local Actor CurParent,OldParent;
   local string RobotName;
   local USARVehicle touchingRobot;
   local BotDeathMatch UsarGame;
   UsarGame = BotDeathMatch(WorldInfo.Game);

   if (UsarGame!=None && UsarGame.bLogVictimRobotCol) {
      CurParent = Other.Owner;

      // Bug Fix: the projected light is counted as a bump, when it should not be
      if(Other.IsA('USARHeadLight'))
          return;

      while ( ( CurParent !=  None ) && ( ! CurParent.IsA('USARVehicle') ) ) {
      	 OldParent = CurParent;
	     CurParent = CurParent.Owner;
      }

      touchingRobot = USARVehicle(CurParent);

      if ( ( touchingRobot == None ) || ( touchingRobot.Controller == None ) )
        return;

      //RobotName = USARRemoteBot(touchingRobot.Controller).RobotName; dropped USARRemoteBot in the port

      //fLog("Bump:"@Owner.Class@" "@boneName@" "@RobotName@" "@Other.Class@" "@Level.TimeSeconds, RobotName);
   }
}

defaultproperties
{
     DrawScale=0.75
     StaticMesh=StaticMesh'USARSim_Objects_Meshes.VictCollision.StandBox'
     bStatic=False
     bNoDelete=False
     Physics=PHYS_None
     Skins(0)=Texture'USARSim_Objects_Textures.VictCollisionc.FullTrans';
}
