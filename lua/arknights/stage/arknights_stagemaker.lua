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
		Structures = Arknights.Stage.Structures,
		Structures_Details = Arknights.Stage.Structures_Details,
		Background = Arknights.Stage.Background,
		Music = Arknights.Stage.Music,
		Size = Arknights.Stage.Size,
	}
	file.Write("arknights/locallevels/"..Arknights.Stage.MapID..".dat", util.Compress(util.TableToJSON(mapData)))
end