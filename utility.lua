--> Last Update 10.09.2020
-->>  by kPee
local CovenantPartyGlobal, CovenantParty = ...

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
            local args = {...}
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
    function CovenantParty.U.ParseAddOnMsg(message, distribution_type)

        -->> Message format: SL_COPA <type> \t <payload>
        local messageType, payload = strsplit("\t", message)

        --> Version
        if messageType == CovenantParty.MESSAGETYPE["VERSION"] then
            print("VERSION Received.")
        --> Covenant
        elseif messageType == CovenantParty.MESSAGETYPE["COVENANT"] then
            print("COVENANT Received")            
        end        

        return messageType, payload
    end

--> Covenant Functions
    function CovenantParty.U.GetCovenantData()
        local covenantID = C_Covenants.GetActiveCovenantID()        
        if characterCovenantID ~= 0 then
            local covenantData = nil
            covenantData = C_Covenants.GetCovenantData(covenantID)
            return covenantData
        else
            return nil
        end
    end

    function CovenantParty.U.StorePartyMemberCovenantData(name, covenant)
        for _name, _ in pairs(CovenantParty.G["group"]) do
            if _name == name then
                CovenantParty.G["group"][name]["covenant"] = covenant
            end
        end
    end

    function CovenantParty.U.CheckAndStorePartyMemberVersion(name, version)
        local versionStatus = "degrated"

        if version ==  CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR then
            versionStatus = "up-to-date"
        end

        for _name, _ in pairs(CovenantParty.G["group"]) do
            if _name == name then
                CovenantParty.G["group"][name]["version"] = versionStatus
            end
        end
    end