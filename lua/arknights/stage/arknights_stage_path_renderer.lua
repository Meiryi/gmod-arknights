Arknights.Stage = Arknights.Stage || {}
Arknights.Stage.RenderingPaths = {}
Arknights.Stage.RenderingPathParticles = {}

local color_ground = Color(255, 50, 50, 30)
local color_air = Color(255, 200, 50, 30)

function Arknights.Stage.RenderPath(pathid)
	local pathdata = Arknights.Stage.Paths[pathid]
	if(!pathdata) then return end
	local isair = Arknights.IsHighGround(pathdata[1].vec.x, pathdata[1].vec.y)
	local path = {
		currentPathIndex = 1,
		currentFraction = 0,
		currentOffset = Vector(0, 0, 0),
		currentPos = Arknights.Stage.StructureOrigin,
		isair = isair,
		prevPos = -1,
		color = color_ground,
		paths = {}
	}
	if(isair) then
		path.color = color_air
	end
	for k,v in ipairs(pathdata) do
		table.insert(path.paths, v.vec)
	end
	for i = 0, 1 do
		timer.Simple((0.3 * i) * (1 / Arknights.TimeScale), function()
			table.insert(Arknights.Stage.RenderingPaths, table.Copy(path))
		end)
	end
end

function Arknights.Stage.RenderAllPaths()
	for k,v in pairs(Arknights.Stage.Paths) do
		Arknights.Stage.RenderPath(k)
	end
end

local renderMaterial = Material("arknights/torappu/arts/[uc]common/path_fx/mask_09.png", "smooth")
local offset = Vector(24, 24, 0)
local boxsize = Vector(2, 2, 2)
local gapSize = 1
local render_DrawBox = render.DrawBox
hook.Add("PostDrawOpaqueRenderables", "Arknights_PathRenderer", function()
	local origin = Arknights.Stage.StructureOrigin
	render.SetMaterial(renderMaterial)
	cam.IgnoreZ(true)
	for k, v in ipairs(Arknights.Stage.RenderingPathParticles) do
		if(v.alpha <= 0) then
			table.remove(Arknights.Stage.RenderingPathParticles, k)
			continue
		else
			v.size = math.max(v.size - (Arknights.GetFixedValue(v.sizedecspeed) * Arknights.TimeScale))
			v.alpha = math.Clamp(v.alpha - (Arknights.GetFixedValue(v.decspeed) * Arknights.TimeScale), 0, 255)
		end
		local clr = v.color
		local size = v.size
		local sx = Vector(size, size, size)
		render_DrawBox(v.pos, angle_zero, -sx, sx, Color(clr.r, clr.g, clr.b, v.alpha))
	end
	local size = Arknights.Stage.GridSize
	for k, path in ipairs(Arknights.Stage.RenderingPaths) do
		path.currentVec = path.paths[path.currentPathIndex]
		path.currentPos = origin + path.currentVec * size + offset
		local nextNode = path.paths[path.currentPathIndex + 1]
		if(!nextNode) then
			table.remove(Arknights.Stage.RenderingPaths, k)
			continue
		end
		if(path.prevPos == -1) then
			path.prevPos = path.currentPos
		end
		local targetPos = origin + nextNode * size + offset
		if(path.isair) then
			path.currentPos.z = path.currentPos.z + 24
			targetPos.z = targetPos.z + 24
		end
		local vOffset = (targetPos - path.currentPos) * path.currentFraction
		local renderPos = path.currentPos + vOffset
		path.currentFraction = math.Clamp(path.currentFraction + (Arknights.GetFixedValue(0.09) * Arknights.TimeScale), 0, 1)

		local dst = path.prevPos:Distance(renderPos)
		if(dst > gapSize) then
			local gap = math.Round(dst / gapSize, 0)
			local vOffset = renderPos - path.prevPos
			for i = 1, gap do
				table.insert(Arknights.Stage.RenderingPathParticles, {
					pos = path.prevPos + vOffset * (i / gap),
					decspeed = 10,
					sizedecspeed = 0.05,
					size = 1.5,
					color = path.color,
					alpha = 150,
				})
			end
			path.prevPos = renderPos
		end

		if(path.currentFraction >= 1) then
			path.currentFraction = 0
			path.currentPathIndex = path.currentPathIndex + 1
		end
	end
	cam.IgnoreZ(false)
end)