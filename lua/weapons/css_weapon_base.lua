if SERVER then AddCSLuaFile() AddCSLuaFile("weapons/css_weapon_base_vars.lua") AddCSLuaFile("weapons/css_weapon_base_util.lua") end

SWEP.Base = "weapon_base"
SWEP.CSSWeapon = true 
SWEP.Category = "Counter-Strike: Source"
SWEP.Author   = "Wontairr"
SWEP.IconLetter = "b"
SWEP.Type = CSS_Rifle
SWEP.Slot = CSS_SelectSlot(SWEP.Type)

SWEP.Spawnable = false 
SWEP.Equipped = false

SWEP.HoldType = "ar2"

SWEP.m_WeaponDeploySpeed = 1.0
SWEP.ViewBobData = {
	CurBobScale = 0,
	CurMouseSpeed = 0,
	CurOwnerSpeedPercentage = 0,
	BobSpeedMultiplier = 0
}

SWEP.ViewModel  = Model("models/weapons/cstrike/c_rif_ak47.mdl")
local carms = CSSServerConvars.weapons_carms:GetBool()
SWEP.UseHands = carms
SWEP.CArmsSettings = {
	offsetPos = Vector(1.5,7,0.5),
	offsetAng = Angle(0,0,0)
}
SWEP.ViewModelFOV = 74
if CLIENT then
	SWEP.ViewModelFOV = CSSClientConvars.weapons_carms_adjust:GetBool() and 74 or 54
end

SWEP.ViewModelFlip = !carms
if CLIENT then SWEP.ViewModelFlip = !CSSClientConvars.weapons_lefthand:GetBool() end
SWEP.ViewmodelRightHanded = false

SWEP.BounceWeaponIcon  = false 
SWEP.DrawWeaponInfoBox = false
SWEP.SwayScale = 0.5


include("weapons/css_weapon_base_vars.lua")
--[[

	EVENT FUNCTIONS

]]
function SWEP:AddEvent(eventName)
	local highest = 0
	for name, id in pairs(self.Event) do
		if id > highest then highest = id end
	end
	self.Event[eventName] = highest + 1
end
SWEP.LockEventsB = false

function SWEP:LockEvents() self.LockEventsB = true end
function SWEP:UnlockEvents() self.LockEventsB = false end
function SWEP:GetEventsLocked() return self.LockEventsB end

function SWEP:DelayedEvent(event,delay)
	if self.LockEventsB then return end
	self:SetEvent(event)
	self:SetEventTime(CurTime() + delay)
end

include("weapons/css_weapon_base_util.lua")

function SWEP:Think()
	self:Think2()
	-- Drop
	if CLIENT then
		if not self.DontDrop and self:GetOwner() == LocalPlayer() and input.IsButtonDown(CSSClientConvars.drop_bind:GetInt()) 
		and not self:GetOwner():IsTyping() and not gui.IsConsoleVisible() and not self:GetDropped() then
			self:SetDropped(true)
			net.Start("toServer_CSSDropWeapon")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end
	-- idk what this does but keeping for compatibility I guess
	if self.LastBulletThink and not CLIENT then
		if self.NextEmptyCheck != -1 and CurTime() >= self.NextEmptyCheck and self.LastBullet > 1 then
			self.LastBullet = 1
		end
	end
	
	-- Events
	local event = self:GetEvent()
	if event == -1 or CurTime() < self:GetEventTime() then return end

	local stop = self:HandleEvent(event)
	if stop == true then self:SetEvent(-1) return end

	if event == self.Event.Silence then
		local newSilenced = !self:GetSilenced()
		--self:SharedSetVar("Silenced",newSilenced,true)
		self:SetSilenced(newSilenced)

		if newSilenced then
			self:SetWorldModel(self.WorldModelSilenced)
			self:SetAccuracy("AccuracySilenced")
		else
			self:SetWorldModel(self.WorldModelUnsilenced)
			self:SetAccuracy("AccuracyUnSilenced")
		end

		if SERVER then
			self:CallOnClient("SetHoldType",self.HoldType)
			self:SetHoldType(self.HoldType)
		end
	end
	if event == self.Event.ReScope then
		self:Scope(self.previousScopeLevel)
	end
	if event == self.Event.Idle then
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	
	
	self:SetEvent(-1)
	if event == self.Event.Idle then
		self:IdleEnd()
	end
end

-- Override.
function SWEP:IdleEnd() end

-- Override.
function SWEP:Think2() end

-- Override. If you return true in this you can prevent the default events from happening.
function SWEP:HandleEvent(event) end


function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	if SERVER then
		timer.Simple(0.025,function()
			if not IsValid(self) then return end
			self:CallOnClient("SetVMFlip","true")
		end)
	end


	self:PostInitialize()

	if string.find(self.Primary.Sound,".wav") != nil then self.Primary.SoundRaw = self.Primary.Sound return end
	local snd = sound.GetProperties(self.Primary.Sound).sound
	if istable(snd) then self.Primary.SoundRaw = snd[1] else self.Primary.SoundRaw = snd end
end
-- Override.
function SWEP:PostInitialize() end

function SWEP:OnRemove(fullUpdate)
	self:ResetVariables()
	self:PostRemove()

	if CSSServerConvars.weapons_drop:GetBool() == false then return end
	local owner = self:GetOwner()

	if SERVER and IsValid(owner) and not owner.CSSDroppingWeapons then
		owner.CSSDroppingWeapons = true
		
		
		for _, wep in ipairs(owner:GetWeapons()) do
			if IsValid(wep) and wep.CSSWeapon and not wep.DontDrop then
				wep:Drop(owner)
			end
		end
		timer.Simple(0,function()
			if IsValid(owner) then
				owner.CSSDroppingWeapons = true
			end
		end)
	end
end

-- Override.
function SWEP:PostRemove() end


function SWEP:Equip(owner)
	self:SetHoldType(self.HoldType)

	if SERVER and not self:GetBeenPickedUp() then
		if not owner:IsNPC() and engine.ActiveGamemode() == "sandbox" and CSSServerConvars.weapons_give_ammo_sandbox:GetBool() then
			owner:GiveAmmo(self.Primary.DefaultClip,self.Primary.Ammo,false)
		end
		self:SetBeenPickedUp(true)
	end

	owner:EmitSound("items/itempickup.wav",100,100,1,CHAN_ITEM,SND_NOFLAGS,0)

	if CSSServerConvars.weapons_autoswitch:GetBool() 
	and self.Type
	and self.Type != CSS_Pistol 
	and self.Type != CSS_Utility 
	and self.Type != CSS_Misc then
		owner:SelectWeapon(self:GetClass())
	end

	self:PostEquip(owner)

	return true
end
-- Override.
function SWEP:PostEquip(owner) end



function SWEP:Deploy()
	self.Equipped = true

	self:SetReloading(false)

	self:SetEvent(-1)
	self:SetHoldType(self.HoldType)
	self.ViewModelFOV = 74
	if CLIENT then
		self.ViewModelFOV = CSSClientConvars.weapons_carms_adjust:GetBool() and 74 or 54
	end

	if SERVER then
		self:CallOnClient("SetVMFlip","true")
	end

	self:SetDropped(false)

	self:SendWeaponAnim(self:GetSilenced() and ACT_VM_DRAW_SILENCED or ACT_VM_DRAW)
	local owner = self:GetOwner()
	if IsValid(owner) and not owner:IsNPC() then
		owner:SetCanZoom(false)
	end
	if self.DeploySound and SERVER then
		local filter = RecipientFilter()
		filter:AddPlayer(owner)
		self:EmitSound(self.DeploySound,nil,nil,nil,nil,nil,nil,filter)
	end

	if self.AutoIdle then
		self:DelayedEvent(self.Event.Idle,self:SequenceDuration(ACT_VM_DEPLOY) + self.AutoIdleDelay)
	end

	self:PostDeploy()

	return true
end

-- Override.
function SWEP:PostDeploy() end


function SWEP:Holster(weapon)
	if IsFirstTimePredicted() then
		self:ResetVariables()
		self:SetEvent(-1)
	end
	local owner = self:GetOwner()
	if IsValid(owner) and not owner:IsNPC() then
		owner:SetCanZoom(true)
	end

	self:PostHolster(weapon)

	return true
end

-- Override.
function SWEP:PostHolster(weapon) end

function SWEP:Drop(ownerOverride)
	if CLIENT then return end
	self:ResetVariables()
	self:SetEvent(-1) -- cancel events

	local owner = nil 
	if ownerOverride != nil then owner = ownerOverride else owner = self:GetOwner() end
	if not IsValid(owner) then return end
	local ownerVelocity = owner:GetVelocity()
	if ownerOverride then
		-- Create a drop from scratch for deathdrops
		local me = ents.Create(self.ClassName)
		me:SetPos(self:GetPos())
		me:SetAngles(self:GetAngles())
		me:Spawn()
		me:Activate()
		me:SetOwner(owner)
		me:SetClip1(self:Clip1())
		me:SetClip2(self:Clip2())
		me:SetSilenced(self:GetSilenced())
		me:SetBurst(self:GetBurst())
		me:SetBeenPickedUp(self:GetBeenPickedUp())
		me:PhysWake()
		me:ResetVariables()
		local phys = me:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(true)
			phys:ApplyForceCenter(ownerVelocity)
		end


		self:PostDrop(ownerOverride,me)
		return
	end
	
	owner:DropWeapon(self,nil,owner:GetAimVector():GetNormalized() * 200)

	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		ownerVelocity:Mul(1.5)
		phys:ApplyForceCenter(ownerVelocity)
		self:PostDrop(ownerOverride,nil)
	end

end

-- Override.
function SWEP:PostDrop(ownerOverride,remakeEnt) end

--[[

	PRIMARY ATTACK

]]
SWEP.NextFire = 0 -- NPC ONLY
function SWEP:CanPrimaryAttack()
	if ( self:GetOwner():IsNPC() and CurTime() < self.NextFire ) then return end

	if ( self:Clip1() <= 0 ) then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		if self:GetOwner():KeyPressed(IN_ATTACK) then
			if self.Type and self.Type == CSS_Pistol then
				self:EmitSound( "Default.ClipEmpty_Pistol" )
			else
				self:EmitSound( "Default.ClipEmpty_Rifle" )
			end
			if self:Ammo1() > 0 then
				self:Reload(true)
			end
		end
		return false

	end

	return true

end

function SWEP:PostCanPrimaryAttack()
	self:BeforePrimaryAttack()

	self:SetReloading(false)
	
	self.ShotgunReloading = false
	
	local wasScoping = self:GetScopingIn()
	
	if self:GetBurst() then
		self:SetNextPrimaryFire(CurTime() + (self.BurstDelay))
		if IsFirstTimePredicted()  then
			self.BurstLeft = self.BurstAmount
		end
	else		
		self:TakePrimaryAmmo(self.Primary.BulletTake)
		self:EmitSound(self:GetSound("PrimaryFire"))
		
		self:SendAnimation(self:GetAnimation("Fire"),PLAYER_ATTACK1)
		if wasScoping and not self.StayScopedAfterShot then
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 0.09)	
		else
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		end
		
		self:ShootBullet(self.Primary.Damage,self.Primary.Bullets,self:GetAccuracyFloat(),self:DoRecoil(),self.Primary.Distance)
		self:SetNextEmptyCheck()
	end
	if self:GetOwner():IsNPC() then self.NextFire = CurTime() + self.Primary.Delay end
	
	-- Put after shot so that the accuracy is kept.
	if (CSSServerConvars.weapons_sniper_unscopeaftershot:GetBool() and not self.StayScopedAfterShot) and wasScoping then
		self:ResetScoping(true)
	end	
	
	
	if self.AutoIdle then
		self:DelayedEvent(self.Event.Idle,self:SequenceDuration() + self.AutoIdleDelay)
	end
	
	self:AfterPrimaryAttack()
end


-- Override
function SWEP:BeforePrimaryAttack() end

-- Override
function SWEP:AfterPrimaryAttack() end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return false end
	self:PostCanPrimaryAttack()
end
-- Recover spread/spray.
function SWEP:SetNextEmptyCheck(override)
	if override == nil then override = self:GetNextPrimaryFire() else override = CurTime() + override end
	self.NextEmptyCheck = override + self.SprayRecoverTime
end

-- Override.
function SWEP:BulletCallback(attacker,tr,dmginfo) end

-- the colors and stuff is for debugging
local green = Color(0,255,0,255)
local red = Color(255,0,0,255)
local gray = Color(187,187,187,20)
local lerpColor = Color(255,0,0,255)
local debugMin,debugMax = Vector(-1,-1,-1),Vector(1,1,1)
function SWEP:ShootBullet( damage, num_bullets, aimcone,direction,distance,burst, ammo_type, force, tracer)
	
	local owner = self:GetOwner()
	
	local eyeDir = owner:EyeAngles()
	eyeDir:Add(Angle(direction.x,direction.y * (self:GetSprayXSwap() and -1 or 1),0))
	
	local spread = burst != nil and VectorRand(0,aimcone) or Vector( aimcone, aimcone, 0 )
	if burst != nil then spread.z = 0 end
	
	
    local bullet = {}
    bullet.Num     	= num_bullets
	bullet.Dir     	= eyeDir:Forward()  -- Affected by spray pattern
    bullet.Src     	= owner:GetShootPos()
	bullet.Spread	= spread
	bullet.Distance = distance 	or 56756
	bullet.Tracer	= tracer 	or 0
	if owner:IsNPC() then bullet.Tracer = 1 end
	bullet.Force	= force  	or self.Primary.Force
	bullet.Damage	= damage	or self.Primary.Damage
	bullet.AmmoType = ammo_type or self.Primary.Ammo
	
	bullet.Damage = bullet.Damage * CSSServerConvars.weapons_damage_multiplier:GetFloat()
	bullet.Force = bullet.Force * CSSServerConvars.weapons_force_multiplier:GetFloat()
	-- Big nasty debug code.
	if CSSServerConvars.weapons_spray_debug:GetBool() and self.SprayPattern[1] != "none" then
		if (self.NextEmptyCheck != -1 and CurTime() >= self.NextEmptyCheck) or not self.FirstShot then
			self.FirstShot = true
			lerpColor = Color(255,0,0,255)
			
			for _, ang in ipairs(self.SprayPattern) do
				if _ > self.Primary.ClipSize then break end
				local eyeDir = owner:EyeAngles()
				eyeDir:Add(Angle(ang.x,ang.y * (self:GetSprayXSwap() and -1 or 1),0))
				local newtr = util.QuickTrace(owner:GetShootPos(),eyeDir:Forward() * bullet.Distance,owner)
				if SERVER then
					debugoverlay.Box(newtr.HitPos,debugMin,debugMax,2 + self.Primary.Delay * self.Primary.ClipSize,gray)
				end
			end
		end
		bullet.Callback = function(att,tr,dmginfo) 	
			local newtr = util.QuickTrace(owner:GetShootPos(),bullet.Dir * bullet.Distance,owner)
			if SERVER then
				lerpColor = lerpColor:Lerp(green,self.LastBullet/self.Primary.ClipSize)
				lerpColor:AddBrightness(2)
				debugoverlay.Cross(newtr.HitPos,4 + self.Primary.Delay * self.Primary.ClipSize,3.5,lerpColor)
				
				
			end
			self:BulletCallback(att,tr,dmginfo)
		end
	else
		bullet.Callback = self.BulletCallback
	end
	
	owner:FireBullets( bullet )
	
	if self:GetSilenced() then return end
	self:GetOwner():MuzzleFlash() 
	
end

--[[
	
SECONDARY ATTACK/SILENCING

]]
function SWEP:CanSecondaryAttack()
	return CurTime() > self:GetNextSecondaryFire()
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	self:SetReloading(false)
	if self.Silenced != nil then self:AttachSilencer() end
	if self.BurstFire then self:ToggleBurst() end
	return false
end

function SWEP:ToggleBurst()
    if not self:CanSecondaryAttack() then return end
    self:SetNextSecondaryFire(CurTime() + 0.25)

	local burst = self:GetBurst()
    self:SetBurst(!burst)
	-- get new burst value.
	burst = self:GetBurst()
	local accuracy = burst and "AccuracyBurst" or "AccuracyNormal"
	self:SetAccuracy(accuracy)

	if not IsValid(self:GetOwner()) then return end
    self:GetOwner():PrintMessage(HUD_PRINTCENTER,(burst and self.BurstOnMsg or self.BurstOffMsg))
end

function SWEP:AttachSilencer()
	self:SendAnimation(self:GetSilenced() and ACT_VM_DETACH_SILENCER or ACT_VM_ATTACH_SILENCER,PLAYER_RELOAD)

	local nextTime = CurTime() + self:SequenceDuration()

	self:SetNextSecondaryFire(nextTime)
	self:SetNextPrimaryFire(nextTime)
	-- SequenceDuration is different between viewmodel and worldmodel so static delay
	self:DelayedEvent(self.Event.Silence,self.SilencingTime)
end


function SWEP:CanReload()
	return self:Clip1() < self:GetMaxClip1() 
	   and self:Ammo1() > 0 
	   and CurTime() > self:GetNextPrimaryFire() 
	   and self:GetOwner():KeyPressed(IN_RELOAD)
end

function SWEP:Reload(override)
	if not self:CanReload() and not override then return end
	self:ResetScoping()
	self:DefaultReload(self:GetSilenced() and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD)

	self:SetReloading(true)

	
	if self.AutoIdle then
		self:DelayedEvent(self.Event.Idle,self:SequenceDuration() + self.AutoIdleDelay)
	end

	self:PostReload()
end

-- Override.
function SWEP:PostReload() end

hook.Add("EntityEmitSound","CSS_SyncReloadSounds",function(data)
	if SERVER then return end
	local ent = data.Entity
	if not IsValid(ent) then return end
	if not ent:IsPlayer() or ent != LocalPlayer() then return end
	if not string.StartsWith(data.SoundName,"weapons/") then return end
	local wep = ent:GetActiveWeapon()
	if IsValid(wep) and wep.CSSWeapon and wep:GetReloading() then
		if data.OriginalSoundName == nil then return end
		net.Start("toServer_CSSPlaySound")
			net.WriteString(tostring(data.OriginalSoundName))
		net.SendToServer()
	end
end)

--[[

	SPREAD/RECOIL/SPRAYPATTERN

]]

function SWEP:GetAccuracyFloat()
    if not IsValid(self:GetOwner()) then return 0 end
    local owner = self:GetOwner()
    local acc = self.Accuracy
    local spread = acc.Spread
	local walkSpeed = 80
	if not owner:IsNPC() then walkSpeed = owner:GetWalkSpeed() end
	if self.Shotgun then return spread end

    if not owner:OnGround() and owner:GetMoveType() != MOVETYPE_NOCLIP then
		spread = spread + acc.Jump
	end
    if owner:GetVelocity():Length() >= walkSpeed/1.5 then
		spread = spread + acc.Move

	end

	if not owner:IsNPC() then		
		if owner:Crouching() then
			spread = spread + acc.Crouch 
	
		elseif not owner:Crouching() and owner:OnGround() then
			spread = spread + acc.Stand
		end
	end

    if owner:GetMoveType() == MOVETYPE_LADDER then spread = spread + acc.Ladder end

    local retVal = math.Clamp(spread,acc.Spread,acc.Maximum)

    return retVal 
end

-- There are alot of magic numbers here but I literally don't know how CS:S does it so its all perceptive.
function SWEP:ViewPunch(owner,angle)
	if owner:IsNPC() then return end
	if not self.Recoil or noViewPunch then return end

	local viewPunch = Angle(angle.x,angle.y,0)

	viewPunch.y = viewPunch.y * 0.5 * (self:GetSprayXSwap() and -1 or 1)

	viewPunch.x = math.Clamp(viewPunch.x,-10,-4) / 1.7
	if self:GetBurst() then
		if SERVER and IsFirstTimePredicted() then
			owner:SetViewPunchAngles(viewPunch)
		end
	else
		owner:SetViewPunchAngles(viewPunch)
		if CSSServerConvars.weapons_alt_viewpunch:GetBool() then
			owner:SetViewPunchVelocity(owner:GetViewPunchAngles() * 7)
		end
	end

end
-- Spray Pattern.
function SWEP:DoRecoil(noViewPunch)
    local owner = self:GetOwner()
	if noViewPunch == nil then noViewPunch = false end

    if not IsValid(owner) or owner:IsNPC() then return angle_zero end

	if self.SprayPattern[1] == "none" then self:ViewPunch(owner,angle_zero) return angle_zero end

	if IsFirstTimePredicted() then		
		if self.NextEmptyCheck != -1 and CurTime() >= self.NextEmptyCheck then
			self.LastBullet = 1
			if self.SprayPatternRandomXSwap then
				if CSSServerConvars.weapons_randomspraypatternflip:GetBool() then
					self:SetSprayXSwap(math.random(0,1) == 1)
				else
					self:SetSprayXSwap(false)
				end
			end
		else
			self.LastBullet = math.Clamp(self.LastBullet + 1,0,self.Primary.ClipSize)
		end
	end	
	local index = math.Clamp(self.LastBullet,1,#self.SprayPattern) or 1

	local angleAdd = self.SprayPattern[index]
	
	self:ViewPunch(owner,angleAdd)
	
    return angleAdd
end

--[[

	SPECIAL FUNCTIONS (SHOTGUN RELOADING, BURST FIRE)

]]
SWEP.BurstLeft = 0
SWEP.BurstNext = 0


function SWEP:BurstShoot()
	
	self:TakePrimaryAmmo(self.Primary.BulletTake)
	self:EmitSound(self:GetSound("PrimaryFire"))

	self:SendAnimation(self:GetAnimation("Fire"),PLAYER_ATTACK1)

	self:ShootBullet(self.Primary.Damage,self.Primary.Bullets,self:GetAccuracyFloat(),self:DoRecoil(),self.Primary.Distance,true)
	self:SetNextEmptyCheck()
end
function SWEP:BurstThink()
    if not self.BurstFire or self.BurstLeft <= 0 or CurTime() < self.BurstNext then return end
	if self:Clip1() > 0 then
		self:BurstShoot()
	end
	if CLIENT and not IsFirstTimePredicted() then return end

	self.BurstNext = CurTime() + self.BurstShotDelay
	
	self.BurstLeft = self.BurstLeft - 1

end

-- Put in SWEP:Reload() to start a shotgun reload
function SWEP:ShotgunReload()
	if self:Clip1() >= 0 and CurTime() < self:GetNextPrimaryFire() then return end -- Prevents spam fire
    if self:Clip1() >= self.Primary.ClipSize or self:Ammo1() <= 0 or self.ShotgunReloading then return end
    self.ShotgunReloading = true
    self:SendAnimation(self.ShotgunReloadAnimStart,PLAYER_RELOAD)

    -- This sets up a point in time when SWEP:ShotgunReloadThink() will know when to give ammo and
	-- start the next reload animation.
    local time = self:SequenceDuration()
	self.NextShotgunReload = CurTime() + time
	self:SetNextPrimaryFire(CurTime() + time)

	if SERVER then
		self:CallOnClient("SetReloadEnd","true")
	end
	self:PostReload()
end


-- This should be run in your SWEP's Think function.
function SWEP:ShotgunReloadThink()
    -- Check if we are currently reloading and the animation has finished.
    if self.ShotgunReloading == true and CurTime() >= self.NextShotgunReload and SERVER then
        -- Stop reloading when the clip is full.
        if self:Clip1() >= self.Primary.ClipSize or self:Ammo1() == 0 then
            self.ShotgunReloading = false
            self:SendWeaponAnim(self.ShotgunReloadAnimEnd)
            return
        end

		self:GetOwner():RemoveAmmo(1,self.Primary.Ammo)
        -- Add ammo to the clip, clamping it to prevent exceeding the maximum.
        self:SetClip1(math.Clamp(self:Clip1() + self.ShotgunReloadGiveAmount, 0, self:GetMaxClip1()))
		
		-- Play the shell insertion animation.
		self:SendWeaponAnim(self.ShotgunReloadAnim)
	
        
		local time = CurTime() + self:SequenceDuration() / self.ShotgunReloadAnimSpeed
		self.NextShotgunReload = time
		self:SetNextPrimaryFire(CurTime() + 0.1)
    end
end


--[[

	SCOPING

]]

SWEP.previousScopeLevel = 0
-- Set everything scoping related back to defaults.
function SWEP:ResetScoping(returnAfterShot)
	if not self.AccuracyUnScoped then return end


	self.previousScopeLevel = self:GetScopingLevel()

	self:SetScopingIn(false)
	self:SetScopingLevel(0)

	--self.Accuracy = self.AccuracyUnScoped
	if IsFirstTimePredicted() then
		self:SetAccuracy("AccuracyUnScoped")
	end
	local owner = self:GetOwner()
    if IsValid(owner) and not owner:IsNPC() then
        owner:SetFOV(0,self.ScopingTime)
		if returnAfterShot then
			self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
			if previousScopeLevel == 0 then return end
			self:DelayedEvent(self.Event.ReScope,self.Primary.Delay)
		end
    end
	self:PostResetScoping(returnAfterShot,previousScopeLevel)
end
-- Override.
function SWEP:PostResetScoping(returnAfterShot,previousScopeLevel) end

function SWEP:Scope(overrideLevel)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
	self:SetNextSecondaryFire(CurTime() + 0.3)

	if self.ScopeSoundLevel > 0 then
		self:EmitSound(self.ScopeSound, self.ScopeSoundLevel,self.ScopeSoundPitch,1,CHAN_ITEM)
	end
    -- If not scoping or haven't reached max scoping level then scope in/keep scoping in.
    if self:GetScopingIn() == false or (self:GetScopingIn() and self:GetScopingLevel() < self.MaxScopingLevel ) then
		local newLevel = (overrideLevel == nil and self:GetScopingLevel() + 1 or overrideLevel)
		self:SetScopingLevel(newLevel)
		
        owner:SetFOV(self.ScopeLevels[math.Clamp(self:GetScopingLevel(),1,99)], self.ScopingTime)
		
        -- scope in if haven't yet
        if not self:GetScopingIn() then
			self:SetScopingIn(true)
			self:SetAccuracy("AccuracyScoped")
		end

    -- If scoping in and have reached full scoping capacity then unscope.
    elseif self:GetScopingIn() == true and self:GetScopingLevel() >= self.MaxScopingLevel then
		self:ResetScoping()
    end

end

function SWEP:AdjustMouseSensitivity()
	local sens = not self:GetScopingIn() and 1.0 or self.ScopeSensLevels[math.Clamp(self:GetScopingLevel(),1,99)]
	return sens
end

--[[

	CLIENTSIDE VISUAL STUFF

]]

-- Classic CSS Viewbob.
function SWEP:CalcViewModelView(vm,oldPos,oldAng,pos,ang)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

	local viewSway = CSSClientConvars.weapons_viewsway:GetInt()
	
	local offsetPos = self.CArmsSettings.offsetPos
	local add = ang:Right()
	add:Mul(offsetPos.x)
	local up = ang:Up()
	up:Mul(offsetPos.z)
	add:Sub(up)
	local forward = ang:Forward()
	forward:Mul(offsetPos.y)
	add:Sub(forward)

	if viewSway < 1 then
		if self.UseHands and CSSClientConvars.weapons_carms_adjust:GetBool() then
			return pos + add,ang + self.CArmsSettings.offsetAng
		end
		return
	end

	local ownerMaxSpeedSqr = owner:GetMaxSpeed()*owner:GetMaxSpeed()
	local ownerMagnitude = math.Clamp(owner:GetVelocity():LengthSqr(),0,ownerMaxSpeedSqr)
	local moving = ownerMagnitude > 100 
	
	self.ViewBobData.CurOwnerSpeedPercentage = Lerp(FrameTime() * 10,self.ViewBobData.CurOwnerSpeedPercentage,ownerMagnitude / ownerMaxSpeedSqr)
	
	self.ViewBobData.BobSpeedMultiplier = Lerp(FrameTime() * 2,self.ViewBobData.BobSpeedMultiplier,ownerMagnitude / owner:GetWalkSpeed()^2)
	self.ViewBobData.BobSpeedMultiplier = math.Clamp(self.ViewBobData.BobSpeedMultiplier,0,1.5)

	self.ViewBobData.CurBobScale = Lerp(FrameTime() * 4,self.ViewBobData.CurBobScale, (moving and 1 or 0))


	local sin = math.sin(CurTime() * 5) * self.ViewBobData.CurBobScale * self.ViewBobData.BobSpeedMultiplier / 1.25
	local forward1 = ang:Forward()
	local up1 = ang:Up()
	forward1:Mul(sin/2)
	up1:Mul(sin/4)
	forward1:Add(up1)
	oldPos:Add(forward1)


	local newPos = oldPos

	newPos = LerpVector(self.ViewBobData.CurOwnerSpeedPercentage,pos,newPos)

	if self.UseHands and CSSClientConvars.weapons_carms_adjust:GetBool() then
		if viewSway == 2 then return oldPos + add,oldAng + self.CArmsSettings.offsetAng end
		return newPos + add,oldAng + self.CArmsSettings.offsetAng
	end

	if viewSway == 2 then return oldPos,oldAng end
	return newPos,oldAng 

end

-- HUD and scope

local black = Color(0,0,0,255)
local scopeMat = Material("hud/scope_full")

function SWEP:DoDrawCrosshair(x,y)
	if self:GetScopingIn() and self.ScopeDrawOverlay then
		local scrw, scrh = ScrW(), ScrH()
		local scopeCrosshairSize = scrw / scrh
		surface.SetDrawColor(black)
		-- Center lines exactly on the screen center
		surface.DrawRect(0, math.floor(scrh / 2 - scopeCrosshairSize / 2), scrw, math.ceil(scopeCrosshairSize))
		surface.DrawRect(math.floor(scrw / 2 - scopeCrosshairSize / 2), 0, math.ceil(scopeCrosshairSize), scrh)
	end
	if CSSServerConvars.weapons_spray_debug:GetBool() then
		local acc = self:GetAccuracyFloat()
		surface.DrawCircle(ScrW()/2,ScrH()/2,acc * 1000,50,50,255,190)
		surface.SetTextColor(255,255,255)
	
		surface.SetTextPos(ScrW()/2 - surface.GetTextSize("Accuracy" .. acc),ScrH()/2 + 200)
		surface.DrawText("Accuracy: " .. acc)
	end
	return self.HideCrosshair
end

function SWEP:ShouldDrawViewModel()
	if self:GetScopingIn() and self.ScopeDrawOverlay then
		return false
	end
	return true
end

local overlay = Material("overlays/scope_lens")

-- Draw Scope
function SWEP:DrawHUDBackground()
	if self:GetScopingIn() and self.ScopeDrawOverlay then
		surface.SetDrawColor(black)

		local size = ScrH()
		
		local cx, cy = ScrW() / 2 - size/2, ScrH() / 2 - size/2
		
		surface.DrawRect(0,0,cx,size)
		surface.DrawRect(cx + size,0,ScrW(),size)

		surface.SetMaterial(overlay)
		surface.DrawTexturedRect(cx,cy,size,size)

		surface.SetMaterial(scopeMat)
		surface.DrawTexturedRect(cx, cy, size, size)
	end
end