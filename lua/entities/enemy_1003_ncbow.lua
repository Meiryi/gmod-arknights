AddCSLuaFile()
ENT.Base = "arknights_enemy_base"
ENT.EntityID = "enemy_1003_ncbow"

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "combat",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "move_loop",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		