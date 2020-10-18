std = "lua51"
max_line_length = false

exclude_files = {
	"Libs/",
	".luacheckrc"
}
ignore = {
	"211/CovenantPartyGlobal", -- Unused global variable "CovenantPartyGlobal"

}
globals = {
	"_G",

	-- Covenant Party Addon globals
	"CovenantPartyDB",
	"CovenantPartyGlobal",

	-- Third Party Libraries
	"LibStub"
	
	-- 
}
