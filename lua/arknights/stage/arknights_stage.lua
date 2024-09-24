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

function Arknights.RemoveStageStructureEntities(x, y)
	if(!Arknights.Stage.StructuresEntList[x] || !Arknights.Stage.StructuresEntList[x][y] || !IsValid(Arknights.Stage.StructuresEntList[x][y])) then return end
	Arknights.Stage.StructuresEntList[x][y]:Remove()
	Arknights.Stage.StructuresEntList[x][y] = nil
end

function Arknights.RemoveAllStageStructureEntities()
	for k,v in pairs(Arknights.Stage.StructuresEntList) do
		for x,y in pairs(v) do
			if(IsValid(y)) then
				y:Remove()
			end
			Arknights.Stage.StructuresEntList[k][x] = nil
		end
	end
end

function Arknights.RemoveOutOfBoundsStructure()
	local maxX, maxY = Arknights.Stage.Size.w - 1, Arknights.Stage.Size.h - 1
	for k,v in pairs(Arknights.Stage.StructuresEntList) do
		for x,y in pairs(v) do
			if(k <= maxX && x <= maxY) then continue end
			if(IsValid(y)) then
				y:Remove()
			end
			Arknights.Stage.StructuresEntList[k][x] = nil
			if(Arknights.Stage.Structures[k]) then
				Arknights.Stage.Structures[k][x] = nil
			end
		end
	end
end

function Arknights.AddStageStructureEntity(ent, x, y)
	if(!IsValid(ent)) then return end
	if(!Arknights.Stage.StructuresEntList[x]) then
		Arknights.Stage.StructuresEntList[x] = {}
	end
	Arknights.Stage.StructuresEntList[x][y] = ent
end

function Arknights.ReCalculateAllStructurePosition()
	local origin = Arknights.Stage.StructureOrigin
	local size = Arknights.Stage.GridSize
	for k,v in pairs(Arknights.Stage.StructuresEntList) do
		for x,y in pairs(v) do
			if(IsValid(y)) then
				y:SetPos(origin + Vector((k + 1) * size, (x + 1) * size, 0) + y.offset)
			end
		end
	end
end

function Arknights.CreateStructureEntity(x, y, data)
	local origin = Arknights.Stage.StructureOrigin
	local block = ents.CreateClientside("arknights_stage_structure")
		block:Spawn()
		block.type = data.type
		block.offset = data.offset
		block:SetPos(origin + Vector((x + 1) * Arknights.Stage.GridSize, (y + 1) * Arknights.Stage.GridSize, 0) + data.offset)
		Arknights.AddStageStructureEntity(block, x, y)
end

function Arknights.StartStage(stageData, editmode)
	if(!stageData || !istable(stageData)) then return end
	Arknights.Stage.Editmode = editmode
	Arknights.ToggleGameFrame(false)
	for k,v in pairs(stageData) do
		Arknights.Stage[k] = v
	end
	Arknights.CalculateScreenPosition()
	
	for k,v in pairs(Arknights.Stage.Structures) do
		for x,y in pairs(v) do
			Arknights.CreateStructureEntity(k, x, y)
		end
	end
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