SWEP.Base = "weapon_pswgunbase"

if CLIENT then
	SWEP.PrintName		= "Pistol"
	SWEP.Slot			= 1
	SWEP.SlotPos		= 0
	SWEP.DrawCrosshair	= true

	killicon.Add("weapon_psw_pistol", "hud/pistol", color_white)
	SWEP.WepSelectIcon		= surface.GetTextureID("hud/pistol")
	SWEP.BounceWeaponIcon	= false
	SWEP.DrawWeaponInfoBox	= false
end

SWEP.Damage		= 50
SWEP.Delay		= 1
SWEP.Recoil		= 0.5
SWEP.RecoilMax	= -10

SWEP.ShootSound		= "weapons/pistolshot.wav"
SWEP.ReloadSound	= "weapons/pistolreload.wav"
SWEP.DeploySound	= "weapons/flcock_draw.wav"
SWEP.HolsterSound	= "weapons/flcock_draw.wav"

SWEP.HoldType		= "pistol"
SWEP.UseHands		= true
SWEP.ViewModel		= "models/weapons/pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol/w_pistol.mdl"

SWEP.IronSightsPos = Vector (-8.5, 6, 1.5)
SWEP.IronSightsAng = Vector (-2, -11.8, -3)

SWEP.AutoSwitchTo = true
