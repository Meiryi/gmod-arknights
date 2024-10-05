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
function Arknights.AddManualPainting(ent, isEffect, drawModel)
	table.insert(Arknights.Stage.ManualPaintEnities, {
		ent = ent,
		isEffect = isEffect,
		drawModel = drawModel,
	})
end

function Arknights.IsHovered(p1, p2, x, y)
	return (x >= p1.x && y >= p1.y && x <= p2.x && y <= p2.y)
end

function Arknights.SetLookAt(x, y)
	if(!x && !y) then
		Arknights.Stage.LookAt = nil
	end
	Arknights.Stage.LookAt = Vector(x, y, 0)
end

Arknights.ToolTipText = ""
Arknights.ToolTipTextAlpha = 0
Arknights.ToolTipTextTime = 0
Arknights.ToolTipOverrideTime = 0

local angle000 = Angle(0, 0, 0)
local vector005 = Vector(5, 5, 5)
local vector000 = Vector(0, 0, 0)
local vector111 = Vector(1, 1, 1)
local vector001 = Vector(48, 48, 1)
local vectoroffset = Vector(24, 24, 0)
local mins, maxs = Vector(0, 0, 0), Vector(48, 48, 0)
local color1 = Color(255, 255, 255, 50)
local color2 = Color(255, 255, 255, 10)
local color_red = Color(255, 100, 100, 255)
local color_gray = Color(80, 80, 80, 255)
local normal_up = Vector(0, 0, 1)
local normal_side_1 = Vector(1, 0, 0)
local normal_side_2 = Vector(-1, 0, 0)
local normal_side_3 = Vector(0, 1, 0)
local normal_side_4 = Vector(0, -1, 0)
local spriteoffset = Vector(0, 0, 12)
local framemat = Material("arknights/meiryi/frame.png")
local pathmat = Material("arknights/meiryi/arts/node/node_curr_trans.png", "smooth")
local pathbeammat = Material("arknights/torappu/arts/[uc]common/path_fx/mask_09.png")

function Arknights.RenderPathNodes()
	if(!Arknights.StageMaker.IsCurrentNodeValid() || Arknights.StageMaker.SelectedMode != 3) then return end
	local node = Arknights.Stage.Paths[Arknights.StageMaker.SelectedPathNode]
	local origin = Arknights.Stage.StructureOrigin
	local size = Arknights.Stage.GridSize
	local x, y = Arknights.GetSelectedGrid()
	local nodeset = false
	
	for k,v in ipairs(node) do
		local gridoffset = v.vec
		local vec = origin + Vector(gridoffset.x * size, gridoffset.y * size, 0) + vectoroffset + spriteoffset
		if(x == gridoffset.x && y == gridoffset.y) then
			Arknights.StageMaker.SelectedNode = k
			nodeset = true
		end
		render.SetMaterial(pathmat)
		render.DrawSprite(vec, 16, 16, color_red)
		local scpos = (vec - spriteoffset):ToScreen()
		cam.Start2D()
			draw.DrawText("#"..k.." ["..v.timer.."s]", "Arknights_StageMaker_PathNode_Timer_0.5x", scpos.x, scpos.y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		cam.End2D()
		local next = node[k + 1]
		if(!next) then continue end
		local nextoffset = next.vec
		local nextvec = origin + Vector(nextoffset.x * size, nextoffset.y * size, 0) + vectoroffset + spriteoffset
		render.SetMaterial(pathbeammat)
		render.DrawBeam(vec, nextvec, 3, 0, 1, Color(255, 0, 0, 155))
	end

	if(!nodeset) then
		Arknights.StageMaker.SelectedNode = nil
	end
	render.SetMaterial(pathmat)
	local p = origin + Vector(x * size, y * size, 0) + vectoroffset + spriteoffset
	local canplacenode = Arknights.IsSelectedGridWalkable(x, y)
	if(Arknights.StageMaker.NodeEditMode == 0) then
		if(canplacenode && Arknights.Stage.IsHoveringStagePlane) then
			local lastpoint = node[#node]
			local lastvec = origin + Vector(lastpoint.vec.x * size, lastpoint.vec.y * size, 0) + vectoroffset + spriteoffset
			render.DrawSprite(p, 16, 16, color_red)
			render.SetMaterial(pathbeammat)
			render.DrawBeam(lastvec, p, 3, 0, 1, Color(255, 0, 0, 155))
		end
	end
end

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
					if(Arknights.Settings.DisplayGrids) then
						render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_white)
					end
				else
					render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_red)
				end
			else
				render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_gray)
			end
			if(isHovered) then
				render.SetColorMaterial()
				cam.IgnoreZ(true)
				render_DrawBox(p1, angle000, vector000, vector001, color1)
				cam.IgnoreZ(false)
				Arknights.SetSelectedGrid(x, y)
				posSet = true
				render.SetMaterial(framemat)
			end
		end
	end

	Arknights.RenderPathNodes()
	Arknights.Stage.IsHoveringStagePlane = (intersection && Arknights.IsHovered(origin, origin + Vector(end1, end2), intersection.x, intersection.y)) || false
end

function Arknights.IsInScreen(x, y)
	return (x >= 0 && x <= ScrW() && y >= 0 && y <= ScrH())
end

local nextcalc = 0
local finalvec = Vector(0, 0, 0)
local lastW, lastH = 0, 0
function Arknights.CalculateScreenPosition(force)
	local origin = Arknights.Stage.ViewPointOrigin + Vector(0, 0, 256)
	local gridSize = Arknights.Stage.GridSize
	local gridWide, gridTall = Vector(Arknights.Stage.Size.w * gridSize, 0, 0), Vector(0, Arknights.Stage.Size.h * gridSize, 0)
	local center = origin - gridTall * 0.5
	local _ok = false
	local forward = 1
	render.SetColorMaterial()
	if(!(lastW == gridWide && lastH == gridTall) || force) then
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

local function renderMesh(x, y, structure)
	local meshes = nil
	if(!Arknights.Stage.StructureMeshes[x] || !Arknights.Stage.StructureMeshes[x][y]) then return end
	meshes = Arknights.Stage.StructureMeshes[x][y]
	if(structure.material == -1) then
		render_SetMaterial(defMaterial)
	else
		render_SetMaterial(Arknights.GetCachedMaterial(structure.material))
	end
	meshes.top:Draw()
	if(structure.sidematerial == -1) then
		render_SetMaterial(defMaterial)
	else
		render_SetMaterial(Arknights.GetCachedMaterial(structure.sidematerial))
	end
	meshes.side:Draw()
end

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
	if(!defMaterial) then
		defMaterial = Arknights.GetCachedVMaterial("hunter/myplastic")
	end
	render.SuppressEngineLighting(true)
	if(Arknights.Settings.RenderMode == 1) then
		local origin = Arknights.Stage.StructureOrigin
		local size = Arknights.Stage.GridSize
		local offset = size * 0.5
		local height = 512
		render_SetMaterial(defMaterial)
		local strdata = Arknights.Stage.Structures
		for x, data in pairs(strdata) do
			for y, structure in pairs(data) do
				local p1 = origin + Vector(x * size, y * size, 0) + structure.gridoffset
				if(structure.material == -1) then
					render_SetMaterial(defMaterial)
				else
					render_SetMaterial(Arknights.GetCachedMaterial(structure.material))
				end
				render_DrawQuadEasy(p1 + vectoroffset, normal_up, size, size, color_white)
				if(structure.sidematerial == -1) then
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
		-- Render from edge to center to prevent render order issue
		local origin = Arknights.Stage.StructureOrigin

		render.SetAmbientLight(1, 1, 1)
		render.SetModelLighting(BOX_FRONT, 0.8, 0.8, 0.8)
		render.SetModelLighting(BOX_LEFT, 0.5, 0.5, 0.5)
		render.SetModelLighting(BOX_RIGHT, 0.5, 0.5, 0.5)
		render.SetModelLighting(BOX_TOP, 0.6, 0.6, 0.6)

		render.OverrideDepthEnable(true, true)

		local max = Arknights.Stage.Size.h
		local half = math.floor(max / 2)
		for x, data in pairs(Arknights.Stage.Structures) do
			for y, structure in pairs(data) do
				renderMesh(x, y, structure)
			end
			--[[
			for y = max, half, -1 do
				if(y <= half) then break end
				local structure = data[y]
				renderMesh(x, y, structure)
			end
			for y = 0, half do
				local structure = data[y]
				renderMesh(x, y, structure)
			end
			]]
		end
		render.OverrideDepthEnable(false, false)
	end
	render.SuppressEngineLighting(false)
end

function Arknights.RenderArknightsEntities()
	render.SuppressEngineLighting(true)
	for k,v in pairs(Arknights.Stage.ManualPaintEnities) do
		if(!IsValid(v.ent)) then
			Arknights.Stage.ManualPaintEnities[k] = nil
			continue
		end
		if(v.isEffect) then
			v.ent:Draw(true, true, true)
		end
		if(v.drawModel) then
			local clr = v.ent:GetColor()
			render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
			render.SetBlend(clr.a / 255)
			v.ent:DrawModel()
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
		else
			v.ent:Draw(true, true, true)
		end
	end
	render.SuppressEngineLighting(false)
end

hook.Add("PreDrawOpaqueRenderables", "Arknights_PreDrawOpaqueRenderables", function()
	local gameactive = Arknights.IsGameActive()
	Arknights_DrawHUD = !gameactive
	Arknights.RenderArknightsEntities()
	if(!gameactive || Arknights.IsGameFrameVisible()) then return end
	--[[
		render.Clear(0, 0, 0, 0, true, true)
		render.ClearStencil()
	]]
	Arknights.RenderStage()
	Arknights.RenderArknightsEntities()
	Arknights.RenderStageEditMode()

	cam.Start2D()
		draw.RoundedBox(0, 0, 0, AKScrW(), AKHOFFS, Color(0, 0, 0, 255))
		draw.RoundedBox(0, 0, ScrH() - AKHOFFS, AKScrW(), AKHOFFS, Color(0, 0, 0, 255))
	cam.End2D()
	DrawBloom(0.8, 2, 9, 9, 1, 1, 1, 1, 1)
end)

function Arknights.DrawBGText(x, y, text, font, color, alpha, algin_hor, algin_ver)
	local spacing = AKScreenScaleH(2)
	local tw, th = Arknights.GetTextSize(font, text)
	x = x + spacing
	y = y + spacing
	local bgx = x
	if(algin_hor == TEXT_ALIGN_CENTER) then
		bgx = x - tw * 0.5
	end
	draw.RoundedBox(0, bgx, y, tw + spacing * 2, th, Color(0, 0, 0, alpha * 0.75))
	draw.DrawText(text, font, x + spacing, y, Color(color.r, color.g, color.b, alpha), algin_hor || TEXT_ALIGN_LEFT, algin_ver || TEXT_ALIGN_TOP)
end

hook.Add("PostRenderVGUI", "Arknights_DrawToolTip", function()
	cam.Start2D()
		local x, y = input.GetCursorPos()
		if(Arknights.ToolTipTextTime > SysTime()) then
			Arknights.ToolTipTextAlpha = math.Clamp(Arknights.ToolTipTextAlpha + Arknights.GetFixedValue(20), 0, 255)
		else
			if(Arknights.ToolTipTextAlpha > 0) then
				Arknights.ToolTipTextAlpha = math.Clamp(Arknights.ToolTipTextAlpha - Arknights.GetFixedValue(20), 0, 255)
			end
		end
		if(Arknights.ToolTipTextAlpha > 0) then
			Arknights.DrawBGText(x, y, Arknights.ToolTipText, "Arknights_StageMaker_ToolTip", Color(255, 255, 255, 255), Arknights.ToolTipTextAlpha)
		end
	cam.End2D()
end)