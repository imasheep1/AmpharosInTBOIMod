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

-- Function that should be called when the reticle triggers.
-- This placeholder spawns an explosion and despawns the reticle.
local onTrigger = function(star)
    reticleEntity = star:GetEntity()
    Isaac.Explode(reticleEntity.Position, reticleEntity, 80)
    star:Despawn()
end


-- Init MUST be run before calling the spawn function or else it will not work correctly
function star:Init(playerArg, _onTrigger, _reticleEntityType,
                   _reticleEntityVariant, _reticleEntitySubtype)

    rv = true -- return okay by default

    -- More reliable than a simple nil check
    if tostring(type(playerArg)) ~= "userdata" then
        error("playerArg with value "..tostring(playerArg).." is of invalid type "
                          ..tostring(type(playerArg)))
        rv = false
    else
        player = playerArg
    end

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
        print("libstar onTrigger was not initialized")
        print("falling back to previous value...")
        rv = false
    else
        onTrigger = _onTrigger
    end

    return rv
end


local behaviors = {
    -- Reticle behaviors
    fireInterval = 45, -- 45 ticks is 1.5 seconds
    disarmedUntil = 0,
    maxVelocity = 30, -- units/tick
    lerpStep = 1/3, -- lerp step is 1/timeToMaxVelocity
}

-- Note that ticks are optimally 1/30 of a second and are affected by lag
local reticle = {
    entity = nil,  -- A ref to the reticle entity
    
    timers = {
        fromSpawn = 0, -- The time (in ticks) since the reticle was spawned
        cooldown = 0, -- The time remaining until the reticle can be fired again
    },
    states = {
        exists = false, -- Does it exist?
        armed = false, -- Can it fire?
        firing = false, -- Is it firing?
    },
    movement = {
        angleOffset = 0, -- Add this angle to any other angle calculation in movement
        velocityMultiplier = 1, -- Self-explanatory
        lerpProgress = 1, -- Used as a float in lerp calculations
        lerpSource = Vector(0,0), -- Starting vector for lerp calculations
        lerpTarget = Vector(0,0), -- Ending vector for lerp calculations
    },
}

function star:TrySpawn()
    -- Ignore spawn command if it exists already; conditional behavior
    if reticle.states.exists or reticle.timers.cooldown > 0 then return nil end

    -- T.V.S, pos, vel, parent entity(?)
    reticle.entity = Isaac.Spawn(entityInfo.mType, entityInfo.variant, entityInfo.sType,
                                 player.Position, Vector(0, 0), nil)
    reticle.timers.fromSpawn = 0
    reticle.states.exists = true
    reticle.states.armed = false
    reticle.states.firing = false
end

function star:Despawn()
    -- Setting the entity to nil caused the move function to throw an error when the entity
    -- was removed as it was trying to interact with a nil value.
    -- Why it happily works when the entity does not even exist is beyond me.
    reticle.entity:Remove()
    reticle.states.exists = false
    reticle.states.armed = false
    reticle.states.firing = false
end

-- Thank you to Lytebringr for his control hijack tutorial (Episode 023, check it out)
function star:KeyboardMove()

    -- Take inputs
    left = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0)
    right = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0)
    up = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0)
    down = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)
    
    -- Create a normalized velocity vector based on directional inputs
    -- This code still doesn't work for controllers. I'm working on it.
    -- Also positive Y is down. Don't forget that.
    x = 0; if left then x=x-1 end; if right then x=x+1 end
    y = 0; if up   then y=y-1 end; if down  then y=y+1 end

    targetVector = Vector(x, y)
    targetVector:Resize(behaviors.maxVelocity)
    -- Don't lerp between not moving and moving when just starting out
    if reticle.timers.fromSpawn <= 1 then
        reticle.entity.Velocity = targetVector
    end
    
    -- Linearly interpolate between the current and new vector where needed
    if (reticle.movement.lerpTarget:Distance(targetVector) ~= 0) then
        reticle.movement.lerpSource = reticle.entity.Velocity
        reticle.movement.lerpTarget = targetVector
        reticle.movement.lerpProgress = 0
    end
    
    reticle.movement.lerpProgress = reticle.movement.lerpProgress + behaviors.lerpStep
    if (reticle.movement.lerpProgress >= 1) then reticle.movement.lerpProgress = 1 end
    -- Non-mutating lerp function taken from the wiki -- thank you
    newVelocity = reticle.movement.lerpSource * (1 - reticle.movement.lerpProgress) +
                  reticle.movement.lerpTarget * reticle.movement.lerpProgress
    reticle.entity.Velocity = newVelocity
end



--[[ 
    I wish you could add multiple callbacks of a single type. But you can't do that.
    So, you need to do that bit yourself, and I am unbelievably pissed about it.
    Use MC_POST_UPDATE as the function name suggests.
    This code is shit by the way. Good enough for a hacky test though, so who cares.
]]--

function star:OnPostUpdate()
    -- Don't do anything if the reticle isn't even present to begin with
    if not reticle.states.exists then return nil end

    -- Catch a desync caused by leaving a room, floor, etc.
    if not reticle.entity:Exists() then
        self:Despawn()
        return nil
    end

    reticle.timers.fromSpawn = reticle.timers.fromSpawn + 1

    -- Move the reticle
    self:KeyboardMove()
    
    -- Arm for firing 
    if not reticle.states.armed and behaviors.disarmedUntil < reticle.timers.fromSpawn 
                         and not reticle.states.firing then
        reticle.states.armed = true
    end
    -- Trigger firing
    if reticle.states.armed and behaviors.fireInterval < reticle.timers.fromSpawn then
        reticle.states.firing = true
        reticle.states.armed = false

        onTrigger(self)
    end
end

function star:GetEntity() return reticle.entity end

return star

