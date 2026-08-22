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
	if self:GetPos() == Vector(   4065.603515625  ,       3120.9294433594 ,       61.348945617676 ) then
		self:SetItem("079")
	end
	if self:GetPos() == Vector(   8798.9814453125 ,       -1617.6235351562        ,       59.760612487793 ) then
		
	end
	end)
    end
end



ENT.scp_list = {
    ["939"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/939.png"),
		["Name"] = "SCP - 939",
        ["Class"] = "KETER",
		["AL"] = 4,
	},
	["049"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/049.png"),
		["Name"] = "SCP - 049",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["062DE"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/062de.png"),
		["Name"] = "SCP - 062 - De",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["062FR"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/062fr.png"),
		["Name"] = "SCP - 062 - Fr",
        ["Class"] = "KETER",
		["AL"] = 4,
	},
	["076"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/076.png"),
		["Name"] = "SCP - 076 - II",
        ["Class"] = "KETER",
		["AL"] = 4,
	},
	["082"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/082.png"),
		["Name"] = "SCP - 082",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["106"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/106.png"),
		["Name"] = "SCP - 106",
        ["Class"] = "KETER",
		["AL"] = 5,
	},
	["457"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/457.png"),
		["Name"] = "SCP - 457",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["542"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/542.png"),
		["Name"] = "SCP - 542",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["682"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/682.png"),
		["Name"] = "SCP - 682",
        ["Class"] = "KETER",
		["AL"] = 5,
	},
	["811"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/811.png"),
		["Name"] = "SCP - 811",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["912"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/912.png"),
		["Name"] = "SCP - 912",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
	["973"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/973.png"),
		["Name"] = "SCP - 973",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["999"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/999.png"),
		["Name"] = "SCP - 999",
        ["Class"] = "SAFE",
		["AL"] = 2,
	},
	["1903"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/1903.png"),
		["Name"] = "SCP - 1903",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["2012"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/2012.png"),
		["Name"] = "SCP - 2012",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["096"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/2012.png"),
		["Name"] = "SCP - 096",
        ["Class"] = "EUCLID",
		["AL"] = 3,
	},
	["638"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/638.png"),
		["Name"] = "SCP - 638",
        ["Class"] = "KETER",
		["AL"] = 4,
	},
	["079"] = {
		["Icon"] = Material("nextoren/gui/new_icons/scp/079.png"),
		["Name"] = "SCP - 079",
        ["Class"] = "EUCLID",
		["AL"] = 2,
	},
}