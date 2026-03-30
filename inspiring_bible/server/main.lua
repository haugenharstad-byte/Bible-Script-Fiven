local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil

if QBCore and Config.EnableQBCoreUsableItem then
    QBCore.Functions.CreateUseableItem(Config.ItemName, function(source)
        TriggerClientEvent('inspiring_bible:client:open', source, {
            reason = 'qbcore_usable_item'
        })
    end)
end
