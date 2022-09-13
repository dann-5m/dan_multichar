local QBCore = exports['qb-core']:GetCoreObject()

local function GiveStarterItems(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, v.amount, false, info)
    end
end

local function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations', {})
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

-- Commands

QBCore.Commands.Add("logout", "Logout of Character (Admin Only)", {}, false, function(source)
    local src = source
    QBCore.Player.Logout(src)
    TriggerClientEvent('dan_multichar:chooseChar', src)
end, "admin")

-- Callbacks

QBCore.Functions.CreateCallback("dan_multichar:FetchCharacters", function(source, cb)
    if source then
        local plyChars = {}
        local characters = exports.oxmysql:executeSync('SELECT * FROM players WHERE license = :UID', {UID = QBCore.Functions.GetIdentifier(source, 'license')})
        if characters then
            for i = 1, #characters do
                characters[i].charinfo = json.decode(characters[i].charinfo)
                characters[i].money = json.decode(characters[i].money)
                characters[i].job = json.decode(characters[i].job)
                plyChars[#plyChars+1] = characters[i]
            end
            print(#plyChars)
            cb(plyChars)
        end
    end
end)

QBCore.Functions.CreateCallback("dan_multichar:getSkin", function(source, cb, cid)
    if cid then
        local result = exports.oxmysql:executeSync('SELECT * FROM playerskins WHERE citizenid = :citizenid', {citizenid = cid})
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)

RegisterNetEvent('dan_multichar:loadUserData', function(cData,id)
    local src = source
    if QBCore.Player.Login(src, id) then
        QBCore.Commands.Refresh(src)
        loadHouseData()
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..(QBCore.Functions.GetIdentifier(src, 'discord') or 'undefined') .." |  ||"  ..(QBCore.Functions.GetIdentifier(src, 'ip') or 'undefined') ..  "|| | " ..(QBCore.Functions.GetIdentifier(src, 'license') or 'undefined') .." | " ..id.." | "..src..") loaded..")
	end
end)

AddEventHandler('dan_multichar:loadHouseData', function()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations', {})
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
end)


RegisterNetEvent('dan_multichar:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.charinfo = data
    if QBCore.Player.Login(src, false, newData) then
        if Config.StartingApartment then
            local randbucket = (GetPlayerPed(src) .. math.random(1,999))
            SetPlayerRoutingBucket(src, randbucket)
            QBCore.Commands.Refresh(src)
            loadHouseData()
            TriggerClientEvent("dan_multichar:closeNUI", src)
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
            GiveStarterItems(src)
        else
            QBCore.Commands.Refresh(src)
            loadHouseData()
            TriggerClientEvent("dan_multichar:closeNUI", src)
            GiveStarterItems(src)
        end
	end
end)

RegisterNetEvent('dan_multichar:deleteCharacter', function(citizenid)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenid)
end)