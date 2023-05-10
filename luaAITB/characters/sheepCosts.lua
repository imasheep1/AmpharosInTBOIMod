-- This is pretty temporary. CCP takes a bit too much work to add it 
-- this early on in development. We don't even have costume edits.

sheepCosts = {}

local costumes = {
    pure = {"ampharosbody", "amphhorn"},
    tainted = {"ampharosaltbody", "amphalthorn"}
}

local function getCosts(player)
    if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Ampharos", false) then
        return costumes.pure
    elseif player:GetPlayerType() == Isaac.GetPlayerTypeByName("AmpharosAlt", true) then
        return costumes.tainted
    else return nil end
end

function sheepCosts:applyCosts(player)
    local costs = getCosts(player)
    if costs == nil then return end
    for i = 1, #costs do
        local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. costs[i] .. ".anm2")
        if (cost ~= -1) then
            player:AddNullCostume(cost)
        else
            print("gfx/characters/" .. costs[i] .. ".anm2 not found, check spelling?")
        end
    end    
end

return sheepCosts
