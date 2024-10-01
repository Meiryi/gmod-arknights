function Arknights.GetLevelFiles()
	local fn = {}
	for k,v in ipairs(file.Find("arknights/locallevels/*.dat", "DATA")) do
		table.insert(fn, v)
	end

	return fn
end

function Arknights.BuildLevelPanel(levelData)

end

function Arknights.LevelMakerUI()
	local ui = Arknights.CreatePanelMat(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Arknights.GetCachedMaterial("arknights/torappu/bg/bg5.png"),Color(255, 255, 255, 255))
	Arknights.BackButton(ui, function()
		Arknights.FadeTransition(function()
			ui:Remove()
		end)
	end)

	local vertical_margin = AKScreenScaleH(70)
	local horizontal_margin = AKScreenScaleH(28)
	local scroll = Arknights.CreateScroll(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Color(30, 30, 30, 70))

	ui.SelectedLevelIndex = nil

	scroll.ReloadLevels = function()
		local levels = Arknights.GetLevelFiles()
		scroll.Levels = levels
		scroll:Clear()

		for k,v in ipairs(levels) do
			local ctx = file.Read("arknights/locallevels/"..v, "DATA")
			if(!ctx) then continue end
			local decompressed = util.Decompress(ctx)
			if(!decompressed) then continue end
			local levelData = util.JSONToTable(decompressed)
			if(!levelData) then continue end
			
		end
	end
	scroll.ReloadLevels()

	local height = AKScreenScaleH(54)
	local bottomMargin = AKScreenScaleH(10)
	local bottomPanel = Arknights.CreatePanel(ui, 0, AKScrH() - height, AKScrW(), height, Color(10, 10, 10, 210))
	local buttonWide, buttonHeight = AKScreenScaleH(128), AKScreenScaleH(48)
	local innerButtonTall = buttonHeight * 0.65
	local newLevel = Arknights.CreateMatButtonText(bottomPanel, AKScrW() - (buttonWide + horizontal_margin), bottomMargin, buttonWide, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/image_btn_bkg_blue.png"), "New Level", "Arknights_Button_1x", Color(255, 255, 255, 255), function()
		Arknights.PopupTextEntryMenu({
			t1 = "New Level",
			t2 = "Give your level a name!",
			ptext = "Name for the level",
			t1color = Color(130, 130, 130, 255),
			t2color = Color(255, 220, 0, 255),
			tcolor = Color(0, 0, 0, 255),
			condfunc = function(text)
				if(#text <= 2) then
					Arknights.PopupNotify("You need to enter atleast 3 characters!")
					return
				end
				return true
			end,
			passfunc = function(text)
				local mapID = bit.tohex(math.random(1048576, 16777215), 6)
				local defaultStructures = {}
				local tall = 8 - 1
				local wide = 16 - 1
				--[[
					Types of structures:
						ground = Ground tile
						ranged = High ground tile
						wall = Wall tile
						kill = Kill tile
				]]
				for x = 0, tall do
					if(!defaultStructures[x]) then
						defaultStructures[x] = {}
					end
					for y = 0, wide do
						defaultStructures[x][y] = {
							type = "ground",
							offset = -Vector(24, 24, 24),
							gridoffset = Vector(0, 0, 0),
							material = "default",
							sidematerial = "default",
							deployable = true,
						}
					end
				end
				local mapData = {
					MapID = mapID,
					MapName = text,
					Author = LocalPlayer():SteamID64(),
					Enemies = {},
					Spawns = {},
					Paths = {},
					Structures = defaultStructures,
					Structures_Details = {},
					Background = "arknights/torappu/map/TX_LMC_BG.png",
					CreationDate = os.time(),
					Music = "indust",
					Size = {
						w = 8,
						h = 16,
					},
				}
				local ctx = util.Compress(util.TableToJSON(mapData))
				Arknights.LoadingScreen("arknights/torappu/loadingillusts/default.png", {
					midloading = function()
						Arknights.StageMaker.GetMaterials()
						Arknights.StageMaker.CacheMaterial()
					end,
					finishedloading = function()
						Arknights.StartStage(mapData, true)
					end,
				})
				file.Write("arknights/locallevels/"..mapID..".dat", ctx)
			end,
		})
		Arknights.ButtonClickSound("select")
	end, nil, innerButtonTall)
	local side_margin = AKScreenScaleH(8)
	local deleteLevel = Arknights.CreateMatButtonText(bottomPanel, AKScrW() - ((buttonWide * 2 + side_margin) + horizontal_margin), bottomMargin, buttonWide, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/image_btn_bkg_red.png"), "Delete Level", "Arknights_Button_1x", Color(255, 255, 255, 255), function()
		Arknights.ButtonClickSound("select")
	end, nil, innerButtonTall)

	ui.ScrollPanel = scroll
	Arknights.GameFrame.LevelMakerUI = ui
end