local RESOURCE_NAME = GetCurrentResourceName()
local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil

local uiOpen = false
local oxTargetZoneNames = {}
local activeBookProp

local function requestAnimDict(dict)
    if not dict or dict == '' then
        return false
    end

    RequestAnimDict(dict)

    for _ = 1, 100 do
        if HasAnimDictLoaded(dict) then
            return true
        end

        Wait(50)
    end

    return false
end

local function requestModel(model)
    if not model or model == '' then
        return false
    end

    local modelHash = type(model) == 'number' and model or joaat(model)

    if not IsModelInCdimage(modelHash) then
        return false
    end

    RequestModel(modelHash)

    for _ = 1, 100 do
        if HasModelLoaded(modelHash) then
            return modelHash
        end

        Wait(50)
    end

    return false
end

math.randomseed(GetGameTimer())

local function toVector3(value, fallback)
    if type(value) == 'vector3' then
        return value
    end

    if type(value) == 'table' then
        local x = value.x or value[1]
        local y = value.y or value[2]
        local z = value.z or value[3]

        if x and y and z then
            return vec3(x, y, z)
        end
    end

    return fallback
end

local function notify(message, notifyType)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(message, notifyType or 'primary')
    end
end

local function stopReadingAnimation()
    local ped = PlayerPedId()
    local animation = Config.Animation or {}

    if animation.dict and animation.clip and IsEntityPlayingAnim(ped, animation.dict, animation.clip, 3) then
        StopAnimTask(ped, animation.dict, animation.clip, 1.0)
    end

    ClearPedSecondaryTask(ped)

    if activeBookProp and DoesEntityExist(activeBookProp) then
        DetachEntity(activeBookProp, true, true)
        DeleteEntity(activeBookProp)
    end

    activeBookProp = nil
end

local function startReadingAnimation()
    local ped = PlayerPedId()
    local animation = Config.Animation or {}

    if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then
        return
    end

    if animation.dict and animation.clip and requestAnimDict(animation.dict) then
        TaskPlayAnim(
            ped,
            animation.dict,
            animation.clip,
            3.0,
            3.0,
            -1,
            animation.flag or 49,
            0.0,
            false,
            false,
            false
        )
    end

    if activeBookProp and DoesEntityExist(activeBookProp) then
        DeleteEntity(activeBookProp)
        activeBookProp = nil
    end

    local modelHash = requestModel(animation.prop)

    if not modelHash then
        return
    end

    local coords = GetEntityCoords(ped)
    local position = animation.position or vec3(0.13, 0.01, 0.02)
    local rotation = animation.rotation or vec3(10.0, 0.0, -8.0)

    activeBookProp = CreateObject(modelHash, coords.x, coords.y, coords.z + 0.2, true, true, false)

    if DoesEntityExist(activeBookProp) then
        AttachEntityToEntity(
            activeBookProp,
            ped,
            GetPedBoneIndex(ped, animation.bone or 60309),
            position.x,
            position.y,
            position.z,
            rotation.x,
            rotation.y,
            rotation.z,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetModelAsNoLongerNeeded(modelHash)
    end
end

local function openBible(reason, forcedIndex)
    if uiOpen then
        return
    end

    local verseCount = #Config.Verses

    if verseCount == 0 then
        notify('No Bible verses are configured.', 'error')
        return
    end

    uiOpen = true

    startReadingAnimation()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = 'open',
        reason = reason or 'script',
        ui = Config.Ui,
        verses = Config.Verses,
        currentIndex = math.max(1, math.min(forcedIndex or math.random(verseCount), verseCount))
    })
end

local function closeBible()
    if not uiOpen then
        return
    end

    uiOpen = false
    stopReadingAnimation()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

local function registerTargetZones()
    if not Config.EnableOxTarget or GetResourceState('ox_target') ~= 'started' then
        return
    end

    for index, zone in ipairs(Config.TargetZones) do
        local zoneName = zone.name or ('inspiring_bible_zone_' .. index)

        exports.ox_target:addBoxZone({
            coords = toVector3(zone.coords, vec3(0.0, 0.0, 0.0)),
            name = zoneName,
            size = toVector3(zone.size, vec3(1.2, 1.2, 2.0)),
            rotation = zone.rotation or 0.0,
            debug = zone.debug or false,
            drawSprite = zone.drawSprite ~= false,
            options = {
                {
                    name = zoneName .. '_read',
                    icon = zone.icon or 'fa-solid fa-book-bible',
                    label = zone.label or 'Read the Bible',
                    distance = zone.distance or 2.0,
                    onSelect = function()
                        openBible('ox_target_zone')
                    end
                }
            }
        })

        oxTargetZoneNames[#oxTargetZoneNames + 1] = zoneName
    end

    if Config.TargetModels and #Config.TargetModels > 0 then
        exports.ox_target:addModel(Config.TargetModels, {
            {
                name = 'inspiring_bible_model_read',
                icon = 'fa-solid fa-book-bible',
                label = Config.TargetModelLabel or 'Read the Bible',
                distance = Config.TargetModelDistance or 2.0,
                onSelect = function()
                    openBible('ox_target_model')
                end
            }
        })
    end
end

RegisterNetEvent('inspiring_bible:client:open', function(payload)
    payload = payload or {}
    openBible(payload.reason or 'event', payload.index)
end)

RegisterNUICallback('close', function(_, cb)
    closeBible()
    cb(1)
end)

RegisterNUICallback('escapePressed', function(_, cb)
    closeBible()
    cb(1)
end)

exports('openBible', function(reason, index)
    openBible(reason or 'export', index)
end)

exports('bible', function(data)
    if not Config.EnableOxInventoryUse then
        openBible('item_disabled_toggle')
        return
    end

    if GetResourceState('ox_inventory') ~= 'started' then
        openBible('ox_inventory_missing')
        return
    end

    exports.ox_inventory:useItem(data, function(usedData)
        if not usedData then
            return
        end

        openBible('ox_inventory_item')
    end)
end)

if Config.EnableCommand and Config.CommandName then
    RegisterCommand(Config.CommandName, function()
        openBible('command')
    end, false)
end

CreateThread(function()
    Wait(500)
    registerTargetZones()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= RESOURCE_NAME then
        return
    end

    closeBible()

    stopReadingAnimation()

    if GetResourceState('ox_target') ~= 'started' then
        return
    end

    for _, zoneName in ipairs(oxTargetZoneNames) do
        exports.ox_target:removeZone(zoneName)
    end

    if Config.TargetModels and #Config.TargetModels > 0 then
        exports.ox_target:removeModel(Config.TargetModels, 'inspiring_bible_model_read')
    end
end)
