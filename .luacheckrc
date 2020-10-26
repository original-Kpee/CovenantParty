std = "lua51"
max_line_length = false

exclude_files = {
	"Libs/",
	".luacheckrc"
}
ignore = {
	"212",
	"211/CovenantPartyGlobal", -- Unused global variable "CovenantPartyGlobal"
	"311/covenantAtlas", -- Value 'covenantAtlas' unused in block (used in if/else)
	"311/height", -- Value 'height' unused in block (used in if/else)
	"311/width", -- Value 'width' unused in block (used in if/else)
	"311/messageType", -- Value 'messageType' unused in block (function call)
	"311/payload", -- Value 'payload' unused in block (function call)
	"311/covenantData", -- Value 'covenantData' unused in block (function return)
	"311/fullTextString", -- Value 'fullTextString' unused in block (function return)
	"311/args", -- Value 'args' unused in block (function return)
	"111/SLASH_CovenantPartySlash1", -- WoW API for slash commands
	"111/SLASH_CovenantPartySlash2", -- WoW API for slash commands
	"111/SLASH_CovenantPartySlash3", -- WoW API for slash commands
	"113/_previewsTarget", -- Used in function
	"113/_currentTarget" -- Used in function

}
globals = {
	"_G",

	-- Covenant Party Addon globals
	"CovenantPartyDB",
	"CovenantPartyGlobal",

	-- Third Party Libraries
	"LibStub",
	
	-- WoW API
	"LoadAddOn",
	"DisableAddOn",
	"ReloadUI",
	"UnitName",
	"CreateFrame",
	"IsInGroup",
	"GetNumGroupMembers",
	"IsInRaid",
	"GetUnitName",
	"UNKNOWN",
	"C_ChatInfo",
	"PlayerFrame",
	"C_Covenants",
	"strsplit",
	"SlashCmdList",
	"GetBuildInfo",
	"GetLocale",
	"UnitExists",
	"UnitIsPlayer",
	"UIParent",
	"TargetFrame",
	UnitFactionGroup",
	"HIGH"
}
