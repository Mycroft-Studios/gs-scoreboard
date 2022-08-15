
local isScoreboardOpen = false
local requestedData

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(2500)
        TriggerServerEvent("gs-scoreboard:updateValues")
    end
end)

local PlayerPedPreview
function createPedScreen(playerID)
    CreateThread(function()
        ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_JOINING_SCREEN"), true, -1)
        Citizen.Wait(100)
        N_0x98215325a695e78a(false)
        PlayerPedPreview = ClonePed(playerID, GetEntityHeading(playerID), true, false)
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedPreview))
        SetEntityCoords(PlayerPedPreview, x,y,z-10)
        FreezeEntityPosition(PlayerPedPreview, true)
        SetEntityVisible(PlayerPedPreview, false, false)
        NetworkSetEntityInvisibleToNetwork(PlayerPedPreview, false)
        Wait(200)
        SetPedAsNoLongerNeeded(PlayerPedPreview)
        GivePedToPauseMenu(PlayerPedPreview, 2)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(true)
        TriggerServerEvent('gs-scoreboard:requestUserData', tonumber(GetPlayerServerId(PlayerId())))
    end)
end

RegisterCommand('showscoreboard', function()
    if not isScoreboardOpen then
        SetFrontendActive(true)
        createPedScreen(PlayerPedId())
        SendNUIMessage({
            action = "show"
        })
        SetNuiFocus(true,true)
        TriggerScreenblurFadeIn(500)
        isScoreboardOpen = true
    end
end, false)

RegisterCommand('closescoreboard', function()
    if isScoreboardOpen then
        DeleteEntity(PlayerPedPreview)
        SetFrontendActive(false)
        SendNUIMessage({
            action = "hide"
        })
        SetNuiFocus(false,false)
        isScoreboardOpen = false
        TriggerScreenblurFadeOut(500)
    end
end, false)

RegisterKeyMapping('showscoreboard', 'Show/Hide Scoreboard', 'keyboard', 'GRAVE')

RegisterNUICallback('closeScoreboard', function()
    ExecuteCommand('closescoreboard')
end)

RegisterNetEvent("gs-scoreboard:addUserToScoreboard")
AddEventHandler(
    "gs-scoreboard:addUserToScoreboard",
    function(playerID, playerName, playerJob, playerGroup)
        SendNUIMessage(
            {
                action="addUserToScoreboard",
                playerID = playerID,
                playerName = playerName,
                playerJob = playerJob,
                playerGroup = playerGroup,
            }
        )
    end
)

RegisterNetEvent("gs-scoreboard:setValues")
AddEventHandler(
    "gs-scoreboard:setValues",
    function(onlinePlayers, onlineStaff, onlinePolice, onlineEMS, onlineTaxi, onlineMechanics)
        SendNUIMessage(
            {
                action="updateScoreboard",
                onlinePlayers = onlinePlayers,
                onlineStaff = onlineStaff,
                onlinePolice = onlinePolice,
                onlineEMS = onlineEMS,
                onlineTaxi = onlineTaxi,
                onlineMechanics = onlineMechanics,
            }
        )
    end
)

RegisterNetEvent("gs-scoreboard:refrehScoreboard")
AddEventHandler(
    "gs-scoreboard:refrehScoreboard",
    function()
        SendNUIMessage(
            {
                action="refreshScoreboard",
            }
        )
    end
)

RegisterNUICallback('showPlayerPed', function(data)
    local playerID = data.playerID
    DeleteEntity(PlayerPedPreview)
    Citizen.Wait(100)
    local playerTargetID = GetPlayerPed(GetPlayerFromServerId(playerID))
    PlayerPedPreview = ClonePed(playerTargetID, GetEntityHeading(playerTargetID), true, false)
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedPreview))
    SetEntityCoords(PlayerPedPreview, x,y,z-10)
    FreezeEntityPosition(PlayerPedPreview, true)
    SetEntityVisible(PlayerPedPreview, false, false)
    NetworkSetEntityInvisibleToNetwork(PlayerPedPreview, false)
    Wait(200)
    SetPedAsNoLongerNeeded(PlayerPedPreview)
    GivePedToPauseMenu(PlayerPedPreview, 2)
    SetPauseMenuPedLighting(true)
    SetPauseMenuPedSleepState(true)
    TriggerServerEvent('gs-scoreboard:requestUserData', tonumber(data.playerID))
end)

RegisterNetEvent("gs-scoreboard:receiveRequestedData")
AddEventHandler(
    "gs-scoreboard:receiveRequestedData",
    function(from, data)
        requestedData = data
        SendNUIMessage(
        {
            action="playerInfoUpdate",
            playerName = requestedData.playerName,
            playerID = requestedData.playerID,
            timePlayed = requestedData.timePlayed,
            roleplayName = requestedData.roleplayName,
        }
    )
    end
)

RegisterNetEvent("gs-scoreboard:retrieveUserData")
AddEventHandler(
    "gs-scoreboard:retrieveUserData",
    function(from, to)
        local data = {}
        data.playerName = GetPlayerName(PlayerId())
        data.playerID = to
        local retVal, timePlayed = StatGetInt('mp0_total_playing_time')
        data.timePlayed = timePlayed
        TriggerServerEvent('gs-scoreboard:sendRequestedData', from, data)
    end
)
