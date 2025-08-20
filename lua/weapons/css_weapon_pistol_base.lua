SWEP.Base = "css_weapon_base"
SWEP.Pistol = true
SWEP.Type = CSS_Pistol
SWEP.Slot = CSS_SelectSlot(SWEP.Type)
if engine.ActiveGamemode() == "terrortown" then
    SWEP.Kind = WEAPON_PISTOL
    SWEP.AmmoEnt = "item_ammo_pistol_ttt"
end
 
SWEP.Primary.Automatic = CSSServerConvars.weapons_pistols_automatic:GetBool()
