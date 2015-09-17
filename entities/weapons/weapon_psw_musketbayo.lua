SWEP.Base = "weapon_pswgunbase"

if CLIENT then
	SWEP.PrintName		= "Musket"
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.DrawCrosshair	= true

	killicon.Add("weapon_psw_musketbayo", "hud/musket", color_white)
	SWEP.WepSelectIcon		= surface.GetTextureID("hud/musket")
	SWEP.BounceWeaponIcon	= false
	SWEP.DrawWeaponInfoBox	= false
end

SWEP.Damage		= 100
SWEP.Delay		= 0.5
SWEP.Recoil		= 0.5
SWEP.RecoilMax	= -20

SWEP.ShootSound		= "weapons/rifle/ssrifle_fire1.wav"
SWEP.ReloadSound	= "weapons/musket/reload3.wav"
--SWEP.ReloadSound	= "weapons/rifle/ssrifle_reload.wav"
SWEP.DeploySound	= "weapons/rifle/ssrifle_draw.wav"
SWEP.HolsterSound	= "weapons/rifle/ssrifle_holster.wav"

SWEP.HoldType		= "crossbow"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 56
SWEP.ViewModel		= "models/weapons/pirate/c_musket.mdl"
SWEP.WorldModel		= "models/weapons/pirate/w_musket.mdl"

SWEP.AutoSwitchTo	= true

SWEP.Secondary.Delay	= 2
SWEP.Secondary.Damage	= 40

SWEP.HasBayonet = true

function SWEP:SecondaryAttack()
	local trace = self.Owner:GetEyeTrace()
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		if trace.Hit then
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
				bloody = true
			end
			self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(3,5)..".wav")
			bullet = {}
			bullet.Num		= 1
			bullet.Src		= self.Owner:GetShootPos()
			bullet.Dir		= self.Owner:GetAimVector()
			bullet.Spread	= Vector(0, 0, 0)
			bullet.Tracer	= 0
			bullet.Force	= 5
			bullet.Damage	= self.Secondary.Damage
			self.Owner:FireBullets(bullet)
			self.Owner:SetAnimation(ACT_VM_SECONDARYATTACK)
			self.Weapon:SetNextSecondaryFire(CurTime() + 1)
		else
			self.Weapon:EmitSound(self.WallSound)
			self.Owner:SetAnimation(ACT_VM_SECONDARYATTACK)
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		end
	else
		self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.Owner:SetAnimation(ACT_VM_SECONDARYATTACK)
	end
	timer.Simple(0.05, function()
		if not IsValid(self.Owner) then return end
		self.Owner:ViewPunch(Angle(0, 7, 0))
	end)

	timer.Simple(0.2, function()
		if not IsValid(self.Owner) then return end
		self.Owner:ViewPunch(Angle(2, -4, 0))
	end)
end