AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Model = "models/vinrax/scp294/scp294_lg.mdl"

util.AddNetworkString("send_drink")
util.AddNetworkString("create_294_menu")

ENT.Drinks = {}

ENT.Drinks["water"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		
		org.hungry = math.max(0, org.hungry - 15)
		org.satiety = math.min(100, org.satiety + 15)
		
		ply:BrTip(0, "Освежает. То, что нужно.", Color(255, 255, 255), "", Color(255, 255, 255))
		ply:EmitSound("scp294_water")
	end,
	sip = 5,
	vendingsound = 1,
}

ENT.Drinks["fanta"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		
		org.hungry = math.max(0, org.hungry - 25)
		org.satiety = math.min(100, org.satiety + 25)
		org.adrenalineAdd = org.adrenalineAdd + 0.1 
		
		ply:BrTip(0, "Сладкая газировка. Вкусно.", Color(255, 255, 255), "", Color(255, 255, 255))
		ply:EmitSound("scp294_soda")
	end,
	color = Color(255, 150, 0),
	sip = 4,
	vendingsound = 1,
}
ENT.Drinks["pepsi"] = ENT.Drinks["fanta"]
ENT.Drinks["cola"] = ENT.Drinks["fanta"]
ENT.Drinks["cocacola"] = ENT.Drinks["fanta"]
ENT.Drinks["sprite"] = ENT.Drinks["fanta"]

ENT.Drinks["milk"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		org.painkiller = org.painkiller + 0.5 
		org.hungry = math.max(0, org.hungry - 30)
		org.satiety = math.min(100, org.satiety + 30)
	end,
	color = Color(255, 255, 255),
	sip = 3,
	vendingsound = 1,
}

ENT.Drinks["pee"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		
		org.wantToVomit = (org.wantToVomit or 0) + 1.5 
		org.painadd = org.painadd + 5
		
		ply:BrTip(0, "Боже, какая мерзость...", Color(255, 100, 100), "", Color(255, 255, 255))
		ply:EmitSound("scp294_disgust")
	end,
	color = Color(255, 255, 0),
	sip = 6,
	vendingsound = 1,
}

ENT.Drinks["piss"] = ENT.Drinks["pee"]
ENT.Drinks["sperm"] = ENT.Drinks["pee"]
ENT.Drinks["sperm"].color = Color(255, 255, 255)
ENT.Drinks["cum"] = ENT.Drinks["sperm"]
ENT.Drinks["semen"] = ENT.Drinks["sperm"]

ENT.Drinks["turd"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		
		org.wantToVomit = (org.wantToVomit or 0) + 3 
		org.painadd = org.painadd + 20
		org.shock = org.shock + 15
		org.internalBleed = org.internalBleed + 5
		
		ply:BrTip(0, "Я сейчас выблюю свои кишки...", Color(255, 0, 0), "", Color(255, 255, 255))
		ply:EmitSound("scp294_shit")
	end,
	color = Color(105, 55, 15),
	sip = 2,
	vendingsound = 1,
}
ENT.Drinks["shit"] = ENT.Drinks["turd"]
ENT.Drinks["poop"] = ENT.Drinks["turd"]
ENT.Drinks["poo"] = ENT.Drinks["turd"]

ENT.Drinks["suicide"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if not org then return end
		
		org.heartstop = true
		org.brain = 1
		
		ply:BrTip(0, "Темнота...", Color(100, 100, 100), "", Color(255, 255, 255))
		ply:EmitSound("scp294_suicide")
	end,
	color = Color(25, 25, 25),
	sip = 1,
	vendingsound = 1,
}

ENT.Drinks["tnt"] = {
	effect = function(ply, ent)
		local current_pos = ply:GetPos() + Vector(0, 0, 30)
		
		local dmg_info = DamageInfo()
		dmg_info:SetDamage(2000)
		dmg_info:SetDamageType(DMG_BLAST)
		dmg_info:SetAttacker(ply)
		dmg_info:SetInflictor(ent)
		dmg_info:SetDamageForce(Vector(0, 0, 100))

		util.BlastDamageInfo(dmg_info, current_pos, 400)
		
		if hg and hg.ExplosionEffect then hg.ExplosionEffect(current_pos, 1500, 250) end
		
		net.Start("hg_booom")
			net.WriteVector(current_pos)
			net.WriteString("Fire")
		net.Broadcast()
		
		ply:Kill()
	end,
	color = Color(150, 50, 0),
	sip = 1,
	vendingsound = 1,
}

ENT.Drinks["zombie"] = {
	effect = function(ply, ent)
		local org = ply.organism
		local ran = math.random(10, 100)

		if ran <= 15 and ply.SetupZombie then
			ply:SetupZombie()
		else
			if org then
				org.internalBleed = org.internalBleed + 30
				org.painadd = org.painadd + 150
				org.shock = org.shock + 100
				org.blood = math.max(1000, org.blood - 1500)
				
				ply:BrTip(0, "МОИ ВЕНЫ ГОРЯТ! ЧТО ЭТО?!", Color(255, 0, 0), "", Color(255, 255, 255))
				ply:EmitSound("scp294_zombie_fail")
				
				if hg and hg.Fake then hg.Fake(ply) end
			end
		end
	end,
	color = Color(100, 150, 50),
	sip = 2,
	vendingsound = 1,
}

ENT.Drinks["scp009"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then
			org.painadd = org.painadd + 50
			org.shock = org.shock + 30
			
			ply:BrTip(0, "Как же... холодно...", Color(150, 200, 255), "", Color(255, 255, 255))
			ply:EmitSound("scp294_009_1")
		end

		timer.Simple(15, function()
			if IsValid(ply) and ply:GTeam() ~= TEAM_SPEC then
				if ply.Make009Statue then ply:Make009Statue() else ply:Kill() end
			end
		end)
	end,
	color = Color(255, 0, 0),
	sip = 4,
	vendingsound = 2,
}
ENT.Drinks["009"] = ENT.Drinks["scp009"]

ENT.Drinks["scp500"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then
			org.blood = 5000
			org.bleed = 0
			org.internalBleed = 0
			org.pain = 0
			org.painadd = 0
			org.avgpain = 0
			org.shock = 0
			org.adrenaline = 0
			org.wounds = {}
			org.arterialwounds = {}
			ply:SetNetVar("wounds", {})
			ply:SetNetVar("arterialwounds", {})
			
			org.lleg = 0; org.rleg = 0; org.larm = 0; org.rarm = 0
			org.spine1 = 0; org.spine2 = 0; org.spine3 = 0
			org.pelvis = 0; org.chest = 0; org.skull = 0; org.jaw = 0
			org.llegdislocation = false; org.rlegdislocation = false
			org.larmdislocation = false; org.rarmdislocation = false
			org.jawdislocation = false
			
			ply.fullsend = true
		end

		ply:SetHealth(ply:GetMaxHealth())
		ply:BrTip(0, "Я чувствую себя просто превосходно.", Color(0, 255, 0), "", Color(255, 255, 255))
		ply:EmitSound("scp294_scp500")
	end,
	color = Color(255, 50, 50),
	sip = 1,
	vendingsound = 1,
}
ENT.Drinks["500"] = ENT.Drinks["scp500"]

ENT.Drinks["bunny"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then
			org.adrenalineAdd = org.adrenalineAdd + 5
			org.analgesia = org.analgesia + 2
			org.stamina.max = 500
			org.stamina[1] = 500
		end
		
		if not ply.TempValues.bunnydrank then
			ply:SetJumpPower(ply:GetJumpPower() + 175)
		end
		ply.TempValues.bunnydrank = true
		
		ply:BrTip(0, "ЭНЕРГИЯ ПЕРЕПОЛНЯЕТ МЕНЯ!", Color(255, 255, 0), "", Color(255, 255, 255))
		ply:EmitSound("scp294_bunny")
	end,
	color = Color(215, 215, 215),
	sip = 5,
	vendingsound = 1
}

ENT.Drinks["sex"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then
			org.stamina[1] = 5
			org.pulse = 160
			org.heartbeat = 160
		end
		
		ply:EmitSound("vo/npc/"..(ThatPlyIsFemale and ThatPlyIsFemale(ply) and "female" or "male").."01/moan0"..math.random(1,5)..".wav", 75)
		ply:BrTip(0, "Охх...", Color(255, 100, 200), "", Color(255, 255, 255))
		ply:EmitSound("scp294_sex")
	end,
	color = Color(255, 192, 203),
	sip = 5,
	vendingsound = 3,
}

ENT.Drinks["cyox"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then org.adrenalineAdd = org.adrenalineAdd + 2 end
		
		ply:BrTip(0, "Cyox Power!", Color(255, 255, 255), "", Color(255, 255, 255))
		ply:EmitSound("scp294_dev")
	end,
	color = Color(0, 255, 0),
	sip = 2,
	vendingsound = 2,
}
ENT.Drinks["shaky"] = ENT.Drinks["cyox"]
ENT.Drinks["uracos"] = ENT.Drinks["cyox"]
ENT.Drinks["uracosvereches"] = ENT.Drinks["cyox"]

ENT.Drinks["rxsend"] = {
	effect = function(ply, ent)
		local org = ply.organism
		if org then org.adrenalineAdd = org.adrenalineAdd + 2 end
		
		ply:BrTip(0, "Rxsend Power!", Color(255, 255, 255), "", Color(255, 255, 255))
		ply:EmitSound("scp294_dev2")
	end,
	color = Color(0, 255, 0),
	sip = 1,
	vendingsound = 2,
}

ENT.Drinks["clone"] = {
	effect = function(ply, ent)
		local rag = ents.Create("prop_ragdoll")
		rag:SetModel(ply:GetModel())
		rag:SetPos(ply:GetPos())
		rag:SetAngles(ply:GetAngles())
		rag:Spawn()
		
		for i = 0, rag:GetPhysicsObjectCount() - 1 do
			local phys = rag:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				phys:EnableGravity(false)
				phys:SetVelocity(Vector(0, 0, 150))
			end
		end
		
		SafeRemoveEntityDelayed(rag, 10)
		
		ply:BrTip(0, "Твоя копия улетела в лучший мир.", Color(255, 255, 255), "", Color(255, 255, 255))
		ply:EmitSound("scp294_clone")
	end,
	color = Color(100, 95, 95),
	sip = 5,
	vendingsound = 1
}

ENT.DispenseCD = {
	[1] = 2.5,
	[2] = 6.2,
	[3] = 6
}

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.idlesound = CreateSound( self, "nextoren/others/vending_machine_sounds/machine_idle.wav" )
  	self.idlesound:Play()

	local phy = self:GetPhysicsObject()
	if IsValid(phy) then phy:EnableMotion(false) end

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
	if activator:GTeam() ~= TEAM_SPEC and activator:GTeam() ~= TEAM_SCP and activator:GetEyeTrace().Entity == self then
		net.Start("create_294_menu")
		net.Send(activator)
	end
end

function ENT:OnRemove()
	if self.idlesound then self.idlesound:Stop() end
end

function ENT:MakeDrink(drink)
	if self.MakingDrink then return end

	for i, v in pairs(ents.FindByClass("item_drink_294")) do
		if not IsValid(v:GetOwner()) then v:Remove() end
	end

	self.MakingDrink = true

	timer.Create("create_drink_294", self.DispenseCD[self.Drinks[drink].vendingsound or 1], 1, function()
		if not IsValid(self) then return end
		self.MakingDrink = false

		local entA = self:GetAngles()
		local pos = self:GetPos() + entA:Right()*9 + entA:Up()*32 + entA:Forward()*13

		local drink_itself = ents.Create("item_drink_294")
		drink_itself.SCP294 = self
		drink_itself.effect = self.Drinks[drink].effect
		drink_itself.drink = drink

		local col = self.Drinks[drink].color or Color(255, 255, 255)
		drink_itself.sip = self.Drinks[drink].sip or 5

		drink_itself:SetPos(pos)
		drink_itself:Spawn()

		drink_itself:SetNWInt("r", col.r)
		drink_itself:SetNWInt("g", col.g)
		drink_itself:SetNWInt("b", col.b)
	end)

	if self.Drinks[drink].vendingsound then
		self:EmitSound("scp294/dispense"..self.Drinks[drink].vendingsound..".ogg")
	else
		self:EmitSound("scp294/dispense1.ogg")
	end
end

net.Receive("send_drink", function(len, ply)
	local drinkname = net.ReadString()
	local scp294 = net.ReadEntity()

	if not IsValid(scp294) or scp294:GetClass() ~= "ent_scp_294" then return end
	if ply:GetEyeTrace().Entity ~= scp294 then return end

	if not scp294.Drinks[drinkname] then
		ply:BrTip(0, "OUT OF RANGE", Color(255, 0, 0), "", Color(255, 255, 255))
		ply:EmitSound("scp294_out")
		return
	end

	scp294:MakeDrink(drinkname)
end)