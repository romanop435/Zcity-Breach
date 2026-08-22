AddCSLuaFile()

function EFFECT:Init( data )

  local pos = data:GetOrigin()
  local norm = data:GetNormal()
  local ent = data:GetEntity()

  if ( ent:IsPlayer() ) then

    
    

  end

  
  

  
  

    
    
    
    
    
    
    
    
    
    
    

  

  
  
  
  
  
  
  
  
  
  
  

  local maxbound = Vector( 3, 3, 3 )
  local minbound = maxbound * -1
  for i = 1, math.random( 5, 8 ) do

    local dir = ( norm * 2 + VectorRand() ) / 3
    dir:Normalize()
    local eRag = ent:GetNWEntity( "RagdollEntityNO" )
    
    

      
      
      
      
      
      
      

      if ( eRag:IsValid() ) then

        local boneIndex = eRag:LookupBone( "ValveBiped.Bip01_Head1" )
        local fx = EffectData()
        fx:SetFlags( 1 )
        fx:SetMagnitude( boneIndex )
        fx:SetOrigin( eRag:GetBonePosition( boneIndex ) )
        fx:SetEntity(eRag)
        fx:SetColor( BLOOD_COLOR_RED )
        util.Effect( "br_blood_stream", fx )
        util.Effect( "br_blood_spray", fx )

      end

      
      

      
      

        
        
        

      

      


    

  end

end

function EFFECT:Think()

  return false

end

function EFFECT:Render()

end
