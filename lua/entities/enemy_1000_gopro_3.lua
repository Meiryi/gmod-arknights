AddCSLuaFile()
ENT.Base = "arknights_enemy_base"
ENT.EntityID = "enemy_1000_gopro_3"

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
		