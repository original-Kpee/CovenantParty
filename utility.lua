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
    function CovenantParty.U.UpdateGroupList()
        local newGroupSize, unit = GetNumGroupMembers(), "raid"
        if not IsInRaid() then
            newGroupSize, unit = newGroupSize - 1, "party"
        end
        
        _oldGroup = CovenantParty.currentGroup

        if newGroupSize < #CovenantParty.currentGroup then
            print("------------------------\n")
            print("Someone left the group.\n")

            if newGroupSize == 0 then
                wipe(CovenantParty.currentGroup)
                return
            end

            table.foreach(_oldGroup, print)
            print(" - - - - - - -\n")
            print("Group size is " .. newGroupSize)

            for indexOldGroup, nameOldGroup in ipairs(_oldGroup) do
                print("Start Check\n\n")
                for count = 1, newGroupSize do
                    local partyFrameName = GetUnitName(unit..count, true)
                    local leftGroup = true
                    local nameThatLeft = " "

                    print("Checking for " .. partyFrameName)
                    print("... against " .. nameOldGroup .. "\n")

                    if partyFrameName == nameOldGroup then
                        print(nameOldGroup .. " is still in the group. \n\n")
                        leftGroup = false
                    end

                    nameThatLeft = nameOldGroup

                    if leftGroup == true then 
                        print(nameThatLeft .. " is not in the group. Let's remove him.")
                        table.foreach(CovenantParty.currentGroup, function(index, value)
                            print("Looking at " .. index .. " index with name " .. value)
                            if value == nameThatLeft then
                                print(value .. " left the group.\n")
                                table.remove(CovenantParty.currentGroup, index)
                                return
                            end
                        end)
                    end
                end
            end

            table.foreach(CovenantParty.currentGroup, print)
            print("-------------- end ----------\n")
        end
        --> Checks if a new member has joined the group
        for newMember = 1, newGroupSize do
            local newMemberName = GetUnitName(unit..newMember, true)
            local inGroup = false

            if newMemberName and newMemberName ~= UNKNOWN then
                table.foreach(CovenantParty.currentGroup, function(key, value)
                    if value == newMemberName then
                        inGroup = true
                        return
                    end
                end)

                if inGroup == false then
                    table.insert(CovenantParty.currentGroup, newMemberName)
                    print(newMemberName .. " inserted into new group.\n")
                    print("The new group size is " .. #CovenantParty.currentGroup)  
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE.COVENANT .."\t" .. "broadcast" .. "\t" .. CovenantPartyDB["char"]["covenantData"]["ID"], string.upper(unit))
                end
            end
        end
    end