AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "psw_basecannon"
ENT.PrintName	= "Ships Cannon Only"
ENT.Author		= "Thomas Hansen"
ENT.Category	= "Pirate Ship Wars 2"
ENT.Spawnable	= false

ENT.NextAttack	= CurTime()
ENT.NextUse		= CurTime()
ENT.LastThink	= CurTime()

ENT.SSMin = 0.4
ENT.SSMax = 0.8

ENT.Model = "models/frigate01/cannon/cannon.mdl"
