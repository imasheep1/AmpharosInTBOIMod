local sheepStats = {}

-- This no longer uses direct stat setting as it broke very easily. Using bonuses allows for
-- proper damage multipliers as well. See the key name for what operation should be performed 
-- with it. No denoted operation implies either table insertion or directly setting something.
local bonuses = {
    pure = {
        damageMult = 1.4, fireDelayDiv = 2/3, shotSpeedMult = 1, rangeMult = 1,
        speedBonus = -0.20, luckBonus = -1, tearFlags = {TearFlags.TEAR_JACOBS},
        tearColor = Color(1.0, 0.83, 0.14, 1.0, 0, 0, 0) 
    },
    tainted = {
        damageMult = 1.2, fireDelayDiv = 4/5, shotSpeedMult = 1, rangeMult = 1,
        speedBonus = -0.20, luckBonus = -2, tearFlags = {TearFlags.TEAR_JACOBS},
        tearColor = Color(1.0, 0.83, 0.14, 1.0, 0, 0, 0)
    }
}

local function GetStats(player)
    if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Ampharos", false) then
        return bonuses.pure
    elseif player:GetPlayerType() == Isaac.GetPlayerTypeByName("AmpharosAlt", true) then
        return bonuses.tainted
    else return nil end
end

-- The player's stats are reevaluated each time the player picks up something
-- that changes them. Additive and multiplicative bonuses work without hacks.
function sheepStats:CalcStats(player, cacheFlag)
    local stats = GetStats(player)
    if stats == nil then return nil end -- this hurts me a little bit
    
    if (cacheFlag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage * stats.damageMult
    end
    if (cacheFlag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay / stats.fireDelayDiv
    end
    if (cacheFlag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed * stats.shotSpeedMult
    end
    if (cacheFlag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearHeight = player.TearHeight * stats.rangeMult
    end
    if (cacheFlag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + stats.speedBonus
    end
    if (cacheFlag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + stats.luckBonus
    end

    if (cacheFlag & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        for _, effect in ipairs(stats.tearFlags) do
            player.TearFlags = player.TearFlags | effect
        end
    end
    if (cacheFlag & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = stats.tearColor
    end
end

return sheepStats
