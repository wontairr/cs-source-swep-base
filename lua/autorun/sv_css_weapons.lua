if CLIENT then return end

resource.AddSingleFile("resource/fonts/cs.ttf")

util.AddNetworkString("toClient_UpdateSprayPatternPoints")
util.AddNetworkString("toClient_UpdateSprayPatternOrigin")

util.AddNetworkString("toClient_CopySprayPattern")

util.AddNetworkString("toServer_CSSDropWeapon")

util.AddNetworkString("toServer_CSSWeaponFunction")
util.AddNetworkString("toClient_CSSWeaponFunction")
-- Used to relay reload sounds
util.AddNetworkString("toServer_CSSPlaySound")

util.AddNetworkString("toServer_CSSRequestSpawn")
util.AddNetworkString("toClient_CSSSelectWeapon")

util.AddNetworkString("toClient_CSSNotifyUpdate")

CSS_UpdateKnown = file.Exists("authentic_css_update.txt","DATA")


local function IsBeforeDeadline()
    local year  = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local day   = tonumber(os.date("%d"))

    -- Change the year if needed
    local deadlineYear  = 2025
    local deadlineMonth = 12
    local deadlineDay   = 15

    if year < deadlineYear then return true end
    if year > deadlineYear then return false end

    -- same year: compare month/day
    if month < deadlineMonth then return true end
    if month > deadlineMonth then return false end

    -- same month
    return day <= deadlineDay
end
hook.Add("Initialize","CSSUpdateNotifier",function()
    if SERVER and IsBeforeDeadline() and not CSS_UpdateKnown then
        timer.Simple(10,function()
            file.Write("authentic_css_update.txt","1")
            for _,ply in ipairs(player.GetAll()) do
                net.Start("toClient_CSSNotifyUpdate")
                net.WriteString("Hey! As of November 19th 2025, the mod has been updated to have bullet penetration! This means it will likely conflict with any other bullet penetration mod. This message will only appear once.")
                net.Broadcast()
            end
        end)
    end
end)

net.Receive("toServer_CSSRequestSpawn",function(len,ply)
    -- prevent this from being misused in another gamemode
    if engine.ActiveGamemode() != "sandbox" then return end

    local class = net.ReadString()
    local middle = net.ReadBool()
    local weapon = weapons.Get(class)
    if not weapon then return end
    if weapon.AdminOnly and not ply:IsAdmin() then return end
    if middle then
        local wep = ents.Create(class)
        if not IsValid(wep) then return end

        wep:SetPos(ply:GetEyeTrace().HitPos + Vector(0,0,25))
        wep:Spawn()
        wep:Activate()

        return
    end
    ply:Give(class)
    local wep = ply:GetWeapon(class)

    net.Start("toClient_CSSSelectWeapon")
        net.WriteString(class)
    net.Send(ply)
end)


net.Receive("toServer_CSSPlaySound",function(len,ply)
    if IsValid(ply) then
        local filter = RecipientFilter(true)
        filter:AddAllPlayers()
        filter:RemovePlayer(ply)
        local snd = net.ReadString()
        ply:EmitSound(snd,100,100,1,CHAN_AUTO,SND_NOFLAGS,0,filter)
    end
end)


net.Receive("toServer_CSSDropWeapon",function(len,ply)
    local weapon = net.ReadEntity()
    if not IsValid(weapon) or weapon:GetOwner() != ply then return end
    weapon:Drop()
end)


hook.Add("PlayerSpawn","CSSFixDropWeapons",function(ply) ply.CSSDroppingWeapons = false end)