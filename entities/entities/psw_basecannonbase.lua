AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= "Forts Cannon"
ENT.Author		= "Thomas Hansen"
ENT.Model		= "models/frigate01/cannon/cannonbase.mdl"
ENT.Category	= "Pirate Ship Wars 2"

ENT.Spawnable	= true

ENT.HeldCannon	= "psw_fortscannon"
ENT.HCOffset	= 12

if SERVER then
	function ENT:SpawnFunction(ply, tr, classname)
		if not tr.Hit then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create(classname)
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		local cannon = ents.Create(self.HeldCannon)
		cannon:SetPos(self:GetPos() + Vector(0, 0, self.HCOffset))
		local cannonangle = self:GetAngles() + Angle(0, 180, 0)
		cannon:SetAngles(cannonangle)
		cannon:Spawn()
		cannon:SetParent(self)
	end

	function ENT:Use( ply, caller )
		return
	end
end

if CLIENT then
	function ENT:Initialize()
		self.Color = COLOR_WHITE
	end

	function ENT:Draw()
		self.Entity:DrawModel()
	end
end
