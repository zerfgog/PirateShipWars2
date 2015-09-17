AddCSLuaFile()

ENT.Type = "anim"
ENT.Model	= Model("models/props_c17/woodbarrel001.mdl")

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
end


function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
		
	local phys = self:GetPhysicsObject()
		
	if IsValid(phys) then
		phys:Wake()
		phys:SetElasticity(1)
	end
end