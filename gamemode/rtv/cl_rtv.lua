include("rtv/config.lua")

RTV.Panel = nil
RTV.Maps = {}
RTV.Keys = {}

function RTV.TogglePanel()
	if IsValid(RTV.Panel) then
		RTV.Panel:Remove()
	end

	if not GetGlobalBool("In_Voting") then RTV.Keys = {} return end

	local pn = vgui.Create("DFrame")
	pn:SetSize(300, 20 + (26 * #RTV.Maps))
	pn:SetPos(5, ScrH() * 0.4)
	pn:SetTitle("")
	pn:ShowCloseButton(false)
	pn:SetDraggable(false)
	function pn:Paint(w, h)
		surface.SetDrawColor(Color(13, 14, 15, 200))
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(Color(55, 55, 55, 170))
		surface.DrawRect(2, 2, w - 4, h - 4)

		surface.SetTextColor(color_white)
		surface.SetFont("pswsmall")
		local w2, h2 = surface.GetTextSize("Rock the Vote")
		surface.SetTextPos(w/2 - w2/2, 5)
		surface.DrawText("Rock the Vote")
	end
	RTV.Panel = pn

	local voted = false

	for k, v in ipairs(RTV.Maps) do
		local text = vgui.Create("DLabel", pn)
		text:SetFont("pswsmall")
		text:SetColor(color_white)
		text:SetText(tostring(k)..") "..v)
		text:SetPos(5, (26 * k-1))
		text:SizeToContents()
		RTV.Keys[k + 1] = {text, v == "Extend Current Map" and "EXTEND" or k}
	end

	function pn:Think()
		if not voted and GetGlobalBool("In_Voting") and #RTV.Keys > 0 then
			for k, v in pairs(RTV.Keys) do
				if input.IsKeyDown(k) and v[1] then
					voted = true
					v[1]:SetColor(Color(0, 255, 0, 255))
					RunConsoleCommand("rtv_vote", v[2])
					surface.PlaySound("garrysmod/save_load1.wav")
				end
			end
		end
	end
end
concommand.Add("rtv_menu", RTV.TogglePanel)

net.Receive("RTV_Toggle", function(len)
	timer.Simple(0.5, function()
		RTV.TogglePanel()
	end)
end)

net.Receive("RTV_Maps", function()
	RTV.Maps = {}
	local count = net.ReadUInt(4)
	for i = 1, count do
		RTV.Maps[i] = net.ReadString()
	end
end)
