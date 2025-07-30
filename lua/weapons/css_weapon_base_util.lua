

-- DISCLAIMER: ALOT OF THESE NETWORKING RELATED FUNCTIONS ARE BOGUS AND BALOGNEY.
-- TRY NOT TO USE THEM.

if CLIENT then
    -- Function to draw the weapon's HUD icon
    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(
            self.IconLetter,            
            "CSweapons",   
            x + wide / 2,     
            y + tall / 2,    
            Color(255, 189, 0, alpha),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
	
	-- Calls a swep function as the server
	function SWEP:CallServerFunction(funcName,ownerSafe,args)
		local noArgs = args == nil
		
		if ownerSafe == nil then ownerSafe = true end

		net.Start("toServer_CSSWeaponFunction")
			net.WriteEntity(self)
			net.WriteBool(ownerSafe)
			net.WriteString(funcName)
			net.WriteBool(noArgs)
			if not noArgs then net.WriteTable(args) end
		net.SendToServer()
	end

	-- Used in SetClientVar
	function SWEP:RemoteSetVariableClient(varName,varValue)
		if self[varName] != nil then self[varName] = varValue end
		
	end
	-- Sets a swep variable on the server
	function SWEP:SetServerVar(varName,varValue,ownerSafe)
		self:CallServerFunction("RemoteSetVariableServer",ownerSafe,{varName,varValue})
	end

elseif SERVER then
	-- Calls a swep function as the client
	function SWEP:CallClientFunction(funcName,broadcast,args)
		if not IsValid(self:GetOwner()) or CLIENT then return end
		local noArgs = args == nil
		if broadcast == nil then broadcast = false end

		net.Start("toClient_CSSWeaponFunction")
		net.WriteEntity(self)
		net.WriteString(funcName)
		net.WriteBool(!noArgs)
		if not noArgs then net.WriteTable(args) end
		if broadcast then
			net.Broadcast()
		else
			net.Send(self:GetOwner())
		end
	end
	-- Used in SetServerVar
	function SWEP:RemoteSetVariableServer(varName,varValue)
		if self[varName] != nil then self[varName] = varValue end
	end
	-- Sets a swep variable on the client
	function SWEP:SetClientVar(varName,varValue,broadcast)
		self:CallClientFunction("RemoteSetVariableClient",broadcast,{varName,varValue})
	end
end

-- This creates a timer that will remove itself if the weapon isn't deployed.
function SWEP:CreateSafeTimer(delay,ownerSafe,func)
	local name = "CSWepTimer" .. self:EntIndex() .. CurTime()
	timer.Create(name,delay,1,function()
		if not IsValid(self) or ( ownerSafe and not IsValid(self:GetOwner()) ) then return end
		func(self)
	end)
	table.insert(self.SafeTimers,name)
end
function SWEP:ClearSafeTimers()
	for _,timerName in ipairs(self.SafeTimers) do
		timer.Remove(timerName)
	end
end

--[[
In singleplayer, some shared SWEP functions aren't actually shared and only work on a multiplayer server.

Example: Deploy is on both client and server, but in singleplayer the code only is called on the server.
So if you want to set a variable thats on the client, you would use this function.
--]]
function SWEP:ClientSetVar(varName,varValue,broadcast)
	if SERVER and game.SinglePlayer() then
		self:SetClientVar(varName,varValue,broadcast)
	elseif CLIENT and not game.SinglePlayer() then
		self[varName] = varValue
	end
end
-- Same as above, but for functions (only functions that are on the server AND the client)
function SWEP:ClientFunction(funcName,broadcast,args)
	if SERVER and game.SinglePlayer() then
		if not istable(args) then args = {args} end
		self:CallClientFunction(funcName,broadcast,args)
	elseif CLIENT and not game.SinglePlayer() then
		self[funcName](self,(istable(args) and unpack(args) or args))
	end
end
-- Same as ClientSetVar but also sets the var on the server.
function SWEP:SharedSetVar(varName,varValue,broadcast)
	if SERVER then
		if game.SinglePlayer() then
			self:SetClientVar(varName,varValue,broadcast)
		end
		self[varName] = varValue
	elseif CLIENT and not game.SinglePlayer() then
		self[varName] = varValue
	end
end
-- Same as ClientFunction but also calls the function on the server
function SWEP:SharedFunction(funcName,broadcast,args)
	if SERVER then
		if game.SinglePlayer() then
			if not istable(args) then args = {args} end
			self:CallClientFunction(funcName,broadcast,args)
		end
		self[funcName](self,(istable(args) and unpack(args) or args))
	elseif CLIENT and not game.SinglePlayer() then
		self[funcName](self,(istable(args) and unpack(args) or args))
	end
end

-- Used in accuracy changing stuff
function SWEP:ReplaceTable(tableA,tableB)
    for key, value in pairs(tableA) do
        if tableB[key] then tableA[key] = tableB[key] end
    end
end

function SWEP:GetAnimation(animation)
	if animation == "Fire" then 
		if self:GetSilenced() then return ACT_VM_PRIMARYATTACK_SILENCED else return ACT_VM_PRIMARYATTACK end
	end
	if animation == "Reload" then 
		if self:GetSilenced() then return ACT_VM_RELOAD else return ACT_VM_RELOAD_SILENCED end
	end
end
local nilSound = Sound("garrysmod/balloon_pop_cute.wav")
function SWEP:GetSound(snd)
	if snd == "PrimaryFire" then 
		if self:GetSilenced() then
			return self.Primary.SoundSilenced or nilSound
		else
			return Choose(self:Clip1() > 0, self.Primary.Sound,self.Primary.SoundRaw) or nilSound
		end
	end
	if snd == "SecondaryFire" then 
		return self.Secondary.Sound or nilSound
	end
	return nilSound
end

-- Do weapon and player animation
function SWEP:SendAnimation(weaponAnim,playerAnim)
	self:SendWeaponAnim(weaponAnim)
	local owner = self:GetOwner()
	if IsValid(owner) then
		owner:SetAnimation(playerAnim)
	end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if ( not self.CSMuzzleFlashes ) then return end
	-- Third person muzzleflash
	if (event == 5003 and (self:GetSilenced() == true or self.NoMuzzleFlash)) then return true end
	-- CS Muzzle flashes
	if ( event == 5001 or event == 5011 or event == 5021 or event == 5031 ) then
		if self:GetSilenced() or self.NoMuzzleFlash then return true end
	
		local data = EffectData()
		data:SetFlags( 0 )
		data:SetEntity( self:GetOwner():GetViewModel() )
		data:SetAttachment( self.MuzzleAttachment )
		data:SetScale( self.CSMuzzleScale ) 
		if ( self.CSMuzzleX ) then
			util.Effect( "CS_MuzzleFlash_X", data )
		else
			util.Effect( "CS_MuzzleFlash", data )
		end
	
		return true
	end

end

function SWEP:ResetVariables(dontResetDropped,dontClearSafeTimers)
	self:ResetScoping()
	self.Equipped = false
	self.ShotgunReloading = false

	local owner = self:GetOwner()
	if IsValid(owner) and not owner:IsNPC() then
		owner:SetCanZoom(true)
		if SERVER then
			local speedType = CSSServerConvars.weapons_player_slowing:GetInt()
			if speedType == 1 then
				owner:SetWalkSpeed(self.OGWalkSpeed)
			elseif speedType == 2 then
				owner:SetWalkSpeed(self.OGWalkSpeed)
				owner:SetRunSpeed(self.OGRunSpeed)
			end
		end
	end
	self.BurstLeft = 0
	self.BurstNext = 0

	self:SetReloading(false)
	self:SetHoldType(self.HoldType)

	if not dontClearSafeTimers then self:ClearSafeTimers() end

	if dontResetDropped then return end
	self:SetDropped(false)
end


function SWEP:SetVMFlip()
	local flip = !CSSClientConvars.weapons_lefthand:GetBool()
	if self.UseHands then flip = !flip self.ViewModelFlip = flip return end

	if self.ViewModelRightHanded then flip = !flip end

	self.ViewModelFlip = flip
end