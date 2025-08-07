AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "Counter-Strike: Source"
ENT.Spawnable = false

ENT.Model = "models/Items/BoxSRounds.mdl"
ENT.Ammo = ""
ENT.Amount = 1
ENT.PickedUp = false

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then phys:Wake() end
    if SERVER then
        self:SetTrigger(true)
    end
    self:UseTriggerBounds(true,24)
    self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:Touch(ent)
    if CLIENT or self.PickedUp then return end
    self.PickedUp = true 
    if ent:IsPlayer() then
        ent:GiveAmmo(self.Amount,self.Ammo,false)
        if not self:IsMarkedForDeletion() then
            self:Remove()
        end
    end
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end