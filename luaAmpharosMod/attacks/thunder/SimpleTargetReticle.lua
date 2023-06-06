--[[

    Simple Targeting Reticle library (libstar) by IAG
    TODO: Write a wiki because this code is kinda messy
    Also TODO: Could use a rewrite

]]--

local star = {}


-- This placeholder spawns an explosion and despawns the reticle.
local onTriggerPlaceholder = function(star)
    reticleEntity = star.reticle.entity
    Isaac.Explode(reticleEntity.Position, reticleEntity, 80)
    star:Despawn()
end

-- This placeholder is a linear curve that starts at 5 and ends at 1
local flashFunctionPlaceholder = function(tickNumber)
    if tickNumber > 40 then return 1 -- tick
    else
        -- f(0)=5; f(8)=4; f(16)=3; f(24)=3; f(32)=2; f(40)=1
        return math.floor((5 - tickNumber/10) + 0.5)
    end
end

star.config = {
    appearance = {
        entityType = EntityType.ENTITY_EFFECT, -- 1000
        entityVariant = EffectVariant.TARGET, -- 30
        entitySubtype = 0,
        animName = "Blink",
        dimFrame = 1,
        brightFrame = 0, -- animation frames are zero indexed
        dimWhileNotArmed = false,
        brightWhileFiring = false,
        flashFunction = flashFunctionPlaceholder,
    },

    movement = {
        maxVelocity = 30, -- TODO: Not actually sure what unit this is in
        lerpStep = 1/3, -- 1 / how many frames it takes to lerp
    },

    firing = {
        fireInterval = 45, -- 1.5 seconds
        disarmedUntil = 0, -- 0 seconds
        fireGap = 20, -- 0.5 seconds
        onTrigger = onTriggerPlaceholder,
    },

    auxilliary = {}, -- Intended for storing extra data for the firing function, if needed
    
    libstar = {
        useExperimental = false, -- enable experimental features
    },
}

-- Note that ticks are optimally 1/30 of a second and are affected by lag
star.reticle = {
    entity = nil,  -- A ref to the reticle entity
    
    timers = {
        fromSpawn = 0, -- The time (in ticks) since the reticle was spawned
        cooldown = 0, -- The time remaining until the reticle can be spawned again
        flashFrame = 0, 
    },
    states = {
        exists = false, -- Does it exist?
        armed = false, -- Can it fire?
        firing = false, -- Is it firing?
        bright = false, -- Is it in its bright state?
    },
    movement = {
        angleOffset = 0, -- Add this angle to any other angle calculation in movement
        velocityMultiplier = 1, -- Self-explanatory
        lerpProgress = 1, -- Used as a float in lerp calculations
        lerpSource = Vector(0,0), -- Starting vector for lerp calculations
        lerpTarget = Vector(0,0), -- Ending vector for lerp calculations
    },
}

function star:TrySpawn(player)
    if type(player) ~= "userdata" then 
        error("argument player expected data of type userdata, got "..type(player))
        return nil
    end

    -- Ignore spawn command if entity exists already; conditional behavior
    if self.reticle.states.exists or self.reticle.timers.cooldown > 0 then return nil end

    -- T.V.S, pos, vel, parent entity(?)
    self.reticle.entity = Isaac.Spawn(self.config.appearance.entityType, 
                                      self.config.appearance.entityVariant,
                                      self.config.appearance.entitySubtype,
                                      player.Position, Vector(0, 0), nil)

    self.reticle.states.exists = true
end

function star:Despawn()
    -- Setting the entity to nil caused the move function to throw an error when the entity
    -- was removed as it was trying to interact with a nil value.
    -- Why it happily works when the entity does not even exist is beyond me.
    self.reticle.entity:Remove()
    star:Reset()
    self.reticle.timers.cooldown = self.config.firing.fireGap
end

function star:Reset()
    self.reticle.entity = nil

    self.reticle.states.exists = false
    self.reticle.states.armed = false
    self.reticle.states.firing = false
    self.reticle.states.bright = false

    self.reticle.timers.fromSpawn = 0
    self.reticle.timers.flashFrame = 0
    
    self.reticle.movement.lerpProgress = 0
    self.reticle.movement.lerpSource = Vector(0,0)
    self.reticle.movement.lerpTarget = Vector(0,0)
end

function star:Animate()
    -- Don't blink too fast
    waitNeeded = self.config.appearance.flashFunction(self.reticle.timers.fromSpawn)
    self.reticle.timers.flashFrame = self.reticle.timers.flashFrame + 1
    if self.reticle.timers.flashFrame < waitNeeded then return nil end
    
    -- Blink
    if self.reticle.states.bright then
        self.reticle.states.bright = false
        self.reticle.entity:SetSpriteFrame(self.config.appearance.animName, 
                                           self.config.appearance.dimFrame)
    else
        self.reticle.states.bright = true
        self.reticle.entity:SetSpriteFrame(self.config.appearance.animName,
                                           self.config.appearance.brightFrame)
    end
    self.reticle.timers.flashFrame = 0
end

-- Thank you to Lytebringr for his control hijack tutorial (Episode 023, check it out)
function star:KeyboardMove()

    -- Take inputs
    left = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0)
    right = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0)
    up = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0)
    down = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0)
    
    -- Create a normalized velocity vector based on directional inputs
    -- Also positive Y is down
    -- TODO: This code still doesn't work for controllers
    x = 0; if left then x=x-1 end; if right then x=x+1 end
    y = 0; if up   then y=y-1 end; if down  then y=y+1 end

    targetVector = Vector(x,y)
    targetVector:Resize(self.config.movement.maxVelocity)
    -- Don't lerp between not moving and moving when just starting out
    -- TODO: This is dumb, make it suck less
    if self.reticle.timers.fromSpawn <= 1 then
        self.reticle.entity.Velocity = targetVector
    end
    
    -- Linearly interpolate between the current and new vector where needed
    if (self.reticle.movement.lerpTarget:Distance(targetVector) ~= 0) then
        self.reticle.movement.lerpSource = self.reticle.entity.Velocity
        self.reticle.movement.lerpTarget = targetVector
        self.reticle.movement.lerpProgress = 0
    end
    
    self.reticle.movement.lerpProgress = self.reticle.movement.lerpProgress +
                                         self.config.movement.lerpStep
    if (self.reticle.movement.lerpProgress >= 1) then self.reticle.movement.lerpProgress = 1 end
    -- Non-mutating lerp function taken from the wiki -- thank you
    newVelocity = self.reticle.movement.lerpSource * (1 - self.reticle.movement.lerpProgress) +
                  self.reticle.movement.lerpTarget * self.reticle.movement.lerpProgress
    self.reticle.entity.Velocity = newVelocity
end



--[[ 
    I wish you could add multiple callbacks of a single type. But you can't do that.
    So, you need to do that bit yourself, and I am unbelievably pissed about it.
    Use MC_POST_UPDATE as the function name suggests.
    TODO: This code is not very good. Improve it eventually.
]]--

function star:OnPostUpdate()
    if self.reticle.timers.cooldown > 0 then
        self.reticle.timers.cooldown = self.reticle.timers.cooldown - 1
    end

    -- Don't do anything else if the reticle isn't even present to begin with
    if not self.reticle.states.exists then return nil end

    -- Catch a desync caused by leaving a room, floor, etc.
    if not self.reticle.entity:Exists() then
        self:Reset()
        return nil
    end

    self.reticle.timers.fromSpawn = self.reticle.timers.fromSpawn + 1

    self:KeyboardMove()
    self:Animate()

    -- Arm for firing 
    if not self.reticle.states.armed and 
           self.config.firing.disarmedUntil < self.reticle.timers.fromSpawn and
           not self.reticle.states.firing then
        self.reticle.states.armed = true
    end
    -- Trigger firing
    if self.reticle.states.armed and self.config.firing.fireInterval < self.reticle.timers.fromSpawn then
        self.reticle.states.firing = true
        self.reticle.states.armed = false

        self.config.firing.onTrigger(self)
    end
end

return star

