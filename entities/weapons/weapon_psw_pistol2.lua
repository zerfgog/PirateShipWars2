SWEP.Base = "weapon_pswgunbase"

if CLIENT then
	SWEP.PrintName		= "SS Pistol"
	SWEP.Slot			= 1
	SWEP.SlotPos		= 0
	SWEP.DrawCrosshair	= true

	killicon.Add("weapon_psw_pistol2", "hud/sspistol", color_white)
	SWEP.WepSelectIcon		= surface.GetTextureID("hud/sspistol")
	SWEP.BounceWeaponIcon	= false
	SWEP.DrawWeaponInfoBox	= false
end

SWEP.Damage		= 50
SWEP.Delay		= 1
SWEP.Recoil		= 0.5
SWEP.RecoilMax	= -10

SWEP.ShootSound		= "weapons/pistolshot.wav"
--SWEP.ReloadSound	= "weapons/cockpistol.wav"
SWEP.ReloadSound	= "weapons/pistolreload.wav"
SWEP.DeploySound	= "weapons/flcock_draw.wav"
SWEP.HolsterSound	= "weapons/flcock_draw.wav"

SWEP.HoldType		= "pistol"
SWEP.UseHands		= true
SWEP.ViewModel		= "models/weapons/sspistol.mdl"
SWEP.WorldModel		= "models/weapons/w_sspistol/w_sspistol.mdl"

SWEP.IronSightsPos = Vector (-4.18, 8, -1)
SWEP.IronSightsAng = Vector (3, -0.45, 0)

SWEP.AutoSwitchTo	= true
