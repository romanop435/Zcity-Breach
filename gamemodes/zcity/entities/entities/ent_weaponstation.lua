AddCSLuaFile()

ENT.Base        = "base_gmodentity"
ENT.Category    = "Homigrad"
ENT.PrintName   = "Workbench"
ENT.Spawnable   = true

ENT.Model       = Model( "models/cult_props/entity/workbench.mdl" )
ENT.Angles      = Angle( 0, 180, 0 )
ENT.Pos         = {
  Vector( 7520.312012, -4175.750000, 0.031254 ),
  Vector( -1765.097412, 1982.283203, 0.031254 )
}

function ENT:Initialize()
	self:SetModel( self.Model )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )

	if ( self.n_Type ) then
		self:SetPos( self.Pos[ self.n_Type ] )
		self:SetAngles( self.Angles * ( -1 + self.n_Type ) )
	end
end

if SERVER then
	util.AddNetworkString( "WeaponStation_RedactMessage" )
	util.AddNetworkString( "HG_Workbench_Toggle" )

	ENT.AllSurvivors = {}

	function ENT:Think()
		if ( #self.AllSurvivors != 0 ) then
			local allsurvivors = self.AllSurvivors
			for i = #allsurvivors, 1, -1 do
				local survivor = allsurvivors[ i ]
				if ( survivor and survivor:IsValid() and (survivor:GetPos():DistToSqr( self:GetPos() ) > 15000 or not survivor:Alive()) ) then
					net.Start( "WeaponStation_RedactMessage" )
						net.WriteBool( false )
					net.Send( survivor )

					table.remove( self.AllSurvivors, i )
					survivor.CanAttach = nil
					survivor:SetNW2Bool("Breach:CanAttach", false)
				end
			end
		end
		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:Use( survivor )
		if ( survivor.CanAttach ) then return end
		if ( survivor:GetPos():DistToSqr( self:GetPos() ) > 15000 ) then return end

		net.Start( "WeaponStation_RedactMessage" )
			net.WriteBool( true )
		net.Send( survivor )

		survivor.CanAttach = true
		survivor:SetNW2Bool("Breach:CanAttach", true)

		self.AllSurvivors[ #self.AllSurvivors + 1 ] = survivor
	end

	function ENT:OnRemove()
		for i = 1, #self.AllSurvivors do
			local survivor = self.AllSurvivors[ i ]
			if ( survivor and survivor:IsValid() ) then
				survivor.CanAttach = nil
				survivor:SetNW2Bool("Breach:CanAttach", false)
			end
		end
	end


	net.Receive("HG_Workbench_Toggle", function(len, ply)
		if not ply:GetNW2Bool("Breach:CanAttach") then return end
		
		if (ply.HG_NextAttachTime or 0) > CurTime() then return end
		ply.HG_NextAttachTime = CurTime() + 0.2
		
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not ishgweapon(wep) then return end
		if not wep.attachments then return end
		
		local attName = net.ReadString()

		if attName == "supressor6" or string.find(attName, "laser") then return end
		
		local placement
		for plc, tbl in pairs(hg.attachments) do
			if tbl[attName] then
				placement = tbl[attName][1] or plc
				break
			end
		end
		
		if not placement then return end
		if not wep.availableAttachments[placement] then return end
		
		local isEquipped = wep.attachments[placement] and wep.attachments[placement][1] == attName
		
		if isEquipped then
			local emptyIndex
			for n, atta in pairs(wep.availableAttachments[placement]) do
				if istable(atta) and atta[1] == "empty" then emptyIndex = n break end
			end
			wep.attachments[placement] = emptyIndex and wep.availableAttachments[placement][emptyIndex] or {}
		else
			local targetIndex
			for n, atta in pairs(wep.availableAttachments[placement]) do
				if istable(atta) and atta[1] == attName then targetIndex = n break end
			end
			
			if targetIndex then
				wep.attachments[placement] = wep.availableAttachments[placement][targetIndex]
			else
				wep.attachments[placement] = {attName, {}}
			end
		end
		
		wep:AttachAnim()
		wep:SyncAtts()
		wep:EmitSound("arc9_eft_shared/weap_ar_pickup.ogg", 60)
	end)
end

if CLIENT then

	
	local UI_WIDTH  = 2000 
	local UI_HEIGHT = 1200 
	local UI_SCALE  = 0.02 

	local UI_OFFSET_FORWARD = -16.9 
	local UI_OFFSET_RIGHT   = -10.5 
	local UI_OFFSET_UP      = 67    

	local UI_ANGLE_PITCH = 180 
	local UI_ANGLE_YAW   = 180 
	local UI_ANGLE_ROLL  = 0   


	surface.CreateFont("Workbench_Title", { font = "Hitmarker Normal", size = 64, weight = 800, extended = true })
	surface.CreateFont("Workbench_Category", { font = "Hitmarker Normal", size = 42, weight = 600, extended = true })
	surface.CreateFont("Workbench_Item", { font = "Hitmarker Normal", size = 32, weight = 500, extended = true })
	surface.CreateFont("Workbench_Item_Large", { font = "Hitmarker Normal", size = 42, weight = 700, extended = true })
	surface.CreateFont("Workbench_Small", { font = "Hitmarker Normal", size = 24, weight = 600, extended = true })

	local rust_bg       = Color(18, 16, 15, 255)
	local rust_panel    = Color(30, 28, 25, 255)
	local rust_outline  = Color(255, 255, 255, 10)
	local rust_green    = Color(112, 126, 73)
	local rust_yellow   = Color(218, 165, 32)
	local rust_text     = Color(230, 230, 230)
	local rust_dim      = Color(140, 140, 140)

	net.Receive( "WeaponStation_RedactMessage", function()
	end )

	local function GetScreenData(ent)
		if not IsValid(ent) then return Vector(0,0,0), Angle(0,0,0) end
		
		local pos = ent:GetPos()
		local fwd = ent:GetForward()
		local rgt = ent:GetRight()
		local up = ent:GetUp()
		
		local planePos = pos + (fwd * UI_OFFSET_FORWARD) + (rgt * UI_OFFSET_RIGHT) + (up * UI_OFFSET_UP)
		local planeAng = ent:GetAngles()
		
		planeAng:RotateAroundAxis(planeAng:Up(), 90)
		planeAng:RotateAroundAxis(planeAng:Right(), -90)
		planeAng:RotateAroundAxis(planeAng:Up(), -90)
		
		planeAng:RotateAroundAxis(planeAng:Right(), UI_ANGLE_PITCH)
		planeAng:RotateAroundAxis(planeAng:Up(), UI_ANGLE_YAW)
		planeAng:RotateAroundAxis(planeAng:Forward(), UI_ANGLE_ROLL)
		
		return planePos, planeAng
	end

	local function GetPanelAbsolutePos(pnl, rootPnl)
		local x, y = 0, 0
		while IsValid(pnl) and pnl ~= rootPnl do
			local px, py = pnl:GetPos()
			x = x + px
			y = y + py
			pnl = pnl:GetParent()
		end
		return x, y
	end

local HG_WorkbenchUI = nil

	local function CreateWorkbenchUI(ent)
		if IsValid(HG_WorkbenchUI) then HG_WorkbenchUI:Remove() end
		
		HG_WorkbenchUI = vgui.Create("DPanel")
		HG_WorkbenchUI:SetSize(UI_WIDTH, UI_HEIGHT)
		HG_WorkbenchUI:SetPaintedManually(true)
		
		HG_WorkbenchUI:SetMouseInputEnabled(false)
		HG_WorkbenchUI:SetKeyboardInputEnabled(false)
		
		HG_WorkbenchUI.ActiveWepClass = ""
		HG_WorkbenchUI.TargetEntity = ent
		HG_WorkbenchUI.CursorX = nil
		HG_WorkbenchUI.CursorY = nil
		HG_WorkbenchUI.IsPressedE = false 
		
		function HG_WorkbenchUI:Paint(w, h)
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, w, h, 2)

			draw.SimpleText("СТАНЦИЯ МОДИФИКАЦИИ ВООРУЖЕНИЯ", "Workbench_Title", 40, 30, color_white, TEXT_ALIGN_LEFT)
			
			surface.SetDrawColor(rust_yellow)
			surface.DrawRect(40, 100, w - 80, 2)
			
			local ply = LocalPlayer()
			if not ply:GetNW2Bool("Breach:CanAttach") then
				draw.SimpleText("ОЖИДАНИЕ ОПЕРАТОРА...", "Workbench_Title", w/2, h/2 - 20, rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("ПОДОЙДИТЕ БЛИЖЕ И НАЖМИТЕ [E]", "Workbench_Category", w/2, h/2 + 40, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				return
			end
			
			local wep = ply:GetActiveWeapon()
			if not IsValid(wep) or not ishgweapon(wep) then
				draw.SimpleText("ОРУЖИЕ НЕ ОБНАРУЖЕНО", "Workbench_Title", w/2, h/2 - 20, Color(188, 64, 43), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("ВОЗЬМИТЕ СОВМЕСТИМОЕ ОРУЖИЕ В РУКИ", "Workbench_Category", w/2, h/2 + 40, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				return
			end

			draw.SimpleText("НАВЕДИТЕСЬ [ ПРИЦЕЛ ]   |   УСТАНОВИТЬ/СНЯТЬ [ E ]", "Workbench_Small", w - 40, 60, rust_yellow, TEXT_ALIGN_RIGHT)
		end
		
		function HG_WorkbenchUI:Think()
			if not LocalPlayer():KeyDown(IN_USE) then
				self.IsPressedE = false
			end

			local ply = LocalPlayer()
			if not ply:GetNW2Bool("Breach:CanAttach") then 
				if self.ActiveWepClass ~= "" then
					self:Clear()
					self.ActiveWepClass = ""
				end
				return 
			end
			
			local wep = ply:GetActiveWeapon()
			if not IsValid(wep) or not ishgweapon(wep) then 
				if self.ActiveWepClass ~= "" then
					self:Clear()
					self.ActiveWepClass = ""
				end
				return 
			end
			
			if self.ActiveWepClass ~= wep:GetClass() then
				self.ActiveWepClass = wep:GetClass()
				self:Rebuild(wep)
			end
		end
		
		function HG_WorkbenchUI:Rebuild(wep)
			self:Clear()
			
			local scroll = vgui.Create("DScrollPanel", self)
			scroll:SetPos(40, 130)
			scroll:SetSize(UI_WIDTH - 80, UI_HEIGHT - 160)
			
			local sbar = scroll:GetVBar()
			sbar:SetWide(8)
			function sbar:Paint(w, h)
				surface.SetDrawColor(10, 10, 10, 255)
				surface.DrawRect(0, 0, w, h)
			end
			function sbar.btnUp:Paint() end
			function sbar.btnDown:Paint() end
			function sbar.btnGrip:Paint(w, h)
				surface.SetDrawColor(140, 140, 140, 255)
				surface.DrawRect(0, 0, w, h)
			end
			
			for placement, globalAtts in pairs(hg.attachments or {}) do
				if not wep.availableAttachments or not wep.availableAttachments[placement] then continue end
				
				local wepPlacementData = wep.availableAttachments[placement]
				local wepMount = wepPlacementData.mountType
				
				local validAtts = {}
				for attName, attData in pairs(globalAtts) do
					if attName == "empty" then continue end
					if type(attData) ~= "table" then continue end
					
					if attName == "supressor6" or string.find(attName, "laser") then continue end
					
					local isExplicit = false
					for n, atta in pairs(wepPlacementData) do
						if istable(atta) and atta[1] == attName then
							isExplicit = true
							break
						end
					end
					
					local attMount = attData.mountType
					local isMountMatch = false
					if wepMount and attMount then
						if istable(wepMount) then
							isMountMatch = table.HasValue(wepMount, attMount)
						else
							isMountMatch = (wepMount == attMount)
						end
					end
					
					if isExplicit or isMountMatch then
						table.insert(validAtts, attName)
					end
				end
				
				if #validAtts == 0 then continue end
				
				local catLabel = scroll:Add("DLabel")
				catLabel:Dock(TOP)
				catLabel:SetText(string.upper(placement))
				catLabel:SetFont("Workbench_Category")
				catLabel:SetTextColor(rust_dim)
				catLabel:SizeToContents()
				catLabel:DockMargin(0, 30, 0, 15)
				
				local grid = scroll:Add("DIconLayout")
				grid:Dock(TOP)
				grid:SetSpaceX(15)
				grid:SetSpaceY(10)
				
				for _, attName in ipairs(validAtts) do
					local safeAttName = attName 
					local niceName = hg.attachmentslaunguage and hg.attachmentslaunguage[safeAttName] or safeAttName
					
					local btn = grid:Add("DButton")
					btn:SetSize(450, 60)
					btn:SetText("")
					btn.HoverLerp = 0
					
					function btn:Think()
						local ui = HG_WorkbenchUI
						if not IsValid(ui) then return end
						
						local cx, cy = ui.CursorX, ui.CursorY
						local isHovered = false
						
						if cx and cy then
							if cy >= 130 and cy <= 130 + (UI_HEIGHT - 160) then
								local absX, absY = GetPanelAbsolutePos(self, ui)
								if cx >= absX and cx <= absX + self:GetWide() and cy >= absY and cy <= absY + self:GetTall() then
									isHovered = true
								end
							end
						end
						
						self.ManualHovered = isHovered
						
						if isHovered and LocalPlayer():KeyDown(IN_USE) then
							if not ui.IsPressedE then
								ui.IsPressedE = true
								self:DoClick()
							end
						end
					end
					
					function btn:Paint(w, h)
						local isEquipped = wep.attachments and wep.attachments[placement] and wep.attachments[placement][1] == safeAttName
						local isHovered = self.ManualHovered
						
						self.HoverLerp = Lerp(FrameTime() * 15, self.HoverLerp, isHovered and 1 or 0)
						
						local expandX = self.HoverLerp * 20 
						local expandY = self.HoverLerp * 10
						
						local dX = -expandX
						local dY = -expandY
						local dW = w + (expandX * 2)
						local dH = h + (expandY * 2)

						DisableClipping(true)
						
						surface.SetDrawColor(isHovered and Color(40, 38, 35) or rust_panel)
						surface.DrawRect(dX, dY, dW, dH)
						
						if isEquipped then
							surface.SetDrawColor(rust_green)
							surface.DrawRect(dX, dY, 6, dH)
						elseif self.HoverLerp > 0.01 then
							surface.SetDrawColor(ColorAlpha(rust_yellow, 255 * self.HoverLerp))
							surface.DrawRect(dX, dY, 4, dH)
						end
						
						surface.SetDrawColor(rust_outline)
						surface.DrawOutlinedRect(dX, dY, dW, dH, 1)
						
						local txt = string.upper(niceName)
						local textColor = isEquipped and color_white or (isHovered and rust_text or rust_dim)
						
						if self.HoverLerp < 0.99 then
							draw.SimpleText(txt, "Workbench_Item", dX + 20, dY + dH/2, ColorAlpha(textColor, 255 * (1 - self.HoverLerp)), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end
						if self.HoverLerp > 0.01 then
							draw.SimpleText(txt, "Workbench_Item_Large", dX + 20, dY + dH/2, ColorAlpha(textColor, 255 * self.HoverLerp), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end
						
						DisableClipping(false)
					end
					
					function btn:DoClick()
						local ply = LocalPlayer()
						if (ply.HG_NextAttachTime or 0) > CurTime() then return end
						ply.HG_NextAttachTime = CurTime() + 0.2

						net.Start("HG_Workbench_Toggle")
						net.WriteString(safeAttName)
						net.SendToServer()
						
						surface.PlaySound("UI/buttonclick.wav")
					end
				end
			end
		end
	end

	function ENT:Draw()
		self:DrawModel()

		local ply = LocalPlayer()
		if not ply:IsLineOfSightClear(self) then return end
		if ply:GetPos():DistToSqr(self:GetPos()) > 60000 then return end

		if not IsValid(HG_WorkbenchUI) then CreateWorkbenchUI(self) end

		local planePos, planeAng = GetScreenData(self)
		local planeNormal = planeAng:Up()
		
		local cx, cy = nil, nil
		if ply:GetNW2Bool("Breach:CanAttach") then
			local hitPos = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), planePos, planeNormal)
			if hitPos and ply:GetAimVector():Dot(planeNormal) <= 0 then
				local localPos = WorldToLocal(hitPos, angle_zero, planePos, planeAng)
				cx = localPos.x / UI_SCALE
				cy = -localPos.y / UI_SCALE
			end
		end

		if IsValid(HG_WorkbenchUI) then
			HG_WorkbenchUI.CursorX = cx
			HG_WorkbenchUI.CursorY = cy
		end

		vgui.Start3D2D(planePos, planeAng, UI_SCALE)
			if IsValid(HG_WorkbenchUI) then
				HG_WorkbenchUI:PaintManual()
			end

			if cx and cy then
				if cx >= 0 and cx <= UI_WIDTH and cy >= 0 and cy <= UI_HEIGHT then
					local curColor = Color(218, 165, 32, 220)
					surface.SetDrawColor(curColor)

					surface.DrawRect(cx - 2, cy - 2, 4, 4)

					local s = 12
					local l = 6
					local t = 2

					surface.DrawRect(cx - s, cy - s, l, t)
					surface.DrawRect(cx - s, cy - s, t, l)

					surface.DrawRect(cx + s - l + t, cy - s, l, t)
					surface.DrawRect(cx + s, cy - s, t, l)

					surface.DrawRect(cx - s, cy + s, l, t)
					surface.DrawRect(cx - s, cy + s - l + t, t, l)

					surface.DrawRect(cx + s - l + t, cy + s, l, t)
					surface.DrawRect(cx + s, cy + s - l + t, t, l)
				end
			end
		vgui.End3D2D()
	end
	
	function ENT:OnRemove()
		if IsValid(HG_WorkbenchUI) then
			HG_WorkbenchUI:Remove()
		end
	end
end