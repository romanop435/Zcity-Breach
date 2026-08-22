local tonumber = tonumber
local tostring = tostring
local CurTime = CurTime
local Entity = Entity
local table = table
local pairs = pairs
local timer = timer
local ents = ents
local hook = hook
local math = math
local pcall = pcall
local ErrorNoHalt = ErrorNoHalt
local util = util
local net = net



local mply = FindMetaTable("Player")
local ment = FindMetaTable("Entity")

util.AddNetworkString("AskInventoryData")
util.AddNetworkString("SendInventoryData")
util.AddNetworkString("InventoryTakeItem")
util.AddNetworkString("InventoryTakeHands")
util.AddNetworkString("InventoryDropItem")
util.AddNetworkString("InventoryDropAmmo")
util.AddNetworkString("InventoryDragAnDrop")
util.AddNetworkString("SendInventoryDataOper")
util.AddNetworkString("InventoryTakeVictimItem")
util.AddNetworkString("InventoryDropVictimItem")
util.AddNetworkString("InventoryEffect_CQC")
util.AddNetworkString("InventoryEffect_checker")
util.AddNetworkString("InventoryEffect_cannibal")
util.AddNetworkString("SendInventoryDataTryp")
util.AddNetworkString("InventoryTakeVictimAmmo")
util.AddNetworkString("SetFrequency")
util.AddNetworkString("RadioHooks")
util.AddNetworkString("GetRadioChannel")

function InventoryGetFreeSlots(ply)
    local count = 12
    if not ply.Inventory or not ply.Inventory["Items"] then return 0 end
    for k, v in pairs(ply.Inventory["Items"]) do
        if not table.IsEmpty(v) then count = count - 1 end
    end
    return count
end

function InventoryGetFreeSlot(ply)
    local count = 0
    if not ply.Inventory or not ply.Inventory["Items"] then return 1 end
    for k, v in pairs(ply.Inventory["Items"]) do
        count = count + 1
        if table.IsEmpty(v) then return count end
    end
    return count + 1
end

function mply:MarkInventoryChanged()
    local newVersion = (self:GetNWInt("InvVersion", 0) + 1)
    self:SetNWInt("InvVersion", newVersion)
end

local function SendInventoryData(ply)
    if not ply.Inventory or not ply.Inventory["Items"] then return end
    local copy_table = table.Copy(ply.Inventory)
    for k, v in pairs(copy_table["Items"]) do
        if v.class == "item_drink_294" then
            v.effect = nil
            v.scp294 = nil
        end
    end
    net.Start("SendInventoryDataOper")
    net.WriteTable(copy_table)
    net.Send(ply)
    ply:MarkInventoryChanged()
end

local function GetWeaponInvData(wep)
    if not IsValid(wep) then return {} end
    local data = { class = wep:GetClass() }

    if wep.GetInventoryData then
        table.Merge(data, wep:GetInventoryData())
        return data
    end

    if wep.ishgwep or wep.Base == "homigrad_base" or wep.Base == "weapon_base" then
        data.Clip = wep:Clip1()
        data.drawBullet = wep.drawBullet
        data.hg_atts = wep.attachments and table.Copy(wep.attachments) or {}

        if wep.Drum then data.Drum = table.Copy(wep.Drum) end
        if wep.Tube then data.Tube = table.Copy(wep.Tube) end
        if wep.GetChamber then data.Chamber = wep:GetChamber() end
        if wep.newammotype then data.newammotype = wep.newammotype end
    end

    if data.class == "item_radio" then data.RadioChannel = wep.Channel end
    if data.class == "item_tazer" then data.Clip = wep:Clip1() end
    if data.class:find("item_medkit_") then data.Heal_Left = wep.Heal_Left or (weapons.GetStored(data.class) and weapons.GetStored(data.class).Heal_Left) end
    if data.class == "item_drink_294" then
        data.scp294 = wep.SCP294
        data.effect = wep.effect
        data.drink = wep.drink
        data.sip = wep.sip
    end
    if wep.CW20Weapon then
        local attachmentsCopy = {}
        for k, v in pairs(wep.ActiveAttachments or {}) do
            if v == true then attachmentsCopy[k] = v end
        end
        data.Atach = attachmentsCopy
        data.Clip = wep:Clip1()
    end

    return data
end

local function ApplyWeaponInvData(wep, data)
    if not IsValid(wep) then return end
    
    if wep.ApplyInventoryData then
        wep:ApplyInventoryData(data)
        return
    end

    if wep.ishgwep or wep.Base == "homigrad_base" or wep.Base == "weapon_base" then
        if data.newammotype and wep.ApplyAmmoChanges then
            wep:ApplyAmmoChanges(data.newammotype)
        end

        timer.Simple(0.15, function()
            if not IsValid(wep) then return end
            
            if data.Clip ~= nil then wep:SetClip1(data.Clip) end
            if data.drawBullet ~= nil then 
                wep.drawBullet = data.drawBullet 
                if SERVER and wep.SetNetVar then
                    wep:SetNetVar("drawBullet", data.drawBullet)
                end
            end

            if data.Drum then
                wep.Drum = table.Copy(data.Drum)
                if wep.SendDrum then wep:SendDrum() end
            end

            if data.Tube then wep.Tube = table.Copy(data.Tube) end
            if data.Chamber and wep.SetChamber then wep:SetChamber(data.Chamber) end

            if data.hg_atts then
                wep.attachments = table.Copy(data.hg_atts)
                if SERVER and wep.SetNetVar then
                    wep:SetNetVar("attachments", wep.attachments)
                end
            end
        end)
    end

    if data.class == "item_radio" and data.RadioChannel then wep.Channel = data.RadioChannel end
    if data.class == "item_tazer" and data.Clip then wep:SetClip1(data.Clip) end
    if data.class:find("item_medkit_") and data.Heal_Left then wep.Heal_Left = data.Heal_Left end
    if data.class == "item_drink_294" then
        wep.SCP294 = data.scp294
        wep.effect = data.effect
        wep.drink = data.drink
        wep.sip = data.sip
    end
    if wep.CW20Weapon then
        local attachmentsCopy = {}
        for k, v in pairs(data.Atach or {}) do
            if v == true then attachmentsCopy[k] = v end
        end
        wep.ActiveAttachments = attachmentsCopy
        wep:SetClip1(data.Clip or 0)
        for k, v in pairs(wep.ActiveAttachments) do
            if v then
                wep:attachSpecificAttachment(k)
                timer.Simple(0.01, function() if IsValid(wep) then wep:ValidateAttachments() end end)
            end
        end
    end
end

function mply:BreachGive(wep, customtable)
    self.JustSpawned = true
    self.JustSpawned = false

    if InventoryGetFreeSlots(self) == 0 then return end
    local freeSlot = InventoryGetFreeSlot(self)

    if freeSlot > tonumber(self:GetNWInt("InventoryMaxSlots", 8)) then
        local weptable = customtable or {}
        if not weptable.class then weptable.class = wep end 
        
        local prop = ents.Create(wep)
        local eyePos = self:GetPos() + Vector(0, 0, 30)
        local eyeAng = self:EyeAngles()
        eyeAng:RotateAroundAxis(eyeAng:Up(), 90)

        prop:SetPos(eyePos)
        prop:SetAngles(self:GetAngles())
        prop:Spawn()
        prop:Activate()

        local physObj = prop:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:SetVelocity(Vector(eyeAng:Right() * 300))
        end

        ApplyWeaponInvData(prop, weptable)
        if prop:GetClass() == "item_special_document" then self:SetNWBool("HasDocument", false) end
        return
    end

    local itemtable = customtable or {}
    if not itemtable.class then
        itemtable.class = wep 
    end

    self.Inventory["Items"][freeSlot] = itemtable
    SendInventoryData(self)
end

function mply:RemoveItem(id)
    self.NextInvDropAction = CurTime() + 0.25
    self.Inventory["Items"][id] = {}
    if self:GetNWInt("ActiveSlot") == id then
        self:SetNWInt("ActiveSlot", 0)
        local last_weapon = self:GetActiveWeapon()
        if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
            last_weapon:Remove()
        end
        self:SelectWeapon("br_holster")
    end
    SendInventoryData(self)
end

function mply:RemoveItemClass(class)
    self.NextInvDropAction = CurTime() + 0.25
    for k, v in pairs(self.Inventory["Items"]) do
        if v.class == class then
            self.Inventory["Items"][k] = {}
            SendInventoryData(self)
            return
        end
    end
end

function mply:IIDrop(id)
    if (self.NextInvDropAction or 0) > CurTime() then return end
    self.NextInvDropAction = CurTime() + 0.25

    if id == 0 or not self.Inventory or not self.Inventory["Items"] or table.IsEmpty(self.Inventory["Items"][id] or {}) then return end
    
    local dropData = self.Inventory["Items"][id]
    if not dropData.class or not weapons.GetStored(dropData.class) then return end
    
    local wepInfo = weapons.GetStored(dropData.class)
    if wepInfo.droppable == false or wepInfo.UnDroppable then return end
    
    if dropData.class == "item_scp_1499" and self:GetPos().y < -13000 then return end

    if BREACH and BREACH.AdminLogs then
        BREACH.AdminLogs:Log("drop", {
            user = self,
            weapon = wepInfo.PrintName or dropData.class
        })
    end

    local activeSlot = tonumber(self:GetNWInt("ActiveSlot", 0))
    
    if activeSlot == id then
        local last_weapon = self:GetActiveWeapon()
        if IsValid(last_weapon) and last_weapon:GetClass() == dropData.class then
            dropData = GetWeaponInvData(last_weapon)
            if last_weapon:GetClass() == "item_special_document" then self:SetNWBool("HasDocument", true) end
            last_weapon:Remove() 
        end
        self:SetNWInt("ActiveSlot", 0)
        self:SelectWeapon("br_holster")
    end

    local itemDataToSpawn = table.Copy(dropData)
    self.Inventory["Items"][id] = {}

    local success, err = pcall(function()
        local prop = ents.Create(itemDataToSpawn.class)
        local eyePos = self:GetPos() + Vector(0, 0, 30)
        local eyeAng = self:EyeAngles()
        eyeAng:RotateAroundAxis(eyeAng:Up(), 90)

        prop:SetPos(eyePos)
        prop:SetAngles(self:GetAngles())
        prop:Spawn()
        prop:Activate()

        local physObj = prop:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:SetVelocity(Vector(eyeAng:Right() * 300))
        end

        ApplyWeaponInvData(prop, itemDataToSpawn)
        if prop:GetClass() == "item_special_document" then self:SetNWBool("HasDocument", false) end
    end)

    if not success then
        ErrorNoHalt("Ошибка при выбросе предмета: " .. tostring(err) .. "\n")
        self.Inventory["Items"][id] = itemDataToSpawn
    end

    if self:Health() > 0 and IsValid(self.NVG_Bonemerged) then
        local nvgEquipped = self.NVG_Bonemerged:GetModel()
        local nvgMatched = (nvgEquipped == "models/imperator/items/nightvision/bonemerge_nvg_forface_green.mdl" and itemDataToSpawn.class == "item_nightvision_green") or
                           (nvgEquipped == "models/imperator/items/nightvision/bonemerge_nvg_forface_blue.mdl" and itemDataToSpawn.class == "item_nightvision_blue") or
                           (nvgEquipped == "models/imperator/items/nightvision/bonemerge_nvg_forface_white.mdl" and (itemDataToSpawn.class == "item_nightvision_white" or itemDataToSpawn.class == "item_nightvision_goc")) or
                           (nvgEquipped == "models/imperator/items/nightvision/bonemerge_nvg_forface_red.mdl" and itemDataToSpawn.class == "item_nightvision_red")
        
        if nvgMatched and not self:IIHasWeapon(itemDataToSpawn.class) then
            self.NVG_Bonemerged:Remove()
            BREACH.SendClientEvent(self, "clear_nvg")
            net.Start("NightvisionOff") net.Send(self)
        end
    end

    if self.GASMASK_Equiped and not self:IIHasWeapon("gasmask") then
        self.GASMASK_Ready = false
        self:GASMASK_SetEquipped(false)
        self:GASMASK_RequestToggle()
    end

    SendInventoryData(self)
end

net.Receive("AskInventoryData", function(len, ply)
    SendInventoryData(ply)
end)

net.Receive("InventoryDragAnDrop", function(len, ply)
    local old = net.ReadInt(8)
    local new = net.ReadInt(8)
    if new > tonumber(ply:GetNWInt("InventoryMaxSlots", 8)) then SendInventoryData(ply) return end

    local activeSlot = tonumber(ply:GetNWInt("ActiveSlot", 0))
    
    if activeSlot == old or activeSlot == new then
        local last_weapon = ply:GetActiveWeapon()
        if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
            if ply.Inventory["Items"][activeSlot] and ply.Inventory["Items"][activeSlot].class == last_weapon:GetClass() then
                ply.Inventory["Items"][activeSlot] = GetWeaponInvData(last_weapon)
            end
            if last_weapon.ActiveAttachments then table.Empty(last_weapon.ActiveAttachments) end
            last_weapon:Remove()
        end
        ply:SetNWInt("ActiveSlot", 0)
        ply:SelectWeapon("br_holster")
    end

    local slot_data_old = table.Copy(ply.Inventory["Items"][old] or {})
    local slot_data_new = table.Copy(ply.Inventory["Items"][new] or {})
    
    ply.Inventory["Items"][new] = slot_data_old
    ply.Inventory["Items"][old] = slot_data_new

    SendInventoryData(ply)
end)

net.Receive("InventoryTakeItem", function(len, ply)
    if (ply.NextInvAction or 0) > CurTime() then return end
    ply.NextInvAction = CurTime() + 0.3
    ply.NextInvDropAction = CurTime() + 0.3

    local id = net.ReadInt(8)
    local activeSlot = tonumber(ply:GetNWInt("ActiveSlot", 0))
    local last_weapon = ply:GetActiveWeapon()

    if activeSlot ~= 0 and IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
        if ply.Inventory["Items"][activeSlot] and ply.Inventory["Items"][activeSlot].class == last_weapon:GetClass() then
            ply.Inventory["Items"][activeSlot] = GetWeaponInvData(last_weapon)
        end
        if last_weapon:GetClass() == "item_special_document" then ply:SetNWBool("HasDocument", true) end
    end

    if not ply.Inventory["Items"][id] or table.IsEmpty(ply.Inventory["Items"][id]) or activeSlot == id then
        ply:SetNWInt("ActiveSlot", 0)
        ply:SelectWeapon("br_holster")
        if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
            if last_weapon.ActiveAttachments then table.Empty(last_weapon.ActiveAttachments) end
            last_weapon:Remove()
        end
        return 
    end

    ply:SetNWInt("ActiveSlot", id)
    ply:SelectWeapon("br_holster")

    if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
        if last_weapon.ActiveAttachments then table.Empty(last_weapon.ActiveAttachments) end
        last_weapon:Remove()
    end

    timer.Simple(0.15, function()
        if not IsValid(ply) or ply:GetNWInt("ActiveSlot", 0) ~= id then return end
        local wData = ply.Inventory["Items"][id]
        if not wData or not wData.class then return end

        ply.JustSpawned = true
        local item = ply:Give(wData.class, true)
        ply.JustSpawned = false

        ApplyWeaponInvData(item, wData)
        ply:SelectWeapon(wData.class)

        if BREACH and BREACH.AdminLogs then
            local wName = wData.class
            local wepStored = weapons.GetStored(wName)
            if wepStored and wepStored.PrintName then wName = wepStored.PrintName end

            BREACH.AdminLogs:Log("pickup", {
                user = ply,
                weapon = wName
            })
        end
    end)
end)

net.Receive("InventoryTakeHands", function(len, ply)
    if (ply.NextInvAction or 0) > CurTime() then return end
    ply.NextInvAction = CurTime() + 0.3

    local id = net.ReadInt(8)
    if not ply.Inventory["Items"][id] or table.IsEmpty(ply.Inventory["Items"][id]) then return end

    local activeSlot = tonumber(ply:GetNWInt("ActiveSlot", 0))
    local last_weapon = ply:GetActiveWeapon()

    if activeSlot ~= 0 and IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
        if ply.Inventory["Items"][activeSlot] and ply.Inventory["Items"][activeSlot].class == last_weapon:GetClass() then
            ply.Inventory["Items"][activeSlot] = GetWeaponInvData(last_weapon)
        end
        if last_weapon:GetClass() == "item_special_document" then ply:SetNWBool("HasDocument", true) end
    end

    ply:SetNWInt("ActiveSlot", 0)
    ply:SelectWeapon("br_holster")
    
    if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
        if last_weapon.ActiveAttachments then table.Empty(last_weapon.ActiveAttachments) end
        last_weapon:Remove()
    end
    SendInventoryData(ply)
end)

net.Receive("InventoryDropItem", function(len, ply)
    local id = net.ReadInt(8)
    ply:IIDrop(id)
end)

local function GetAmmoModel(ammotype)
    local name = string.lower(game.GetAmmoName(ammotype) or "")
    if name:find("pistol") then return "models/Items/BoxSRounds.mdl" end
    if name:find("357") or name:find("revolver") then return "models/Items/357ammo.mdl" end
    if name:find("smg") or name:find("ar2") then return "models/Items/BoxMRounds.mdl" end
    if name:find("buckshot") or name:find("shotgun") then return "models/Items/BoxBuckshot.mdl" end
    return "models/Items/BoxSRounds.mdl"
end

net.Receive("InventoryDropAmmo", function(len, ply)
    if not IsValid(ply) or not ply:Alive() or ply:GTeam() == TEAM_SPEC then return end
    if (ply.NextInvDropAction or 0) > CurTime() then return end
    
    local ammotype = net.ReadUInt(16)
    local amount = net.ReadUInt(16)

    if amount <= 0 then return end
    
    local plyAmmo = ply:GetAmmoCount(ammotype)
    if plyAmmo < amount then amount = plyAmmo end
    if amount <= 0 then return end

    if BREACH and BREACH.AdminLogs then
        local aName = BREACH.AmmoTranslation[game.GetAmmoName(ammotype)] or game.GetAmmoName(ammotype) or "Unknown"
        BREACH.AdminLogs:Log("drop", {
            user = ply,
            weapon = "Патроны " .. aName .. " x" .. amount
        })
    end

    ply.NextInvDropAction = CurTime() + 0.25
    ply:RemoveAmmo(amount, ammotype)

    local prop = ents.Create("prop_physics")
    prop:SetModel(GetAmmoModel(ammotype))
    local eyePos = ply:EyePos() + (ply:GetAimVector() * 40)
    prop:SetPos(eyePos)
    prop:SetAngles(ply:EyeAngles())
    prop:Spawn()
    prop:Activate()
    
    prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    prop.IsDroppedAmmo = true
    prop.AmmoType = ammotype
    prop.Amount = amount

    local physObj = prop:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:SetVelocity(ply:GetAimVector() * 150)
        physObj:Wake()
    end

    local index = prop:EntIndex()
    timer.Create("AmmoMerge_" .. index, 1, 0, function()
        if not IsValid(prop) then 
            timer.Remove("AmmoMerge_" .. index) 
            return 
        end
        if prop.IsMerging then return end
        
        local nearby = ents.FindInSphere(prop:GetPos(), 40)
        for _, v in ipairs(nearby) do
            if v ~= prop and IsValid(v) and v.IsDroppedAmmo and not v.IsMerging then
                if v.AmmoType == prop.AmmoType then
                    prop.IsMerging = true
                    v.Amount = v.Amount + prop.Amount
                    
                    local newScale = math.Clamp(1 + (v.Amount / 300) * 0.2, 1, 1.5)
                    v:SetModelScale(newScale, 0.2)

                    prop:Remove()
                    timer.Remove("AmmoMerge_" .. index)
                    return
                end
            end
        end
    end)
end)


hook.Add("KeyPress", "ItemPickup_SHAKY", function(ply, butt)
    if butt == IN_USE and ply:GTeam() ~= TEAM_SPEC and ply:GTeam() ~= TEAM_SCP and ply:Health() > 0 then
        
        local startPos, aimDirScaled, filter = hg.eye(ply, 150)
        if not startPos then 
            startPos = ply:GetShootPos() 
            aimDirScaled = ply:GetAimVector() * 150
            filter = ply
        end
        
        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + aimDirScaled,
            filter = filter
        })
        
        local wepent = tr.Entity

        if not IsValid(wepent) or (not wepent:IsWeapon() and not wepent.IsDroppedAmmo) then
            tr = util.TraceHull({
                start = startPos,
                endpos = startPos + aimDirScaled,
                mins = Vector(-8, -8, -8),
                maxs = Vector(8, 8, 8),
                filter = filter
            })
            wepent = tr.Entity
        end

        if not IsValid(wepent) then return end
        if not wepent:IsWeapon() and not wepent.IsDroppedAmmo then return end
        if wepent:GetPos():DistToSqr(startPos) > 15000 then return end 
        
        if wepent.IsDroppedAmmo then
            if (ply.NextAmmoPickup or 0) > CurTime() then return end
            ply.NextAmmoPickup = CurTime() + 0.1
            
            local ammo_limits = { ["Pistol"] = 60, ["Revolver"] = 30, ["SMG1"] = 120, ["AR2"] = 120, ["Shotgun"] = 80, ["Sniper"] = 30, ["RPG_Rocket"] = 2, ["GOC"] = 120, ["GRU"] = 120 }
            local ammo_name = game.GetAmmoName(wepent.AmmoType)
            local limit = ammo_limits[ammo_name] or 120
            local curAmmo = ply:GetAmmoCount(wepent.AmmoType)
            
            if curAmmo >= limit then
                ply:BrTip( 0, "[Патроны]", Color(255, 0, 0), "Максимум патронов этого типа!", Color(255, 255, 255) )
                return
            end
            
            local toGive = wepent.Amount
            if curAmmo + toGive > limit then
                toGive = limit - curAmmo
                wepent.Amount = wepent.Amount - toGive
                ply:GiveAmmo(toGive, wepent.AmmoType, true)
                ply:EmitSound("items/ammo_pickup.wav", 50, math.random(95, 105))
                return
            end
            
            ply:GiveAmmo(toGive, wepent.AmmoType, true)
            ply:EmitSound("items/ammo_pickup.wav", 50, math.random(95, 105))
            wepent:Remove()
            return
        end

        local ent_class = wepent:GetClass()
        if ply:GTeam() ~= TEAM_CBG and ent_class == "kasanov_cbg_cog" then
            ply.NextPickup = CurTime() + 1
            return
        end

        local maximumdefaultslots = ply:GetMaxSlots()
        local maximumitemsslots = 6
        local maximumnotdroppableslots = 6

        local countdefault, countitem, countnotdropable = 0, 0, 0
        for _, weapon in ipairs(ply:GetWeapons()) do
            if not weapon.Equipableitem and not weapon.UnDroppable then countdefault = countdefault + 1
            elseif weapon.Equipableitem then countitem = countitem + 1
            elseif weapon.UnDroppable then countnotdropable = countnotdropable + 1 end
        end

        if not wepent.Equipableitem and not wepent.UnDroppable and countdefault >= maximumdefaultslots then
            ply:setBottomMessage("l:inventory_full") return
        elseif wepent.Equipableitem and countitem >= maximumitemsslots then
            ply:setBottomMessage("l:secondary_inventory_full") return
        elseif wepent.UnDroppable and countnotdropable >= maximumnotdroppableslots then
            ply:setBottomMessage("l:inventory_full") return
        end

        local physobj = wepent:GetPhysicsObject()
        if IsValid(physobj) then physobj:EnableMotion(false) end

        local function finishcallback()
            if not IsValid(wepent) or wepent:GetOwner() == ply then return end
            
            local checkCamPos = hg.eye(ply) or ply:GetShootPos()
            if wepent:GetPos():DistToSqr(checkCamPos) > 20000 then return end

            ply.Shaky_PICKUPWEAPON = wepent

            if wepent:GetClass() == "item_drink_294" and wepent.drink == "tnt" then
                ply:CompleteAchievement("tnt")
                local current_pos = ply:GetPos()
                ply.abouttoexplode = nil
                ply.burnttodeath = true
                local dmg_info = DamageInfo()
                dmg_info:SetDamage(2000)
                dmg_info:SetDamageType(DMG_BLAST)
                dmg_info:SetAttacker(ply)
                dmg_info:SetDamageForce(-ply:GetAimVector() * 40)
                util.BlastDamageInfo(dmg_info, ply:GetPos(), 400)
                sound.Play("nextoren/others/explosion_ambient_" .. math.random(1, 2) .. ".ogg", current_pos, 100, 100, 100)
                net.Start("CreateParticleAtPos") net.WriteString("pillardust") net.WriteVector(current_pos) net.Broadcast()
                net.Start("CreateParticleAtPos") net.WriteString("gas_explosion_main") net.WriteVector(current_pos) net.Broadcast()
                wepent:Remove()
                return
            end

            local customtable = GetWeaponInvData(wepent)
            if wepent:GetClass() == "item_special_document" then ply:SetNWBool("HasDocument", true) end

            ply:BreachGive(wepent:GetClass(), customtable)
            ply:EmitSound("^nextoren/charactersounds/inventory/nextoren_inventory_itemreceived.wav")
            wepent:Remove()
        end

        local function stopcallback()
            if IsValid(wepent) and IsValid(wepent:GetPhysicsObject()) then
                wepent:GetPhysicsObject():EnableMotion(true)
            end
        end

        ply:BrProgressBar("l:progress_wait", 0.5, "nextoren/gui/new_icons/hand.png", wepent, false, finishcallback, nil, stopcallback)
    end
end)

hook.Add("PlayerTick", "CheckEmptyHands", function(ply, mv)
    if (ply.NextHolsterCheck or 0) > CurTime() then return end
    ply.NextHolsterCheck = CurTime() + 1.0
    
    if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then
        if ply:HasWeapon("br_holster") then ply:StripWeapon("br_holster") end
        return
    end

    if ply:Alive() and not IsValid(ply:GetActiveWeapon()) then
        if not ply:HasWeapon("br_holster") then
            ply.JustSpawned = true
            ply:Give("br_holster", true)
            ply.JustSpawned = false
        end
        ply:SelectWeapon("br_holster")
    end
end)

net.Receive("SetFrequency", function(len, ply)
    local wep = net.ReadEntity()
    local freq = net.ReadFloat()
    if not IsValid(wep) then return end
    freq = tonumber(string.sub(tostring(freq), 1, 5))
    wep.Channel = freq
    if wep.SetKeyRedact then wep:SetKeyRedact(false) end
end)

hook.Add("PlayerButtonDown", "Radio_TriggerOn_InvNew", function(caller, button)
    if caller:GTeam() == TEAM_SPEC or caller:GTeam() == TEAM_SCP then return end
    if not caller:IIHasWeapon("item_radio") then return end
    if caller:IsFrozen() or caller:GetMoveType() ~= MOVETYPE_WALK then return end
    
    if button == KEY_G then
        if (caller.NextRadioToggle or 0) > CurTime() then return end
        caller.NextRadioToggle = CurTime() + 2

        if not caller:GetNWBool("radio_enbl") then
            caller:SetNWBool("radio_enbl", true)
            caller:EmitSound("radio.toggle")
        else
            caller:SetNWBool("radio_enbl", false)
        end
    end
end)

net.Receive("InventoryEffect_cannibal", function(len, ply)
    if not table.HasValue(GetRoleTableSH(ply:GetRoleName()).weapons, "weapon_cannibal") then return end
    local tr = ply:GetEyeTraceNoCursor()
    local ent = tr.Entity

    if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" or ent:GetModel():find("corpse.mdl") then return end

    local uniqid = "GibSound" .. ply:SteamID64()
    local function start()
        ply:EmitSound("nextoren/others/cannibal/gibbing" .. math.random(1, 3) .. ".wav", 90, 100, 1, CHAN_AUTO)
        timer.Create(uniqid, 1, 8, function()
            if IsValid(ply) then ply:EmitSound("nextoren/others/cannibal/gibbing" .. math.random(1, 3) .. ".wav", 90, 100, 1, CHAN_AUTO) end
        end)
    end
    local function stop() timer.Remove(uniqid) end
    local function finish()
        if IsValid(ent) then
            ent:SetModel("models/cultist/humans/corpse.mdl")
            ent:SetSkin(2)
            ent:SetBodygroup(0, ent.IsFemale and 1 or 0)
            ent.AlreadyEaten = true
            ent.breachsearchable = false

            ply:AddToAchievementPoint("cannibal", 1)
            ply:SetHealth(math.min(ply:Health() + 30, ply:GetMaxHealth() + 40))
            ply:SetMaxHealth(ply:GetMaxHealth() + 40)

            for i, bnmrg in pairs(ent:LookupBonemerges()) do bnmrg:Remove() end
        end
    end

    ply:BrProgressBar("l:cannibal", 8, "nextoren/gui/new_icons/canibal.png", ent, false, finish, start, stop)
end)

net.Receive("InventoryEffect_checker", function(len, ply)
    local Phrases = {
        [TEAM_CLASSD] = "Класс-Д", [TEAM_GOC] = "Класс-Д", [TEAM_SCI] = "ученый",
        [TEAM_SPECIAL] = "учёный", [TEAM_DZ] = "из неизвестной организации",
        [TEAM_USA] = "из неизвестной организации", [TEAM_CHAOS] = "из неизвестной организации",
        [TEAM_SECURITY] = "из Службы Безопасности", [TEAM_QRT] = "из Отряда Быстрого Реагирования",
        [TEAM_NTF] = "из специальной группировки", [TEAM_GUARD] = "из военного персонала",
        [TEAM_OSN] = "из Отряда Специального Назначения"
    }
    if not table.HasValue(GetRoleTableSH(ply:GetRoleName()).weapons, "weapon_checker") then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GTeam() == TEAM_SCP then return end

    ply:BrProgressBar("l:checking_class", 4, "nextoren/gui/new_icons/player_check.png", ent, true, function()
        if not IsValid(ent) then return end
        local t = ent:GTeam()
        if t == TEAM_CLASSD or t == TEAM_CHAOS or t == TEAM_DZ or t == TEAM_USA then
            ply:AddToStatistics("l:checker_bonus", 100)
        end
        if Phrases[t] then
            ply:ConCommand("say Этот человек - " .. Phrases[t] .. ".")
        else
            ply:ConCommand("say Я не знаю кто это.")
        end
        if t == TEAM_GOC or t == TEAM_CHAOS or t == TEAM_DZ then ply:CompleteAchievement("mtfagent") end
    end)
end)

net.Receive("InventoryEffect_CQC", function(len, ply)
    if not table.HasValue(GetRoleTableSH(ply:GetRoleName()).weapons, "weapon_cqc") then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsPlayer() then return end

    if not ply:IsSuperAdmin() then
        if ent:GTeam() == TEAM_SCP then return end
        if ent:GetModel() ~= "models/cultist/humans/mog/mog.mdl" and (ent:GTeam() == TEAM_CLASSD or ent:GTeam() == TEAM_SCI or ent:GTeam() == TEAM_DZ or (ent:GTeam() == TEAM_GOC and ent:GetRoleName() == "ClassD_GOCSpy")) then return end
    end

    local wep = ent:GetActiveWeapon()
    if IsValid(wep) and not wep.UnDroppable then
        ply:BrProgressBar("l:disarming", 2, "nextoren/gui/new_icons/disarm.png", ent, true, function()
            if IsValid(ent) then ent:IIDrop(ent:GetNWInt("ActiveSlot", 0)) end
        end)
    end
end)

net.Receive("InventoryTakeVictimAmmo", function(len, ply)
    local ammoid = net.ReadUInt(16)
    local amount = net.ReadUInt(16)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent.vtable or not ent.Ammo or not ent.Ammo[ammoid] or ent.Ammo[ammoid] < amount then return end

    ent.Ammo[ammoid] = ent.Ammo[ammoid] - amount
    ply:GiveAmmo(amount, game.GetAmmoName(ammoid), true)

    local translated = BREACH.AmmoTranslation[game.GetAmmoName(ammoid)] or game.GetAmmoName(ammoid)
    ply:RXSENDNotify("l:looted_ammo_pt1 " .. translated .. " l:looted_ammo_pt2")
    ply:EmitSound("^items/ammo_pickup.wav", 50, math.random(95, 105), 1, CHAN_REPLACE)
end)

net.Receive("InventoryTakeVictimItem", function(len, ply)
    local id = net.ReadInt(8)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent.vtable or not ent.vtable.Items or not ent.vtable.Items[id] then return end

    local freeSlot = InventoryGetFreeSlot(ply)
    local pointData = table.Copy(ent.vtable.Items[id])

    if pointData and pointData.class then
        local wepInfo = weapons.GetStored(pointData.class)
        if wepInfo and (wepInfo.droppable == false or wepInfo.UnDroppable) then return end
    end

    if freeSlot > tonumber(ply:GetNWInt("InventoryMaxSlots", 8)) then
        local prop = ents.Create(pointData.class)
        local eyePos = ply:EyePos() + (ply:GetAimVector() * 40)
        local eyeAng = ply:EyeAngles()
        eyeAng:RotateAroundAxis(eyeAng:Up(), 90)

        prop:SetPos(eyePos)
        prop:SetAngles(ply:GetAngles())
        prop:Spawn()
        prop:Activate()

        local physObj = prop:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:SetVelocity(Vector(eyeAng:Right() * 325))
        end

        ApplyWeaponInvData(prop, pointData)
        if prop:GetClass() == "item_special_document" then ply:SetNWBool("HasDocument", false) end
    else
        ply.Inventory["Items"][freeSlot] = pointData
        SendInventoryData(ply)
    end
    
    ent.vtable.Items[id] = {}
end)

function BotEquipWeaponBreach(bot, weaponClass)
    if not IsValid(bot) or not bot:IsPlayer() then return end

    if not bot.Inventory then
        bot.Inventory = { Items = {} }
        for i = 1, 12 do
            bot.Inventory["Items"][i] = {}
        end
    end

    local freeSlot = InventoryGetFreeSlot(bot)
    local maxSlots = tonumber(bot:GetNWInt("InventoryMaxSlots", 8))

    if freeSlot > maxSlots then
        freeSlot = 1
    end

    bot.Inventory["Items"][freeSlot] = { class = weaponClass }
    
    if SendInventoryData then
        SendInventoryData(bot)
    end

    local last_weapon = bot:GetActiveWeapon()
    if IsValid(last_weapon) and last_weapon:GetClass() ~= "br_holster" then
        last_weapon:Remove()
    end

    bot:SetNWInt("ActiveSlot", freeSlot)
    bot:SelectWeapon("br_holster")

    timer.Simple(0.15, function()
        if not IsValid(bot) or bot:GetNWInt("ActiveSlot", 0) ~= freeSlot then return end

        bot.JustSpawned = true
        local item = bot:Give(weaponClass, true)
        bot.JustSpawned = false

        bot:SelectWeapon(weaponClass)

        if BREACH and BREACH.AdminLogs then
            local wName = weaponClass
            local wepStored = weapons.GetStored(wName)
            if wepStored and wepStored.PrintName then wName = wepStored.PrintName end

            BREACH.AdminLogs:Log("pickup", {
                user = bot,
                weapon = wName
            })
        end
    end)
end