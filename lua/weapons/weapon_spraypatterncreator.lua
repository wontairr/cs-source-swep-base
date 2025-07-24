if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Spray Pattern Creator"
SWEP.Instructions = "To start, press ALT + R to center (and to reset)\nThen press RIGHT CLICK to start.\n Pressing LEFT CLICK makes a point, Pressing R copies the code."
SWEP.Spawnable = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1

SWEP.Points = {}
SWEP.VisPoints = {}
SWEP.StartPos = Vector(0,0,0)
SWEP.StartAngle = Angle(0,0,0)

function SWEP:CanPrimaryAttack()
    return CurTime() >= self:GetNextPrimaryFire()
end


function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:EmitSound("friends/friend_join.wav",100,100,1,CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    local currentAngle = self:GetOwner():EyeAngles()
    local point = currentAngle - self.StartAngle
    self:GetOwner():ChatPrint("Point Created! " .. "(" .. currentAngle.x .. "," .. point.y .. "," .. point.z .. ")")

    if #self.Points == 0 then point = Angle(0,0,0) end

    table.insert(self.Points, point)
    table.insert(self.VisPoints,currentAngle)
    //self.StartAngle = currentAngle
    if SERVER then        
        net.Start("toClient_UpdateSprayPatternPoints")
            net.WriteEntity(self)
            net.WriteTable(self.VisPoints,true)
        net.Send(self:GetOwner())
    end
end

function SWEP:SecondaryAttack()
    self:EmitSound("friends/friend_online.wav",100,100,1,CHAN_AUTO)
    self.StartPos = self:GetOwner():EyePos()
    self.StartAngle = self:GetOwner():EyeAngles()
    self:GetOwner():ChatPrint("Origin Set!")
    if SERVER then
        net.Start("toClient_UpdateSprayPatternOrigin")
            net.WriteEntity(self)
            net.WriteVector(self.StartPos)
            net.WriteAngle(self.StartAngle)
        net.Send(self:GetOwner())
    end
end

function SWEP:Reload()
    if not self:GetOwner():KeyPressed(IN_RELOAD) then return end
    if not IsFirstTimePredicted() then return end
    if self:GetOwner():KeyDown(IN_WALK) then
        self.Points = {}
        self.VisPoints = {}
        self:GetOwner():ChatPrint("Pattern Reset!")
        if not SERVER then return end
        self:GetOwner():SetEyeAngles(Angle(0,-90,0))
        net.Start("toClient_UpdateSprayPatternPoints")
            net.WriteEntity(self)
            net.WriteTable({},true)
        net.Send(self:GetOwner())
    else
        self:GetOwner():ChatPrint("Code Copied To Clipboard!")
        if not SERVER then return end
        net.Start("toClient_CopySprayPattern")
            net.WriteTable(self.Points,true)
        net.Send(self:GetOwner())
    end
end

function SWEP:DrawHUD()
    draw.SimpleText("Points: " .. #self.Points,"Trebuchet24",ScrW()/2.5,ScrH()/2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    surface.SetDrawColor(255,0,0)
    surface.DrawLine(ScrW()/2,ScrH()/2 - 25,ScrW()/2,ScrH()/2 + 25)
    surface.DrawLine(ScrW()/2 - 25,ScrH()/2,ScrW()/2 + 25,ScrH()/2)
    surface.DrawCircle(ScrW()/2,ScrH()/2,2,0,255,0,255)
end



hook.Add("PostDrawTranslucentRenderables","SprayPatternCreatorHook",function()
    if CLIENT then
        render.SetColorMaterial()
        local weapon = nil  
        if IsValid(player.GetByID(1)) and IsValid(player.GetByID(1):GetActiveWeapon()) and player.GetByID(1):GetActiveWeapon():GetClass() == "weapon_spraypatterncreator" then
            weapon = player.GetByID(1):GetActiveWeapon()
        end
        if not IsValid(weapon) then return end

        local playerPos = weapon:GetOwner():EyePos()
        local direction = -weapon:GetOwner():EyeAngles():Forward() * 30
        render.SetMaterial(Material("spraypatterncreator/square.png"))
        render.DrawQuadEasy(weapon.StartPos + weapon.StartAngle:Forward() * 30 + weapon.StartAngle:Up() * 6.5, direction, 6.4, 14, color_white, 0)

        for _,point in ipairs(weapon.Points) do
            render.DrawWireframeSphere(weapon.StartPos + point:Forward() * 30,0.5,15,15,color_white)
            //render.DrawBeam(self.StartPos,self.StartPos + point:Forward() * 10,20,1,1,color_blue)
        end
    end
end)

