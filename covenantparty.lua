-- Updated 10/12/2020
--  by kPee
local CovenantPartyGlobal, CovenantParty = ...

--> Local Var(s)
local _previewsTarget = _previewsTarget
local _currentTarget = _currentTarget 
local _joinedGroup = false

CovenantParty.currentGroup = {}
CovenantParty.newGroup = {}

CovenantParty.T = {targetFrame = CreateFrame("Frame", nil, TargetFrame)}
CovenantParty.P = {playerFrame = CreateFrame("Frame", nil, PlayerFrame)}
CovenantParty.G = {groupFrame = CreateFrame("Frame", nil, CompactPartyFrame)}

--> OnEvent Frame 
    -- CovenantParty.onEventFrame = CreateFrame("Frame", nil, UIParent)
    --> Global Frame
    CovenantParty.mainFrame = CreateFrame("Frame")
    CovenantParty.mainFrame:SetScript("OnEvent", function(self, event,...)

        if event == "GROUP_ROSTER_UPDATE" then 
            
            if IsInGroup() and _joinedGroup == false then
                CovenantParty:CreateCovenantSigil("party", CovenantPartyDB["char"]["covenantData"]["ID"], CompactPartyFrameMember1) 
                _joinedGroup = true
            end   

            if not IsInGroup() then
                print("You are not in a group.")
                _joinedGroup = false
                return
            end
            
            CovenantParty.U.UpdateGroupList()

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

            CovenantParty:CreateCovenantSigil(UnitName("player"), CovenantPartyDB["char"]["covenantData"]["ID"], PlayerFrame)

        elseif event == "PLAYER_LOGIN" then
            
            --> Make sure that SharedVariables are not nil
            if CovenantPartyDB == nil then
                return

            else
                
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
            end

            CovenantParty:CreateCovenantSigil(UnitName("player"), CovenantPartyDB["char"]["covenantData"]["ID"], PlayerFrame)

            if UnitIsPVP("player") then
                CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocationPvP[1], CovenantParty.PlayerFrameLocationPvP[2])
            else
                -- Move Covenant icon where PvP icon used to be
                CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocation[1], CovenantParty.PlayerFrameLocation[2])
            end

            if IsInGroup() and _joinedGroup == false then
                CovenantParty:CreateCovenantSigil("party", CovenantPartyDB["char"]["covenantData"]["ID"], CompactPartyFrameMember1) 
                _joinedGroup = true
            end               
            
        elseif event == "CHAT_MSG_ADDON" then
            --> As per WoW API the CHAT_MSG_ADDON fires when a message
            -->> is received from SendAddonMessage(). The Addon prefix
            -->> must be register with RegisterAddonMessagePrefix or
            -->> any messages sent by other players will be blocked
            local prefix, message, distribution_type, sender = ...

            --> Check that message is from/for Covenant Party AddOn
            --> If it is (prefix is "SL_COPA") call handler
            -->> CovenantParty.M.messageType, CovenantParty.M.payload
            if prefix and CovenantParty.M.messageAddonPrefix[prefix] then
                local _, payload = CovenantParty.U.ParseAddOnMsg(message, distribution_type, sender)
                if distribution_type == "WHISPER" then
                    if payload then
                        if _currentTarget ~= strsplit("-", sender) then 
                            return
                        else                        
                            CovenantParty:CreateCovenantSigil("target", payload, TargetFrame)
                        end
                    end 

                elseif distribution_type == "PARTY" or distribution_type == "INSTANCE" then
                    if strsplit("-", sender) == UnitName("player") then                    
                        CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember1)                        
                    else
                        CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember .. CovenantParty.currentGroup[sender] + 1)
                        CovenatParty.currentGroup[sender]["covenantID"] = payload
                    end
                end
            end
        elseif event == "PLAYER_TARGET_CHANGED" then
            _previewsTarget = _currentTarget
            _currentTarget = UnitName("target")

            if _currentTarget ~= _previewsTarget then
                if CovenantParty.T["texture"] ~= nil then CovenantParty.T["texture"]:Hide() end
            end

            if UnitExists("target") and UnitIsPlayer("target") and UnitFactionGroup("target") == UnitFactionGroup("player") then
                local targetName = UnitName("target")
                C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. "request", "WHISPER", targetName)
            elseif not UnitExists("target") then
                if CovenantParty.T["texture"] ~= nil then CovenantParty.T["texture"]:Hide() end
            end
        elseif event == "PLAYER_FLAGS_CHANGED" then
            if UnitIsPVP("player") then
                CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocationPvP[1], CovenantParty.PlayerFrameLocationPvP[2])
            else
                -- Move Covenant icon where PvP icon used to be
                CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocation[1], CovenantParty.PlayerFrameLocation[2])
            end
        end
    end
    )

--> CreateCovenantSigil()
    --> Called when player logs in OR when player chooses a covenant. Called when
    -->> a new party member joins the group.
    --> This function creates a texture and displays the players covenant sigil
    -->> on to the relative frame seleced.
    function CovenantParty:CreateCovenantSigil(playerIndex, playerCovenant, relativeFrame)
        local covenantAtlas = nil
        local height = 0
        local width = 0

        if playerCovenant == 1 then
            width = CovenantParty.SIGILS["kyrian"][1]
            height = CovenantParty.SIGILS["kyrian"][2]
            covenantAtlas = "covenantchoice-celebration-kyriansigil"
        elseif playerCovenant == 3 then
            width = CovenantParty.SIGILS["nightfae"][1]
            height = CovenantParty.SIGILS["nightfae"][2]
            covenantAtlas = "covenantchoice-celebration-nightfaesigil"
        elseif playerCovenant == 4 then
            width = CovenantParty.SIGILS["necrolords"][1]
            height = CovenantParty.SIGILS["necrolords"][2]
            covenantAtlas = "covenantchoice-celebration-necrolordsigil"
        elseif playerCovenant == 2 then
            width = CovenantParty.SIGILS["venthyr"][1]
            height = CovenantParty.SIGILS["venthyr"][2]
            covenantAtlas = "covenantchoice-celebration-venthyrsigil"
        else
            return
        end

        if playerIndex == UnitName("player") then
            CovenantParty.P["texture"] = CovenantParty.P["playerFrame"]:CreateTexture("Sigil","ARTWORK", PlayerFrame)
            CovenantParty.P.playerFrame:SetParent(PlayerFrame)
            CovenantParty.P.playerFrame:SetFrameStrata(HIGH)

            if UnitIsPVP("player") then
                CovenantParty.P["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.PlayerFrameLocationPvP[1], CovenantParty.PlayerFrameLocationPvP[2])
            else
                CovenantParty.P["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.PlayerFrameLocation[1], CovenantParty.PlayerFrameLocation[2])
            end

            CovenantParty.P["texture"]:SetHeight(height)
            CovenantParty.P["texture"]:SetWidth(width)
            CovenantParty.P["texture"]:SetAtlas(covenantAtlas)
        elseif playerIndex == "target" then
            CovenantParty.T["texture"] = CovenantParty.T.targetFrame:CreateTexture("Sigil","ARTWORK")
            CovenantParty.T.targetFrame:SetParent(TargetFrame)
            CovenantParty.T.targetFrame:SetFrameStrata(HIGH)
            
            if UnitIsPVP("player") then
                CovenantParty.T["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.TargetFrameLocationPvP[1], CovenantParty.TargetFrameLocationPvP[2])
            else
                CovenantParty.T["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.TargetFrameLocation[1], CovenantParty.TargetFrameLocation[2])
            end

            CovenantParty.T["texture"]:SetHeight(height)
            CovenantParty.T["texture"]:SetWidth(width)
            CovenantParty.T["texture"]:SetAtlas(covenantAtlas)
        elseif playerIndex == "party" then         
            if CovenantParty.G[string.lower(tostring(relativeFrame))] == nil or CovenantParty.G[string.lower(tostring(relativeFrame))]["active"] == false then
                print("Generating texture for " .. string.lower(tostring(relativeFrame)))
                CovenantParty.G[string.lower(tostring(relativeFrame))] = CovenantParty.G.groupFrame:CreateTexture("Sigil", "ARTWORK", relativeFrame)
                CovenantParty.G.groupFrame:SetParent(CompactPartyFrame)
                CovenantParty.G.groupFrame:SetFrameStrata(HIGH)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetPoint("CENTER", relativeFrame, "TOPRIGHT", 0, 0)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetHeight(height)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetWidth(width)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetAtlas(covenantAtlas)
                CovenantParty.G.groupFrame:Show()
                CovenantParty.G[string.lower(tostring(relativeFrame))]["active"] = true
            end
        end
    end

--> Register Events
    CovenantParty.mainFrame:RegisterEvent("PLAYER_LOGIN")
    CovenantParty.mainFrame:RegisterEvent("COVENANT_CHOSEN")
    CovenantParty.mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    CovenantParty.mainFrame:RegisterEvent("CHAT_MSG_ADDON")
    CovenantParty.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    CovenantParty.mainFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")