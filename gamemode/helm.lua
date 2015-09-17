local DRIVE = {}

function DRIVE:Init()
	self.LastMove = CurTime()
end

function DRIVE:CalcView()
	local view = {}
	view.origin = self.Entity:GetPos() + Vector(0,0,200)
	view.angles = self.Entity:GetAngles()
	return view
end

function DRIVE:SetupControls()
end

function DRIVE:StartMove(md, cmd)
end

function DRIVE:Move(md)
end

function DRIVE:FinishMove(md)
end
drive.Register("drive_helm", DRIVE, "drive_base")