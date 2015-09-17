SWEP.Base = "weapon_pswgunbase"

if CLIENT then
	SWEP.PrintName		= "Musket"
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.DrawCrosshair	= true

	killicon.Add("weapon_psw_musket", "hud/musket", color_white)
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

SWEP.IronSightsPos = Vector(-7.6, 7, 6)
SWEP.IronSightsAng = Vector(0, 0.1, 0)

SWEP.AutoSwitchTo	= true
