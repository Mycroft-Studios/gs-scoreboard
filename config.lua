Config = {}

Config.screenBlur = true
Config.screenBlurAnimationDuration = 500
Config.showKeyBinds = true
Config.showPlayerInfo = true
Config.showPlayerPed = true
Config.showIllegalActivites = true

Config.keyBinds = {
    {
        key = "F1",
        description = "Open Inventory"
    },
    {
        key = "F3",
        description = "Open Animation Menu"
    },
    {
        key = "T",
        description = "Open Chat"
    },
    {
        key = "Y",
        description = "Clothing Whell"
    },
    {
        key = "X",
        description = "Raise Hands"
    }
}

Config.illegalActivites = {
    {
        id = "robseveneleven",
        title = "Rob 7/11 Stores",
        description = "You can rob 7/11 Stores only if there are a minimum of 10 players online and 2 Police Officers on duty!",
        group_name = "police",
        minimum_player_online = 10,
        minimum_group_online = 2,
    },
    {
        id = "robsmallbanks",
        title = "Rob Small Banks",
        description = "You can rob Small Banks only if there are a minimum of 30 players online and 4 Police Officers on duty!",
        group_name = "police",
        minimum_player_online = 30,
        minimum_group_online = 4,
    },
    {
        id = "robbigbanks",
        title = "Rob Big Bank",
        description = "You can rob Big Bank only if there are a minimum of 60 players online and 10 Police Officers on duty!",
        group_name = "police",
        minimum_player_online = 60,
        minimum_group_online = 10,
    },
}