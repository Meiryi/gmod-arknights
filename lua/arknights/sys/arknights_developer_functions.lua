local Template = [[
-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

]]

local function ismovingAnimation(anim)
	return (anim == "move" || anim == "move_loop" || anim == "run_loop")
end

local function ispremovingAnimation(anim)
	return (anim == "move_begin" || anim == "run_begin")
end

local function isendmovingAnimation(anim)
	return (anim == "move_end" || anim == "run_end")
end

local function isdyingAnimation(anim)
	return (anim == "die")
end

local function isattackingAnimation(anim)
	return (anim == "attack")
end

local function iscombatAnimation(anim)
	return (anim == "combat")
end

local function isidleAnimation(anim)
	return (anim == "idle")
end

local newline = {
	[3] = true,
	[4] = true,
	[6] = true,
}

local maximumIndex = 158
function Arknights.CreateTemplateEntities()
	local files, directories = file.Find("materials/arknights/assets/enemies/*", "GAME")
	for k,v in ipairs(directories) do
		if(k >= maximumIndex) then break end
		local tmp = Template
		local _, anims = file.Find("materials/arknights/assets/enemies/"..v.."/front/*", "GAME")
		local hasanim = {
			[1] = {
				attack_pre = false
			},
			[2] = {
				attack_loop = false
			},
			[3] = {
				attack_end = false,
			},
			[4] = {
				combat = false,
			},
			[5] = {
				idle = false,
			},
			[6] = {
				die = false,
			},
			[7] = {
				move_pre = false,
			},
			[8] = {
				move = false,
			},
			[9] = {
				move_end = false,
			},
		}
		tmp = tmp..'ENT.EntityID = "'..v..'"'
		tmp = tmp.."\n\n"
		local allanims = {}
		tmp = tmp..'--[[ Animation IDs\n'
		for _,anim in ipairs(anims) do
			tmp = tmp.."		"..anim.."\n"
		end
		tmp = tmp..']]'
		tmp = tmp.."\n\n"
		for x,anim in ipairs(anims) do
			if(isattackingAnimation(anim)) then
				hasanim[2].attack_loop = anim
			end
			if(iscombatAnimation(anim)) then
				hasanim[4].combat = anim
			end
			if(isidleAnimation(anim)) then
				hasanim[5].idle = anim
			end
			if(isdyingAnimation(anim)) then
				hasanim[6].die = anim
			end
			if(ispremovingAnimation(anim)) then
				hasanim[7].move_pre = anim
			end
			if(ismovingAnimation(anim)) then
				hasanim[8].move = anim
			end
			if(isendmovingAnimation(anim)) then
				hasanim[9].move_end = anim
			end
		end

		tmp = tmp.."ENT.AnimTable = {\n"
		for _, tab in ipairs(hasanim) do
			for anim, val in pairs(tab) do
				if(!val) then
					tmp = tmp.."		"..anim..' = "",'
				else
					tmp = tmp.."		"..anim..' = "'..val..'",'
				end
				tmp = tmp.."\n"
				if(newline[_]) then
					tmp = tmp.."\n"
				end
			end
		end
		tmp = tmp.."\n"
		tmp = tmp.."}"
		tmp = tmp.."\n\n"
		tmp = tmp..[[
ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		]]
		file.Write("arknights/batching/"..v..".txt", tmp)
	end
end

function Arknights.ReformatTable()
	local tmp = table.Copy(Arknights.EnemyStatsRating)
	local ret = {}
	for k,v in pairs(tmp) do
		ret[v.classLevel] = v
	end
	local str = util.TableToJSON(ret, true)
	SetClipboardText(str)
end