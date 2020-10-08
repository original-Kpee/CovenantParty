CovenantParty = LibStub("AceAddon-3.0"):NewAddon("CovenantParty", "AceConsole-3.0","AceComm-3.0", "AceEvent-3.0", "AceSerializer-3.0")
CovenantParty = _G.CovenantParty

    -- Initialization Function called by AceAddon 3.0
    function CovenantParty:OnInitialize()
        -- Register all Events we care about
        self:RegisterEvent("COVENANT_CHOSEN")
        self:RegisterEvent("GROUP_ROSTER_UPDATE")

        CovenantParty:Print("Covenant Party has been Initialized. We are ready to party!")
    end