-- Many thanks to the following people:
    -- wofsauge, for documenting the Isaac modding API
    -- nanaphoenix, for the original character template
    -- Sanio, for inspiration and mod structure examples

-- Init

AmpharosInTBOIModGlobals = {
    ModRef = RegisterMod("Ampharos", 1),
    Thunder = require("luaAmpharosMod.attacks.thunder.Thunder")
}

require("luaAmpharosMod.callbacks.EvaluateCache")
require("luaAmpharosMod.callbacks.PostPlayerInit")
require("luaAmpharosMod.callbacks.PostUpdate")

