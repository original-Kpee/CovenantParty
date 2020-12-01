local CovenantPartyGlobal, CovenantParty = ...

local L = LibStub("AceLocale-3.0"):NewLocale("CovenantParty", "enUS", true)
if not L then return end

--> Minimap
    L.Version = "version"
    L.MinimapTooltip = {
        lineOne = CovenantParty.STARTLINE .. CovenantParty.COLORS["PINK"] .. "Covenant Party!" .. CovenantParty.ENDLINE,
        lineTwo = CovenantParty.STARTLINE .. CovenantParty.COLORS["GOLD"] .. "Left-click " .. CovenantParty.STARTLINE .. CovenantParty.COLORS["WHITE"] .. "will enable the AddOn." .. CovenantParty.ENDLINE,
        lineThree = CovenantParty.STARTLINE .. CovenantParty.COLORS["GOLD"] .. "Right-click " .. CovenantParty.STARTLINE .. CovenantParty.COLORS["WHITE"] .. "will disable the AddOn." .. CovenantParty.ENDLINE,
        lineFour = " ",
        lineFive = "Be kind to each other."
    }
