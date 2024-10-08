-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1010_demon_2"

--[[ Animation IDs
		attack
		attack_end
		attack_idle
		attack_nopre
		die
		idle
		move_loop
]]

ENT.AnimTable = {
		attack_pre = "attack",
		attack_loop = "attack_nopre",
		attack_end = "attack_end",

		combat = "",

		idle = "idle",
		die = "die",

		move_pre = "",
		move = "move_loop",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.35,
		attacked = false,
	}
}
		