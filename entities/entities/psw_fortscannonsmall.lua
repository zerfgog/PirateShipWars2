AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "psw_basecannon"
ENT.PrintName	= "Forts Cannon Only Small"
ENT.Author		= "Thomas Hansen"
ENT.Category	= "Pirate Ship Wars 2"
ENT.Spawnable	= false

ENT.NextAttack	= CurTime()
ENT.NextUse		= CurTime()
ENT.LastThink	= CurTime()

ENT.SSMin = 0.3
ENT.SSMax = 0.6

ENT.Model = "models/frigate01/cannon/cannonsmall.mdl"

ENT.Pang = 15
ENT.Yang = 15

if CLIENT then
	killicon.Add("psw_fortscannonsmall", "killicons/sent_cball_killicon", COLOR_WHITE)
end
