local star = require("luaAmpharosMod.attacks.thunder.SimpleTargetReticle")

AmpharosInTBOIModGlobals.ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if (
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)) then
        star:TrySpawn(Isaac.GetPlayer())
    end
    star:OnPostUpdate()
end)
