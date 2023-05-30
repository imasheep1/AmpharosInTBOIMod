local sheepStats = include("luaAmpharosMod.characters.SheepStats")

AmpharosInTBOIModGlobals.ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    sheepStats:CalcStats(player, cacheFlag)
end)

