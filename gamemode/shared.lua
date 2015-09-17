DeriveGamemode("base")

GM.Name		= "Pirate Ship Wars 2"
GM.Author	= "Thomas Hansen"
GM.Email	= ""
GM.Website	= ""

--Team setup
TEAM_RED		= 1
TEAM_BLUE		= 2
TEAM_JOINING	= 3
TEAM_SPECTATE	= 4

team.SetUp(TEAM_RED, "Redcoats", Color(240,40,40,255))
team.SetUp(TEAM_BLUE, "Pirates", Color(40,40,240,255))
team.SetUp(TEAM_JOINING, "Joining", Color(75,75,75,100))
team.SetUp(TEAM_SPECTATE, "Spectating", Color(50,50,50,255))

team.SetSpawnPoint(TEAM_RED, {"psw_redspawn"})
team.SetSpawnPoint(TEAM_BLUE, {"psw_bluespawn"})
team.SetSpawnPoint(TEAM_SPECTATE, {"psw_bluespawn", "psw_redspawn"})

player_manager.AddValidModel("redcoat", "models/player/redcoat.mdl")
player_manager.AddValidHands("redcoat", "models/weapons/c_arms_citizen.mdl", 1, "00000000")

player_manager.AddValidModel("jsparrow", "models/player/jack_sparrow.mdl")
player_manager.AddValidHands("jsparrow", "models/player/jack_sparrow.mdl", 1, "00000000")

resource.AddFile("resource/akbar.ttf")

CreateConVar("psw_nodoors",1,{FCVAR_REPLICATED,FCVAR_ARCHIVE},"Removes Ships Explosive Barrel")
CreateConVar("psw_friendlyfire",1,{FCVAR_REPLICATED,FCVAR_ARCHIVE},"Toggle Friendly Fire")
CreateConVar("psw_nowaterdamage",1,{FCVAR_REPLICATED,FCVAR_ARCHIVE},"Disable Water Damage")
CreateConVar("psw_maxrounds",4,{FCVAR_REPLICATED,FCVAR_ARCHIVE},"Rounds per map")

COLOR_BLACK = Color(0, 0, 0)
COLOR_WHITE = Color(255, 255, 255)

GM.HELP = [[
In this gamemode there are 2 teams, Pirates and Redcoats. The Objective of this Gamemode is
to sink the Enemy ship or to board them and kill its crew.

Menus:
F1 - Main Menu
F2 - Change Teams
F3 - Client and Admin options

Chat Commands:
!rtv - Vote for the next map
!firstperson- Change to First Person View, this can also be toggled in the F2 menu
!thirdperson - Change to Third Person View, this can also be toggled in the F2 menu
!kill - Suicide, useful when stuck.
]]

GM.Credits = [[
Garry's Mod 13 - Pirate Ship Wars 2.0
	Thomas 'g\mail termy58' Hansen
	CaptainShaun
	Zerf
	Disseminate
	Professor Heavy - Redcoat model
	Voikanaa - Jack Sparrow model

Garry's Mod 10 - Pirate Ship Wars
	EmpV
	Metroid48
	Thomas 'g\mail termy58' Hansen

Gmod 9 Original - Pirate Ship Wars
	EmpV

Also thanks to the artists who have contributed various weapon models
]]

GM.Rules = [[
1. Don't be a jerk.
2. Don't excessively teamkill.
3. Don't spawncamp.

Possible punishment includes kicking and banning.
]]

local META_ENTITY = META_ENTITY or meta_entity or FindMetaTable("Entity")
function META_ENTITY:GetMass()
	local p = self:GetPhysicsObject()

	if IsValid(p) then
		return p:GetMass()
	end

	return 0
end

function META_ENTITY:SetMass(i)
	i = (i and i < 5) and i or 5

	local p = self:GetPhysicsObject()

	if IsValid(p) then
		p:SetMass(i)
	end
end

local META_PLAYER = FindMetaTable("Player")
function META_PLAYER:CanChangeTeam(t)
	if self:Team() ~= t and team.NumPlayers(t) + 1 <= team.NumPlayers(self:Team()) then
		return true
	end

	return false
end

function GM:GetMapList()
	local f, d = file.Find("maps/psw*.bsp", "GAME")

	for k, v in pairs(f) do
		f[k] = string.sub(v, 1, -5) -- remove .bsp
	end

	return f
end

function GM:ShouldCollide(a, b)
	if self.PlayersNoCollide and a:IsPlayer() and b:IsPlayer() then return false end
	return self.BaseClass:ShouldCollide(a, b)
end

function GM:OpposingTeam(t)
	return t == TEAM_RED and TEAM_BLUE or TEAM_RED
end

if file.Exists(GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua") then
	for _, v in pairs(files) do
		if SERVER then AddCSLuaFile("maps/" .. v) end
		include("maps/" .. v)
	end

	MsgC(Color(200, 200, 200, 255), "Loaded map lua file for " .. game.GetMap() .. ".\n")
end
