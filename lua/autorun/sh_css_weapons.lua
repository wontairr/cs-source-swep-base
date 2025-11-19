if SERVER then
    net.Receive("toServer_CSSWeaponFunction",function(len,ply)
        local weapon = net.ReadEntity()
        local ownerSafe = net.ReadBool()
        if not IsValid(weapon) or (ownerSafe and weapon:GetOwner() != ply) then return end

        local func = net.ReadString()

        if not weapon[func] then return end

        local args = {}
        local readArgs = net.ReadBool()
        if readArgs then args = net.ReadTable() end

        weapon[func](weapon,unpack(args))
    end)

elseif CLIENT then

    net.Receive("toClient_CSSWeaponFunction",function(len)
        local weapon = net.ReadEntity()
  
        if not IsValid(weapon) then return end
        local func = net.ReadString()

        if not weapon[func] then return end
        
        local args = {}
        local readArgs = net.ReadBool()
        if readArgs then args = net.ReadTable() end
        

        weapon[func](weapon,unpack(args))
    end)
end
-- I don't know why this is here but keeping for compatibility sake.
function Choose(condition,out1,out2)
    if condition then return out1 else return out2 end
end

CSSBaseClass = baseclass.Get("css_weapon_base")

local ARCHIVED_REPLICATED = {FCVAR_ARCHIVE,FCVAR_REPLICATED}

CSSServerConvars = {
    weapons_randomspraypatternflip  = CreateConVar("css_sv_weapons_randomspraypatternflip","1",ARCHIVED_REPLICATED,
    "Enables random horizontal flipping of weapon spray patterns if the weapon supports it.",0,1),
    weapons_sniper_unscopeaftershot = CreateConVar("css_sv_weapons_sniper_unscope_aftershot","1",ARCHIVED_REPLICATED,
    "Enables snipers unscoping after a shot.",0,1),
    weapons_give_ammo_sandbox       = CreateConVar("css_sv_sandbox_weapons_give_ammo","1",ARCHIVED_REPLICATED,
    "Makes weapons give a little reserve ammo when spawning them in.",0,1),
    weapons_infinite_grenades       = CreateConVar("css_sv_weapons_infinite_grenades","0",ARCHIVED_REPLICATED,
    "Grenades wont be removed when thrown if set to 1.",0,1),
    weapons_pistols_automatic       = CreateConVar("css_sv_weapons_pistols_automatic","0",ARCHIVED_REPLICATED,
    "Pistols are automatic (and more responsive) when set to 1."),
    weapons_sandbox_slots           = CreateConVar("css_sv_weapons_sandbox_slots","1",ARCHIVED_REPLICATED,
    "If set to 1, weapons will be organized more conveniently for sandbox. Otherwise, they will be in the default CS:S slot positions."),

    weapons_carms                   = CreateConVar("css_sv_weapons_use_arms","0",ARCHIVED_REPLICATED,
    "If set to 1, the viewmodels will use C Arms (Arms of your playermodel) NOTE: These look worse/have animation issues."),

    weapons_real_ammo                   = CreateConVar("css_sv_weapons_use_css_ammo","0",ARCHIVED_REPLICATED,
    "If set to 1, weapons that support it will use CS:S ammo types instead of HL2 ammo types."),

    weapons_penetration             = CreateConVar("css_sv_weapon_penetration","1",ARCHIVED_REPLICATED,
    "If set to 1, weapons will penetrate through certain materials like wood."),
    weapons_penetration_mult        = CreateConVar("css_sv_weapon_penetration_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplies the distance weapons can penetrate."),

    weapons_spray_debug             = CreateConVar("css_sv_debug_weapon_spray","0",ARCHIVED_REPLICATED,
    "If set to 1, weapons will show debugging visuals for the spray pattern/bullet direction.",0,1),

    weapons_damage_real_scale       = CreateConVar("css_sv_weapons_damage_css_scales","1",ARCHIVED_REPLICATED,
    "If set to 1, weapon damage will use real CS:S damage scaling. (4x for head, 1.25x for stomach, etc.)"),

    weapons_damage_multiplier       = CreateConVar("css_sv_weapons_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all weapon damage.",0,10),

    weapons_rifle_damage_multiplier       = CreateConVar("css_sv_weapons_rifle_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all rifle damage.",0,10),
    weapons_smg_damage_multiplier       = CreateConVar("css_sv_weapons_smg_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all smg damage.",0,10),
    weapons_pistol_damage_multiplier       = CreateConVar("css_sv_weapons_pistol_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all pistol damage.",0,10),
    weapons_shotgun_damage_multiplier       = CreateConVar("css_sv_weapons_shotgun_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all shotgun damage.",0,10),
    weapons_sniper_damage_multiplier       = CreateConVar("css_sv_weapons_sniper_damage_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all sniper damage.",0,10),

    weapons_force_multiplier        = CreateConVar("css_sv_weapons_force_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier of all weapon force.",0,10),

    weapons_npc_accuracy            = CreateConVar("css_sv_weapons_npc_accuracy","0.7",ARCHIVED_REPLICATED,
    "For NPCs only: 0.0 is poor accuracy, 1.0 is perfect accuracy.",0.0,1.0),
    weapons_npc_damage_multiplier   = CreateConVar("css_sv_weapons_npc_damage_multiplier","1.0",ARCHIVED_REPLICATED,
    "Multiplier of damage for weapons held by NPCs",0.0,10),

    weapons_drop                    = CreateConVar("css_sv_weapons_drop_on_death","0",ARCHIVED_REPLICATED,
    "If set to 1, players will drop CS:S weapons on death.",0,1),

    weapons_autoswitch              = CreateConVar("css_sv_weapons_autoswitch","1",ARCHIVED_REPLICATED,
    "If set to 1, whenever you pickup a rifle or similar, you will autoswitch to it.",0,1),

    weapons_alt_viewpunch           = CreateConVar("css_sv_weapons_alt_viewpunch","0",ARCHIVED_REPLICATED,
    "If set to 1, CS:S weapons will use an alternative viewpunch that may be more or less authentic, depending on what you think.",0,1),

    weapons_lock_counts             = CreateConVar("css_sv_weapons_lock_counts","0",ARCHIVED_REPLICATED,
    "If set to 1, you can only hold one primary or secondary.",0,1),

    weapons_player_slowing          = CreateConVar("css_sv_weapons_player_slowing","0",ARCHIVED_REPLICATED,
    "If set to 1, player movement speed will be affected by whatever weapon they're holding. If set to 2, sprinting speed will be CS:S walk speed + crouching will be like CS:S.",0,2),

    weapons_disable_zoom             = CreateConVar("css_sv_weapons_disable_zoom","1",ARCHIVED_REPLICATED,
    "If set to 1, players wont be able to use +zoom when holding css weapons.",0,1),


    flashbang_blindtime_multiplier  = CreateConVar("css_sv_flashbang_blindtime_multiplier","1",ARCHIVED_REPLICATED,
    "Multiplier for the blind time of the flashbang.",0.0,1.0),
    flashbang_blind_maxalpha        = CreateConVar("css_sv_flashbang_blind_maxalpha","255",ARCHIVED_REPLICATED,
    "Maximum blind color alpha.",0,255),
}




function CSS_Viewmodel(default_path)
    local carms = CSSServerConvars.weapons_carms:GetBool()
    if carms then return Model(string.Replace(default_path,"models/weapons/v_","models/weapons/cstrike/c_")) end
    return Model(default_path)
end

function CSS_ShrinkSprayPattern(sprayPattern,factor,createNewAngles)
	factor = factor or 0.75

    for i, ang in ipairs(sprayPattern) do
        if createNewAngles then
            sprayPattern[i] = Angle(ang.p * factor,ang.y * factor,ang.r)
        else
            ang.p = ang.p * factor
            ang.y = ang.y * factor
            sprayPattern[i] = ang
        end
    end

end

function CSS_UsingArms() return CSSServerConvars.weapons_carms:GetBool() end
-- Usage: SWEP.Primary.Ammo = CSS_GetAmmo("ar2","BULLET_PLAYER_762MM").
function CSS_GetAmmo(hl2ammo,cssammo) return CSSServerConvars.weapons_real_ammo:GetBool() and cssammo or hl2ammo end


CSS_Rifle   = 1
CSS_Pistol  = 2
CSS_Smg     = 3
CSS_Shotgun = 4
CSS_Sniper  = 5
CSS_Admin   = 6
CSS_Utility = 7
CSS_Misc    = 8

local SlotsSandbox = {
    2, -- CSS_Rifle   = 
    1, -- CSS_Pistol  = 
    2, -- CSS_Smg     = 
    3, -- CSS_Shotgun = 
    4, -- CSS_Sniper  = 
    2, -- CSS_Admin   = 
    4, -- CSS_Utility = 
    0 -- CSS_Misc    = 
}

function CSS_SelectSlot(gunType)
    local sandbox = CSSServerConvars.weapons_sandbox_slots:GetBool()
    if sandbox then

        return SlotsSandbox[gunType]
    else
        if gunType != CSS_Pistol then return 0 else return 1 end
    end
    return 0
end


cvars.AddChangeCallback("css_sv_weapons_use_arms",function()
    MsgC(Color(255,0,0),"css_sv_weapons_use_arms: You have to restart/change the map for the changes to take effect!\n")
end,"css_sv_use_arms_change")

cvars.AddChangeCallback("css_sv_weapons_pistols_automatic",function()
    MsgC(Color(255,0,0),"css_sv_weapons_pistols_automatic: You have to restart/change the map for the changes to take effect!\n")
end,"css_sv_pistols_change")

cvars.AddChangeCallback("css_sv_weapons_sandbox_slots",function()
    MsgC(Color(255,0,0),"css_sv_weapons_sandbox_slots: You have to restart/change the map for the changes to take effect!\n")
end,"css_sv_slots_change")

cvars.AddChangeCallback("css_sv_weapons_use_css_ammo",function()
    MsgC(Color(255,0,0),"css_sv_weapons_use_css_ammo: You have to restart/change the map for the changes to take effect!\n")
end,"css_sv_ammo_change")

cvars.AddChangeCallback("css_sv_debug_weapon_spray",function(c,o,n)
    if tobool(n) then
        MsgC(Color(255,170,0),"css_sv_weapons_sandbox_slots: Make sure 'developer' is set to 1 to see the debugging visuals.\n")
    end
end,"css_sv_debugspray_change")

local primary = {
    [CSS_Rifle] = true, 
    [CSS_Sniper] = true,
    [CSS_Shotgun] = true,
    [CSS_Smg] = true,
}

hook.Add( "PlayerCanPickupWeapon", "CSSSinglePickup", function( ply, newWep )
    if newWep.CSSWeapon and newWep.Type and CSSServerConvars.weapons_lock_counts:GetBool() and not ply:HasWeapon( newWep:GetClass() ) then
		for _, wep in ipairs(ply:GetWeapons()) do
            if wep.Type and ((primary[wep.Type] and primary[newWep.Type]) or (wep.Type == CSS_Pistol and newWep.Type == CSS_Pistol)) then return false end
        end
	end
end )

hook.Add("ScaleNPCDamage","CSSScaleNPCDamage",function(npc,hitgroup,dmginfo)
    if not CSSServerConvars.weapons_damage_real_scale:GetBool() then return end
    if IsValid(npc) then
        local att = dmginfo:GetAttacker()
        if not IsValid(att) then return end
        local wep = att:GetActiveWeapon()

        if IsValid(wep) and not wep.CSSWeapon then return end
        if hitgroup == HITGROUP_HEAD then
            dmginfo:ScaleDamage(4)
        elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
            dmginfo:ScaleDamage(0.75)
        elseif hitgroup == HITGROUP_STOMACH then
            dmginfo:ScaleDamage(1.25)
        end

        return true
    end
end)
hook.Add("ScalePlayerDamage","CSSScalePlayerDamage",function(ply,hitgroup,dmginfo)
    if not CSSServerConvars.weapons_damage_real_scale:GetBool() then return end
    if IsValid(ply) then
        local att = dmginfo:GetAttacker()
        if not IsValid(att) then return end
        local wep = att:GetActiveWeapon()

        if IsValid(wep) and not wep.CSSWeapon then return end
        if hitgroup == HITGROUP_HEAD then
            dmginfo:ScaleDamage(4)
        elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
            dmginfo:ScaleDamage(0.75)
        elseif hitgroup == HITGROUP_STOMACH then
            dmginfo:ScaleDamage(1.25)
        end

        return true
    end
end)