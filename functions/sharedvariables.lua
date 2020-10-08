local CovenantParty = _G.CovenantParty
local _L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty")

--> Global Default
local global_default = {
    account_profiles = {},
    covenant_icon_setting = {
        position = {
            x = 0,
            y = 0
        },
        size = 10,
        rotation = 0,
        discolored = false,
        opacity = 100
    },
}

--> Character Default
local player_default = {
    last_login = date("%d"),
    last_version = CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR,
    covenant_data = {
        ID = nil,
        textureKit = nil,
        celebrationSoundKit = nil,
        animaChannelSelectSoundKit = nil,
        animaChannelActiveSoundKit = nil,
        animaGemsFullSoundKit = nil,
        animaNewGemSoundKit = nil,
        animaReinforceSelectSoundKit = nil,
        name = nil,
        soulbindIDs = {},
        last_betrayal = nil,
        total_betrayals = 0,
    },
}

--> Assign local defaults to Object variables
CovenantParty.default_player_data = player_default
CovenantParty.default_global_data = global_default