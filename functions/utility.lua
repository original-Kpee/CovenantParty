local CovenantParty = _G.CovenantParty
local _L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty")

-- Utility Function for loading saved variables and checking if 
--  any new keys to table have been added
local function LoadAndCheckTable(table_var, shared_variable)
    for key, value in pairs(table_var) do        
        -- Check if a new key exists in 'table'. If so,
        --  add it to SharedVariable(s)
        if shared_variable[key] == nil then
            -- Check if type of value is a table. If so,
            --  do a deep copy of table
            if type(value) == "table" then
                shared_variable[key] = table_deepcopy(table_var[key])
            else
                shared_variable[key] = value
            end
        elseif type(shared_variable[key] == "string") then
            
        elseif type(shared_variable[key] == "table") then                        
            for nested_key, nested_value in pairs(table_var[key]) do
                if shared_variable[key][nested_key] == nil then
                    if type(nested_value) == "table" then
                        shared_variable[key][nested_key] = table_deepcopy(table_var[key][nested_key])
                    else
                        shared_variable[key][nested_key] = nested_value
                    end
                end
            end
        else
            -- Copy the key to addon Object
            if type(value) == "table" then
                CovenantParty[key] = table_deepcopy(shared_variable[key])
            else
                CovenantParty[key] = shared_variable[key]
            end
        end
    end
end

-- Load global and character data
function CovenantParty:LoadSharedVariables()
    -- Check if SharedVariables exist
    if not CovenantParty_SV then
        CovenantParty_SV = table_deepcopy(CovenantParty.default_global_data)
    end

    -- Check if SharedVariablesPerCharacter exist
    if not CovenantParty_SVperChar then
        CovenantParty_SVperChar = table_deepcopy(CovenantParty.default_player_data)
    end

    -- Load and Check for Update
    LoadAndCheckTable(CovenantParty.default_global_data, CovenantParty_SV)
    LoadAndCheckTable(CovenantParty.default_player_data, CovenantParty_SVperChar)
end