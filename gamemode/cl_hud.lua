---------------------------------
--HUD
---------------------------------
local teamtex = {}
teamtex[TEAM_RED] = {'vgui/hud/blood', 'vgui/hud/skull', Color(130, 30, 30, 140)}
teamtex[TEAM_BLUE] = {'vgui/hud/blueblood', 'vgui/hud/blueskull', Color(30, 30, 130, 140)}

function GM:HUDPaint()
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )

	local ammo
	local ammostr
	local ammotype
	local curwep
	local playerteam = LocalPlayer():Team()

	if not GetConVar("psw_HUDEnabled"):GetBool() == true then return end

	if LocalPlayer():Team() == TEAM_SPECTATE then return end

	if LocalPlayer():Alive() then
		draw.WordBox(1, ScrW()*0.41,  ScrH()*0.02, "Redcoats", "pswsize12", Color(200,0,0,0), Color(130, 30, 30, 255))
		draw.WordBox(1, ScrW()*0.475, ScrH()*0.001,  "Rounds", "pswsize12", Color(200,0,0,0), Color(255,255,255,255))
		draw.WordBox(1, ScrW()*0.526, ScrH()*0.02,  "Pirates", "pswsize12", Color(200,0,0,0), Color(30, 30, 130, 255))

		draw.WordBox(1, ScrW()*0.432, ScrH()*0.04, CL_TeamLives[TEAM_RED].." Lives",       "pswsize12", Color(200,0,0,0), Color(255,255,255,255))
		draw.WordBox(1, ScrW()*0.49,  ScrH()*0.02, ""..GetConVarNumber("psw_maxrounds"), "pswsize12", Color(200,0,0,0), Color(255,255,255,255))
		draw.WordBox(1, ScrW()*0.542, ScrH()*0.04, CL_TeamLives[TEAM_BLUE].." Lives",      "pswsize12", Color(200,0,0,0), Color(255,255,255,255))

		surface.SetDrawColor(255, 255, 255, 255)
		local tid = surface.GetTextureID(teamtex[playerteam][1])
		surface.SetTexture(tid)
		surface.DrawTexturedRect( ScrW()*0.01, ScrH()*0.88, ScrW()*0.187, ScrH()*0.12 )

		local tid2 = surface.GetTextureID(teamtex[playerteam][2])
		surface.SetTexture(tid2)
		surface.DrawTexturedRect(ScrW()*0.01, ScrH()*0.88, ScrW()*0.06, ScrH()*0.088)

--			if LocalPlayer():Armor() > 0 then
--				draw.RoundedBox( 10, ScrW()*0.0665, ScrH()*0.86, ( ScrW()*0.1255 * ( LocalPlayer():Armor() / 100 ) ), ScrH()*0.029, Color( 30, 30, 130, 140 ) )
--				draw.RoundedBox( 10, ScrW()*0.064, ScrH()*0.858, ScrW()*0.13, ScrH()*0.033, Color( 20, 20, 20, 150 ) )
--			end

		if LocalPlayer():Health() > 10 then
			draw.RoundedBox(10, ScrW()*0.0665, ScrH()*0.9, (ScrW()*0.1255 * (LocalPlayer():Health() / 100 )), ScrH()*0.029, teamtex[playerteam][3])
			draw.RoundedBox(10, ScrW()*0.064, ScrH()*0.898, ScrW()*0.13, ScrH()*0.033, Color(20, 20, 20, 150))
		else --Added to prevent the bar from screwing
			surface.SetFont("psw") 
			surface.SetTextPos(ScrW()*0.07, ScrH()*0.895)
			surface.SetTextColor(170, 50, 50, 245)
			surface.DrawText("Ye be bleedin'!")
			draw.RoundedBox(10, ScrW()*0.064, ScrH()*0.898, ScrW()*0.13, ScrH()*0.033, Color(20, 20, 20, 150))
		end
	end

	if #LocalPlayer():GetWeapons() > 0 then
		curwep = LocalPlayer():GetActiveWeapon()
		if curwep and IsValid(curwep) then
			if curwep:GetPrimaryAmmoType() then
				ammotype = curwep:GetPrimaryAmmoType()
			else
				ammotype = false
			end
			if ammotype and ammotype ~= -1 then
				ammo = LocalPlayer():GetAmmoCount( ammotype )
				ammostr = curwep:Clip1() .. " / " .. ammo
				if ammo == 0 and curwep:Clip1() == 0 then 
					ammostr = "0 / 0"
				end

				surface.SetDrawColor( 255, 255, 255, 255 )
				local tid = surface.GetTextureID( "vgui/hud/gunhud" )
				surface.SetTexture( tid )
				surface.DrawTexturedRect( ScrW() - 354, ScrH() - 160, 356, 151 )

				surface.SetFont("psw") 
				surface.SetTextPos( ScrW() - 200, ScrH() - 100)
				surface.SetTextColor( 170, 50, 50, 245 )
				surface.DrawText(ammostr)
			end
		end
	end
end


function PSW2_ThirdPersonHUDPaint()
	if GetConVarNumber("psw_3rdperson") >= 1 then
		local ply = LocalPlayer()
		-- trace from muzzle to hit pos
		local t = {}
		t.start = ply:GetShootPos()
		t.endpos = t.start + ply:GetAimVector() * 9000
		t.filter = ply
		local tr = util.TraceLine(t)
		local pos = tr.HitPos:ToScreen()
		local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024
		local size = 10 + 20 * (1.0 - fraction)
		local offset = size * 0.5
		local offset2 = offset - (size * 0.1)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y)
		surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y)
		surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2)
		surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2)
		surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y)
		surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1)
	end
end
hook.Add("HUDPaint", "PSW2_ThirdPersonHUDPaint", PSW2_ThirdPersonHUDPaint)

function PSW2_MyCalcView(ply, pos, angles, fov)
	if GetConVarNumber("psw_3rdperson") >= 1 then
		local view = {}
		view.origin = pos-(angles:Forward()*100) + ( angles:Right()* 15 )
		view.angles = angles
		view.fov = fov
		return view
	end
end
hook.Add("CalcView", "PSW2_MyCalcView", PSW2_MyCalcView)

hook.Add("ShouldDrawLocalPlayer", "PSW2_ShouldDrawLocalPlayer", function(ply)
	if GetConVarNumber("psw_3rdperson") >= 1 then
		return true
	end
end)

--[[---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
   Desc: Draw the target id (the name of the player youre currently looking at)
---------------------------------------------------------]]--
function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if not trace.Hit then return end
	if not trace.HitNonWorld then return end

	local text = ""
	local font = "pswsmall"

	if trace.Entity:IsPlayer() then
		text = trace.Entity:Nick()
	else
		return
		--text = trace.Entity:GetClass()
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = gui.MousePos()

	if MouseX == 0 and MouseY == 0 then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

--	if trace.Entity:Team() == LocalPlayer():Team() then
		y = y + h + 5
		local healthtext = trace.Entity:Health() .. "%"

		surface.SetFont( font )
		local w, h = surface.GetTextSize( healthtext )
		local x =  MouseX  - w / 2

		draw.SimpleText( healthtext, font, x+1, y+1, Color(0,0,0,120) )
		draw.SimpleText( healthtext, font, x+2, y+2, Color(0,0,0,50) )
		draw.SimpleText( healthtext, font, x, y, self:GetTeamColor( trace.Entity ) )
--	end
end

local HideElement = {
	CHudHealth = true,
	CHudBattery = true,
	CHudSecondaryAmmo = true,
	CHudAmmo = true,
}
function GM:HUDShouldDraw(n)
    return not HideElement[n]
end

function GM:CalcView( ply, origin, angles, fov )
	local plViewAngle = {}
	plViewAngle.origin = origin
	plViewAngle.fov = fov + 10
	plViewAngle.angles = Angle( angles.p, angles.y, 0 )
 	return plViewAngle
end

function GM:HUDAmmoPickedUp(name, amount)
	return false
end

function GM:HUDItemPickedUp(name)
	return false
end

function GM:HUDDrawPickupHistory()
	return false
end
