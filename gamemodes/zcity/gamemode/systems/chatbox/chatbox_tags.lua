/**
* Tags configuration
* This is not a dedicated tags add-on, there are probably better add-ons out there for tags.
**/

-- Tag to display for a dead player's message in the CHAT
-- You can use parsers here.
LOUNGE_CHAT.TagDead = "<color=255,0,0>*DEAD*</color> "

-- Tag to display for a player's team message in the CHAT
-- The color preceding this will be the player's team color.
-- You can use parsers here.
LOUNGE_CHAT.TagTeam = " "

-- Tag to display for a dead player's message in the CONSOLE
-- You can't put parsers in there. What you can do is use a table for different text/colors.
LOUNGE_CHAT.TagDeadConsole = {Color(255, 0, 0), "*DEAD* "}

-- Tag to display for a player's team message in the CONSOLE
-- The color preceding this will be the player's team color.
-- You can't put parsers in there. What you can do is use a table for different text/colors.
LOUNGE_CHAT.TagTeamConsole = {" "}

/**
* Name Color configuration
*/

-- Here you can set up custom name colors for specific usergroups.
-- By default the name color is the player's team color.
LOUNGE_CHAT.CustomColorsGroups = {
	["superadmin"] = Color(255, 0, 0),
}

-- Here you can set up custom name colors for specific players.
-- This takes priority over the usergroup custom color.
-- By default the name color is the player's team color.
LOUNGE_CHAT.CustomColorsPlayers = {
	["76561198300184275"] = Color(148, 0, 211),
	--["STEAM_0:1:8039869"] = Color(0, 255, 255),
	--["76561197976345467"] = Color(0, 255, 255),
}

/**
* Team Tags configuration
*/

-- Set to true to display the player's team name before their name.
LOUNGE_CHAT.TeamTags = false

-- Set to 1 to change the team tag's case to uppercase.
-- Set to -1 to change it to lowercase.
LOUNGE_CHAT.TeamTagsCase = 1

-- (Advanced) String format of the team tag. Leave it alone if you don't know what this does.
LOUNGE_CHAT.TeamTagsFormat = "[%s]"

/**
* DayZ Tags configuration
* Because the generic DayZ gamemode for sale on gmodstore is terribly coded in general,
* we have to discard its tag system and use our own instead.
* Don't touch this if you don't know what this does.
**/

local ooc = {
	tagcolor = Color(100, 100, 100),
	tag = "[OOC] ",
}

LOUNGE_CHAT.DayZ_ChatTags = {
	["!"] = {
		["ooc"] = ooc,
		["g"] = ooc,
		["y"] = ooc,
	},
	["/"] = {
		["ooc"] = ooc,
		["g"] = ooc,
		["y"] = ooc,
		["/"] = ooc,
	},
}

/**
* Custom Tags configuration
* If aTags is installed, this won't be used at all.
**/

-- Enable custom tags for specific usergroups/players.
LOUNGE_CHAT.EnableCustomTags = true

-- Here is where you set up custom tags for usergroups.
-- If there's a custom tag for a specific SteamID/SteamID64, it'll take priority over the one here.
-- If you don't want a group to have a custom tag, then don't put it in the table.
-- You can use parsers here.
LOUNGE_CHAT.CustomTagsGroups = {
	--["superadmin"] = ":script_edit: ",
	["cm"] = ":user_gray: <flash=165,73,50,1>[Community manager]</flash>",
	["spectator"] = ":rosette: <flash=165,73,50,1>[Warden]</flash>",
	["headadmin"] = ":fire: <flash=255,55,0,1>[Head Administrator]</flash>",
	["admin"] = ":shield: <flash=255,0,0,1>[Administrator]</flash>",
	["premium"] = ":medal_gold_1:",
}

LOUNGE_CHAT.CustomTagsGroups_RUSSIAN = {
	--["superadmin"] = ":script_edit: ",
	["spectator"] = ":rosette: <flash=165,73,50,1>[Смотритель]</flash>",
	["cm"] = ":user_gray: <flash=165,73,50,1>[Комьюнити менеджер]</flash>",
	["headadmin"] = ":fire: <flash=255,55,0,1>[Главный Администратор]</flash>",
	["admin"] = ":shield: <flash=255,0,0,1>[Администратор]</flash>",
	["premium"] = ":medal_gold_1:",
}

-- Here is where you set up custom tags for specific players. Accepts SteamIDs and SteamID64s.
-- This takes priority over the usergroup custom tag.
-- You can use parsers here.
LOUNGE_CHAT.CustomTagsPlayers = {
	--["76561198362124735"] = ":heart:<rainbow=1>[Жена Императора] </rainbow>",
	["76561198975900753"] = ":heart:<rainbow=1>[FemBoy] </rainbow>",
	["76561198992538944"] = ":heart:<rainbow=1>[Boykisser] </rainbow>",
	["76561199133126422"] = "<rainbow=1>[Брич Головного Мозга] </rainbow>",
	["76561198031993253"] = "<rainbow=1>[Sturmbannfuhrer] </rainbow>",
	["76561198386593453"] = "<flash=174,0,255,0>[DIOR SAUVAGE] </flash>",
	["76561198420505102"] = "<rainbow=1>[GiveAFuck] </rainbow>",
	["76561198849203748"] = "<rainbow=1>[Ебал Бризоль] </rainbow>",
	["76561198376609388"] = '<rainbow=1>[покупной] </rainbow>',
	["76561198208507147"] = "<flash=255,122,248,0>[Папа Айдена] </flash>",
	["76561198287181658"] = '<rainbow=1>[Hauptsturmführer] </rainbow>',
	["76561198803892483"] = '<rainbow=1>[Раб Императора] </rainbow>',
	["76561198225449752"] = '<rainbow=1>[adminhuesos] </rainbow>',
	["76561198086006446"] = ':shield: <rainbow=1>[adminhuesos] </rainbow>',
	["76561198952289814"] = ":heart:<rainbow=1>[FemBoy] </rainbow>",
	["76561198256901202"] = ":heart:<rainbow=1>[FemBoy] </rainbow>",
	["76561198189145034"] = ":heart:<rainbow=1>[FemBoy] </rainbow>",
	["76561199144351466"] = ":star:<rainbow=1>[ВЕЛИКИЙ ВОЖДЬ] </rainbow>",
	--["76561198897628230"] = ":award_star_add:<flash=255,188,0,0>[Главный по хуям] </flash>",
	["76561198376629308"] = ":script_edit:<rainbow=1>[DEVELOPER] </rainbow>",
	["76561199231572195"] = ":script_edit:<rainbow=1>[Разраб Года] </rainbow>",
	["76561198336701519"] = "<rainbow=1>[Militante] </rainbow>",
	["76561199098754455"] = "<rainbow=1>[ЦРБ Любимки] </rainbow>",

	["76561198834615679"] = ":heart:<rainbow=1>[Фурри фембойчик] </rainbow>",

	["76561199226082766"] = "<rainbow=1>[Император Мой Фанат] </rainbow>",

	["76561198363582847"] = "<flash=255,122,248,0>[Куратор Медиа] </flash>",

	["76561198288541766"] = ":fox:<rainbow=1>[Funch Imperator] </rainbow>:fox:",

	--["76561198966614836"] = ':script_edit:<rainbow=1>[Разраб Года] </rainbow>',
}