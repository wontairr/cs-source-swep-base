AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Damage Dummy"

ENT.Spawnable = true
ENT.Category = "Counter-Strike: Source"

ENT.rag = nil

CSS_SPAWNEDDUMMY = false

function ENT:Draw() end




function ENT:OnRemove()
    if SERVER and IsValid(self.rag) then
        self.rag:Remove()
    end
end

local red = Color(255,0,0)


local texttodraw = {}
local function _inserttext(text,_pos,time)
    text = tostring(text)
    table.insert(texttodraw,{
        txt = text,
        pos = _pos,
        life = CurTime() + time
    })
end

if SERVER then
    util.AddNetworkString("toClient_CSSDummy")
else
    net.Receive("toClient_CSSDummy",function()
        _inserttext(net.ReadString(),net.ReadVector(),net.ReadFloat())
    end)
end
local function inserttext(text,_pos,time)
    net.Start("toClient_CSSDummy")
    text = tostring(text)
    net.WriteString(text)
    net.WriteVector(_pos)
    net.WriteFloat(time)
    net.Broadcast()
end
if CLIENT then
        surface.CreateFont("DUMMYArial", {
        font = "Arial",
        size = 50,
        weight = 500,
        outline = true
    })
end
local white = Color(255,255,255)
local function CREATE_HOOKS()
    if CSS_SPAWNEDDUMMY then return end
    hook.Add("HUDPaint","CSSDamageDummyHudStuff",function()
        for _,text in ipairs(texttodraw) do
            if CurTime() > text.life then
                table.remove(texttodraw,_)
            else
                local x,y = 0,0
                local screen = text.pos:ToScreen()
                x = screen.x
                y = screen.y
                draw.SimpleText(text.txt,"DUMMYArial",x + 2,y + 2,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(text.txt,"DUMMYArial",x,y,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end
    end)
    hook.Add("PostEntityTakeDamage","CSSDamageDummy",function(ent,dmginfo,wasdamagetaken)
        if IsValid(ent) and ent.damagedummy and IsValid(ent.damagedummy) and dmginfo:GetDamage() >= 1 then
            debugoverlay.Sphere(dmginfo:GetDamagePosition(),3,1,red)
            inserttext(dmginfo:GetDamage(),dmginfo:GetDamagePosition(),3)
            
        end
    end)
end





function ENT:Initialize()
    CREATE_HOOKS()
    CSS_SPAWNEDDUMMY = true
    self:SetModel("")

    self:SetNoDraw(true)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then phys:Wake() end

    if SERVER then
        self.rag = ents.Create("npc_breen")
        self.rag:SetModel("models/player/t_phoenix.mdl")
        self.rag:SetPos(self:GetPos())
        self.rag:SetAngles(self:GetAngles())
        self.rag:Spawn()
        self.rag:SetMaxHealth(9999)
        self.rag:SetHealth(9999)
        self.rag.damagedummy = self

    end
end