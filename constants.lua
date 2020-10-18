local CovenantPartyGlobal, CovenantParty = ...

--> Version Constants
    CovenantParty.ADDON_VERSION_MAJOR = "alpha_0.0"
    CovenantParty.ADDON_VERSION_MINOR = "0"
    
--> Text Beautification
    CovenantParty.COLORS = {        
        LIGHT_BLUE = 'cff00ccff',
        LIGHT_RED = 'cffff6060',
        RED = 'cffFF0000',
        PURPLE = 'cffDA70D6',
        GOLD = 'cffffcc00',
        ORANGE = 'cffFF4500',
        PINK = 'cffFF6EB4',
        WHITE = 'cffffffff',
        BLUE = 'cff0000ff',
        BLACK = 'cFF000000'
    }

    CovenantParty.STARTLINE = '\124'
    CovenantParty.ENDLINE = '\124r'

    CovenantParty.MESSAGETYPE = {
        VERSION = 1,
        COVENANT = 2
    }

    CovenantParty.MESSAGE_PREFIX = "SL_COPA"