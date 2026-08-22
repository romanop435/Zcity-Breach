include("shared.lua")
local newrb_r = Material("nextoren_hud/round_box_3_big_r2.png")
function ENT:Draw()

	self:DrawModel()


	

		local oang = self:GetAngles()
	  local ang = self:GetAngles()
	  local pos = self:GetPos()

	  ang:RotateAroundAxis( oang:Up(), 90 )
	  ang:RotateAroundAxis( oang:Right(), -111 )
	  ang:RotateAroundAxis( oang:Forward(), 0 )

	  cam.Start3D2D( pos + oang:Up() * 11 + oang:Right() * -0.5 + oang:Forward() * 11.4, ang, 0.07 )
        draw.RoundedBox( 0, -286, 141, 592, 171, Color( 0, 0, 0,255) )

       
            draw.SimpleText( L(self:GetItem()), "ImpactBig2", 20, 221, string.ToColor(self:GetTextColor()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            
	  	    
	  	    
            
            
            
            
	  	    
	  	    

		    
            
            
            
		cam.End3D2D()

	

end

