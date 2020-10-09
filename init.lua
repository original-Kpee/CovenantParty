-- CovenantParty = LibStub("AceAddon-3.0"):NewAddon("CovenantParty", "AceConsole-3.0","AceComm-3.0", "AceEvent-3.0", "AceSerializer-3.0")
-- CovenantParty = _G.CovenantParty

--     -- Initialization Function called by AceAddon 3.0
--     function CovenantParty:OnInitialize()
--         -- Register all Events we care about
--         self:RegisterEvent("COVENANT_CHOSEN")
--         self:RegisterEvent("GROUP_ROSTER_UPDATE")

--         CovenantParty:Print("Covenant Party has been Initialized. We are ready to party!")
--     end



-- Last Updated 10.08.2020
--  by kPee

local GlobalAddonName, CovenantParty = ...

CovenantParty.version = CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR
CovenantParty.passVersionCheck = false
CovenantParty.needsAddonUpdate = false
CovenantParty.addonEnabled = true

CovenantParty.messageTypes = {
    version = "__V",
    versionRequest = "__VR",
    shareCovenant = "__SC"
}

CovenantParty.L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty", true)

--> Shared Variable default
    local defaults = {
        char = {
            firstUse = true,
            covenantID = nil,
            covenantData = {
                textureKit = nil,
                celebrationSoundKit = nil,
                animaChannelSelectSoundKit = nil,
                animaChannelActiveSoundKit = nil,
                animaGemsFullSoundKit = nil,
                animaNewGemSoundKit = nil,
                animaReinforceSelectSoundKit = nil,
                name = nil,                    
                last_betrayal = nil,
                total_betrayals = 0,
            }
        },
        profile = 
        {
            minimap = 
            {
                hide = false
            }
        },
        global = 
        {
            region = GetLocale()
        }
    }

-- Minimap Icon with LibDBIcon 1.0 
--  and Library Data Broker Support with LibDataBroker 1.1
local __icon = LibStub("LibDBIcon-1.0")
local __LDB = LibStub("LibDataBroker-1.1"):NewDataObject("CovenantParty", {
    type = "launcher",
    text = "Covenant Party",
    icon = "Interface\\AddOns\\CovenantParty\\images\\covenantparty",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Enable Addon (if not already enabled)
            if not CovenantParty.addonEnabled then
                LoadAddOn("CovenantParty")
            end
        elseif button == "RightButton" then
            -- Disable Adddon (if not already disabled)
            if  CovenantParty.addonEnabled then
                DisableAddOn("CovenantParty")                    
            end
        end
        CovenantParty.addonEnabled = not CovenantParty.addonEnabled
        ReloadUI()
    end,
    OnTooltipShow = function(_)
        _:AddLine("Covenant Party", 1, 1, 1)
        _:AddLine("version: "..CovenantParty.version, 0,2,1,1)
        _:AddLine(" ")
        _:AddLine(CovenantParty.L.MinimapTooltip)
    end
})

--> Version
    do
        -- Get WoW current version
        local version, build, build_date, toc_version = GetBuildInfo()

        -- Only supports WoW Expansion 9.0 and above (Shadowlands)
        local expansion, majorPatch, minorPatch = (version or "9.0.0"):match("^(%d+)%.(%d+)%.(%d+)")

        -- Check version for support
        if expansion ~= "9" then
            CovenantParty.passVersionCheck = false
        else
            local standarized_version = math.floor((expansion * 10000) + (majorPatch * 100) + (minorPatch))
            if standarized_version == toc_version then
                CovenantParty.needsAddonUpdate = false
            else
                CovenantParty.needsAddonUpdate = true
            end
            CovenantParty.passVersionCheck = true
        end
    end

    -- Callback for OnProfileChanged, OnProfileCopied
    --  and OnProfileReset.
    function CovenantParty:RefreshConfiguration()

        -- Check if player setting is to hide minimap or if addon is enables
        if CovenantPartyDB.profile.minimap.hide then
            __icon.Hide("CovenantParty")
            print("Icon Hidden")
        else
            if CovenantPartyDB.char[covenantId] ~= 0 then
                __LDB.icon = 'Interface\\AddOns\\CovenantParty\\images\\covenantparty'
                print(__LDB.icon)
            else
                __LDB.icon = 'Interface\\AddOns\\CovenantParty\\images\\covenantparty'            
                print("Icon")
            end            
        end        
    end

--> Global Frame
CovenantParty.frame = CreateFrame("Frame")

CovenantParty.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and CovenantParty.addonEnabled == true then
        local addonName = ...
        if addonName ~= GlobalAddonName then
            return
        end
        CovenantPartyDB = CovenantPartyDB or {}

        for key, value in pairs(defaults) do
            if CovenantPartyDB[key] == nil then
                CovenantPartyDB[key] = value
            end
        end

        -- Register the Minimap Icon
        __icon:Register("CovenantParty", __LDB, CovenantPartyDB.profile.minimap.hide)
        
        CovenantParty.addonEnabled = true

        CovenantParty:RefreshConfiguration()

        return true
    end
end
)

-- Set global object
_G["CovenantParty"] = CovenantParty
CovenantParty.frame:RegisterEvent("ADDON_LOADED")