AddCSLuaFile()

SWEP.PrintName		= "SCP Spawn Creator"
SWEP.Author 		= "Imperator"
SWEP.Purpose 		= "To create loot/player positions and save them to data"
SWEP.Instructions	= "ЛКМ - Спавн Лута\nПКМ - Спавн Игрока (под ногами)\nRELOAD - Взять вектор энтити\nUSE + RELOAD - Очистить пропы"
SWEP.Category 		= "Breach"

SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ShowViewModel  = false
SWEP.ShowWorldModel = false
SWEP.UseHands 		= true
SWEP.droppable		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Automatic	= false

SWEP.LootPositions = 0
SWEP.PlayerPositions = 0
SWEP.PlacedProps = {}

local function Notify(msg)
	if RXSENDNotify then
		RXSENDNotify(msg)
	elseif chat and chat.AddText then
		chat.AddText(Color(0, 255, 0), "[Спавнер] ", Color(255, 255, 255), msg)
	else
		print(msg)
	end
end

local function SaveVectorToFile(pos_type, pos)
	if not CLIENT then return end
	
	local x, y, z = math.Round(pos.x, 2), math.Round(pos.y, 2), math.Round(pos.z, 2)
	local str = string.format("Vector(%s, %s, %s),\n", x, y, z)
	
	local filename = "ksaikok_" .. pos_type .. "_" .. game.GetMap() .. ".txt"
	
	file.Append(filename, str)
	Notify("Сохранено в " .. filename .. ": " .. str)
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	return true
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.PlacedProps = {}
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	self:SetNextPrimaryFire(CurTime() + 0.3)

	if CLIENT then
		local tr = util.TraceLine({
			start = LocalPlayer():EyePos(),
			endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 10000,
			mask = MASK_ALL,
			filter = LocalPlayer()
		})

		local spawnPos = tr.HitPos + Vector(0, 0, 10)

		local prop = ClientsideModel("models/hunter/plates/plate.mdl")
		prop:SetPos(spawnPos)
		prop:SetColor(Color(255, 255, 0))
		table.insert(self.PlacedProps, prop)

		self.LootPositions = self.LootPositions + 1
		SaveVectorToFile("loot", spawnPos)
		
		surface.PlaySound("garrysmod/save_load1.wav")
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	self:SetNextSecondaryFire(CurTime() + 0.3)

	if CLIENT then
		local spawnPos = LocalPlayer():GetPos()

		local prop = ClientsideModel("models/editor/playerstart.mdl")
		prop:SetPos(spawnPos)
		prop:SetAngles(Angle(0, LocalPlayer():EyeAngles().y, 0)) -- Смотрим в ту же сторону
		table.insert(self.PlacedProps, prop)

		self.PlayerPositions = self.PlayerPositions + 1
		SaveVectorToFile("players", spawnPos)
		
		surface.PlaySound("garrysmod/save_load2.wav")
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end 

	if CLIENT then
		if LocalPlayer():KeyDown(IN_USE) then
			for _, prop in ipairs(self.PlacedProps) do
				if IsValid(prop) then prop:Remove() end
			end
			self.PlacedProps = {}
			self.LootPositions = 0
			self.PlayerPositions = 0
			Notify("Все расставленные пропы очищены. (В файлах они остались)")
			surface.PlaySound("buttons/button10.wav")
			return
		end

		local tr = util.TraceLine({
			start = LocalPlayer():GetShootPos(),
			endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 10000,
			filter = LocalPlayer()
		})

		if IsValid(tr.Entity) and not tr.Entity:IsWorld() then
			local pos = tr.Entity:GetPos()
			local x, y, z = math.Round(pos.x, 2), math.Round(pos.y, 2), math.Round(pos.z, 2)
			Notify(string.format("Энтити вектор: Vector(%s, %s, %s)", x, y, z))
		end
	end
end

function SWEP:Think()
	if CLIENT then
		if not IsValid(self.GhostProp) then
			self.GhostProp = ClientsideModel("models/hunter/plates/plate.mdl")
			self.GhostProp:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self.GhostProp:SetColor(Color(0, 255, 0, 150))
			self.GhostProp:SetMaterial("models/wireframe")
		end

		local tr = util.TraceLine({
			start = LocalPlayer():EyePos(),
			endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 10000,
			mask = MASK_ALL,
			filter = LocalPlayer()
		})

		if tr.Hit then
			self.GhostProp:SetPos(tr.HitPos + Vector(0, 0, 10))
		end
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.GhostProp) then
		self.GhostProp:Remove()
	end
	return true
end

function SWEP:OnRemove()
	if CLIENT and IsValid(self.GhostProp) then
		self.GhostProp:Remove()
	end
end

function SWEP:DrawHUD()
end