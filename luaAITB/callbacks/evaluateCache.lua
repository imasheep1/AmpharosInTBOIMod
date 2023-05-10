local sheepStats = require("luaAITB.characters.sheepStats")

modAITB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    sheepStats:calcStats(player, cacheFlag)
end)

