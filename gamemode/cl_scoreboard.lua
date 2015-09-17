local PSWSB
local PSWSBLeft
local PSWSBRight
local PSWSBSpectator

local function SortByUserID(a, b)
	local afrags = a:Frags()
	local bfrags = b:Frags()

	return afrags == bfrags and (a:Deaths() < b:Deaths()) or (bfrags < afrags)
end

local function profileopen(self, mc)
	if mc == MOUSE_LEFT then
		local player = self.Player
		if player:IsValid() then
			self.Player:ShowProfile()
		end
	end
end

function GM:ScoreboardRefresh(PSWSB)
	for _, element in pairs(PSWSB.Elements) do
		element:Remove()
		element:SetVisible(false)
	end
	PSWSB.Elements = {}

	local list = vgui.Create("DPanelList", PSWSB)
	local panw = ScrW() * 0.28 - 8
	list:SetSize(panw, PSWSB:GetTall() - 72)
	list:SetPos(4, 64)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSpacing(2)
	PSWSB.PanelList = list
	table.insert(PSWSB.Elements, list)

	local Label = vgui.Create("DLabel", PSWSB)
	Label:SetText("Score")
	Label:SetTextColor(color_white)
	Label:SetFont("pswsmall")
	surface.SetFont("pswsmall")
	local tw, th = surface.GetTextSize("Score")
	Label:SetPos(panw * 0.67 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(PSWSB.Elements, Label)

	local Label = vgui.Create("DLabel", PSWSB)
	Label:SetText("Deaths")
	Label:SetTextColor(color_white)
	Label:SetFont("pswsmall")
	surface.SetFont("pswsmall")
	local tw, th = surface.GetTextSize("Deaths")
	Label:SetPos(panw * 0.79 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(PSWSB.Elements, Label)

	local Label = vgui.Create("DLabel", PSWSB)
	Label:SetText("Ping")
	Label:SetTextColor(color_white)
	Label:SetFont("pswsmall")
	surface.SetFont("pswsmall")
	local tw, th = surface.GetTextSize("Ping")
	Label:SetPos(panw * 0.9 + 8 - tw * 0.5, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(PSWSB.Elements, Label)

	local allplayers
	if PSWSB == PSWSBLeft then
		allplayers = team.GetPlayers(TEAM_RED)
	elseif PSWSB == PSWSBRight then
		allplayers = team.GetPlayers(TEAM_BLUE)
	else
		allplayers = team.GetPlayers(TEAM_SPECTATE)
	end

	table.sort(allplayers, SortByUserID)
	for i, pl in ipairs(allplayers) do
		local Panel = vgui.Create("Panel", list)
		Panel:SetSize(panw, 40)
		Panel:SetMouseInputEnabled(true)
		Panel.Player = pl
		Panel.Paint = emtptypaint
		Panel.OnMousePressed = profileopen
		list:AddItem(Panel)

		if pl:IsValid() then
			local avatar = vgui.Create("AvatarImage", Panel)
			avatar:SetPos(4, 4)
			avatar:SetSize(32, 32)
			avatar:SetPlayer(pl)
		end

		local Label = vgui.Create("DLabel", Panel)
		local txt = pl:Name()
		if not pl:Alive() and pl:Team() ~= TEAM_SPECTATE then
			txt = "*DEAD* "..txt
			Label:SetTextColor(team.GetColor(TEAM_SPECTATE))
		else
			Label:SetTextColor(team.GetColor(pl:Team()))
		end
		Label:SetText(txt)
		Label:SetFont("pswsmall")
		surface.SetFont("pswsmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetPos(48, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)
		Label:SetSize(tw, th)

		local txt = pl:Frags()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("pswsmall")
		surface.SetFont("pswsmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.67 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Deaths()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("pswsmall")
		surface.SetFont("pswsmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.79 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Ping()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("pswsmall")
		surface.SetFont("pswsmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.9 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)
		
		local Label = vgui.Create("DLabel", PSWSBLeft)
		Label:SetText("Redcoats")
		Label:SetTextColor(Color(240,40,40,255))
		Label:SetFont("psw")
		surface.SetFont("psw")
		Label:SetPos(ScrW()* 0.09, ScrH()* 0.001)
		Label:SizeToContents()
		
		local Label = vgui.Create("DLabel", PSWSBRight)
		Label:SetText("Pirates")
		Label:SetTextColor(Color(40,40,240,255))
		Label:SetFont("psw")
		surface.SetFont("psw")
		Label:SetPos(ScrW()* 0.1, ScrH()* 0.001)
		Label:SizeToContents()
		
		local Label = vgui.Create("DLabel", PSWSBSpectator)
		Label:SetText("Spectator")
		Label:SetTextColor(color_black)
		Label:SetFont("psw")
		surface.SetFont("psw")
		Label:SetPos(ScrW()* 0.088, ScrH()* 0.001)
		Label:SizeToContents()
	end
end

local Scroll = 0
function GM:CreateScoreboard()
	PSWSB = vgui.Create("DImage")
	PSWSB:SetPos(ScrW()* 0.20, ScrH()* 0.06)
	PSWSB:SetImage('PirateShipWars/old_parchment')
	PSWSB:SizeToContents() // make the control the same size as the image. 
	PSWSB:SetSize(ScrW()* 0.60, ScrH()* 0.90)

	PSWSBImage2 = vgui.Create("DImage")
	PSWSBImage2:SetPos(ScrW()* 0.42, ScrH()* 0.01)
	PSWSBImage2:SetImage('Pirateshipwars/PSWlogo')
	PSWSBImage2:SizeToContents() // make the control the same size as the image. 
	PSWSBImage2:SetSize(ScrW()* 0.15, ScrH()* 0.11)
	
	PSWSBLeft = vgui.Create("DPanel", PSWSB)
	PSWSBLeft:SetSize(ScrW()* 0.275, ScrH()* 0.60)
	PSWSBLeft:SetPos(ScrW()* 0.02, ScrH()* 0.026)
	PSWSBLeft.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		draw.RoundedBox( 8, 0, 0, PSWSBLeft:GetWide(), PSWSBLeft:GetTall(), Color( 0, 0, 0, 150 ) ) -- Draw the rect
	end
	PSWSBLeft.NextRefresh = CurTime() + 3
	PSWSBLeft.Elements = {}
	local oldthink = PSWSBLeft.Think
	PSWSBLeft.Think = function(p)
		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = PSWSBLeft.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	PSWSBRight = vgui.Create("DPanel", PSWSB)
	PSWSBRight:SetSize(ScrW()* 0.275, ScrH()* 0.6)
	PSWSBRight:SetPos(ScrW()* 0.305, ScrH()* 0.026)
	PSWSBRight.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		draw.RoundedBox( 8, 0, 0, PSWSBRight:GetWide(), PSWSBRight:GetTall(), Color( 0, 0, 0, 150 ) ) -- Draw the rect
	end
	PSWSBRight.NextRefresh = CurTime() + 3
	PSWSBRight.Elements = {}
	local oldthink = PSWSBRight.Think
	PSWSBRight.Think = function(p)
		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = PSWSBRight.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	PSWSBSpectator = vgui.Create("DPanel", PSWSB)
	PSWSBSpectator:SetSize(ScrW()* 0.275, ScrH()* 0.3 - 64)
	PSWSBSpectator:SetPos(ScrW()* 0.162, ScrH()* 0.638)
	PSWSBSpectator.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		draw.RoundedBox( 8, 0, 0, PSWSBSpectator:GetWide(), PSWSBSpectator:GetTall(), Color( 0, 0, 0, 150 ) ) -- Draw the rect
	end
	PSWSBSpectator.NextRefresh = CurTime() + 3
	PSWSBSpectator.Elements = {}
	local oldthink = PSWSBSpectator.Think
	PSWSBSpectator.Think = function(p)
		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	self:ScoreboardRefresh(PSWSBLeft)
	self:ScoreboardRefresh(PSWSBRight)
	self:ScoreboardRefresh(PSWSBSpectator)
end

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if not PSWSBLeft then
		self:CreateScoreboard()
	end
	
	PSWSBLeft:SetVisible(true)
	PSWSBRight:SetVisible(true)
	PSWSBSpectator:SetVisible(true)
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false

	if not MOUSE_VIEW then
		gui.EnableScreenClicker(false)
	end

	PSWSB:SetVisible(false)
	PSWSBImage2:SetVisible(false)
	PSWSBLeft:Remove()
	PSWSBLeft = nil
	PSWSBRight:Remove()
	PSWSBRight = nil
	PSWSBSpectator:Remove()
	PSWSBSpectator = nil
end

function GM:HUDDrawScoreBoard()
end