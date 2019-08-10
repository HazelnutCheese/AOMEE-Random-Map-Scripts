// Waterfall constants
int _waterfallCliffSizeTiles = 60;
float _waterfallCliffSize = 0.0;

// Layer Constants
float _firstLayerHeight = 6.0;
int _firstLayerLengthTiles = 34;

// Team Constants
int _teamSpacingTiles = 20;
float _teamLayerHeight = 14.0;
int _teamLayerLengthTiles = 26;

// Player Constants
int _playerSpacingTiles = 10;
float _playerLayerHeight = 22.0;
int _playerLayerWidthTiles = 16;
int _playerLayerLengthTiles = 18;

int numOfOddTeams=0;
int numOfEvenTeams=0;

int numOfOddPlayers=0;
int numOfEvenPlayers=0;

int sizeL=0;

void showMessage(string text="") 
{ 
   int id = rmCreateTrigger("message"+rmRandInt());

   rmSwitchToTrigger(id);
   rmSetTriggerLoop(true);
   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 5, false);
   rmAddTriggerEffect("Message");
   rmSetTriggerEffectParamInt("Timeout", 10000, false);
   rmSetTriggerEffectParam("Text", text, false);
}

bool getIsOddTeam(int teamNum=0)
{
   return(teamNum % 2 == 0);
}

int getSizeOfTeamTiles(int teamNum=0)
{
   int numPlayersOnTeam = rmGetNumberPlayersOnTeam(teamNum);  

   int teamSize = _playerSpacingTiles + (numPlayersOnTeam * (_playerLayerWidthTiles + _playerSpacingTiles));

   return(teamSize);
}

float getSizeOfTeam(int teamNum=0)
{
   int tiles = getSizeOfTeamTiles(teamNum);
   bool isOdd = getIsOddTeam(teamNum);

   if(isOdd)
   {
      return(rmZTilesToFraction(tiles));
   }
   else
   {
      return(rmXTilesToFraction(tiles));
   }
}

void SetNumOfPlayersOddAndEven()
{
   for(teamNum=0; < cNumberTeams)
   {
      bool isOddTeam = getIsOddTeam(teamNum);
      
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
   rmSetAreaTerrainType(areaId, "SandA");
   rmSetAreaCliffType(areaId, "Egyptian");
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, true, true, true, 1.5, true);
   rmSetAreaBaseHeight(areaId, baseHeight);
   rmAddAreaConstraint(areaId, areaConstraint);
}

float createPlayerCliffArea(int playerNum=0, bool isOddTeam=false, float offset=0.0)
{
   int playerAreaId = rmCreateArea("player"+playerNum);

   float x1LocationP = 0.0;
   float x2LocationP = 0.0;
   float z1LocationP = 0.0;
   float z2LocationP = 0.0; 

   float settlementX = 0.0;
   float settlementY = 0.0;

   float nextPlayerOffset=0.0;
   float playerLayerWidth = 0.0;

   if(isOddTeam)
   {
      playerLayerWidth = rmZTilesToFraction(_playerLayerWidthTiles);

      x1LocationP = 1.0;
      z1LocationP = offset - rmZTilesToFraction(_playerSpacingTiles); 
      x2LocationP = 1.0 - rmXTilesToFraction(_playerLayerLengthTiles);
      z2LocationP = z1LocationP - playerLayerWidth;

      settlementX = x1LocationP - (playerLayerWidth/2);
      settlementY = z1LocationP - (playerLayerWidth/1.75);

      nextPlayerOffset = z2LocationP;
   }
   else
   {
      playerLayerWidth = rmXTilesToFraction(_playerLayerWidthTiles);

      x1LocationP = offset - rmXTilesToFraction(_playerSpacingTiles); 
      z1LocationP = 1.0;
      x2LocationP = x1LocationP - playerLayerWidth;
      z2LocationP = 1.0 - rmZTilesToFraction(_playerLayerLengthTiles);

      settlementX = x1LocationP - (playerLayerWidth/1.75);
      settlementY = z1LocationP - (playerLayerWidth/2);

      nextPlayerOffset = x2LocationP;
   }      

   int playerAreaConstraint =  rmCreateBoxConstraint(
               "playerCliffConstraint"+playerNum, 
               x1LocationP, 
               z1LocationP, 
               x2LocationP, 
               z2LocationP);

   rmSetPlayerLocation(playerNum, settlementX, settlementY);
   createCliffLayer(playerAreaId, playerAreaConstraint, _playerLayerHeight);
   rmSetAreaLocPlayer(playerAreaId, playerNum);
   rmSetPlayerArea(playerNum, playerAreaId);
   rmBuildAllAreas();

   return(nextPlayerOffset);
}

void createPlayersCliffArea(int teamNum=0, float teamStartPosition=0.0)
{
   float playerPositionCounter = teamStartPosition;
   bool isOddTeam = getIsOddTeam(teamNum);

   for(playerNum=0; < cNumberPlayers)
   {
      if(rmGetPlayerTeam(playerNum) == teamNum)
      {
         playerPositionCounter = createPlayerCliffArea(playerNum, isOddTeam, playerPositionCounter);
      }
   }  
}

float createTeamCliffArea(int teamNum=0, float offset=0.0)
{
   int areaId = rmCreateArea("team"+teamNum);
   bool isOddTeam = getIsOddTeam(teamNum);
   int numPlayersOnTeam = rmGetNumberPlayersOnTeam(teamNum);  

   float x1Location = 0.0;
   float x2Location = 0.0;
   float z1Location = 0.0;
   float z2Location = 0.0;

   float teamSize = getSizeOfTeam(teamNum);
   float nextTeamOffset=0.0;
   float playerStartOffset=0.0;

   if(isOddTeam)
   {
      float zTeamSpacing = rmZTilesToFraction(_teamSpacingTiles);
      float xTeamLength = rmXTilesToFraction(_teamLayerLengthTiles);

      x1Location = 1.0;
      z1Location = offset - zTeamSpacing; 
      x2Location = 1.0 - xTeamLength;
      z2Location = z1Location - teamSize;

      nextTeamOffset = z2Location;
      playerStartOffset = z1Location;
   }
   else
   {
      float xTeamSpacing = rmXTilesToFraction(_teamSpacingTiles);
      float zTeamLength = rmZTilesToFraction(_teamLayerLengthTiles);

      x1Location = offset - xTeamSpacing; 
      z1Location = 1.0;
      x2Location = x1Location - teamSize;
      z2Location = 1.0 - zTeamLength;

      nextTeamOffset = x2Location;
      playerStartOffset = x1Location;
   }

   int areaConstraint =  rmCreateBoxConstraint(
      "teamCliffConstraint"+teamNum, 
      x1Location, 
      z1Location, 
      x2Location, 
      z2Location);

   createCliffLayer(areaId, areaConstraint, _teamLayerHeight);
   rmSetAreaLocTeam(areaId, teamNum);
   rmSetTeamArea(teamNum, areaId);
   rmBuildAllAreas();

   createPlayersCliffArea(teamNum, playerStartOffset);
   
   return(nextTeamOffset);
}

void createTeamsCliffAreas()
{
   float teamOffsetX = _waterfallCliffSize;
   float teamOffsetZ = _waterfallCliffSize;
   for(teamNum=0; < cNumberTeams)
   {  
      if(getIsOddTeam(teamNum))
      {
         teamOffsetZ=createTeamCliffArea(teamNum, teamOffsetZ); 
      }
      else
      {
         teamOffsetX=createTeamCliffArea(teamNum, teamOffsetX); 
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

void createFirstLayers(bool isRight=false)
{
   float x1 = 0.0;
   float z1 = 0.0;
   float x2 = 0.0;
   float z2 = 0.0;

   if(isRight)
   {
      x1 = 1.0-rmXTilesToFraction(_firstLayerLengthTiles);
      z1 = _waterfallCliffSize;
      x2 = 1.0;
      z2 = 0.0;
   }
   else
   {
      x1 = _waterfallCliffSize;
      z1 = 1.0-rmZTilesToFraction(_firstLayerLengthTiles);
      x2 = 0.0;
      z2 = 1.0;
   }

   int areaId = rmCreateArea("layerCliff"+isRight);
   int areaConstraint = rmCreateBoxConstraint(
      "layerCliffConstraint"+isRight, 
      x1, 
      z1, 
      x2, 
      z2);

   createCliffLayer(areaId, areaConstraint, _firstLayerHeight);
   rmSetAreaLocTeam(areaId, 0);
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
   float oddSize = _waterfallCliffSizeTiles + 10;
   float evenSize = _waterfallCliffSizeTiles + 10;

   for(teamNum=0; <cNumberTeams)
   {
      bool isOddTeam = getIsOddTeam(teamNum);
      int tiles = getSizeOfTeamTiles(teamNum);

      if(isOddTeam)
      {
         oddSize = oddSize + tiles + _teamSpacingTiles;
      }
      else
      {
         evenSize = evenSize + tiles+ _teamSpacingTiles;
      }
   }

   oddSize = oddSize*2;
   evenSize = evenSize*2;

   sizeL = oddSize;
   if(sizeL < evenSize)
   {
      sizeL = evenSize;
   }

   rmSetMapSize(sizeL, sizeL);

   _waterfallCliffSize = 1.0-rmXTilesToFraction(_waterfallCliffSizeTiles);

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
      _waterfallCliffSize, 
      _waterfallCliffSize);

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
   // int centerLake=rmCreateArea("lake in the middle");
   // rmSetAreaSize(centerLake, 0.3, 0.3);
   // rmSetAreaLocation(centerLake, 0.0, 0.0);
   // rmSetAreaWaterType(centerLake, "Egyptian Nile");
   // rmSetAreaBaseHeight(centerLake, 0.0);
   // rmSetAreaMinBlobs(centerLake, 1);
   // rmSetAreaMaxBlobs(centerLake, 1);
   // rmSetAreaMinBlobDistance(centerLake, 1.0);
   // rmSetAreaMaxBlobDistance(centerLake, 1.0);
   // rmSetAreaSmoothDistance(centerLake, 25);
   // rmSetAreaCoherence(centerLake, 0);
   // rmBuildAllAreas();

   // int waterfallLake=rmCreateArea("lake under the waterfall");
   // rmSetAreaSize(waterfallLake, rmXTilesToFraction(5), rmZTilesToFraction(5));
   // rmSetAreaLocation(waterfallLake, _waterfallCliffSize, _waterfallCliffSize);
   // rmSetAreaWaterType(waterfallLake, "Egyptian Nile");
   // rmSetAreaBaseHeight(waterfallLake, 0.0);
   // rmSetAreaMinBlobs(waterfallLake, 1);
   // rmSetAreaMaxBlobs(waterfallLake, 1);
   // rmSetAreaMinBlobDistance(waterfallLake, 0.0);
   // rmSetAreaMaxBlobDistance(waterfallLake, 0.0);
   // rmSetAreaSmoothDistance(waterfallLake, 25);
   // rmSetAreaCoherence(waterfallLake, 0);
   // rmBuildAllAreas();

   // Create the team cliffs
   //int leftCliffArea = rmCreateArea("leftCliff");
   //int rightCliffArea = rmCreateArea("rightCliff");
   int midCliffArea = rmCreateArea("midCliff");

   //createCliffsideArea(leftCliffArea, cliffsideBackLeftConstraint, 10.0);
   //createCliffsideArea(rightCliffArea, cliffsideBackRightConstraint, 10.0);
   createCliffsideArea(midCliffArea, cliffsideBackMidConstraint, 35.0);
   rmBuildAllAreas();

   createFirstLayers(true);
   createFirstLayers(false);
   createTeamsCliffAreas();  

   // Forest.
   // int classForest=rmDefineClass("forest");
   // int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   // int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 15.0);
   // //int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   // int failCount=0;
   // int numTries=10*cNumberNonGaiaPlayers;
   // for(i=0; <numTries)
   // {
   //    int forestID=rmCreateArea("forest"+i);
   //    rmSetAreaSize(forestID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(120));
   //    rmSetAreaWarnFailure(forestID, false);
   //    rmSetAreaForestType(forestID, "palm forest");
   //    //rmAddAreaConstraint(forestID, forestSettleConstraint);
   //    rmAddAreaConstraint(forestID, forestObjConstraint);
   //    rmAddAreaConstraint(forestID, forestConstraint);
   //    //rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
   //    rmAddAreaToClass(forestID, classForest);
      
   //    rmSetAreaMinBlobs(forestID, 1);
   //    rmSetAreaMaxBlobs(forestID, 5);
   //    rmSetAreaMinBlobDistance(forestID, 16.0);
   //    rmSetAreaMaxBlobDistance(forestID, 40.0);
   //    rmSetAreaCoherence(forestID, 0.0);

   //    // Hill trees?
   //    if(rmRandFloat(0.0, 1.0)<0.2)
   //       rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));

   //    if(rmBuildArea(forestID)==false)
   //    {
   //       // Stop trying once we fail 3 times in a row.
   //       failCount++;
   //       if(failCount==3)
   //          break;
   //    }
   //    else
   //       failCount=0;
   // } 
   
   // Set loading bar to 100%
   rmSetStatusText("",1.0);
}
