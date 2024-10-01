Arknights.StagerMaker = Arknights.StagerMaker || {}
Arknights.StageMaker.SelectedPathNode = Arknights.StageMaker.SelectedPathNode || nil

function Arknights.StagerMaker.IsCurrentNodeValid()
	local node = Arknights.StageMaker.SelectedPathNode
	if(!node || !Arknights.Stage.Paths[node]) then return false end
	return true
end

function Arknights.StagerMaker.NewPathNode(x, y)
	local id = table.Count(Arknights.Stage.Paths) + 1
		Arknights.PopupTextEntryMenu({
			t1 = "New Node Path",
			t2 = "ID for the node path",
			ptext = "Any text",
			deftext = "nodepath_"..id,
			t1color = Color(130, 130, 130, 255),
			t2color = Color(255, 220, 0, 255),
			tcolor = Color(0, 0, 0, 255),
			condfunc = function(text)
				return true
			end,
			passfunc = function(text)
				Arknights.Stage.Paths[text] = {
					paths = {
						{
							vec = Vector(x, y),
							timer = 0,
						}
					},
				}
				Arknights.StageMaker.SelectedPathNode = text
			end
		})
end