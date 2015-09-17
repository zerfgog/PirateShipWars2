SWEP.Category			= "Pirate Ship Wars 2"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.HoldType			= "pistol"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip		= false

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.UseHands = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ShootSound		= Sound("")
SWEP.ReloadSound	= Sound("")
SWEP.DeploySound	= Sound("")
SWEP.HolsterSound	= Sound("")
SWEP.EmptySound		= Sound("Weapon_Pistol.Empty")

SWEP.HasBayonet = false

SWEP.Damage		= 100
SWEP.Delay		= 0.5
SWEP.Recoil		= 0.5
SWEP.RecoilMax	= -20

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:SetBayonet(bBayo)
	if not self.HasBayonet then return end
	if not (IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) and IsValid(self.Owner:GetActiveWeapon())) then return end

	local num = (bBayo == true) and 1 or 0

	self.Owner:GetViewModel():SetBodygroup(1, num)
	self.Owner:GetActiveWeapon():SetBodygroup(1, num)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:EmitSound(self.ShootSound)
	local rnda = self.Recoil * self.RecoilMax
	local rndb = self.Recoil * math.random(self.RecoilMax, self.RecoilMax * -1)
	self.Owner:ViewPunch(Angle(rnda,rndb,rnda))

 	if SERVER then
		local ball = ents.Create("psw_ballbearing")
		ball.DamageDealt = self.Damage
		ball:SetPos(self.Owner:GetShootPos())
		ball:SetAngles(self.Owner:GetAngles())
		ball:SetOwner(self.Owner)
		ball:Spawn()
		ball:Activate()
		ball:GetPhysicsObject():SetVelocity(self:GetForward() * 14000)
	end

	self:ShootEffects()
	self:TakePrimaryAmmo(1)
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound(self.EmptySound)
		self:Reload()
		return false
	end

	if self.Owner:WaterLevel() > 1 and not self.FiresUnderwater then
		self:EmitSound(self.EmptySound)
		return false
	end

	return true
end

SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
	if not self.IronSightsPos then return end
	if self.NextSecondaryAttack > CurTime() then return end

	self:SetIronSights(not (self:GetIronSights()))

	self.NextSecondaryAttack = CurTime() + IRONSIGHT_TIME + 0.5
end

function SWEP:Reload()
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end

	if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self:SetIronSights(false)
		self:DefaultReload(ACT_VM_RELOAD)
		self:EmitSound(self.ReloadSound)
		local animtime = self.Owner:GetViewModel():SequenceDuration()
		self.ReloadingTime = CurTime() + animtime
		self:SetNextPrimaryFire(CurTime() + animtime)
		self:SetNextSecondaryFire(CurTime() + animtime)
	end
end

function SWEP:Deploy()
	self:SetBayonet(self.HasBayonet)
	self:SetIronSights(false)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:EmitSound(self.DeploySound)
	self.Owner:ViewPunch(Angle(1, 0, -1))
	return true
end

function SWEP:Holster()
	self:EmitSound(self.HolsterSound)
	return true
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:SetIronSights(b)
	local fov = (b) and 35 or 0

	self.Owner:SetFOV(fov, 0.4)

	self:SetNWBool("IronSights", b)
end

function SWEP:GetIronSights()
	return (self:GetNWBool("IronSights", false))
end

local IRONSIGHT_TIME = 0.25
function SWEP:GetViewModelPosition(pos, ang)
	if not self.IronSightsPos then return pos, ang end

	local bIron = self:GetIronSights()

	if bIron ~= self.LastIron then
		self.LastIron = bIron
		self.IronTime = CurTime()

		self.SwayScale	= bIron and 0.3 or 1.0
		self.BobScale	= bIron and 0.1 or 1.0
	end

	local IronTime = self.IronTime or 0

	if (not bIron) and (IronTime < (CurTime() - IRONSIGHT_TIME)) then
		return pos, ang
	end

	local mul = 1.0

	if IronTime > CurTime() - IRONSIGHT_TIME then
		mul = math.Clamp((CurTime() - IronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then mul = 1 - mul end
	end

	local offset = self.IronSightsPos

	if self.IronSightsAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(),	self.IronSightsAng.x * mul)
		ang:RotateAroundAxis(ang:Up(),		self.IronSightsAng.y * mul)
		ang:RotateAroundAxis(ang:Forward(),	self.IronSightsAng.z * mul)
	end

	pos = pos + offset.x * ang:Right()   * mul
	pos = pos + offset.y * ang:Forward() * mul
	pos = pos + offset.z * ang:Up()      * mul

	return pos, ang
end

function SWEP:ShootEffects()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local effectdata = EffectData()
	effectdata:SetOrigin(self.Owner:GetShootPos())
	effectdata:SetEntity(self)
	effectdata:SetStart(self.Owner:GetShootPos())
	effectdata:SetNormal(self.Owner:GetAimVector())
	effectdata:SetAttachment(1)
	util.Effect("muzzleblast", effectdata)
end
