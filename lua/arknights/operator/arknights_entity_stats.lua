function Arknights.SetEnemyStats(ent)
	local id = ent.EntityID
	local stats = Arknights.EnemyStats[id]
	if(!stats) then return nil end
	ent["rangeRadius"] = stats[1].enemyData.rangeRadius.m_value
	for k,v in pairs(stats[1].enemyData.attributes) do
		ent[k] = v.m_value
	end
end