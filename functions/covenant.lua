local CovenantParty = _G.CovenantParty
local _L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty")


-- Get Player covenant data
function CovenantParty:GetCovenantData()
    characterCovenantID = C_Covenants.GetActiveCovenantID()
     if characterCovenantID ~= 0 then
        covenant_data = C_Covenants.GetCovenantData(characterCovenantID)
 
         for key, value in pairs(covenant_data) do
            CovenantParty.default_player_data["covenant_data"][key] = value
         end
     end
 end