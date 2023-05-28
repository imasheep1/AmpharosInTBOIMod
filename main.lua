-- Many thanks to the following people:
    -- wofsauge, for documenting the Isaac modding API
    -- nanaphoenix, for the original character template
    -- Sanio, for inspiration and mod structure examples

-- Init
modAITB = RegisterMod("Ampharos", 1)
include("luaAITB.callbacks.EvaluateCache")
include("luaAITB.callbacks.PostPlayerInit")
include("luaAITB.attacks.thunder.Thunder")
