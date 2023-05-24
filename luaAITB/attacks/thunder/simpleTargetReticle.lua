----------------------------------------------------
-- Simple Targeting Reticle (STaR) library by IAG --
----------------------------------------------------

local star = {}

--

---- DEFINE BEHAVIOR

-- These preloaded defaults attempt to closely emulate Epic Fetus.
local config = {
    -- Bring your own reticle entity if you want it to work correctly.
    -- Thanks to Lytebringr for bringing up these defaults in a video.
    entity = {
        Type    = EntityType.ENTITY_EFFECT, -- 1000
        Variant = EffectVariant.TARGET,     -- 30
        Subtype = 0                         -- 0
    },

    -- Optional flags are currently unused
    flags = {},
    
    variables = {
        Lifetime        = 2,    -- Lifetime in ticks
        Acceleration    = 50,   -- Maximum acceleration in units/tick/tick
        MaxVelocity     = 10    -- Maximum velocity in units/tick
    },

    -- Function that should be called when the reticle fires
    onExpireDo =    function(position, player)
                        Isaac.spawn(EntityType.ENTITY_EFFECT, EntityEffect.BOMB_EXPLOSION, 0,
                                    position, Vector(0,0), nil)
                        return true
                    end
}

-- Init MUST be run before calling the spawn function or else it will not work correctly.
-- Returns true if okay, false if there was a problem.
function star:Init(onExpireDo, reticleEntityType, reticleEntityVariant, reticleEntitySubtype,
                    _useHoming, _lifetime, _acceleration, _maxVelocity, _flags)
    
    -- Set lifetime, velocity, and acceleration
    if _lifetime     then self.config.flags.Lifetime     = _lifetime     end
    if _acceleration then self.config.flags.Acceleration = _acceleration end
    if _maxVelocity  then self.config.flags.MaxVelocity  = _maxVelocity  end
    
    rv = true -- return ok by default

    -- Only set reticleEntity info if all three are set
    if reticleEntityType and reticleEntityVariant and reticleEntitySubtype then
        self.config.entity.Type      = reticleEntityType
        self.config.entity.Variant   = reticleEntityVariant
        self.config.entity.Subtype   = reticleEntitySubtype
    else
        error("Warning: reticleEntity's Type, Variant, and/or Subtype was not initialized.")
        error("         Falling back to defaults...")
        rv = false
    end
    
    if onExpireDo then
        self.config.OnExpireDo = onExpireDo
    else
        error("Warning: onExpireDo was not initialized. Falling back to default...")
        rv = false
    end

    return rv
end


---- USE THE RETICLE

-- Flags, timers, coordinates, and the reticle entity itself
-- Note that ticks are optimally 1/30 of a second and are affected by lag
local reticleDefaults = {
    isAlive     = false, -- Is the reticle alive?
    canMove     = false, -- Whether or not the reticle is coupled to the arrow keys

    timeAlive   = 0,     -- The duration (in ticks) that the reticle has been alive
    timeWaiting = 0,     -- The duration (in ticks) that we have waited for onExpireDo to finish
    
    entity      = nil,   -- The reticle entity
}

-- Fully intended to be publicly accessible
function star:Spawn(player)
    
    -- T.V.S, pos, vel, parent entity(?)
    self.reticle.entity = Isaac.Spawn
            (config.reticleEntity.Type, config.reticleEntity.Variant, config.reticleEntity.Subtype, 
             player.Position, Vector(0, 0), nil)
end

-- The following are only publicly accessible for debugging purposes, mostly
function star:KeyboardMove(vector)
    self.reticle.entity.
end



function star:Decouple()
    self.reticle.pointer.
end

function star:Hide()
    self.reticle.pointer.

-- Don't use POST_RENDER for movement and seppuku checks. We're not rendering anything.
modAITB:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    
end)
