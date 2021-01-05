ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('luke_chopshop:Payment')
AddEventHandler('luke_chopshop:Payment', function(vehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    DamageDone = (1000 - vehicle) * Config.MoneyLostPerHitPoint
    AmountToPay = math.floor(Config.Payment - DamageDone)

    if xPlayer ~= nil then

        if Config.PaymentInBlackMoney == true then
            xPlayer.addAccountMoney('black_money', AmountToPay)
            if AmountToPay <= 0 then
                TriggerClientEvent('esx:showAdvancedNotification', src, 'Stranger', '', 'You totaled the car, you get ~r~no ~w~money! You can talk to me again soon.', 'CHAR_MULTIPLAYER', 9)
            else
                TriggerClientEvent('esx:showAdvancedNotification', src, 'Stranger', '', 'You recieved ~r~$'..AmountToPay..'! ~w~You can talk to me again soon.', 'CHAR_MULTIPLAYER', 9)
            end
        else
            xPlayer.addMoney(AmountToPay)
            if AmountToPay <= 0 then
                TriggerClientEvent('esx:showAdvancedNotification', src, 'Stranger', '', 'You totaled the car, you get ~r~no ~w~money! You can talk to me again soon.', 'CHAR_MULTIPLAYER', 9)
            else
               TriggerClientEvent('esx:showAdvancedNotification', src, 'Stranger', '', 'You recieved ~r~$'..AmountToPay..'! ~w~You can talk to me again soon.', 'CHAR_MULTIPLAYER', 9)
           end 
        end
    end

end)