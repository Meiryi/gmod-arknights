Arknights.CurrentEnemies = Arknights.CurrentEnemies || {}

function Arknights.AddEnemyToList(ent)
	table.insert(Arknights.CurrentEnemies, ent)
end

function Arknights.ValidateEnemy(index, ent)
	if(!IsValid(ent)) then
		table.remove(Arknights.CurrentEnemies, index)
		return false
	end
	return true
end

function Arknights.IsInAttackRange(ent, aabbs)
	local pos = ent:GetPos()
	for _, aabb in ipairs(aabbs) do
		if(pos:WithinAABox(aabb.mins, aabb.maxs)) then
			return true
		end
	end
end