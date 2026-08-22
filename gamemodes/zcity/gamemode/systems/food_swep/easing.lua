FoodSwep.ANIMATION_LINEAR = 0
FoodSwep.ANIMATION_EASE_IN = 1
FoodSwep.ANIMATION_EASE_OUT = 2
FoodSwep.ANIMATION_EASE_IN_EASE_OUT = 3
FoodSwep.ANIMATION_EASE_OUT_EASE_IN = 4
FoodSwep.ANIMATION_EASE_IN_EASE_IN = 5
FoodSwep.ANIMATION_EASE_OUT_EASE_OUT = 6
FoodSwep.ANIMATION_EASE_DRINK = 7

FoodSwep.EasingFunctions = {}

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_LINEAR] = function(animationTime)
    return animationTime
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_IN] = function(animationTime)
    return animationTime * animationTime
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_OUT] = function(animationTime)
    return animationTime * (2 - animationTime)
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_IN_EASE_OUT] = function(animationTime)
    local frac = 0

    if animationTime > 0.5 then
        frac = (1 - animationTime) * 2
        frac = frac * frac
    else
        frac = (animationTime * 2)
        frac = frac * (2 - frac)
    end
    return frac
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_DRINK] = function(animationTime)
    local idleFactor = 0.05
    local frac = 0

    if animationTime < 0.3 then
        frac = animationTime / 0.3 -- 0 to 1 real 0.3
        frac = frac * (2 - frac)
    else
        if animationTime < 0.8 then
            frac = 1 + (((animationTime - 0.3) / 0.5) * idleFactor) -- 0 to 1.5 real 0.7-0.8
        else
            frac = (1 + idleFactor) - (((animationTime - 0.8) / 0.2) * (1 + idleFactor))
            frac = frac * frac
        end
    end
    return frac
end
