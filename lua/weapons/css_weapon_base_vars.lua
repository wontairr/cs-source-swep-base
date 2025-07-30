SWEP.MuzzleAttachment = 1

SWEP.CSMuzzleFlashes = true 
SWEP.CSMuzzleX       = false
SWEP.CSMuzzleScale   = 1.0

SWEP.Primary.Pistol     = false
SWEP.Primary.Sound      = Sound("Weapon_AK47.Single")
SWEP.Primary.Bullets 	= 1
SWEP.Primary.BulletTake = 1
SWEP.Primary.Delay  	= 0.1
SWEP.Primary.Damage 	= 36
SWEP.Primary.Force		= 10
SWEP.Primary.Distance   = 8192

SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false


SWEP.SilencingTime = 2.0 -- Time in seconds that the silencer attach animation lasts

-- Scoping (ScopingIn and ScopingLevel in SetupDataTables)

SWEP.ScopeLevels 		= { 40, 10 } -- Fov numbers for the scoping level
SWEP.ScopeSensLevels    = { 0.4, 0.10 } -- Sensitivity multipliers for the scoping level
SWEP.MaxScopingLevel    = 2   -- How far you can scope in.

SWEP.ScopeFOV           = 20  -- Divided by the current ScopingLevel
SWEP.ScopingTime        = 0.05 -- How long it takes to scope in

SWEP.ScopeDrawOverlay   = true

SWEP.ScopeSound         = Sound("weapons/zoom.wav") -- Sound that plays when you scope in/out
SWEP.ScopeSoundPitch    = 100
SWEP.ScopeSoundLevel    = 120

SWEP.StayScopedAfterShot = false


-- Shotgun reloading (USE THE FUNCTION)
SWEP.ShotgunReloading          = false -- currently shotgun reloading
SWEP.ShotgunReloadGiveAmount   = 1 -- Shells to give every insert

SWEP.ShotgunReloadAnimSpeed = 1.0
SWEP.ShotgunReloadAnimStart = ACT_SHOTGUN_RELOAD_START
SWEP.ShotgunReloadAnim      = ACT_VM_RELOAD
SWEP.ShotgunReloadAnimEnd   = ACT_SHOTGUN_RELOAD_FINISH
SWEP.NextShotgunReload      = -1

-- Burst Fire (USE BURSTTHINK)
SWEP.BurstFire      = false 
SWEP.BurstAmount    = 3
SWEP.BurstDelay     = 1 -- Replaces SWEP.Primary.Delay
SWEP.BurstShotDelay = 0.1 -- Delay between shots

SWEP.BurstOnMsg = "Switched to burst-fire mode"
SWEP.BurstOffMsg = "Switched to semi-automatic"

-- For spray patterns
SWEP.NextEmptyCheck = -1
SWEP.LastBullet = 1



SWEP.SafeTimers = {}

SWEP.MaxPlayerSpeed = 250

SWEP.Recoil = true -- If false the gun wont do any viewpunch

SWEP.Accuracy = {
	Spread      = 0.00060,
	
    Crouch      = 0.00687,
    Stand       = 0.00916,
    Jump        = 0.43044,
    Land        = 0.08609,
    Ladder      = 0.10761,
    Move        = 0.09222,
	
    Maximum     = 1.25
}

SWEP.SprayPatternRandomXSwap = false
--SWEP.xSwapCurrent = false -- DONT CHANGE
SWEP.SprayRecoverTime = 0.1
SWEP.SprayPattern = { -- UGLY but its just for placeholder

	Angle(0,0,0),Angle(-0.90625,0.125,0),
	Angle(-1.3125,0.5,0),Angle(-2.375,0.25,0),
	Angle(-4.59375,1.4375,0),Angle(-6.71875,2.375,0),
	Angle(-8.96875,2.75,0),Angle(-10.8125,3.5625,0),
	Angle(-12.25,3.40625,0),Angle(-12,2.5,0),
	Angle(-12.78125,2.5,0),Angle(-11.71875,1.3125,0),
	Angle(-12.53125,0.90625,0),Angle(-11.71875,0,0),
	Angle(-12.25,-0.65625,0),Angle(-11.34375,-1.03125,0),
	Angle(-11.875,-2.375,0),Angle(-10.8125,-3.03125,0),
	Angle(-12.125,-4.0625,0),Angle(-10.8125,-5.125,0),
	Angle(-11.59375,-5.25,0),Angle(-11.59375,-3.5625,0),
	Angle(-11.46875,-2.375,0),Angle(-11.71875,-1.3125,0),
	Angle(-11.59375,0.375,0),Angle(-12,1.5625,0),
	Angle(-11.46875,0.65625,0),Angle(-11.875,-0.5,0),
	Angle(-11.85,-1.1,0),Angle(-11.75,-1.5,0),

}

SWEP.Event = {
	Silence = 0,
	ReScope = 1,
	Idle	= 2
}
SWEP.AutoIdle = false
SWEP.AutoIdleDelay = 1



local dev = GetConVar("developer")

function SWEP:SetupDataTables()

	self:NetworkVar("String","WorldModel")
	self:NetworkVarNotify("WorldModel",function(ent,name,old,new)
		self.WorldModel = new
	end)


	self:NetworkVar("Bool","BeenPickedUp")

	self:NetworkVar("Bool","SprayXSwap")

	self:NetworkVar("Bool","Reloading")

    self:NetworkVar("Bool","Dropped")
	
    self:NetworkVar("Bool","Burst")
	
	self:NetworkVar("Int","MuzzleAttachment")
	
	self:NetworkVar("Bool","Silenced")
	
	self:NetworkVar("Bool","ScopingIn")
	self:NetworkVar("Int","ScopingLevel")
	self:NetworkVar("String","Accuracy")
	self:NetworkVarNotify("Accuracy",function(ent,name,old,new)
		if not self[new] and dev:GetInt() == 1 then print("ERROR: TRIED TO SET ACCURACY TO A NIL TABLE: '" .. new .. "'") return end
		self.Accuracy = self[new]
	end)
	

	self:NetworkVar("Int","Event")
	self:NetworkVar("Float","EventTime")

	self:SetupMoreDataTables()
end

function SWEP:InitializeNetworkVars() end

-- Override this instead of the one above.
function SWEP:SetupMoreDataTables() end
