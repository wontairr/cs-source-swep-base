SWEP.Base = "css_weapon_base"
SWEP.Type = CSS_Sniper
SWEP.Slot = CSS_SelectSlot(SWEP.Type)


SWEP.HideCrosshair = true


SWEP.ScopeLevels 		= { 40, 10 } -- Fov numbers for the scoping level

SWEP.ScopeMoveSpeed = nil -- Set this to a number in your SWEP code.

function SWEP:SecondaryAttack()
	self:Scope()
end
