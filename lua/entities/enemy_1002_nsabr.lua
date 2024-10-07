-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1002_nsabr"

--[[ Animation IDs
		attack
		die
		idle
		move_down
		move_loop
		move_up
		run_loop
		run_loop_2
		x_move_loop
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "run_loop",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		