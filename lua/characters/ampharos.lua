-- Pure Ampharos character data. Conf at top, code at bottom.
-- Derived from wofsauge's character template. I have no shame.

-- Stats are NOT multipliers over Isaac's default stats. They are directly set.
local stats = {
    damage = 4.20, -- default is 3.50
    firedelay = 15.00, -- default is 10.00
    shotspeed = 1.00, -- default is 1.00
    range = 6.50, -- default is 6.50
    speed = 0.80, -- default is 1.00

    tearflags = TearFlags.TEAR_JACOBS, -- Jacob's Ladder
    tearcolor = Color(1.0, 0.83, 0.14, 1.0, 0, 0, 0),
    flying = false, -- sheep can't fly
    luck = -1.00 -- default is 0.00
}

local char = Isaac.GetPlayerTypeByName("Ampharos", false)
local costume = {"ampharosbody","amphhorn"}


-- handy namespaces
local config = Isaac.GetItemConfig()
local game = Game()


modAITB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
    -- Obviously only run the callback if you're playing as Ampharos
    if (player:GetPlayerType() == char) then
        if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = stats.damage
        end
        if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = stats.firedelay
        end
        if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = stats.shotspeed
        end
        if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearHeight = stats.range
        end
        if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = stats.speed
        end
        if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = stats.luck
        end

        if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
            if (stats.flying) then
                player.CanFly = true
            end
        end
        if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | stats.tearflags
        end
        if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
            player.TearColor = stats.tearcolor
        end
    end
end)

modAITB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    -- Obviously only run the callback if you're playing as Ampharos
    if (player:GetPlayerType() == char) then
        for i = 1, #costume do
            local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. costume[i] .. ".anm2")
            if (cost ~= -1) then
                player:AddNullCostume(cost)
            else
                print("gfx/characters/" .. costume[i] .. ".anm2 not found, check spelling?")
            end
        end
    end
end)

