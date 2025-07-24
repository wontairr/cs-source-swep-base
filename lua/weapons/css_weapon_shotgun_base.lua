SWEP.Base = "css_weapon_base"
SWEP.Shotgun = true
SWEP.Type = CSS_Shotgun
SWEP.Slot = CSS_SelectSlot(SWEP.Type)

function SWEP:Reload()
	self:ShotgunReload()
end
function SWEP:Think()
    CSSBaseClass.Think(self)
	self:ShotgunReloadThink()
end
