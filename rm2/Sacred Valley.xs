// Waterfall constants
int _waterfallCliffSizeTiles = 90;
float _waterfallCliffSize = 0.0;
int _avoidMidCliffConstraint = 0;

// River Top Pool
int _riverTopPoolTilesX = 10;
int _riverTopPoolTilesZ = 10;
string _riverType="Egyptian Nile";

// Base Layer Constants
string _baseLayerFloorTexture="PlainDirt25";

// Layer Constants
float _firstLayerHeight = 0.0;
int _firstLayerLengthTiles = 20;
string _firstLayerFloorTexture="PlainDirt50";
string _firstLayerCliffTexture="Plain";

// Team Constants
int _teamSpacingTiles = 70;
float _teamLayerHeight = 6.0;
int _teamLayerLengthTiles = 18;
string _teamLayerFloorTexture="PlainDirt75";
string _teamLayerCliffTexture="Plain";

// Player Constants
int _playerSpacingTiles = 2;
float _playerLayerHeight = 10.0;
int _playerLayerWidthTiles = 16;
int _playerLayerLengthTiles = 16;
string _playerLayerFloorTexture="PlainRoadA";
string _playerLayerCliffTexture="Plain";

int _mapSize=0;

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

void createCliffsideArea(int areaId=0, int constraint=0, float height=0.0) 
{      
   rmSetAreaSize(areaId, 1.0, 10000);
   rmSetAreaMinBlobs(areaId, 1);
   rmSetAreaMaxBlobs(areaId, 1);
   rmSetAreaMinBlobDistance(areaId, 0.0);
   rmSetAreaMaxBlobDistance(areaId, 0.0);
   rmSetAreaCoherence(areaId, 0.0);
   rmSetAreaTerrainType(areaId, "CliffPlainA");
   rmSetAreaCliffType(areaId, "Plain");
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, false, true, true, 1.5, true);
   rmSetAreaCliffHeight(areaId, -1.0, 0.0, 0.5);
   rmSetAreaBaseHeight(areaId, height);
   rmAddAreaConstraint(areaId, constraint);
}

void createCliffLayer(int areaId=0, int areaConstraint=0, float baseHeight=0.0, string cliffTexture="", string groundTexture="")
{
   rmSetAreaSize(areaId, 1.0, 1.0);
   rmSetAreaMinBlobs(areaId, 1);
   rmSetAreaMaxBlobs(areaId, 1);
   rmSetAreaMinBlobDistance(areaId, 0.0);
   rmSetAreaMaxBlobDistance(areaId, 0.0);
   rmSetAreaCoherence(areaId, 0.0);
   rmSetAreaTerrainType(areaId, groundTexture);
   rmSetAreaCliffType(areaId, cliffTexture);
   rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
   rmSetAreaCliffPainting(areaId, true, true, true, 1.5, true);
   rmSetAreaBaseHeight(areaId, baseHeight);
   rmAddAreaConstraint(areaId, areaConstraint);
}

float createPlayerCliffArea(int playerNum=0, int teamNum=0, bool isOddTeam=false, float offset=0.0)
{
   int playerAreaId = rmCreateArea("player"+playerNum);

   float x1LocationP = 0.0;
   float x2LocationP = 0.0;
   float z1LocationP = 0.0;
   float z2LocationP = 0.0; 

   float settlementX = 0.0;
   float settlementZ = 0.0;
   float rampAimX = 0.0;
   float rampAimZ = 0.0;

   float nextPlayerOffset = 0.0;
   float playerLayerWidth = 0.0;

   int rampDistTiles = _firstLayerLengthTiles - 7;

   if(isOddTeam)
   {
      playerLayerWidth = rmZTilesToFraction(_playerLayerWidthTiles);

      x1LocationP = 1.0;
      z1LocationP = offset - rmZTilesToFraction(_playerSpacingTiles); 
      x2LocationP = 1.0 - rmXTilesToFraction(_playerLayerLengthTiles);
      z2LocationP = z1LocationP - playerLayerWidth;

      settlementX = x1LocationP - (playerLayerWidth/2);
      settlementZ = z1LocationP - (playerLayerWidth/1.75);

      rampAimX = settlementX - rmXTilesToFraction(rampDistTiles);
      rampAimZ = settlementZ;

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
      settlementZ = z1LocationP - (playerLayerWidth/2);

      rampAimX = settlementX;
      rampAimZ = settlementZ - rmZTilesToFraction(rampDistTiles);

      nextPlayerOffset = x2LocationP;
   }      

   int playerAreaConstraint =  rmCreateBoxConstraint(
      "playerCliffConstraint"+playerNum, 
      x1LocationP, 
      z1LocationP, 
      x2LocationP, 
      z2LocationP);

   rmSetPlayerLocation(playerNum, settlementX, settlementZ);
   createCliffLayer(playerAreaId, playerAreaConstraint, _playerLayerHeight, _playerLayerCliffTexture, _playerLayerFloorTexture);
   rmSetAreaLocPlayer(playerAreaId, playerNum);
   rmSetPlayerArea(playerNum, playerAreaId);
   rmBuildAllAreas();

   int dummy=rmCreateArea("Player Center Dummy"+playerNum);
   rmSetAreaSize(dummy, 0.001, 0.001);
   rmSetAreaLocation(dummy, rampAimX, rampAimZ);
   rmSetAreaCoherence(dummy, 1.0);
   rmBuildAllAreas();

   int rampID=rmCreateConnection("PlayerRamp_"+playerNum);
   rmAddConnectionToClass(rampID, rmClassID("connection"));
   rmSetConnectionType(rampID, cConnectAreas, true, 1.0);
   rmSetConnectionWidth(rampID, 3, 0);
   rmSetConnectionHeightBlend(rampID, 10.0);
   rmSetConnectionSmoothDistance(rampID, 0.1);
   rmSetConnectionCoherence(rampID, 0.0);
   rmAddConnectionTerrainReplacement(rampID, "CliffPlainA", _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(rampID, "CliffPlainB", _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(rampID, _baseLayerFloorTexture, _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(rampID, _firstLayerFloorTexture, _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(rampID, _teamLayerFloorTexture, _playerLayerFloorTexture);
   rmAddConnectionArea(rampID, playerAreaId);
   rmAddConnectionArea(rampID, dummy); 
   rmBuildConnection(rampID);

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
         playerPositionCounter = createPlayerCliffArea(playerNum, teamNum, isOddTeam, playerPositionCounter);
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
      z1Location = offset; 
      x2Location = 1.0 - xTeamLength;
      z2Location = z1Location - teamSize;

      nextTeamOffset = z2Location - zTeamSpacing;
      playerStartOffset = z1Location;
   }
   else
   {
      float xTeamSpacing = rmXTilesToFraction(_teamSpacingTiles);
      float zTeamLength = rmZTilesToFraction(_teamLayerLengthTiles);

      x1Location = offset; 
      z1Location = 1.0;
      x2Location = x1Location - teamSize;
      z2Location = 1.0 - zTeamLength;

      nextTeamOffset = x2Location  - xTeamSpacing;
      playerStartOffset = x1Location;
   }

   int areaConstraint =  rmCreateBoxConstraint(
      "teamCliffConstraint"+teamNum, 
      x1Location, 
      z1Location, 
      x2Location, 
      z2Location);

   createCliffLayer(areaId, areaConstraint, _teamLayerHeight, _teamLayerCliffTexture, _teamLayerFloorTexture);
   rmSetAreaLocTeam(areaId, teamNum);
   rmSetTeamArea(teamNum, areaId);
   rmBuildAllAreas();

   createPlayersCliffArea(teamNum, playerStartOffset);
   
   return(nextTeamOffset);
}

void createTeamsCliffAreas()
{
   float teamOffsetX = _waterfallCliffSize - (rmXTilesToFraction(_teamSpacingTiles/2));
   float teamOffsetZ = _waterfallCliffSize - (rmZTilesToFraction(_teamSpacingTiles/2));
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

   //createCliffLayer(areaId, areaConstraint, _firstLayerHeight, _firstLayerCliffTexture, _firstLayerFloorTexture);
   rmSetAreaLocTeam(areaId, 0);
   rmBuildAllAreas();
}

int createRoad(int roadId=0, float xStart=0.0, float xEnd=0.0, float zStart=0.0, float zEnd=0.0)
{
   rmAddConnectionToClass(roadId, rmClassID("connection"));
   rmSetConnectionType(roadId, cConnectAreas, true, 1.0);
   rmSetConnectionWidth(roadId, 6, 0.0);
   rmSetConnectionHeightBlend(roadId, 1.0);
   rmSetConnectionSmoothDistance(roadId, 1.0);
   rmSetConnectionCoherence(roadId, 1.0);
   rmAddConnectionTerrainReplacement(roadId, "PlainDirt25", _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(roadId, "CliffPlainA", _playerLayerFloorTexture);
   rmAddConnectionTerrainReplacement(roadId, "CliffPlainB", _playerLayerFloorTexture);

   int roadStart = rmCreateArea("roadStart"+roadId);
   rmSetAreaSize(roadStart, 0.01, 0.01);
   rmSetAreaTerrainType(roadStart, "SnowA");
   rmSetAreaLocation(roadStart, xStart, zStart);

   int roadEnd = rmCreateArea("roadEnd"+roadId);
   rmSetAreaSize(roadEnd, 0.001, 0.001);
   rmSetAreaTerrainType(roadEnd, "SnowA");
   rmSetAreaLocation(roadEnd, xEnd, zEnd);

   rmAddConnectionArea(roadId, roadStart);
   rmAddConnectionArea(roadId, roadEnd);
}

void FairlyPlaceRandomSettlements(int avoidImpassableLand=0, int avoidRiverClass=0)
{
   int id=rmAddFairLoc("Settlement", false, true,  150, _mapSize/2, 40, 100); /*back inside */
   rmAddFairLocConstraint(id, avoidImpassableLand);
   rmAddFairLocConstraint(id, avoidRiverClass);

   if(rmRandFloat(0,1)<0.75)
   {      
      id=rmAddFairLoc("Settlement", true, true, 150, _mapSize/2, 70, 30);
      rmAddFairLocConstraint(id, avoidImpassableLand);
      rmAddFairLocConstraint(id, avoidRiverClass);
   }
   else
   {  
      id=rmAddFairLoc("Settlement", false, true, 150, _mapSize/2, 40, 30);
      rmAddFairLocConstraint(id, avoidImpassableLand);
      rmAddFairLocConstraint(id, avoidRiverClass);
   }

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {         
            float locationX = rmFairLocXFraction(i, j);
            float locationY = rmFairLocZFraction(i, j);

            int cnctRoadA=rmCreateConnection("" + i + "roadA" + j);
            int cnctRoadB=rmCreateConnection("" + i + "roadB" + j);

            float roadOffset = rmXMetersToFraction(20);

            float roadAStartX = locationX + roadOffset;
            float roadAStartZ = locationY;
            float roadAEndX = locationX - roadOffset;
            float roadAEndZ = locationY;

            float roadBStartX = locationX;
            float roadBStartZ = locationY + roadOffset;
            float roadBEndX = locationX;
            float roadBEndZ = locationY - roadOffset;

            createRoad(cnctRoadA, roadAStartX, roadAEndX, roadAStartZ, roadAEndZ);
            createRoad(cnctRoadB, roadBStartX, roadBEndX, roadBStartZ, roadBEndZ);

            int loopMax = 3;
            for(k=1; <loopMax)
            {
               int widthModTiles = 4 + ((loopMax - k) * 6);
               float widthMod = rmXMetersToFraction(widthModTiles);
               float height = 2 + 5 * k;

               string areaName = "" + i + "settle" + j + "" + k;
               string constraintName = "" + i + "settleConstraint" + j + "" + k;

               int areaId = rmCreateArea(areaName);
               int areaConstraintId = rmCreateBoxConstraint(constraintName, 
                  locationX + widthMod, 
                  locationY + widthMod, 
                  locationX - widthMod, 
                  locationY - widthMod);

               rmSetAreaSize(areaId, 1.0, 1.0);
               rmSetAreaMinBlobs(areaId, 1);
               rmSetAreaMaxBlobs(areaId, 1);
               rmSetAreaMinBlobDistance(areaId, 0.0);
               rmSetAreaMaxBlobDistance(areaId, 0.0);
               rmSetAreaCoherence(areaId, 1.0);
               rmSetAreaTerrainType(areaId, "SnowA");
               rmSetAreaCliffType(areaId, "Plain");
               rmSetAreaCliffEdge(areaId, 1.0, 1.0, 0.0, 1.0, 0);
               rmSetAreaCliffPainting(areaId, false, true, true, 1.0, true);
               rmSetAreaCliffHeight(areaId, 0.0, 0.0, 1.0);
               rmSetAreaBaseHeight(areaId, height);
               rmAddAreaConstraint(areaId, areaConstraintId);

               rmBuildArea(areaId);
            }

            rmPlaceObjectDefAtLoc(id, 0, locationX, locationY, 1);

            rmBuildConnection(cnctRoadA);
            rmBuildConnection(cnctRoadB);
         }
      }
   }
}

void PlaceGold(
   int medAvoidGold=0, 
   int avoidConnectionsConstraint=0, 
   int shortAvoidSettlement=0, 
   int shortAvoidImpassableLand=0,
   int avoidImpassableLand=0, 
   int stayInCenter=0)
{
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, medAvoidGold);
   rmAddObjectDefConstraint(mediumGoldID, avoidConnectionsConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 105.0);
	rmSetObjectDefMaxDistance(farGoldID, _mapSize);
	rmAddObjectDefConstraint(farGoldID, medAvoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, avoidConnectionsConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, stayInCenter);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 2));
}

void PlaceForest(int avoidConnectionsConstraint=0, int shortAvoidImpassableLand=0)
{
   //Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", classForest, 15.0);
   int failCount=0;
   int numTries=15*cNumberNonGaiaPlayers;

   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(120), rmAreaTilesToFraction(180));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "plain forest");
      rmAddAreaConstraint(forestID, avoidConnectionsConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 1);
      rmSetAreaMaxBlobs(forestID, 10);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 40.0);
      rmSetAreaCoherence(forestID, 0.0);

      if(rmBuildArea(forestID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
            break;
      }
      else
         failCount=0;
   } 
}

void PlaceHunting(
   int classBonusHuntable=0, 
   int avoidHuntable=0, 
   int avoidFood=0, 
   int shortAvoidImpassableLand=0, 
   int startingSettleConstraint=0)
{
   int farPredatorID=rmCreateObjectDef("far predator");
   rmAddObjectDefItem(farPredatorID, "bear", 1, 6.0);    
   rmAddObjectDefToClass(farPredatorID, classBonusHuntable);
   rmAddObjectDefConstraint(farPredatorID, avoidHuntable);
   rmAddObjectDefConstraint(farPredatorID, avoidFood);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, startingSettleConstraint);
   rmSetObjectDefMinDistance(farPredatorID, 40.0);
	rmSetObjectDefMaxDistance(farPredatorID, _mapSize);
   rmPlaceObjectDefPerPlayer(farPredatorID, false, cNumberNonGaiaPlayers/2);

   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   rmAddObjectDefItem(bonusHuntableID, "ram", 2, 2.0);     
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
   rmSetObjectDefMinDistance(bonusHuntableID, 40.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, _mapSize);
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, cNumberNonGaiaPlayers);
}

void PlaceRelics(int avoidImpassableLand=0, int startingSettleConstraint=0)
{
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 60.0));
   rmAddObjectDefConstraint(relicID, avoidImpassableLand);
   rmAddObjectDefConstraint(relicID, startingSettleConstraint);
   rmSetObjectDefMinDistance(relicID, 40.0);
	rmSetObjectDefMaxDistance(relicID, _mapSize);
   rmPlaceObjectDefPerPlayer(relicID, false, 1);
}

void PlaceFish()
{
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 22.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, 3000);
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers); 
}

void PlaceScenery(int avoidAll=0, int shortAvoidImpassableLand=0)
{
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, 600);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, shortAvoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   int bushID=rmCreateObjectDef("big bush patch");
   rmAddObjectDefItem(bushID, "bush", 4, 3.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, 600);
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int bush2ID=rmCreateObjectDef("small bush patch");
   rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
   rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
   rmSetObjectDefMinDistance(bush2ID, 0.0);
   rmSetObjectDefMaxDistance(bush2ID, 600);
   rmAddObjectDefConstraint(bush2ID, avoidAll);
   rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   int nearRiver=rmCreateTerrainMaxDistanceConstraint("near river", "water", true, 5.0);
   int riverBushID=rmCreateObjectDef("bushs by river");
   rmAddObjectDefItem(riverBushID, "bush", 3, 3.0);
   rmAddObjectDefItem(riverBushID, "grass", 7, 8.0);
   rmSetObjectDefMinDistance(riverBushID, 0.0);
   rmSetObjectDefMaxDistance(riverBushID, 600);
   rmAddObjectDefConstraint(riverBushID, avoidAll);
   rmAddObjectDefConstraint(riverBushID, nearRiver);
   rmPlaceObjectDefAtLoc(riverBushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
}

void main(void)
{
   // Set Loading Screen text and percentage
   rmSetStatusText("",0.01);

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

   _mapSize = oddSize;
   if(_mapSize < evenSize)
   {
      _mapSize = evenSize;
   }

   rmSetMapSize(_mapSize, _mapSize);

   _waterfallCliffSize = 1.0-rmXTilesToFraction(_waterfallCliffSizeTiles);

   // Init map
   rmSetSeaType(_riverType);
   rmSetSeaLevel(0.0);
   rmTerrainInitialize(_baseLayerFloorTexture);

   // Class Definitions
   int classConnection=rmDefineClass("connection");
   int classStartingSet=rmDefineClass("starting settlement");
   int classRiver=rmDefineClass("river");
   int classBonusHuntable=rmDefineClass("bonus huntable");

   // Define constraints
   rmSetStatusText("",0.10);

   int edgeConstraint = rmCreateBoxConstraint("edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
   int lakeConstraint = rmCreateBoxConstraint("lake constraint", rmXTilesToFraction(0), 0.35-rmZTilesToFraction(0), 0.4-rmXTilesToFraction(0), 0.65-rmZTilesToFraction(0));

   int stayInCenter= 0;
   int avoidConnectionsConstraint = rmCreateClassDistanceConstraint(
      "Avoid Connections", 
      classConnection, 
      3.0);
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint(
      "avoid impassable land", 
      "land", 
      false, 
      7.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint(
      "short avoid impassable land", 
      "land", 
      false, 
      3.0);
   int nearAvoidImpassableLand=rmCreateTerrainDistanceConstraint(
      "near avoid impassable land", 
      "land", 
      false, 
      1.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint(
      "far avoid impassable land", 
      "land", 
      false, 
      20.0);
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidRiver=rmCreateTerrainDistanceConstraint("near river", "water", true, 5.0);
   int avoidRiverClass=rmCreateClassDistanceConstraint("river avoid", classRiver, 60.0);


   // Buildings
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 6.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 60.0);

   // Gold
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
   int medAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 40.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 60.0);

   // Food
   int avoidHuntable=rmCreateClassDistanceConstraint("huntable avoid", classBonusHuntable, 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // River
   int centerLake=rmCreateArea("lake in the middle");
   rmSetAreaSize(centerLake, 0.1, 0.1);
   rmSetAreaLocation(centerLake, 0.0, 0.0);
   rmSetAreaWaterType(centerLake, _riverType);
   rmSetAreaBaseHeight(centerLake, 0.0);
   rmSetAreaMinBlobs(centerLake, 5);
   rmSetAreaMaxBlobs(centerLake, 15);
   rmSetAreaMinBlobDistance(centerLake, 1.0);
   rmSetAreaMaxBlobDistance(centerLake, 40.0);
   rmSetAreaSmoothDistance(centerLake, 25);
   rmSetAreaCoherence(centerLake, 0);
   rmBuildAllAreas();

   int topLake=rmCreateArea("lake at the top");
   rmSetAreaSize(topLake, rmXTilesToFraction(_riverTopPoolTilesX), rmZTilesToFraction(_riverTopPoolTilesZ));
   rmSetAreaLocation(topLake, 1.0, 1.0);
   rmSetAreaWaterType(topLake, _riverType);
   rmSetAreaBaseHeight(topLake, 0.0);
   rmSetAreaMinBlobs(topLake, 5);
   rmSetAreaMaxBlobs(topLake, 15);
   rmSetAreaMinBlobDistance(topLake, 1.0);
   rmSetAreaMaxBlobDistance(topLake, 40.0);
   rmSetAreaSmoothDistance(topLake, 25);
   rmSetAreaCoherence(topLake, 0);
   rmAddAreaConstraint(topLake, avoidImpassableLand);
   rmBuildAllAreas();

   for(riverIteration=0; <20)
   {
      int riverC=rmCreateArea("riverC"+riverIteration);
      rmAddAreaToClass(riverC, classRiver);
      rmSetAreaSize(riverC, 0.015, 0.015);
      rmSetAreaLocation(riverC, 0.05*riverIteration, 0.05*riverIteration);
      rmSetAreaWaterType(riverC, _riverType);
      rmSetAreaBaseHeight(riverC, 0.0);
      rmSetAreaMinBlobs(riverC, 5);
      rmSetAreaMaxBlobs(riverC, 10);
      rmSetAreaMinBlobDistance(riverC, 1.0);
      rmSetAreaMaxBlobDistance(riverC, 5.0);
      rmSetAreaSmoothDistance(riverC, 25);
      rmSetAreaCoherence(riverC, 0);
      rmBuildAllAreas();
   }

   int riverBridgeA=rmCreateArea("riverBridgeA");
   rmSetAreaSize(riverBridgeA, 0.0175, 0.0175);
   rmSetAreaLocation(riverBridgeA, 0.4, 0.4);
   rmSetAreaBaseHeight(riverBridgeA, 0.0);
   rmSetAreaMinBlobs(riverBridgeA, 5);
   rmSetAreaMaxBlobs(riverBridgeA, 15);
   rmSetAreaMinBlobDistance(riverBridgeA, 5.0);
   rmSetAreaMaxBlobDistance(riverBridgeA, 25.0);
   rmSetAreaSmoothDistance(riverBridgeA, 10);
   rmSetAreaCoherence(riverBridgeA, 0);
   rmSetAreaTerrainType(riverBridgeA, _baseLayerFloorTexture);
   rmBuildAllAreas();

   int riverBridgeB=rmCreateArea("riverBridgeB");
   rmSetAreaSize(riverBridgeB, 0.0175, 0.0175);
   rmSetAreaLocation(riverBridgeB, 0.8, 0.8);
   //rmSetAreaWaterType(riverC, _riverType);
   rmSetAreaBaseHeight(riverBridgeB, 0.0);
   rmSetAreaMinBlobs(riverBridgeB, 5);
   rmSetAreaMaxBlobs(riverBridgeB, 15);
   rmSetAreaMinBlobDistance(riverBridgeA, 5.0);
   rmSetAreaMaxBlobDistance(riverBridgeA, 25.0);
   rmSetAreaSmoothDistance(riverBridgeB, 10);
   rmSetAreaCoherence(riverBridgeB, 0);
   rmSetAreaTerrainType(riverBridgeB, _baseLayerFloorTexture);
   rmBuildAllAreas();

   // Terrain
   createFirstLayers(true);
   createFirstLayers(false);
   createTeamsCliffAreas();  
   
   // Place Player Settlements
   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmSetObjectDefMinDistance(startingSettlementID, 0.0); // needed Boilerplate?
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0); // needed Boilerplate?
   rmAddObjectDefToClass(startingSettlementID, classStartingSet);
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 1.0);
   rmSetObjectDefMaxDistance(startingTowerID, 8.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, nearAvoidImpassableLand);
   rmAddObjectDefConstraint(startingTowerID, avoidConnectionsConstraint);
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 1.0);
   rmSetObjectDefMaxDistance(startingGoldID, 16.0);
   rmAddObjectDefConstraint(startingGoldID, shortAvoidGold);
   rmAddObjectDefConstraint(startingGoldID, nearAvoidImpassableLand);
   rmAddObjectDefConstraint(startingGoldID, avoidConnectionsConstraint);
   rmPlaceObjectDefPerPlayer(startingGoldID, true);

   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", rmRandInt(4,6), 4.0);
   rmSetObjectDefMinDistance(closeBerriesID, 0.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 20.0);
   rmAddObjectDefConstraint(closeBerriesID, nearAvoidImpassableLand);
   rmAddObjectDefConstraint(closeBerriesID, avoidBuildings);
   rmAddObjectDefConstraint(closeBerriesID, shortAvoidGold);
   rmAddObjectDefConstraint(closeBerriesID, avoidConnectionsConstraint);
   rmPlaceObjectDefPerPlayer(closeBerriesID, true);

   int closeGoatsID=rmCreateObjectDef("close Goats");
   rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 20.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 25.0);
   rmAddObjectDefConstraint(closeGoatsID, nearAvoidImpassableLand);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   rmPlaceObjectDefPerPlayer(closeGoatsID, true);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(5,9), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, nearAvoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   int startingSettleConstraint=rmCreateClassDistanceConstraint("starting settle avoid", classStartingSet, 80.0);

   // Place Settlements
   FairlyPlaceRandomSettlements(farAvoidImpassableLand, avoidRiverClass);

   // Place Resources
   PlaceGold(medAvoidGold, 
      avoidConnectionsConstraint, 
      shortAvoidSettlement, 
      shortAvoidImpassableLand, 
      avoidImpassableLand,
      stayInCenter);
   
   PlaceForest(avoidConnectionsConstraint, 
      shortAvoidImpassableLand);

   PlaceHunting(classBonusHuntable, 
      avoidHuntable, 
      avoidFood, 
      shortAvoidImpassableLand, 
      startingSettleConstraint);

   PlaceRelics(avoidImpassableLand, 
      startingSettleConstraint);

   PlaceFish();

   // Place bushes and rocks etc
   PlaceScenery(avoidAll, 
      shortAvoidImpassableLand);

   // Set player starting resources
   for(i=1; <cNumberPlayers)
   {
      rmAddPlayerResource(i, "Food", 300);
      rmAddPlayerResource(i, "Wood", 200);
      rmAddPlayerResource(i, "Gold", 100);
   }

   // Set loading bar to 100%
   rmSetStatusText("",1.0);
}
