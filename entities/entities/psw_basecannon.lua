AddCSLuaFile()

ENT.Type	= "anim"
ENT.Base	= "base_anim"
ENT.PrintName	= "Ships Cannon Only"
ENT.Author		= "Thomas Hansen"
ENT.Category	= "Pirate Ship Wars 2"
ENT.Spawnable	= false

ENT.NextAttack	= CurTime()
ENT.NextUse		= CurTime()
ENT.LastThink	= CurTime()

ENT.SSMin = 0.3
ENT.SSMax = 0.6

ENT.Model = "models/frigate01/cannon/cannon.mdl"

ENT.Pang = 18
ENT.Yang = 8

ENT.weps = {}

if CLIENT then
	killicon.Add("psw_shipscannonsmall", "killicons/sent_cball_killicon", COLOR_WHITE)
	killicon.Add("psw_cannonball", "killicons/sent_cball_killicon", COLOR_WHITE)
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetSolid(SOLID_VPHYSICS)
	end

	function ENT:Use(ply, caller)
		if self.NextUse > CurTime() then return end
		self.NextUse = CurTime() + 0.5
		local owner = self.Entity:GetOwner()
		if ply:IsPlayer() then
			if owner and IsValid(owner) and owner:IsPlayer() and owner:Alive() and ply ~= owner then ply:PrintMessage(HUD_PRINTTALK, "Someone be using that!") return end
			if not ply:KeyPressed(IN_USE) then return end
			ply:SetMoveType(MOVETYPE_NONE)
			ply:SetGravity(0)
			ply:DrawViewModel(false)
			ply.Cannon = self
			self.Entity:SetOwner(ply)

			self.weps = {}
			for _, wep in pairs(ply:GetWeapons()) do
				self.weps[#self.weps + 1] = wep:GetClass()
			end
			ply:StripWeapons()
		end
	end

	function ENT:Deactivate()
		local ply = self.Entity:GetOwner()
		if IsValid(ply) and ply:IsPlayer() then
			self:SetOwner(self:GetParent())
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetGravity(1)
			ply:DrawViewModel(true)
			ply.Cannon = false

			for _, wep in pairs(self.weps) do
				ply:Give(wep)
			end
		end
	end

	function ENT:Think()
		local owner = self.Entity:GetOwner()
		if owner:IsPlayer() and owner:Alive() then
			local ownerpos = owner:GetPos()
			local cannonpos = self:GetPos()

			if cannonpos:Distance(ownerpos) > 120 then
				self:Deactivate()
				return
			end

			if owner:KeyDown(IN_USE) then
				if self.NextUse < CurTime() then
					self.NextUse = CurTime() + 0.5
					self:Deactivate()
					return
				end
			end

			local ang = owner:GetAimVector():Angle()
			local bang = self:GetParent():GetAngles() + Angle(0, 180, 0)--Base Angle ;)

			local pang = math.AngleDifference(bang.p, ang.p)
			local yang = math.AngleDifference(bang.y, ang.y)

			if pang > 15 then
				ang.p = (bang - Angle(self.Pang,0,0)).p
			end
			if pang < (0 - 15) then
				ang.p = (bang + Angle(self.Pang,0,0)).p
			end
			if yang > 5 then
				ang.y = (bang - Angle(0,self.Yang,0)).y
			end
			if yang < (0 - 5) then
				ang.y = (bang + Angle(0,self.Yang,0)).y
			end

			self:SetAngles(ang)

			if owner:KeyDown(IN_ATTACK) then
				if self.NextAttack < CurTime() then -- and not self:WaterLevel() == 3
					self.NextAttack = CurTime() + 4
					self:EmitShootEffects()

					local ball = ents.Create("psw_cannonball")
					ball:SetPos((self:GetPos() + self:GetForward() * 100) + Vector(0, 0, 0))
					ball:SetAngles(self:GetAngles())
					ball:SetOwner(owner)
					ball:Spawn()
					ball:Activate()
					ball:GetPhysicsObject():SetVelocity(self:GetForward() * 8000)
				end
			end

			if owner:KeyDown(IN_ATTACK2) then
				owner:SetFOV((ScopeLevel == 0 and 45 or ScopeLevel == 1 and 25 or 0), 0)
				ScopeLevel = ScopeLevel == 0 and 1 or ScopeLevel == 1 and 2 or 0
			end
		end

		if self:GetAngles() ~= self:GetParent():GetAngles() then
		end

		self.LastThink = CurTime()
	end

	function ENT:OnRemove()
		self:Deactivate()
	end
end

if CLIENT then
	function ENT:Initialize()
		self.Color = COLOR_WHITE
	end

	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:EmitShootEffects()
	local effect = EffectData()
	effect:SetOrigin(self:LocalToWorld(Vector(25, -0, 0)))
	effect:SetStart(self:GetForward() * 850 * 1.4)
	util.Effect("cannon_muzzleblast", effect, true, true)

	util.ScreenShake(self:GetPos(), 20, 4, math.Rand(self.SSMin, self.SSMax), 320)
end
