AddCSLuaFile()

ENT.Type	= "anim"
ENT.Sail	= Model( "" )

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
end

if CLIENT then
	function ENT:Initialize()
		local mdl = ClientsideModel(self.Sail, RENDERGROUP_BOTH)
		mdl:SetPos(self:GetPos())
		mdl:SetAngles(self:GetAngles())
		mdl:SetParent(self)
		mdl:SetColor(COLOR_WHITE)
		mdl:Spawn()

		--timer.Simple(5, function() mdl:Remove() end)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end