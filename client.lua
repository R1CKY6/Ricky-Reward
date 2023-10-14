-- Tech Development on top
-- Other free script here
-- https://discord.gg/tHAbhd94vS

local ESX = nil 
local QBCore = nil
local FrameworkFound = nil
Citizen.CreateThread(function()
    if Config.Framework == 'esx' then 
        ESX = exports.es_extended:getSharedObject()
        FrameworkFound = 'esx'
     elseif Config.Framework == 'qbcore' then
        QBCore = exports["qb-core"]:GetCoreObject()
        FrameworkFound = 'qbcore'
     elseif Config.Framework == 'autodetect' then 
        if GetResourceState('es_extended') == 'started' then
            ESX = exports.es_extended:getSharedObject() 
            FrameworkFound = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            QBCore = exports["qb-core"]:GetCoreObject()
            FrameworkFound = 'qbcore'
        end
    end

    Wait(100)
    SendNUIMessage({
        type = "SET_NAME",
        name = GetPlayerName(PlayerId())
    })
end)

Notification = function(text, type)
    if FrameworkFound == 'esx' then 
        ESX.ShowNotification(text, type)
    elseif FrameworkFound == 'qbcore' then
        QBCore.Functions.Notify(text, type)
    end
end

RegisterCommand('rewardstaff', function(source, args, rawCommand)
    if not SonoStaff() then 
        Notification(Config.Locales['not_staff'], 'error')
        return 
    end
    SendNUIMessage({
        type = "SET_STAFF",
        staff = SonoStaff()
    })
    OpenReward()
end)

RegisterCommand('reward', function(source, args, rawCommand)
    SendNUIMessage({
        type = "SET_STAFF",
        staff = false
    })
    OpenReward()
end)

TriggerServerCallback = function(name, data)
    local data2 = nil
    if FrameworkFound == 'esx' then 
        ESX.TriggerServerCallback(name, function(data3) 
            data2 = data3
        end, data)
    elseif FrameworkFound == 'qbcore' then
        QBCore.Functions.TriggerCallback(name, function(data3)
            data2 = data3
        end, data)
    end

    while data2 == nil do
        Wait(0)
    end

    return data2
end

SonoStaff = function()
    local staff = TriggerServerCallback('ricky-reward:sonoStaff')
    return staff
end

OpenReward = function()
    SetNuiFocus(true, true)
    if SonoStaff() then 
        updateStaffReward()
    end

    updateUserReward()
    SendNUIMessage({
        type = "SET_LOCALES",
        locales = Config.Locales
    })
    SendNUIMessage({
        type = "OPEN"
    })
end

RegisterNUICallback('createReward', function(data, cb)
    local code = TriggerServerCallback('ricky-reward:createReward', data)
    cb(code)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('deleteReward', function(data, cb)
    local deleted = TriggerServerCallback('ricky-reward:deleteReward', data)
    cb(deleted)
end)

RegisterNUICallback('checkCode', function(data, cb)
    local code = data
    local result = TriggerServerCallback('ricky-reward:checkCode', code)
    cb(result)
end)

RegisterNUICallback('redeemCode', function(data, cb)
    local code = data
    local data = TriggerServerCallback('ricky-reward:redeemCode', code)
    cb(data)
end)

RegisterNUICallback('checkVehicle', function(data, cb)
    local carName = data.car
    if carName then 
        if IsModelInCdimage(carName) then 
            if IsModelAVehicle(carName) then 
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

updateStaffReward = function()
    local staffRewards = TriggerServerCallback('ricky-reward:getRewardCreated')
    for k,v in pairs(staffRewards) do 
        v.viewCode = false 
    end
    SendNUIMessage({
        type = "UPDATE_STAFF_REWARDS",
        staffRewards = staffRewards
    })
end

updateUserReward = function()
    local userRewards = TriggerServerCallback('ricky-reward:getRewardRedeemed')
    for k,v in pairs(userRewards) do 
        v.viewCode = false 
    end

    SendNUIMessage({
        type = "UPDATE_USER_REWARDS",
        userRewards = userRewards
    })
end

RegisterNetEvent('ricky-reward:updateStaffReward')
AddEventHandler('ricky-reward:updateStaffReward', function()
    updateStaffReward()
end)

RegisterNetEvent('ricky-reward:updateUserReward')
AddEventHandler('ricky-reward:updateUserReward', function()
    updateUserReward()
end)

GenerateVehicleProps = function(vehicle)
    if FrameworkFound == 'esx' then 
        local props = ESX.Game.GetVehicleProperties(vehicle)
        return props
    elseif FrameworkFound == 'qbcore' then
        local props = QBCore.Functions.GetVehicleProperties(vehicle)
        return props
    end
end

RegisterNetEvent('ricky-reward:giveCar')
AddEventHandler('ricky-reward:giveCar', function(data)
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    RequestModel(data.car)
    while not HasModelLoaded(data.car) do
        Wait(0)
    end
    local vehicle = CreateVehicle(GetHashKey(data.car), coords, heading, true, false)
    local props = GenerateVehicleProps(vehicle)
    if #data.plate >= 1 then 
        props.plate = data.plate
    end
    SetEntityVisible(vehicle, false, false)
    SetEntityCollision(vehicle, false, false)
    TriggerServerEvent('ricky-reward:giveCar', props, data.car)
    DeleteEntity(vehicle)
end)