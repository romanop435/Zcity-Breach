local FindMetaTable = FindMetaTable
local CurTime = CurTime
local pairs = pairs
local string = string
local table = table
local timer = timer
local hook = hook
local math = math
local tonumber = tonumber
local tostring = tostring
local util = util



local math_sin, math_cos = math.sin, math.cos
local math_rad, math_deg = math.rad, math.deg
local math_sqrt, math_acos = math.sqrt, math.acos
local math_asin, math_atan2 = math.asin, math.atan2
local math_abs, math_min, math_max = math.abs, math.min, math.max

if CLIENT then
	BREACH = BREACH or {}
	BREACH.GunPositions = BREACH.GunPositions or {}

	local originx = CreateClientConVar("ubreach_gunorigin_x", "0", true, true, "-4 - 4, gun origin x", -4, 4)
	local originy = CreateClientConVar("ubreach_gunorigin_y", "0", true, true, "-4 - 4, gun origin y", -4, 4)
	local originz = CreateClientConVar("ubreach_gunorigin_z", "0", true, true, "-4 - 4, gun origin z", -4, 4)

	hook.Add("InitPostEntity", "Breach_GunPositions_Init", function()
		BREACH.GunPositions[LocalPlayer()] = {
			originx:GetFloat(),
			originy:GetFloat(),
			originz:GetFloat()
		}
	end)

	cvars.AddChangeCallback("ubreach_gunorigin_x", function(convar_name, value_old, value_new)
		if IsValid(LocalPlayer()) then BREACH.GunPositions[LocalPlayer()][1] = tonumber(value_new) or 0 end
	end, "cback1")

	cvars.AddChangeCallback("ubreach_gunorigin_y", function(convar_name, value_old, value_new)
		if IsValid(LocalPlayer()) then BREACH.GunPositions[LocalPlayer()][2] = tonumber(value_new) or 0 end
	end, "cback2")

	cvars.AddChangeCallback("ubreach_gunorigin_z", function(convar_name, value_old, value_new)
		if IsValid(LocalPlayer()) then BREACH.GunPositions[LocalPlayer()][3] = tonumber(value_new) or 0 end
	end, "cback3")
end

local QUATERNION = {
	__epsl = 0.0001,
	__lerp = 0.9995,
	__axis = Vector()
}
QUATERNION.__index = QUATERNION
debug.getregistry().Quaternion = QUATERNION

function IsQuaternion(obj)
	return getmetatable(obj) == QUATERNION
end

function Quaternion(w, x, y, z)
	if IsQuaternion(w) then
		return setmetatable({ w = w.w, x = w.x, y = w.y, z = w.z }, QUATERNION)
	end
	return setmetatable({ w = w or 1.0, x = x or 0.0, y = y or 0.0, z = z or 0.0 }, QUATERNION)
end

function QUATERNION:__eq(q)
	return self.w == q.w and self.x == q.x and self.y == q.y and self.z == q.z
end

function QUATERNION:Set(w, x, y, z)
	if IsQuaternion(w) then 
		self.w, self.x, self.y, self.z = w.w, w.x, w.y, w.z
	else 
		self.w, self.x, self.y, self.z = w, x, y, z
	end
	return self
end

function QUATERNION:SetAngle(ang)
	local p = math_rad(ang.p) * 0.5
	local y = math_rad(ang.y) * 0.5
	local r = math_rad(ang.r) * 0.5
	
	local sinp, cosp = math_sin(p), math_cos(p)
	local siny, cosy = math_sin(y), math_cos(y)
	local sinr, cosr = math_sin(r), math_cos(r)

	return self:Set(
		cosr * cosp * cosy + sinr * sinp * siny,
		sinr * cosp * cosy - cosr * sinp * siny,
		cosr * sinp * cosy + sinr * cosp * siny,
		cosr * cosp * siny - sinr * sinp * cosy
	)
end

function QUATERNION:SetAngleAxis(theta, axis)
	local ang = math_rad(theta) * 0.5
	local sin = math_sin(ang)
	local vec = axis:GetNormalized()

	self.__axis = vec
	return self:Set(math_cos(ang), vec.x * sin, vec.y * sin, vec.z * sin)
end

function QUATERNION:SetMatrix(m)
	local m11, m12, m13, _, m21, m22, m23, _, m31, m32, m33 = m:Unpack()
	local scale = 1.0
	local trace = m11 + m22 + m33 + scale

	if trace > self.__epsl then
		scale = math_sqrt(trace) * 2.0
		self:Set(0.25 * scale, (m32 - m23) / scale, (m13 - m31) / scale, (m21 - m12) / scale)
	else
		if m11 > m22 and m11 > m33 then
			scale = math_sqrt(1.0 + m11 - m22 - m33) * 2.0
			self:Set((m32 - m23) / scale, 0.25 * scale, (m21 + m12) / scale, (m13 + m31) / scale)
		elseif m22 > m33 then
			scale = math_sqrt(1.0 + m22 - m11 - m33) * 2.0
			self:Set((m13 - m31) / scale, (m21 + m12) / scale, 0.25 * scale, (m32 + m23) / scale)
		else
			scale = math_sqrt(1.0 + m33 - m11 - m22) * 2.0
			self:Set((m21 - m12) / scale, (m13 + m31) / scale, (m23 + m32) / scale, 0.25 * scale)
		end
	end
	return self:Normalize()
end

function QUATERNION:SetDirection(forward, up)
	up = (up and up:GetNormalized()) or Vector(0, 0, 1)
	forward = forward:GetNormalized()

	local m = Matrix()
	local right = up:Cross(forward)
	m:SetUnpacked(forward.x, right.x, up.x, 0.0, forward.y, right.y, up.y, 0.0, forward.z, right.z, up.z, 0.0, 0.0, 0.0, 0.0, 1.0)

	return self:SetAngle(m:GetAngles())
end

function QUATERNION:LengthSqr()
	return self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z
end

function QUATERNION:Length() return math_sqrt(self:LengthSqr()) end

function QUATERNION:Normalize()
	local len = self:Length()
	return len > 0 and self:DivScalar(len) or self
end

function QUATERNION:Normalized() return Quaternion(self):Normalize() end
function QUATERNION:Conjugate() return self:Set(self.w, -self.x, -self.y, -self.z) end
function QUATERNION:Conjugated() return Quaternion(self):Conjugate() end
function QUATERNION:Invert() return self:Conjugate():Normalize() end
function QUATERNION:Inverted() return Quaternion(self):Invert() end
function QUATERNION:Negate() return self:MulScalar(-1.0) end
function QUATERNION:Negated() return Quaternion(self):Negate() end
function QUATERNION:__unm() return self:Negated() end

function QUATERNION:Dot(q)
	return self.w * q.w + self.x * q.x + self.y * q.y + self.z * q.z
end

function QUATERNION:AngleDifference(q)
	return math_deg(math_acos(math_min(math_abs(self:Dot(q)), 1.0)) * 2.0)
end

function QUATERNION:AddScalar(scalar) self.w = self.w + scalar return self end
function QUATERNION:Add(q) return self:Set(self.w + q.w, self.x + q.x, self.y + q.y, self.z + q.z) end
function QUATERNION:__add(q) return IsQuaternion(q) and Quaternion(self):Add(q) or Quaternion(self):AddScalar(q) end

function QUATERNION:SubScalar(scalar) return self:AddScalar(-scalar) end
function QUATERNION:Sub(q) return self:Add(-q) end
function QUATERNION:__sub(q) return IsQuaternion(q) and Quaternion(self):Sub(q) or Quaternion(self):SubScalar(q) end

function QUATERNION:MulScalar(scalar) return self:Set(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar) end

function QUATERNION:Mul(q)
	local qw, qx, qy, qz = self.w, self.x, self.y, self.z
	local q2w, q2x, q2y, q2z = q.w, q.x, q.y, q.z

	return self:Set(
		qw * q2w - qx * q2x - qy * q2y - qz * q2z,
		qx * q2w + qw * q2x + qy * q2z - qz * q2y,
		qy * q2w + qw * q2y + qz * q2x - qx * q2z,
		qz * q2w + qw * q2z + qx * q2y - qy * q2x
	)
end

function QUATERNION:__mul(q) return IsQuaternion(q) and Quaternion(self):Mul(q) or Quaternion(self):MulScalar(q) end
function QUATERNION:__concat(q) return Quaternion(q):Mul(self) end

function QUATERNION:DivScalar(scalar) return self:MulScalar(1.0 / scalar) end
function QUATERNION:Div(q) return self:Mul(q:Inverted()) end
function QUATERNION:__div(q) return IsQuaternion(q) and Quaternion(self):Div(q) or Quaternion(self):DivScalar(q) end

function QUATERNION:LerpDomain(q, alphaStart, alphaEnd)
	return self:MulScalar(alphaStart):Add(Quaternion(q):MulScalar(alphaEnd)):Normalize()
end

function QUATERNION:Lerp(q, alpha)
	return self:LerpDomain(q, 1.0 - alpha, alpha)
end

function QUATERNION:SLerp(q, alpha)
	local ref = q
	local dot = self:Dot(ref)
	local alphaStart = 1.0 - alpha
	local alphaEnd = alpha

	if dot < 0.0 then
		ref = -q
		dot = -dot
	end

	if dot < self.__lerp then
		local theta = math_acos(dot)
		local thetaInv = math_abs(theta) < self.__epsl and 1.0 or (1.0 / math_sin(theta))
		alphaStart = math_sin((1.0 - alpha) * theta) * thetaInv
		alphaEnd = math_sin(alpha * theta) * thetaInv
	end

	return self:LerpDomain(ref, alphaStart, alphaEnd)
end

function QUATERNION:RotateVector(vec)
	local qw, qx, qy, qz = self.w, self.x, self.y, self.z
	local vx, vy, vz = vec.x, vec.y, vec.z

	vec:SetUnpacked(
		qw * qw * vx + 2.0 * qy * qw * vz - 2.0 * qz * qw * vy + qx * qx * vx + 2.0 * qy * qx * vy + 2.0 * qz * qx * vz - qz * qz * vx - qy * qy * vx,
		2.0 * qx * qy * vx + qy * qy * vy + 2.0 * qz * qy * vz + 2.0 * qw * qz * vx - qz * qz * vy + qw * qw * vy - 2.0 * qx * qw * vz - qx * qx * vy,
		2.0 * qx * qz * vx + 2.0 * qy * qz * vy + qz * qz * vz - 2.0 * qw * qy * vx - qy * qy * vz + 2.0 * qw * qx * vy - qx * qx * vz + qw * qw * vz)
	return vec
end

function QUATERNION:RotatedVector(vec) return self:RotateVector(Vector(vec)) end

function QUATERNION:Angle()
	local qw, qx, qy, qz = self.w, self.x, self.y, self.z
	return Angle(
		math_deg(math_asin(2.0 * (qw * qy - qz * qx))),
		math_deg(math_atan2(2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz))),
		math_deg(math_atan2(2.0 * (qw * qx + qy * qz), 1.0 - 2.0 * (qx * qx + qy * qy)))
	)
end

function QUATERNION:AngleAxis()
	local qw = self.w
	local den = math_sqrt(1.0 - qw * qw)
	return math_deg(2.0 * math_acos(qw)), den > self.__epsl and (Vector(self.x, self.y, self.z) / den) or self.__axis
end

function QUATERNION:Matrix(m)
	local qw, qx, qy, qz = self.w, self.x, self.y, self.z
	m = m or Matrix()
	m:SetUnpacked(
		1.0 - 2.0 * (qy * qy + qz * qz), 2.0 * (qx * qy - qw * qz),       2.0 * (qx * qz + qw * qy),       0.0,
		2.0 * (qx * qy + qw * qz),       1.0 - 2.0 * (qx * qx + qz * qz), 2.0 * (qy * qz - qw * qx),       0.0,
		2.0 * (qx * qz - qw * qy),       2.0 * (qy * qz + qw * qx),       1.0 - 2.0 * (qx * qx + qy * qy), 0.0,
		0.0,                             0.0,                             0.0,                             1.0
	)
	return m
end

function QUATERNION:Unpack() return self.w, self.x, self.y, self.z end
function QUATERNION:__tostring() return string.format("%f %f %f %f", self:Unpack()) end

local vec = FindMetaTable("Vector")
function vec:Copy()
	return Vector(self.x, self.y, self.z)
end

function math.TimedSinWave(freq, min, max)
	min = (min + max) / 2
	return math.SinWave(RealTime(), freq, min - max, min)
end

function math.SinWave(x, freq, amp, offset)
	return math_sin(2 * math.pi * freq * x) * amp + offset
end

if CLIENT then
	function surface.DrawRing(x, y, radius, thick, angle, segments, fill, rotation)
		angle = math.Clamp(angle or 360, 1, 360)
		fill = math.Clamp(fill or 1, 0, 1)
		rotation = rotation or 0

		local segang = angle / segments
		local bigradius = radius + thick

		for i = 1, math.Round(segments * fill) do
			local ang1 = math_rad(rotation + (i - 1) * segang)
			local ang2 = math_rad(rotation + i * segang)

			local sin1, cos1 = math_sin(ang1), -math_cos(ang1)
			local sin2, cos2 = math_sin(ang2), -math_cos(ang2)

			surface.DrawPoly({
				{ x = x + sin1 * radius, y = y + cos1 * radius },
				{ x = x + sin1 * bigradius, y = y + cos1 * bigradius },
				{ x = x + sin2 * bigradius, y = y + cos2 * bigradius },
				{ x = x + sin2 * radius, y = y + cos2 * radius }
			})
		end
	end
end

function AddTables(tab1, tab2)
	for k, v in pairs(tab2) do
		if tab1[k] and istable(v) then
			AddTables(tab1[k], v)
		else
			tab1[k] = v
		end
	end
end

INI_LOADER_VERSION = "GMOD 1.0"

local function WriteSections(f, tab)
	local d = file.Open(f, "w", "DATA")
	if not d then error("Failed to open " .. f) end

	d:Write("# INI library by danx91 version: " .. INI_LOADER_VERSION)

	for k, v in pairs(tab) do
		d:Write("\n\n[" .. k .. "]")
		for _k, _v in pairs(v) do
			d:Write("\n" .. _k .. " = " .. tostring(_v))
		end
	end
	d:Close()
end

local function CreateSections(tab, name, prefix, sections, char)
	local n = prefix .. char .. name
	sections[n] = {}
	for k, v in pairs(tab) do
		local vType = type(v)
		if vType == "table" then
			CreateSections(v, k, n, sections, char)
		elseif vType ~= "function" and vType ~= "userdata" then
			sections[n][k] = v
		end
	end
end

local function ParseFile(path)
	local f = file.Open(path, "r", "DATA")
	if not f then error("Failed to open " .. path) end

	local tab = {}
	local activetab
	local line_i = 0

	while true do
		local line = f:ReadLine()
		if not line then break end
		
		line_i = line_i + 1
		if not line:match("^%s*#") and not line:match("^%s+$") then
			local section = line:match("%s*%[(%S+)%]")
			if section then
				tab[section] = {}
				activetab = section
			end

			local key, value = line:match("%s*(.+)%s+=%s*(.*%S+)%s*")
			if key and value then
				if value == "true" then value = true
				elseif value == "false" then value = false
				elseif tonumber(value) then value = tonumber(value) end
				
				if activetab and tab[activetab] then
					tab[activetab][key] = value
				end
			end

			if not section and not key and not value then
				f:Close()
				error("Unexpected char at line " .. line_i .. " in file " .. path)
			end
		end
	end

	f:Close()
	return tab
end

function util.LoadINI(f, target)
	local data = ParseFile(f)
	if not data._ini or not data._GLOBAL then return end

	local char = data._ini.char
	local version = data._ini.version
	if not char then return end

	if not version or version ~= INI_LOADER_VERSION then
		MsgC(Color(255, 50, 50), "Version of file and parser is different!\n\tFile: " .. f .. "\n\tVersion of parser: " .. INI_LOADER_VERSION .. "\n\tVersion of file: " .. (version or "Undefined") .. "\n")
	end

	local result = target or {}
	for k, v in pairs(data._GLOBAL) do result[k] = v end

	for k, v in pairs(data) do
		if k ~= "_ini" and k ~= "_GLOBAL" then
			local stack = {}
			for s in string.gmatch(k, "[^%" .. char .. "]+") do
				table.insert(stack, s)
			end

			local parent
			for i = 1, #stack do
				if not parent then
					result[stack[i]] = result[stack[i]] or {}
					parent = result[stack[i]]
				else
					parent[stack[i]] = parent[stack[i]] or {}
					parent = parent[stack[i]]
				end
				if i == #stack then
					for _k, _v in pairs(v) do parent[_k] = _v end
				end
			end
		end
	end

	return result
end

function util.WriteINI(f, data, ignoretables, customchar)
	customchar = customchar or "."
	local sections = {
		_GLOBAL = {},
		_ini = { char = customchar, version = INI_LOADER_VERSION }
	}
	
	for k, v in pairs(data) do
		if type(v) ~= "table" then
			sections._GLOBAL[k] = v
		else
			sections[k] = {}
			for _k, _v in pairs(v) do
				local vType = type(_v)
				if vType ~= "table" and vType ~= "function" and vType ~= "userdata" then
					sections[k][_k] = _v
				elseif vType == "table" and not ignoretables then
					CreateSections(_v, _k, k, sections, customchar)
				end
			end
		end
	end
	
	WriteSections(f, sections)
end

_TimersCache = _TimersCache or {}

Timer = {}
Timer.__index = Timer

function Timer:Create(name, time, repeats, callback, endcallback, noactivate, nocache)
	if not name or not time or not repeats or not callback then return end
	local t = setmetatable({}, Timer)
	t.name = name
	t.time = time
	t.repeats = repeats
	t.callback = callback
	t.endcallback = endcallback
	t.current = 0
	t.ncall = 0
	t.alive = false
	t.destroyed = false
	t.Create = function() end

	if not nocache then
		_TimersCache[name] = t
	end

	if not noactivate then
		t:Start()
	end

	return t
end

function Timer:GetName()
	if self.destroyed then return end
	return self.name
end

function Timer:Stop()
	if self.destroyed then return end
	self.alive = false
end

function Timer:Start()
	if self.destroyed then return end
	self.alive = true
	self.ncall = CurTime() + self.time
end

function Timer:Reset()
	if self.destroyed then return end
	self.current = 0
end

function Timer:Change(time, repeats)
	if self.destroyed then return end
	if time then self.time = time end
	if repeats then self.repeats = repeats end
end

function Timer:StopReset()
	if self.destroyed then return end
	self:Stop()
	self:Reset()
end

function Timer:Destroy()
	if self.destroyed then return end
	self.destroyed = true
	_TimersCache[self.name] = nil
	self.alive = false
end

function Timer:Tick()
	if self.destroyed then return end

	self.ncall = self.ncall + self.time
	self.current = self.current + 1
	self.callback(self, self.current)

	if self.repeats > 0 and self.current >= self.repeats then
		self:Destroy()
		if self.endcallback then self.endcallback() end
	end
end

setmetatable(Timer, { __call = Timer.Create })

function GetTimer(name)
	return _TimersCache[name]
end

hook.Add("Tick", "TimersTick", function()
	local ct = CurTime()
	for k, v in pairs(_TimersCache) do
		if v.alive and v.ncall <= ct then
			v:Tick()
		end
	end
end)

if CLIENT then
   -- Is screenpos on screen?
   function IsOffScreen(scrpos)
      return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
   end
end

function AccessorFuncDT(tbl, varname, name)
   tbl["Get" .. name] = function(s) return s.dt and s.dt[varname] end
   tbl["Set" .. name] = function(s, v) if s.dt then s.dt[varname] = v end end
end

function util.PaintDown(start, effname, ignore)
   local btr = util.TraceLine({start=start, endpos=(start + Vector(0,0,-256)), filter=ignore, mask=MASK_SOLID})

   util.Decal(effname, btr.HitPos+btr.HitNormal, btr.HitPos-btr.HitNormal)
end

local function DoBleed(ent)
   if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror())) then
      return
   end

   local jitter = VectorRand() * 30
   jitter.z = 20

   util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
end

-- Something hurt us, start bleeding for a bit depending on the amount
function util.StartBleeding(ent, dmg, t)
   if dmg < 5 or not IsValid(ent) then
      return
   end

   if ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror()) then
      return
   end

   local times = math.Clamp(math.Round(dmg / 15), 1, 20)

   local delay = math.Clamp(t / times , 0.1, 2)

   if ent:IsPlayer() then
      times = times * 2
      delay = delay / 2
   end

   timer.Create("bleed" .. ent:EntIndex(), delay, times,
                function() DoBleed(ent) end)
end