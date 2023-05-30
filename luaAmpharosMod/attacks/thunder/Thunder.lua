local thunder = {}

local star = require("luaAmpharosMod/attacks/thunder/SimpleTargetReticle")

function thunder:Init()
    star:Init(Isaac.GetPlayer())
end

function thunder:GiveStar() return star end

return thunder

