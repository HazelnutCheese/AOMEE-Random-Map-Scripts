void createCliffsideArea(int areaId=0, int constraint=0, float height=0.0) 
{      
   rmSetAreaSize(areaId, 1.0, 10000);
   rmSetAreaMinBlobs(areaId, 1);
   rmSetAreaMaxBlobs(areaId, 1);
   rmSetAreaMinBlobDistance(areaId, 0.0);
   rmSetAreaMaxBlobDistance(areaId, 0.0);
   rmSetAreaCoherence(areaId, 0.0);
   rmSetAreaCliffType(areaId, "Jungle");
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, false, true, true, 1.5, true);
   rmSetAreaCliffHeight(areaId, -1.0, 0.0, 0.5);
   rmSetAreaBaseHeight(areaId, height);
   rmAddAreaConstraint(areaId, constraint);
}

void main(void)
{
   // Set Loading Screen text and percentage
   rmSetStatusText("",0.01);

   // Set Map Size.
   int sizeL=1.0*sqrt(cNumberNonGaiaPlayers*15000);
   int sizeW=1.0*sqrt(cNumberNonGaiaPlayers*15000);
   rmSetMapSize(sizeL, sizeW);

   // Init map
   rmSetSeaLevel(1);
   rmTerrainInitialize("JungleA");

   // -------------Define constraints
   rmSetStatusText("",0.10);

   // Create a edge of map constraint. 
   // rmXTilesToFraction(2) = 2 units away from map x origin point (aka placed at 2% of the maps X)
   // 1-rmZTilesToFraction(2) = 2 units away from map x end point (aka placed at 98% of the maps X)

   int edgeConstraint = rmCreateBoxConstraint("edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
   int lakeConstraint = rmCreateBoxConstraint("lake constraint", rmXTilesToFraction(0), 0.35-rmZTilesToFraction(0), 0.4-rmXTilesToFraction(0), 0.65-rmZTilesToFraction(0));

   int stayInCenter= 0;

   int cliffsideBackMidConstraint =  rmCreateBoxConstraint(
      "cliffsideBackMidConstraint", 
      1.0-rmXTilesToFraction(0), 
      1.0-rmZTilesToFraction(0), 
      0.8-rmXTilesToFraction(0), 
      0.8-rmZTilesToFraction(0));

   int cliffsideBackLeftConstraint =  rmCreateBoxConstraint(
      "cliffsideBackLeftConstraint", 
      0.2-rmXTilesToFraction(0), 
      1.0-rmZTilesToFraction(0), 
      0.8-rmXTilesToFraction(0), 
      0.8-rmZTilesToFraction(0));

   int cliffsideBackRightConstraint =  rmCreateBoxConstraint(
      "cliffsideBackRightConstraint", 
      1.0-rmXTilesToFraction(0), 
      0.2-rmZTilesToFraction(0), 
      0.8-rmXTilesToFraction(0), 
      0.8-rmZTilesToFraction(0));

   // -------------Define objects
   rmSetStatusText("",0.20);

   // Starting Settlements 

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmSetObjectDefMinDistance(startingSettlementID, 0.0); // needed Boilerplate?
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0); // needed Boilerplate?

   // -------------Done defining objects

   // -------------Setup Teams
   rmSetStatusText("",0.30);

   // Set player starting resources
   for(i=1; <cNumberPlayers)
   {
      rmAddPlayerResource(i, "Food", 300);
      rmAddPlayerResource(i, "Wood", 200);
      rmAddPlayerResource(i, "Gold", 100);
   }

   // Create the lake
   int centerLake=rmCreateArea("lake in the middle");
   rmSetAreaSize(centerLake, 0.175, 0.1);
   rmSetAreaLocation(centerLake, 0.0, 0.5);
   rmSetAreaWaterType(centerLake, "Marsh Pool");
   rmSetAreaBaseHeight(centerLake, 0.0);
   rmSetAreaMinBlobs(centerLake, 1);
   rmSetAreaMaxBlobs(centerLake, 1);
   rmSetAreaMinBlobDistance(centerLake, 0.0);
   rmSetAreaMaxBlobDistance(centerLake, 0.0);
   rmSetAreaSmoothDistance(centerLake, 25);
   rmSetAreaCoherence(centerLake, 1);
   rmBuildAllAreas();

   // Create the team cliffs
   int leftCliffArea = rmCreateArea("leftCliff");
   int rightCliffArea = rmCreateArea("rightCliff");
   int midCliffArea = rmCreateArea("midCliff");

   rmSetTeamArea(0, leftCliffArea);
   rmSetTeamArea(1, rightCliffArea);

   createCliffsideArea(leftCliffArea, cliffsideBackLeftConstraint, 14.0);
   createCliffsideArea(rightCliffArea, cliffsideBackRightConstraint, 14.0);
   createCliffsideArea(midCliffArea, cliffsideBackMidConstraint, 20.0);

   rmSetAreaLocTeam(leftCliffArea, 0);
   rmSetAreaLocTeam(rightCliffArea, 1);
   
   rmBuildAllAreas();

   // Place Players in their lines    
   // We don't know the player order or if there is an equal number
   //    of players on each team. 
   // Therefore we need to keep a counter running of each player in
   //    each team that we place so we can make sure we put them in
   //    the correct x fraction (aka 0.25, 0.5, 0.75 etc).

   int currentTeam1Counter = 1;
   int currentTeam2Counter = 1;

   for(i=1; <cNumberPlayers)
   {
      int teamNum = rmGetPlayerTeam(i);
      int numPlayersOnTeam = rmGetNumberPlayersOnTeam(teamNum);    

      float teamXFractionMultiplier = 1.0 / (numPlayersOnTeam + 1); 
      float xLocation = 0.0;
      float zLocation = 0.0;
      
      if(teamNum == 1)
      {
         xLocation = teamXFractionMultiplier * currentTeam2Counter;
         currentTeam2Counter = currentTeam2Counter + 1;
         
         zLocation = rmZTilesToFraction(10);
      }
      else
      {
         xLocation = teamXFractionMultiplier * currentTeam1Counter;
         currentTeam1Counter = currentTeam1Counter + 1;

         zLocation = 1.0-rmZTilesToFraction(10);
      }

      rmPlacePlayer(i, xLocation, zLocation);
   }   
   rmBuildAllAreas();

   // Place starting settlements.
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);
   
   // Set loading bar to 100%
   rmSetStatusText("",1.0);
}
