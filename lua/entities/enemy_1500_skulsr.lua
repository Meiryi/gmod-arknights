-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1500_skulsr"

--[[ Animation IDs
		attack
		combat
		combat_end
		combat_nopre
		die
		idle
		move1
		move2
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "combat",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "move2",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
ENT.RangedAttack = true
ENT.AttackProjectileEntity = ""