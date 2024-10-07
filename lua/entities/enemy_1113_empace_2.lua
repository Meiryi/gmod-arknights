-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1113_empace_2"

--[[ Animation IDs
		attack_1_end
		attack_1_idle
		attack_1_loop
		attack_1_start
		attack_2
		die
		idle
		move
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "",
		attack_end = "",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "move",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		