Arknights.Stage.CursorPos = {x = 0, y = 0}
Arknights.Stage.CursorDir = Vector(0, 0, 0)

render_DrawLine = render.DrawLine
render_DrawBox = render.DrawBox
render_DrawWireframeBox = render.DrawWireframeBox
render_DrawQuadEasy = render.DrawQuadEasy
render_SetMaterial = render.SetMaterial

hook.Add("CalcView", "Arknights_CalcView", function(ply, pos, angles, fov)
	if(!Arknights.IsGameActive()) then return end
	local view = {
		origin = Arknights.Stage.ViewPointOrigin,
		angles = Arknights.Stage.ViewPointAngle,
		fov = Arknights.Stage.ViewPointFOV,
		drawviewer = true,
	}
	return view
end)

Arknights_DrawHUD = true

hook.Add( "HUDShouldDraw", "Arknights_DisableHUD", function(name)
	if(!Arknights_DrawHUD) then
		return false
	end
end)

Arknights_DisableHUD = Arknights_DisableHUD || false
Arknights.Stage.ManualPaintEnities = Arknights.Stage.ManualPaintEnities || {}
function Arknights.AddManualPainting(ent, isEffect)
	table.insert(Arknights.Stage.ManualPaintEnities, {
		ent = ent,
		isEffect = isEffect,
	})
end

function Arknights.IsHovered(p1, p2, x, y)
	return (x >= p1.x && y >= p1.y && x <= p2.x && y <= p2.y)
end

Arknights.ToolTipText = ""
Arknights.ToolTipTextAlpha = 0
Arknights.ToolTipTextTime = 0

local angle000 = Angle(0, 0, 0)
local vector005 = Vector(5, 5, 5)
local vector000 = Vector(0, 0, 0)
local vector111 = Vector(1, 1, 1)
local vector001 = Vector(48, 48, 1)
local vectoroffset = Vector(24, 24, 0)
local mins, maxs = Vector(0, 0, 0), Vector(48, 48, 0)
local color1 = Color(255, 255, 255, 100)
local color2 = Color(255, 255, 255, 10)
local color_red = Color(255, 100, 100, 255)
local color_gray = Color(80, 80, 80, 255)
local normal_up = Vector(0, 0, 1)
local normal_side_1 = Vector(1, 0, 0)
local normal_side_2 = Vector(-1, 0, 0)
local normal_side_3 = Vector(0, 1, 0)
local normal_side_4 = Vector(0, -1, 0)
local framemat = Material("arknights/meiryi/frame.png")
function Arknights.RenderStageEditMode()
	if(Arknights.TakingScreenshot) then return end
	--if(!Arknights.Stage.Editmode) then return end
	local origin = Arknights.Stage.StructureOrigin
	local gridx, gridy = Arknights.Stage.Size.w, Arknights.Stage.Size.h
	local size = Arknights.Stage.GridSize
	local end1, end2 = gridx * size, gridy * size
	local dir = Arknights.Stage.CursorDir
	local max_x, max_y = gridx - 1, gridy - 1
	local intersection = util.IntersectRayWithPlane(Arknights.Stage.ViewPointOrigin, dir, origin, Vector(0, 0, 1))
	local _x, _y = -32767, -32767
	if(intersection) then
		_x = math.floor((intersection.x - origin.x) / size)
		_y = math.floor((intersection.y - origin.y) / size)
	end
	cam.IgnoreZ(true)
	render.SetMaterial(framemat)
	for x = 0, max_x do
		for y = 0, max_y do
			local p1 = origin + Vector(x * size, y * size, 0)
			local isHovered = (_x == x && _y == y)
			local strdata = Arknights.GetHoveredStructure(x, y)
			local offs = vector000
			local deployable = true
			if(strdata) then
				deployable = strdata.deployable
				offs = strdata.gridoffset
				p1 = p1 + offs
			end
			if(strdata) then
				if(deployable) then
					render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_white)
				else
					render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_red)
				end
			else
				render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_gray)
			end
			if(isHovered) then
				render.SetColorMaterial()
				render_DrawBox(p1, angle000, vector000, vector001, color1)
				Arknights.SetSelectedGrid(x, y)
				posSet = true
				render.SetMaterial(framemat)
			end
		end
	end
	cam.IgnoreZ(false)
	Arknights.Stage.IsHoveringStagePlane = (intersection && Arknights.IsHovered(origin, origin + Vector(end1, end2), intersection.x, intersection.y)) || false
end

function Arknights.IsInScreen(x, y)
	return (x >= 0 && x <= ScrW() && y >= 0 && y <= ScrH())
end

local nextcalc = 0
local finalvec = Vector(0, 0, 0)
local lastW, lastH = 0, 0
function Arknights.CalculateScreenPosition()
	local origin = Arknights.Stage.ViewPointOrigin + Vector(0, 0, 256)
	local gridSize = Arknights.Stage.GridSize
	local gridWide, gridTall = Vector(Arknights.Stage.Size.w * gridSize, 0, 0), Vector(0, Arknights.Stage.Size.h * gridSize, 0)
	local center = origin - gridTall * 0.5
	local _ok = false
	local forward = 1
	render.SetColorMaterial()
	if(!(lastW == gridWide && lastH == gridTall)) then
		local calcTime = SysTime() + 1
		local forwarded = 0
		while(calcTime > SysTime() && !_ok) do
			local viewangle = Arknights.Stage.ViewPointAngle
			local pos = center + viewangle:Forward() * forward
			local view = render.GetViewSetup()
			cam.Start3D(view.origin)
				local p1 = pos
				local p2 = pos + Vector(0, (Arknights.Stage.Size.h * gridSize), 0)
				local p3 = p1 + Vector(Arknights.Stage.Size.w * gridSize, 0, 0)
				local p4 = p2 + Vector(Arknights.Stage.Size.w * gridSize, 0, 0)
				--[[
				render.DrawBox(p1, angle000, -vector005, vector005, Color(255, 255, 255))
				render.DrawBox(p2, angle000, -vector005, vector005, Color(255, 255, 255))
				render.DrawBox(p3, angle000, -vector005, vector005, Color(255, 255, 255))
				render.DrawBox(p4, angle000, -vector005, vector005, Color(255, 255, 255))
				]]
				p1 = p1:ToScreen()
				p2 = p2:ToScreen()
				p3 = p3:ToScreen()
				p4 = p4:ToScreen()

				if(Arknights.IsInScreen(p1.x, p1.y) && Arknights.IsInScreen(p2.x, p2.y) && Arknights.IsInScreen(p3.x, p3.y) && Arknights.IsInScreen(p4.x, p4.y)) then
					_ok = true
					finalvec = pos
					cam.End3D()
					local __ok = false
					local fallbacktime = SysTime() + 0.1
					local upperSpace = p1.y
					local lowerSpace = ScrH() - p4.y
					local v1, v2 = pos, pos + Vector(1, 0, 0)
					local vecOffset = math.abs(v1:ToScreen().y - v2:ToScreen().y)
					if(upperSpace > lowerSpace) then
						local targetOffset = ((upperSpace - lowerSpace) * 0.5) / vecOffset
						finalvec.x = finalvec.x - targetOffset * 0.5
					else
						local targetOffset = ((lowerSpace - upperSpace) * 0.5) / vecOffset
						finalvec.x = finalvec.x + targetOffset * 0.5
					end
					break
				end
			cam.End3D()
			forwarded = forwarded + 1
			forward = forward + 16
			lastW = gridWide
			lastH = gridTall
		end
		nextcalc = SysTime() + 0.33
	end
	Arknights.Stage.StructureOrigin = finalvec
end

local function isgroundtile(id)
	return (id == "ground" || id == "ground2")
end

local bgMaterial = Material("arknights/torappu/map/TX_LMC_BG.png")
local defMaterial = nil --hunter/myplastic
local lastbg = ""
local offset_1 = Vector(48, 24, -24)
local offset_2 = Vector(24, 0, -24)
local offset_3 = Vector(24, 48, -24)
function Arknights.RenderStage()
	if(lastbg != Arknights.Stage.Background) then
		bgMaterial = Arknights.GetCachedMaterial(Arknights.Stage.Background)
		lastbg = Arknights.Stage.Background
	end
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(bgMaterial)
	cam.Start2D()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	cam.End2D()
	Arknights.CalculateScreenPosition()
	if(Arknights.Settings.RenderMode == 1) then
		local origin = Arknights.Stage.StructureOrigin
		local size = Arknights.Stage.GridSize
		local offset = size * 0.5
		local height = 512
		if(!defMaterial) then
			defMaterial = Arknights.GetCachedVMaterial("hunter/myplastic")
		end
		render_SetMaterial(defMaterial)
		local strdata = Arknights.Stage.Structures
		for x, data in pairs(strdata) do
			for y, structure in pairs(data) do
				local p1 = origin + Vector(x * size, y * size, 0) + structure.gridoffset
				if(structure.material == "default") then
					render_SetMaterial(defMaterial)
				else
					render_SetMaterial(Arknights.GetCachedMaterial(structure.material))
				end
				render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_white)
				if(structure.sidematerial == "default") then
					render_SetMaterial(defMaterial)
				else
					render_SetMaterial(Arknights.GetCachedMaterial(structure.sidematerial))
				end
				local nextY = strdata[x + 1]
				local currentX = strdata[x]
				if(structure.type == "ranged" ||structure.type == "wall") then
					if(!nextY || !nextY[y] || isgroundtile(nextY[y].type)) then
						render_DrawQuadEasy(p1 + offset_1, normal_side_1, size, size, color_white)
					end
					if(!currentX[y - 1] || isgroundtile(currentX[y - 1].type)) then
						render_DrawQuadEasy(p1 + offset_2, normal_side_4, size, size, color_white)
					end
					if(!currentX[y + 1] || isgroundtile(currentX[y + 1].type)) then
						render_DrawQuadEasy(p1 + offset_3, normal_side_3, size, size, color_white)
					end
					continue
				end
				if(!nextY || !nextY[y]) then
					render_DrawQuadEasy(p1 + offset_1, normal_side_1, size, size, color_white)
				end
				if(!currentX[y - 1]) then
					render_DrawQuadEasy(p1 + offset_2, normal_side_4, size, size, color_white)
				end
				if(!currentX[y + 1]) then
					render_DrawQuadEasy(p1 + offset_3, normal_side_3, size, size, color_white)
				end
			end
		end
		render.SetColorMaterial()
	elseif(Arknights.Settings.RenderMode == 2) then
		
	end
end

function Arknights.RenderArknightsEntities()
	render.SuppressEngineLighting(true)
	for k,v in pairs(Arknights.Stage.ManualPaintEnities) do
		if(!IsValid(v.ent)) then
			Arknights.Stage.ManualPaintEnities[k] = nil
			continue
		end
		v.ent:Draw(true, true, true)
	end
	render.SuppressEngineLighting(false)
end

hook.Add("PreDrawOpaqueRenderables", "Arknights_PreDrawOpaqueRenderables", function()
	local gameactive = Arknights.IsGameActive()
	Arknights_DrawHUD = !gameactive
	if(!gameactive || Arknights.IsGameFrameVisible()) then return end
	render.Clear(0, 0, 0, 0, true, true)
	render.ClearStencil()
	Arknights.RenderStage()
	Arknights.RenderArknightsEntities()
	Arknights.RenderStageEditMode()
end)

hook.Add("PostRenderVGUI", "Arknights_DrawToolTip", function()
	cam.Start2D()
		local spacing = AKScreenScaleH(2)
		local tw, th = Arknights.GetTextSize("Arknights_StageMaker_ToolTip", Arknights.ToolTipText)
		local x, y = input.GetCursorPos()
		x = x + spacing
		y = y + spacing
		if(Arknights.ToolTipTextTime > SysTime()) then
			Arknights.ToolTipTextAlpha = math.Clamp(Arknights.ToolTipTextAlpha + Arknights.GetFixedValue(20), 0, 255)
		else
			if(Arknights.ToolTipTextAlpha > 0) then
				Arknights.ToolTipTextAlpha = math.Clamp(Arknights.ToolTipTextAlpha - Arknights.GetFixedValue(20), 0, 255)
			end
		end
		if(Arknights.ToolTipTextAlpha > 0) then
			draw.RoundedBox(0, x, y, tw + spacing * 2, th, Color(0, 0, 0, Arknights.ToolTipTextAlpha * 0.5))
			draw.DrawText(Arknights.ToolTipText, "Arknights_StageMaker_ToolTip", x + spacing, y, Color(255, 255, 255, Arknights.ToolTipTextAlpha), TEXT_ALIGN_LEFT)
		end
	cam.End2D()
end)