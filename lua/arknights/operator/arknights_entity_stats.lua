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