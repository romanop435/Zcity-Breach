local DONATELIST = {}
DONATELIST.discount = 0
DONATELIST.levelprice = 1

local desc_premium = "l:desc_premium"
local desc_premium_plus = "l:desc_premium_plus"
local desc_newbiekit = "l:desc_newbiekit"
local desc_activewarn = "l:desc_activewarn"
local desc_penalty = "l:desc_penalty"
local desc_unmute = "l:desc_unmute"
local desc_ungag = "l:desc_ungag"
local desc_unban = "l:desc_unban"
local desc_prefix = "l:desc_prefix"
local desc_prefix_rainbow = "l:desc_prefix_rainbow"
local desc_admin = "l:desc_admin"

local desc_buffchemist = "l:desc_tf2pyro"
local desc_thiccboy = "l:desc_thiccboy"

DONATELIST.Info = "l:donate_paymenttype"
local levellistcockers = {function(n) return true, 50 end,}
local premlistcockers = {function(n) return true, 10 end,}
function DonationGetDiscount(n) 
    return math.Round(n * ((100 - DONATELIST.discount) / 100), 2)
end

function CalculateRequiredMoneyForLevel(curlevel, amount)
    local total = 0
    for i = curlevel + 1, curlevel + amount do
        for d = 1, #levellistcockers do
            local f = levellistcockers[d]
            local v, mune = f(i)
            if v then
                total = total + mune
                break
            end
        end
    end
    return total
end

function CalculateRequiredMoneyForLevel2(curlevel, amount)
    local total = 0
    for i = curlevel + 1, curlevel + amount do
        for d = 1, #premlistcockers do
            local f = premlistcockers[d]
            local v, mune = f(i)
            if v then
                total = total + mune
                break
            end
        end
    end
    return total
end

function CalculateNewbiekit(curlevel)
    local priceforprem = CalculateRequiredMoneyForLevel2(curlevel, 10)
    local priceforlevel = CalculateRequiredMoneyForLevel(curlevel, 50)
    return math.Round((priceforprem + priceforlevel) * 0.7, 2)
end

donate_pricetag = {
    
    
    ["premium"] = CalculateRequiredMoneyForLevel2,
    
    ["awarn"] = 50,
    ["penalty"] = 20,
    ["level"] = CalculateRequiredMoneyForLevel,
    ["prefix"] = {150, 290,},
    ["tf2pyro"] = 449,
    ["thiccboy"] = 349
}

function GetDonationPrice(type, id, mylevel, level)
    if id == 0 then return 0 end
    local d = donate_pricetag[type]
    if isfunction(d) then return d(mylevel, level) end
    if istable(d) then return d[id] end
    return d
end

DONATELIST.categories = {
    {
        name = "l:donationtitle_prem",
        items = {
            
            
            
            
            
            
            
            
            
            
            
            
            {
                name = "l:donationtitle_prem",
                ispremcock = true,
                price = 0,
                predesc = "10 рублей / день",
                icon = Material("donate/prem.png"),
            },
        },
        
    },
    {
        name = "l:donate_other",
        items = {
            {
                name = "l:donate_awarn",
                desc = desc_activewarn,
                uid = "warn",
                price = GetDonationPrice("awarn"),
                predesc = "50 рублей",
                icon = Material("donate/warn.png")
            },
            {
                name = "l:donate_penalty",
                desc = desc_penalty,
                uid = "shtraf",
                price = GetDonationPrice("penalty"),
                predesc = "20 рублей",
                icon = Material("donate/straf.png")
            },
            {
                name = "l:donate_level",
                islevelcock = true,
                price = 0,
                predesc = "50 рублей / уровень",
                icon = Material("donate/lvl.png")
            },
            
            
            
            
            
            
            
            
            
            
            
            
        },
    },

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

return DONATELIST