-- W.I.P
SWEP.Base = "css_weapon_base"


SWEP.ThrowSpeed   = 100
SWEP.ThrownEntity = ""
SWEP.Slot = 2

SWEP.JustThrown = false


function SWEP:CanPrimaryAttack()
    if self.Primary.ClipSize == -1 then
        return CurTime() >= self:GetNextPrimaryFire()
    else
        return self:Clip1() > 0 and CurTime() >= self:GetNextPrimaryFire()
    end
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return false end

    
    self.JustThrown = true
    self:SendAnimation(ACT_VM_PULLPIN,PLAYER_ATTACK1)
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )


    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())

end



function SWEP:Throw()
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local entity = ents.Create(self.ThrownEntity)

    
    
    local angThrow = owner:LocalEyeAngles()
    
 
    if (angThrow.x < 90 ) then
        angThrow.x = -10 + angThrow.x * ((90 + 10) / 90.0)
    else
        
        angThrow.x = 360.0 - angThrow.x
        angThrow.x = -10 + angThrow.x * -((90 - 10) / 90.0)
    end
    angThrow.x = Lerp(math.abs(angThrow.x / -90),angThrow.x,angThrow.x + 10)
    angThrow.x = math.Clamp(angThrow.x,-90,90)

    local flVel = (90 - angThrow.x) * 6
    if (flVel > 750) then
        flVel = 750
    end
    
    local ang = Angle(angThrow[1], angThrow[2], angThrow[3])
    local vForward, vRight, vUp = ang:Forward(), ang:Right(), ang:Up()
    
    local vecSrc = owner:GetPos() + owner:GetViewOffset()
    
    // We want to throw the grenade from 16 units out.  But that can cause problems if we're facing
    // a thin wall.  Do a hull trace to be safe.
    local minsIn = Vector( -2, -2, -2 )
    local maxsIn = Vector(  2,  2,  2 )
    
    
    
    local trace = util.TraceHull({
        start   = vecSrc,
        endpos  = vecSrc + vForward * 6,
        mins    = minsIn,
        maxs    = maxsIn,
        mask    = MASK_SOLID,
        filter  = owner,
        collisiongroup = COLLISION_GROUP_NONE 
    })

    vecSrc = trace.HitPos + trace.HitNormal
    
    local vecThrow = vForward * flVel + (owner:GetAbsVelocity())
    

    
    
    entity:SetPos(vecSrc)
    entity:Spawn()
    entity:PhysWake()
    entity:SetOwner(self:GetOwner())



    entity:SetVelocity(vecThrow * 1.16  )
end


function SWEP:Think()
    CSSBaseClass.Think(self)
    local owner = self:GetOwner()
    if not IsValid(owner) or CLIENT then return end

    if self.JustThrown and not owner:KeyDown(IN_ATTACK) then
        self:SendAnimation(ACT_VM_THROW,PLAYER_ATTACK1)
        timer.Simple(0.1,function()
            if not IsValid(self) or not IsValid(self:GetOwner()) then return end
            self:Throw()
        end)
        self:TakePrimaryAmmo(self.Primary.BulletTake)
        self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
        self:CreateSafeTimer(self:SequenceDuration(),true,function()
            if (self.Primary.ClipSize == -1 or (self:Clip1() <= 0)) and not CSSServerConvars.weapons_infinite_grenades:GetBool() then
                self:GetOwner():StripWeapon(self.ClassName)
            else
                self:SendWeaponAnim(ACT_VM_DRAW)
                self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
            end
        end)
        self.JustThrown = false
    end
end