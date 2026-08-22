
SWEP.PrintName = "Сладенький поцелуйчик"
SWEP.Purpose = "Kiss boys! :3"

SWEP.Category = "Boykisser"
SWEP.droppable = false
SWEP.UnDroppable = true

SWEP.Slot = 1; SWEP.SlotPos = 4

SWEP.Spawnable = true; SWEP.AdminOnly = false

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1; SWEP.Primary.DefaultClip = -1; SWEP.Primary.Automatic = true; SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1; SWEP.Secondary.DefaultClip = -1; SWEP.Secondary.Automatic = true; SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

if SERVER then
    util.AddNetworkString("Boykisser_Kiss")
end

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:PrimaryAttack()
    self.Owner:EmitSound("bk_kiss_swep/meow" .. math.random(1, 2) .. ".wav")

    self.Owner:SetVelocity(self.Owner:GetAimVector() * 300)

    local tr = util.TraceLine({
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 200,
        filter = self.Owner,
        mask = MASK_SHOT_HULL
    })

    if SERVER && IsValid(tr.Entity) then
        if tr.Entity:IsPlayer() then
            
            if self.Owner:IsPlayer() then
                net.Start("Boykisser_Kiss")
                net.Send({tr.Entity, self.Owner})
            else
                net.Start("Boykisser_Kiss")
                net.Send(tr.Entity)
            end
            net.Send({tr.Entity, self.Owner})
            
        elseif tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            
            if self.Owner:IsPlayer() then
                net.Start("Boykisser_Kiss")
                net.Send(self.Owner)
            end
           
        end
    end

    self:SetNextPrimaryFire(CurTime() + 1)
end

if CLIENT then
    function bk_kiss()
        if timer.Exists("BoyKissTimer") then
            bk_boy_art:Remove()
            timer.Remove("BoyKissTimer")
            timer.Remove("BoyKissImageTimer")
        end

        local i = 255
        bk_boy_art = vgui.Create("DImage")

        bk_boy_art:SetPos(0, 0); bk_boy_art:SetSize(ScrW(), ScrH())
        bk_boy_art:SetImage("kissing_boys/kiss" .. math.random(1, 13) .. ".png")

        timer.Create("BoyKissImageTimer", 0.019, 51, function()
            if IsValid(bk_boy_art) then
                bk_boy_art:SetImageColor(Color(255, 255, 255, i))
                i = i - 5
            else
                timer.Remove("BoyKissImageTimer")
            end
        end)

        timer.Create("BoyKissTimer", 1, 1, function()
            bk_boy_art:Remove()
        end)
    end

    net.Receive("Boykisser_Kiss", function()
        surface.PlaySound("bk_kiss_swep/kiss" .. math.random(1, 4) .. ".wav")
        
        bk_kiss()
    end)

    SWEP.WepSelectIcon = Material("kissing_boys/bk_soft_kiss_icon.png")
    function SWEP:DrawWeaponSelection( x, y, w, h, a )
	    surface.SetDrawColor( 255, 255, 255, a )
	    surface.SetMaterial( self.WepSelectIcon )

	    local size = math.min( w, h )
	    surface.DrawTexturedRect( x + w / 2 - size / 2, y, size, size )
    end
end

function SWEP:SecondaryAttack()
    if self.Owner:IsPlayer() then
		if ( self.LoopSound ) then
			self.LoopSound:ChangeVolume( 1, 0.1 )
		else
			self.LoopSound = CreateSound( self.Owner, Sound( "bk_kiss_swep/chipichipi.wav" ) )
			if ( self.LoopSound ) then self.LoopSound:Play() end
		end
    end
end

function SWEP:Think()
	if ( self.Owner:IsPlayer() && ( self.Owner:KeyReleased( IN_ATTACK ) || !self.Owner:KeyDown( IN_ATTACK ) ) ) then
		if ( self.LoopSound ) then self.LoopSound:ChangeVolume( 0, 0.1 ) end
	end
end