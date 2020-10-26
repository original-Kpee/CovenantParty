-- Updated 10/12/2020
--  by kPee
local CovenantPartyGlobal, CovenantParty = ...

--> Local Var(s)
    local _previewsTarget = _previewsTarget
    local _currentTarget = _currentTarget
    local _currentGroup = {}
    local _newGroup = {}    

CovenantParty.T = {targetFrame = CreateFrame("Frame", nil, TargetFrame)}
CovenantParty.P = {playerFrame = CreateFrame("Frame", nil, PlayerFrame)}
CovenantParty.G = {
    group = {},
    newGroup = {}
}

CovenantParty.G.playerTextures = {}

--> OnEvent Frame 
    CovenantParty.onEventFrame = CreateFrame("Frame", nil, UIParent)
    CovenantParty.onEventFrame:SetScript("OnEvent", function(self, event,...)
        if event == "GROUP_ROSTER_UPDATE" then
            CovenantParty.G["group"] = CovenantParty.G["newGroup"]
            CovenantParty.G["newGroup"] = {}

            if not IsInGroup() then
                return
            end

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
            for name, _ in pairs(CovenantParty.G["newGroup"]) do
                if not CovenantParty.G["group"] then
                    --> This play were not in the group previewsly
                    -->> Send your covenant and version to the new player
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["VERSION"] .. "\t" .. CovenantParty.ADDON_VERSION_MAJOR .. CovenantParty.ADDON_VERSION_MINOR .. CovenantParty.ADDON_VERSION_PATCH, "WHISPER", name)
                    C_ChatInfo.SendAddonMessage(CovenantParty.MESSAGE_PREFIX, CovenantParty.MESSAGETYPE["COVENANT"] .. "\t" .. CovenantPartyDB["char"]["covenantData"]["covenantID"], "WHISPER", name)
                end
            end

            --> Check if the change in roster was somone leaving the group
            for name, index in pairs(CovenantParty.G["group"]) do
                if not CovenantParty.G["newGroup"] then
                    -->>                  TODO                   <<--
                    --> Place holder: Need to update raid frames. <--
                    -->>                  TODO                   <<--
                end
            end

            CovenantParty.onEventFrame:Show()

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

            CovenantParty:DisplayCovenantSigil(UnitName("player"), CovenantPartyDB["char"]["covenantData"]["ID"], PlayerFrame)

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

            CovenantParty:DisplayCovenantSigil(UnitName("player"), CovenantPartyDB["char"]["covenantData"]["ID"], PlayerFrame)

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
                if distribution_type == "WHISPER" then

                    local _, payload = CovenantParty.U.ParseAddOnMsg(message, distribution_type, sender)
                    if payload then
                        if _currentTarget ~= strsplit("-", sender) then 
                            return
                        else                        
                            CovenantParty:DisplayCovenantSigil("target", payload, TargetFrame)
                        end
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
        end
    end
    )

--> DisplayCovenantSigil()
    --> Called when player logs in OR when player chooses a covenant. Called when
    -->> a new party member joins the group.
    --> This function creates a texture and displays the players covenant sigil
    -->> on to the relative frame seleced.
    function CovenantParty:DisplayCovenantSigil(playerIndex, playerCovenant, relativeFrame)
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
            CovenantParty.P["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.PlayerFrameLocation[1], CovenantParty.PlayerFrameLocation[2])
            CovenantParty.P["texture"]:SetHeight(height)
            CovenantParty.P["texture"]:SetWidth(width)
            CovenantParty.P["texture"]:SetAtlas(covenantAtlas)
        elseif playerIndex == "target" then
            CovenantParty.T["texture"] = CovenantParty.T.targetFrame:CreateTexture("Sigil","ARTWORK")
            CovenantParty.T.targetFrame:SetParent(TargetFrame)
            CovenantParty.T.targetFrame:SetFrameStrata(HIGH)
            CovenantParty.T["texture"]:SetPoint("CENTER", relativeFrame, "CENTER", CovenantParty.TargetFrameLocation[1], CovenantParty.TargetFrameLocation[2])
            CovenantParty.T["texture"]:SetHeight(height)
            CovenantParty.T["texture"]:SetWidth(width)
            CovenantParty.T["texture"]:SetAtlas(covenantAtlas)
        end
    end

--> Register Events
    CovenantParty.onEventFrame:RegisterEvent("PLAYER_LOGIN")
    CovenantParty.onEventFrame:RegisterEvent("COVENANT_CHOSEN")
    CovenantParty.onEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    CovenantParty.onEventFrame:RegisterEvent("CHAT_MSG_ADDON")
    CovenantParty.onEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")