AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "psw_basecannon"
ENT.PrintName	= "Forts Cannon Only"
ENT.Author		= "Thomas Hansen"
ENT.Category	= "Pirate Ship Wars 2"
ENT.Spawnable	= false

ENT.NextAttack	= CurTime()
ENT.NextUse		= CurTime()
ENT.LastThink	= CurTime()

ENT.SSMin = 0.5
ENT.SSMax = 0.8

ENT.Model = "models/frigate01/cannon/cannon.mdl"

ENT.Pang = 15
ENT.Yang = 15

if CLIENT then
	killicon.Add("psw_fortscannon", "killicons/sent_cball_killicon", COLOR_WHITE)
end
