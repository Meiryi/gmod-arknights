-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1019_jshoot"

--[[ Animation IDs
		attack
		combat
		die
		idle
		move
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "combat",

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
		