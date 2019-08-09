// waterfall Tiles
int cliffSizeTiles = 40;

// Waterfall Fractions
float midCliffSize = 0.0;

// Team Tiles
int teamSpacingTiles = 15;
int teamLengthTiles = 22;

// Team Fractions
float evenTeamCounter = 0.0;
float oddTeamCounter = 0.0;

// Player Tiles
int playerSizeTiles = 15;
int playerSpacingTiles = 5;

// Player Fractions
float playerSize = 0.0;
float playerSpacing = 0.0;

int numOfOddTeams=0;
int numOfEvenTeams=0;

int numOfOddPlayers=0;
int numOfEvenPlayers=0;

int sizeL=0;

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

void createCliffLayer(int areaId=0, int areaConstraint=0, float baseHeight=0.0)
{
   rmSetAreaSize(areaId, 1.0, 1.0);
   rmSetAreaMinBlobs(areaId, 1);
   rmSetAreaMaxBlobs(areaId, 1);
   rmSetAreaMinBlobDistance(areaId, 0.0);
   rmSetAreaMaxBlobDistance(areaId, 0.0);
   rmSetAreaCoherence(areaId, 0.0);
   rmSetAreaCliffType(areaId, "Egyptian");
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, true, true, true, 1.5, true);
   rmSetAreaBaseHeight(areaId, baseHeight);
   rmAddAreaConstraint(areaId, areaConstraint);
}

void createTeamCliffArea()
{
   for(teamNum=0; < cNumberTeams)
   {
      int areaId = rmCreateArea("team"+teamNum);

      bool isOddTeam = teamNum % 2 == 0;
      int numPlayersOnTeam = rmGetNumberPlayersOnTeam(teamNum);    
      int teamSize = playerSpacingTiles + (numPlayersOnTeam * (playerSizeTiles + playerSpacingTiles));

      float x1Location = 0.0;
      float x2Location = 0.0;
      float z1Location = 0.0;
      float z2Location = 0.0;
 
      if(isOddTeam)
      {
         float zTeamSize = rmZTilesToFraction(teamSize);
         float zTeamSpacing = rmZTilesToFraction(teamSpacingTiles);
         float xTeamLength = rmXTilesToFraction(teamLengthTiles);

         x1Location = 1.0;
         z1Location = oddTeamCounter; 
         x2Location = 1.0 - xTeamLength;
         z2Location = z1Location - zTeamSize;

         oddTeamCounter = z2Location - zTeamSpacing;
      }
      else
      {
         float xTeamSize = rmXTilesToFraction(teamSize);
         float xTeamSpacing = rmXTilesToFraction(teamSpacingTiles);
         float zTeamLength = rmZTilesToFraction(teamLengthTiles);

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

      createCliffLayer(areaId, areaConstraint, 10);
      rmSetAreaLocTeam(areaId, teamNum);
      rmSetTeamArea(teamNum, areaId);
      rmBuildAllAreas();

      float playerCounter = 0.0;

      if(isOddTeam)
      {
         playerCounter = z1Location;
      }
      else
      {
         playerCounter = x1Location;
      }

      for(playerNum=0; < cNumberPlayers)
      {
         if(rmGetPlayerTeam(playerNum) == teamNum)
         {
            int playerAreaId = rmCreateArea("player"+playerNum);

            float x1LocationP = 0.0;
            float x2LocationP = 0.0;
            float z1LocationP = 0.0;
            float z2LocationP = 0.0;            

            if(isOddTeam)
            {
               x1LocationP = 1.0;
               z1LocationP = playerCounter - playerSpacing; 
               x2LocationP = 1.0 - playerSize;
               z2LocationP = z1LocationP - playerSize;

               playerCounter = z2LocationP;
            }
            else
            {
               x1LocationP = playerCounter - playerSpacing; 
               z1LocationP = 1.0;
               x2LocationP = x1LocationP - playerSize;
               z2LocationP = 1.0 - playerSize;

               playerCounter = x2LocationP;
            }

            int playerAreaConstraint =  rmCreateBoxConstraint(
               "playerCliffConstraint"+playerNum, 
               x1LocationP, 
               z1LocationP, 
               x2LocationP, 
               z2LocationP);

            rmSetPlayerLocation(playerNum, x1LocationP-(playerSize/2), z1LocationP-(playerSize/2));

            createCliffLayer(playerAreaId, playerAreaConstraint, 20);
            rmSetAreaLocPlayer(playerAreaId, playerNum);
            rmSetPlayerArea(teamNum, areaId);
            rmBuildAllAreas();
         }
      }      
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
   int oddSize = 4.0*sqrt(cNumberNonGaiaPlayers*1500);
   int evenSize = 4.0*sqrt(cNumberNonGaiaPlayers*1500);

   sizeL = oddSize;
   if(sizeL < evenSize)
   {
      sizeL = evenSize;
   }

   rmSetMapSize(sizeL, sizeL);

   playerSize = rmZTilesToFraction(playerSizeTiles);
   playerSpacing = rmZTilesToFraction(playerSpacingTiles);

   midCliffSize = 1.0-rmXTilesToFraction(cliffSizeTiles);
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
   //int leftCliffArea = rmCreateArea("leftCliff");
   //int rightCliffArea = rmCreateArea("rightCliff");
   int midCliffArea = rmCreateArea("midCliff");

   //createCliffsideArea(leftCliffArea, cliffsideBackLeftConstraint, 10.0);
   //createCliffsideArea(rightCliffArea, cliffsideBackRightConstraint, 10.0);
   createCliffsideArea(midCliffArea, cliffsideBackMidConstraint, 35.0);
   rmBuildAllAreas();

   createTeamCliffArea();   
   
   // Set loading bar to 100%
   rmSetStatusText("",1.0);
}
