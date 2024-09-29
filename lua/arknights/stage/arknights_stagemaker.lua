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
		Structures = Arknights.Stage.Structures,
		Structures_Details = Arknights.Stage.Structures_Details,
		Background = Arknights.Stage.Background,
		Music = Arknights.Stage.Music,
		Size = Arknights.Stage.Size,
		CreationDate = Arknights.Stage.CreationDate,
	}
	file.Write("arknights/locallevels/"..Arknights.Stage.MapID..".dat", util.Compress(util.TableToJSON(mapData)))
end

Arknights.StageMaker.SelectedMode = nil
Arknights.StageMaker.BlockType = "ground"
Arknights.StageMaker.CurrentMaterial = "metal2t"

--[[
	Edit this function to add more structures, next time start coding from here
]]
local tiledata = {
	ground = {
		type = "ground",
		offset = -Vector(24, 24, 24),
		gridoffset = Vector(0, 0, 0),
		material = "default",
		deployable = true,
	},
	ranged = {
		type = "ranged",
		offset = -Vector(24, 24, 0),
		gridoffset = Vector(0, 0, 24),
		material = "default",
		deployable = true,
	},
	wall = {
		type = "wall",
		offset = -Vector(24, 24, 0),
		gridoffset = Vector(0, 0, 24),
		material = "default",
		deployable = false,
	},
}
function Arknights.GetStructureData(id)
	local data = tiledata[id] || tiledata
	return data
end

function Arknights.GetHoveredStructureEntity(x, y)
	if(!Arknights.Stage.StructuresEntList[x] || !IsValid(Arknights.Stage.StructuresEntList[x][y])) then return nil end
	return Arknights.Stage.StructuresEntList[x][y]
end

function Arknights.GetHoveredStructure(x, y)
	if(!Arknights.Stage.Structures[x]) then return nil end
	return Arknights.Stage.Structures[x][y]
end

function Arknights.RemoveStructure(x, y)
	if(!Arknights.Stage.Structures[x]) then return end
	Arknights.Stage.Structures[x][y] = nil
	Arknights.RemoveStageStructureEntities(x, y)
	Arknights.SaveLevelData()
end

function Arknights.SetStructure(x, y, id)
	if(!Arknights.Stage.Structures[x]) then
		Arknights.Stage.Structures[x] = {}
	end
	local prevData = Arknights.GetHoveredStructure(x, y)
	local data = Arknights.GetStructureData(id)
	if(prevData && prevData.type == data.type) then
		return
	end
	if(IsValid(Arknights.GetHoveredStructureEntity(x, y))) then
		Arknights.RemoveStageStructureEntities(x, y)
	end
	Arknights.Stage.Structures[x][y] = data
	Arknights.CreateStructureEntity(x, y, data)
	Arknights.SaveLevelData()
end

-- Next time start coding from here
--[[
	Needs to make a function that can create different strcutures based on the data given
]]
function Arknights.StageMaker.ClickedFunc()
	if(!Arknights.StageMaker.InEditMode()) then return end
	if(!input.IsMouseDown(107) && !input.IsMouseDown(108)) then return end
	local left_or_right = input.IsMouseDown(107) -- True for left, false for right
	if(input.IsMouseDown(108)) then
		left_or_right = false
	end
	local x, y = Arknights.GetSelectedGrid()
	if(left_or_right) then
		Arknights.SetStructure(x, y, Arknights.StageMaker.BlockType)
	else
		Arknights.RemoveStructure(x, y)
	end
	
end

function Arknights.StageMaker.HoldingFunc()
	if(!Arknights.StageMaker.InEditMode()) then return end
	Arknights.StageMaker.ClickedFunc()
end

function Arknights.StageMaker.InEditMode()
	return IsValid(Arknights.StageMaker.EditorFrame)
end