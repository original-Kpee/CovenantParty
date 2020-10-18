--> Last Updated 10.08.2020
-->>  by kPee

local CovenantPartyGlobal, CovenantParty = ...

CovenantParty.version = CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR
CovenantParty.passVersionCheck = false
CovenantParty.needsAddonUpdate = false
CovenantParty.addonEnabled = true

CovenantParty.M = {}

CovenantParty.M.messageAddonPrefix = {
    [CovenantParty.MESSAGE_PREFIX] = true 
}

CovenantParty.M.parsedData = {}

CovenantParty.L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty", true)

--> Shared Variable default
    CovenantParty.defaults = {
        char = {
            firstUse = true,
            covenantData = {
                covenantID = 0,
                textureKit = "None",
                celebrationSoundKit = 0,
                animaChannelSelectSoundKit = 0,
                animaChannelActiveSoundKit = 0,
                animaGemsFullSoundKit = 0,
                animaNewGemSoundKit = 0,
                animaReinforceSelectSoundKit = 0,
                name = "None",
                last_betrayal = "None",
                total_betrayals = 0,
            }
        },
        profile = 
        {
            minimap = {
                hide = false
            },
            autoReload = false,
        },
        global = 
        {
            region = GetLocale()
        },
    }

--> Minimap Icon with LibDBIcon 1.0 
-->>  and Library Data Broker Support with LibDataBroker 1.1
local __icon = LibStub("LibDBIcon-1.0")
local __LDB = LibStub("LibDataBroker-1.1"):NewDataObject("CovenantParty", {
    type = "launcher",
    text = "Covenant Party",
    icon = "Interface\\AddOns\\CovenantParty\\images\\covenantparty",
    OnClick = function(self, button)
        if button == "LeftButton" then
            --> Enable Addon (if not already enabled)
            if not CovenantParty.addonEnabled then
                LoadAddOn("CovenantParty")
            end
        elseif button == "RightButton" then
            --> Disable Adddon (if not already disabled)
            if  CovenantParty.addonEnabled then
                DisableAddOn("CovenantParty")
            end
        end
        CovenantParty.addonEnabled = not CovenantParty.addonEnabled
        ReloadUI()
    end,
    OnTooltipShow = function(_)
        _:AddLine("Covenant Party", 1, 1, 1)
        _:AddLine(CovenantParty.L.Version  ..": "..CovenantParty.version, 0,2,1,1)
        _:AddLine(" ")
        _:AddLine(CovenantParty.L.MinimapTooltip["lineOne"])
        _:AddLine(CovenantParty.L.MinimapTooltip["lineTwo"])
        _:AddLine(CovenantParty.L.MinimapTooltip["lineThree"])
        _:AddLine(CovenantParty.L.MinimapTooltip["lineFour"])
        _:AddLine(CovenantParty.L.MinimapTooltip["lineFive"])
    end
})

--> Version
    do
        --> Get WoW current version
        local version, build, build_date, toc_version = GetBuildInfo()

        --> Only supports WoW Expansion 9.0 and above (Shadowlands)
        local expansion, majorPatch, minorPatch = (version or "9.0.0"):match("^(%d+)%.(%d+)%.(%d+)")

        --> Check version for support
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

    --> Callback for OnProfileChanged, OnProfileCopied
    -->>  and OnProfileReset.
    function CovenantParty:RefreshConfiguration()
        --> Check if player setting is to hide minimap or if addon is enables
        if CovenantPartyDB.profile.minimap.hide then
            __icon.Hide()
        else
            if CovenantPartyDB.char[covenantId] ~= 0 then
                __LDB.icon = 'Interface\\AddOns\\CovenantParty\\images\\covenantparty'
            else
                __LDB.icon = 'Interface\\AddOns\\CovenantParty\\images\\covenantparty'                            
            end          
            __icon.Show()  
        end
        
        if CovenantPartyDB.autoReload then
            ReloadUI()
        end
    end

--> Slash Command(s)
    SlashCmdList["CovenantPartySlash"] = function(arg)        
        if arg == "hide" then
            CovenantPartyDB.profile.minimap.hide = true
        
            __icon.Hide()

            if CovenantParty.autoReload then
                ReloadUI()
            else
                CovenantParty.U.Print(
                    {color = CovenantParty.COLORS["PINK"], text = "Covenant Party"},
                    {color = CovenantParty.COLORS["BLACK"], text = ": "},
                    {color = CovenantParty.COLORS["BLACK"], text = "The AddOn minimap button will be "},
                    {color = CovenantParty.COLORS["LIGHT_BLUE"], text = "hidden "},
                    {color = CovenantParty.COLORS["BLACK"], text = "on the next UI reload. "}
                )
            end
            
        elseif arg == "show" then            
            CovenantPartyDB.profile.minimap.hide = false
        
            __icon.Show()

            if CovenantParty.autoReload then
                ReloadUI()
            else
                CovenantParty.U.Print(
                    {color = CovenantParty.COLORS["PINK"], text = "Covenant Party"},
                    {color = CovenantParty.COLORS["BLACK"], text = ": "},
                    {color = CovenantParty.COLORS["BLACK"], text = "The AddOn minimap button will be "},
                    {color = CovenantParty.COLORS["LIGHT_BLUE"], text = "show "},
                    {color = CovenantParty.COLORS["BLACK"], text = "on the next UI reload. "}
                )
            end
        elseif arg == "version" or arg == "ver" then
            if CovenantParty.passVersionCheck then
                CovenantParty.U.Print(
                    {color = CovenantParty.COLORS["PINK"], text = "Covenant Party"},
                    {color = CovenantParty.COLORS["WHITE"], text = ": "},
                    {color = CovenantParty.COLORS["BLACK"], text = "The AddOn is "},
                    {color = CovenantParty.COLORS["LIGHT_BLUE"], text = "up-to-date"},
                    {color = CovenantParty.COLORS["WHITE"], text = ". "},
                    {color = CovenantParty.COLORS["WHITE"], text = "Version: "},
                    {color = CovenantParty.COLORS["BLUE"], text = CovenantParty.version}
                )
            end
        
        elseif arg == "auto reload" then
                CovenantParty.autoReload  = not CovenantParty.autoReload
            
            if CovenantParty.autoReload == true then
                CovenantParty.U.Print(
                    {color = CovenantParty.COLORS["PINK"], text = "Covenant Party"},
                    {color = CovenantParty.COLORS["WHITE"], text = ": "},
                    {color = CovenantParty.COLORS["WHITE"], text = "UI will be automatically "},
                    {color = CovenantParty.COLORS["LIGHT_BLUE"], text = "reloaded "},
                    {color = CovenantParty.COLORS["WHITE"], text = "after requested changes."}
                )
            else
                CovenantParty.U.Print(
                    {color = CovenantParty.COLORS["PINK"], text = "Covenant Party"},
                    {color = CovenantParty.COLORS["WHITE"], text = ": "},
                    {color = CovenantParty.COLORS["WHITE"], text = "UI will "},
                    {color = CovenantParty.COLORS["RED"], text = "not "},
                    {color = CovenantParty.COLORS["WHITE"], text = "be automatically "},
                    {color = CovenantParty.COLORS["LIGHT_BLUE"], text = "reloaded "},
                    {color = CovenantParty.COLORS["WHITE"], text = "after requested changes."}
                )
            end
        elseif arg == "msgtest" then
            C_ChatInfo.SendAddonMessage("SL_COPA", "Broadcast version", "PARTY")
        end
    end

    --> Assign handlers for supported slash commands
    SLASH_CovenantPartySlash1 = "/CovenantParty"
    SLASH_CovenantPartySlash2 = "/CoPa"
    SLASH_CovenantPartySlash3 = "/Copa"


--> Global Frame
    CovenantParty.frame = CreateFrame("Frame")

    CovenantParty.frame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" and CovenantParty.addonEnabled == true then
            local addonName = ...
            if addonName ~= CovenantPartyGlobal then
                return
            end
            
            CovenantPartyDB = CovenantPartyDB or {}
                        
            --> Ensure that SharedVariables contain all the
            -->>  expected data defined in the 'default' var.
            for key, value in pairs(CovenantParty.defaults) do                
                if CovenantPartyDB[key] == nil then
                    CovenantPartyDB[key] = value
                elseif type(value) == "table" then
                    
                end
            end

            --> Check default values against SharedVariable to ensure
            -->>  all default values exist within the SharedVariable
            for key, value in pairs(CovenantParty.defaults) do
                if CovenantPartyDB[key] == nil then                
                    CovenantPartyDB[key] = value
                else
                    --> Key already exists in new table
                    -->>  Must now check to see if this value
                    -->>  is a table or not. If table then
                    -->> look at all of its key to ensure that
                    -->> they exist.
                    if type(value) == "table" then
                        for inner_key, inner_value in pairs(value) do                        
                            if CovenantPartyDB[key][inner_key] == nil then
                                CovenantPartyDB[key][inner_key] = inner_value
                            else
                                --> Last nested table check
                                -->>  This only supporst up to three nested tables
                                if type(inner_value) == "table" then
                                    for deeper_key, deeper_value in pairs(inner_value) do
                                        if CovenantPartyDB[key][inner_key][deeper_key] == nil then
                                            CovenantPartyDB[key][inner_key][deeper_key] = deeper_value
                                        end
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end

            --> Now let's check that the current saved SharedVariable
            -->>  does not contain any stale data that is no longer
            -->>  defined within our 'defaults' var
            for key, value in pairs(CovenantPartyDB) do
                if CovenantParty.defaults[key] == nil then                
                    CovenantPartyDB[key] = nil
                else
                    --> Key already exists in new table
                    -->>  Must now check to see if this value
                    -->>  is a table or not. If table then
                    -->>  look at all of its key to ensure that
                    -->>  they exist.
                    if type(value) == "table" then
                        for inner_key, inner_value in pairs(value) do                        
                            if CovenantParty.defaults[key][inner_key] == nil then
                                CovenantPartyDB[key][inner_key] = nil
                            else
                                --> Last nested table check
                                -->  This only supporst up to three nested tables
                                if type(inner_value) == "table" then
                                    for deeper_key, deeper_value in pairs(inner_value) do
                                        if CovenantParty.defaults[key][inner_key][deeper_key] == nil then
                                            CovenantPartyDB[key][inner_key][deeper_key] = nil
                                        end
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end
              

            CovenantParty.autoRelaod = CovenantPartyDB.profile.autoReload

            --> Initialize auto reload from profile
            CovenantParty.autoReload =  CovenantPartyDB.profile.autoReload
            
            if not CovenantParty.U.UTILITY_FILE_LOADED then
                print(
                    CovenantParty.COLORS["PINK"].."Covenant Party"..":"..
                    CovenantParty.COLORS["LIGHT_RED"].." Utility(s) were not loaded. We are gonna party at a "..
                    CovenantParty.COLORS["RED"].."reduced capacity"..
                    CovenantParty.COLORS["LIGHT_RED"]..".")
            end

            --> Register all C_ChatInfo Addon Messages prefix(es)
            for _prefix, _ in pairs(CovenantParty.M.messageAddonPrefix) do
                C_ChatInfo.RegisterAddonMessagePrefix(_prefix)
            end
        
            --> Register the Minimap Icon
            __icon:Register("CovenantParty", __LDB, CovenantPartyDB.profile.minimap)
            

            --> Unregister the ADDON_LOADED event
            self:UnregisterEvent("ADDON_LOADED")

            --> Addon as been enabled
            CovenantParty.addonEnabled = true

            CovenantParty:RefreshConfiguration()

            return true
        elseif event == "PLAYER_LOGOUT" then
            CovenantPartyDB.profile.autoReload = CovenantParty.autoReload

            return true
        end
    end
    )

--> Register all events for Initial frame
CovenantParty.frame:RegisterEvent("ADDON_LOADED")
CovenantParty.frame:RegisterEvent("PLAYER_LOGOUT")

--> Set global object
_G["CovenantParty"] = CovenantParty
