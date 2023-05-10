local sheepCosts = require("luaAITB.ampharos.sheepCosts")

modAITB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    sheepCosts:applyCosts(player)
end)

