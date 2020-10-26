local CovenantPartyGlobal, CovenantParty = ...

--> Version Constants
    --> [major].[minor].[patch] - [a,b,rc].[build]
    CovenantParty.ADDON_VERSION_MAJOR = "alpha_"
    CovenantParty.ADDON_VERSION_MINOR = "0"
    CovenantParty.ADDON_VERSION_PATCH = 0

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

    CovenantParty.SIGILS = {
        kyrian = {28, 42},
        venthyr = {35, 37},
        nightfae = {32, 32},
        necrolords = {40, 48}
    }

    CovenantParty.PlayerFrameLocation = {-78, 10}
    CovenantParty.TargetFrameLocation = {78, 10}