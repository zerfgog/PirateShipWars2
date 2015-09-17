function GM:PlayerDeath(victim, inflictor, attacker)
	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a
	-- pistol but kill you by hitting you with their arm.
	if not attacker:IsPlayer() and attacker:GetOwner() then
		if IsValid(attacker:GetOwner()) then
			if attacker:GetOwner():IsPlayer() then
				attacker = attacker:GetOwner()
			end
		end
	end

	if inflictor and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()
		if not inflictor then inflictor = attacker end
	end

	victim.NextSpawnTime = CurTime() + 4

	if attacker == victim then
		hook.Run("PSW_PlayerKilledSelf", victim)
		net.Start("PSW_PlayerKilledSelf")
			net.WriteEntity(victim)
		net.Broadcast()
		MsgAll(attacker:Nick() .. " took their own life!\n")
		return
	end

	if TeamLives[victim:Team()] > 0 and not (GAMEMODE.round_state == ROUND_INACTIVE) then
		TeamLives[victim:Team()] = TeamLives[victim:Team()] - 1
		net.Start("PSW_UpdateTeamLives")
			net.WriteTable(TeamLives)
		net.Broadcast()
		if TeamLives[victim:Team()] == 0 then
			shipdata[victim:Team()].sinking = true
			winner(team.GetOpposing(victim:Team()))
		end
	end

	if attacker:IsPlayer() then
		print(inflictor)
		local wep = inflictor and inflictor:GetClass() or ""
		hook.Run("PSW_PlayerKilledByPlayer", victim, wep, attacker)
		net.Start("PSW_PlayerKilledByPlayer")
			net.WriteEntity(victim)
			net.WriteString(wep)
			net.WriteEntity(attacker)
		net.Broadcast()
		MsgAll( attacker:Nick() .. " killed " .. victim:Nick() .. " using " .. inflictor:GetClass() .. "\n" )
		return
	end

	hook.Run("PSW_PlayerKilled", victim, inflictor:GetClass(), attacker:GetClass())
	net.Start("PSW_PlayerKilled")
		net.WriteEntity(victim)
		net.WriteString(inflictor:GetClass())
		net.WriteString(attacker:GetClass())
	net.Broadcast()

	MsgAll(victim:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
end

function GM:PlayerDeathSound()
	return true
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:CreateRagdoll()
	ply:AddDeaths(1)

	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		DamageLog(Format("KILL:\t %s [%s] killed %s [%s]", attacker:Nick(), team.GetName(attacker:Team()), ply:Nick(), team.GetName(ply:Team())))
	else
		DamageLog(Format("KILL:\t <something/world> killed %s [%s]", ply:Nick(), team.GetName(ply:Team())))
	end
end

---------------------------------
--Spawning Functions
---------------------------------
function enableSpawning()
	GAMEMODE.round_state = ROUND_ACTIVE
	for k,v in pairs(player.GetAll()) do
		v.canSpawn = true
		v:KillSilent()
	end
end
timer.Simple(5, enableSpawning)

local function chooseteam(ply, initial)
	if ply.spectating then return end
	local blu = team.NumPlayers(TEAM_BLUE)
	local red = team.NumPlayers(TEAM_RED)
	local plteam = ply:Team()

	if initial and plteam == TEAM_SPECTATE then
		if bb == rr then
			ply:SetTeam(math.random(TEAM_RED, TEAM_BLUE))
		elseif bb > rr then
			ply:SetTeam(TEAM_RED)
		else
			ply:SetTeam(TEAM_BLUE)
		end
	else -- autobalance
		if blu > (red + 1) and plteam ~= TEAM_RED then
			ply:SetTeam(TEAM_RED)
		elseif (red > blu + 1) and plteam ~= TEAM_BLUE then
			ply:SetTeam(TEAM_BLUE)
		end
	end
end

function PSW_CheckTeam(chosenteam)
	local opposing = chosenteam == TEAM_RED and TEAM_BLUE or TEAM_RED
	return (team.NumPlayers(chosenteam) < team.NumPlayers(opposing)) -- If the chosen team has 1 fewer player than opposing team
end

function GM:PlayerInitialSpawn(ply)
	if GAMEMODE.round_state == ROUND_ACTIVE then
		ply.canSpawn = true
	end

	ply:PrintMessage(HUD_PRINTTALK, "Change Team? Press F2")
	ply:SetTeam(TEAM_SPECTATE)
	ply:SetNoCollideWithTeammates(true)
	ply:SetCustomCollisionCheck(true)
	ply:SetCanZoom(false)

	chooseteam(ply, true)

	ply.temp		= 98.6
	ply.heal		= false
	ply.lastpos		= nil
	ply.kd			= 0
	ply.lastspawn	= nil
	ply.parented	= false
	ply.UsingCannon	= 0
	ply:Freeze(true)
end

function GM:PlayerSpawn(ply)
	if GAMEMODE.round_state == ROUND_ACTIVE then
		ply:UnSpectate()
		ply:Freeze(false)
		ply:GodDisable(false)
		ply:SprintDisable()
		ply.temp = 98.6
		pang = ply:GetAngles()
		ply:SetAngles(Angle(0, pang.y, 0))
		GAMEMODE:PlayerLoadout(ply)
		GAMEMODE:PlayerSetModel(ply)
		ply:SetupHands()
		GAMEMODE:SetPlayerSpeed(ply, 250, 300)
		if ply:Team() == TEAM_SPECTATE then
			ply:Spectate(OBS_MODE_ROAMING)
			return
		end
	end
end

function GM:PlayerSelectSpawn(ply) --Returns correct spawn point for team
	self:FixTeleportAngles()
	chooseteam(ply)

	return table.Random(team.GetSpawnPoints(ply:Team()))
end

function GM:PlayerLoadout(ply)
	if ply:Team() == TEAM_SPECTATE then return end

	if ply:Team() == TEAM_BLUE or ply:Team() == TEAM_RED then
		ply:Give("weapon_psw_sabre")

		if ply:Team() == TEAM_RED then
			ply:Give("weapon_psw_pistol")
		elseif ply:Team() == TEAM_BLUE then
			ply:Give("weapon_psw_pistol2")
		end

		if ply:GetInfoNum("psw_muskettype", 0) == 0 then
			ply:Give("weapon_psw_musket")
		else
			ply:Give("weapon_psw_musketbayo")
		end

		ply:Give("weapon_psw_grenade")

		if ply:IsSuperAdmin() then
			ply:Give("weapon_physgun")
		end

		ply:GiveAmmo(7, "pistol")

		ply:SelectWeapon("weapon_psw_sabre")
	end
end

function GM:PlayerSetModel(ply)
	if ply:Team() == TEAM_SPECTATE then return end

	if ply:Team() == TEAM_BLUE then
		ply:SetModel("models/player/jack_sparrow.mdl")
	end

	if ply:Team() == TEAM_RED then
		ply:SetModel("models/player/redcoat/redcoat.mdl")
	end
end

function GM:PlayerSetHandsModel(ply, ent)
	local plymdl = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(plymdl)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

function GM:PlayerConnect(name, ip)
	PrintMessage(HUD_PRINTTALK, name .. " be joinin' the battle!")
end

function GM:PlayerDisconnected(ply)
	PrintMessage(HUD_PRINTTALK, ply:Nick().. " 'as fled the battle!")
end

function GM:PlayerUse(ply, entity)
	if ply:Team() == TEAM_SPECTATE then
		return false
	end

	return true
end

function GM:PlayerNoClip(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		return true
	end

	return false
end

--[[
function GM:ShouldCollide(ent1, ent2)
	if ent1:IsPlayer() and ent2:IsPlayer() then
		return false
	end
end
--]]

function GM:PlayerShouldTakeDamage(vic, att)
	if att:IsPlayer() then
		if att:Team() == vic:Team() and GetConVarNumber("psw_friendlyfire") == 0 then
			return false
		end
	elseif att:GetName() == "pswwaterdamage" and GetConVarNumber("psw_nowaterdamage") == 1 then
		return false
	end
--[[
	elseif attacker:GetClass() == "trigger_hurt" and GetConVarNumber("psw_nowaterdamage") == 1 then
		return false
	end
--]]
	return true
end

--Extinguish Player on Fire and Breath Underwater in case of water damage disabled
hook.Add("Think", "PSW_LimitedBreath", function(ply)
	for _, v in pairs(player.GetAll()) do
		if v:Alive() then
			if v:WaterLevel() == 3 then
				if v:IsOnFire() then
				   v:Extinguish()
				end
				if v.NextHurt < CurTime() then
					v:TakeDamage(5)
					v.NextHurt = CurTime() + 1
				end
			else
				v.NextHurt = CurTime() + 10
			end
		end
	end
end)
