if CLIENT then
	SWEP.Author			= "PSW GM9 / Metroid48 / Termy58/ / Buzzofwar"
	SWEP.Slot			= 0
	SWEP.SlotPos		= 0
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= true
	SWEP.BounceWeaponIcon	= false
	SWEP.DrawWeaponInfoBox	= false
end

SWEP.Category		= "Pirate Ship Wars 2"
SWEP.Spawnable		= true
SWEP.AdminOnly		= false
SWEP.HoldType		= "melee"
SWEP.Weight			= 0
SWEP.AutoSwitchTo	= true
SWEP.AutoSwitchFrom	= true
SWEP.ViewModelFlip	= false
SWEP.UseHands = true

SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Spread		= 0
SWEP.Primary.NumShots	= 1
SWEP.Primary.Recoil		= 0
SWEP.Primary.ClipSize	= 0
SWEP.Primary.Delay		= 1
SWEP.Primary.Force		= 5
SWEP.Primary.MaxDist	= 75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:EmitSound(self.DrawSound)
end

function SWEP:Holster()
	self:SendWeaponAnim(ACT_VM_HOLSTER)
	self:EmitSound(self.HolsterSound)
	return true
end

function SWEP:Reload()
	return false
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local trace = self.Owner:GetEyeTrace()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= self.Primary.MaxDist then
		if trace.Hit then
			math.randomseed(os.time())
			self:EmitSound(table.Random(self.HitSounds))
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = self.Primary.Force
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		else
			self:EmitSound(table.Random(self.HitSounds))
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		end
	else
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		self:EmitSound(self.SwingSound)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:OnDrop()
	self:Remove()
end
