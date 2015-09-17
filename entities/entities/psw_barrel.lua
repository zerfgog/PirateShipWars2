AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "Explosive Barrel"
ENT.Category	= "Pirate Ship Wars 2"

ENT.Spawnable	= true

ENT.Model = Model("models/weapons/w_keg/w_keg.mdl")

if SERVER then
	function ENT:SpawnFunction(ply, tr, ClassName)
		if not tr.Hit then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create(ClassName)
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		--self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self.nextUse = 0

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end
	
	function ENT:OnTakeDamage(dmg)
		self:Explode()
	end

	function ENT:Use(ply,caller)
		if self.nextUse > CurTime() then return end
		self.nextUse = CurTime()+6
		if ply:IsPlayer() then
			if self:GetName() == "ship1explosive" or self:GetName() == "ship2explosive" then
				PrintMessage(HUD_PRINTTALK, "Player " .. ply:Nick() .. " has set a fuse on the powder stores which explode in 5 seconds")
				timer.Create("explosion", 5, 0, function() self:Explode() end)
			else
				PrintMessage(HUD_PRINTTALK, "Entity " .. ply:GetName() .. " has set a fuse on the powder stores which explode in 5 seconds")
				timer.Create("explosion", 5, 0, function() self:Explode() end)
			end
		end
	end

	function ENT:Explode()
		local explode = ents.Create("env_explosion") -- creates the explosion
		explode:SetPos(self.Entity:GetPos())
		explode:SetOwner(self.Owner) -- this sets you as the person who made the explosion
		explode:SetKeyValue("iMagnitude", 2000)
		explode:SetKeyValue("iRadiusOverride", 400)
		explode:Fire("Explode", 0, 0)	
		explode:Spawn() -- this actually spawns the explosion
		explode:Activate()
		self:Remove()
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end