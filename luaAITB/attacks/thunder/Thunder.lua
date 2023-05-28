local star = require("luaAITB/attacks/thunder/SimpleTargetReticle")
star:Init()

modAITB:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    star:OnPostUpdate()

    if (
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)) then

        star:TrySpawn()
    end
end)
