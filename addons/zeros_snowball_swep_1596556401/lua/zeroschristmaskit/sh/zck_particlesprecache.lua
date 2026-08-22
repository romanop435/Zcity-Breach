AddCSLuaFile()

if file.Exists("particles/zck_snowball.pcf", "GAME") then game.AddParticles("particles/zck_snowball.pcf") end

PrecacheParticleSystem( "zck_snowball_explode" )
PrecacheParticleSystem( "zck_snowball_pickup" )
PrecacheParticleSystem( "zck_snowball_trail" )
