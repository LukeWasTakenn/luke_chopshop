local PedIsCloseToPed = false
local HasVehicleObjective = false
local PedHasTalked = false
local PedIsAtChopShop = false
local HasGarageObjective = false
local CoupeDoors = {0, 1, 4, 5}
local PlayerData = {}
ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

--Creating the NPC
Citizen.CreateThread(function()
  local NPCModel = Config.NPCModel
  RequestModel(NPCModel)

  while not HasModelLoaded(NPCModel) do
      Citizen.Wait(0)
  end

  local NPC = CreatePed(4, Config.NPCModel, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z, Config.NPCLocation.h, false, true)
  SetPedFleeAttributes(NPC, 2)
  SetBlockingOfNonTemporaryEvents(NPC, true)
  SetPedCanRagdollFromPlayerImpact(NPC, false)
  SetPedDiesWhenInjured(NPC, false)
  FreezeEntityPosition(NPC, true)
  SetEntityInvincible(NPC, true)
  SetPedCanPlayAmbientAnims(NPC, true)
  TaskStartScenarioInPlace(NPC, "WORLD_HUMAN_DRUG_DEALER", 0, false)
end)

--Checking the distance
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(300)
    PlayerCoords = GetEntityCoords(PlayerPedId())

    if Get3DDistance(PlayerCoords, Config.NPCLocation) < 3 and PedHasTalked == false then
      PedIsCloseToPed = true
    else
      PedIsCloseToPed = false
    end
  end
end)

--Drawing the marker if the player is close
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(4)

    if PedIsCloseToPed == true and PedHasTalked == false then
      Draw3DText(Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z+1.25, "Press ~r~[E] ~w~To ~r~Talk ~w~To The Stranger", 0.4)
    end

    if PedIsAtChopShop == true then
      Draw3DText(randomGarage.x, randomGarage.y, randomGarage.z, "Press ~r~[E] ~w~To ~r~Chop ~w~The Vehicle", 0.4)
    end

    --Talk to the ped
    if IsControlJustReleased(0, 51) and PedIsCloseToPed == true then
      exports['pogressBar']:drawBar(10000, "Talking")
      TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
      Citizen.Wait(10000)
      ESX.ShowAdvancedNotification('Stranger', '', "Get the vehicle, deliver it to the garage and you'll be paid.", 'CHAR_MULTIPLAYER', 1)
      PedHasTalked = true
      ClearPedTasksImmediately(GetPlayerPed(-1))
    end

    --Chop the vehicle
    if IsControlJustReleased(0, 51) and PedIsAtChopShop then
      if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= vehicleToFind then
        ESX.ShowNotification("This is not the right vehicle")
      else
        local NumberOfDoors = GetNumberOfVehicleDoors(vehicleToFind)
        FreezeEntityPosition(vehicleToFind, true)
        if NumberOfDoors > 4 then
          for v = 0, NumberOfDoors-1 do
            SetVehicleDoorOpen(vehicleToFind, v, false, false)
            exports['pogressBar']:drawBar(Config.ChoppingTime, 'Chopping the Vehicle')
            Citizen.Wait(Config.ChoppingTime)
            SetVehicleDoorBroken(vehicleToFind, v, false)
          end
        else
          for k, v in pairs(CoupeDoors) do
            SetVehicleDoorOpen(vehicleToFind, v, false, false)
            exports['pogressBar']:drawBar(Config.ChoppingTime, 'Chopping the Vehicle')
            Citizen.Wait(Config.ChoppingTime)
            SetVehicleDoorBroken(vehicleToFind, v, false, false)
          end
        end

        exports['pogressBar']:drawBar(Config.FinishingUpTime, 'Finishing Up...')
        Citizen.Wait(Config.FinishingUpTime)

        Health = GetVehicleBodyHealth(vehicleToFind)
        TriggerServerEvent('luke_chopshop:Payment', Health)

        RemoveBlip(GarageBlip)
        FreezeEntityPosition(vehicleToFind, false)
        DeleteEntity(vehicleToFind)
        vehiclePlate = ''
        PedIsAtChopShop = false
        HasVehicleObjective = false
        HasGarageObjective = false
        PedHasTalked = false
        if Config.EnableCooldown == true then
          Citizen.Wait(Config.Cooldown)
        end

      end
    end
  end
end)

--Getting a random vehicle
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(800)
    if PedHasTalked == true and HasVehicleObjective == false then
      GetRandomVehicle()
    end

    if GetVehiclePedIsIn((GetPlayerPed(-1)), false) == vehicleToFind and HasGarageObjective == false then
      RemoveBlip(VehicleBlip)
      GetRandomGarage()
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(300)
    if HasGarageObjective == true then
      if Get3DDistance(PlayerCoords, randomGarage) < 5 then
        PedIsAtChopShop = true
      else
        PedIsAtChopShop = false
      end
    end
  end
end)

function GetRandomGarage()
  HasGarageObjective = true
  math.randomseed(GetGameTimer())
  randomGarage = Config.DeliveryGarages[math.random(#Config.DeliveryGarages)]

  GarageBlip = AddBlipForCoord(randomGarage.x, randomGarage.y, randomGarage.z)
  SetBlipSprite(GarageBlip, 1) -- Blip icon
  SetBlipScale(GarageBlip, 0.9) -- Blip size (Value of 1 breaks it for some reason)
  SetBlipColour(GarageBlip, 1) -- Taxi Yellow color (5)
  SetBlipDisplay(GarageBlip, 2) -- Show both on map and minimap (2)
  SetBlipAsShortRange(GarageBlip, false) -- BLip only appears when it's in range
  SetBlipRoute(GarageBlip, true)

  BeginTextCommandSetBlipName("STRING") -- Text type String
  AddTextComponentString('Delivery Garage') -- String name
  EndTextCommandSetBlipName(GarageBlip)

  return randomGarage
end

function GetRandomVehicle()
  HasVehicleObjective = true
  math.randomseed(GetGameTimer())
  local randomVehicle = Config.Vehicles[math.random(#Config.Vehicles)]
  local randomCoords = Config.VehicleLocations[math.random(#Config.VehicleLocations)]


  ESX.Game.SpawnVehicle(randomVehicle, vector3(randomCoords.x, randomCoords.y, randomCoords.z), randomCoords.h, function(vehicle)
    vehicleToFind = vehicle
    vehiclePlate = GetVehicleNumberPlateText(vehicle)
  end)

  VehicleBlip = AddBlipForCoord(randomCoords.x, randomCoords.y, randomCoords.z)
  SetBlipSprite(VehicleBlip, 1) -- Blip icon
  SetBlipScale(VehicleBlip, 0.9) -- Blip size (Value of 1 breaks it for some reason)
  SetBlipColour(VehicleBlip, 1) -- Taxi Yellow color (5)
  SetBlipDisplay(VehicleBlip, 2) -- Show both on map and minimap (2)
  SetBlipAsShortRange(VehicleBlip, false) -- BLip only appears when it's in range
  SetBlipRoute(VehicleBlip, true)

  BeginTextCommandSetBlipName("STRING") -- Text type String
  AddTextComponentString('Vehicle') -- String name
  EndTextCommandSetBlipName(VehicleBlip)
  return vehicleToFind
end

function Get3DDistance(originCoords, objectCoords)
  return math.sqrt((objectCoords.x - originCoords.x) ^ 2 + (objectCoords.y - originCoords.y) ^ 2 + (objectCoords.z - originCoords.z) ^ 2)
end

function Draw3DText(x, y, z, text, scale)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

  SetTextScale(scale, scale)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextEntry("STRING")
  SetTextCentre(true)
  SetTextColour(255, 255, 255, 215)
  AddTextComponentString(text)
  DrawText(_x, _y)
  
  local factor = (string.len(text)) / 700
  DrawRect(_x, _y + 0.0150, 0.06 + factor, 0.03, 41, 11, 41, 100)
end