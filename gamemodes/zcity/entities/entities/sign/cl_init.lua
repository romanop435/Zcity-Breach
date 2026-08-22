include("shared.lua")
local newrb_r = Material("nextoren_hud/round_box_3_big_r2.png")
function ENT:Draw()

	self:DrawModel()


	if ( LocalPlayer():IsLineOfSightClear( self ) ) then

		local oang = self:GetAngles()
	  local ang = self:GetAngles()
	  local pos = self:GetPos()

	  ang:RotateAroundAxis( oang:Up(), 90 )
	  ang:RotateAroundAxis( oang:Right(), -90 )
	  ang:RotateAroundAxis( oang:Up(), 90 )

	  cam.Start3D2D( pos + oang:Up() * 11 + oang:Right() * -0.5, ang, 0.07 )

        
		
		
		
		
		
		
		
		
		
		
		
		

                

        
        if self:GetItem() == "нил" then

            


            draw.SimpleText( L"l:NewS_Name", "ImpactSmall42", 0, 2, status, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            
	  	    
	  	    
            draw.RoundedBox( 0, -220, 70, 200, 200, Color( 0, 0, 0,255) )
            draw.SimpleText( "Not", "ImpactSmall42", -150 + 30, 145, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "Image", "ImpactSmall42", -150 + 30, 145 + 40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            surface.SetDrawColor(Color(255,255,255));
	  	    surface.SetMaterial(newrb_r);
	  	    surface.DrawTexturedRect(-220, 70, 200, 200);

		    draw.SimpleText( "Empty cell", "ImpactSmall42", 0, 85, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            
            draw.SimpleText( "Access level - 0", "ImpactSmall42", 0, 85 + 40, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            
        else
        local Main_Color = Color(100,255,80)
        if self.scp_list[self:GetItem()]["Class"] == "SAFE" then
            Main_Color = Color(100,255,80)
        elseif self.scp_list[self:GetItem()]["Class"] == "EUCLID" then
            Main_Color = Color(255,150,80)
        elseif self.scp_list[self:GetItem()]["Class"] == "KETER" then
            Main_Color = Color(255,80,80)
        end
        local A_Color = Color(80,205,255)
        local S_Color = Color(255,107,107)
		draw.SimpleText( L"l:NewS_Name", "ImpactSmall42", 0, 2, status, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        surface.SetDrawColor(255, 255, 255);
	  	surface.SetMaterial(self.scp_list[self:GetItem()]["Icon"]);
	  	surface.DrawTexturedRect(-220, 70, 200, 200);

        surface.SetDrawColor(Main_Color);
	  	surface.SetMaterial(newrb_r);
	  	surface.DrawTexturedRect(-220, 70, 200, 200);

		draw.SimpleText( self.scp_list[self:GetItem()]["Name"], "ImpactSmall42", 0, 85, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        draw.SimpleText( L"l:NewS_Class"..self.scp_list[self:GetItem()]["Class"], "ImpactSmall42", 0, 85 + 40, Main_Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        draw.SimpleText( L"l:NewS_AL"..self.scp_list[self:GetItem()]["AL"], "ImpactSmall42", 0, 85 + 40 + 40, A_Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            if self:GetStatus() then
                draw.SimpleText( L"l:NewS_Status_1", "ImpactSmall42", 0, 85 + 40 + 40 + 40, Color(100,255,80), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            else
                draw.SimpleText( L"l:NewS_Status_2", "ImpactSmall42", 0, 85 + 40 + 40 + 40, Color(255,80,80), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            end
        end
		cam.End3D2D()

	end

end

