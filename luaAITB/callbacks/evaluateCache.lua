local sheepStats = require("luaAITB.ampharos.sheepStats")

modAITB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    sheepStats:calcStats(player, cacheFlag)
end)

