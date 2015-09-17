ENT.Type = "anim"

ENT.PrintName		= "Pirate Grenade"
ENT.Author			= "Night-Eagle, Metroid48"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.BounceSound = Sound("HEGrenade.Bounce")
ENT.Model = "models/powdergrenade/powdergrenade.mdl"

if SERVER then
	function ENT:OnTakeDamage(dmginfo)
	end

	function ENT:PhysicsCollide(data,phys)
		if data.Speed > 50 then
			self.Entity:EmitSound(self.BounceSound)
		end

		local impulse = -data.Speed * data.HitNormal * .2 + (data.OurOldVelocity * -.4) --.4 .6
		phys:ApplyForceCenter(impulse)
	end

	function ENT:Initialize()
		self.Entity:SetModel(self.Model)

		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)

		local phys = self.Entity:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		self.timer = CurTime() + 3
	end

	function ENT:Think()
		if self.timer < CurTime() then
			if SERVER then	
				self.Entity:EmitSound(Sound("weapons/hegrenade/explode"..math.random(3,5)..".wav"))
				self.Entity:Remove()

				local explode = ents.Create("env_explosion")
				explode:SetPos(self.Entity:GetPos())
				explode:SetOwner(self.Owner)
				explode:SetKeyValue("iMagnitude", 120)
				explode:SetKeyValue("iRadiusOverride", 500)
				--explode:SetKeyValue( "iIgnoredClass", "func_breakable" )
				explode:Fire("Explode", 0, 0)
				explode:Spawn()
				explode:Activate()
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent(bDontDrawModel)
		self:Draw()
	end
end
