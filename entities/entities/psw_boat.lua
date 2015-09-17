AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "Boat"
ENT.Category	= "Pirate Ship Wars 2"
ENT.Spawnable	= true

if SERVER then
	function ENT:SpawnFunction(ply, tr, classname)
		if not tr.Hit then return end
		local spawnpos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create(classname)
		ent:SetPos(spawnpos)
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/boat/boat1.mdl")

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:SetBuoyancyRatio(0.025)
			phys:Wake()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
