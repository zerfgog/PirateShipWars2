AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= "Pistol Ammo"

ENT.Spawnable	= true

ENT.uses = 2

ENT.Model = "models/items/boxsrounds.mdl"

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetSkin(0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local phys = self.Entity:GetPhysicsObject()
		if phys and IsValid(phys) then phys:Wake() end
	end

	function ENT:SpawnFunction(ply, tr)
		if not tr.Hit then return end

		local spawnpos = tr.HitPos + tr.HitNormal * 16 
		local ent = ents.Create("ammobox_Pistol")
		ent:SetPos(spawnpos)
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:Use(activator, caller )
		if activator:IsPlayer() then 
			activator:GiveAmmo(6, "pistol")
			self.uses = self.uses - 1
		end

		if self.uses < 1 then
			self:Remove()
		end
	end

	function ENT:Think() 
	end
end

if CLIENT then
	function ENT:Initialize()
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
	end

	function ENT:Think()
	end
end
