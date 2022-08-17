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
        TriggerClientEvent("gs-scoreboard:sendConfigToNUI", -1)
        getIllegalActivitesData()
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        RefreshScoreboard()
    end
    TriggerClientEvent("gs-scoreboard:sendConfigToNUI", -1)
end)

RegisterCommand("refreshscoreboard", function()
    RefreshScoreboard()
end, false)

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
        TriggerClientEvent("gs-scoreboard:setValues", -1, onlinePlayers, onlineStaff, onlinePolice, onlineEMS, onlineTaxi, onlineMechanics, illegalActivites)
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
        if xPlayer ~= nil then
            data.roleplayName = xPlayer.getName()
            TriggerClientEvent("gs-scoreboard:receiveRequestedData", to, source, data)
        end
    end
)

AddEventHandler(
    'esx:playerLoaded',  
    function()
        RefreshScoreboard()
    end
)

AddEventHandler(
    'playerDropped', 
    function()
        RefreshScoreboard()
    end
)

AddEventHandler('playerDropped', function (reason)
    Citizen.Wait(500)
    RefreshScoreboard()
end)
  

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

function getIllegalActivitesData()
    local data = Config.illegalActivites
    for i = 1,#data do
        data[i]["onlinePlayers"] = getOnlinePlayers()
        data[i]["onlineGroup"] = #ESX.GetExtendedPlayers('group',data[i]["group_name"])
        TriggerClientEvent("gs-scoreboard:sendIllegalActivity",-1,data[i])
    end
    return data
end