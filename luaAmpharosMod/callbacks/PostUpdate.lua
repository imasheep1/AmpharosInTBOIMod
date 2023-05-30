local thunder = AmpharosInTBOIModGlobals.Thunder
local star = thunder:GiveStar()

AmpharosInTBOIModGlobals.ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if (
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)) then
        star:TrySpawn()
    end
    star:OnPostUpdate()
end)
