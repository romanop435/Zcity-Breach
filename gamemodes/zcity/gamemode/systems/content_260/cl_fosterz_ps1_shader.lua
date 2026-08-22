


// some shit code idk how i write this 
// developed by FosterZRussian
// https://steamcommunity.com/id/fosterzrussian/

CreateClientConVar( "pp_fz_ps1_shader_enable",                 0,      true, true, "Enable/Disable effect" );


CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_0",                 0,      true, true, "Enable/Disable Sub Effect" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_1",                 0,      true, true, "Enable/Disable Sub Effect" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_2",                 0,      true, true, "Enable/Disable Sub Effect" );


CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_ca",                 1,      true, true, "Enable/Disable Sub Effect" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_r_layer",                 1,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_g_layer",                 1,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_b_layer",                 1,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_r_x",                 -6,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_r_y",                 4,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_g_x",                 5,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_g_y",                 1,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_b_x",                 3,      true, true, "Sub Effect Setting" );
CreateClientConVar( "pp_fz_ps1_shader_seffect_vhs_en_offs_b_y",                 7,      true, true, "Sub Effect Setting" );

CreateClientConVar( "pp_fz_ps1_shader_effect_x_size",         120,      true, true, "Screen X-size" );
CreateClientConVar( "pp_fz_ps1_shader_effect_y_size",         40,      true, true, "Screen Y-size" );

CreateClientConVar( "pp_fz_ps1_shader_effect_lerpspeed",         0.12,      true, true, "Pixels Speed" );
CreateClientConVar( "pp_fz_ps1_shader_effect_maxsize",         1.8,      true, true, "Pixels Speed" );

local function ResetCA_Effect()
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_r_layer"):SetBool(true)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_g_layer"):SetBool(true)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_b_layer"):SetBool(true)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_r_x"):SetFloat(-6)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_r_y"):SetFloat(4)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_g_x"):SetFloat(5)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_g_y"):SetFloat(1)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_b_x"):SetFloat(3)
    GetConVar("pp_fz_ps1_shader_seffect_vhs_en_offs_b_y"):SetFloat(7)
end
-- im sorry for this local functions style, but why not -_-
local function ResetNotPrimaryEffects()
    ResetCA_Effect()
end

concommand.Add("pp_fz_ps1_reset_eff_ca", ResetCA_Effect)

concommand.Add("pp_fz_ps1_reset", function()
    GetConVar("pp_fz_ps1_shader_effect_x_size"):SetInt(120)
    GetConVar("pp_fz_ps1_shader_effect_y_size"):SetInt(40)
    GetConVar("pp_fz_ps1_shader_effect_lerpspeed"):SetFloat(0.12)
    GetConVar("pp_fz_ps1_shader_effect_maxsize"):SetFloat(1.8)
    ResetNotPrimaryEffects()
end)
concommand.Add("pp_fz_ps1_reset_medium", function()
    GetConVar("pp_fz_ps1_shader_effect_x_size"):SetInt(120)
    GetConVar("pp_fz_ps1_shader_effect_y_size"):SetInt(80)
    GetConVar("pp_fz_ps1_shader_effect_lerpspeed"):SetFloat(0.2)
    GetConVar("pp_fz_ps1_shader_effect_maxsize"):SetFloat(2.1)
    ResetNotPrimaryEffects()
end)
concommand.Add("pp_fz_ps1_reset_hight", function()
    GetConVar("pp_fz_ps1_shader_effect_x_size"):SetInt(175)
    GetConVar("pp_fz_ps1_shader_effect_y_size"):SetInt(175)
    GetConVar("pp_fz_ps1_shader_effect_lerpspeed"):SetFloat(0.5)
    GetConVar("pp_fz_ps1_shader_effect_maxsize"):SetFloat(4.2)
    ResetNotPrimaryEffects()
end)
concommand.Add("pp_fz_ps1_reset_low", function()
    GetConVar("pp_fz_ps1_shader_effect_x_size"):SetInt(70)
    GetConVar("pp_fz_ps1_shader_effect_y_size"):SetInt(30)
    GetConVar("pp_fz_ps1_shader_effect_lerpspeed"):SetFloat(0.1)
    GetConVar("pp_fz_ps1_shader_effect_maxsize"):SetFloat(3.75)
    ResetNotPrimaryEffects()
end)



local RenderBuffer = GetRenderTarget( CurTime() .. "FZPS1Render_Test",ScrW(), ScrH() );
local RenderBufferTMP = GetRenderTarget( CurTime() .. "FZPS1Render_Test_+1", ScrW(), ScrH() );
local RenderBufferOLD = GetRenderTarget( CurTime() .. "FZPS1Render_Test_+2", ScrW(), ScrH() );


local VHS_MAT2 = CreateMaterial( "PS1EFF_FZ_VHS_EFFECT_2" .. CurTime(), "UnLitGeneric", {
    ["$basetexture"] = "FosterZ/ps1effect/ps1_crt",
     ["Proxies"] = {
        ['TextureScroll'] = {
            ['texturescrollvar'] = '$basetexturetransform',
            ['texturescrollrate'] = 0.01,
            ['texturescrollangle'] = 0,
        }
    }, 
    ['$translucent'] = 1,
    ['$additive'] = 1,
})
local VHS_MAT3 = CreateMaterial( "PS1EFF_FZ_VHS_EFFECT_3" .. CurTime(), "UnLitGeneric", {
    ["$basetexture"] = "FosterZ/ps1effect/ps1_crt_r_l",
     ["Proxies"] = {
        ['TextureScroll'] = {
            ['texturescrollvar'] = '$basetexturetransform',
            ['texturescrollrate'] = 0.01,
            ['texturescrollangle'] = 0,
        }
    }, 
    ['$translucent'] = 1,
    ['$additive'] = 1,
    
} )

local RenderMaterial = CreateMaterial( "FZPS1Render_RT_Mat+1", "UnlitGeneric", {
    ["$basetexture"] = RenderBuffer:GetName() 
} )

local TempDrawMaterial = CreateMaterial( "FZPS1Render_RT_Mat+2", "UnlitGeneric", {
    ["$basetexture"] = RenderBufferTMP:GetName(),
} )
local OLDRenderMaterial = CreateMaterial( "FZPS1Render_RT_Mat+3", "UnlitGeneric", {
    ["$basetexture"] = RenderBufferOLD:GetName(),
} )

local EffSize_X = 150
local EffSize_X_cached = EffSize_X
local EffSize_Y = 100
local EffSize_Y_cached = EffSize_Y
local EffSize_Table = {}
for x = 1, EffSize_X do
    for y = 1, EffSize_Y do
        EffSize_Table[x] = EffSize_Table[x] or {}
        EffSize_Table[x][y] = 1
    end
end

local RT_Update = CurTime()
local Next_X_Update = 1
local Next_Y_Update = 1

local VHS_MAT_INDEX = 1
--[[ local VHS_DYNMATS = {}
for i = 1, 43 do
    VHS_DYNMATS[i] = cerate--]] 

local VHS_MAT4 = CreateMaterial( "PS1EFF_FZ_VHS_EFFECT_4" .. CurTime(), "UnLitGeneric", {
    ["$basetexture"] = "!",
    --['$translucent'] = 1,
    ['$additive'] = 0,
    
} )


local CA_EFFECT_MATERIALS = {
    R = CreateMaterial( "CA_EFFECT_MATERIALS_R" .. CurTime(), "UnLitGeneric", {
        ["$basetexture"] = "!",
        --['$translucent'] = 1,
        ["$additive"] = "1",
        ["$color2"] = "[1 0 0]",
    } ),
    G = CreateMaterial( "CA_EFFECT_MATERIALS_G" .. CurTime(), "UnLitGeneric", {
        ["$basetexture"] = "!",
        --['$translucent'] = 1,
        ["$additive"] = "1",
        ["$color2"] = "[0 1 0]",
    } ),
    B = CreateMaterial( "CA_EFFECT_MATERIALS_B" .. CurTime(), "UnLitGeneric", {
        ["$basetexture"] = "!",
        --['$translucent'] = 1,
        ["$additive"] = "1",
        ["$color2"] = "[0 0 1]",
    } ),
}


local function RenderCA_Effect()

    local NUPD_RT_TEX = render.GetScreenEffectTexture()        

    if true then
        CA_EFFECT_MATERIALS.R:SetTexture("$basetexture", NUPD_RT_TEX)
        local R_EFFECT_POS_OFFSET_X = 500      
        local R_EFFECT_POS_OFFSET_Y = 500
        render.SetMaterial(CA_EFFECT_MATERIALS.R) 
        render.DrawScreenQuadEx((R_EFFECT_POS_OFFSET_X > 0 && -R_EFFECT_POS_OFFSET_X) or 0, (R_EFFECT_POS_OFFSET_Y > 0 && -R_EFFECT_POS_OFFSET_Y) or 0, (R_EFFECT_POS_OFFSET_X > 0 && ScrW()+R_EFFECT_POS_OFFSET_X) or ScrW()-R_EFFECT_POS_OFFSET_X*2, (R_EFFECT_POS_OFFSET_Y > 0 && ScrH()+R_EFFECT_POS_OFFSET_Y) or ScrH()-R_EFFECT_POS_OFFSET_Y*2) 
    end


    if true then
        CA_EFFECT_MATERIALS.G:SetTexture("$basetexture", NUPD_RT_TEX)
        local G_EFFECT_POS_OFFSET_X = 500                
        local G_EFFECT_POS_OFFSET_Y = 500
        render.SetMaterial(CA_EFFECT_MATERIALS.G) 
        render.DrawScreenQuadEx((G_EFFECT_POS_OFFSET_X > 0 && -G_EFFECT_POS_OFFSET_X) or 0, (G_EFFECT_POS_OFFSET_Y > 0 && -G_EFFECT_POS_OFFSET_Y) or 0, (G_EFFECT_POS_OFFSET_X > 0 && ScrW()+G_EFFECT_POS_OFFSET_X) or ScrW()-G_EFFECT_POS_OFFSET_X*2, (G_EFFECT_POS_OFFSET_Y > 0 && ScrH()+G_EFFECT_POS_OFFSET_Y) or ScrH()-G_EFFECT_POS_OFFSET_Y*2) 
    end

    if true then
        CA_EFFECT_MATERIALS.B:SetTexture("$basetexture", NUPD_RT_TEX)
        local B_EFFECT_POS_OFFSET_X = 500                       
        local B_EFFECT_POS_OFFSET_Y = 500
        render.SetMaterial(CA_EFFECT_MATERIALS.B) 
        render.DrawScreenQuadEx((B_EFFECT_POS_OFFSET_X > 0 && -B_EFFECT_POS_OFFSET_X) or 0, (B_EFFECT_POS_OFFSET_Y > 0 && -B_EFFECT_POS_OFFSET_Y) or 0, (B_EFFECT_POS_OFFSET_X > 0 && ScrW()+B_EFFECT_POS_OFFSET_X) or ScrW()-B_EFFECT_POS_OFFSET_X*2, (B_EFFECT_POS_OFFSET_Y > 0 && ScrH()+B_EFFECT_POS_OFFSET_Y) or ScrH()-B_EFFECT_POS_OFFSET_Y*2) 
    end

end


hook.Add("RenderScreenspaceEffects", "RenderScreenspaceEffects_PS1EFF_FZ", function()
        


        
        
    if !LocalPlayer().br_scp079_mode then return end



        local S_EN_EFF_1 = true
        local S_EN_EFF_2 = true

        local S_EN_EFF_CA = false



        if S_EN_EFF_1 or S_EN_EFF_2 then
            render.OverrideBlend( true, 2, 1, 0, 0, 0, 4 )
                if S_EN_EFF_2 then
                    render.SetMaterial(VHS_MAT2)
                    render.DrawScreenQuad()
                end
                if S_EN_EFF_1 then
                    render.SetMaterial(VHS_MAT3)
                    render.DrawScreenQuad()
                end
            render.OverrideBlend(false)
        end



        EffSize_X = 500
        EffSize_Y = 500
        if EffSize_X_cached != EffSize_X or EffSize_Y_cached != EffSize_Y then
            EffSize_Table = {}
            for x = 1, EffSize_X do
                for y = 1, EffSize_Y do
                    EffSize_Table[x] = EffSize_Table[x] or {}
                    EffSize_Table[x][y] = 1
                end
            end
            EffSize_X_cached = EffSize_X
            EffSize_Y_cached = EffSize_Y
            Next_X_Update = 1
            Next_Y_Update = 1
        end

        render.ResetToneMappingScale(1)

        render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )

        RenderMaterial:SetTexture( "$basetexture", render.GetScreenEffectTexture() )

        render.Clear(0,0,0,0,true,true)   



        cam.Start2D()
            render.Clear(0,0,0,0)

            local SCREEN_SIZE_X = 800
            local SCREEN_SIZE_Y = 600
            local SCREEN_X_RELATIVESIZE = ScrW()/SCREEN_SIZE_X 
            local SCREEN_Y_RELATIVESIZE = (ScrH()/SCREEN_SIZE_Y)
            local CALC_X_MATS = (SCREEN_SIZE_X/EffSize_X)*SCREEN_X_RELATIVESIZE
            local CALC_Y_MATS = ((SCREEN_SIZE_Y/EffSize_Y))*SCREEN_Y_RELATIVESIZE                
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial(TempDrawMaterial)            
            surface.DrawTexturedRect(0, 0, ScrW(),ScrH())                  
            if CurTime() > RT_Update then
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial(RenderMaterial)
                local CalculedMFrames = 0
                local C_Calc = 0
                local need_brake = false

                for Y = 1, EffSize_Y do
                    if need_brake then
                        --RT_Update = RT_Update + 0.05
                        break
                    end
                    if Next_Y_Update != Y then 
                        continue 
                    end
                    local Y_U_NOW = (Y-1)/EffSize_Y
                    local Y_U_NEXT = (Y)/EffSize_Y            
                    for X = 1, EffSize_X do       
                        if Next_X_Update != X then continue end
                        C_Calc = C_Calc + 1                            
                        local X_U_NOW = (X-1)/EffSize_X
                        local X_U_NEXT = (X)/EffSize_X                        
                        EffSize_Table[X][Y] = Lerp(1000, EffSize_Table[X][Y], math.random(1.1, 1 ))                                                        
                        Next_X_Update = Next_X_Update + 1
                        if Next_X_Update > EffSize_X then
                            Next_X_Update = 1
                            Next_Y_Update = Next_Y_Update + 1
                            CalculedMFrames = CalculedMFrames + 1
                            if CalculedMFrames >= 50 && CalculedMFrames % 3 == 0 then
                                need_brake = true
                            end
                            if Next_Y_Update > EffSize_Y then
                                Next_Y_Update = 1
                            end                               
                        end
                        if C_Calc == math.random(2,4) then
                            C_Calc = 0
                        else
                            surface.DrawTexturedRectUV((X-1)/EffSize_X * ScrW(), (Y-1)/EffSize_Y * ScrH(), CALC_X_MATS*EffSize_Table[X][Y],CALC_Y_MATS*EffSize_Table[X][Y], X_U_NOW, Y_U_NOW, X_U_NEXT, Y_U_NEXT)
                        end                        
                    end
                end                    
            end 
            render.CopyRenderTargetToTexture(RenderBufferTMP)
            TempDrawMaterial:SetTexture( "$basetexture", RenderBufferTMP) 
        cam.End2D()


        
        if true then
            VHS_MAT4:SetTexture( "$basetexture", Material("fosterz/ps1effect/vhs_mat/" .. VHS_MAT_INDEX .. ".png"):GetTexture("$basetexture") )
            render.OverrideBlend( true, 1, 1, 0, 0, 0, 0 )
                render.SetMaterial(VHS_MAT4)
                render.DrawScreenQuad()
            render.OverrideBlend(false)
            if math.random(1,5) == 5 then
                 VHS_MAT_INDEX = VHS_MAT_INDEX - 2
            else
                VHS_MAT_INDEX = VHS_MAT_INDEX + 1
            end
            if VHS_MAT_INDEX == 44 then
                VHS_MAT_INDEX = 1
            elseif VHS_MAT_INDEX < 1 then
                VHS_MAT_INDEX = 1
            end
        end


        render.UpdateScreenEffectTexture()


        if S_EN_EFF_CA then
            RenderCA_Effect()
        end

end )



list.Set( "PostProcess", "FosterZ PS1-Style Shader", {

    icon = "gui/postprocess/fosterz_ps1_shader.png",
    convar = "pp_fz_ps1_shader_enable",
    category = "FosterZ PS1-Style Shader",
    cpanel = function( CPanel )

        CPanel:AddControl( 
            "Header", {
                    Description = "PS1 Style Visualization" 
            } )

        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Enable shader", 
                Command = "pp_fz_ps1_shader_enable" 
            } )



        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Visualization X", 
                Command = "pp_fz_ps1_shader_effect_x_size", 
                Type = "Integer", 
                Min = "10", 
                Max = "450" 
            } )
    
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Visualization Y", 
                Command = "pp_fz_ps1_shader_effect_y_size", 
                Type = "Integer", 
                Min = "10", 
                Max = "450" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Pixels Lerp Speed", 
                Command = "pp_fz_ps1_shader_effect_lerpspeed", 
                Type = "Float", 
                Min = "0.1", 
                Max = "1" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Pixels MaxSize", 
                Command = "pp_fz_ps1_shader_effect_maxsize", 
                Type = "Float", 
                Min = "1.2", 
                Max = "10" 
            } )
        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Default)", 
                Command = "pp_fz_ps1_reset", 
            } )
        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Low)", 
                Command = "pp_fz_ps1_reset_low", 
            } )

        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Medium)", 
                Command = "pp_fz_ps1_reset_medium", 
            } )
        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Hight)", 
                Command = "pp_fz_ps1_reset_hight", 
            } )

         CPanel:AddControl( 
            "Header", {
                    Description = "Additional Effects" 
            } )

        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Enable CRT Colorable Lines", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_0" 
            } )
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Enable CRT White Lines", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_1" 
            } )
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Enable VHX Noise Effect", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_2" 
            } )
         CPanel:AddControl( 
            "Header", {
                    Description = "Chromatics Abbirations effect" 
            } )
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Enable Chromatics Abbirations (CA) effect", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_ca" 
            } )


        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Chromatics Abbirations", 
                Command = "pp_fz_ps1_reset_eff_ca", 
            } )
        --
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Red Layer - Enable", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_r_layer" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Red Layer - Offset X ", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_r_x", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Red Layer - Offset Y", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_r_y", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        --
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Green Layer - Enable", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_g_layer" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Green Layer - Offset X ", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_g_x", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Green Layer - Offset Y", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_g_y", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        --
        CPanel:AddControl( "CheckBox", 
            { 
                Label = "Blue Layer - Enable", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_b_layer" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Blue Layer - Offset X ", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_b_x", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Blue Layer - Offset Y", 
                Command = "pp_fz_ps1_shader_seffect_vhs_en_offs_b_y", 
                Type = "Float", 
                Min = "-100", 
                Max = "100" 
            } )
        

    end

} )





