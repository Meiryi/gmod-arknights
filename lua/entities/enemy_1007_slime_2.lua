AddCSLuaFile()
ENT.Base = "arknights_enemy_base"
ENT.EntityID = "enemy_1007_slime_2"

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
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
		