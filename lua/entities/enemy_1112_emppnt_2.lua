-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1112_emppnt_2"

--[[ Animation IDs
		attack
		die
		idle
		move
		move_end
		move_start
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "move",
		move_end = "move_end",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		