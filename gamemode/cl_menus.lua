CreateClientConVar("psw_muskettype", 0, true, true)

local COLOR_WHITE = Color(255, 255, 255, 255)
local COLOR_BLACK = Color(0, 0, 0, 255)
local COLOR_INVIS = Color(0, 0, 0, 0)
---------------------------------
--F1 main
-------------------------------

local buttonTable = {}
buttonTable["Helpmain"] = {"Help"}
buttonTable["Teams"] = {"Select Team"}
buttonTable["Options"] = {"Options"}
buttonTable["Credits"] = {"Credits"}
buttonTable["Rules"] = {"Rules"}

function GM:ShowHelp()
	local main = vgui.Create("DLabel")
	main:SetSize(ScrW()*0.25, ScrH()*0.4)
	main:SetText("")
	main:Center()
	main.startTime = SysTime()
	main.Paint = function()
		Derma_DrawBackgroundBlur(main, main.startTime)
	end

	for k,v in pairs(buttonTable) do
		local btn = vgui.Create("DButton", main)
		btn:SetFont("psw")
		btn:SetText(v[1])
		btn:SetTall(ScrW()*0.02)
		btn:DockMargin(0, 0, 0, 12)
		btn:DockPadding(0, 12, 0, 12)
		btn:Dock(TOP)
		btn:SetDrawBackground(false)
		btn.DoClick = function() RunConsoleCommand(k) main:Remove() end
	end

	local closebutton = vgui.Create("DButton", main)
	closebutton:SetFont("psw")
	closebutton:SetText("Close")
	closebutton:SetTall(ScrW()*0.02)
	closebutton:DockMargin(0, 24, 0, 0)
	closebutton:DockPadding(0, 12, 0, 12)
	closebutton:Dock(TOP)
	closebutton:SetDrawBackground(false)
	closebutton.DoClick = function() main:Remove() end

	main:MakePopup()
end
concommand.Add("ShowHelp", function()
	hook.Run("ShowHelp")
end)

local function configmain(frm)
	frm:SetSize(ScrW()*0.48, ScrH()*0.72)
	frm:Center()
	frm:SetTitle("")
	frm:SetVisible(true)
	frm:SetDraggable(false)
	frm:ShowCloseButton(true)
	frm:MakePopup()
end

local simplemenus = {}
simplemenus["Helpmain"] = {
	function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
		draw.SimpleTextOutlined("Pirate Ship Wars 2", "psw", ScrW()*0.24, 36, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		draw.DrawText(GAMEMODE.HELP, "pswsize10", 10, 80, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
}
simplemenus["Credits"] = {
	function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
		draw.SimpleTextOutlined("Pirate Ship Wars 2", "psw", 400, 36, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		draw.DrawText(GAMEMODE.Credits, "pswsize12", 10, 80, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
}
simplemenus["Rules"] = {
	function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
		draw.SimpleTextOutlined("Pirate Ship Wars 2", "psw", 400, 36, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		draw.DrawText(GAMEMODE.Rules, "pswsize12", 10, 80, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
}

for name, v in pairs(simplemenus) do
	concommand.Add(name, function()
		local main = vgui.Create("DFrame")
		main:SetSize(ScrW()*0.48, ScrH()*0.72)
		main:Center()
		main:SetTitle("")
		main:SetVisible(true)
		main:SetDraggable(false)
		main:ShowCloseButton(true)
		main:MakePopup()
		main.Paint = v[1]
	end)
end

local teambuttons = {}
teambuttons[TEAM_RED] = {"Redcoat", "models/player/redcoat/redcoat.mdl", TEAM_RED, 0.0171}
teambuttons[TEAM_BLUE] = {"Pirate", "models/player/jack_sparrow.mdl", TEAM_BLUE, 0.25}

function teams(ply)
	local main = vgui.Create("DLabel")
	main:SetSize(ScrW()*0.48, ScrH()*0.72)
	main:SetText("")
	main:Center()
	main.startTime = SysTime()
	main.Paint = function()
		Derma_DrawBackgroundBlur(main, main.startTime)
	end

	PSWSB = vgui.Create("DImage", main)
	PSWSB:SetImage("gui/teamselect")
	PSWSB:SizeToContents()
	PSWSB:SetSize(ScrW()*0.48, ScrH()*0.65)

	for command, v in pairs(teambuttons) do
		local icon = vgui.Create("DModelPanel", main)
		icon:SetModel(v[2])
		icon:SetSize(ScrW()*0.2149, ScrH()*0.492)
		icon:SetPos(ScrW()*v[4], ScrH()*0.122)
		icon:SetFOV(50)
		icon.DoClick = function()
			net.Start("PSW_ChangeTeam")
				net.WriteInt(command, 4)
			net.SendToServer()
		end
	end

	local button = vgui.Create("DButton", main)
	button:SetFont("psw")
	button:SetText("Spectate")
	button:SetTall(ScrW()*0.02)
	button:DockMargin(0, 10, 0, 0)
	button:DockPadding(0, 12, 0, 12)
	button:Dock(BOTTOM)
	button:SetDrawBackground(false)
	button.DoClick = function()
		net.Start("PSW_ChangeTeam")
			net.WriteInt(TEAM_SPECTATE, 4)
		net.SendToServer()
	end

	local button = vgui.Create("DButton", main)
	button:SetFont("psw")
	button:SetText("Close")
	button:SetTall(ScrW()*0.02)
	button:DockMargin(0, 10, 0, 0)
	button:DockPadding(0, 12, 0, 12)
	button:Dock(BOTTOM)
	button:SetDrawBackground(false)
	button.DoClick = function() main:Remove() end

	main:MakePopup()
end
concommand.Add("Teams", teams)

---------------------------------
--F2 main
---------------------------------
function set_team(ply)
	local MainMenuFrame = vgui.Create("DFrame")
	MainMenuFrame:SetSize(600, 600)
	MainMenuFrame:SetTitle("Pirate Ship Wars V2")
	MainMenuFrame:Center()
	MainMenuFrame:SetVisible(true)
	MainMenuFrame:SetDraggable(false)
	MainMenuFrame:MakePopup()

	local ChooseATeam = vgui.Create("DLabel", MainMenuFrame) -- We only have to parent it to the DPanelList now, and set it's position.
	ChooseATeam:SetPos(220,0)
	ChooseATeam:SetColor(COLOR_WHITE)
	ChooseATeam:SetFont("psw")
	ChooseATeam:SetText("Choose a Team:")
	ChooseATeam:SizeToContents()

	local RedcoatsSB = vgui.Create("DLabel", MainMenuFrame) -- We only have to parent it to the DPanelList now, and set it's position.
	RedcoatsSB:SetPos(93,280)
	RedcoatsSB:SetColor(Color(165, 42, 42, 255))
	RedcoatsSB:SetFont("psw")
	RedcoatsSB:SetText("Redcoats")
	RedcoatsSB:SizeToContents()
	PlayerTeam1 = vgui.Create("DListView", MainMenuFrame)
	PlayerTeam1:SetPos(20, 320)
	PlayerTeam1:SetSize(270, 200)
	PlayerTeam1:SetMultiSelect(false)
	PlayerTeam1:AddColumn("Player") -- Add column
	PlayerTeam1:AddColumn("Kills")
	PlayerTeam1:AddColumn("Deaths")
	for k,v in pairs(team.GetPlayers(1)) do
		PlayerTeam1:AddLine(v:Nick(),v:Frags(),v:Deaths())
	end

	local PiratesSB = vgui.Create("DLabel", MainMenuFrame) -- We only have to parent it to the DPanelList now, and set it's position.
	PiratesSB:SetPos(390,280)
	PiratesSB:SetColor(Color(100, 149, 237, 255))
	PiratesSB:SetFont("psw")
	PiratesSB:SetText("Pirates")
	PiratesSB:SizeToContents()
	PlayerTeam2 = vgui.Create("DListView", MainMenuFrame)
	PlayerTeam2:SetPos(305, 320)
	PlayerTeam2:SetSize(270, 200)
	PlayerTeam2:SetMultiSelect(false)
	PlayerTeam2:AddColumn("Player") -- Add column
	PlayerTeam2:AddColumn("Kills")
	PlayerTeam2:AddColumn("Deaths")
	for k,v in pairs(team.GetPlayers(2)) do
		PlayerTeam2:AddLine(v:Nick(),v:Frags(),v:Deaths())
	end

	SpectatorButton = vgui.Create("DButton", MainMenuFrame)
	SpectatorButton:SetSize(310, 60)
	SpectatorButton:SetPos(145, 205)
	SpectatorButton:SetText("Spectator")
	SpectatorButton:SetFont("psw")
	SpectatorButton:SetColor(COLOR_WHITE)
	SpectatorButton:SetDrawBackground(false)
	SpectatorButton.DoClick = function()
		net.Start("PSW_ChangeTeam")
			net.WriteInt(TEAM_SPECTATE, 4)
		net.SendToServer()
	end

	RedLabel = vgui.Create("DLabel")
	RedLabel:SetParent(MainMenuFrame)
	RedLabel:SetPos(155, 50)
	RedLabel:SetText("Redcoats")
	RedLabel:SetFont("psw")
	RedLabel:SetTextColor(Color(165, 42, 42, 255))
	RedLabel:SizeToContents()

	BlueLabel = vgui.Create("DLabel")
	BlueLabel:SetParent(MainMenuFrame)
	BlueLabel:SetPos(335, 50)
	BlueLabel:SetText("Pirates")
	BlueLabel:SetFont("psw")
	BlueLabel:SetTextColor(Color(100, 149, 237, 255))
	BlueLabel:SizeToContents()

	ReDButton = vgui.Create("DImageButton")
	ReDButton:SetParent(MainMenuFrame)
	ReDButton:SetSize(128, 168)
	ReDButton:SetPos(145, 80)
	ReDButton:SetImage("vgui/hud/skull")
	ReDButton:SizeToContents()
	ReDButton.DoClick = function()
		net.Start("PSW_ChangeTeam")
			net.WriteInt(TEAM_RED, 4)
		net.SendToServer()
	end

	BlueButton = vgui.Create("DImageButton")
	BlueButton:SetParent(MainMenuFrame)
	BlueButton:SetSize(128, 168)
	BlueButton:SetPos(315, 80)
	BlueButton:SetImage("vgui/hud/blueskull")
	BlueButton:SizeToContents()
	BlueButton.DoClick = function()
		net.Start("PSW_ChangeTeam")
			net.WriteInt(TEAM_BLUE, 4)
		net.SendToServer()
	end
end
concommand.Add("ChooseTeam", set_team)

---------------------------------
--F4 main
---------------------------------
function Options(ply)
	local mainpanel = vgui.Create("DFrame")
	local wide = math.min(ScrW(), 500)
	local tall = math.min(ScrH(), 580)
	mainpanel:SetSize(wide, tall)
	mainpanel:Center()
	mainpanel:SetTitle("Pirate Ship Wars Options")
	mainpanel:SetVisible(true)
	mainpanel:SetDraggable(false)
	mainpanel:ShowCloseButton(true)
	mainpanel:MakePopup()
	--mainpanel.Paint = function()
		--draw.RoundedBox(8, 0, 0, mainpanel:GetWide(), mainpanel:GetTall(), COLOR_INVIS)
	--end

	local PropertySheet = vgui.Create("DPropertySheet", mainpanel)
	PropertySheet:SetPos(5, 30)
	PropertySheet:SetSize(490, 545)
	PropertySheet.Paint = function()
		draw.RoundedBox(8, 0, 0, PropertySheet:GetWide(), PropertySheet:GetTall(), COLOR_INVIS)
	end

--//Tab One options
	local TabOne = vgui.Create("DPanelList")
	TabOne:SetPos(0, 0)
	TabOne:SetSize(PropertySheet:GetWide(), PropertySheet:GetTall())
	TabOne:SetSpacing(5)
	TabOne:EnableHorizontal(false)
	TabOne:EnableVerticalScrollbar(true)

	local TestingForm = vgui.Create("DForm", TabOne)
	--TestingForm:SetPos(25, 50)
	TestingForm:SetSize(350, 50)
	TestingForm:SetSpacing(5)
	TestingForm:SetName("HUD Settings")
	TestingForm.Paint = function()
		surface.SetDrawColor(255, 51, 15, 255)
	end
	TabOne:AddItem(TestingForm)

	local CategoryContentOne = vgui.Create("DCheckBoxLabel", TabOne)
	--CategoryContentOne:SetPos(0,50)
	CategoryContentOne:SetText("Enable Hud")
	CategoryContentOne:SetConVar("psw_HUDEnabled")
	CategoryContentOne:SizeToContents()
	TestingForm:AddItem(CategoryContentOne)

	local CategoryContentTwo = vgui.Create("DCheckBoxLabel", TabOne)
	CategoryContentTwo:SetPos(0,70)
	CategoryContentTwo:SetText("Display Round Info (WIP)")
	CategoryContentTwo:SetConVar("psw_displayroundinfo")
	CategoryContentTwo:SizeToContents()
	TestingForm:AddItem(CategoryContentTwo)

	--[[local CategoryContentThree = vgui.Create("DCheckBoxLabel", TabOne)
	--CategoryContentThree:SetPos(0,70)
	CategoryContentThree:SetText("Display lives left (WIP Only Works If The Owner/Admin Has Enabled Lives System)")
	CategoryContentThree:SetConVar("psw_displaylives")
	CategoryContentThree:SizeToContents()
	TestingForm:AddItem(CategoryContentThree)]]--

	local TestingForm2 = vgui.Create("DForm", TabOne)
	TestingForm2:SetSize(350, 50)
	TestingForm2:SetSpacing(5)
	TestingForm2:SetName("Other Settings")
	TestingForm2.Paint = function()
		surface.SetDrawColor(255, 51, 15, 255)
	end
	TabOne:AddItem(TestingForm2)

	local CategoryContentFour = vgui.Create("DCheckBoxLabel", TabOne)
	CategoryContentFour:SetText("Toggle 3rd Person Mode")
	CategoryContentFour:SetConVar("psw_3rdperson")
	CategoryContentFour:SizeToContents()
	TestingForm2:AddItem(CategoryContentFour)

	local CategoryContentFive = vgui.Create("DCheckBoxLabel", TabOne)
	CategoryContentFive:SetText("Enable End Round Music")
	CategoryContentFive:SetConVar("psw_endroundmusic")
	CategoryContentFive:SizeToContents()
	TestingForm2:AddItem(CategoryContentFive)

	local CategoryContentSix = vgui.Create("DCheckBoxLabel", TabOne)
	CategoryContentSix:SetPos(0,70)
	CategoryContentSix:SetText("If enabled, your musket will have a bayonet attack instead of ironsights.")
	CategoryContentSix:SetConVar("psw_muskettype")
	CategoryContentSix:SizeToContents()
	TestingForm2:AddItem(CategoryContentSix)

	PropertySheet:AddSheet("Client Options", TabOne, "icon16/page_edit.png", false, false, "Client Options")
--//End of Tab One options

--//Tab Two options
	if (LocalPlayer():IsAdmin()) or (LocalPlayer():IsSuperAdmin()) then
	local TabTwo = vgui.Create("DPanelList")
	TabTwo:SetPos(0, 0)
	TabTwo:SetSize(PropertySheet:GetWide(), PropertySheet:GetTall())
	TabTwo:SetSpacing(5)
	TabTwo:EnableHorizontal(false)
	TabTwo:EnableVerticalScrollbar(true)

--Server Settings
	local TestingForm = vgui.Create("DForm", TabTwo)
	TestingForm:SetPos(25, 50)
	TestingForm:SetSize(350, 50)
	TestingForm:SetSpacing(5)
	TestingForm:SetName("Server Settings")
	TestingForm.Paint = function()
		surface.SetDrawColor(255, 51, 15, 255)
	end
	TabTwo:AddItem(TestingForm)

	local CategoryContentOne = vgui.Create("DCheckBoxLabel")
	CategoryContentOne:SetText("Disable Ships Explosive Barrel (On Next Round)")
	CategoryContentOne:SetTextColor(COLOR_WHITE)
	if GetConVarNumber("psw_nodoors") == 1 then
		CategoryContentOne:SetChecked(true)
	else
		CategoryContentOne:SetChecked(false)
	end
	function CategoryContentOne.OnChange()
		if GetConVarNumber("psw_nodoors") == 1 then
		net.Start("NoDoors")
		net.WriteFloat(0)
		net.SendToServer()
		else
		net.Start("NoDoors")
		net.WriteFloat(1)
		net.SendToServer()
		end
	end
	CategoryContentOne:SizeToContents()
	TestingForm:AddItem(CategoryContentOne)

	local CategoryContentTwo = vgui.Create("DCheckBoxLabel")
	CategoryContentTwo:SetText("Disable Friendly Fire")
	CategoryContentTwo:SetTextColor(COLOR_WHITE)
	if GetConVarNumber("psw_friendlyfire") == 1 then
		CategoryContentTwo:SetChecked(true)
	else
		CategoryContentTwo:SetChecked(false)
	end
	function CategoryContentTwo.OnChange()
		if GetConVarNumber("psw_friendlyfire") == 1 then
		net.Start("friendlyfire")
		net.WriteFloat(0)
		net.SendToServer()
		else
		net.Start("friendlyfire")
		net.WriteFloat(1)
		net.SendToServer()
		end
	end
	CategoryContentTwo:SizeToContents()
	TestingForm:AddItem(CategoryContentTwo)

	local CategoryContentThree = vgui.Create("DCheckBoxLabel")
	CategoryContentThree:SetText("Disable Water Damage")
	CategoryContentThree:SetTextColor(COLOR_WHITE)
	if GetConVarNumber("psw_nowaterdamage") == 1 then
		CategoryContentThree:SetChecked(true)
	else
		CategoryContentThree:SetChecked(false)
	end
	function CategoryContentThree.OnChange()
		if GetConVarNumber("psw_nowaterdamage") == 1 then
		net.Start("nowaterdamage")
		net.WriteFloat(0)
		net.SendToServer()
		else
		net.Start("nowaterdamage")
		net.WriteFloat(1)
		net.SendToServer()
		end
	end
	CategoryContentThree:SizeToContents()
	TestingForm:AddItem(CategoryContentThree)

	--[[local Enableplayerslives = vgui.Create("DCheckBoxLabel")
	Enableplayerslives:SetText("Enable Players Lives System (WIP)")
	Enableplayerslives:SetTextColor(COLOR_WHITE)
	if GetConVarNumber("psw_enableplayerslives") == 1 then
		Enableplayerslives:SetChecked(true)
	else
		Enableplayerslives:SetChecked(false)
	end
	function Enableplayerslives.OnChange()
		if GetConVarNumber("psw_enableplayerslives") == 1 then
		net.Start("enableplayerslives")
		net.WriteFloat(0)
		net.SendToServer()
		else
		net.Start("enableplayerslives")
		net.WriteFloat(1)
		net.SendToServer()
		end
	end
	Enableplayerslives:SizeToContents()
	TestingForm:AddItem(Enableplayerslives)

	local CategoryContentFive = vgui.Create("DNumSlider")
	CategoryContentFive:SetText("Players Lives (On Next Round)")
	CategoryContentFive:SetMinMax(1, 25)
	CategoryContentFive:SetDecimals(0)
	CategoryContentFive:SetValue(GetConVarNumber("psw_playerslives"))
	CategoryContentFive.ValueChanged = function(Self, Value)
		net.Start("Playerslives")
		net.WriteFloat(Value)
		net.SendToServer()
	end
	CategoryContentFive:SizeToContents()
	TestingForm:AddItem(CategoryContentFive)]]--

	local CategoryContentSix = vgui.Create("DNumSlider")
	CategoryContentSix:SetText("Max Rounds")
	CategoryContentSix:SetMinMax(4, 12)
	CategoryContentSix:SetDecimals(0)
	CategoryContentSix:SetValue(GetConVarNumber("psw_maxrounds"))
	CategoryContentSix.ValueChanged = function(Self, Value)
		net.Start("MaxRounds")
		net.WriteFloat(Value)
		net.SendToServer()
	end
	CategoryContentSix:SizeToContents()
	TestingForm:AddItem(CategoryContentSix)

	PropertySheet:AddSheet("Admin Options", TabTwo, "icon16/group", false, false, "Server Options")
	end
--//End of Tab Two options
end
concommand.Add("Options",Options)