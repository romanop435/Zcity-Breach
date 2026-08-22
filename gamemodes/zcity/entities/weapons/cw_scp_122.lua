SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "SCP-122"
SWEP.Author = "Spy"
SWEP.Instructions = ""
SWEP.Category = "CW BREACH"
SWEP.Slot = 2
SWEP.SlotPos = 10

-- Модели
SWEP.ViewModel = ""
SWEP.WorldModel = "models/cultist/scp_items/scp122/w_scp122.mdl"
SWEP.WorldModelFake = "models/cultist/scp_items/scp122/v_scp122.mdl"

-- Иконки
SWEP.WepSelectIcon2 = Material("nextoren/gui/new_icons/scp122.png")
SWEP.IconOverride = "nextoren/gui/new_icons/scp122.png"

-- Позиционирование WorldModelFake (v_model)
SWEP.FakePos = Vector(0, 3, 6)
SWEP.FakeAng = Angle(0, 0, 180)
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"

SWEP.FakeBodyGroups = "0"
SWEP.ZoomPos = Vector(0, 0, 0) -- Настройте прицеливание с помощью команды hg_setzoompos 1

-- Звуки для перезарядки (Обычная)
SWEP.FakeReloadSounds = {
	[0.44] = "nextoren/weapons/scp122/gunother/rifle_slideforward.wav", -- 14/30 / 3.15 = 0.148 (но оригинальный тайминг 14/30 = 0.46 сек) - делим 0.46 на 3.15 (длина анимации)
	[0.14] = "nextoren/weapons/scp122/gunother/rifle_clip_out_1.wav",
	[0.61] = "nextoren/weapons/scp122/gunother/rifle_clip_in_1.wav",
	[0.86] = "nextoren/weapons/scp122/gunother/rifle_slideback.wav"
}

-- Звуки для пустой перезарядки
SWEP.FakeEmptyReloadSounds = {
	[0.32] = "nextoren/weapons/scp122/gunother/rifle_slideforward.wav", -- 14/30 / 4.35 = 0.10
	[0.10] = "nextoren/weapons/scp122/gunother/rifle_clip_out_1.wav",
	[0.44] = "nextoren/weapons/scp122/gunother/rifle_clip_in_1.wav",
	[0.72] = "nextoren/weapons/scp122/gunother/rifle_slideback.wav"
}

-- Привязка анимаций из CW2.0 к Homigrad-базе
SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}

SWEP.weaponInvCategory = 1
SWEP.bigNoDrop = true

-- Настройки стрельбы
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.45x39 mm" -- В CW2.0 у него стоит гильза "KK_INS2_545x39"
SWEP.CustomShell = "545x39"

SWEP.punchmul = 1.2
SWEP.punchspeed = 1
SWEP.ShockMultiplier = 3
SWEP.ScrappersSlot = "Primary"

-- Положение дула для эффектов
SWEP.LocalMuzzlePos = Vector(23,0,2.5)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

-- Дамаг и отдача
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 50
SWEP.Primary.Sound = {"nextoren/weapons/scp122/gunfire/rifle_fire_1.wav", 85, 100, 100}
SWEP.SupressedSound = {"nextoren/weapons/scp122/gunfire/rifle_fire_1.wav", 65, 100, 100}
SWEP.Primary.Wait = 60/650 -- 650 RPM как в оригинале
SWEP.ReloadTime = 3.15 -- За основу берем обычную перезарядку

-- Эффекты
SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle2"
SWEP.HoldType = "ar2"

-- Кастомизация TPIK (позиции рук в пространстве)
SWEP.RHandPos = Vector(2, -1, 1)
SWEP.LHandPos = false
SWEP.AimHands = Vector(-2, 0.45, -5.9)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 0.8
SWEP.Penetration = 7
SWEP.WorldPos = Vector(5.666, 0.66, -1.055)
SWEP.WorldAng = Angle(10, 0, 180)
SWEP.UseCustomWorldModel = true

-- Система модулей / аттачментов (стандартная конфигурация под автомат)
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		["mount"] = Vector(0,0,0),
	},
	sight = {
		["empty"] = {
			"empty",
			{ [1] = "null" },
		},
		["mountType"] = {"picatinny","ironsight"},
		["mount"] = {ironsight = Vector(0, 0, 0), picatinny = Vector(0, 0, 0)},
		["removehuy"] = { [1] = "null" }
	},
	grip = {
		["mount"] = Vector(0, 0, 0),
		["mountType"] = "picatinny"
	},
	underbarrel = {
		["mount"] = {["picatinny_small"] = Vector(0, 0, 0),["picatinny"] = Vector(0, 0, 0)},
		["mountAngle"] = {["picatinny_small"] = Angle(0, 0, 0),["picatinny"] = Angle(0, 0, 0)},
		["mountType"] = {"picatinny_small","picatinny"},
		["removehuy"] = {
			["picatinny"] = {},
			["picatinny_small"] = {}
		}
	}
}

SWEP.StartAtt = {}

SWEP.weight = 3

-- Для сброса физического магазина 
SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(3,9.5,-16.5)
SWEP.lmagang2 = Angle(0,0,-90)
SWEP.FakeMagDropBone = 0 -- Номер кости магазина (Нужно указать номер кости из printboneswm)

if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.MagModel = "models/weapons/arccw/c_ud_m16.mdl" -- Измените на вашу модель магазина если есть
	SWEP.FakeReloadEvents = {}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end

SWEP.ShootAnimMul = 3
function SWEP:DrawPost()
end

SWEP.lengthSub = 5
SWEP.holsteredPos = Vector(5, 8, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

--Локал для головы / правой руки
SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
SWEP.LHPos = Vector(15,1,-3.3)
SWEP.LHAng = Angle(-110,-180,0)

--Gun Cam
SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.FakeEjectBrassATT = "2"

-- Скрипт оригинального оружия
local function initialize(self)
	if self:GetClass() != "cw_scp_122" then return end
	self.NotWorthy = {}
end

-- Данная логика из оригинального CW2.0 закомментирована, но вы можете использовать ее, перенастроив под ZCity
-- function SWEP:PrimaryShootPre()
--     -- Для кастомной логики стрельбы ZCity используйте PrimaryShootPre вместо preFire!
-- end