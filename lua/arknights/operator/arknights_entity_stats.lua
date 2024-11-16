function Arknights.SetEnemyStats(ent)
	local id = ent.EntityID
	local stats = Arknights.EnemyStats[id]
	if(!stats) then return nil end
	ent["rangeRadius"] = stats[1].enemyData.rangeRadius.m_value
	for k,v in pairs(stats[1].enemyData.attributes) do
		ent[k] = v.m_value
		ent["def_"..k] = v.m_value
	end
end

function Arknights.SetOperatorStats(ent)
	local id = ent.EntityID
	local stats = Arknights.OperatorDatas[id]
	if(!stats) then return nil end
	local eliteLevel = (ent.EliteLevel || 0) + 1
	local maxEliteLevel = #stats.phases
	local data = stats.phases[eliteLevel]
	if(!data) then return nil end
	local rangeid = data.rangeId
	local range = Arknights.OperatorRanges[rangeid]
	ent.AttackRange = {}
	if(range) then
		local size = Arknights.Stage.GridSize
		local sizehalf = 0
		local fside = ent.DeployedFacingSide
		for _, grid in pairs(range.grids) do
			if(fside == Arknights.ENUM_FORWARD) then
				table.insert(ent.AttackRange, Vector((grid.col * size) + sizehalf, (grid.row * size) + sizehalf, 0))
			elseif(fside == Arknights.ENUM_BACKWARD) then
				table.insert(ent.AttackRange, Vector((grid.col * -size) + sizehalf, (grid.row * -size) + sizehalf, 0))
			elseif(fside == Arknights.ENUM_UP) then
				table.insert(ent.AttackRange, Vector((grid.row * size) + sizehalf, (grid.col * size) + sizehalf, 0))
			elseif(fside == Arknights.ENUM_DOWN) then
				table.insert(ent.AttackRange, Vector((grid.row * -size) + sizehalf, (grid.col * -size) + sizehalf, 0))
			end
		end

		for _, grid in ipairs(ent.AttackRange) do
			local bpos = Vector(grid.y - size * 0.5, grid.x - size * 0.5, grid.z)
			table.insert(ent.AttackRangeAABBs, {
				mins = bpos + Vector(0, 0, -size),
				maxs = bpos + Vector(size, size, size * 3)
			})
		end

		ent.rangeID = rangeid
	end

	--[[
		data[Elite level] :
			<Datas>
			attributesKeyFrames :
				[1] = min level
				[2] = max level
	]]
	for k,v in pairs(data.attributesKeyFrames[1].data) do
		ent[k] = v
		ent["def_"..k] = v
	end
end

function Arknights.GetEnemyName(index)
	local stats = Arknights.EnemyStats[index]
	if(!stats) then
		return "NULL"
	end
	return stats[1].enemyData.name.m_value
end

local errMaterial = Material("arknights/torappu/common/empty_noback.png", "smooth")
function Arknights.GetEntityPortraits(index)
	local material = Arknights.Portraits[index]
	if(!material) then
		return errMaterial
	end
	return material
end

--[[
	attack
	magicRes
	maxHP
	attackSpeed
	def
	moveSpeed

	classLevel

	enemyRes ??
	enemyDamageRes ??
]]

function Arknights.GetStatsRating(input, index)
	for k,v in ipairs(Arknights.EnemyStatsRating) do
		local t = v[index]
		if(!t) then return "nil" end
		local min, max = t.min, t.max
		if(input >= min && input <= max) then
			return v.classLevel
		end
	end
	return "N"
end