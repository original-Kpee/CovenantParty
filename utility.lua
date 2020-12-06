local CovenantPartyGlobal, CovenantParty = ...

local _oldGroup = {}

CovenantParty.U = {}

--> Global check that the utility.lua file has
-->>  been loaded and all utility functions are
-->>  available for use
CovenantParty.U.UTILITY_FILE_LOADED = true

--> Beautification Functions
do
    function CovenantParty.U.Print(text,...)
        if type(text) ~= "table" then
            return
        else
            local fullTextString = ...

            -- Assign the required first text for
            --  function call
            fullTextString = CovenantParty.STARTLINE..text["color"]..text["text"]..CovenantParty.ENDLINE

            -- Iterate through each subsequent arg to add to string
            for i = 1, select("#", ...) do
                if type(select(i, ...)) == "table" then
                    fullTextString = fullTextString..CovenantParty.STARTLINE..select(i,...)["color"]..select(i,...)["text"]..CovenantParty.ENDLINE
                end
            end

            -- Print full string
            print(fullTextString)
        end
    end
end


--> Communication Functions
    function CovenantParty.U.ParseAddOnMsg(message, distribution_type, sender)
        -->> Message format: SL_COPA <type> \t <payload>
        local messageType, payload, covenantID = strsplit("\t", message)

        --> Version
        if tonumber(messageType) == CovenantParty.MESSAGETYPE["VERSION"] then
            print("VERSION Received.")
        --> Covenant
        elseif tonumber(messageType) == CovenantParty.MESSAGETYPE["COVENANT"] then
            if payload == "request" then
                C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. CovenantPartyDB["char"]["covenantData"]["ID"], "WHISPER", sender)
                return     
            elseif payload == "broadcast" then
                payload = covenantID       
            end
        end

        return messageType, tonumber(payload)
    end

--> Covenant Functions
    function CovenantParty.U.GetCovenantData()
        local covenantID = C_Covenants.GetActiveCovenantID()
        if covenantID ~= 0 then
            local covenantData = nil
            covenantData = C_Covenants.GetCovenantData(covenantID)
            return covenantData
        else
            return nil
        end
    end

--> Group Utility
    function CovenantParty.GetPartyMemberNames()
        local _namesTemp = {}
        table.foreach(CovenantParty.currentGroup, function(key,value)
            table.insert(_namesTemp, CovenantParty.currentGroup[key]["name"])
        end)
        
        return _namesTemp
    end

    function CovenantParty.GetPartyMemberCovenants()
        local _covenantsTemp = {}
        table.foreach(CovenantParty.currentGroup, function(key,value)
            table.insert(_covenantsTemp, CovenantParty.currentGroup[key]["covenant"])
        end)

        return _covenantsTemp
    end

    function CovenantParty.GetPartySize()
        return #CovenantParty.currentGroup
    end

    function CovenantParty.PrintPartyMembersNames()
        local _names = CovenantParty.GetPartyMemberNames()

        table.foreach(_names, print)
    end

    function CovenantParty.U.UpdateGroupList()
        local newGroupSize, unit = GetNumGroupMembers(), "raid"

        if not IsInRaid() then
            newGroupSize, unit = newGroupSize - 1, "party"
        end
        
        -- Assign the current group to the old group
        --  If this is the first time through then currentGroup
        --      shall be empty (nil)
        _oldGroup = CovenantParty.currentGroup

        if newGroupSize == #_oldGroup then return end

        if newGroupSize < #CovenantParty.currentGroup then
            if newGroupSize == 0 then
                wipe(CovenantParty.currentGroup)
                return
            end        

            for oldGroupIndex, oldGroupValue in pairs(_oldGroup) do            
                if oldGroupValue["name"] ~= GetUnitName(unit..oldGroupIndex, true) then
                    -- Look for old group member name in new group
                    for eachMember = 1, newGroupSize do
                        if GetUnitName(unit..eachMember, true) == oldGroupValue["name"] then return end
                    end                        

                    table.foreach(CovenantParty.currentGroup, function(index, value)
                        if value["name"] == oldGroupValue["name"] then
                            table.remove(CovenantParty.currentGroup, index)
                            return
                        end
                    end)
                end
            end
        end

        --> Checks if a new member has joined the group
        for newMember = 1, newGroupSize do
            local newMemberName = GetUnitName(unit..newMember, true)
            local inGroup = false

            if newMemberName and newMemberName ~= UNKNOWN then
                table.foreach(CovenantParty.currentGroup, function(key, value)
                    if CovenantParty.currentGroup[key]["name"] == newMemberName then
                        inGroup = true
                        return
                    end
                end)

                if inGroup == false then                
                    table.insert(CovenantParty.currentGroup, {name = newMemberName, covenant = 0})
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE.COVENANT .."\t" .. "broadcast" .. "\t" .. CovenantPartyDB["char"]["covenantData"]["ID"], string.upper(unit))
                end
            end
        end
    end