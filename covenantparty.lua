local CovenantParty = _G.CovenantParty
local L = _G.LibStub("AceLocale-3.0"):GetLocale("CovenantParty")

local groups, new_group, events = {}, {}, {}

function  CovenantParty:OnEnable()
    CovenantParty:GetCovenantData()
    CovenantParty:LoadSharedVariables() 
end


function CovenantParty:GROUP_ROSTER_UPDATE()
    group, new_group = new_group, group
    new_group = {}

    CovenantParty:SendCommMessage(CovenantParty.communications.id["VERSION_CHECK"], CovenantParty:Serialize(UnitName("player"), CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR), "PARTY")

    -- if not IsInGroup() then
    --     CovenantParty:Print("You are not in a group")
    --     return
    -- end

    local n, unit = GetNumGroupMembers(), "raid"
    if not IsInRaid() then
        n, unit = n - 1, "party"
    end

    for i = 1, n do
        local name = GetUnitName(unit..i, true)
        if name and name ~= UNKNOWN then
            new_group[name] = i
        end
    end

    for name, index in pairs(new_group) do 
        if not group[name] then
            CovenantParty:Print(name, "joined the group.")
        elseif group[name] ~= index then
            CovenantParty:Print(name, "moved within the group.")
        end
    end

    for name, index in pairs(group) do
        if not new_group[name] then
            CovenantParty:Print(name, "left the group.")
        end
    end
end

function CovenantParty:COVENANT_CHOSEN()
    CovenantParty:GetCovenantData()
    CovenantParty:Print("Hey")
    LoadAndCheckTable(CovenantParty.default_player_data, CovenantParty_SVperChar)
end