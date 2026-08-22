AddCSLuaFile()

ENT.Base        = "base_gmodentity"
ENT.Category    = "Custom"
ENT.PrintName   = "Control Panel"
ENT.Spawnable   = true

ENT.Model       = Model( "models/next_breach/gas_monitor.mdl" )
ENT.Angles      = Angle( 0, 180, 0 )
ENT.Pos         = Vector(6479.18, 2196.97, -191.88)
if SERVER then
  function ENT:Initialize()
  	self:SetModel( self.Model )
  	self:SetMoveType( MOVETYPE_NONE )
  	self:SetSolid( SOLID_BBOX )

  	self:SetPos( self.Pos )
  	self:SetAngles( self.Angles )
  end
end

if SERVER then
	util.AddNetworkString( "WeaponStation_RedactMessage" )

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
end

if CLIENT then

	local UI_WIDTH  = 2450 
	local UI_HEIGHT = 1300 
	local UI_SCALE  = 0.02 

	local UI_OFFSET_FORWARD = 23.9 
	local UI_OFFSET_RIGHT   = -3.1 
	local UI_OFFSET_UP      = 14    

	local UI_ANGLE_PITCH = 0 
	local UI_ANGLE_YAW   = 180 
	local UI_ANGLE_ROLL  = 0   

	surface.CreateFont("Workbench_Title1", { font = "Hitmarker Normal", size = 64, weight = 800, extended = true })
	surface.CreateFont("Workbench_Category1", { font = "Hitmarker Normal", size = 42, weight = 600, extended = true })
	surface.CreateFont("Workbench_Item1", { font = "Hitmarker Normal", size = 68, weight = 500, extended = true })
	surface.CreateFont("Workbench_Item_Large1", { font = "Hitmarker Normal", size = 88, weight = 700, extended = true })
	surface.CreateFont("Workbench_Small1", { font = "Hitmarker Normal", size = 24, weight = 600, extended = true })

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
		
		HG_WorkbenchUI.IsBuilt = false
		HG_WorkbenchUI.TargetEntity = ent
		HG_WorkbenchUI.CursorX = nil
		HG_WorkbenchUI.CursorY = nil
		HG_WorkbenchUI.IsPressedE = false 
		
		function HG_WorkbenchUI:Paint(w, h)
			surface.SetDrawColor(rust_bg)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(rust_outline)
			surface.DrawOutlinedRect(0, 0, w, h, 2)

			draw.SimpleText("ПАНЕЛЬ УПРАВЛЕНИЯ", "Workbench_Title1", 40, 30, color_white, TEXT_ALIGN_LEFT)
			
			surface.SetDrawColor(rust_yellow)
			surface.DrawRect(40, 100, w - 80, 2)
			
			local ply = LocalPlayer()
			if not ply:GetNW2Bool("Breach:CanAttach") then
				draw.SimpleText("ОЖИДАНИЕ ОПЕРАТОРА...", "Workbench_Title1", w/2, h/2 - 20, rust_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("ПОДОЙДИТЕ БЛИЖЕ И НАЖМИТЕ [E]", "Workbench_Category1", w/2, h/2 + 40, rust_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				return
			end
			
			draw.SimpleText("НАВЕДИТЕСЬ [ ПРИЦЕЛ ]   |   ПОДТВЕРДИТЬ [ E ]", "Workbench_Small1", w - 40, 60, rust_yellow, TEXT_ALIGN_RIGHT)
		end
		
		function HG_WorkbenchUI:Think()
			if not LocalPlayer():KeyDown(IN_USE) then
				self.IsPressedE = false
			end

			local ply = LocalPlayer()
			if not ply:GetNW2Bool("Breach:CanAttach") then 
				if self.IsBuilt then
					self:Clear()
					self.IsBuilt = false
				end
				return 
			end
			
			if not self.IsBuilt then
				self.IsBuilt = true
				self:Rebuild()
			end
		end
		
		function HG_WorkbenchUI:Rebuild()
			self:Clear()
			
			local container = vgui.Create("DPanel", self)
			container:SetSize(1400, 600)
			container:SetPos(UI_WIDTH / 2 - 700, UI_HEIGHT / 2 - 300 + 50)
			container.Paint = function() end
			
			local buttonsList = {
				"ПОДНЯТЬ КУБ",
				"ОПУСТИТЬ КУБ",
				"ПРИЗВАТЬ"
			}
			
			for i, btnText in ipairs(buttonsList) do
				local btn = vgui.Create("DButton", container)
				btn:Dock(TOP)
				btn:DockMargin(0, 0, 0, 40)
				btn:SetTall(150)
				btn:SetText("")
				btn.HoverLerp = 0
				
				function btn:Think()
					local ui = HG_WorkbenchUI
					if not IsValid(ui) then return end
					
					local cx, cy = ui.CursorX, ui.CursorY
					local isHovered = false
					
					if cx and cy then
						local absX, absY = GetPanelAbsolutePos(self, ui)
						if cx >= absX and cx <= absX + self:GetWide() and cy >= absY and cy <= absY + self:GetTall() then
							isHovered = true
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
					
					if self.HoverLerp > 0.01 then
						surface.SetDrawColor(ColorAlpha(rust_yellow, 255 * self.HoverLerp))
						surface.DrawRect(dX, dY, 8, dH)
					end
					
					surface.SetDrawColor(rust_outline)
					surface.DrawOutlinedRect(dX, dY, dW, dH, 2)
					
					local textColor = isHovered and rust_text or rust_dim
					
					if self.HoverLerp < 0.99 then
						draw.SimpleText(btnText, "Workbench_Item1", dX + dW/2, dY + dH/2, ColorAlpha(textColor, 255 * (1 - self.HoverLerp)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
					if self.HoverLerp > 0.01 then
						draw.SimpleText(btnText, "Workbench_Item_Large1", dX + dW/2, dY + dH/2, ColorAlpha(textColor, 255 * self.HoverLerp), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
					
					DisableClipping(false)
				end
				
				function btn:DoClick()
					
					print(btnText)
					if btnText == "ПОДНЯТЬ КУБ" then
						
						net.Start("Breach:CubreOperation")
						net.WriteString("Поднять якорь")
						net.SendToServer()
					elseif btnText == "ОПУСТИТЬ КУБ" then
						
						net.Start("Breach:CubreOperation")
						net.WriteString("Опустить якорь")
						net.SendToServer()

					elseif btnText == "ПРИЗВАТЬ" then
						
						net.Start("Breach:CubreOperation")
						net.WriteString("Якорь!!!")
						net.SendToServer()

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