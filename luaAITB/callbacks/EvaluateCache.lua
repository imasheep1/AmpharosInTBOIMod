local sheepStats = require("luaAITB.characters.SheepStats")

modAITB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    sheepStats:CalcStats(player, cacheFlag)
end)

