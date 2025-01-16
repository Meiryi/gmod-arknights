Arknights.StageMaker = Arknights.StageMaker || {}
Arknights.StageMaker.StopClickTime = -1
Arknights.StageMaker.MusicID = {
	lungmenbat = "lungmenbat",
	lungmenbatimp = "lungmenbatimp",
	chasing = "chasing",
	epic = "epic",
	escapebattle = "escapebattle",
	frostnova = "frostnova",
	indust = "indust",
	normal01 = "normal01",
	normal02 = "normal02",
	normal03 = "normal03",
	normalbattle = "normalbattle",
	qiecheng = "qiecheng",
	qiechengimp = "qiechengimp",
}

Arknights.StageMaker.BackgroundID = {
	background1 = "arknights/torappu/map/TX_BG_LM_roof_D.png",
	background2 = "arknights/torappu/map/TX_BG_LM_roof_N.png",
	background3 = "arknights/torappu/map/TX_Bridge_BG.png",
	background4 = "arknights/torappu/map/TX_Bridge_BG_fire.png",
	background5 = "arknights/torappu/map/TX_Dosscity_BG.png",
	background6 = "arknights/torappu/map/TX_GLBY_BG.png",
	background7 = "arknights/torappu/map/TX_LMC_BG.png",
	background8 = "arknights/torappu/map/TX_Qcity_core_BG.png",
	background9 = "arknights/torappu/map/TX_Qcity_ice_BG.png",
	background10 = "arknights/torappu/map/TX_Qcity_ice_BG01.png",
	background11 = "arknights/torappu/map/TX_SalViento_BG.png",
}

Arknights.StageMaker.SelectedEnemy = "NULL"
Arknights.StageMaker.SelectedEnemyPath = "NULL"
Arknights.StageMaker.SelectedEnemyPosition = {x = 0, y = 0}
Arknights.StageMaker.SelectedEnemySpawnTime = 0

function Arknights.ShowToolTip(tip, time)
	Arknights.ToolTipText = tip
	Arknights.ToolTipTextTime = SysTime() + time
end

local spacing = ScreenScaleH(4)
if(AKScreenScaleH) then
	spacing = AKScreenScaleH(4)
end
function Arknights.AutoResizePanel(ui, pnl, space)
	ui.Height = ui.Height + pnl:GetTall() + (space || spacing)
end

function Arknights.StageMaker.CreateTitle(ui, title)
	local _, _, title = Arknights.CreateLabel(ui, spacing, spacing, title, "Arknights_StageMaker_2x", Color(255, 255, 255, 255))
	title:Dock(TOP)
	title:DockMargin(spacing, 0, 0, spacing)
	Arknights.AutoResizePanel(ui, title)
end

function Arknights.StageMaker.CreateDesc(ui, desc)
	local _, _, title = Arknights.CreateLabel(ui, spacing, spacing, desc, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
	title:Dock(TOP)
	title:DockMargin(spacing, 0, 0, 0)
	Arknights.AutoResizePanel(ui, title)
end

function Arknights.StageMaker.CustomDropDown(ui, x, y, w, h, font, color)
	lastActivePanel = ui
	local panel = Arknights.CreatePanel(nil, x, y, w, h, Color(30, 30, 30, 255))
	panel:MakePopup()
	panel.NextFrame = true
	panel.Exiting = false
	panel.Alpha = 0
	panel.CurrentHeight = 0
	panel:SetZPos(32767)
	panel.TargetHeight = h
	panel.Think = function()
		if(IsValid(ui)) then
			local x, y = ui:LocalToScreen(0, 0)
			panel:SetPos(x, y + ui:GetTall())
		end
		if(panel.Exiting) then
			panel.CurrentHeight = math.Clamp(panel.CurrentHeight - Arknights.GetFixedValue(panel.CurrentHeight * 0.25), 0, panel.TargetHeight)
			if(panel.CurrentHeight <= 5) then
				panel:Remove()
			end
		else
			panel.CurrentHeight = math.Clamp(panel.CurrentHeight + Arknights.GetFixedValue((panel.TargetHeight - panel.CurrentHeight) * 0.25), 0, panel.TargetHeight)
		end
		panel:SetTall(panel.CurrentHeight)
		if(panel.NextFrame) then panel.NextFrame = false return end

		if(!panel:HasFocus()) then
			panel.Exiting = true
		end
	end
	panel.Paint = function()
		draw.RoundedBox(0, 0, 0, panel:GetWide(), panel:GetTall(), Color(30, 30, 30, 255))
	end
	panel.NextY = 0
	panel.Index = 0
	local spacing = AKScreenScaleH(2)
	panel.AddOption = function(text, val, targetval, func)
		local button = Arknights.CreateButton(panel, spacing, panel.NextY, panel:GetWide() - (spacing * 2), h, text, font, Color(255, 255, 255, 255), Color(40, 40, 40, 255), function()
			Arknights.Stage[targetval] = val
			Arknights.SaveLevelData()
			panel.Exiting = true
			func(val)
			Arknights.ButtonClickSound("select")
		end)
		if(panel.Index > 0) then
			panel.TargetHeight = panel.TargetHeight + h + spacing
		end
		panel.Index = panel.Index + 1
		panel.NextY = panel.NextY + button:GetTall() + spacing
	end

	return panel
end

function Arknights.StageMaker.DropdownMenu(ui, settings, values, func)
	local wide = ui:GetWide() - (spacing * 2)
	local val = Arknights.Stage[settings]
	if(val == nil) then return end
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, AKScreenScaleH(14), Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)
		local _, _, label = Arknights.CreateLabel(basepnl, spacing, basepnl:GetTall() * 0.5, val, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
		label.CentVer()
		local btn = Arknights.InvisButton(basepnl, 0, 0, basepnl:GetWide(), basepnl:GetTall(), function()
			local x, y = basepnl:LocalToScreen(0, 0)
			local pnl = Arknights.StageMaker.CustomDropDown(basepnl, x, y, basepnl:GetWide(), basepnl:GetTall(), "Arknights_StageMaker_0.5x", Color(30, 30, 30, 255))
			if(!IsValid(pnl)) then return end
			for k,v in pairs(values) do
				pnl.AddOption(k, v, settings, func)
			end
			Arknights.ButtonClickSound("select")
		end)
		btn.Alpha = 0
		btn.Paint = function()
			label.UpdateText(Arknights.Stage[settings])
			if(btn:IsHovered()) then
				btn.Alpha = math.Clamp(btn.Alpha + Arknights.GetFixedValue(3), 0, 25)
			else
				btn.Alpha = math.Clamp(btn.Alpha - Arknights.GetFixedValue(3), 0, 25)
			end
			draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), Color(255, 255, 255, btn.Alpha))
		end

	Arknights.AutoResizePanel(ui, basepnl)
end

function Arknights.StageMaker.MaterialButton(ui)
	local wide = ui:GetWide() - (spacing * 2)
	local height = AKScreenScaleH(48)
	local innerspacing = AKScreenScaleH(2)
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, height, Color(30, 30, 30, 255))
	basepnl:Dock(TOP)
	local size = height - (innerspacing * 2)
	local materialPreview = Arknights.CreatePanelMat(basepnl, innerspacing, innerspacing, size, size, Arknights.GetCachedMaterial(Arknights.StageMaker.CurrentMaterial), Color(255, 255, 255, 255))
	local _, _, materialLabel = Arknights.CreateLabel(basepnl, size + (innerspacing * 3), basepnl:GetTall() * 0.25, Arknights.StageMaker.CurrentMaterial, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
	materialLabel.CentVer()
	materialPreview.Label = materialLabel
	materialPreview.UpdateMaterial = function(material)
		materialPreview.Label.UpdateText(material)
		materialPreview.mat = Arknights.GetCachedMaterial(material)
	end
	local sidewide = basepnl:GetWide() - (size + (innerspacing * 3))
	local buttonheight = AKScreenScaleH(24)
	local browseButton = Arknights.CreateButton(basepnl, (size + innerspacing * 2), basepnl:GetTall() - (buttonheight + innerspacing), sidewide, buttonheight, "Browse Materials", "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(20, 20, 20, 255), function()
		Arknights.StageMaker.MaterialBrowser(materialPreview)
		Arknights.ButtonClickSound("select")
	end)
	Arknights.AutoResizePanel(ui, basepnl)
end

Arknights.StageMaker.CachedMaterialPaths = Arknights.StageMaker.CachedMaterialPaths || {}
local paths = {
	"arknights/meiryi/level/chernobog",
	"arknights/meiryi/level/lungmen",
}
function Arknights.StageMaker.GetMaterials()
	if(#Arknights.StageMaker.CachedMaterialPaths > 0) then
		return Arknights.StageMaker.CachedMaterialPaths
	end
	local result = {"hunter/myplastic"}
	for _,path in ipairs(paths) do
		local p = "materials/"..path.."/*.vmt"
		if(path == "") then
			p = "materials/*.vmt"
		end
		local fn = file.Find(p, "GAME")
		for k,v in ipairs(fn) do
			local file = string.StripExtension(v)
			local _p = path.."/"..file
			if(path == "") then
				_p = file
			end
			table.insert(result, _p)
		end
	end
	Arknights.StageMaker.CachedMaterialPaths = result
	return Arknights.StageMaker.CachedMaterialPaths
end

function Arknights.StageMaker.CacheMaterial()
	for k,v in pairs(Arknights.StageMaker.CachedMaterialPaths) do
		Arknights.GetCachedVMaterial(v)
	end
end

Arknights.StageMaker.CachedUsableEnemies = Arknights.StageMaker.CachedUsableEnemies || {}
Arknights.StageMaker.HistoryEnemies = {}
function Arknights.StageMaker.CacheEnemies()
	local f = file.Find("lua/entities/enemy_*_*.lua", "GAME")
	for k,v in ipairs(f) do
		local name = string.Replace(v, ".lua", "")
		table.insert(Arknights.StageMaker.CachedUsableEnemies, name)
	end
end

local statsList = {
	{
		name = "HP",
		index = "maxHP",
		dataindex = "maxHp",
	},
	{
		name = "ATK",
		index = "attack",
		dataindex = "atk",
	},
	{
		name = "DEF",
		index = "def",
		dataindex = "def",
	},
	{
		name = "RES",
		index = "magicRes",
		dataindex = "magicResistance",
	},
	{
		name = "Movement Speed",
		index = "moveSpeed",
		dataindex = "moveSpeed",
	},
	{
		name = "ASPD",
		index = "attackSpeed",
		dataindex = "baseAttackTime",
	},
}

local eBrowser = nil
function Arknights.StageMaker.EnemyBrowser(clickfunc)
	if(#Arknights.StageMaker.CachedUsableEnemies <= 0) then
		Arknights.StageMaker.CacheEnemies()
	end
	if(IsValid(eBrowser)) then
		eBrowser.func = clickfunc
		eBrowser:SetVisible(true)
		eBrowser.ui.Alpha = 1
		eBrowser.ui.Exiting = false
		eBrowser:MakePopup()
		return
	end
	local side = 0.125
	local basepnl = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		basepnl:MakePopup()
		basepnl.func = clickfunc
	local ui = Arknights.CreateFrame(basepnl, AKScrW() * side, AKScrH() * side, AKScrW() * (1 - side * 2), AKScrH() * (1 - side * 2), Color(30, 30, 30, 255))
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui.Think = function()
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(20), 0, 255)
				if(ui.Alpha <= 0) then
					basepnl:SetVisible(false)
					return
				end
			else
				ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(20), 0, 255)
			end
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
			ui:SetAlpha(ui.Alpha)
		end
		function basepnl:OnMousePressed()
			ui.Exiting = true
		end
		local margin = AKScreenScaleH(4)
		Arknights.CreateLabelBG(ui, margin, margin, "Enemy Browser", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(66, 194, 245, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/sprite_kill.png"))

		local vertical_margin = AKScreenScaleH(36)
		local dockMargin = AKScreenScaleH(2)
		local scroll = Arknights.CreateScroll(ui, margin, vertical_margin, ui:GetWide() - (margin * 2), ui:GetTall() - (vertical_margin * 2), Color(0, 0, 0, 0))

		local tall = scroll:GetTall() * 0.175
		for k,v in pairs(Arknights.StageMaker.CachedUsableEnemies) do
			local pnl = Arknights.CreatePanel(scroll, 0, 0, scroll:GetWide(), tall, Color(20, 20, 20, 255))
				pnl:Dock(TOP)
				pnl:DockMargin(0, 0, 0, dockMargin)
				local img = Arknights.CreatePanelMat(pnl, 0, 0, tall, tall, Arknights.GetEntityPortraits(v))
				local enemyName = Arknights.GetEnemyName(v)
				local _, _, name = Arknights.CreateLabel(pnl, img:GetWide(), margin, enemyName, "Arknights_EnemyPlacement_1x")
				local tw, th, index = Arknights.CreateLabel(pnl, 0, 0, v, "Arknights_EnemyPlacement_0.5x")
				index:SetPos(pnl:GetWide() - (tw + margin * 2), pnl:GetTall() - (th + margin))

				local lastpnl = nil
				local data = Arknights.EnemyStats[v]
				if(data) then
					for _, dat in ipairs(statsList) do
						local val = Arknights.GetStatsRating(data[1].enemyData.attributes[dat.dataindex].m_value || 0, dat.index)
						local str = dat.name.." : "..val
						if(!lastpnl) then
							local label = Arknights.CreateLabelBG(pnl, margin, margin, str, "Arknights_EnemyPlacement_0.75x", Color(255, 255, 2555, 255), Color(70, 70, 70, 255))
							label:SetPos(img:GetWide() + margin, pnl:GetTall() - (label:GetTall() + margin))
							lastpnl = label
						else
							local n = Arknights.GetGUINextPos(lastpnl)
							local label = Arknights.CreateLabelBG(pnl, n.x + margin, n.y - lastpnl:GetTall(), str, "Arknights_EnemyPlacement_0.75x", Color(255, 255, 2555, 255), Color(70, 70, 70, 255))
							lastpnl = label
						end
					end
				end

				local InvisButton = Arknights.InvisButton(pnl, 0, 0, pnl:GetWide(), pnl:GetTall(), function()
					basepnl.func(v)
					ui.Exiting = true
					Arknights.ButtonClickSound("select")
				end)
				InvisButton.Alpha = 0
				InvisButton.Paint = function()
					if(InvisButton:IsHovered()) then
						InvisButton.Alpha = math.Clamp(InvisButton.Alpha + Arknights.GetFixedValue(3), 0, 25)
					else
						InvisButton.Alpha = math.Clamp(InvisButton.Alpha - Arknights.GetFixedValue(3), 0, 25)
					end
					draw.RoundedBox(0, 0, 0, InvisButton:GetWide(), InvisButton:GetTall(), Color(255, 255, 255, InvisButton.Alpha))
				end
		end

		local size = AKScreenScaleH(14)
		Arknights.CreateMatButton(ui, ui:GetWide() - (size + margin), margin, size, size, Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)

	basepnl.ui = ui
	eBrowser = basepnl
end

function Arknights.StageMaker.CalculateStageMaxTime()
	local t = 0
	for k,v in ipairs(Arknights.Stage.Enemies) do
		if(v.time > t) then
			t = v.time
		end
	end
	Arknights.Stage.MaxTime = t
end


function Arknights.StageMaker.EnemyUpdated()

end

local viewAlpha = 75
function Arknights.StageMaker.EnemyList()
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui:MakePopup()

		local margin = AKScreenScaleH(8)
		local textmargin = AKScreenScaleH(6)
		local dockmargin = AKScreenScaleH(2)
		local vertical_margin = AKScrH() * 0.2
		local horizontal_margin = AKScrW() * 0.2
		local inner = Arknights.CreatePanelMat(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"),Color(50, 50, 50, 255))

		local label = Arknights.CreateLabelBG(inner, margin, margin, "Enemy List", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(66, 194, 245, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/sprite_kill.png"))

		local upMargin = label:GetY() + label:GetTall()
		local scroll = Arknights.CreateScroll(inner, margin, upMargin + margin, inner:GetWide() - margin * 2, inner:GetTall() - (margin * 2 + upMargin), Color(20, 20, 20, 125))
		local list = {}
		local vec = {x = 0, y = 0}
		local renderPath = nil
		local dropdown = nil
		local btnSize = AKScreenScaleH(16)

		local c1, c2 = Color(100, 100, 100, 255), Color(40, 40, 40, 255)
		local hoveredfunc = function(self)
			if(self:IsHovered()) then
				self.bgcolor = c1
			else
				self.bgcolor = c2
			end
		end

		scroll.UpdateList = function()
			list = {}
			scroll:Clear()
			for index, enemy in ipairs(Arknights.Stage.Enemies) do
				enemy.index = index
				table.insert(list, enemy)
			end
			table.sort(list, function(a, b) return a.time < b.time end)
			
			for _, enemy in ipairs(list) do
				local pnl = Arknights.CreatePanel(scroll, 0, 0, scroll:GetWide(), scroll:GetTall() * 0.15, Color(20, 20, 20, 255))
					pnl:Dock(TOP)
					pnl:DockMargin(0, 0, 0, dockmargin)
					local portraits = Arknights.CreatePanelMat(pnl, 0, 0, pnl:GetTall(), pnl:GetTall(), Arknights.GetEntityPortraits(enemy.id))
					local nick = Arknights.CreateLabelBG(pnl, dockmargin + portraits:GetWide(), dockmargin, Arknights.GetEnemyName(enemy.id), "Arknights_EnemyPlacement_1x", Color(255, 255, 2555, 255), Color(40, 40, 40, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/icon_input.png"))
					local label = Arknights.CreateLabelBG(pnl, nick:GetX(), 0, "Spawn after "..enemy.time.." seconds", "Arknights_EnemyPlacement_0.75x", Color(255, 255, 2555, 255), Color(40, 40, 40, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/icon_input.png"))
					label:SetY(pnl:GetTall() - (dockmargin + label:GetTall()))
					local label2 = Arknights.CreateLabelBG(pnl, Arknights.GetGUINextPos(label).x + textmargin, label:GetY(), "Path : "..enemy.path, "Arknights_EnemyPlacement_0.75x", Color(255, 255, 255, 255), Color(40, 40, 40, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/icon_input.png"))
					local delete = Arknights.CreateMatButton(pnl, pnl:GetWide() - (btnSize + margin), pnl:GetTall() * 0.5 - btnSize * 0.5, btnSize, btnSize, Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), function()
						table.remove(Arknights.Stage.Enemies, enemy.index)
						scroll.UpdateList()
						Arknights.StageMaker.CalculateStageMaxTime()
						Arknights.SaveLevelData()
						Arknights.ButtonClickSound("select")
					end)

					function nick:OnMousePressed()
						Arknights.StageMaker.EnemyBrowser(function(ret)
							Arknights.Stage.Enemies[enemy.index].id = ret
							scroll.UpdateList()
							Arknights.SaveLevelData()
						end)
						Arknights.ButtonClickSound("select")
					end
					function label:OnMousePressed()
						Arknights.PopupTextEntryMenu({
							t1 = "Spawn Time",
							t2 = "Time for enemy to spawn",
							ptext = "Any number",
							t1color = Color(130, 130, 130, 255),
							t2color = Color(255, 220, 0, 255),
							tcolor = Color(0, 0, 0, 255),
							condfunc = function(text)
								local num = tonumber(text)
								if(!num) then
									Arknights.PopupNotify("Invalid number")
									return
								end
								if(num < 0) then
									Arknights.PopupNotify("Number must be greater than 0")
									return
								end
								return true
							end,
							passfunc = function(text)
								local num = tonumber(text)
								Arknights.Stage.Enemies[enemy.index].time = num
								Arknights.StageMaker.CalculateStageMaxTime()
								Arknights.SaveLevelData()
								scroll.UpdateList()
							end
						})
						Arknights.ButtonClickSound("select")
					end
					function label2:OnMousePressed()
						vec = enemy.pos
						local x, y = pnl:LocalToScreen(0, 0)
						dropdown = Arknights.PathDropdown(pnl, x, y, pnl:GetWide(), AKScreenScaleH(128), function(ret)
							Arknights.Stage.Enemies[enemy.index].path = ret
						end)
						Arknights.ButtonClickSound("select")
					end
					pnl.Think = function()
						if(pnl.CurrentSelectedNode) then
							renderPath = pnl.CurrentSelectedNode
							pnl.CurrentSelectedNode = nil
						end
					end
					nick.Think = hoveredfunc
					label.Think = hoveredfunc
					label2.Think = function()
						if(label2:IsHovered()) then
							renderPath = enemy.path
						end
						hoveredfunc(label2)
					end
			end
		end

		scroll.Think = function()
			if(!scroll.Reload) then return end
			scroll.UpdateList()
			scroll.Reload = true
		end
		scroll.UpdateList()

		function ui:OnMousePressed()
			ui.Exiting = true
		end

		ui.Paint = function()
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(15), 0, 255)
				if(ui.Alpha <= 0) then
					ui:Remove()
					return
				end
			else
				if(renderPath) then
					ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue((viewAlpha - ui.Alpha) * 0.2), 0, 255)
				else
					ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(15), 0, 255)
				end
			end
			ui:SetAlpha(ui.Alpha)
			local valid = IsValid(dropdown)
			if(renderPath) then
				cam.Start3D()
					if(valid) then
						dropdown:SetAlpha(ui.Alpha)
						Arknights.RenderPathNode(renderPath, false, vec)
					else
						Arknights.RenderPathNode(renderPath, true)
					end
				cam.End3D()
			end
			renderPath = nil
		end
end

function Arknights.StageMaker.CreateEnemyPreview(ui, autosize)
	local wide = ui:GetWide() - (spacing * 2)
	local height = AKScreenScaleH(48)
	local innerspacing = AKScreenScaleH(2)
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, height, Color(30, 30, 30, 255))

	local size = basepnl:GetTall() - (innerspacing * 2)
	local image = Arknights.CreatePanelMat(basepnl, innerspacing, innerspacing, size, size, Arknights.GetEntityPortraits(Arknights.StageMaker.SelectedEnemy))
	local _, _, name = Arknights.CreateLabel(basepnl, image:GetX() + image:GetWide() + innerspacing, innerspacing, Arknights.GetEnemyName(Arknights.StageMaker.SelectedEnemy), "Arknights_EnemyPlacement_2x")
	image.Think = function()
		image.mat = Arknights.GetEntityPortraits(Arknights.StageMaker.SelectedEnemy)
		name.UpdateText(Arknights.GetEnemyName(Arknights.StageMaker.SelectedEnemy))
	end

	local buttonheight = basepnl:GetTall() - (name:GetTall() + (innerspacing * 2))
	local x = size + innerspacing * 2
	local browseButton = Arknights.CreateButton(basepnl, x, basepnl:GetTall() - (buttonheight + innerspacing), basepnl:GetWide() - (size + innerspacing * 3), buttonheight, "Browse Enemies", "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(20, 20, 20, 255), function()
		Arknights.StageMaker.EnemyBrowser(function(ret)
			Arknights.StageMaker.SelectedEnemy = ret
		end)
		Arknights.ButtonClickSound("select")
	end)

	return basepnl
end

local selectedAlpha = 30
local lerpMul = 0.2
function Arknights.PathDropdown(parent, x, y, w, h, func)
	local elemHeight = AKScreenScaleH(24)
	local margin = AKScreenScaleH(4)
	local popup = Arknights.CreateFrame(nil, x, y, w, 0, Color(30, 30, 30, 255))
	local textentry = Arknights.CreateTextEntry(popup, margin, margin, w - (margin * 2), elemHeight - (margin * 2), "Search by name", "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(105, 105, 105, 255), Color(25, 25, 25, 255))
	popup:MakePopup()
	popup.NextFrame = true
	popup.Exiting = false
	popup.Alpha = 0
	popup.CurrentHeight = 0
	popup.Think = function()
		if(popup.NextFrame) then
			popup.NextFrame = false
			return
		end
		if(!popup:HasFocus() && !textentry:HasFocus()) then
			popup:Remove()
		end
		if(popup.Exiting) then
			popup.Alpha = math.Clamp(popup.Alpha - Arknights.GetFixedValue(15), 0, 255)
			popup.CurrentHeight = math.Clamp(popup.CurrentHeight - Arknights.GetFixedValue(popup.CurrentHeight * 0.33), 0, h)

			if(popup.Alpha <= 0) then
				popup:Remove()
			end
		else
			if(parent.CurrentSelectedNode) then
				popup.Alpha = math.Clamp(popup.Alpha + Arknights.GetFixedValue((selectedAlpha - popup.Alpha) * lerpMul), 0, 255)
			else
				popup.Alpha = math.Clamp(popup.Alpha + Arknights.GetFixedValue(15), 0, 255)
			end
			popup.CurrentHeight = math.Clamp(popup.CurrentHeight + Arknights.GetFixedValue((h - popup.CurrentHeight) * 0.33), 0, h)
		end
		popup:SetTall(popup.CurrentHeight)
		popup:SetAlpha(popup.Alpha)
	end
	popup.Paint = function()
		draw.RoundedBox(0, 0, 0, popup:GetWide(), popup:GetTall(), Color(30, 30, 30, 255))
	end
	local scroll = Arknights.CreateScroll(popup, margin, margin + elemHeight, w - (margin * 2), h - (margin * 2 + elemHeight), Color(25, 25, 25, 255))
	local idSet = false
	for k,v in pairs(Arknights.Stage.Paths) do
		local connections = #v
		local pnl = Arknights.CreatePanel(scroll, 0, 0, scroll:GetWide(), elemHeight, Color(15, 15, 15, 255))
			pnl:Dock(TOP)
			pnl:DockMargin(0, 0, 0, margin)
			local _, _, t = Arknights.CreateLabel(pnl, pnl:GetWide() * 0.5, pnl:GetTall() * 0.5, k.." ["..connections.." Connections]", "Arknights_StageMaker_1x", Color(255, 255, 255, 255))
			t.CentPos()
			local btn = Arknights.InvisButton(pnl, 0, 0, pnl:GetWide(), pnl:GetTall(), function()
				func(k)
				popup.Exiting = true
				Arknights.ButtonClickSound("select")
			end)
			btn.Alpha = 0
			btn.Paint = function()
				if(btn:IsHovered()) then
					parent.CurrentSelectedNode = k
					idSet = true
					btn.Alpha = math.Clamp(btn.Alpha + Arknights.GetFixedValue(3), 0, 25)
				else
					btn.Alpha = math.Clamp(btn.Alpha - Arknights.GetFixedValue(3), 0, 25)
				end
				draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), Color(255, 255, 255, btn.Alpha))
			end

		pnl.SortString = k
		scroll.AddPanel(pnl)
	end

	textentry.OnChange = function()
		local val = textentry:GetValue()
		scroll.FiltePanels(val)
	end
	textentry.Think = function()
		if(!idSet) then
			parent.CurrentSelectedNode = nil
		end
		idSet = false
	end

	return popup
end

function Arknights.CreatePathSelector(ui, autosize)
	local wide = ui:GetWide() - (spacing * 2)
	local height = AKScreenScaleH(24)
	local innerspacing = AKScreenScaleH(2)
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, height, Color(30, 30, 30, 255))
	local dropdown = nil
	local btn = Arknights.InvisButton(basepnl, 0, 0, basepnl:GetWide(), basepnl:GetTall(), function()
		local x, y = basepnl:LocalToScreen(0, 0)
		dropdown = Arknights.PathDropdown(basepnl, x, y, basepnl:GetWide(), AKScreenScaleH(200), function(ret)
			Arknights.StageMaker.SelectedEnemyPath = ret
		end)
		Arknights.ButtonClickSound("select")
	end)
	basepnl.top = btn
	btn.Think = function()
		if(!IsValid(dropdown)) then
			basepnl.CurrentSelectedNode = nil
		end
	end
	local _, _, t = Arknights.CreateLabel(basepnl, basepnl:GetWide() * 0.5, basepnl:GetTall() * 0.5, "NULL", "Arknights_StageMaker_1x", Color(255, 255, 255, 255))
	t.CentPos()
	basepnl.PathText = t
	if(autosize) then
		Arknights.AutoResizePanel(basepnl, basepnl)
	end
	return basepnl
end

function Arknights.StageMaker.EnemyPlacementPopup()
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		ui.BlurPasses = 0
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui:MakePopup() -- So DTextEntry can receive inputs

		local iconoffs = AKScreenScaleH(2)
		local offs = AKScreenScaleH(4)
		local vertical_margin = AKScrH() * 0.25
		local horizontal_margin = AKScrW() * 0.2
		local inner = Arknights.CreatePanelMat(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"),Color(50, 50, 50, 255))
		local text_margin = AKScreenScaleH(8)
		local text1 = Arknights.CreateLabelBG(inner, text_margin, text_margin, "New Enemy", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(130, 130, 130, 255), nil)
		Arknights.CreateLabelBG(inner, Arknights.GetGUINextPos(text1).x, text_margin, "Enemy Placement", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(255, 220, 0, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/sprite_kill.png"))

		local _, _, t = Arknights.CreateLabel(inner, text_margin, inner:GetTall() * 0.125, "Enemy type", "Arknights_EnemyPlacement_1x", Color(220, 220, 220, 255))
		local enemyPreview = Arknights.StageMaker.CreateEnemyPreview(inner)
		enemyPreview:SetY(t:GetY() + t:GetTall() + offs)
		local _, _, t = Arknights.CreateLabel(inner, text_margin, enemyPreview:GetY() + enemyPreview:GetTall() + offs, "Path for enemy", "Arknights_EnemyPlacement_1x", Color(220, 220, 220, 255))
		local selector = Arknights.CreatePathSelector(inner, autosize)
		selector:SetY(t:GetY() + t:GetTall() + offs)
		local _, _, t = Arknights.CreateLabel(inner, text_margin, selector:GetY() + selector:GetTall() + offs, "Time to spawn", "Arknights_EnemyPlacement_1x", Color(220, 220, 220, 255))
		local time = Arknights.CreateTextEntry(inner, text_margin, t:GetY() + t:GetTall(), inner:GetWide() - (text_margin * 2), AKScreenScaleH(24), "Any time", "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(105, 105, 105, 255), Color(25, 25, 25, 255))
		time:SetValue(Arknights.StageMaker.SelectedEnemySpawnTime)
		function time:OnChange()
			local val = tonumber(time:GetValue()) || 0
			Arknights.StageMaker.SelectedEnemySpawnTime = val
		end
		ui.Think = function()
			selector.PathText.UpdateText(Arknights.StageMaker.SelectedEnemyPath || "NULL")
			selector.PathText.CentPos()
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(25), 0, 255)
				if(ui.Alpha <= 0) then
					ui:Remove()
				end
			else
				if(selector.CurrentSelectedNode) then
					ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue((selectedAlpha - ui.Alpha) * lerpMul), 0, 255)
				else
					ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(25), 0, 255)
				end
			end
			ui:SetAlpha(ui.Alpha1 || ui.Alpha)
			Arknights.StageMaker.StopClickTime = SysTime() + 0.15
		end

		ui.Paint = function()
			if(selector.top:IsHovered()) then
				if(Arknights.Stage.Paths[Arknights.StageMaker.SelectedEnemyPath]) then
					selector.CurrentSelectedNode = Arknights.StageMaker.SelectedEnemyPath
				end
			end
			local node = selector.CurrentSelectedNode
			if(!node) then return end
			surface.SetAlphaMultiplier(1)
			cam.Start3D()
				Arknights.RenderPathNode(node)
			cam.End3D()
			surface.SetAlphaMultiplier(ui.Alpha / 255)
		end

		local buttonWidth, buttonHeight = inner:GetWide() * 0.5, AKScreenScaleH(28)
		local cancel_button = Arknights.CreateMatButtonTextIcon(ui, inner:GetX(), inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_cancel_bkg.png"), "Cancel", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		local confirmbutton = Arknights.CreateMatButtonTextIcon(ui, inner:GetX() + inner:GetWide() * 0.5, inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_confirm_blue_bkg.png"), "Confirm", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_confirm.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			local val = tonumber(time:GetValue())
			local name = Arknights.GetEnemyName(Arknights.StageMaker.SelectedEnemy)
			if(name == "NULL") then
				Arknights.PopupNotify("Invalid enemy data")
				return
			end
			if(!Arknights.Stage.Paths[Arknights.StageMaker.SelectedEnemyPath]) then
				Arknights.PopupNotify("Invalid path")
				return
			end
			if(!val || val < 0) then
				Arknights.PopupNotify("Spawn time needs to be an number and greater than zero!")
				return
			end
			table.insert(Arknights.Stage.Enemies, {
				time = val,
				id = Arknights.StageMaker.SelectedEnemy,
				pos = table.Copy(Arknights.StageMaker.SelectedEnemyPosition),
				path = Arknights.StageMaker.SelectedEnemyPath,
			})
			Arknights.StageMaker.CalculateStageMaxTime()
			Arknights.SaveLevelData()
			ui.Exiting = true
		end)
		ui.InnerPanel = inner
end

Arknights.StageMaker.MaterialBrowserPanel = Arknights.StageMaker.MaterialBrowserPanel || nil
function Arknights.StageMaker.MaterialBrowser(baseui)
	if(IsValid(Arknights.StageMaker.MaterialBrowserPanel)) then
		Arknights.StageMaker.MaterialBrowserPanel:Remove()
	end
	local side = 0.125
	local basepnl = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		basepnl:MakePopup()
	local ui = Arknights.CreateFrame(basepnl, AKScrW() * side, AKScrH() * side, AKScrW() * (1 - side * 2), AKScrH() * (1 - side * 2), Color(30, 30, 30, 255))
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui.Think = function()
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(20), 0, 255)
				if(ui.Alpha <= 0) then
					basepnl:Remove()
					return
				end
			else
				ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(20), 0, 255)
			end
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
			ui:SetAlpha(ui.Alpha)
		end
		function basepnl:OnMousePressed()
			ui.Exiting = true
		end
		local margin = AKScreenScaleH(4)
		Arknights.CreateLabelBG(ui, margin, margin, "Material Browser", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(66, 194, 245, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/icon_cg_normal.png"))
		local size = AKScreenScaleH(14)
		Arknights.CreateMatButton(ui, ui:GetWide() - (size + margin), margin, size, size, Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		local sx = (size + margin * 2)
		local bottom_height = AKScreenScaleH(48)
		local lower = Arknights.CreateScroll(ui, 0, sx, ui:GetWide(), ui:GetTall() - (sx + bottom_height), Color(25, 25, 25, 0))
		local path = Arknights.StageMaker.GetMaterials()
		local textTall = AKScreenScaleH(16)
		local gap = AKScreenScaleH(2)
		local wide, tall = (ui:GetWide() / 8) - (gap), (ui:GetTall() / 5) + textTall
		local maxelem = 7
		local currentelem = 1
		local currenty = 0
		local function MaterialPreview(path)
			local mat = Arknights.GetCachedVMaterial(path)
			if(!mat:GetTexture("$basetexture")) then
				return
			end
			local base = Arknights.CreatePanel(lower, (currentelem * wide) + ((currentelem - 1) * gap), currenty * tall, wide, tall, Color(40, 40, 40, 255))
			local img = Arknights.CreatePanelMat(base, 0, 0, wide, wide, mat, Color(255, 255, 255, 255))
			local label = Arknights.CreateLabel(base, gap, base:GetWide(), path, "Arknights_StageMaker_0.35x", Color(255, 255, 255, 255))
			local invis = Arknights.InvisButton(base, 0, 0, base:GetWide(), base:GetTall(), function()
				Arknights.StageMaker.CurrentMaterial = path
				baseui.UpdateMaterial(path)
				ui.Exiting = true
				Arknights.ButtonClickSound("select")
			end)

			currentelem = currentelem + 1
			if(currentelem > maxelem) then
				currentelem = 0
				currenty = currenty + 1
			end
		end
		for k,v in pairs(path) do
			MaterialPreview(v)
		end
	Arknights.StageMaker.MaterialBrowserPanel = basepnl
end

function Arknights.StageMaker.CreatePopupButton(ui, settings, texts, funcs)
	local wide = ui:GetWide() - (spacing * 2)
	local val = Arknights.Stage[settings]
	if(val == nil) then return end
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, AKScreenScaleH(14), Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)
		local _, _, label = Arknights.CreateLabel(basepnl, spacing, basepnl:GetTall() * 0.5, val, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
		label.CentVer()
		local btn = Arknights.InvisButton(basepnl, 0, 0, basepnl:GetWide(), basepnl:GetTall(), function()
			Arknights.PopupTextEntryMenu({
				t1 = texts.t1,
				t2 = texts.t2,
				ptext = texts.t3,
				
				t1color = Color(130, 130, 130, 255),
				t2color = Color(255, 220, 0, 255),
				tcolor = Color(0, 0, 0, 255),
				condfunc = funcs.condfunc,
				passfunc = funcs.passfunc,
			})
			Arknights.ButtonClickSound("select")
		end)
		basepnl.Think = function()
			label.UpdateText(Arknights.Stage[settings])
		end
	Arknights.AutoResizePanel(ui, basepnl)
end

function Arknights.StageMaker.CreatePopupButtonStageSize(ui, settings, funcs)
	local wide = ui:GetWide() - (spacing * 2)
	local val = Arknights.Stage.Size[settings]
	if(val == nil) then return end
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, AKScreenScaleH(14), Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)
		local _, _, label = Arknights.CreateLabel(basepnl, spacing, basepnl:GetTall() * 0.5, val, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
		label.CentVer()
		local btn = Arknights.InvisButton(basepnl, 0, 0, basepnl:GetWide(), basepnl:GetTall(), function()
			Arknights.PopupTextEntryMenu({
				t1 = "Level Size",
				t2 = "Size for the level (Numbers only)",
				ptext = "Size for the level",
				t1color = Color(130, 130, 130, 255),
				t2color = Color(255, 220, 0, 255),
				tcolor = Color(0, 0, 0, 255),
				condfunc = funcs.condfunc,
				passfunc = funcs.passfunc,
			})
			Arknights.ButtonClickSound("select")
		end)
		basepnl.Think = function()
			label.UpdateText(Arknights.Stage.Size[settings])
		end
	Arknights.AutoResizePanel(ui, basepnl)
end

function Arknights.StageMaker.CreateVariableSwitch(ui, settings, var)
	local val = Arknights.StageMaker[settings]
	local count = table.Count(var)
	local vertical_margin = AKScreenScaleH(4)
	local horizontal_margin = AKScreenScaleH(4)
	local elemheight = AKScreenScaleH(18)
	local spacing = AKScreenScaleH(2)
	local wide = ui:GetWide() - spacing * 2
	local height = vertical_margin * 2 + ((count - 1) * spacing) + (count * elemheight)
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, height, Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)
		local startY = vertical_margin
		local w, h = basepnl:GetWide() - (horizontal_margin * 2), elemheight
		for k,v in pairs(var) do
			local btn_base = Arknights.CreatePanel(basepnl, horizontal_margin, startY, w, h, Color(20, 20, 20, 255))
			local _, _, label = Arknights.CreateLabel(btn_base, w * 0.5, h * 0.5, k, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
			label.CentPos()

			btn_base.Alpha = 0
			btn_base.oPaint = btn_base.Paint
			btn_base.Paint = function()
				btn_base:oPaint()
				local val = Arknights.StageMaker[settings]
				if(val == v) then
					btn_base.Alpha = math.Clamp(btn_base.Alpha + Arknights.GetFixedValue(3), 0, 25)
				else
					btn_base.Alpha = math.Clamp(btn_base.Alpha - Arknights.GetFixedValue(3), 0, 25)
				end
				draw.RoundedBox(0, 0, 0, btn_base:GetWide(), btn_base:GetTall(), Color(255, 255, 255, btn_base.Alpha))
			end
			local btn = Arknights.InvisButton(btn_base, 0, 0, btn_base:GetWide(), btn_base:GetTall(), function()
				Arknights.StageMaker[settings] = v
				Arknights.ButtonClickSound("select")
			end)
			startY = startY + elemheight + spacing
		end

	Arknights.AutoResizePanel(ui, basepnl)
end

function Arknights.StageMaker.CreateButton(ui, text, func)
	local basepnl = Arknights.CreatePanel(ui, 0, 0, ui:GetWide() - (spacing * 2), AKScreenScaleH(24), Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)
		local _, _, label = Arknights.CreateLabel(basepnl, basepnl:GetWide() * 0.5, basepnl:GetTall() * 0.5, text, "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
		label.CentPos()
		local btn = Arknights.InvisButton(basepnl, 0, 0, basepnl:GetWide(), basepnl:GetTall(), function()
			func()
			Arknights.ButtonClickSound("select")
		end)

	Arknights.AutoResizePanel(ui, basepnl)
end

Arknights.ReloadPathList = false
function Arknights.CreatePathList(ui)
	local wide = ui:GetWide() - (spacing * 2)
	local basepnl = Arknights.CreateScroll(ui, spacing, 0, wide, AKScreenScaleH(150), Color(30, 30, 30, 255))
		basepnl:Dock(TOP)
		basepnl:DockMargin(spacing, 0, 0, spacing)

		basepnl.ReloadTime = 0
		basepnl.ReloadList = function()
			basepnl:Clear()
			local paths = Arknights.Stage.Paths
			for k,v in pairs(paths) do
				local pathpnl = Arknights.CreatePanel(basepnl, 0, 0, basepnl:GetWide(), AKScreenScaleH(24), Color(20, 20, 20, 255))
					pathpnl:Dock(TOP)
					pathpnl:DockMargin(0, 0, 0, spacing)
					local _, _, label = Arknights.CreateLabel(pathpnl, spacing, pathpnl:GetTall() * 0.5, k.." ["..#v.." Connections]", "Arknights_StageMaker_0.5x", Color(255, 255, 255, 255))
					label.CentVer()
					local btn = Arknights.InvisButton(pathpnl, 0, 0, pathpnl:GetWide(), pathpnl:GetTall(), function()
						if(Arknights.StageMaker.SelectedPathNode == k) then
							Arknights.StageMaker.SelectedPathNode = nil
						else
							Arknights.StageMaker.SelectedPathNode = k
						end
						Arknights.ButtonClickSound("select")
					end)
					btn.Alpha = 0
					btn.Paint = function()
						if(btn:IsHovered() || Arknights.StageMaker.SelectedPathNode == k) then
							if(Arknights.StageMaker.SelectedPathNode == k) then
								btn.Alpha = math.Clamp(btn.Alpha + Arknights.GetFixedValue(3), 0, 25)
							else
								btn.Alpha = math.Clamp(btn.Alpha + Arknights.GetFixedValue(1), 0, 7)
							end
						else
							btn.Alpha = math.Clamp(btn.Alpha - Arknights.GetFixedValue(3), 0, 25)
						end
						draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), Color(255, 255, 255, btn.Alpha))
					end
			end
		end
		basepnl.Think = function()
			if(!Arknights.ReloadPathList) then return end
			basepnl.ReloadList()
			Arknights.ReloadPathList = false
		end
		basepnl.ReloadList()
	Arknights.AutoResizePanel(ui, basepnl)
end

local outofrange = function(val)
	return (val >= 4 && val <= 24)
end

Arknights.StageMaker.ToolTabs = {
	{
		title = "Level Settings",
		func = function(ui)
			Arknights.StageMaker.CreateDesc(ui, "Level Name")
			Arknights.StageMaker.CreatePopupButton(ui, "MapName",
			{
				t1 = "Map Name",
				t2 = "New map name",
				t3 = "Any text",
			},
			{
				condfunc = function(text)
					if(!text || #text <= 0) then
						Arknights.PopupNotify("You need to enter atleast 1 character!")
						return false
					end
					return true
				end,
				passfunc = function(text)
					Arknights.Stage.MapName = text
					Arknights.SaveLevelData()
				end
			})
			Arknights.StageMaker.CreateDesc(ui, "Level Music")
			Arknights.StageMaker.DropdownMenu(ui, "Music", Arknights.StageMaker.MusicID, function(val)
				Arknights.IdealMusic = val
			end)
			Arknights.StageMaker.CreateDesc(ui, "Level Background")
			Arknights.StageMaker.DropdownMenu(ui, "Background", Arknights.StageMaker.BackgroundID, function(val)
				Arknights.Stage.Background = val
			end)
			Arknights.StageMaker.CreateDesc(ui, "Level Width")
			Arknights.StageMaker.CreatePopupButtonStageSize(ui, "h", {
				condfunc = function(text)
					local value = tonumber(text)
					if(!value) then
						Arknights.PopupNotify("You need to enter a number!")
						return
					end
					if(!outofrange(value)) then
						Arknights.PopupNotify("Value is out of range! (4-24)")
						return
					end
					return true
				end,
				passfunc = function(text)
					local val = tonumber(text)
					Arknights.Stage.Size.h = val
					Arknights.CalculateScreenPosition(true)
					Arknights.RemoveOutOfBoundsStructure()
					Arknights.RebuildStageMeshes()
					Arknights.RebuildSpawnModelEntities()
					Arknights.SaveLevelData()
				end,
			})
			Arknights.StageMaker.CreateDesc(ui, "Level Height")
			Arknights.StageMaker.CreatePopupButtonStageSize(ui, "w", {
				condfunc = function(text)
					local value = tonumber(text)
					if(!value) then
						Arknights.PopupNotify("You need to enter a number!")
						return
					end
					if(!outofrange(value)) then
						Arknights.PopupNotify("Value is out of range! (4-24)")
						return
					end
					return true
				end,
				passfunc = function(text)
					local val = tonumber(text)
					Arknights.Stage.Size.w = val
					Arknights.CalculateScreenPosition(true)
					Arknights.RemoveOutOfBoundsStructure()
					Arknights.RebuildStageMeshes()
					Arknights.RebuildSpawnModelEntities()
					Arknights.SaveLevelData()
				end,
			})
		end,
	},
	{
		title = "Mapping",
		func = function(ui)
			--[[
					Types of structures:
						ground = Ground tile
						ranged = High ground tile
						wall = Wall tile
						kill = Kill tile
			]]
			Arknights.StageMaker.CreateDesc(ui, "Tile Type")
			Arknights.StageMaker.CreateVariableSwitch(ui, "BlockType", {
				["High Ground Tile (Undeplayable)"] = "wall",
				["Ground Tile (Undeplayable)"] = "ground2",
				["High Ground Tile"] = "ranged",
				["Ground Tile"] = "ground",
				["Defend Point"] = "homebase",
				["Enemy Base"] = "enemybase_ground",
				["Enemy Base (Air)"] = "enemybase_air",
			})
		end,
	},
	{
		title = "Texturing",
		func = function(ui)
			Arknights.StageMaker.CreateDesc(ui, "Materials")
			Arknights.StageMaker.MaterialButton(ui)
			Arknights.StageMaker.CreateDesc(ui, "Texturing Mode")
			Arknights.StageMaker.CreateVariableSwitch(ui, "TexturingMode", {
				["Top"] = 1,
				["Side"] = 2,
			})
		end,
	},
	{
		title = "Enemies",
		func = function(ui)
			Arknights.StageMaker.CreateButton(ui, "Enemy List", function()
				Arknights.StageMaker.EnemyList()
			end)
		end,
	},
	{
		title = "Node Path",
		func = function(ui)
			Arknights.StageMaker.CreateDesc(ui, "Edit Mode")
			Arknights.StageMaker.CreateVariableSwitch(ui, "NodeEditMode", {
				["Create / Remove"] = 0,
				["Adjust Timer"] = 1,
			})
			Arknights.StageMaker.CreateDesc(ui, "Paths")
			Arknights.CreatePathList(ui)
		end,
	},
	{
		title = "Editor Settings",
		func = function(ui)

		end,
	},
}

function Arknights.ToggleGameFrame(vis)
	if(!IsValid(Arknights.GameFrame)) then return end
	Arknights.GameFrame.BasePanel:SetVisible(vis)
end

function Arknights.CreateStageUI()
	if(IsValid(Arknights.Stage.BasePanel)) then
		Arknights.Stage.BasePanel:Remove()
	end
	Arknights.IdealMusic = Arknights.Stage.Music
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	ui:MakePopup()

	local out = true
	local panelHovered = false
	local indicatedPath = {}
	if(Arknights.Stage.Editmode) then
		Arknights.StageMaker.SelectedMode = 1
		Arknights.StageMaker.TexturingMode = 1
		Arknights.StageMaker.SelectedPathNode = nil
		Arknights.StageMaker.SelectedNode = nil
		Arknights.StageMaker.NodeEditMode = 0
		Arknights.StageMaker.HistoryEnemies = {}
		Arknights.StageMaker.SelectedEnemy = "NULL"
		Arknights.StageMaker.SelectedEnemyPath = "NULL"
		Arknights.StageMaker.SelectedEnemyPosition = {x = 0, y = 0}

		local wide = AKScrW() * 0.2
		local origin = AKScrW() - wide
		local currentPos = origin
		local properties = Arknights.CreateScroll(ui, origin, 0, wide, AKScrH(), Color(40, 40, 40, 200))
		local buttonSize = AKScreenScaleH(32)
		properties.HideButton = Arknights.CreateMatButtonScale(ui, properties:GetX() - buttonSize, 0, buttonSize, buttonSize, Arknights.GetCachedMaterial("arknights/meiryi/arts/button/in.png"), 0.5, Color(40, 40, 40, 205), function()
			out = !out
			if(!out) then
				properties.HideButton.mat = Arknights.GetCachedMaterial("arknights/meiryi/arts/button/out.png")
			else
				properties.HideButton.mat = Arknights.GetCachedMaterial("arknights/meiryi/arts/button/in.png")
			end
			Arknights.ButtonClickSound("select")
		end)
		properties.HideButton.Think = function()
			properties.HideButton:SetX(properties:GetX() - buttonSize)
		end
		properties.Think = function()
			local x, y = input.GetCursorPos()
			panelHovered = x >= properties:GetX()
			local currentX = properties:GetX()
			if(out) then
				currentPos = (math.Clamp(currentPos - Arknights.GetFixedValue((currentPos - origin) * 0.15), origin, AKScrW()))
			else
				currentPos = (math.Clamp(currentPos + Arknights.GetFixedValue((AKScrW() - currentPos) * 0.15), origin, AKScrW()))
			end
			properties:SetPos(currentPos)
		end
		local buttonHeight = AKScrH() * 0.06
		local dockmargin = AKScreenScaleH(2)
		for k,v in ipairs(Arknights.StageMaker.ToolTabs) do
			local panel = Arknights.CreateButton(properties, 0, 0, properties:GetWide(), buttonHeight, v.title, "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(40, 40, 40, 255))
			panel:Dock(TOP)
			panel:DockMargin(0, 0, 0, dockmargin)
			panel.Extend = false
			if(k == 1) then
				panel.Extend = true
			end
			local lerptime = 0.125
			local extendTime = SysTime() + lerptime
			local hideTime = SysTime()
			panel.SubPanel = Arknights.CreatePanel(properties, 0, 0, properties:GetWide(), 0, Color(0, 0, 0, 0))
			panel.SubPanel.Height = 0
			panel.SubPanel.CurrentHeight = panel.SubPanel.Height
			panel.SubPanel:Dock(TOP)

			panel.DoClick = function()
				if(!panel.Extend) then
					panel.Extend = true
					extendTime = SysTime() + lerptime
				else
					panel.Extend = false
					hideTime = SysTime() + lerptime
				end
				Arknights.ButtonClickSound("detail")
			end

			panel.Think = function()
				if(panel.Extend) then
					panel.SubPanel.CurrentHeight = panel.SubPanel.Height * (1 - math.Clamp((extendTime - SysTime()) / lerptime, 0, 1))
				else
					panel.SubPanel.CurrentHeight = panel.SubPanel.Height * math.Clamp((hideTime - SysTime()) / lerptime, 0, 1)
				end
				panel.SubPanel:SetHeight(panel.SubPanel.CurrentHeight)
				panel.SubPanel:SetVisible(panel.SubPanel.CurrentHeight > 0)
			end
			local alpha = 0
			panel.Paint = function()
				if(panel.Extend) then
					alpha = math.Clamp(alpha + Arknights.GetFixedValue(3), 0, 30)
				else
					alpha = math.Clamp(alpha - Arknights.GetFixedValue(3), 0, 30)
				end
				draw.RoundedBox(0, 0, 0, panel:GetWide(), panel:GetTall(), Color(40, 40, 40, 255))
				draw.RoundedBox(0, 0, 0, panel:GetWide(), panel:GetTall(), Color(255, 255, 255, alpha))
			end
			v.func(panel.SubPanel)
		end

		ui.Paint = function()
			if(Arknights.StageMaker.SelectedMode == 3) then
				if(Arknights.StageMaker.IsCurrentNodeValid()) then
					Arknights.DrawBGText(AKScrW() * 0.5, AKScrH() * 0.65, "Press enter to finish current path", "Arknights_StageMaker_PathNode_Timer", Color(255, 255, 255, 255), 255, TEXT_ALIGN_CENTER)
				end
			end
		end

		local w, h = AKScrW() * 0.2, AKScrH() * 0.065
		local toolbar = Arknights.CreatePanel(ui, AKScrW() * 0.5 - w * 0.5, 0, w, h, Color(30, 30, 30, 255))
		local tools = {
			{
				material = "arknights/torappu/common_icon/icon_new_block.png",
				id = 1,
				tip = "Structure Tool",
			},
			{
				material = "arknights/torappu/common_icon/icon_paint.png",
				id = 2,
				tip = "Texturing Tool",
			},
			{
				material = "arknights/torappu/common_icon/icon_link.png",
				id = 3,
				tip = "Node Path Tool",
			},
			{
				material = "arknights/torappu/common_icon/sprite_kill.png",
				id = 4,
				tip = "Enemy Placement",
			},
		}
		local spacing = AKScreenScaleH(2)
		local height = toolbar:GetTall() - (spacing * 2)
		local margin = toolbar:GetWide() / #tools
		local gap = margin * 0.2
		local nextX = gap
		for k,v in ipairs(tools) do
			local button = Arknights.CreateMatButton(toolbar, nextX, spacing, height, height, Arknights.GetCachedMaterial(v.material), function()
				Arknights.StageMaker.SelectedMode = v.id
				Arknights.ButtonClickSound("select")
			end)
			button.Think = function()
				if(button:IsHovered() && Arknights.ToolTipOverrideTime < SysTime()) then
					Arknights.ShowToolTip(v.tip, 0.25)
				end
			end
			button.Alpha = 0
			button.Paint2x = function()
				if(Arknights.StageMaker.SelectedMode == v.id) then
					button.Alpha = math.Clamp(button.Alpha + Arknights.GetFixedValue(2), 0, 25)
				else
					button.Alpha = math.Clamp(button.Alpha - Arknights.GetFixedValue(2), 0, 25)
				end
				draw.RoundedBox(spacing, 0, 0, button:GetWide(), button:GetTall(), Color(255, 255, 255, button.Alpha))
			end
			nextX = nextX + margin
		end

		function ui:OnKeyCodePressed(key)
			Arknights.StageMaker.KeyCodePressed(key)
		end

		local h = AKScreenScaleH(60)
		local timingbar = Arknights.CreatePanel(ui, 0, AKScrH() - h, AKScrW(), h, Color(30, 30, 30, 255))
		timingbar:SetZPos(-1)
		local margin = AKScreenScaleH(16)
		local yPadding = AKScreenScaleH(48)
		local lineHeight = AKScreenScaleH(2)
		local timingLine = Arknights.CreatePanel(timingbar, margin, yPadding, AKScrW() - (margin * 2), lineHeight, Color(0, 0, 0, 255))
		timingLine.oPaint = timingLine.Paint
		timingLine.Paint = function()
			timingLine.oPaint()
			local fraction = math.Clamp(Arknights.Stage.CurrentTime / Arknights.Stage.MaxTime, 0, 1)
			local x = timingLine:GetWide() * fraction
			draw.RoundedBox(0, 0, 0, x, timingLine:GetTall(), Color(255, 255, 255, 255))
		end
		local w, h = timingLine:GetWide(), AKScreenScaleH(16)
		local buttonLayer = Arknights.CreatePanel(timingbar, margin, yPadding - h * 0.5, w, h, Color(255, 255, 255, 255))
		function buttonLayer:OnMousePressed()
			local fraction = math.Clamp((gui.MouseX() - self:GetPos()) / self:GetWide(), 0, 1)
			indicatedPath = {}
			Arknights.Stage.CurrentTime = fraction * Arknights.Stage.MaxTime
			Arknights.Stage.ClearAllEntities()
			local currentTime = Arknights.Stage.CurrentTime
			for k,v in ipairs(Arknights.Stage.Enemies) do
				if(v.time < currentTime) then
					v.spawned = true
					continue
				end
			end
			Arknights.ButtonClickSound("switch")
		end
		buttonLayer.Alpha = 0
		buttonLayer.Think = function()
			if(buttonLayer:IsHovered()) then
				buttonLayer.Alpha = math.Clamp(buttonLayer.Alpha + Arknights.GetFixedValue(1.5), 0, 10)
			else
				buttonLayer.Alpha = math.Clamp(buttonLayer.Alpha - Arknights.GetFixedValue(1.5), 0, 10)
			end
			buttonLayer:SetAlpha(buttonLayer.Alpha)
		end
		local errorMaterial = Material("arknights/torappu/common/empty_noback.png", "smooth")
		local iconSize = AKScreenScaleH(16)
		local iconSizeHalf = iconSize * 0.5
		timingbar.oPaint = timingbar.Paint
		timingbar.Paint = function()
			timingbar.oPaint()
			local p1, p2 = timingLine:GetX(), timingLine:GetX() + timingLine:GetWide()
			local y = timingLine:GetY() + timingLine:GetTall() + lineHeight
			local maxtime = Arknights.Stage.MaxTime
			local basepos = timingLine:GetX()
			local wide = timingLine:GetWide()
			local ypos = timingLine:GetY() - AKScreenScaleH(4)

			surface.SetDrawColor(255, 255, 255, 255)
			for _, enemy in ipairs(Arknights.Stage.Enemies) do
				local timingPos = basepos + ((enemy.time / maxtime) * wide)
				local material = Arknights.Portraits[enemy.id]
				if(!material) then
					surface.SetMaterial(errorMaterial)
				else
					surface.SetMaterial(material)
				end
				surface.DrawTexturedRect(timingPos - iconSizeHalf, ypos - iconSize, iconSize, iconSize)
			end

			draw.DrawText(math.Round(Arknights.Stage.CurrentTime, 2).."s", "Arknights_StageMaker_0.5x", p1, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
			draw.DrawText(math.Round(Arknights.Stage.MaxTime, 2).."s", "Arknights_StageMaker_0.5x", p2, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		end
		local size = AKScreenScaleH(16)
		local playmat = Arknights.GetCachedMaterial("arknights/torappu/common_icon/play.png")
		local stopmat = Arknights.GetCachedMaterial("arknights/torappu/common_icon/stop.png")
		local playButton = Arknights.CreateMatButton(timingbar, timingbar:GetWide() * 0.5 - size * 0.5, AKScreenScaleH(2), size, size, playmat, function(self)
			if(Arknights.Stage.StartTimer) then
				self.mat = playmat
			else
				self.mat = stopmat
			end
			Arknights.Stage.StartTimer = !Arknights.Stage.StartTimer
			Arknights.ButtonClickSound("select")
		end)
		Arknights.StageMaker.EditorFrame = properties
	end

	ui.Think = function()
		local x, y = input.GetCursorPos()
		if((out && panelHovered) || Arknights.StageMaker.StopClickTime > SysTime()) then
			x, y = -1, -1
		end
		Arknights.Stage.CursorPos.x = x
		Arknights.Stage.CursorPos.y = y
		Arknights.Stage.CursorDir = gui.ScreenToVector(x, y)
		if(Arknights.TakingScreenshot) then
			ui:SetAlpha(0)
		else
			ui:SetAlpha(255)
		end

		local currentTime = Arknights.Stage.CurrentTime
		for k,v in ipairs(Arknights.Stage.Enemies) do
			if(!indicatedPath[v.path] && math.abs(v.time - currentTime) < 0.5) then
				Arknights.Stage.RenderPath(v.path)
				indicatedPath[v.path] = true
			end
			if(v.time > currentTime) then
				v.spawned = false
				continue
			end
			if(v.spawned) then continue end
			--[[
				time = val,
				id = Arknights.StageMaker.SelectedEnemy,
				pos = table.Copy(Arknights.StageMaker.SelectedEnemyPos),
				path = Arknights.StageMaker.SelectedEnemyPath,
			]]
			local pos = v.pos
			Arknights.Stage.CreateEnemy(v.id, v.path, pos.x, pos.y)
			v.spawned = true
		end
	end

	Arknights.BackButton(ui, function()
		Arknights.Stage.ClearAllEntities()
		Arknights.Stage.RenderingPaths = {}
		Arknights.Stage.RenderingPathParticles = {}
		if(Arknights.Stage.Editmode) then
			Arknights.NextFrameFunc(Arknights.TakeScreenshot)
		end
		local func = function()
			Arknights.FadeTransition(function()
				Arknights.ToggleGameFrame(true)
				Arknights.DestroyAllStageMeshes()
				Arknights.RemoveAllSpawnModelEntities()
				Arknights.IdealMusic = "void"
				Arknights.ReloadLevels = true
				ui:Remove()
			end)
		end
		Arknights.NextFrameFunc(func)
	end)

	Arknights.Stage.BasePanel = ui
end