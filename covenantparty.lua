-- Updated 10/12/2020
--  by kPee
local GlobalAddonName, CovenantParty = ...

CovenantParty.G = {
    group = {},
    newGroup = {}
}

    CovenantParty.frame = CreateFrame("Frame")

    CovenantParty.frame:SetScript("OnEvent", function(self, event,...)
        if event == "GROUP_ROSTER_UPDATE" then
            CovenantParty.G["group"] = CovenantParty.G["newGroup"]
            CovenantParty.G["newGroup"] = {}

            local numbOfGroupMembers = GetNumGroupMembers()

            --> Add all the names of the group members
            -->> to internal table
            if not IsInRaid() then
                for countEachMember = 1, numbOfGroupMembers do
                    local name = GetUnitName("party"..countEachMember, true)

                    if name and name ~= UNKNOWN then
                        CovenantParty.G["newGroup"][name]= countEachMember
                    end
                end
            end

            --> Check if the change in roster was a move or a join
            for name, index in pairs(CovenantParty.G["newGroup"]) do
                if not CovenantParty.G["group"] then
                    --> This play were not in the group previewsly
                    -->> Send your covenant and version to the new player
                    SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["VERSION"] .. "\t" .. CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR, "WHISPER", name)
                    SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. CovenantPartyDB["char"]["covenantData'"]["covenantID"], "WHISPER", name)
                end
            end

        elseif event == "COVENANT_CHOSEN" then
            --> During initalization the AddOn discovered that
            -->> the player had not choosen a covenant yet.
            -->> So, the COVENANT_CHOSE event was registered
            -->> and the code below triggered when player
            -->> chooses a covenant.
            -->> --> Note: This even will trigger if player
            -->> --> leave a covenant and joins another.
            local covenantInfo = CovenantParty.U.GetCovenantData()

            for key, value in pairs(covenantInfo) do
                CovenantPartyDB["char"]["covenantData"][key] = value
            end

        elseif event == "PLAYER_LOGIN" then    
            --> Check player covenant selection
            -- if CovenantPartyDB["char"]["covenantData"]["covenantID"] ==  0 then
            local covenantInfo = CovenantParty.U.GetCovenantData()

            if covenantInfo == nil then
                --> No covenant has been selected. Register event for
                -->> when player decided to choose a covenant
                self:RegisterEvent("COVENANT_CHOSEN")

                --> Ensure that SharedVariables is back to default
                -->> for this player
                for key, value in pairs(CovenantParty.defaults) do
                    if key == "char" then
                        for charKey, charValue in pairs(value) do
                            CovenantPartyDB["char"][charKey] = charValue
                        end
                    end
                end
            else
                for key, value in pairs(covenantInfo) do
                    CovenantPartyDB["char"]["covenantData"][key] = value
                end

            end

        elseif event == "CHAT_MSG_ADDON" then
            --> As per WoW API the CHAT_MSG_ADDON fires when a message
            -->> is received from SendAddonMessage(). The Addon prefix
            -->> must be register with RegisterAddonMessagePrefix or
            -->> any messages sent by other players will be blocked
            local prefix, message, distribution_type, sender = ...

            --> Check that message is from/for Covenant Party AddOn
            if prefix and CovenantParty.M.messageAddonPrefix[prefix] then
                --> If it is (prefix is "SL_COPA") call handler
                CovenantParty.M.parsedData = CovenantParty.U.ParseAddOnMsg(message, distribution_type)


            end

        end
    end
    )

    CovenantParty.frame:RegisterEvent("PLAYER_LOGIN")
    CovenantParty.frame:RegisterEvent("COVENANT_CHOSEN")
    CovenantParty.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    CovenantParty.frame:RegisterEvent("CHAT_MSG_ADDON")

    -- local groups, new_group, events = {}, {}, {}

    -- function CovenantParty:GROUP_ROSTER_UPDATE()
    --     group, new_group = new_group, group
    --     new_group = {}

    --     local n, unit = GetNumGroupMembers(), "raid"
    --     if not IsInRaid() then
    --         n, unit = n - 1, "party"
    --     end

    --     for i = 1, n do
    --         local name = GetUnitName(unit..i, true)
    --         if name and name ~= UNKNOWN then
    --             new_group[name] = i
    --         end
    --     end

    --     for name, index in pairs(new_group) do 
    --         if not group[name] then
    --             CovenantParty:Print(name, "joined the group.")
    --         elseif group[name] ~= index then
    --             CovenantParty:Print(name, "moved within the group.")
    --         end
    --     end

    --     for name, index in pairs(group) do
    --         if not new_group[name] then
    --             CovenantParty:Print(name, "left the group.")
    --         end
    --     end
    -- end