SWEP.Base = "weapon_pswmeleebase"

if CLIENT then
	SWEP.PrintName		= "Sabre"

	killicon.Add("weapon_psw_sabre", "deathnotify/sabre_kill", Color(255,255,255,255))
	SWEP.WepSelectIcon		= surface.GetTextureID("hud/cutlass")
end

SWEP.Primary.Damage		= 45
SWEP.Primary.Delay		= 0.5

SWEP.DrawSound		= "sabre/draw.wav"
SWEP.HolsterSound	= "sabre/holster.wav"
SWEP.HitSounds		= {"sabre/hitwall.wav", "sabre/hitwall2.wav"}
SWEP.SwingSound		= "sabre/swing.wav"

SWEP.UseHands			= true
SWEP.ViewModelFOV		= 55
SWEP.ViewModel			= "models/weapons/pirate/c_sabre.mdl"
SWEP.WorldModel			= "models/weapons/pirate/w_sabre.mdl"
