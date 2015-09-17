AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "Powder Keg"
ENT.Category	= "Pirate Ship Wars 2"

ENT.Spawnable	= false

ENT.BounceSound	= Sound("HEGrenade.Bounce")

ENT.Model		= "models/weapons/w_keg/w_keg.mdl"

ENT.BaseDamage	= 150

if CLIENT then
	killicon.Add("psw_grenade", "hud/keg", COLOR_WHITE)
end

function ENT:PhysicsCollide(data, phys)
	if CLIENT then
		if data.Speed > 50 then
			self:EmitSound(self.BounceSound)
		end
	end
	if SERVER then
		local impulse = -data.Speed * data.HitNormal * .2 + (data.OurOldVelocity * -.4) --.4 .6
		phys:ApplyForceCenter(impulse)
	end
end

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)

		-- Don't collide with the player
		--self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end

	self.timer = CurTime() + 3
end

function ENT:Think()
	if self.timer < CurTime() then
		if SERVER then
			local range		= 512
			local damage	= 0
			local pos		= self:GetPos()

			self:EmitSound(Sound("weapons/hegrenade/explode"..math.random(3,5)..".wav"))
			self:Remove()

			target_ents = ents.FindInSphere(pos, 150)
			for i, ent in pairs(target_ents) do
				if ent:IsPlayer() then
					if (ent:Team() ~= self.Owner:Team()) or (ent == self.Owner) then
						local expdmg = self.BaseDamage - pos:Distance(ent:GetPos())
						ent:TakeDamage(expdmg, self.Owner)
					end
				end
			end

			local explode = ents.Create("env_explosion")
			explode:SetPos(self.Entity:GetPos())
			explode:SetOwner(self.Owner)
			explode:SetKeyValue("iMagnitude", 120)
			explode:SetKeyValue("iRadiusOverride", 500)
			explode:Fire("Explode", 0, 0)
			explode:Spawn()
			explode:Activate()
		end
	end
end
