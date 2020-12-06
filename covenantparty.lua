-- Updated 10/12/2020
--  by kPee
local CovenantPartyGlobal, CovenantParty = ...

--> Local Var(s)
local _previewsTarget = _previewsTarget
local _currentTarget = _currentTarget 
local _joinedGroup = false

local countPartyFrame = 1

CovenantParty.currentGroup = {}
CovenantParty.newGroup = {}

CovenantParty.T = {targetFrame = CreateFrame("Frame", nil, TargetFrame)}
CovenantParty.P = {playerFrame = CreateFrame("Frame", nil, PlayerFrame)}
CovenantParty.G = {groupFrame = CreateFrame("Frame", nil, CompactPartyFrame)}
    
--> OnEvent Frame 
    --> Global Frame
    CovenantParty.mainFrame = CreateFrame("Frame")
    CovenantParty.mainFrame:SetScript("OnEvent", function(self, event,...)

        if event == "GROUP_ROSTER_UPDATE" then 
            
            if IsInGroup() and _joinedGroup == false then
                CovenantParty:CreateCovenantSigil("party", CovenantPartyDB["char"]["covenantData"]["ID"], CompactPartyFrameMember1) 
                _joinedGroup = true                

                CovenantParty.ShowDebugFrame()
            end   

            if not IsInGroup() then
                _joinedGroup = false
                CovenantParty.HideDebugFrame()
            end
            
            CovenantParty.U.UpdateGroupList()

            CovenantParty.ReWriteTextOnDebugFrame({"Party Member Names: ", CovenantParty.GetPartyMemberNames()}) 

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

            CovenantParty:ConfigureDebugFrame()

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
                    local _senderName, _senderRealm = strsplit("-", sender)

                    if _senderName == UnitName("player") then  
                        CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember1)                        
                    else
                        table.foreach(CovenantParty.currentGroup, function(key, value)                                                        
                            if CovenantParty.currentGroup[key]["name"] == _senderName then
                              
                                CovenantParty.currentGroup[key]["covenant"] = payload
                                
                                local _currentyPartyMemberIndexCount = key + 1

                                if _currentyPartyMemberIndexCount == 2 then
                                    CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember2)
                                elseif _currentyPartyMemberIndexCount == 3 then
                                    CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember3)
                                elseif _currentyPartyMemberIndexCount == 4 then
                                    CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember4)
                                elseif _currentyPartyMemberIndexCount == 5 then
                                    CovenantParty:CreateCovenantSigil("party", payload, CompactPartyFrameMember5)
                                end
                            end                            
                        end)
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
                local targetName, targetRealm = UnitName("target")
                if targetRealm == nil then
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. "request", "WHISPER", targetName)
                else
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. "request", "WHISPER", targetName .. "-" .. targetRealm)
                end
                
            elseif not UnitExists("target") then
                if CovenantParty.T["texture"] ~= nil then CovenantParty.T["texture"]:Hide() end
            end

        elseif event == "PLAYER_FLAGS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            
            if IsInGroup() and _joinedGroup == false then
                CovenantParty:CreateCovenantSigil("party", CovenantPartyDB["char"]["covenantData"]["ID"], CompactPartyFrameMember1) 
                _joinedGroup = true
            end       

            CovenantParty:UpdatePlayerFrameSigil()
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
                CovenantParty.G[string.lower(tostring(relativeFrame))] = CovenantParty.G.groupFrame:CreateTexture("Sigil", "ARTWORK", relativeFrame)
                CovenantParty.G.groupFrame:SetParent(CompactPartyFrame)
                CovenantParty.G.groupFrame:SetFrameStrata(HIGH)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetPoint("CENTER", relativeFrame, "CENTER", -55, 5)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetHeight(height)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetWidth(width)
                CovenantParty.G[string.lower(tostring(relativeFrame))]:SetAtlas(covenantAtlas)
                CovenantParty.G.groupFrame:Show()
                CovenantParty.G[string.lower(tostring(relativeFrame))]["active"] = true
            end
        end
    end

    function CovenantParty:RemoveCompactPartyFrameSigil(frame)
        print(type(frame))
        if type(frame) == "string" and frame == "all" then
            for i = 1, CovenantParty.GetPartySize() do
                if _currentyPartyMemberIndexCount == 1 then                    
                    CovenantParty.G[CompactPartyFrameMember2]:SetAtlas(nil)
                elseif _currentyPartyMemberIndexCount == 2 then
                    CovenantParty.G[CompactPartyFrameMember3]:SetAtlas(nil)
                elseif _currentyPartyMemberIndexCount == 3 then
                    CovenantParty.G[CompactPartyFrameMember4]:SetAtlas(nil)
                elseif _currentyPartyMemberIndexCount == 4 then
                    CovenantParty.G[CompactPartyFrameMember5]:SetAtlas(nil)
                end
            end
        else
        end
    end

    function CovenantParty:UpdatePlayerFrameSigil()
        if UnitIsPVP("player") then
            CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocationPvP[1], CovenantParty.PlayerFrameLocationPvP[2])
        else
            -- Move Covenant icon where PvP icon used to be
            CovenantParty.P["texture"]:SetPoint("CENTER", PlayerFrame, "CENTER", CovenantParty.PlayerFrameLocation[1], CovenantParty.PlayerFrameLocation[2])
        end
    end

--> Frames
    function CovenantParty:ConfigureDebugFrame()
        --> Debug Frame
        CovenantParty.debugFrame = CreateFrame("Frame", "CovenantParty! Debug Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
        CovenantParty.debugFrame:EnableMouse(true)
        CovenantParty.debugFrame:SetMovable(true)
        CovenantParty.debugFrame:RegisterForDrag("LeftButton")
        CovenantParty.debugFrame:SetWidth(150)
        CovenantParty.debugFrame:SetHeight(200)
        CovenantParty.debugFrame:SetAlpha(.90)
        CovenantParty.debugFrame:SetPoint("CENTER", 650, -100)
        CovenantParty.debugFrame.text = CovenantParty.debugFrame:CreateFontString(nil, "ARTWORK")
        CovenantParty.debugFrame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
        CovenantParty.debugFrame.text:SetPoint("CENTER", 0,0)
        CovenantParty.debugFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        CovenantParty.debugFrame:SetBackdropColor(0, 0, 1, .5)
        CovenantParty.debugFrame:SetScript("OnDragStart", CovenantParty.debugFrame.StartMoving)
        CovenantParty.debugFrame:SetScript("OnDragStop", CovenantParty.debugFrame.StopMovingOrSizing)

        CovenantParty.debugFrame:Hide()
    end

    function CovenantParty.ReWriteTextOnDebugFrame(...)
        local _arg = {...}
        local _displayableText = {}

        if _arg then
            for i,v in ipairs(_arg) do
                if type(v) == "table" then
                    for ii, vv in ipairs(v) do
                        if type(vv) == "table" then
                            for iii, vvv in ipairs(vv) do
                                table.insert(_displayableText, vvv)
                                -- CovenantParty.debugFrame.text:SetText(vvv .. "\n")
                            end
                        else
                            table.insert(_displayableText, vv)
                            -- CovenantParty.debugFrame.text:SetText(vv .. "\n")
                        end
                    end
                else
                    table.insert(_displayableText, v)
                    -- CovenantParty.debugFrame.text:SetText(v .. "\n")
                end
            end
            local _tempDisplayableText = ""

            table.foreach(_displayableText, function(i, v)
                _tempDisplayableText = _tempDisplayableText .. "\n" .. v 
                CovenantParty.debugFrame.text:SetText(_tempDisplayableText)                
            end)
        end
    end

    function CovenantParty:HideDebugFrame()
        CovenantParty.ReWriteTextOnDebugFrame(" ")
        CovenantParty.debugFrame:Hide()
    end

    function CovenantParty:ShowDebugFrame()
        CovenantParty.debugFrame:Show()
    end

--> Register Events
    CovenantParty.mainFrame:RegisterEvent("PLAYER_LOGIN")
    CovenantParty.mainFrame:RegisterEvent("COVENANT_CHOSEN")
    CovenantParty.mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    CovenantParty.mainFrame:RegisterEvent("CHAT_MSG_ADDON")
    CovenantParty.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    CovenantParty.mainFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    CovenantParty.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

