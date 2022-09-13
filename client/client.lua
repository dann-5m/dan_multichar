local Characters = {}
local isCamActive = false
local charPed = nil
local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('dan_multichar:chooseChar')
			return
		end
	end
end)

local function loadHouseData()
  local HouseGarages = {}
  local Houses = {}
  local result = MySQL.Sync.fetchAll('SELECT * FROM houselocations', {})
  if result[1] ~= nil then
      for k, v in pairs(result) do
          local owned = false
          if tonumber(v.owned) == 1 then
              owned = true
          end
          local garage = v.garage ~= nil and json.decode(v.garage) or {}
          Houses[v.name] = {
              coords = json.decode(v.coords),
              owned = v.owned,
              price = v.price,
              locked = true,
              adress = v.label,
              tier = v.tier,
              garage = garage,
              decorations = {},
          }
          HouseGarages[v.name] = {
              label = v.label,
              takeVehicle = garage,
          }
      end
  end
  TriggerClientEvent("qb-garages:client:houseGarageConfig", -1, HouseGarages)
  TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Houses)
end


local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  cb({})
  ToggleCamera()
  DeleteEntity(charPed)
  charPed = nil
end)

ToggleCamera = function()
  if not isCamActive then
    DoScreenFadeOut(500)
    Wait(500)
    CharCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(CharCamera, true)
		RenderScriptCams(true, false, 1, true, true)
		SetCamCoord(CharCamera, -919.1846, -440.6378, 120.2044)
		PointCamAtCoord(CharCamera, -912.6655, -442.7600, 119.2044 + 1.3)
    isCamActive = true
    Wait(500)
    DoScreenFadeIn(500)
  else
    Wait(800)
		SetCamActive(CharCamera, false)
		RenderScriptCams(false, false, 0, true, true)
		CharCamera = nil
    isCamActive = false
  end
end

RegisterNUICallback('DeletePrevPed', function(data,cb)
  DeleteEntity(charPed)
  charPed = nil
end)

Positions = {
  {pedCoords = vector4(-915.7780, -440.5512, 119.2254, 116.7088),animation = "base_amanda",dict = "timetable@reunited@ig_10"},
  {pedCoords = vector4(-915.0660, -441.9583, 119.2254, 117.3233),animation = "base",dict = "timetable@ron@ig_3_couch"},
  {pedCoords = vector4(-915.4965, -442.4395, 119.2254, 32.5241),animation = "ig_5_p3_base",dict = "timetable@ron@ig_5_p3"},
  {pedCoords = vector4(-916.7404, -443.2154, 119.2254, 32.2869),animation = "base_amanda",dict = "timetable@reunited@ig_10"},
}

RegisterNUICallback('CurrentCharacter', function(charID,cb)
  QBCore.Functions.TriggerCallback("dan_multichar:getSkin", function(model,skinData)
    if model ~= nil then model = tonumber(model) end
    if model ~= nil then
      RequestModel(model)
      while not HasModelLoaded(model) do
          Wait(0)
      end
      Position = Positions[math.random(#Positions)]
      charPed = CreatePed(2, model, Position.pedCoords, false, true)
      loadAnimDict(Position['dict'])
      TaskPlayAnim(charPed, Position['dict'], Position['animation'], 1000.0, 1000.0, -1, 1, 0, false, false, false)
      SetPedComponentVariation(charPed, 0, 0, 0, 2)
      FreezeEntityPosition(charPed, false)
      SetEntityInvincible(charPed, true)
      PlaceObjectOnGroundProperly(charPed)
      SetBlockingOfNonTemporaryEvents(charPed, true)
      data = json.decode(skinData)
      TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)

    else
      local model = GetHashKey("mp_m_freemode_01")
      RequestModel(model)
      while not HasModelLoaded(model) do
          Wait(0)
      end
      Position = Positions[math.random(#Positions)]
      charPed = CreatePed(2, model, Position.pedCoords, false, true)
      loadAnimDict(Position['dict'])
      TaskPlayAnim(charPed, Position['dict'], Position['animation'], 1000.0, 1000.0, -1, 1, 0, false, false, false)
      SetPedComponentVariation(charPed, 0, 0, 0, 2)
      FreezeEntityPosition(charPed, false)
      SetEntityInvincible(charPed, true)
      PlaceObjectOnGroundProperly(charPed)
      SetBlockingOfNonTemporaryEvents(charPed, true)
      SetEntityAlpha(charPed, 100, false)
    end
    cb("ok")
  end, charID)
end)

function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(5)
  end
end

RegisterNUICallback('SelectCharacter', function(data,cb)
  local id = data.id
  local cData = data.cData
  toggleNuiFrame(false)
  DoScreenFadeOut(500)
  Wait(750)
  ToggleCamera()
  TriggerServerEvent('dan_multichar:loadUserData', cData,id)
  SetEntityAsMissionEntity(charPed, true, true)
  DeleteEntity(charPed)
  FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNUICallback('DeleteCharacter', function(data, cb)
  TriggerServerEvent('dan_multichar:deleteCharacter', data.id)
  SendReactMessage('removeChar', data.id)
  cb("ok")
end)

RegisterNetEvent('dan_multichar:DeleteCamera', function()
  DestroyCam(CharCamera)
end)

RegisterNetEvent('dan_multichar:chooseChar', function()
  SetNuiFocus(false, false)
  DoScreenFadeOut(10)
  Wait(1000)
  local interior = GetInteriorAtCoords(-915.1423, -442.1271, 120.2254)
  LoadInterior(interior)
  while not IsInteriorReady(interior) do
      Wait(1000)
  end
  FreezeEntityPosition(PlayerPedId(), true)
  SetEntityCoords(PlayerPedId(), -922.1642, -440.1428, 120.2044)
  Wait(1500)
  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()
  SetUpChar()
end)

function SetUpChar()
  NetworkOverrideClockTime(22, 00, 0)
  SetWeatherTypeNow("EXTRASUNNY")

  QBCore.Functions.TriggerCallback("dan_multichar:FetchCharacters", function(characters)
    local sendData = {}
    if characters then
      for i=1, #characters do
        local info = characters[i].charinfo
        local Bank = characters[i].money
        local data = {
          name = info.firstname.." "..info.lastname,
          birthdate = info.birthdate,
          id = characters[i].citizenid,
          phone = info.phone,
          bank = Bank.bank,
          cData = characters[i],
        }
        sendData[i] = data
      end
      Wait(500)
      ToggleCamera()
      toggleNuiFrame(true)
      SendReactMessage('characters', sendData)
    else
      Wait(500)
      ToggleCamera()
      toggleNuiFrame(true)
      SendReactMessage('characters')
    end
  end)
end

RegisterNUICallback('createCharacter', function(data,cb)
  local cData = data
  DoScreenFadeOut(150)
  if cData.gender == "m" then
      cData.gender = 0
  elseif cData.gender == "f" then
      cData.gender = 1
  end
  TriggerServerEvent('dan_multichar:createCharacter', cData)
  Wait(500)
  cb("ok")
end)

RegisterNetEvent('dan_multichar:closeNUI', function()
  toggleNuiFrame(false)
  ToggleCamera()
  DeleteEntity(charPed)
  charPed = nil
end)