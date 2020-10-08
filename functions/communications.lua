local CovenantParty = _G.CovenantParty
local _L = LibStub("AceLocale-3.0"):GetLocale("CovenantParty")

CovenantParty.communications = {}

-- Communication Constants
local VERSION_CHECK = "VC"
local SHARE_DATA = "SD"
local HANDSHAKE_REQ = "HR"
local HANDSHAKE_DATA = "HD"

CovenantParty.communications.id = {
    ["VERSION_CHECK"] = VERSION_CHECK,
    ["SHARE_DATA"] = SHARE_DATA,
    ["HANDSHAKE_REQ"] = HANDSHAKE_REQ,
    ["HANDSHAKE_DATA"] = HANDSHAKE_DATA,
}


-- Handels when a message is received
function CovenantParty:OnMsgReceived(_, msg, _, sender)
    local prefix, player, arg1 =  _select (2, _detalhes:Deserialize (data))

    CovenantParty:Print(player .. " has sent your Addon a message.")
end

CovenantParty:RegisterComm("CovenantParty", "OnMsgReceived")