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

local spacing = ScreenScaleH(4)
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
	local spacing = ScreenScaleH(2)
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
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, ScreenScaleH(14), Color(30, 30, 30, 255))
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
	local height = ScreenScaleH(48)
	local innerspacing = ScreenScaleH(2)
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, height, Color(30, 30, 30, 255))
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
	local buttonheight = ScreenScaleH(24)
	local browseButton = Arknights.CreateButton(basepnl, (size + innerspacing * 2), basepnl:GetTall() - (buttonheight + innerspacing), sidewide, buttonheight, "Browse Materials", "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(20, 20, 20, 255), function()
		Arknights.StageMaker.MaterialBrowser(materialPreview)
		Arknights.ButtonClickSound("select")
	end)
	Arknights.AutoResizePanel(ui, basepnl)
end

Arknights.StageMaker.CachedMaterialPaths = Arknights.StageMaker.CachedMaterialPaths || {}
local paths = {
	"",
	"wood",
	"tile",
	"plaster",
	"metal",
	"concrete",
	"bulding_template",
	"brick",
}
function Arknights.StageMaker.GetMaterials()
	if(#Arknights.StageMaker.CachedMaterialPaths > 0) then
		return Arknights.StageMaker.CachedMaterialPaths
	end
	local result = {}
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

Arknights.StageMaker.MaterialBrowserPanel = Arknights.StageMaker.MaterialBrowserPanel || nil
function Arknights.StageMaker.MaterialBrowser(baseui)
	if(IsValid(Arknights.StageMaker.MaterialBrowserPanel)) then
		Arknights.StageMaker.MaterialBrowserPanel:Remove()
	end
	local side = 0.125
	local basepnl = Arknights.CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
		basepnl:MakePopup()
	local ui = Arknights.CreateFrame(basepnl, ScrW() * side, ScrH() * side, ScrW() * (1 - side * 2), ScrH() * (1 - side * 2), Color(30, 30, 30, 255))
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
		local margin = ScreenScaleH(4)
		Arknights.CreateLabelBG(ui, margin, margin, "Material Browser", "Arknights_Popup_1x", Color(0, 0, 0, 255), Color(66, 194, 245, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/icon_cg_normal.png"))
		local size = ScreenScaleH(14)
		Arknights.CreateMatButton(ui, ui:GetWide() - (size + margin), margin, size, size, Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		local sx = (size + margin * 2)
		local bottom_height = ScreenScaleH(48)
		local lower = Arknights.CreateScroll(ui, 0, sx, ui:GetWide(), ui:GetTall() - (sx + bottom_height), Color(25, 25, 25, 0))
		local path = Arknights.StageMaker.GetMaterials()
		local textTall = ScreenScaleH(16)
		local gap = ScreenScaleH(2)
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

function Arknights.StageMaker.CreatePopupButton(ui, settings, funcs)
	local wide = ui:GetWide() - (spacing * 2)
	local val = Arknights.Stage[settings]
	if(val == nil) then return end
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, ScreenScaleH(14), Color(30, 30, 30, 255))
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

function Arknights.StageMaker.CreatePopupButtonStageSize(ui, settings, funcs)
	local wide = ui:GetWide() - (spacing * 2)
	local val = Arknights.Stage.Size[settings]
	if(val == nil) then return end
	local basepnl = Arknights.CreatePanel(ui, spacing, 0, wide, ScreenScaleH(14), Color(30, 30, 30, 255))
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
	local vertical_margin = ScreenScaleH(4)
	local horizontal_margin = ScreenScaleH(4)
	local elemheight = ScreenScaleH(18)
	local spacing = ScreenScaleH(2)
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

local outofrange = function(val)
	return (val >= 4 && val <= 24)
end

Arknights.StageMaker.ToolTabs = {
	{
		title = "Level Settings",
		func = function(ui)
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
					Arknights.NextFrameFunc(Arknights.ReCalculateAllStructurePosition)
					Arknights.RemoveOutOfBoundsStructure()
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
					Arknights.NextFrameFunc(Arknights.ReCalculateAllStructurePosition)
					Arknights.RemoveOutOfBoundsStructure()
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
				["Ground Tile"] = "ground",
				["High Ground Tile"] = "ranged",
				["High Ground Tile (Undeplayable)"] = "wall",
				--["Kill Tile"] = "kill",
			})
		end,
	},
	{
		title = "Texturing",
		func = function(ui)
			Arknights.StageMaker.MaterialButton(ui)
		end,
	},
	{
		title = "Spawns",
		func = function(ui)

		end,
	},
	{
		title = "Enemies",
		func = function(ui)

		end,
	},
	{
		title = "Path Node",
		func = function(ui)

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
	local ui = Arknights.CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
	ui:MakePopup()

	local out = true
	local panelHovered = false
	if(Arknights.Stage.Editmode) then
		local wide = ScrW() * 0.2
		local origin = ScrW() - wide
		local currentPos = origin
		local properties = Arknights.CreateScroll(ui, origin, 0, wide, ScrH(), Color(40, 40, 40, 200))
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
				currentPos = (math.Clamp(currentPos - Arknights.GetFixedValue((currentPos - origin) * 0.15), origin, ScrW()))
			else
				currentPos = (math.Clamp(currentPos + Arknights.GetFixedValue((ScrW() - currentPos) * 0.15), origin, ScrW()))
			end
			properties:SetPos(currentPos)
		end
		local buttonHeight = ScrH() * 0.06
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
	end

	local w, h = ScrW() * 0.3, ScrH() * 0.075
	local toolbar = Arknights.CreatePanel(ui, ScrW() * 0.5 - w * 0.5, 0, w, h, Color(30, 30, 30, 255))

	Arknights.BackButton(ui, function()
		Arknights.FadeTransition(function()
			Arknights.ToggleGameFrame(true)
			Arknights.IdealMusic = "void"
			Arknights.RemoveAllStageStructureEntities()
			ui:Remove()
		end)
	end)

	Arknights.Stage.BasePanel = ui
end