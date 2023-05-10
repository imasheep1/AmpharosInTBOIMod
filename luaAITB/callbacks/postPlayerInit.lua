local sheepCosts = require("luaAITB.characters.sheepCosts")

modAITB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    sheepCosts:applyCosts(player)
end)

