Arknights.Stage = Arknights.Stage || {}
Arknights.Stage.Editmode = Arknights.Stage.Editmode || false
Arknights.Stage.ViewPointOrigin = Vector(0, 0, -25000)
Arknights.Stage.ViewPointAngle = Angle(55, 180, 0)
Arknights.Stage.ViewPointFOV = 60
Arknights.Stage.StructureOrigin = Vector(0, 0, -25200)

Arknights.Stage.GridSize = 48
Arknights.Stage.StructureID = 0

Arknights.Stage.Music = Arknights.Stage.Music || "indust"
Arknights.Stage.MapID = Arknights.Stage.MapID || "NULL"
Arknights.Stage.MapName = Arknights.Stage.MapName || "NULL"
Arknights.Stage.Author = Arknights.Stage.Author || "NULL"
Arknights.Stage.Background = Arknights.Stage.Background || "arknights/torappu/map/TX_LMC_BG.png"
Arknights.Stage.CreationDate = Arknights.Stage.CreationDate || -1

Arknights.Stage.Data = Arknights.Stage.Data || {}
Arknights.Stage.Size = Arknights.Stage.Size || {w = 16, h = 16}
Arknights.Stage.Enemies = Arknights.Stage.Enemies || {}
Arknights.Stage.Spawns = Arknights.Stage.Spawns || {}
Arknights.Stage.Paths = Arknights.Stage.Paths || {}
Arknights.Stage.Structures = Arknights.Stage.Structures || {}
Arknights.Stage.Structures_Details = Arknights.Stage.Structures_Details || {}

Arknights.Stage.StructuresEntList = Arknights.Stage.StructuresEntList || {}
Arknights.Stage.StructureMeshes = Arknights.Stage.StructureMeshes || {}
Arknights.Stage.IsHoveringStagePlane = false

function Arknights.CreateDebugOperator()
	if(IsValid(AKT)) then
		AKT:Remove()
		return
	end
	AKT = ents.CreateClientside("arknights_operator_base")
	AKT:Spawn()
end

function Arknights.MoveDebugOperator()
	if(!IsValid(AKT)) then return end
	AKT:SetPos(LocalPlayer():GetPos())
end

function Arknights.MoveDebugOperatorToViewOrigin(offset)
	if(!IsValid(AKT)) then return end
	AKT:SetPos(Arknights.Stage.ViewPointOrigin + (offset || Vector(0, 0, 0)))
end

function Arknights.RemoveDebugOperator()
	if(!IsValid(AKT)) then return end
	AKT:Remove()
end

function Arknights.RemoveOutOfBoundsStructure()
	local maxX, maxY = Arknights.Stage.Size.w - 1, Arknights.Stage.Size.h - 1
	for k,v in pairs(Arknights.Stage.Structures) do
		for x,y in pairs(v) do
			if(k <= maxX && x <= maxY) then continue end
			if(Arknights.Stage.Structures[k]) then
				Arknights.Stage.Structures[k][x] = nil
			end
		end
	end
end

function Arknights.StartStage(stageData, editmode)
	if(!stageData || !istable(stageData)) then return end
	Arknights.Stage.Editmode = editmode
	Arknights.ToggleGameFrame(false)
	for k,v in pairs(stageData) do
		Arknights.Stage[k] = v
	end
	Arknights.CalculateScreenPosition()
	Arknights.CreateStageUI()
end

local keydown = false
local das = 0
local dastime = 0
hook.Add("Think", "Arknights_ClickHandler", function()
	if(!Arknights.IsGameActive() || gui.IsGameUIVisible() || !Arknights.Stage.IsHoveringStagePlane) then return end
	local hold = (input.IsMouseDown(107) || input.IsMouseDown(108))
	if(!keydown && hold) then
		Arknights.StageMaker.ClickedFunc()
		dastime = SysTime() + 0.1
	else
		if(keydown && dastime < SysTime()) then
			Arknights.StageMaker.HoldingFunc()
		end
	end
	keydown = hold
end)