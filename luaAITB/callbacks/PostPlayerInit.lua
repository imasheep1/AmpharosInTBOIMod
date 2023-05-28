local sheepCosts = require("luaAITB.characters.SheepCosts")

modAITB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    sheepCosts:ApplyCosts(player)
end)

