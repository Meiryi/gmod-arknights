Arknights.StageMaker = Arknights.StageMaker || {}
Arknights.StageMaker.SelectedGridX = nil
Arknights.StageMaker.SelectedGridY = nil

function Arknights.SetSelectedGrid(x, y)
	Arknights.StageMaker.SelectedGridX = x
	Arknights.StageMaker.SelectedGridY = y
end

function Arknights.GetSelectedGrid()
	return Arknights.StageMaker.SelectedGridX, Arknights.StageMaker.SelectedGridY
end

function Arknights.SaveLevelData()
	local mapData = {
		MapID = Arknights.Stage.MapID,
		MapName = Arknights.Stage.MapName,
		Author = Arknights.Stage.Author,
		Enemies = Arknights.Stage.Enemies,
		Paths = Arknights.Stage.Paths,
		Spawns = Arknights.Stage.Spawns,
		MaxTime = Arknights.Stage.MaxTime,
		Structures = Arknights.Stage.Structures,
		Structures_Details = Arknights.Stage.Structures_Details,
		Background = Arknights.Stage.Background,
		Music = Arknights.Stage.Music,
		Size = Arknights.Stage.Size,
		CreationDate = Arknights.Stage.CreationDate,
	}
	file.Write("arknights/locallevels/"..Arknights.Stage.MapID..".dat", util.Compress(util.TableToJSON(mapData)))
end

Arknights.StageMaker.SelectedMode = 1
Arknights.StageMaker.BlockType = "ground"
Arknights.StageMaker.CurrentMaterial = "hunter/myplastic"
Arknights.StageMaker.TexturingMode = 1

--[[
	Edit this function to add more structures, next time start coding from here
]]
Arknights.StageMaker.TileData = {
	ground = {
		type = "ground",
		offset = -Vector(24, 24, 24),
		meshoffset = Vector(24, 24, 0),
		gridoffset = Vector(0, 0, 0),
		material = -1,
		sidematerial = -1,
		deployable = true,
	},
	ground2 = {
		type = "ground2",
		offset = -Vector(24, 24, 24),
		meshoffset = Vector(24, 24, 0),
		gridoffset = Vector(0, 0, 0),
		material = -1,
		sidematerial = -1,
		deployable = false,
	},
	ranged = {
		type = "ranged",
		offset = -Vector(24, 24, 0),
		meshoffset = Vector(24, 24, 24),
		gridoffset = Vector(0, 0, 24),
		material = -1,
		sidematerial = -1,
		deployable = true,
	},
	wall = {
		type = "wall",
		offset = -Vector(24, 24, 0),
		meshoffset = Vector(24, 24, 24),
		gridoffset = Vector(0, 0, 24),
		material = -1,
		sidematerial = -1,
		deployable = false,
	},
}

local spawns = {
	homebase = true,
	enemybase_ground = true,
	enemybase_air = true,
}
function Arknights.IsSpawn(id)
	return spawns[id]
end

function Arknights.IsHighGround(x, y)
	if(Arknights.Stage.Structures[x] && Arknights.Stage.Structures[x][y]) then
		return (Arknights.Stage.Structures[x][y].type == "wall" || Arknights.Stage.Structures[x][y].type == "ranged")
	end
	return false
end

function Arknights.GetStructureData(id)
	local data = table.Copy(Arknights.StageMaker.TileData[id])
	return data
end

function Arknights.GetHoveredStructure(x, y)
	if(!Arknights.Stage.Structures[x]) then return nil end
	return Arknights.Stage.Structures[x][y]
end

function Arknights.RemoveStructure(x, y)
	if(!Arknights.Stage.Structures[x]) then return end
	Arknights.Stage.Structures[x][y] = nil
	Arknights.DestroyStageMesh(x, y)
	Arknights.SaveLevelData()
end

function Arknights.SetStructureMaterial(x, y)
	local data = Arknights.GetHoveredStructure(x, y)
	if(!data) then return end
	if(Arknights.StageMaker.TexturingMode == 1) then
		Arknights.Stage.Structures[x][y].material = Arknights.StageMaker.CurrentMaterial
	else
		Arknights.Stage.Structures[x][y].sidematerial = Arknights.StageMaker.CurrentMaterial
	end
	Arknights.SaveLevelData()
end

function Arknights.CreateSpawnModelEntity(x, y, id)
	Arknights.Stage.Structures_Entities[x] = Arknights.Stage.Structures_Entities[x] || {}
	if(Arknights.Stage.Structures_Entities[x][y] && IsValid(Arknights.Stage.Structures_Entities[x][y])) then -- Remove old entity
		Arknights.Stage.Structures_Entities[x][y]:Remove()
	end
	local strdata = Arknights.Stage.Structures[x]
	local offset = Vector(0, 0, 0)
	if(strdata && strdata[y]) then
		if(strdata[y].type == "wall" || strdata[y].type == "ranged") then
			offset = Vector(0, 0, 24)
		end
	end
	local model, color = Arknights.Stage.SpawnModelList[id], Arknights.Stage.SpawnColorList[id]
	Arknights.Stage.Structures_Entities[x][y] = ClientsideModel(model)
	Arknights.Stage.Structures_Entities[x][y]:SetPos(Arknights.Stage.StructureOrigin + Vector(x * Arknights.Stage.GridSize, y * Arknights.Stage.GridSize, 0) + Vector(24, 24, 24) + offset)
	Arknights.Stage.Structures_Entities[x][y]:Spawn()
	Arknights.Stage.Structures_Entities[x][y]:SetColor(color)
	Arknights.Stage.Structures_Entities[x][y]:SetRenderMode(RENDERMODE_TRANSALPHA)
	Arknights.AddManualPainting(Arknights.Stage.Structures_Entities[x][y], false, true)
end

function Arknights.RemoveSpawnModelEntity(x, y)
	if(!Arknights.Stage.Structures_Entities[x] || !Arknights.Stage.Structures_Entities[x][y] || !IsValid(Arknights.Stage.Structures_Entities[x][y])) then return end
	Arknights.Stage.Structures_Entities[x][y]:Remove()
	Arknights.Stage.Structures_Entities[x][y] = nil
	Arknights.Stage.Spawns[x][y] = nil
	Arknights.SaveLevelData()
end

function Arknights.RemoveAllSpawnModelEntities()
	for x, data in pairs(Arknights.Stage.Structures_Entities) do
		for y, entity in pairs(data) do
			if(IsValid(entity)) then
				entity:Remove()
			end
			Arknights.Stage.Structures_Entities[x][y] = nil
		end
	end
end

function Arknights.RebuildSpawnModelEntities()
	Arknights.RemoveAllSpawnModelEntities()
	for x, data in pairs(Arknights.Stage.Spawns) do
		for y, spawn in pairs(data) do
			Arknights.CreateSpawnModelEntity(x, y, spawn.id)
		end
	end
end


function Arknights.SetSpawn(x, y, id)
	if(!Arknights.Stage.Spawns[x]) then
		Arknights.Stage.Spawns[x] = {}
	end
	Arknights.Stage.Spawns[x][y] = {
		id = id,
	}
	Arknights.CreateSpawnModelEntity(x, y, id)
	Arknights.SaveLevelData()
end

function Arknights.SetStructure(x, y, id)
	if(!Arknights.Stage.Structures[x]) then
		Arknights.Stage.Structures[x] = {}
	end
	if(Arknights.IsSpawn(id)) then
		Arknights.SetSpawn(x, y, id)
		return
	end
	local prevData = Arknights.GetHoveredStructure(x, y)
	local data = Arknights.GetStructureData(id)
	if(prevData && prevData.type == data.type && prevData.material == Arknights.StageMaker.CurrentMaterial) then
		return
	end
	local strdata = data
	Arknights.Stage.Structures[x][y] = strdata
	Arknights.CreateStageMesh(x, y)
	Arknights.SaveLevelData()
end

-- Next time start coding from here
--[[
	Needs to make a function that can create different strcutures based on the data given
]]
function Arknights.StageMaker.ClickedFunc(hold)
	if(!Arknights.StageMaker.InEditMode()) then return end
	if(!input.IsMouseDown(107) && !input.IsMouseDown(108)) then return end
	local left_or_right = input.IsMouseDown(107) -- True for left, false for right
	if(input.IsMouseDown(108)) then
		left_or_right = false
	end
	local x, y = Arknights.GetSelectedGrid()
	if(left_or_right) then
		if(Arknights.StageMaker.SelectedMode == 1) then
			Arknights.SetStructure(x, y, Arknights.StageMaker.BlockType)
		elseif(Arknights.StageMaker.SelectedMode == 2) then
			Arknights.SetStructureMaterial(x, y)
		elseif(Arknights.StageMaker.SelectedMode == 3) then
			if(hold) then return end
			if(Arknights.StageMaker.NodeEditMode == 0) then
				if(!Arknights.StageMaker.IsCurrentNodeValid()) then
					Arknights.StageMaker.NewPathNode(x, y)
				else
					Arknights.StageMaker.NewNode(x, y)
				end
			else
				Arknights.StageMaker.ModifyNodeTimer(Arknights.StageMaker.SelectedNode)
			end
		elseif(Arknights.StageMaker.SelectedMode == 4) then
			if(hold) then return end
			Arknights.StageMaker.EnemyPlacementPopup()
			Arknights.StageMaker.SelectedEnemyPosition = {x = x, y = y}
		end
	else
		if(Arknights.StageMaker.SelectedMode == 1) then
			if(Arknights.IsSpawn(Arknights.StageMaker.BlockType)) then
				Arknights.RemoveSpawnModelEntity(x, y)
			else
				Arknights.RemoveStructure(x, y)
			end
		elseif(Arknights.StageMaker.SelectedMode == 2) then

		elseif(Arknights.StageMaker.SelectedMode == 3) then
			if(hold) then return end
			if(Arknights.StageMaker.NodeEditMode == 0) then
				Arknights.StageMaker.RemoveNode()
			end
		end
	end
	
end

function Arknights.StageMaker.HoldingFunc()
	if(!Arknights.StageMaker.InEditMode()) then return end
	Arknights.StageMaker.ClickedFunc(true)
end

function Arknights.StageMaker.KeyCodePressed(key)
		if(Arknights.StageMaker.SelectedMode == 1) then

		elseif(Arknights.StageMaker.SelectedMode == 2) then

		elseif(Arknights.StageMaker.SelectedMode == 3) then
			if(Arknights.StageMaker.IsCurrentNodeValid() && key == KEY_ENTER) then
				Arknights.StageMaker.SelectedPathNode = nil
			end
		end
end

function Arknights.StageMaker.InEditMode()
	return IsValid(Arknights.StageMaker.EditorFrame)
end