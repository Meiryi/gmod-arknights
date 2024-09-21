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
