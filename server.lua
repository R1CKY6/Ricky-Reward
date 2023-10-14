-- Tech Development on top
-- Other free script here
-- https://discord.gg/tHAbhd94vSs

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
    else
        print("Invalid Framework, please check your config.lua file.")
        return
    end


    RegisterServerCallback = function(name, cb)
        if FrameworkFound == 'esx' then 
            ESX.RegisterServerCallback(name, cb)
        elseif FrameworkFound == 'qbcore' then
            QBCore.Functions.CreateCallback(name, cb)
        end
    end

    GetPlayer = function(source)
        if FrameworkFound == 'esx' then 
            return ESX.GetPlayerFromId(source)
        elseif FrameworkFound == 'qbcore' then
            return QBCore.Functions.GetPlayer(source)
        end
    end
    
    SonoStaff = function(source)
        if FrameworkFound == 'esx' then 
            local xPlayer = GetPlayer(source)
            for k,v in pairs(Config.AdminGroups) do
                if xPlayer.getGroup() == v then 
                    return true
                end
            end
        elseif FrameworkFound == 'qbcore' then
            for k,v in pairs(Config.AdminGroups) do
                if QBCore.Functions.HasPermission(source, v) then 
                    return true
                end
            end
        end
        return false
    end
    
    GetIdentifier = function(source)
        local identifiers = GetPlayerIdentifiers(source)
        for i=1, #identifiers, 1 do
            if string.match(identifiers[i], 'license:') then
                identifiers[i] = string.gsub(identifiers[i], 'license:', '')
                return identifiers[i]
            end
        end
    end
    
    generateCode = function()
        local length = tonumber(Config.CodeSettings.length)
        local prefix = Config.CodeSettings.prefix
        local letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        local code = prefix
        for i = 1, length, 1 do
            local random = math.random(1, #letters)
            code = code..string.sub(letters, random, random)
        end
        return code
    end
    
    checkCode = function(code)
        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_reward WHERE code = @code", {
            ['@code'] = code,
        })
        if result[1] ~= nil then
            return true
        else
            return false
        end
    end
    
    checkUsed = function(code)
        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_reward WHERE code = @code", {
            ['@code'] = code,
        })
        local userInfo = json.decode(result[1].userInfo)
        if userInfo.identifier == nil then
            return false
        else
            return true
        end
    end
    
    RegisterServerEvent('ricky-reward:giveCar')
    AddEventHandler('ricky-reward:giveCar', function(data, vehicleLabel)
        local player = GetPlayer(source)
        local identifier = nil
        if FrameworkFound == 'esx' then 
            identifier = player.identifier
            AssignVehicle(FrameworkFound, identifier, data, nil, vehicleLabel)
        elseif FrameworkFound == 'qbcore' then
            identifier = player.PlayerData.license 
            citizenid = player.PlayerData.citizenid
            AssignVehicle(FrameworkFound, identifier, data, citizenid, vehicleLabel)
        end    
    end)

    RegisterServerCallback('ricky-reward:checkCode', function(source, cb, code)
        cb(checkCode(code) and not checkUsed(code))
    end)
    
    RegisterServerCallback('ricky-reward:redeemCode', function(source, cb, code)
        if not checkCode(code) then 
            cb(false)
            return 
        end
    
        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_reward WHERE code = @code", {
            ['@code'] = code,
        })
    
        local name = GetPlayerName(source)
        local identifier = GetIdentifier(source)
    
        local userInfo = json.decode(result[1].userInfo)
        userInfo.name = name
        userInfo.identifier = identifier
    
        MySQL.Sync.execute("UPDATE ricky_reward SET userInfo = @userInfo WHERE code = @code", {
            ['@userInfo'] = json.encode(userInfo),
            ['@code'] = code,
        })
        
        cb(json.decode(result[1].data))
    
        if json.decode(result[1].data).type == 'money' then 
            local data = json.decode(result[1].data)
            data.amount = tonumber(data.amount)
            local xPlayer = GetPlayer(source)
            if data.account == 'bank' then 
                if FrameworkFound == 'esx' then 
                    xPlayer.addAccountMoney('bank', data.amount, 'Reward System')
                elseif FrameworkFound == 'qbcore' then
                    xPlayer.Functions.AddMoney('bank', data.amount, 'Reward System')
                end
            elseif data.account == 'money' then
                if FrameworkFound == 'esx' then 
                    xPlayer.addInventoryItem('money', data.amount)
                elseif FrameworkFound == 'qbcore' then
                    xPlayer.Functions.AddMoney('cash', data.amount, 'Reward System')
                end
            elseif data.account == 'black_money' then
                if FrameworkFound == 'esx' then 
                    xPlayer.addInventoryItem('black_money', data.amount)
                elseif FrameworkFound == 'qbcore' then
                    xPlayer.Functions.AddMoney('black_money', data.amount, 'Reward System')
                end
            end
    
        elseif json.decode(result[1].data).type == 'car' then 
            local data = json.decode(result[1].data)
            local xPlayer = GetPlayer(source)
            TriggerClientEvent('ricky-reward:giveCar', source, data)
        end
        TriggerClientEvent('ricky-reward:updateUserReward', source)
    end)
    
    RegisterServerCallback('ricky-reward:getRewardRedeemed', function(source, cb)
        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_reward")
        local reward = {}
        for i=1, #result, 1 do
            local userInfo = json.decode(result[i].userInfo)
            if userInfo.identifier == GetIdentifier(source) then
                table.insert(reward, result[i])
            end
        end
        cb(reward)
    end)
    
    RegisterServerCallback('ricky-reward:getRewardCreated', function(source, cb)
        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_reward")
        local reward = {}
        for i=1, #result, 1 do
            local staffInfo = json.decode(result[i].staffInfo)
            if staffInfo.identifier == GetIdentifier(source) then
                table.insert(reward, result[i])
            end
        end
        cb(reward)
    end)
    
    RegisterServerCallback('ricky-reward:createReward', function(source, cb, data)
        local name = GetPlayerName(source)
        local identifier = GetIdentifier(source)
        local staffInfo = {
            name = name,
            identifier = identifier,
        }
    
        if not SonoStaff(source) then 
            return 
        end
    
        local code = generateCode()
        while checkCode(code) do
            code = generateCode()
        end
    
        if data.type == 'car' then 
            data.typeLabel = Config.Locales['car_type']
        elseif data.type == 'money' then 
            data.typeLabel = Config.Locales['money']
            
            if data.account == 'bank' then 
                data.accountLabel = Config.Locales['bank']
            elseif data.account == 'money' then
                data.accountLabel = Config.Locales['money']
            elseif data.account == 'black_money' then
                data.accountLabel = Config.Locales['black_money']
            end
        end
    
        MySQL.Sync.execute("INSERT INTO ricky_reward (code, data, staffInfo, date, userInfo) VALUES(@code, @data, @staffInfo, @date, @userInfo)", {
            ['@code'] = code,
            ['@data'] = json.encode(data),
            ['@staffInfo'] = json.encode(staffInfo),
            ['@date'] = os.date('%d/%m/%Y %H:%M'),
            ['@userInfo'] = json.encode({})
        })
        cb(code)
        TriggerClientEvent('ricky-reward:updateStaffReward', source)
    end)
    
    
    RegisterServerCallback('ricky-reward:deleteReward', function(source, cb, code)
        if not SonoStaff(source) then 
            return 
        end
    
        if checkCode(code) then 
            MySQL.Sync.execute("DELETE FROM ricky_reward WHERE code = @code", {
                ['@code'] = code,
            })
            cb(true)
        else
            cb(false)
        end
        TriggerClientEvent('ricky-reward:updateStaffReward', source)
    end)
    
    
    RegisterServerCallback('ricky-reward:sonoStaff', function(source, cb)
        cb(SonoStaff(source))
    end)

    Wait(1000)
    print('Framework Found: '..FrameworkFound)
end)
