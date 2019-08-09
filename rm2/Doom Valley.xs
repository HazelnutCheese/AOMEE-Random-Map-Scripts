float midCliffSize = 0.0;
float evenTeamCounter = 0.0;
float oddTeamCounter = 0.0;

int numOfOddTeams=0;
int numOfEvenTeams=0;

int numOfOddPlayers=0;
int numOfEvenPlayers=0;

int sizeL=0;
int sizeW=0;

void SetNumOfPlayersOddAndEven()
{
   for(teamNum=0; < cNumberTeams)
   {
      bool isOddTeam = teamNum % 2 == 0;
      
      if(isOddTeam)
      {
         numOfOddPlayers = numOfOddPlayers + rmGetNumberPlayersOnTeam(teamNum);
      }
      else
      {
         numOfEvenPlayers = numOfEvenPlayers + rmGetNumberPlayersOnTeam(teamNum);
      }    
   }
}

void createCliffsideArea(int areaId=0, int constraint=0, float height=0.0) 
{      
   rmSetAreaSize(areaId, 1.0, 10000);
   rmSetAreaMinBlobs(areaId, 1);
   rmSetAreaMaxBlobs(areaId, 1);
   rmSetAreaMinBlobDistance(areaId, 0.0);
   rmSetAreaMaxBlobDistance(areaId, 0.0);
   rmSetAreaCoherence(areaId, 0.0);
   rmSetAreaCliffType(areaId, "Egyptian");
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, false, true, true, 1.5, true);
   rmSetAreaCliffHeight(areaId, -1.0, 0.0, 0.5);
   rmSetAreaBaseHeight(areaId, height);
   rmAddAreaConstraint(areaId, constraint);
}

void createTeamCliffArea()
{
   for(teamNum=0; < cNumberTeams)
   {
      int areaId = rmCreateArea("team"+teamNum);

      bool isOddTeam = teamNum % 2 == 0;
      int numPlayersOnTeam = rmGetNumberPlayersOnTeam(teamNum);    
      int teamSize = 15 + (numPlayersOnTeam * 15);
      int teamSpacing = 15;

      float x1Location = 0.0;
      float x2Location = 0.0;
      float z1Location = 0.0;
      float z2Location = 0.0;

      int teamLength = 30;
      
      float xBorderMod = rmXTilesToFraction(2);
      float zBorderMod = rmZTilesToFraction(2);

      if(isOddTeam)
      {
         float zTeamSize = rmZTilesToFraction(teamSize);
         float zTeamSpacing = rmZTilesToFraction(teamSpacing);
         float xTeamLength = rmXTilesToFraction(teamLength);

         x1Location = 1.0;
         z1Location = oddTeamCounter; 
         x2Location = 1.0 - xTeamLength;
         z2Location = z1Location - zTeamSize;

         oddTeamCounter = z2Location - zTeamSpacing;
      }
      else
      {
         float xTeamSize = rmXTilesToFraction(teamSize);
         float xTeamSpacing = rmXTilesToFraction(teamSpacing);
         float zTeamLength = rmZTilesToFraction(teamLength);

         x1Location = evenTeamCounter; 
         z1Location = 1.0;
         x2Location = x1Location - xTeamSize;
         z2Location = 1.0 - zTeamLength;

         evenTeamCounter = x2Location - xTeamSpacing;
      }

      int areaConstraint =  rmCreateBoxConstraint(
         "teamCliffConstraint"+teamNum, 
         x1Location, 
         z1Location, 
         x2Location, 
         z2Location);

      rmSetTeamArea(teamNum, areaId);
      rmSetAreaSize(areaId, 1.0, 10000);
      rmSetAreaMinBlobs(areaId, 1);
      rmSetAreaMaxBlobs(areaId, 1);
      rmSetAreaMinBlobDistance(areaId, 0.0);
      rmSetAreaMaxBlobDistance(areaId, 0.0);
      rmSetAreaCoherence(areaId, 0.0);
      rmSetAreaCliffType(areaId, "Egyptian");
      rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
      rmSetAreaCliffPainting(areaId, false, true, true, 1.5, true);
      rmSetAreaCliffHeight(areaId, -1.0, 0.0, 0.5);
      rmSetAreaBaseHeight(areaId, 20.0);
      rmAddAreaConstraint(areaId, areaConstraint);
      rmSetAreaLocTeam(areaId, teamNum);
      rmSetTeamArea(teamNum, areaId);
      rmBuildAllAreas();

      rmSetPlacementTeam(teamNum);
      rmSetPlayerPlacementArea(x1Location-xBorderMod, z1Location-zBorderMod, x2Location+xBorderMod, z2Location+zBorderMod);
      rmPlacePlayersSquare(0.25, 0.0, 0.0);
      rmBuildAllAreas();
   }

   // Place Player Settlements
   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmSetObjectDefMinDistance(startingSettlementID, 0.0); // needed Boilerplate?
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0); // needed Boilerplate?
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);
   rmBuildAllAreas();
}

void main(void)
{
   // Set Loading Screen text and percentage
   rmSetStatusText("",0.01);

   // Define Globals
   numOfEvenTeams = cNumberTeams / 2;
   numOfOddTeams = numOfEvenTeams + (cNumberTeams % 2);

   SetNumOfPlayersOddAndEven();

   // Set Map Size.
   sizeL = 40 + (cNumberTeams * 40) + (cNumberPlayers * 30);

   rmSetMapSize(sizeL, sizeL);

   midCliffSize = 1.0-rmXTilesToFraction(40);
   evenTeamCounter = midCliffSize;
   oddTeamCounter = midCliffSize;

   // Init map
   rmSetSeaLevel(1);
   rmTerrainInitialize("SandDirt50");

   // -------------Define constraints
   rmSetStatusText("",0.10);

   int edgeConstraint = rmCreateBoxConstraint("edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
   int lakeConstraint = rmCreateBoxConstraint("lake constraint", rmXTilesToFraction(0), 0.35-rmZTilesToFraction(0), 0.4-rmXTilesToFraction(0), 0.65-rmZTilesToFraction(0));

   int stayInCenter= 0;

   int cliffsideBackMidConstraint =  rmCreateBoxConstraint(
      "cliffsideBackMidConstraint", 
      1.0, 
      1.0, 
      midCliffSize, 
      midCliffSize);

   int cliffsideBackLeftConstraint =  rmCreateBoxConstraint(
      "cliffsideBackLeftConstraint", 
      0.0, 
      1.0, 
      midCliffSize, 
      1.0-rmZTilesToFraction(40)); 

   int cliffsideBackRightConstraint =  rmCreateBoxConstraint(
      "cliffsideBackRightConstraint", 
      1.0, 
      0.0, 
      1.0-rmXTilesToFraction(40), 
      midCliffSize);

   // -------------Define objects
   rmSetStatusText("",0.20);

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

   createCliffsideArea(leftCliffArea, cliffsideBackLeftConstraint, 10.0);
   createCliffsideArea(rightCliffArea, cliffsideBackRightConstraint, 10.0);
   createCliffsideArea(midCliffArea, cliffsideBackMidConstraint, 25.0);
   rmBuildAllAreas();

   createTeamCliffArea();   
   
   // Set loading bar to 100%
   rmSetStatusText("",1.0);
}
