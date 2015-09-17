local PLAYER = FindMetaTable("Player")

function PLAYER:PSW_ChangeTeam(chosenteam)
	if chosenteam == self:Team() then
		self:PrintMessage(HUD_PRINTTALK, "You are already one of the "..team.GetName(chosenteam).."!")
	else
		local canswitch = self:CanChangeTeam()
		if canswitch or self.spectating then
			self:SetTeam(chosenteam)
			self:KillSilent()
			if chosenteam == TEAM_SPECTATE then
				self:StripWeapons()
				self:Spectate(OBS_MODE_ROAMING)
				self.spectating = true
				PrintMessage(HUD_PRINTTALK, self:Nick().." is now spectating!")
			else
				self:Spawn()
				self.spectating = false
				PrintMessage(HUD_PRINTTALK, self:Nick().." is now one of the "..team.GetName(chosenteam).."!")
			end
		else
			self:PrintMessage(HUD_PRINTTALK, "There are too many "..team.GetName(chosenteam).."!")
		end
	end
end
