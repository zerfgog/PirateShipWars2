MsgN("Loading client-side PirateShip Wars.")

include("shared.lua")
include("util.lua")
include("cl_menus.lua")
include("cl_scoreboard.lua")
include("cl_dermaskin.lua")
include("cl_deathnotice.lua")
include("cl_hud.lua")

include("rtv/cl_rtv.lua")

language.Add("func_physbox", "Ship")
language.Add("env_explosion", "Ship Explosion")
language.Add("func_breakable", "Ship")
language.Add("worldspawn", "Ship")
language.Add("trigger_hurt", "Davy Jones Locker")

killicon.Add("func_physbox", "killicons/ship", COLOR_WHITE)
killicon.Add("func_breakable", "killicons/ship", COLOR_WHITE)
killicon.Add("worldspawn", "killicons/sent_cball_killicon", COLOR_WHITE)
killicon.Add("env_explosion", "hud/keg", COLOR_WHITE)

CreateClientConVar("psw_hudenabled", "1")
CreateClientConVar("psw_3rdperson", "0")
local psw_ambiancesounds = CreateClientConVar("psw_ambiancesounds", "1")
local psw_endroundmusic = CreateClientConVar("psw_endroundmusic", "1")

RunConsoleCommand("cl_pred_optimize", "1")

PSW_CONTENT_ID = 313668966
PSW_EXTRAMAPSCONTENT_ID = 313561979

CL_TeamLives = {}
CL_TeamLives[TEAM_RED] = 30
CL_TeamLives[TEAM_BLUE] = 30

function GM:PostDrawViewModel(vm, ply, weapon)
	if not IsValid(weapon) then return false end

	if weapon.PostDrawViewModel == nil then return false end
	return weapon:PostDrawViewModel(vm, weapon, ply)
end

GM.LastWave = 0
GM.LastBird = 0
function GM:Think() -- Ambience
	self.BaseClass:Think()

	if not psw_ambiancesounds:GetBool() then return end

	if LocalPlayer():WaterLevel() == 3 then return end

	if CurTime() > self.LastWave + 2 then
		self.LastWave = CurTime()
		LocalPlayer():EmitSound("ambient/water/wave" .. math.random(1, 6) .. ".wav", math.random(20, 40))
	end

	if CurTime() > self.LastBird + 8 then
		self.LastBird = CurTime()
		if not math.random(1,3) == 3 then return end
		local rand = Vector(math.random(-256, 256), math.random(-256, 256), math.random(0, 256)), 75, 100, math.Rand(0.2, 0.3)
		sound.Play("ambient/levels/coast/seagulls_ambient" .. math.random(1, 5) .. ".wav", LocalPlayer():EyePos() + rand)
	end
end

local function endroundmusic()
	if psw_endroundmusic:GetBool() then
		surface.PlaySound("psw/shipsinking.mp3")
	end
end
concommand.Add("endroundmusic", endroundmusic)

net.Receive("thirdperson", function()
	chat.AddText(COLOR_BLACK, "[PSW] ", Color(75, 75, 255), "You are now in third person!")
	RunConsoleCommand("psw_3rdperson", "1")
end)

net.Receive("firstperson", function()
	chat.AddText(COLOR_BLACK, "[PSW] ", Color(75, 75, 255), "You are now in first person!")
	RunConsoleCommand("psw_3rdperson", "0")
end)

net.Receive("PSW_Winner", function()
	local winteam = net.ReadInt(4)
	chat.AddText("The "..team.GetName(winteam).." win!")
end)

net.Receive("PSW_UpdateTeamLives", function()
	CL_TeamLives[TEAM_RED] = net.ReadUInt(8)
	CL_TeamLives[TEAM_BLUE] = net.ReadUInt(8)
end)

surface.CreateFont("psw", {
	size = ScreenScale(16),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsmall", {
	size = ScreenScale(8),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize4", {
	size = ScreenScale(4),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize6", {
	size = ScreenScale(6),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize8", {
	size = ScreenScale(8),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize10", {
	size = ScreenScale(10),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize12", {
	size = ScreenScale(12),
	weight = 200,
	antialias = true,
	additive = false,
	font = "akbar"
})

surface.CreateFont("pswsize16", {
	size = ScreenScale(16),
	weight = 400,
	antialias = true,
	additive = false,
	font = "akbar"
})
