ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Указатель"
ENT.Category = "SCP"
ENT.Spawnable = true
ENT.Editable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true
function ENT:SetupDataTables()

  self:NetworkVar( "String", 0, "Item" )
  self:NetworkVar( "Bool", 0, "Status" )
  

end

function ENT:Initialize()
    if SERVER then
        
    self:SetModel("models/imperator/labelholder.mdl")
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )
    self:SetItem("нил")
    self:SetStatus(true)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(0000)
    end

	timer.Simple( 12, function()
		if self:GetPos() == Vector(   8798.9814453125 ,       -1617.6235351562        ,       59.760612487793 ) then
			self:SetItem("weapon_scp_009")
		end
		if self:GetPos() == Vector(   8666.9609375    ,       -1950.7125244141        ,       60.925457000732 ) then
			self:SetItem("038")
		end
		if self:GetPos() == Vector(   9157.125        ,       -4894.7094726562        ,       59.424030303955 ) then
			self:SetItem("914")
		end
	end)
    end
end



ENT.scp_list = {
    ["weapon_scp_500"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/500.png"),
		["Name"] = "SCP - 500",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_scp_215"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/215.png"),
		["Name"] = "SCP - 215",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_scp_1499"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/1499.png"),
		["Name"] = "SCP - 1499",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_drink_dado_fire"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/scp3238_fire.png"),
		["Name"] = "SCP - 3238-F",
        ["Class"] = "SAFE",
		["AL"] = 3,
	},
    ["item_drink_dado_radioactive"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/scp3238_rad.png"),
		["Name"] = "SCP - 3238-R",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_scp_1033"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/1033.png"),
		["Name"] = "SCP - 1033-RU",
        ["Class"] = "SAFE",
		["AL"] = 3,
	},
    ["weapon_scp_427"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/427.png"),
		["Name"] = "SCP - 427",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_scp_207"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/207.png"),
		["Name"] = "SCP - 207",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["item_scp_268"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/268.png"),
		["Name"] = "SCP - 268",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
    ["cw_scp_122"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp122.png"),
		["Name"] = "SCP - 127",
        ["Class"] = "SAFE",
		["AL"] = 4,
	},
    ["item_scp_005"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/005.png"),
		["Name"] = "SCP - 005",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
    ["kasanov_ar_iso"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/2806.png"),
		["Name"] = "SCP - 2806",
        ["Class"] = "SAFE",
		["AL"] = 4,
	},
	["weapon_scp_009"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/009.png"),
		["Name"] = "SCP - 009",
        ["Class"] = "EUCLID",
		["AL"] = 5,
	},
	["038"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/038.png"),
		["Name"] = "SCP - 038",
        ["Class"] = "SAFE",
		["AL"] = 4,
	},
	["914"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/914.png"),
		["Name"] = "SCP - 914",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
}