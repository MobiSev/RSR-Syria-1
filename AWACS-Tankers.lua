-- Author: Wildcat (Chandawg)
-- Date Created: 04 Nov 2020
-- Same principle used to spawn UAVs, but going to spawn Tankers and AWACs
-- Spawns
---Objects to be spawned with attributes set
Spawn_Blue_AWACs = SPAWN:NewWithAlias("AWACS Blue","Magic 1-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Magic_11)
        Magic_11:CommandSetCallsign(2, 1)
        MESSAGE:New("Magic 1-1 is on station contact on channel 251.000 MHz",25,"Magic 1-1"):ToBlue()                
      end)
    --:SpawnScheduled(30,0.5)

Spawn_Blue_TankerBasket = SPAWN:NewWithAlias("Tanker Basket Blue","Texaco 1-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Texaco_11)
        Texaco_11:CommandSetCallsign(1, 2)
        MESSAGE:New("Texaco 1-1 (Basket) is on station contact on channel 142.000 MHz",25,"Texaco 1-1"):ToBlue()
      end)
    --:SpawnScheduled(30,0.5)

Spawn_Blue_TankerBoom = SPAWN:NewWithAlias("Tanker Boom Blue","Texaco 2-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Texaco_21)
        Texaco_21:CommandSetCallsign(1, 2)
        Texaco_21:CommandSetFrequency(141.000)
        MESSAGE:New("Texaco 2-1 (Boom) is on station contact on channel 141.000 MHz",25,"Texaco 2-1"):ToBlue()
      end)
    --:SpawnScheduled(30,0.5)


Spawn_Red_AWACs = SPAWN:NewWithAlias("AWACS Red","Overlord 1-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Overlord_11)
        Overlord_11:CommandSetCallsign(1, 1)
        MESSAGE:New("Overlord 1-1 is on station contact on channel 121.000 MHz",25,"Overlord 1-1"):ToRed()
      end)

Spawn_Red_TankerBasket = SPAWN:NewWithAlias("Tanker Basket Red","Shell 1-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Shell_11)
        Shell_11:CommandSetCallsign(3, 1)
        MESSAGE:New("Shell 1-1 (Basket) is on station contact on channel 142.000 MHz",25,"Shell 1-1"):ToRed()
      end)
    --:SpawnScheduled(30,0.5)

Spawn_Red_TankerBoom = SPAWN:NewWithAlias("Tanker Boom Red","Shell 2-1")
    :InitLimit(1,0)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Shell_21)
        Shell_21:CommandSetCallsign(3, 2)
        MESSAGE:New("Shell 2-1 (Boom) is on station contact on channel 141.000 MHz",25,"Shell 2-1"):ToRed()
      end)
    --:SpawnScheduled(30,0.5)
              
----Function to actually spawn the UAV from the players nose      
function BlueAWACs(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_AWACs:SpawnFromVec3(spawnVec3)
end

function BlueTankerBasket(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_TankerBasket:SpawnFromVec3(spawnVec3)
end

function BlueTankerBoom(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_TankerBoom:SpawnFromVec3(spawnVec3)
end

function RedAWACs(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_AWACs:SpawnFromVec3(spawnVec3)
end

function RedTankerBasket(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_TankerBasket:SpawnFromVec3(spawnVec3)
end

function RedTankerBoom(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_TankerBoom:SpawnFromVec3(spawnVec3)
end

----Define the client to have the menu
local SetClient3 = SET_CLIENT:New():FilterCoalitions("blue"):FilterPrefixes({" Blue AF"}):FilterStart()
local SetClient4 = SET_CLIENT:New():FilterCoalitions("red"):FilterPrefixes({" Red AF"}):FilterStart()
----Menus for the client
local function AWACs_Tanker_MENU()
  SetClient3:ForEachClient(function(client3)
      if (client3 ~= nil) and (client3:IsAlive()) then 
      local group3 = client3:GetGroup()
      local groupName = group3:GetName()
            BlueMenuGroup2 = group3
            BlueMenuGroupName2 = BlueMenuGroup2:GetName()
            ----Main Menu
            BlueSpawnAWACs = MENU_GROUP:New( BlueMenuGroup2, "AWACS-Tankers" )
            ---- Sub Menu
            BlueSpawnAWACsmenu = MENU_GROUP:New( BlueMenuGroup2, "Spawn AWACs-Tankers", BlueSpawnAWACs)
            ---- Command for the sub Menu the number on the end is the argument for the command (the rng) for the function
            BlueSpawnAWACsrng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "E-3 5 nmi in front co-altitude", BlueSpawnAWACs, BlueAWACs, BlueMenuGroup2, 5)
            BlueSpawnTanker1rng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "KC-135MPRS 5 nmi in front co-altitude", BlueSpawnAWACs, BlueTankerBasket, BlueMenuGroup2, 5)
            BlueSpawnTanker2rng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "KC-135 5 nmi in front co-altitude", BlueSpawnAWACs, BlueTankerBoom, BlueMenuGroup2, 5)
            ---- Enters log information
            env.info("Player name: " ..client3:GetPlayerName())
            env.info("Group Name: " ..group3:GetName())
            SetClient3:Remove(client3:GetName(), true)
    end
  end)
timer.scheduleFunction(AWACs_Tanker_MENU,nil,timer.getTime() + 1)
end
local function AWACs_Tanker_MENU2()
  SetClient4:ForEachClient(function(client4)
      if (client4 ~= nil) and (client4:IsAlive()) then 
      local group4 = client4:GetGroup()
      local groupName = group4:GetName()
            RedMenuGroup2 = group4
            RedMenuGroupName2 = RedMenuGroup2:GetName()
            ----Main Menu
            RedSpawnAWACs = MENU_GROUP:New( RedMenuGroup2, "AWACS-Tankers" )
            ---- Sub Menu
            RedSpawnAWACsmenu = MENU_GROUP:New( RedMenuGroup2, "Spawn AWACs-Tankers", RedSpawnAWACs)
            ---- Command for the sub Menu the number on the end is the argument for the command (the rng) for the function
            RedSpawnAWACsrng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "E-3 5 nmi in front co-altitude", RedSpawnAWACs, RedAWACs, RedMenuGroup2, 5)
            RedSpawnTanker1rng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "KC-135MPRS 5 nmi in front co-altitude", RedSpawnAWACs, RedTankerBasket, RedMenuGroup2, 5)
            RedSpawnTanker2rng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "KC-135 5 nmi in front co-altitude", RedSpawnAWACs, RedTankerBoom, RedMenuGroup2, 5)
            ---- Enters log information
            env.info("Player name: " ..client4:GetPlayerName())
            env.info("Group Name: " ..group4:GetName())
            SetClient4:Remove(client4:GetName(), true)
    end
  end)
timer.scheduleFunction(AWACs_Tanker_MENU2,nil,timer.getTime() + 1)
end
AWACs_Tanker_MENU()
AWACs_Tanker_MENU2()