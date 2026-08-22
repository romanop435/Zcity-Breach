SWEP.PrintName = "Снежек"
SWEP.Author = "Zerochain"
SWEP.Instructions = "LeftClick Throw Snoball, RightClick Pickup snow"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.ViewModelFOV = 45
SWEP.ViewModel = "models/zerochain/props_christmas/snowballswep/zck_c_snowballswep.mdl"
SWEP.WorldModel =  "models/zerochain/props_christmas/snowballswep/zck_w_snowballswep.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "grenade"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "Zeros Snowball Swep"
SWEP.DrawAmmo = false
SWEP.base = "weapon_base"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.4
SWEP.UseHands = true
SWEP.DisableDuplicator = true
SWEP.droppable				= false
SWEP.UnDroppable = true

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/new_icons/snowbal.png" )

end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "SnowballCount")

	if SERVER then
		self:SetSnowballCount(5)
	end
end
