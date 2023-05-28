--[[

    Simple Targeting Reticle library (libstar) by IAG
    TODO: Write the wiki because this code is kinda messy

]]--

local star = {}

-- Thanks to Lytebringr for bringing up these defaults in a video
local entityInfo = {
    mType   = EntityType.ENTITY_EFFECT, -- 1000
    variant = EffectVariant.TARGET,     -- 30
    sType   = 0                         -- 0
}

-- Function that should be called when the reticle fires.
-- This placeholder spawns an explosion and despawns the reticle.
local fire = function(reticle) reticle:Despawn() end


-- Init MUST be run before calling the spawn function or else it will not work correctly
function star:Init(_fire, _reticleEntityType,
                   _reticleEntityVariant, _reticleEntitySubtype)
    rv = true -- return okay by default
    
    -- Only set entityInfo if all three are set
    if not (_reticleEntityType and _reticleEntityVariant and _reticleEntitySubtype) then 
        print("libstar reticleEntity type, variant, and/or subtype was not initialized")
        print("falling back to previous values...")
        rv = false
    else
        entityInfo.mType   = _reticleEntityType
        entityInfo.variant = _reticleEntityVariant
        entityInfo.sType   = _reticleEntitySubtype
    end
    
    if not (_fire) then
        print("libstar fire was not initialized")
        print("falling back to previous value...")
        rv = false
    else
        fire = _fire
    end

    return rv
end


local behaviors = {
    -- Reticle behaviors
    fireInterval = 45, -- 45 ticks is 1.5 seconds
    noFireUntil = 0,
    maxVelocity = 30 -- units/tick
}

-- Note that ticks are optimally 1/30 of a second and are affected by lag
local reticle = {
    entity  = nil,      -- A ref to the reticle entity
    
    exists  = false,    -- Does it exist?
    armed   = false,    -- Can it fire?
    firing  = false,    -- Is it firing?

    timeFromSpawn = 0   -- The time (in ticks) since the reticle was spawned
}

function star:TrySpawn()   
    -- Ignore spawn command if it exists already; conditional behavior
    if reticle.exists then return nil end

    -- T.V.S, pos, vel, parent entity(?)
    reticle.entity = Isaac.Spawn(entityInfo.mType, entityInfo.variant, entityInfo.sType,
                                 Vector(0, 0), Vector(0, 0), nil)
    reticle.timeFromSpawn = 0
    reticle.exists = true
    reticle.armed = false
    reticle.firing = false
end

function star:Despawn()
    -- Setting the entity to nil caused the move function to throw an error when the entity
    -- was removed as it was trying to interact with a nil. 
    -- Why it happily works when the entity does not exist but its pointer does is beyond me.
    reticle.entity:Remove()
    reticle.exists = false
    reticle.firing = false
end

-- Thank you to Lytebringr for his control hijack tutorial. (Episode 023, check it out)
-- This code probably sucks a lot but it is super temporary... Probably.
function star:KeyboardMove()

    -- Take inputs
    left = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0)
    right = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0)
    up = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0)
    down = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)
    
    -- Convert directions to vector multipliers
    xMult = 0
    if left then xMult = xMult - 1 end
    if right then xMult = xMult + 1 end
    yMult = 0
    if up then yMult = yMult - 1 end
    if down then yMult = yMult + 1 end
    
    -- Normalize the vectors
    -- This doesn't work with joysticks... Too bad!
    if xMult ~= 0 and yMult ~= 0 then
        xMult = xMult * math.sin(math.rad(45))
        yMult = yMult * math.sin(math.rad(45))
    end

    -- Change velocity of the reticle
    reticle.entity.Velocity = Vector(behaviors.maxVelocity * xMult, behaviors.maxVelocity * yMult)
end



--[[ 
    I wish you could add multiple callbacks of a single type. But you can't do that.
    So, you need to do that bit yourself, and I am unbelievably pissed about it.
    Use MC_POST_UPDATE as the function name suggests.
    This code is shit by the way. Good enough for a hacky test though, so who cares.
]]--

function star:OnPostUpdate()
    -- Don't do anything if the reticle isn't even present to begin with
    if not reticle.exists then return nil end

    reticle.timeFromSpawn = reticle.timeFromSpawn + 1
    -- Arm for firing 
    if not reticle.armed and behaviors.noFireUntil <= reticle.timeFromSpawn then
        reticle.armed = true
    end
    -- Trigger firing
    if reticle.armed and behaviors.fireInterval <= reticle.timeFromSpawn then
        fire(self)
    end

    -- Move the reticle
    self:KeyboardMove()
end

return star
