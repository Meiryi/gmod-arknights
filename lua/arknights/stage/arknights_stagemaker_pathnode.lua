Arknights.StageMaker = Arknights.StageMaker || {}
Arknights.StageMaker.SelectedPathNode = Arknights.StageMaker.SelectedPathNode || nil
Arknights.StageMaker.SelectedNode = Arknights.StageMaker.SelectedNode || nil
Arknights.StageMaker.NodeEditMode = Arknights.StageMaker.NodeEditMode || 0

function Arknights.StageMaker.IsCurrentNodeValid()
	local node = Arknights.StageMaker.SelectedPathNode
	if(!node || !Arknights.Stage.Paths[node]) then return false end
	return true
end

function Arknights.StageMaker.NewPathNode(x, y)
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
					{
						vec = Vector(x, y),
						timer = 0,
					}
				}
				Arknights.StageMaker.SelectedPathNode = text
				Arknights.ReloadPathList = true
				Arknights.SaveLevelData()
			end
		})
	Arknights.ReloadPathList = true
end

function Arknights.StageMaker.ModifyNodeTimer(node)
	if(!node || !Arknights.StageMaker.IsCurrentNodeValid() || !Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode][node]) then return end
	Arknights.PopupTextEntryMenu({
		t1 = "Timer",
		t2 = "Time for enemy to stay on this node",
		ptext = "Any number",
		t1color = Color(130, 130, 130, 255),
		t2color = Color(255, 220, 0, 255),
		tcolor = Color(0, 0, 0, 255),
		condfunc = function(text)
			local value = tonumber(text)
			if(!value) then
				Arknights.PopupNotify("You need to enter a number!")
				return
			end
			if(value < 0) then
				Arknights.PopupNotify("Value can't be smaller than 0!")
				return
			end
			return true
		end,
		passfunc = function(text)
			Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode][node].timer = tonumber(text)
			Arknights.SaveLevelData()
		end
	})
end

function Arknights.StageMaker.NewNode(x, y)
	table.insert(Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode], {
		vec = Vector(x, y),
		timer = 0,
	})
	Arknights.SaveLevelData()
	Arknights.ReloadPathList = true
end

function Arknights.StageMaker.RemoveNode()
	local selectedNode = Arknights.StageMaker.SelectedNode
	if(selectedNode != #Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode]) then return end
	table.remove(Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode], selectedNode)
	if(#Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode] <= 0) then
		Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode] = nil
		Arknights.StageMaker.SelectedPathNode = nil
	end
	Arknights.SaveLevelData()
	Arknights.ReloadPathList = true
end