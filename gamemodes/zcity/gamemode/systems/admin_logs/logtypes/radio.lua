local LOGDATA = {}

LOGDATA.name = "RADIO"
LOGDATA.color = Color(218, 165, 32)
LOGDATA.no_deepinfo = true
LOGDATA.no_snapshot = true

LOGDATA.supa_colors = {
	["channel"] = Color(89, 160, 232),
}

function LOGDATA:GetText()
	return "sender [ channel ] : message"
end

LOGDATA.Filters = {
	["sender"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["channel"] = {
		name = "Канал",
		type = ShLog_FILTERTYPE_TEXT
	},
	["message"] = {
		name = "Сообщение",
		type = ShLog_FILTERTYPE_TEXT
	},
}

-- НЕ УДАЛЯТЬ --
return LOGDATA