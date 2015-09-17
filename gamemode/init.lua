AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("util.lua")
AddCSLuaFile("helm.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_menus.lua")
AddCSLuaFile("cl_dermaskin.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_hud.lua")

include("shared.lua")
include("util.lua")
include("player.lua")
include("player_ext.lua")
include("helm.lua")
include("damagelog.lua")

include("rtv/sv_rtv.lua")

PSW = {}
ships = false
PirateData = {}
canSpawn = false
exploded = {}
shipdata = {}
shipdata[TEAM_RED] = {}
shipdata[TEAM_RED].name = "Redcoats"
shipdata[TEAM_RED].n = 35
shipdata[TEAM_BLUE] = {}
shipdata[TEAM_BLUE].name = "Pirates"
shipdata[TEAM_BLUE].n = 35
pswThrusters = {}
pswThrusters[1] = {}
pswThrusters[2] = {}
cannonExplosive = nil
mastsBroken = {}
PSW.RoundsDone = 0

TeamLives = {}
TeamLives[TEAM_RED] = 0
TeamLives[TEAM_BLUE] = 0

ROUND_INACTIVE = 0
ROUND_ACTIVE = 1

function GM:Initialize()
	self.round_state = ROUND_INACTIVE
	self.DamageLog = {}
	self.RoundStartTime = 0
	local livesmath = #player.GetAll() * 10
	livesmath = livesmath >= 20 and livesmath or 20
	TeamLives[TEAM_RED] = livesmath
	TeamLives[TEAM_BLUE] = livesmath
	net.Start("PSW_UpdateTeamLives")
		net.WriteUInt(livesmath, 8)
		net.WriteUInt(livesmath, 8)
	net.Broadcast()
end

---------------------------------
--Menu
---------------------------------
function GM:ShowHelp(ply) -- F1
	ply:ConCommand("ShowHelp")
end

function GM:ShowTeam(ply) -- F2
	ply:ConCommand("ChooseTeam")
end

function GM:ShowSpare2(ply) -- F3
end

function GM:ShowSpare2(ply) -- F4
end

---------------------------------
--Main gamemode-related functions
---------------------------------
function GM:EntityKeyValue(ent, key, val)
	--[[if key == "team" then
		ent.team = tonumber(val)
		if string.find(ent:GetClass(), "psw_thruster_") then
			pswThrusters[ent.team][ string.sub(ent:GetClass(), 14) ] = ent
			print(string.sub(ent:GetClass(), 14))
		end
		if ent:GetClass() == "psw_helm" then
			pswThrusters[ent.team]["helm"] = ent
		end
	end]]--

	--[[if key == "force" then
		if ent:GetClass() == "phys_thruster" then

			if string.find(ent:GetName(), "forward") then
				return "600"
			elseif string.find(ent:GetName(), "right") then
				return "200"
			elseif string.find(ent:GetName(), "left") then
				return "200"
			elseif string.find(ent:GetName(), "reverse") then
				return "250"
			end
		end
	end]]--
end

--Spawns ships at map/round start
function GM:Think() --gamerulesThink()
	if not ships then
		spawnships()
		ships = true
	end

	lastthink = CurTime()
end

--SpawnShips
function spawnships()
	for k,v in pairs(ents.FindByName("spawnbutton")) do
		v:Fire("Press", "", 0)
	end

	shipdata[TEAM_RED].sinking = false
	shipdata[TEAM_BLUE].sinking = false
	shipdata[TEAM_RED].disabled = false
	shipdata[TEAM_BLUE].disabled = false
	starting = true

	for k, ply in pairs(player.GetAll()) do
		ply.kd = ply.kd - 1
		ply.kd = ply.kd < 0 and 0 or ply.kd
	end

	timer.Simple(4,getshipparts)
	timer.Simple(30,roundstart)
end

function roundstart()
	starting = false
	GAMEMODE.DamageLog = {}
	GAMEMODE.RoundStartTime = CurTime()
end

function PSW_NewRound()
	PSW.RoundsDone = PSW.RoundsDone + 1
	if PSW.RoundsDone == GetConVarNumber("psw_maxrounds") -1 then
		PrintMessage(HUD_PRINTTALK, "Last round before map restart!")
	end
	if PSW.RoundsDone >= GetConVarNumber("psw_maxrounds") then
		RunConsoleCommand("rtv_start2")
	end
	--team.AddScore(team.GetOpposing(v),30)

	timer.Remove("SinkTimer")
	enableSpawning()

	for k,v in pairs(player.GetAll()) do
		v:ConCommand("r_cleardecals")
		v:SetTeam(v:Team() == TEAM_RED and TEAM_BLUE or TEAM_RED)
	end

	local livesmath = #player.GetAll() * 10
	livesmath = livesmath >= 20 and livesmath or 20
	TeamLives[TEAM_RED] = livesmath
	TeamLives[TEAM_BLUE] = livesmath
	net.Start("PSW_UpdateTeamLives")
		net.WriteTable(TeamLives)
	net.Broadcast()
end

function findpartowner(ent, isstringbool)
	local entstring = isstringbool and ent or ent:GetName()

	if string.find(entstring, "ship1") or string.find(entstring,"s1") then
		return 1
	end
	if string.find(entstring, "ship2") or string.find(entstring,"s2") then
		return 2
	end
end

function getshipparts() --GETS ENTITY ID'S FROM ALL SHIP PARTS AND SET MASSES.
	for v=1, 2 do
		pswThrusters[v] = { ["forward"] = { Ent = ents.FindByName("ship"..v.."_thruster_forward")[1],
											On = false},
							["reverse"] = { Ent = ents.FindByName("ship"..v.."_thruster_reverse")[1],
											On = false},
							["left"]    = { Ent = ents.FindByName("ship"..v.."_thruster_left")[1],
											On = false},
							["right"]   = { Ent = ents.FindByName("ship"..v.."_thruster_right")[1],
											On = false},
											}
		shipdata[v][3] = ents.GetByName("ship" .. v .. "keelbottom1")
		shipdata[v][4] = ents.GetByName("ship" .. v .. "keelbottom2")
		shipdata[v][5] = ents.GetByName("ship" .. v .. "keelbottom3")
		shipdata[v][6] = ents.GetByName("ship" .. v .. "keelbottom4")
		shipdata[v][8] = ents.GetByName("ship" .. v .. "keelbottom5")
		shipdata[v][9] = ents.GetByName("ship" .. v .. "keel2")
		shipdata[v][11] = ents.GetByName("ship" .. v .. "sinker")

		shipdata[v][16] = ents.GetByName("ship" .. v .. "door")
		shipdata[v][17] = ents.GetByName("ship" .. v .. "explosive")
		shipdata[v][18] = ents.GetByName("ship" .. v .. "keel")

		shipdata[v][3]:EnableDrag(false)
		shipdata[v][4]:EnableDrag(false)
		shipdata[v][5]:EnableDrag(false)
		shipdata[v][6]:EnableDrag(false)
		shipdata[v][8]:EnableDrag(false)
		shipdata[v][9]:EnableDrag(false)
		shipdata[v][11]:EnableDrag(false)

		shipdata[v][16]:EnableDrag(false)
		--shipdata[v][17]:EnableDrag(false)
		shipdata[v][18]:EnableDrag(false)

		shipdata[v][3]:SetMass(40000)
		shipdata[v][4]:SetMass(40000)
		shipdata[v][5]:SetMass(40000)
		shipdata[v][6]:SetMass(40000)
		shipdata[v][8]:SetMass(35000)
		mastsBroken["ship" .. v .. "mast1"] = false
		mastsBroken["ship" .. v .. "mast2"] = false
		mastsBroken["ship" .. v .. "mast3"] = false

		if GetConVarNumber("psw_noDoors") >= 1 then
			ents.GetByName("ship" .. v .. "door", true):Remove()
			--ents.GetByName("ship" .. v .. "barrelexplode", true):Remove()
			ents.GetByName("ship" .. v .. "explosive", true):Remove()
			--ents.GetByName("s" .. v .. "smoke", true):Remove()
		end
	end
end

function sink(v) --Sink function, called when a piece of a ship breaks
	if not shipdata[v].sinking then
		if shipdata[v][8] ~= nil and shipdata[v][8]:GetMass() > 9000 then
			shipdata[v][8]:SetMass(shipdata[v][8]:GetMass()-1000)
			if shipdata[v][11]:GetMass() < 40000 then
				shipdata[v][11]:SetMass(shipdata[v][11]:GetMass()+2000)
			end
		end
		if shipdata[v][3] ~= nil and shipdata[v][3]:GetMass() > 2000 then
			shipdata[v][3]:SetMass(shipdata[v][3]:GetMass()-1000)
			shipdata[v][4]:SetMass(shipdata[v][4]:GetMass()-1000)
			shipdata[v][5]:SetMass(shipdata[v][5]:GetMass()-1000)
			shipdata[v][6]:SetMass(shipdata[v][6]:GetMass()-1000)
		else
			if shipdata[v][3] ~= nil and shipdata[v][3]:GetMass() > 14000 then
				shipdata[v][8]:SetMass(1000)
				shipdata[v][9]:SetMass(25000)
				shipdata[v][3]:SetMass(shipdata[v][3]:GetMass() - 1000)
				shipdata[v][4]:SetMass(shipdata[v][4]:GetMass() - 1000)
				shipdata[v][5]:SetMass(1000)
				shipdata[v][6]:SetMass(1000)
				shipdata[v][11]:SetMass(15000)
			else
				if not shipdata[team.GetOpposing(v)].sinking then
					shipdata[v].n = 35
					shipdata[v].sinking = true
					winner(team.GetOpposing(v))
				end
			end
		end
	end
end

function CountDown(v)
	if shipdata[v].n == 30 then
		canSpawn=false
	end
	--[[if shipdata[v].n == 7 and shipdata[v].sinking then
		for k,v in pairs(player.GetAll()) do
			v:StripWeapons()
			v:Spectate(OBS_MODE_ROAMING)
		end
	end
	if shipdata[v].n == 5 and shipdata[v].sinking then
		spawnships()
	end
	if shipdata[v].n == 1 then
		PSW_NewRound()
	end]]--

	shipdata[v].n = shipdata[v].n - 1

	if shipdata[v].sinking then
		if shipdata[v][3]:GetMass() > 400 then
			shipdata[v][3]:SetMass(shipdata[v][3]:GetMass() - 200)
			shipdata[v][4]:SetMass(shipdata[v][4]:GetMass() - 200)
		end

		shipdata[v][8]:SetMass(1000)

		if shipdata[v][11]:GetMass() <= 40000 then
			shipdata[v][5]:SetMass(500)
			shipdata[v][6]:SetMass(500)
			shipdata[v][11]:SetMass(shipdata[v][11]:GetMass() + 1000)
		end

		if shipdata[v][11]:GetMass() > 40000 then
			shipdata[v][5]:SetMass(1000)
			shipdata[v][6]:SetMass(1000)
			if shipdata[v][9]:GetMass() > 2000 then
				shipdata[v][9]:SetMass(shipdata[v][9]:GetMass()-1000)
			end
		elseif shipdata[v][11]:GetMass() > 49000 then
			shipdata[v][10]:SetMass(35000)
			shipdata[v][9]:SetMass(2000)
			shipdata[v][3]:SetMass(1000)
			shipdata[v][4]:SetMass(1000)
		end
	end
end

function GM:EntityTakeDamage(target, dmginfo)
	local caller = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if target:IsPlayer() then return false end

	local ent = target:GetPhysicsObject()
	owner = findpartowner(target)

	if caller:GetClass() == "psw_ballbearing" then
		if target:IsPlayer() then
			dmginfo:ScaleDamage(2)
			dmginfo:SetAttacker(caller:GetOwner())
			attacker = caller:GetOwner()
			return dmginfo
		else
			dmginfo:ScaleDamage(0)
			return dmginfo
		end
	end

	if attacker:IsPlayer() and string.find(target:GetName(), "ship") then
		if attacker:Team() == TEAM_RED and string.find(target:GetName(), "ship1") then return false end
		if attacker:Team() == TEAM_BLUE and string.find(target:GetName(), "ship2") then return false end
		if target:GetClass() ~= "prop_physics_multiplayer" and target:GetClass() ~= "func_breakable" then
			return false
		end
		if starting then
			return false
		end
	end

	if owner then
		if target:GetName() == "ship" .. owner .. "mast1" then
			if (caller:GetClass() == "func_physbox") or (caller:GetClass() == "func_breakable") or (caller:GetClass() == "psw_cannonball") and ents.FindByName("ship" .. owner .. "weldmast1")[1] then
				if ents.FindByName("ship" .. owner .. "weldmast1")[1] then
				   ents.FindByName("ship" .. owner .. "weldmast1")[1]:Fire("Break", "", 1)
				end
			end
		end
		if target:GetName() == "ship" .. owner .. "mast2" then
			if (caller:GetClass() == "func_physbox") or (caller:GetClass() == "func_breakable") or (caller:GetClass() == "psw_cannonball")and ents.FindByName("ship" .. owner .. "weldmast2")[1] then
				if ents.FindByName("ship" .. owner .. "weldmast2")[1] then
				   ents.FindByName("ship" .. owner .. "weldmast2")[1]:Fire("Break", "", 1)
				end
			end
		end

		if target:GetName() == "ship" .. owner .. "mast3" then
			if (caller:GetClass() == "func_physbox") or (caller:GetClass() == "func_breakable") or (caller:GetClass() == "psw_cannonball") and ents.FindByName("ship" .. owner .. "weldmast3")[1] then
				if ents.FindByName("ship" .. owner .. "weldmast3")[1] then
				   ents.FindByName("ship" .. owner .. "weldmast3")[1]:Fire("Break", "", 1)
				end
			end
		end

		if string.find(target:GetName(), "ship") then
			if ent and ent:GetMass()>amount+5000 then
				ent:SetMass(ent:GetMass()-amount)
			else
				ent:SetMass(5000)
			end
		end

		if caller:GetClass() == "psw_cannonball" then
			if caller:GetOwner():IsPlayer() then
				if owner == caller:GetOwner():Team() then
					dmginfo:ScaleDamage(0)
					return dmginfo
				end
			end
		else
			dmginfo:ScaleDamage(0)
			return dmginfo
		end
	end

	if string.find(target:GetName(), "ship") then
		if ent and ent:GetMass()>amount+5000 then
			ent:SetMass(ent:GetMass()-amount)
		else
			ent:SetMass(5000)
		end
		sink(owner)
	end
end

--Anounce winner
function winner(t)
	GAMEMODE.round_state = ROUND_INACTIVE
	local winner

	if shipdata[1].sinking == true then
		winner = TEAM_BLUE
		PrintMessage(HUD_PRINTCENTER, "The Pirates Win!")
	end

	if shipdata[2].sinking == true then
		winner = TEAM_RED
		PrintMessage(HUD_PRINTCENTER, "The Redcoats Win!")
	end

	net.Start("PSW_Winner")
		net.WriteInt(winner, 4)
	net.Broadcast()
	hook.Run("PSW_EndRound")

	if shipdata[1].sinking == true or shipdata[2].sinking == true then -- If the team wins by sinking the ship
		for k,v in pairs(player.GetAll()) do
			v:ConCommand("endroundmusic")
		end

		sinktimer = timer.Create("SinkTimer", 1, shipdata[t].n, function() CountDown(t) end) -- timer.Simple(n1, CountDown)

		-- sets all players to spectate after 20 seconds of the ship sinking
		kill = timer.Create("PSW_EndRoundKill", 20, 1, function()
			for k,v in pairs(player.GetAll()) do
				timer.Simple(0.1, function()
					v:StripWeapons()
					v:Spectate(OBS_MODE_ROAMING)
				end)
			end
		end)

		-- Spawn the ships and new round after 25 seconds
		NewRoundAndSpawn = timer.Create("PSW_NewRoundAndSpawn", 25, 1, function()
			PSW_NewRound()
			timer.Simple(0.1, function()
				spawnships()
			end)
		end)
	end
end

function GM:FixTeleportAngles() -- Fix the spawnpoint so that we don't spawn with a tilted view!
	for i = 1, 2 do
		local ent = ents.FindByName("ship" .. i .. "playerdestination*")

		for _, v in pairs(ent) do
			local a = v:GetAngles()
			v:SetAngles(Angle(0, a.y, 0))
		end
	end
end

---------------------------------
--Server Commands
---------------------------------
util.AddNetworkString("MaxRounds")
util.AddNetworkString("NoDoors")
util.AddNetworkString("friendlyfire")
util.AddNetworkString("nowaterdamage")
util.AddNetworkString("PSW_Winner")
util.AddNetworkString("PSW_PlayerKilledSelf")
util.AddNetworkString("PSW_PlayerKilledByPlayer")
util.AddNetworkString("PSW_PlayerKilled")
util.AddNetworkString("PSW_ChangeTeam")
util.AddNetworkString("firstperson")
util.AddNetworkString("thirdperson")
util.AddNetworkString("PSW_UpdateTeamLives")

net.Receive("MaxRounds", function(len,ply)
	if ply:IsSuperAdmin() then
		local nrf = net.ReadFloat()
		local rnrf = (math.Round(nrf))
		RunConsoleCommand("psw_maxrounds",rnrf)
	end
end)

net.Receive("NoDoors", function(len,ply)
	if ply:IsSuperAdmin() then
		local nrf = net.ReadFloat()
		local rnrf = (math.Round(nrf))
		RunConsoleCommand("psw_nodoors",rnrf)
	end
end)

net.Receive("friendlyfire", function(len,ply)
	if ply:IsSuperAdmin() then
		local nrf = net.ReadFloat()
		local rnrf = (math.Round(nrf))
		RunConsoleCommand("psw_friendlyfire",rnrf)
	end
end)

net.Receive("nowaterdamage", function(len,ply)
	if ply:IsSuperAdmin() then
		local nrf = net.ReadFloat()
		local rnrf = (math.Round(nrf))
		RunConsoleCommand("psw_nowaterdamage",rnrf)
	end
end)

net.Receive("PSW_ChangeTeam", function(len, ply)
	local chosenteam = net.ReadInt(4)
	ply:PSW_ChangeTeam(chosenteam)
end)

--Chat Commands
hook.Add("PlayerSay", "thirdperson", function(ply, text)
	if string.sub(text, 1, 12) == "!thirdperson" then
		net.Start("thirdperson")
		net.Send(ply)
		function SODVM()
			self.Owner:DrawViewModel(false)
		end
	end
end)

hook.Add("PlayerSay", "firstperson", function(ply, text)
	if string.sub(text, 1, 12) == "!firstperson" then
		net.Start("firstperson")
		net.Send(ply)
		function SODVM()
			self.Owner:DrawViewModel(true)
		end
	end
end)