-- Tech Development on top
-- Other free script here
-- https://discord.gg/tHAbhd94vS

Config = {}

Config.Framework = 'autodetect' -- autodetect, esx, qbcore

Config.AdminGroups = {
    'admin'
}

Config.CodeSettings = {
    prefix = "TECH-",
    length = 6,
}

Config.Locales = {
    ['create_reward'] = "Create Reward",
    ['created_reward'] = "Created Reward",
    ['step'] = "Step",
    ['reward_type'] = "Reward Type",
    ['next'] = "Next",
    ['money_reward'] = "Money Reward",
    ['amount'] = "Amount",
    ['custom_message'] = "Custom Message",
    ['custom_message_nb'] = "This message will be displayed when the player redeems this item.",
    ['create'] = "Create",
    ['vehicle_reward'] = "Vehicle Reward",
    ['car'] = "Car Name",
    ['custom_plate'] = "Custom Plate",
    ['congratulations'] = "Congratulations!",
    ['created_successfully'] = "Created successfully!",
    ['reward_info'] = "Reward Info",
    ['type'] = "Type",
    ['account'] = "Account",
    ['money'] = "Money",
    ['bank'] = "Bank",
    ['black_money'] = "Black Money",
    ['car_type'] = " Car",
    ['none'] = "None",
    ['return_menu'] = "Main Menu",
    ['copy_code'] = "Copy Code",
    ['copied'] = "Copied!",
    ['no_vehicle'] = "This vehicle doesn’t exist",
    ['reward_info'] = "Reward Info",
    ['redeemed_from'] = "Redeemed from",
    ['created'] = "Created",
    ['actions'] = "Actions",
    ['delete'] = "Delete",
    ['close'] = "Close",
    ['currency'] = "$",
    ['redeem_code'] = "Redeem Code",
    ['history'] = "History",
    ['type_code'] = "Type Code",
    ['redeem'] = "Redeem",
    ['code_error'] = "Invalid Code",
    ['view_info'] = "View Info",
    ['not_staff'] = "You are not staff!",
    ['reward_created'] = "You have created %s rewards",
    ['reward_redeemed'] = "You have redeemed %s rewards",
    ['redeemed_successfully'] = "Redeemed Successfully",
    ['hi'] = "Hi"
}



-- Functions --
AssignVehicle = function(FrameworkFound, identifier, data, citizenid, vehicleLabel)
    -- citizenid IS ONLY FOR QBCORE!
    if FrameworkFound == 'esx' then 
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking) VALUES (@owner, @plate, @vehicle, @stored, @parking)', {
            ['@owner'] = identifier,
            ['@plate'] = data.plate,
            ['@vehicle'] = json.encode(data),
            ['@stored'] = 1,
            ['@parking'] = "SanAndreasAvenue"
        })
    elseif FrameworkFound == 'qbcore' then
        MySQL.Async.execute('INSERT INTO player_vehicles (license,citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)', {
            ['@license'] = identifier,
            ['@citizenid'] = citizenid,
            ['@vehicle'] = vehicleLabel,
            ['@hash'] = data.model,
            ['@mods'] = json.encode(data),
            ['@plate'] = data.plate,
            ['@garage'] = 'pillboxgarage',
            ['@state'] = 1,
        })
    end
end