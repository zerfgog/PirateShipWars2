local function GetPrintFunc(ply)
	if IsValid(ply) then
		return function(...)
			local t = ""
			for _, a in ipairs({...}) do
				t = t .. "\t" .. a
			end
			ply:PrintMessage(HUD_PRINTCONSOLE, t)
		end
	else
		return print
	end
end

local function PrintDamageLog(ply)
	local pr = GetPrintFunc(ply)

	if (not IsValid(ply)) or ply:IsSuperAdmin() then
		ServerLog(string.format("%s used damagelog_print\n", IsValid(ply) and ply:Nick() or "console"))
		pr("*** Damage log:\n")

		for k, txt in ipairs(GAMEMODE.DamageLog) do
			pr(txt)
		end

		pr("*** Damage log end.")
	else
		if IsValid(ply) then
			pr("You do not appear to be RCON or a superadmin, nor are we in the post-round phase!")
		end
	end
end
concommand.Add("damagelog_print", PrintDamageLog)

local function SaveDamageLog()
	local text = ""
	if #GAMEMODE.DamageLog == 0 then
		text = "Damage log is empty."
	else
		for k, txt in ipairs(GAMEMODE.DamageLog) do
			text = text .. txt .. "\n"
		end
	end

	local fname = string.format("damagelogs/dmglog_%s_%d.txt", os.date("%d%b%Y_%H%M"), os.time())

	file.Write(fname, text)
end
hook.Add("PSW_EndRound", "damagelog_save_hook", SaveDamageLog)

function DamageLog(txt)
	local t = math.max(0, CurTime() - GAMEMODE.RoundStartTime)

	txt = util.SimpleTime(t, "%02i:%02i.%02i - ") .. txt
--	ServerLog(txt .. "\n")

	table.insert(GAMEMODE.DamageLog, txt)
end