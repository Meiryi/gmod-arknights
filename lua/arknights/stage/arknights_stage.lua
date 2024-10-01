Arknights.Stage = Arknights.Stage || {}
Arknights.Stage.Editmode = Arknights.Stage.Editmode || false
Arknights.Stage.ViewPointOrigin = Vector(0, 0, -20480)
Arknights.Stage.ViewPointAngle = Angle(55, 180, 0)
Arknights.Stage.ViewPointFOV = 60
Arknights.Stage.StructureOrigin = Vector(0, 0, -20680)

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

Arknights.Stage.AmbientLight = Arknights.Stage.AmbientLight || Color(0.7843, 0.9019, 1)

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

function Arknights.DestroyAllStageMeshes()
	for index1, data in pairs(Arknights.Stage.StructureMeshes) do
		for index2, meshes in pairs(data) do
			if(meshes) then
				meshes.top:Destroy()
				meshes.side:Destroy()
			end
			Arknights.Stage.StructureMeshes[index1][index2] = nil
		end		
	end
end

function Arknights.DestroyStageMesh(x, y)
	if(Arknights.Stage.StructureMeshes[x] && Arknights.Stage.StructureMeshes[x][y]) then
		Arknights.Stage.StructureMeshes[x][y].top:Destroy()
		Arknights.Stage.StructureMeshes[x][y].side:Destroy()
		Arknights.Stage.StructureMeshes[x][y] = nil
	end
end

function Arknights.RebuildStageMeshes()
	Arknights.DestroyAllStageMeshes()
	for index1, data in pairs(Arknights.Stage.Structures) do
		for index2, structure in pairs(data) do
			Arknights.CreateStageMesh(index1, index2)
		end
	end
end

function Arknights.CreateStageMesh(x, y)
	if(!Arknights.Stage.StructureMeshes[x]) then
		Arknights.Stage.StructureMeshes[x] = {}
	end
	if(Arknights.Stage.StructureMeshes[x][y]) then -- Clear old mesh
		Arknights.DestroyStageMesh(x, y)
	end
	local strdata = Arknights.GetHoveredStructure(x, y)
	local size = Arknights.Stage.GridSize
	local origin = Arknights.Stage.StructureOrigin + Vector(x * size, y * size, 0) + strdata.meshoffset
	local topmesh = Mesh()
	local sidemesh = Mesh()
	mesh.Begin(topmesh, MATERIAL_QUADS, 1)
	mesh.QuadEasy(origin, Vector(0, 0, 1), size, size)
	mesh.End()
	mesh.Begin(sidemesh, MATERIAL_QUADS, 3)
	mesh.QuadEasy(origin + Vector(24, 0, -24),  Vector(1, 0, 0), size, size)
	mesh.QuadEasy(origin + Vector(0, -24, -24),  Vector(0, -1, 0), size, size)
	mesh.QuadEasy(origin + Vector(0, 24, -24),  Vector(0, 1, 0), size, size)
	mesh.End()
	Arknights.Stage.StructureMeshes[x][y] = {
		top = topmesh,
		side = sidemesh,
	}
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
	Arknights.RebuildStageMeshes()
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