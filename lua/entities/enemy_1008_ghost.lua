AddCSLuaFile()
ENT.Base = "arknights_enemy_base"
ENT.EntityID = "enemy_1008_ghost"

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "",
		attack_end = "",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "move_begin",
		move = "move_loop",
		move_end = "move_end",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		