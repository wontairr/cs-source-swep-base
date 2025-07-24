-- CURRENTLY THIS CODE SUCKS AND IS SUCK AND SUCKS
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "hegrenade"

ENT.Spawnable = false
ENT.Category = "Counter-Strike: Source"

ENT.Exploded = false

ENT.FirstHit = false

ENT.Sound       = Sound("CSSGrenadeExplosion")

ENT.BounceSound = Sound( "HEGrenade.Bounce" )

ENT.FuseTime = 1.5

ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

ENT.AimNormalZ = 1

ENT.LastVelocity        = Vector(0,0,0)
ENT.LastPos             = Vector(0,0,0)
ENT.LastVelocityThink   = Vector(0,0,0)

ENT.NextBounce = CurTime()

ENT.MaxVelocity = 75

ENT.ImpactDamage = 1

-- I wish I could just do normal vphysics, but im in too deep.

ENT.DoBadFriction = false 

function ENT:Draw() self:DrawModel() end

local function ScaleForGravity(desiredGravity)
	local worldGravity = GetConVar("sv_gravity"):GetFloat()
	return worldGravity > 0 and desiredGravity / worldGravity or 0
end

if CLIENT then
    net.Receive("toClient_CSSGrenadeExplode",function()
        local id = net.ReadUInt(12)
        local grenade = ents.GetByIndex(id)
        if (not IsValid(grenade)) then return end
        local success, result = pcall(function()
            grenade:Explode()
        end)
        
        
    end)
    
    function ENT:Draw()
        if self.Exploded then self:DrawShadow(false) return end
        self:DrawModel()
    end
else
    util.AddNetworkString("toClient_CSSGrenadeExplode")
end

function ENT:Initialize()
    if CLIENT and not game.SinglePlayer() then return end
    self:SetModel(self.Model)
    self:SetCollisionBounds(vector_origin,vector_origin)
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_FLYGRAVITY)
    self:SetSolid(SOLID_BBOX)

    self:SetLocalAngularVelocity(Angle(math.Rand(-100,-500),0,0))
    
    self:SetGravity(ScaleForGravity(648))
    self:SetVelocity(Vector(100,1000,10))
    self:SetFriction(0.6)
    
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    timer.Simple(0.01,function()
        if IsValid(self) then self.soundsplease = true self:SetCollisionGroup(COLLISION_GROUP_NONE) end
    end)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then phys:Wake() end

    timer.Simple(self.FuseTime,function()
        if not IsValid(self) then return end
        self.Exploded = true
        self:Explode()
        if game.SinglePlayer() and CLIENT then
            local success, result = pcall(function()
                self:Explode()
            end)
        else
            net.Start("toClient_CSSGrenadeExplode")
                net.WriteUInt(self:EntIndex(),12)
            net.Broadcast()
        end
    end)
end


function ENT:Explode()

end

function ENT:OnBounce()
    if self.soundsplease then self:EmitSound( self.BounceSound ) end
end

function ENT:PhysicsUpdate( phys )
    if CLIENT or self.Exploded then return end

    local dist = self:GetVelocity():DistToSqr(self.LastVelocity)

    local trace = util.TraceLine({
        start = self.LastPos,
        endpos = self.LastPos + self.LastVelocity * 10,
        filter = self or self:GetOwner()
    })
    local doBounceSound = false

    if dist > 100 and CurTime() > self.NextBounce then



        local bounce = math.Clamp(math.abs(self.LastVelocity.z) * 5,-self.MaxVelocity,self.MaxVelocity)
        
        if !(IsValid(trace.Entity) and trace.Entity:IsNPC()) then
            self:SetVelocity((trace.HitNormal * 2 * Vector(100,100,1)) + Vector(0,0,bounce * 2))
        else
            -- silly impact damage
            if self.ImpactDamage != -1 then trace.Entity:TakeDamage(self.ImpactDamage,self:GetOwner(),self) end
            self:SetVelocity(-self:GetVelocity() + trace.HitNormal * 25)
        end

        self:OnBounce()

        self.NextBounce = CurTime() + 0.12
   
    elseif dist < 1 and self:GetPos() == self.LastPos and CurTime() > self.NextBounce then
        local bounce = math.Clamp(math.abs(self.LastVelocity.z) * 5,-self.MaxVelocity,self.MaxVelocity)
        self:SetVelocity(Vector(0,0,bounce * 2))
        self:SetPos(self:GetPos() + vector_up)



        self:OnBounce()

        self.NextBounce = CurTime() + 0.1
    
    end


    self.LastVelocity = self:GetVelocity()
    self.LastPos = self:GetPos()
end

function ENT:Think()
    if not self.DoBadFriction or CLIENT or self.Exploded then return end
    
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + Vector(0, 0,-10),
        filter = self
    })

    if trace.Hit then
        local velocity = self:GetVelocity()
        velocity.x = velocity.x * 0.25
        velocity.y = velocity.y * 0.25
        self:SetVelocity(-velocity)
        if self:GetVelocity():LengthSqr() < 8000 then self:SetLocalAngularVelocity(angle_zero) self.NextBounce = CurTime() + 100 end
    end

    self.LastVelocityThink = self:GetVelocity()
end
