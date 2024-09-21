Arknights.Stage.CursorPos = {x = 0, y = 0}
Arknights.Stage.CursorDir = Vector(0, 0, 0)

function Arknights.StartStage(stageData, editmode)
	if(!stageData || !istable(stageData)) then return end
	Arknights.Stage.Editmode = editmode
	Arknights.ToggleGameFrame(false)
	for k,v in pairs(stageData) do
		Arknights.Stage[k] = v
	end
	Arknights.CreateStageUI()
end

hook.Add("CalcView", "Arknights_CalcView", function(ply, pos, angles, fov)
	if(!Arknights.IsGameActive()) then return end
	local view = {
		origin = Arknights.Stage.ViewPointOrigin,
		angles = Arknights.Stage.ViewPointAngle,
		fov = Arknights.Stage.ViewPointFOV,
		drawviewer = true
	}
	return view
end)

Arknights_DrawHUD = true

hook.Add( "HUDShouldDraw", "Arknights_DisableHUD", function(name)
	return Arknights_DrawHUD
end)

Arknights_DisableHUD = Arknights_DisableHUD || false
Arknights.Stage.ManualPaintEnities = {}
function Arknights.AddManualPainting(ent, isEffect)
	table.insert(Arknights.Stage.ManualPaintEnities, {
		ent = ent,
		isEffect = isEffect,
	})
end

function Arknights.IsHovered(p1, p2, x, y)
	return (x >= p1.x && y >= p1.y && x <= p2.x && y <= p2.y)
end

local angle000 = Angle(0, 0, 0)
local vector005 = Vector(5, 5, 5)
local vector000 = Vector(0, 0, 0)
local vector111 = Vector(1, 1, 1)
local vector001 = Vector(48, 48, 1)
function Arknights.RenderStageEditMode()
	--if(!Arknights.Stage.Editmode) then return end
	local origin = Arknights.Stage.StructureOrigin
	local gridx, gridy = Arknights.Stage.Size.w, Arknights.Stage.Size.h
	local size = Arknights.Stage.GridSize
	local end1, end2 = gridx * size, gridy * size
	local dir = Arknights.Stage.CursorDir
	local max_x, max_y = gridx - 1, gridy - 1
	local size_m = size * 0.5
	local size_2x = size * 2
	local vec = Vector(size, size, 0)
	local intersection = util.IntersectRayWithPlane(Arknights.Stage.ViewPointOrigin, dir, origin, Vector(0, 0, 1))
	cam.IgnoreZ(true)
	for i = 0, gridx do
		local x = origin.x + (i * size)
		render.DrawLine(Vector(x, origin.y, origin.z), Vector(x, origin.y + end2, origin.z), Color(255, 255, 255), true)
	end
	for i = 0 , gridy do
		local y = origin.y + (i * size)
		render.DrawLine(Vector(origin.x, y, origin.z), Vector(origin.x + end1, y, origin.z), Color(255, 255, 255), true)
	end
	for x = 0, max_x do
		for y = 0, max_y do
			local p1 = origin + Vector(x * size, y * size, 0)
			local p2 = p1 + vec
			local pos_center = origin + Vector((x * size) + size_m, (y * size) + size_m, 0)
			local isHovered = false
			if(intersection) then
				isHovered = Arknights.IsHovered(p1, p2, intersection.x, intersection.y)
			end
			if(isHovered) then
				render.DrawBox(p1, angle000, vector000, vector001, Color(255, 255, 255, 100))
				Arknights.SetSelectedGrid(x, y)
			else
				render.DrawBox(p1, angle000, vector000, vector001, Color(255, 255, 255, 10))
			end
			render.DrawBox(pos_center, angle000, -vector111, vector111, Color(255, 255, 255, 255))
		end
	end
	cam.IgnoreZ(false)
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

local bgMaterial = Material("arknights/torappu/map/TX_LMC_BG.png")
local lastbg = ""
function Arknights.RenderStage()
	if(lastbg != Arknights.Stage.Background) then
		bgMaterial = Material(Arknights.Stage.Background, "smooth")
		lastbg = Arknights.Stage.Background
	end
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(bgMaterial)
	cam.Start2D()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	cam.End2D()
	Arknights.RenderStageEditMode()
	Arknights.CalculateScreenPosition()
end

function Arknights.RenderArknightsEntities()
	for k,v in pairs(Arknights.Stage.ManualPaintEnities) do
		if(!IsValid(v.ent)) then
			Arknights.Stage.ManualPaintEnities[k] = nil
			continue
		end
		v.ent:Draw(true, true)
	end
end

hook.Add("PreDrawOpaqueRenderables", "Arknights_PostDrawOpaqueRenderables", function()
	local gameactive = Arknights.IsGameActive()
	Arknights_DrawHUD = !gameactive
	if(!gameactive) then return end
	Arknights.RenderStage()
	Arknights.RenderArknightsEntities()
end)