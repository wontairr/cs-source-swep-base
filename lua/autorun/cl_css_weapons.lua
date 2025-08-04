if SERVER then return end

CSSClientConvars = {

weapons_viewsway        = CreateClientConVar("css_cl_weapons_weaponsway","1",true,true,
"Enables classic CS:S weapon sway if set higher than 0. 1 includes view sway, 2 disables view sway.",0,2),

weapons_lefthand        = CreateClientConVar("css_cl_weapons_lefthand","0",true,true,
"Flips the viewmodel over to the left side.",0,1),

weapons_carms_adjust    = CreateClientConVar("css_cl_weapons_adjust_carms","1",true,true,
"If set to 1 and `css_sv_weapons_use_arms` is set to 1 then the C models will be adjusted to look like how the default CS:S Viewmodels look.",0,1),

flashbang_dark          = CreateClientConVar("css_cl_flashbang_dark","0",true,true,
"Makes the flashbang flash dark instead of bright",0,1),

drop_bind               = CreateClientConVar("css_cl_drop_bind",tostring(KEY_G),true,true,
"The key to press to drop weapons.")

}

cvars.AddChangeCallback("css_cl_weapons_adjust_carms",function(name,old,new)
    if not IsValid(LocalPlayer()) then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep.Base == "css_weapon_base" then
        if tonumber(new) == 1 then
            wep.ViewModelFOV = 74
        else
            wep.ViewModelFOV = 54
        end
        wep:SetHoldType(wep.HoldType)
    end
end,"css_cl_carms_adjust_change")

cvars.AddChangeCallback("css_cl_weapons_lefthand",function(name,old,new)
    if not IsValid(LocalPlayer()) then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep.Base == "css_weapon_base" then
        wep:SetVMFlip()
        wep:SetHoldType(wep.HoldType)
    end
end,"css_cl_lefthand_change")

surface.CreateFont("CSweapons",{
    font = "cs",
    size = 170,
	weight = 100,
	antialias = true,
	outline = false
})

surface.CreateFont("CSKillIcons",{
    font = "csd",
    size = 100,
	weight = 100,
	antialias = true,
	outline = false
})



net.Receive("toClient_UpdateSprayPatternPoints",function()
    local weapon = net.ReadEntity()
    if not IsValid(weapon) then return end
    weapon.Points = net.ReadTable(true)

end)

net.Receive("toClient_UpdateSprayPatternOrigin",function()
    local weapon = net.ReadEntity()
    if not IsValid(weapon) then return end
    weapon.StartPos = net.ReadVector()
    weapon.StartAngle = net.ReadAngle()
end)


net.Receive("toClient_CopySprayPattern",function()
    local points = net.ReadTable(true)
    local code = [[
{

]]
    for _,point in ipairs(points) do
        code = code .. "\tAngle(" .. point.x .. "," .. point.y .. "," .. point.z .. ")" .. ",\n"
    end
    code = code .. "\n}"
    SetClipboardText(code)
end)
