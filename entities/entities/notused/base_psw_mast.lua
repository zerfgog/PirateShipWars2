AddCSLuaFile()

ENT.Type	= "anim"
ENT.Model	= Model("models/props_c17/woodbarrel001.mdl")

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	function ENT:OnRemove()
		self:Remove()
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
