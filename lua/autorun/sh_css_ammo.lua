game.AddAmmoType({
	name = "BULLET_PLAYER_50AE", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2400,
	maxcarry = 0,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "BULLET_PLAYER_762MM",
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2400,
	maxcarry = 0,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "BULLET_PLAYER_556MM", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2400,
	maxcarry = 0,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "BULLET_PLAYER_556MM_BOX",
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2400,
	maxcarry = 0,
	minsplash = 10,
	maxsplash = 14
})

game.AddAmmoType({
	name = "BULLET_PLAYER_338MAG",
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2800,
	maxcarry = 0,
	minsplash = 12,
	maxsplash = 16
})

game.AddAmmoType({
	name = "BULLET_PLAYER_9MM", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2000,
	maxcarry = 0,
	minsplash = 5,
	maxsplash = 10
})
game.AddAmmoType({
	name = "BULLET_PLAYER_BUCKSHOT", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 600,
	maxcarry = 0,
	minsplash = 3,
	maxsplash = 6
})
game.AddAmmoType({
	name = "BULLET_PLAYER_45ACP", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2100,
	maxcarry = 0,
	minsplash = 6,
	maxsplash = 10
})
game.AddAmmoType({
	name = "BULLET_PLAYER_357SIG", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2000,
	maxcarry = 0,
	minsplash = 4,
	maxsplash = 8
})
game.AddAmmoType({
	name = "BULLET_PLAYER_57MM", 
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2000,
	maxcarry = 0,
	minsplash = 4,
	maxsplash = 8
})

if CLIENT then
	language.Add("BULLET_PLAYER_50AE_ammo",".50 AE")
	language.Add("BULLET_PLAYER_762MM_ammo",".762")
	language.Add("BULLET_PLAYER_556MM_ammo",".556")
	language.Add("BULLET_PLAYER_556MM_BOX_ammo",".556 BOX")
	language.Add("BULLET_PLAYER_338MAG_ammo",".338 MAG")
	language.Add("BULLET_PLAYER_9MM_ammo","9MM")
	language.Add("BULLET_PLAYER_BUCKSHOT_ammo","BUCKSHOT")
	language.Add("BULLET_PLAYER_45ACP_ammo",".45 ACP")
	language.Add("BULLET_PLAYER_357SIG_ammo",".357 SIG")
	language.Add("BULLET_PLAYER_57MM_ammo",".57")
end

local iconOverrides = {
	["models/Items/357ammo.mdl"] = "entities/item_ammo_357.png",
	["models/Items/BoxSRounds.mdl"] = "entities/item_ammo_pistol.png",
	["models/Items/BoxMRounds.mdl"] = "entities/item_ammo_smg1.png",
	["models/Items/BoxBuckshot.mdl"] = "entities/item_box_buckshot.png"
}
local function registerAmmo(classname,name,ammo,amount,model)
    local ENT = {}
    
    ENT.Type = "anim"
    ENT.Base = "css_ammo_base"
    ENT.Category = "Counter-Strike: Source"
    ENT.PrintName = name .. " Ammo"
    ENT.Spawnable = true 
    ENT.IconOverride = iconOverrides[model]

    ENT.Model = model
    ENT.Ammo = ammo
    ENT.Amount = amount
    scripted_ents.Register(ENT,classname)
end

-- 762MM
registerAmmo(
    "ammo_338mag",
    ".338 MAG",
    "BULLET_PLAYER_338MAG",
    20,
    Model("models/Items/357ammo.mdl")
)
-- 357SIG
registerAmmo(
    "ammo_357sig",
    ".357 SIG",
    "BULLET_PLAYER_357SIG",
    26,
    Model("models/Items/BoxSRounds.mdl")
)
-- 45ACP
registerAmmo(
    "ammo_45acp",
    ".45 ACP",
    "BULLET_PLAYER_45ACP",
    30,
    Model("models/Items/BoxSRounds.mdl")
)
-- 50AE
registerAmmo(
    "ammo_50ae",
    ".50 AE",
    "BULLET_PLAYER_50AE",
    14,
    Model("models/Items/BoxSRounds.mdl")
)
-- 556MM
registerAmmo(
    "ammo_556mm",
    ".556",
    "BULLET_PLAYER_556MM",
    60,
    Model("models/Items/BoxMRounds.mdl")
)
-- 556MM BOX
registerAmmo(
    "ammo_556mm_box",
    ".556 BOX",
    "BULLET_PLAYER_556MM_BOX",
    100,
    Model("models/Items/BoxMRounds.mdl")
)
-- 57MM
registerAmmo(
    "ammo_57mm",
    ".57",
    "BULLET_PLAYER_57MM",
    40,
    Model("models/Items/BoxSRounds.mdl")
)
-- 762MM
registerAmmo(
    "ammo_762mm",
    ".762",
    "BULLET_PLAYER_762MM",
    60,
    Model("models/Items/BoxMRounds.mdl")
)
-- 9MM
registerAmmo(
    "ammo_9mm",
    "9mm",
    "BULLET_PLAYER_9MM",
    40,
    Model("models/Items/BoxSRounds.mdl")
)
-- Buckshot
registerAmmo(
    "ammo_buckshot",
    "Buckshot",
    "BULLET_PLAYER_BUCKSHOT",
    16,
    Model("models/Items/BoxBuckshot.mdl")
)