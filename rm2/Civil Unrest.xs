int _playerTiles=15000;
int _largePlayerTiles=20000;

// Random Textures
string _oceanTextureA="Red Sea";
string _oceanTextureB="Red Sea";
string _landTextureB="CityTileA";

void SetMapSize()
{
   int size = 0;
   if(cMapSize == 1)
   {
      size=2.0*sqrt(cNumberNonGaiaPlayers*_largePlayerTiles);
   }
   else
   {
      size=2.0*sqrt(cNumberNonGaiaPlayers*_playerTiles);
   }

   int x = (rmRandFloat(0, 0.4) + 0.8) * size;
   int z = (rmRandFloat(0, 0.4) + 0.8) * size;

   rmSetMapSize(x, z);
}

void InitialiseWater()
{
   rmSetSeaLevel(0.0);
   float waterType=rmRandFloat(0, 1);
   if(waterType<0.5)   
   {
      rmSetSeaType(_oceanTextureA);
   }
   else
   {
      rmSetSeaType(_oceanTextureB);
   }

   rmTerrainInitialize("water");
}

int CreateMiddleIsland()
{
   int centerID=rmCreateArea("center");

   float x = (rmRandFloat(0, 0.15) + 0.35);
   float z = (rmRandFloat(0, 0.15) + 0.35);

   rmSetAreaSize(centerID, x, z);
   rmSetAreaLocation(centerID, 0.5, 0.5);
   rmSetAreaMinBlobs(centerID, 5);
   rmSetAreaMaxBlobs(centerID, 25);
   rmSetAreaMinBlobDistance(centerID, 10.0);
   rmSetAreaMaxBlobDistance(centerID, 85.0);
   rmSetAreaCoherence(centerID, 0.25);
   rmSetAreaBaseHeight(centerID, 2.0);
   rmSetAreaTerrainType(centerID, _landTextureB);
   rmSetAreaSmoothDistance(centerID, 30);
   rmSetAreaHeightBlend(centerID, 10);
   rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 0.95, 0.95, 0.01));
   rmBuildArea(centerID);

   return(centerID);
}

int CreateCityLimits(int middleIslandArea=0, int csrtFarAvoidImpassableLand=0)
{
   int cstrMiddleIsland=rmCreateAreaConstraint("stay within island", middleIslandArea);

   int cityLimitsID=rmCreateArea("cityLimits");

   rmSetAreaSize(cityLimitsID, 0.75, 0.75);
   rmSetAreaLocation(cityLimitsID, 0.5, 0.5);
   rmSetAreaMinBlobs(cityLimitsID, 5);
   rmSetAreaMaxBlobs(cityLimitsID, 25);
   rmSetAreaMinBlobDistance(cityLimitsID, 10.0);
   rmSetAreaMaxBlobDistance(cityLimitsID, 85.0);
   rmSetAreaCoherence(cityLimitsID, 0.25);
   rmSetAreaBaseHeight(cityLimitsID, 2.0);
   rmAddAreaConstraint(cityLimitsID, csrtFarAvoidImpassableLand);
   rmSetAreaSmoothDistance(cityLimitsID, 30);
   rmSetAreaHeightBlend(cityLimitsID, 2);
   rmAddAreaConstraint(cityLimitsID, cstrMiddleIsland);
   rmBuildArea(cityLimitsID);

   return(cityLimitsID);
}

int DefineStartingSettlements(int startingSettlementClass=0, int csrtShortAvoidImpassableLand=0)
{
   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, startingSettlementClass);
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
   rmAddObjectDefConstraint(startingSettlementID, csrtShortAvoidImpassableLand);
   return(startingSettlementID);
}

int DefineStartingTowers(int avoidTowerContraint=0, int csrtShortAvoidImpassableLand=0)
{
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 11.0);
   rmSetObjectDefMaxDistance(startingTowerID, 14.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTowerContraint);
   rmAddObjectDefConstraint(startingTowerID, csrtShortAvoidImpassableLand);
   return(startingTowerID);
}

int DefineStartingGoats(int avoidTowerContraint=0, int csrtShortAvoidImpassableLand=0, int csrtAvoidGold=0, int csrtAvoidFood=0)
{
   int startingGoatsID=rmCreateObjectDef("Starting goats");
   rmAddObjectDefItem(startingGoatsID, "goat", 4, 2.0);
   rmSetObjectDefMinDistance(startingGoatsID, 11.0);
   rmSetObjectDefMaxDistance(startingGoatsID, 14.0);
   rmAddObjectDefConstraint(startingGoatsID, avoidTowerContraint);
   rmAddObjectDefConstraint(startingGoatsID, csrtShortAvoidImpassableLand);
   rmAddObjectDefConstraint(startingGoatsID, csrtAvoidGold);
   rmAddObjectDefConstraint(startingGoatsID, csrtAvoidFood);
   return(startingGoatsID);
}

int DefineStartingChickens(int avoidTowerContraint=0, int csrtShortAvoidImpassableLand=0, int csrtAvoidGold=0, int csrtAvoidFood=0)
{
   int startingChickensID=rmCreateObjectDef("Starting chickens");
   rmAddObjectDefItem(startingChickensID, "chicken", rmRandInt(5,9), 5.0);
   rmSetObjectDefMinDistance(startingChickensID, 4.0);
   rmSetObjectDefMaxDistance(startingChickensID, 20.0);
   rmAddObjectDefConstraint(startingChickensID, avoidTowerContraint);
   rmAddObjectDefConstraint(startingChickensID, csrtShortAvoidImpassableLand);
   rmAddObjectDefConstraint(startingChickensID, csrtAvoidGold);
   rmAddObjectDefConstraint(startingChickensID, csrtAvoidFood);
   return(startingChickensID);
}

int DefineStartingGold(int csrtAvoidTower=0, int csrtShortStartingSettle=0, int csrtShortAvoidImpassableLand=0)
{
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 1.0);
   rmSetObjectDefMaxDistance(startingGoldID, 16.0);
   rmAddObjectDefConstraint(startingGoldID, csrtAvoidTower);
   rmAddObjectDefConstraint(startingGoldID, csrtShortStartingSettle);
   rmAddObjectDefConstraint(startingGoldID, csrtShortAvoidImpassableLand);
   return(startingGoldID);
}

void FairlyPlaceRandomSettlements(int csrtFarAvoidImpassableLand=0, int cnctRoad=0)
{
   int id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 40); /*back inside */
   rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);

   if(rmRandFloat(0,1)<0.75)
   {      
      id=rmAddFairLoc("Settlement", true, true, 90, 120, 70, 30);
      rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
   }
   else
   {  
      id=rmAddFairLoc("Settlement", false, true,  60, 100, 40, 30);
      rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
   }

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         float locationX = rmFairLocXFraction(i, 0);
         float locationY = rmFairLocZFraction(i, 0);

         int settleID=rmCreateArea("settle"+i);
         rmSetAreaSize(settleID, rmAreaTilesToFraction(45), rmAreaTilesToFraction(45));
         rmSetAreaLocation(settleID, locationX, locationY);
         rmPlaceObjectDefAtLoc(id, i, locationX, locationY, 1);

         rmSetAreaWarnFailure(settleID, false);
         rmSetAreaMinBlobs(settleID, 1);
         rmSetAreaMaxBlobs(settleID, 1);
         rmSetAreaMinBlobDistance(settleID, 0.0);
         rmSetAreaMaxBlobDistance(settleID, 0.0);
         rmSetAreaCoherence(settleID, 1.0);
         rmSetAreaTerrainType(settleID, "PlainRoadA");
         rmSetAreaTerrainLayerVariance(settleID, true);

         // Add Road Connection
         rmAddConnectionArea(cnctRoad, settleID);

         rmBuildArea(settleID);
      }
   }
}

void FairlyPlaceRandomGoldMines(int csrtFarAvoidImpassableLand=0, int csrtFarAvoidConnections=0)
{
   int id=rmAddFairLoc("Gold mine", false, true,  40, 60, 40, 40); /*back inside */
   rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
   rmAddFairLocConstraint(id, csrtFarAvoidConnections);

   if(rmRandFloat(0,1)<0.75)
   {      
      id=rmAddFairLoc("Gold mine", true, true, 50, 70, 70, 30);
      rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
      rmAddFairLocConstraint(id, csrtFarAvoidConnections);
   }
   else
   {  
      id=rmAddFairLoc("Gold mine", false, true,  70, 90, 40, 30);
      rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
      rmAddFairLocConstraint(id, csrtFarAvoidConnections);
   }

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("Gold mine");
      rmAddObjectDefItem(id, "Gold mine", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <3)
         {
            rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
         }
      }
   }
}

void FairlyPlaceRandomFarms(int csrtFarAvoidImpassableLand=0, int csrtFarAvoidConnections=0)
{
   int id=rmAddFairLoc("farm2", false, true,  rmRandInt(60, 100), rmRandInt(100, 200), rmRandInt(60, 10), rmRandInt(60, 100)); /*back inside */
   rmAddFairLocConstraint(id, csrtFarAvoidImpassableLand);
   rmAddFairLocConstraint(id, csrtFarAvoidConnections);

   if(rmPlaceFairLocs())
   {
      int granId =rmCreateObjectDef("gran22");
      rmAddObjectDefItem(granId, "granary", 1, 0.0);
      id=rmCreateObjectDef("farm22");
      rmAddObjectDefItem(id, "farm", 1, 0.0);
      int villId =rmCreateObjectDef("vil22");
      rmAddObjectDefItem(villId, "Villager Greek", 1, 0.0);

      for(i=1; <cNumberPlayers)
      {
         rmPlaceObjectDefAtLoc(granId, 0, rmFairLocXFraction(i, 0), rmFairLocZFraction(i, 0), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)+rmXTilesToFraction(3), rmFairLocZFraction(i, 0)+rmZTilesToFraction(3), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)+rmXTilesToFraction(3), rmFairLocZFraction(i, 0)-rmZTilesToFraction(3), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)-rmXTilesToFraction(3), rmFairLocZFraction(i, 0)+rmZTilesToFraction(3), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)-rmXTilesToFraction(3), rmFairLocZFraction(i, 0)-rmZTilesToFraction(3), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)-rmXTilesToFraction(3), rmFairLocZFraction(i, 0), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0), rmFairLocZFraction(i, 0)-rmZTilesToFraction(3), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0)+rmXTilesToFraction(3), rmFairLocZFraction(i, 0), 1);
         rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, 0), rmFairLocZFraction(i, 0)+rmZTilesToFraction(3), 1);
      }
   }
}

int DefineGenericCityObject(
   string objectName="", 
   int csrtFarAvoidImpassableLand=0, 
   int csrtAvoidConnections=0, 
   int csrtAvoidBuildings=0, 
   int csrtPlayer=0, 
   int cstrAvoidForest=0,
   int csrtAvoidGold=0)
{
   int cityObjectId=rmCreateObjectDef("city "+objectName);
   rmAddObjectDefItem(cityObjectId, objectName, 1, 0.0);
   rmSetObjectDefMinDistance(cityObjectId, 0.0);
   rmSetObjectDefMaxDistance(cityObjectId, 14.0);
   rmAddObjectDefConstraint(cityObjectId, csrtFarAvoidImpassableLand);
   rmAddObjectDefConstraint(cityObjectId, csrtAvoidConnections);
   rmAddObjectDefConstraint(cityObjectId, csrtAvoidBuildings);
   rmAddObjectDefConstraint(cityObjectId, csrtPlayer);
   rmAddObjectDefConstraint(cityObjectId, cstrAvoidForest);
   rmAddObjectDefConstraint(cityObjectId, csrtAvoidGold);
   return(cityObjectId);
}

void PlaceHouses(
   int midIslandArea=0, 
   int csrtFarAvoidImpassableLand=0, 
   int csrtAvoidConnections=0, 
   int csrtShortAvoidBuildings=0, 
   int csrtVeryShortAvoidBuildingsShort=0, 
   int csrtPlayer=0, 
   int cstrAvoidForest=0,
   int csrtAvoidGold=0)
{
   // Buildings
   int cityHouseId=DefineGenericCityObject("house", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityGranaryId=DefineGenericCityObject("granary", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityStorehouseId=DefineGenericCityObject("storehouse", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityTempleId=DefineGenericCityObject("temple", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityMarketId=DefineGenericCityObject("market", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityStableId=DefineGenericCityObject("stable", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityMilitaryAcademyId=DefineGenericCityObject("military academy", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityArcheryRangeId=DefineGenericCityObject("archery range", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   //int cityShrine=DefineGenericCityObject("shrine", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityArmouryId=DefineGenericCityObject("armory", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityManorId=DefineGenericCityObject("manor", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityCounterBarracksId=DefineGenericCityObject("counter barracks", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   //int cityEconomicGuildId=DefineGenericCityObject("economic guild", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtPlayer, cstrAvoidForest, csrtAvoidGold);

   // int cityFarmId=rmCreateObjectDef("city farm");
   // rmAddObjectDefItem(cityFarmId, "farm", 2, 4.0);
   // rmSetObjectDefMinDistance(cityFarmId, 0.0);
   // rmSetObjectDefMaxDistance(cityFarmId, 14.0);
   // rmAddObjectDefConstraint(cityFarmId, csrtFarAvoidImpassableLand);
   // rmAddObjectDefConstraint(cityFarmId, csrtAvoidConnections);
   // rmAddObjectDefConstraint(cityFarmId, csrtVeryShortAvoidBuildingsShort);
   // rmAddObjectDefConstraint(cityFarmId, csrtPlayer);

   // Embellishments
   int cityTorchId=DefineGenericCityObject("torch", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityTentId=DefineGenericCityObject("tent", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityFountainId=DefineGenericCityObject("fountain", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);
   int cityFlagId=DefineGenericCityObject("flag", csrtFarAvoidImpassableLand, csrtAvoidConnections, csrtVeryShortAvoidBuildingsShort, csrtPlayer, cstrAvoidForest, csrtAvoidGold);

   int count=0;
   int numTries=75 * ((cNumberNonGaiaPlayers/4)+1);
   float loadingPercent = 0.4 / numTries;
   int failCount=0;
   int maxFailCount=8;
   for(i=0; <numTries)
   {
      rmSetStatusText("",0.55 + (i * loadingPercent));
      int cityID=rmCreateArea("city"+i, midIslandArea);
      rmSetAreaSize(cityID, 0.01, 0.01);
      rmSetAreaWarnFailure(cityID, false);
      
      rmSetAreaMinBlobs(cityID, 1);
      rmSetAreaMaxBlobs(cityID, 1);
      rmSetAreaMinBlobDistance(cityID, 0.0);
      rmSetAreaMaxBlobDistance(cityID, 0.0);
      rmSetAreaCoherence(cityID, 0.0);

      if(rmBuildArea(cityID)==false)
      {
         // Stop trying once we fail 5 times in a row.
         failCount++;
         if(failCount==maxFailCount)
            break;
      }
      else
      {
         failCount=0;

         //rmPlaceObjectDefInArea(cityFarmId, 0, cityID, rmRandInt(0,1));
         //rmPlaceObjectDefInArea(cityGranaryId, 0, cityID, rmRandInt(0,1));
         //rmPlaceObjectDefInArea(cityStorehouseId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityMarketId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityStableId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityArmouryId, 0, cityID, rmRandInt(0,1));

         rmPlaceObjectDefInArea(cityMilitaryAcademyId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityArcheryRangeId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityTempleId, 0, cityID, rmRandInt(0,1));
         //rmPlaceObjectDefInArea(cityManorId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityCounterBarracksId, 0, cityID, rmRandInt(0,1));         

         //rmPlaceObjectDefInArea(cityShrine, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityTentId, 0, cityID, rmRandInt(0,1)); 
         rmPlaceObjectDefInArea(cityFlagId, 0, cityID, rmRandInt(0,1));
         rmPlaceObjectDefInArea(cityManorId, 0, cityID, rmRandInt(2,5));
         rmPlaceObjectDefInArea(cityHouseId, 0, cityID, rmRandInt(7,15));
         rmPlaceObjectDefInArea(cityTorchId, 0, cityID, rmRandInt(0,2));
         //rmPlaceObjectDefInArea(cityFountainId, 0, cityID, rmRandInt(0,1));
      }         
   }
}

void main(void)
{
   // Start
   rmSetStatusText("",0.01);

   // Map Size
   SetMapSize();

   // Default Terrain
   InitialiseWater(); 

   // Set Gaia Info
   rmSetGaiaCiv(cCivZeus);

   // Lighting
   rmSetLightingSet("night");

   rmSetStatusText("",0.1);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classStartingSettlement=rmDefineClass("starting settlement");
   int classConnection=rmDefineClass("connection");
   int classForest=rmDefineClass("forest");

   // Define Constraints Land
   int csrtFarAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
   int csrtAvoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int csrtShortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
   int csrtNearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
   int csrtAvoidConnections=rmCreateClassDistanceConstraint("avoid connections", classConnection, 3.0);  
   int csrtFarAvoidConnections=rmCreateClassDistanceConstraint("far avoid connections", classConnection, 16.0);  

   // Define Constraints Player   
   int csrtPlayer=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
   int csrtShortPlayer=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 4.0);

   // Define Constraints Resources
   int cstrAvoidForest=rmCreateClassDistanceConstraint("avoid forest", classForest, 10.0);
   int csrtAvoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 8.0);
   int csrtAvoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Define Constraints Buildings
   int csrtShortAvoidBuildings=rmCreateTypeDistanceConstraint("short avoid buildings", "Building", 6);
   int csrtVeryShortAvoidBuildings=rmCreateTypeDistanceConstraint("very short avoid buildings", "Building", 3);
   int csrtAvoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);
   int csrtShortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int csrtFarAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int csrtFarStartingSettle=rmCreateClassDistanceConstraint("objects avoid player TCs", classStartingSettlement, 40.0);
   int csrtShortStartingSettle=rmCreateClassDistanceConstraint("objects avoid player TCs", classStartingSettlement, 4.0);
   int csrtAvoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 12.0);

   // Create Island
   int areaMiddleIsland = CreateMiddleIsland();
   int areaCityLimits = CreateCityLimits(areaMiddleIsland, csrtShortAvoidImpassableLand);

   rmSetStatusText("",0.25);

   // Define Objects
   int objStartingSettlement = DefineStartingSettlements(classStartingSettlement, csrtShortAvoidImpassableLand);
   int objStartingTowers = DefineStartingTowers(csrtAvoidTower, csrtShortAvoidImpassableLand);
   int objStartingGoats = DefineStartingGoats(csrtAvoidTower, csrtShortAvoidImpassableLand, csrtAvoidGold, csrtAvoidFood);
   int objStartingGold = DefineStartingGold(csrtAvoidTower, csrtShortStartingSettle, csrtShortAvoidImpassableLand);
   int objStartingChickens = DefineStartingChickens(csrtAvoidTower, csrtShortAvoidImpassableLand, csrtAvoidGold, csrtAvoidFood);

   // Cheesy "circular" placement of players.
   rmPlacePlayersCircular(0.2, 0.2, rmDegreesToRadians(5.0));

   // Define Road
   float connectionPercentage = 1.0/cNumberNonGaiaPlayers;
   if(cNumberNonGaiaPlayers > 10)
   {
      connectionPercentage = 1.5/cNumberNonGaiaPlayers;
   }

   int cnctRoad=rmCreateConnection("road");
   rmAddConnectionToClass(cnctRoad, classConnection);
   rmSetConnectionType(cnctRoad, cConnectAreas, true, connectionPercentage);
   rmSetConnectionWidth(cnctRoad, 3, 1);
   rmSetConnectionHeightBlend(cnctRoad, 0.1);
   rmSetConnectionSmoothDistance(cnctRoad, 1.0);
   rmSetConnectionCoherence(cnctRoad, 0.25);
   rmAddConnectionTerrainReplacement(cnctRoad, "CityTileA", "PlainRoadA");
   rmAddConnectionTerrainReplacement(cnctRoad, "CityTileA", "PlainRoadA");
   rmSetConnectionPositionVariance(cnctRoad, -1);

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(300);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, areaCityLimits);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 1);
      rmSetAreaMinBlobDistance(id, 0.0);
      rmSetAreaMaxBlobDistance(id, 0.0);
      rmSetAreaCoherence(id, 1.0);
      rmAddAreaConstraint(id, csrtPlayer);
      rmAddAreaConstraint(id, csrtShortPlayer);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "PlainRoadA");

      // Add Road Connection
      rmAddConnectionArea(cnctRoad, id);
   }

   rmBuildAllAreas();

   rmSetStatusText("",0.30);

   rmPlaceObjectDefPerPlayer(objStartingSettlement, true);
   rmPlaceObjectDefPerPlayer(objStartingTowers, true, 4);
   rmPlaceObjectDefPerPlayer(objStartingGold, false);
   rmPlaceObjectDefPerPlayer(objStartingGoats, true);
   rmPlaceObjectDefPerPlayer(objStartingChickens, true);

   FairlyPlaceRandomSettlements(csrtFarAvoidImpassableLand, cnctRoad);

   rmSetStatusText("",0.35);

   rmBuildConnection(cnctRoad);

   rmSetStatusText("",0.40);

   FairlyPlaceRandomGoldMines(csrtFarAvoidImpassableLand, csrtFarAvoidConnections);  

   rmSetStatusText("",0.45);

   FairlyPlaceRandomFarms(csrtAvoidImpassableLand, csrtFarAvoidConnections);

   rmSetStatusText("",0.50);

   // Parks.
   int numTries=8*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i, areaCityLimits);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(45), rmAreaTilesToFraction(80));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, csrtPlayer);
      rmAddAreaConstraint(elevID, csrtFarAvoidConnections);
      rmAddAreaConstraint(elevID, csrtAvoidImpassableLand);
      rmAddAreaConstraint(elevID, cstrAvoidForest);
      rmAddAreaConstraint(elevID, csrtAvoidGold);
      rmAddAreaConstraint(elevID, csrtVeryShortAvoidBuildings);
      rmSetAreaForestType(elevID, "mixed oak forest");
      rmSetAreaTerrainType(elevID, "GrassDirt50");
      rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 1);
      rmSetAreaHeightBlend(elevID, 2);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaToClass(elevID, classForest);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 6 times in a row.
         failCount++;
         if(failCount==6)
            break;
      }
      else
         failCount=0;
   }

   rmSetStatusText("",0.55);

   PlaceHouses(areaCityLimits, csrtAvoidImpassableLand, csrtAvoidConnections, csrtShortAvoidBuildings, csrtVeryShortAvoidBuildings, csrtShortPlayer, cstrAvoidForest, csrtAvoidGold);

   rmSetStatusText("",0.95);

   // pick wolf or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   rmAddObjectDefItem(farPredatorID, "dog", 4, 3.0);    
   rmAddObjectDefConstraint(farPredatorID, csrtAvoidGold);
   rmAddObjectDefConstraint(farPredatorID, csrtAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, csrtFarStartingSettle);
   rmAddObjectDefConstraint(farPredatorID, cstrAvoidForest);
   rmSetObjectDefMinDistance(farPredatorID, 10.0);
	rmSetObjectDefMaxDistance(farPredatorID, 200);
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

   // Fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 22.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, 3000);
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers); 

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 60.0));
   rmAddObjectDefConstraint(relicID, csrtAvoidImpassableLand);
   rmAddObjectDefConstraint(relicID, csrtFarStartingSettle);
   rmSetObjectDefMinDistance(relicID, 40.0);
	rmSetObjectDefMaxDistance(relicID, 400);
   rmPlaceObjectDefPerPlayer(relicID, false, 2);

   int nearRiver=rmCreateTerrainMaxDistanceConstraint("near river", "water", true, 2.0);
   int dockID=rmCreateObjectDef("bushs by river");
   rmAddObjectDefItem(dockID, "dock", 1, 0.0);
   //rmAddObjectDefItem(riverBushID, "grass", 7, 8.0);
   rmSetObjectDefMinDistance(dockID, 0.0);
   rmSetObjectDefMaxDistance(dockID, 1000);
   //rmAddObjectDefConstraint(riverBushID, avoidAll);
   rmAddObjectDefConstraint(dockID, nearRiver);
   rmPlaceObjectDefAtLoc(dockID, 0, 0.5, 0.5, 2);

   // Set player starting resources
   for(i=1; <cNumberPlayers)
   {
      rmAddPlayerResource(i, "Food", 300);
      rmAddPlayerResource(i, "Wood", 200);
      rmAddPlayerResource(i, "Gold", 100);
   }

   // End
   rmSetStatusText("",1.00);
}
