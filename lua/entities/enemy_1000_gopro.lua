-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1000_gopro"

--[[ Animation IDs
		attack
		die
		idle
		move_begin
		move_end
		move_loop
		run_begin
		run_end
		run_loop
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "run_begin",
		move = "run_loop",
		move_end = "run_end",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		