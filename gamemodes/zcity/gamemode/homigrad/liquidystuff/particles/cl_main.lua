local fps = 1 / 24
local delay = 0
local CurTime, FrameTime = CurTime, FrameTime
gasparticles_hook = gasparticles_hook or {}
local gasparticles_hook = gasparticles_hook
hook.Remove("PostDrawOpaqueRenderables", "gasparticles")