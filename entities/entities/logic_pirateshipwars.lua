ENT.Type = "point"

-- Define all the possible outputs
OUTPUTLIST = {"OnStartWarmup", "OnStartRound", "OnEndRound", "OnBlueWins", "OnRedWins"}

function ENT:KeyValue(key, value)
	for i=1, #OUTPUTLIST do
		if key == OUTPUTLIST[i] then
			self:StoreOutput(key, value)
		end
	end
end

function ENT:SendStartWarmup()
	self:TriggerOutput("OnStartWarmup")
end
function ENT:SendStartRound()
	self:TriggerOutput("OnStartRound")
end
function ENT:SendEndRound()
	self:TriggerOutput("OnEndRound")
end
function ENT:SendBlueWins()
	self:TriggerOutput("OnBlueWins")
end
function ENT:SendRedWins()
	self:TriggerOutput("OnRedWins")
end
