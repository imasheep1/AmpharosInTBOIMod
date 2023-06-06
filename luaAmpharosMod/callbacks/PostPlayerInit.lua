local sheepCosts = require("luaAmpharosMod.characters.SheepCosts")

AmpharosInTBOIModGlobals.ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    sheepCosts:ApplyCosts(player)
end)
