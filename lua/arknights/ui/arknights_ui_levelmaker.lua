function Arknights.GetLevelFiles()
	local fn = {}
	for k,v in ipairs(file.Find("arknights/locallevels/*.dat", "DATA")) do
		table.insert(fn, v)
	end

	return fn
end

function Arknights.BuildLevelPanel(levelData)

end

Arknights.ReloadLevels = false
function Arknights.LevelMakerUI()
	local ui = Arknights.CreatePanelMat(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Arknights.GetCachedMaterial("arknights/torappu/bg/bg5.png"),Color(255, 255, 255, 255))
	Arknights.BackButton(ui, function()
		Arknights.FadeTransition(function()
			ui:Remove()
		end)
	end)

	local vertical_margin = AKScreenScaleH(70)
	local horizontal_margin = AKScreenScaleH(28)
	local scroll = Arknights.CreateScroll(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Color(30, 30, 30, 0))

	ui.SelectedLevelIndex = nil

	scroll.Elements = {}
	scroll.ReloadLevels = function()
		local levels = Arknights.GetLevelFiles()
		scroll.Elements = {}
		scroll:Clear()

		local panelMask = Arknights.GetCachedMaterial("arknights/meiryi/arts/ui/mask001.png")
		local margin = AKScreenScaleH(6)
		for k,v in ipairs(levels) do
			local ctx = file.Read("arknights/locallevels/"..v, "DATA")
			if(!ctx) then continue end
			local decompressed = util.Decompress(ctx)
			if(!decompressed) then continue end
			local levelData = util.JSONToTable(decompressed)
			if(!levelData) then continue end
			local panel = Arknights.CreatePanel(scroll, 0, 0, scroll:GetWide(), AKScreenScaleH(72), Color(0, 0, 0, 0))
				panel:Dock(TOP)
				panel:DockMargin(0, 0, 0, margin)
				local img = levelData.Background
				local previewFound = false
				local path = "data/arknights/levelthumbnails/"..levelData.MapID..".png"
				if(file.Exists(path, "GAME")) then
					img = path
					previewFound = true
				end
				local previewsize = panel:GetTall() * 1.778
				if(previewFound) then
					local preview = Arknights.CreateImage(panel, 0, 0, previewsize, panel:GetTall(), img)
				else
					local notfoundbg = Arknights.CreatePanel(panel, 0, 0, previewsize, panel:GetTall(), Color(50, 50, 50, 255))
					local size = notfoundbg:GetWide() * 0.35
					local notfoundicon = Arknights.CreatePanelMat(notfoundbg, notfoundbg:GetWide() * 0.5 - size * 0.5, notfoundbg:GetTall() * 0.5 - size * 0.5, size, size, Arknights.GetCachedMaterial("arknights/torappu/common/empty_big.png"), Color(255, 255, 255, 255))
				end
				local sideSize = panel:GetWide() * 0.15
				local sideTall = panel:GetTall() * 0.5
				local linepos = panel:GetTall() * 0.75
				local lineoffset = panel:GetTall() - linepos
				local bg = Arknights.CreatePanelMat(panel, previewsize, 0, panel:GetWide() - (previewsize + sideSize), panel:GetTall(), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"), Color(180, 180, 180, 200))
				local startX = panel:GetTall() * 1.778 + margin
				local wide, tall, title = Arknights.CreateLabel(panel, startX, margin, levelData.MapName, "Arknights_StageList_1.5x", Color(0, 0, 0, 255))
				local wide, tall, mapid = Arknights.CreateLabel(panel, startX, 0, "ID: "..levelData.MapID, "Arknights_StageList_0.45x", Color(0, 0, 0, 255))
				mapid:SetY(linepos - tall)
				local wide, tall, author = Arknights.CreateLabel(panel, startX, linepos + lineoffset * 0.5, "Author: "..levelData.Author, "Arknights_StageList_0.45x", Color(0, 0, 0, 255))
				author.ConcText = "Author : "
				author.TargetID = levelData.Author
				author.CentVer()
				author.Think = Arknights.LabelNameFunc
				local wide, tall, date = Arknights.CreateLabel(panel, 0, linepos + lineoffset * 0.5, os.date("%Y/%m/%d", levelData.CreationDate), "Arknights_StageList_0.45x", Color(0, 0, 0, 255))
				date.CentVer()
				date:SetX((panel:GetWide() - sideSize) - (wide + margin))
				Arknights.CreatePanel(panel, startX, linepos, bg:GetWide() - (margin * 2), AKScreenScaleH(1), Color(0, 0, 0, 255))
				local sidepos = panel:GetWide() - sideSize
				Arknights.CreateButton(panel, sidepos, 0, sideSize, sideTall, "Edit", "Arknights_StageList_1x", color_white, Color(30, 30, 30, 255), function()
					Arknights.ButtonClickSound("select")
					Arknights.LoadingScreen("arknights/torappu/loadingillusts/default.png", {
						midloading = function()
							Arknights.StageMaker.GetMaterials()
							Arknights.StageMaker.CacheMaterial()
							Arknights.CacheEnemySprites(levelData)
						end,
						finishedloading = function()
							Arknights.StartStage(levelData, true)
						end,
					})
				end)
				Arknights.CreateButton(panel, sidepos, sideTall, sideSize, sideTall, "Delete", "Arknights_StageList_1x", color_white, Color(30, 30, 30, 255), function()
					Arknights.PopupConfirm({
						t1 = "Warning",
						t2 = "Deleting level : "..levelData.MapName,
						ptext = "Name for the level",
						tmat = "arknights/torappu/common_icon/btn_icon_cancel.png",
						centertext = "Are you sure you want to delete this level?",
						t1color = Color(255, 50, 50, 255),
						t2color = Color(40, 40, 40, 255),
						tcolor = Color(0, 0, 0, 255),
						tcolor2 = Color(200, 200, 200, 255),
						passfunc = function()
							file.Delete("arknights/locallevels/"..levelData.MapID..".dat")
							file.Delete("arknights/levelthumbnails/"..levelData.MapID..".png")
							Arknights.ReloadLevels = true
						end,
					})
					Arknights.ButtonClickSound("select")
				end)
				Arknights.CreatePanel(panel, sidepos + margin, sideTall, sideSize - (margin * 2), AKScreenScaleH(1), Color(255, 255, 255, 255))

			table.insert(scroll.Elements, panel)
		end
	end
	scroll.Think = function()
		if(!Arknights.ReloadLevels) then return end
		scroll.ReloadLevels()
		Arknights.ReloadLevels = false
	end
	local success, err = pcall(scroll.ReloadLevels)

	local height = AKScreenScaleH(54)
	local bottomMargin = AKScreenScaleH(10)
	local bottomPanel = Arknights.CreatePanel(ui, 0, AKScrH() - height, AKScrW(), height, Color(10, 10, 10, 210))
	local buttonWide, buttonHeight = AKScreenScaleH(128), AKScreenScaleH(48)
	local innerButtonTall = buttonHeight * 0.65
	local newLevel = Arknights.CreateMatButtonText(bottomPanel, AKScrW() - (buttonWide + horizontal_margin), bottomMargin, buttonWide, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/image_btn_bkg_blue.png"), "New Level", "Arknights_Button_1x", Color(255, 255, 255, 255), function()
	local mapID = Arknights.GetRandomHex(16)
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
						defaultStructures[x][y] = Arknights.GetStructureData("ground")
					end
				end
				local mapData = {
					MapID = mapID,
					MapName = text,
					Author = LocalPlayer():SteamID64(),
					Enemies = {},
					Spawns = {},
					Paths = {},
					MaxTime = 0,
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
	--[[
	local side_margin = AKScreenScaleH(8)
	local deleteLevel = Arknights.CreateMatButtonText(bottomPanel, AKScrW() - ((buttonWide * 2 + side_margin) + horizontal_margin), bottomMargin, buttonWide, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/image_btn_bkg_red.png"), "Delete Level", "Arknights_Button_1x", Color(255, 255, 255, 255), function()
		Arknights.ButtonClickSound("select")
	end, nil, innerButtonTall)
	]]

	ui.ScrollPanel = scroll
	Arknights.GameFrame.LevelMakerUI = ui
end