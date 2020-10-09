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

local CovenantParty_name, CovenantParty = ...

CovenantParty.version = CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR
CovenantParty.passVersionCheck = false
CovenantParty.needsAddonUpdate = false
CovenantParty.events = {}
CovenantParty.minimapIcon = {}

CovenantParty.messageTypes = {
    version = "__V",
    versionRequest = "__VR",
    shareCovenant = "__SC"
}

CovenantParty.L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty", true)

-- Minimap Icon with LibDBIcon 1.0 
--  and Library Data Broker Support with LibDataBroker 1.1
local __icon = LibStub("LibDBIcon-1.0")
local __LDB = LibStub("LibDataBroker-1.1")



--> Version
    do
        -- Get WoW current version
        local version, build, build_date, toc_version = GetBuildInfo()

        -- Only supports WoW Expansion 9.0 and above (Shadowlands)
        local expansion, majorPatch, minorPatch = (version or "9.0.0"):match("^(%d+)%.(%d+)%.(%d+)")

        -- Check version for support
        if expansion ~= 9 then
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

--> Shared Variable
    do
        local defaults = 
        {
            character = 
            {
                firstUse = true,
                covenantID = ...,
                covenantData = 
                {
                    textureKit = ...,
                    celebrationSoundKit = ...,
                    animaChannelSelectSoundKit = ...,
                    animaChannelActiveSoundKit = ...,
                    animaGemsFullSoundKit = ...,
                    animaNewGemSoundKit = ...,
                    animaReinforceSelectSoundKit = ...,
                    name = ...,                    
                    last_betrayal = ...,
                    total_betrayals = 0,
                }
            },
            profile = 
            {
                minimap = 
                {
                    hide = true
                }
            },
            global = 
            {
                region = ...
            }
        }

        -- Using AceDB-3.0 for SharedVariable management (create and set defaults)
        CovenantParty.DB = LibSub("AceDB-3.0"):New("CovenantPartyDB", defaults)

        -- Register callback for when user changes profiles
        CovenantParty.DB.RegisterCallback(CovenantParty, "OnProfileChanged", "RefreshConfiguration")
        CovenantParty.DB.RegisterCallback(CovenantParty, "OnProfileCopied", "RefreshConfiguration")
        CovenantParty.DB.RegisterCallback(CovenantParty, "OnProfileReset", "RefreshConfiguration")
    end


--> Configuration

    -- Create new Data Broker Object
    __LDB:NewDataObject("CovenantParty", {
        type = "launcher",
        text = "Covenant Party",
        icon =  "Interface\\Addon\\CovenantParty\\images\\covenantparty",
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- Enable Addon (if not already enabled)
                if not isEnabled() then
                    EnableAddon("CovenantParty")
                end
            elseif button == "RightButton" then
                -- Disable Adddon (if not already disabled)
                if  isEnabled() then
                    DisableAddon("CovenantParty")                    
                end
            end
            ReloadUI()
        end,
        OnTooltipShow = function(_)
            _:AddLine("Covenant Party "..CovenantParty.version, 1, 1, 1)
            _:AddLine(" ")
            _:AddLine(CovenantParty.L.MinimapTooltip)
        end
    })

    -- Callback for OnProfileChanged, OnProfileCopied
    --  and OnProfileReset.
    function CovenantParty:RefreshConfiguration()

        -- Check if player setting is to hide minimap or if addon is enables
        if not IsEnabled() or self.DB.profile.minimap.hide then
            __icon.Hide("CovenantParty")
        else
            if CovenantParty.DB.character[covenantId] ~= 0 then
                __LDB.icon = 'Interface\\Addon\\CovenantParty\\images\\covenantparty_bw'
            else
                __LDB.icon = 'Interface\\Addon\\CovenantParty\\images\\covenantparty'
            end            
        end        
    end

-- Set global object
_G[CovenantParty] = CovenantParty