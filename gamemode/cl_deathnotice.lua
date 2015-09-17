local hud_deathnotice_time = CreateConVar("hud_deathnotice_time", "6", FCVAR_REPLICATED)

-- These are our kill icons
local COLOR_ICON	= Color(255, 80, 0)
local COLOR_NPC		= Color(250, 50, 50)

killicon.AddFont("prop_physics",		"pswsize12", "9", COLOR_ICON)
killicon.AddFont("weapon_smg1",			"pswsize12", "/", COLOR_ICON)
killicon.AddFont("weapon_357",			"pswsize12", ".", COLOR_ICON)
killicon.AddFont("weapon_ar2",			"pswsize12", "2", COLOR_ICON)
killicon.AddFont("crossbow_bolt",		"pswsize12", "1", COLOR_ICON)
killicon.AddFont("weapon_shotgun",		"pswsize12", "0", COLOR_ICON)
killicon.AddFont("rpg_missile",			"pswsize12", "3", COLOR_ICON)
killicon.AddFont("npc_grenade_frag",	"pswsize12", "4", COLOR_ICON)
killicon.AddFont("weapon_pistol",		"pswsize12", "-", COLOR_ICON)
killicon.AddFont("prop_combine_ball",	"pswsize12", "8", COLOR_ICON)
killicon.AddFont("grenade_ar2",			"pswsize12", "7", COLOR_ICON)
killicon.AddFont("weapon_stunstick",	"pswsize12", "!", COLOR_ICON)
killicon.AddFont("weapon_slam",			"pswsize12", "*", COLOR_ICON)
killicon.AddFont("weapon_crowbar",		"pswsize12", "6", COLOR_ICON)

local deaths = {}

local function PlayerIDOrNameToString(var)
	if type(var) == "string" then
		return var == "" and "" or "#"..var
	end

	local ply = Entity(var)

	if ply == nil then return "" end

	return ply:Nick()
end

net.Receive("PSW_PlayerKilledByPlayer", function(len)
	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
end)

net.Receive("PSW_PlayerKilledSelf", function(len)
	local victim = net.ReadEntity()

	GAMEMODE:AddDeathNotice(nil, 0, "suicide", victim:Name(), victim:Team())
end)

net.Receive("PSW_PlayerKilled", function(len)
	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim:Name(), victim:Team())
end)

local function RecvPlayerKilledNPC(len)
	local victim	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim, -1)
end
net.Receive("PSW_PlayerKilledNPC", RecvPlayerKilledNPC)

local function RecvNPCKilledNPC(len)
	local victim	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim, -1)
end
net.Receive("PSW_NPCKilledNPC", RecvNPCKilledNPC)

--[[---------------------------------------------------------
   Name: gamemode:AddDeathNotice(Victim, Attacker, Weapon)
   Desc: Adds an death notice entry
---------------------------------------------------------]]--
function GM:AddDeathNotice(vic, team1, inflictor, att, team2)
	local death = {}
	death.victim	= vic
	death.attacker	= att
	death.time		= CurTime()

	death.left	= vic
	death.right	= att
	death.icon	= inflictor

	death.color1 = team1 == -1 and COLOR_NPC or team.GetColor(team1)
	death.color2 = team2 == -2 and COLOR_NPC or team.GetColor(team2)

	if death.left == death.right then
		death.left = nil
		death.icon = "suicide"
	end

	table.insert(deaths, death)
end

local function DrawDeath(x, y, death, hud_deathnotice_time)
	local w, h = killicon.GetSize(death.icon)

	local fadeout = (death.time + hud_deathnotice_time) - CurTime()

	local alpha = math.Clamp(fadeout * 255, 0, 255)
	death.color1.a = alpha
	death.color2.a = alpha

	-- draw icon
	killicon.Draw(x, y, death.icon, alpha)

	-- draw killer
	if death.left then
		draw.SimpleText(death.left, "pswsize12", x - (w/2) - 16, y, death.color1, TEXT_ALIGN_RIGHT)
	end

	-- draw victim
	draw.SimpleText(death.right, "pswsize12", x + (w/2) + 16, y, death.color2, TEXT_ALIGN_LEFT)

	return (y + h*0.70)
end

function GM:DrawDeathNotice(x, y)
	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()

	x = x * ScrW()
	y = y * ScrH()

	-- Draw
	for k, death in pairs(deaths) do
		if (death.time + hud_deathnotice_time > CurTime()) then
			if death.lerp then
				x = x * 0.3 + death.lerp.x * 0.7
				y = y * 0.3 + death.lerp.y * 0.7
			end

			death.lerp = death.lerp or {}
			death.lerp.x = x
			death.lerp.y = y

			y = DrawDeath(x, y, death, hud_deathnotice_time)
		end
	end

	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for _, death in pairs(deaths) do
		if (death.time + hud_deathnotice_time > CurTime()) then return end
	end

	deaths = {}
end