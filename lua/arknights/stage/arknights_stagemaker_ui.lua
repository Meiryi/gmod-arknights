Arknights.StageMaker = {}
Arknights.StageMaker.ToolTabs = {
	{
		title = "Level Settings",
		func = function(ui)

		end,
	},
	{
		title = "Structures",
		func = function(ui)

		end,
	},
	{
		title = "Structures (Details)",
		func = function(ui)

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
		title = "Paths",
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

	if(Arknights.Stage.Editmode) then
		--[[
		local height = AKScrH() * 0.175
		local barheight = AKScreenScaleH(24)
		local nextX = 0
		local side_margin = AKScreenScaleH(6)
		local side_margin_2x = side_margin * 2
		local currentSelected = 0
		for k,v in ipairs(Arknights.StageMaker.ToolTabs) do
			local wide = Arknights.GetTextSize("Arknights_StageMaker_1x", v.title)
			local btn = Arknights.CreateButton(propertiesbar, nextX, 0, wide + side_margin_2x, propertiesbar:GetTall(), v.title, "Arknights_StageMaker_1x", Color(255, 255, 255, 255), Color(40, 40, 40, 255), function(self, fromSystem)
				if(currentSelected == k) then return end
				currentSelected = k

				if(fromSystem) then return end
				Arknights.ButtonClickSound("select")
			end)
			local clr = 0
			btn.Think = function()
				if(currentSelected == k) then
					clr = math.Clamp(clr + Arknights.GetFixedValue(5), 0, 40)
				else
					clr = math.Clamp(clr - Arknights.GetFixedValue(5), 0, 40)
				end
			end
			btn.Paint = function()
				draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), Color(clr,  clr, clr, 150))
			end
			if(k == 1) then
				btn.DoClick(btn, true)
			end
			nextX = nextX + btn:GetWide()
		end
		]]

		local wide = ScrW() * 0.2
		local origin = ScrW() - wide
		local currentPos = origin
		local out = true
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
			local currentX = properties:GetX()
			if(out) then
				currentPos = (math.Clamp(currentPos - Arknights.GetFixedValue((currentPos - origin) * 0.15), origin, ScrW()))
			else
				currentPos = (math.Clamp(currentPos + Arknights.GetFixedValue((ScrW() - currentPos) * 0.15), origin, ScrW()))
			end
			properties:SetPos(currentPos)
		end
		local autoResizePanel = function(target, newpnl)

		end
		local buttonHeight = ScrH() * 0.05
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
			panel.SubPanel.Height = ScrH() * 0.2
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
		end
	end

	ui.Think = function()
		local x, y = input.GetCursorPos()
		Arknights.Stage.CursorPos.x = x
		Arknights.Stage.CursorPos.y = y
		Arknights.Stage.CursorDir = gui.ScreenToVector(x, y)
	end

	Arknights.BackButton(ui, function()
		Arknights.FadeTransition(function()
			Arknights.ToggleGameFrame(true)
			Arknights.IdealMusic = "void"
			ui:Remove()
		end)
	end)

	Arknights.Stage.BasePanel = ui
end