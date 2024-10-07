-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1143_merrpg"

--[[ Animation IDs
		attack_a
		attack_b
		die_a
		die_b
		idle_a
		idle_b
		move_a
		move_b
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "",
		attack_end = "",

		combat = "",

		idle = "",
		die = "",

		move_pre = "",
		move = "",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		