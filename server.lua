function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }
    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end

function RefreshScoreboard()
    local xPlayers = ESX.GetExtendedPlayers()
    TriggerClientEvent("gs-scoreboard:refrehScoreboard", -1)
    for _, xPlayer in pairs(xPlayers) do
        local playerID = xPlayer.source
        local playerName = Sanitize(xPlayer.getName())
        local playerJob = xPlayer.job.label
        local playerGroup = xPlayer.getGroup()
        TriggerClientEvent("gs-scoreboard:addUserToScoreboard", -1, playerID, playerName, playerJob, playerGroup)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        RefreshScoreboard()
    end
end)

RegisterCommand("refreshscoreboard", function()
    RefreshScoreboard()
end, true)

RegisterServerEvent("gs-scoreboard:updateValues")
AddEventHandler(
    "gs-scoreboard:updateValues",
    function()
        local onlinePlayers = getOnlinePlayers()
        local onlineStaff = getOnlineStaff()
        local onlinePolice = getOnlinePolice()
        local onlineEMS = getOnlineEMS()
        local onlineTaxi = getOnlineTaxi()
        local onlineMechanics = getOnlineMechanics()
        TriggerClientEvent("gs-scoreboard:setValues", -1, onlinePlayers, onlineStaff, onlinePolice, onlineEMS, onlineTaxi, onlineMechanics)
    end
)

RegisterNetEvent('gs-scoreboard:requestUserData')
AddEventHandler(
    'gs-scoreboard:requestUserData',  
    function(target)
        TriggerClientEvent("gs-scoreboard:retrieveUserData", tonumber(target), source, tonumber(target))
    end
)

RegisterNetEvent('gs-scoreboard:sendRequestedData')
AddEventHandler(
    'gs-scoreboard:sendRequestedData',  
    function(to, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        data.roleplayName = xPlayer.getName()
        TriggerClientEvent("gs-scoreboard:receiveRequestedData", to, source, data)
    end
)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler(
    'esx:playerLoaded',  
    function()
        RefreshScoreboard()
    end
)

AddEventHandler('esx:playerDropped', 
    function()
        RefreshScoreboard()
    end
)

function getOnlinePlayers()
    local xPlayers = ESX.GetExtendedPlayers()
    return #xPlayers
end

function getOnlineStaff()
    local xPlayersTotal = ESX.GetExtendedPlayers()
    local xPlayersUsers = ESX.GetExtendedPlayers('group','user')
    return (#xPlayersTotal - #xPlayersUsers)
end

function getOnlinePolice()
    local xPlayers = ESX.GetExtendedPlayers('group','police')
    return #xPlayers
end

function getOnlineEMS()
    local xPlayers = ESX.GetExtendedPlayers('group','ems')
    return #xPlayers
end

function getOnlineTaxi()
    local xPlayers = ESX.GetExtendedPlayers('group','taxi')
    return #xPlayers
end

function getOnlineMechanics()
    local xPlayers = ESX.GetExtendedPlayers('group','mechanic')
    return #xPlayers
end