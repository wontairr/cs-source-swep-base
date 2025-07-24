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