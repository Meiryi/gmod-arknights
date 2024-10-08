-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1008_ghost"

--[[ Animation IDs
		die
		idle
		move_begin
		move_end
		move_loop
]]

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
ENT.CanAttack = false
ENT.CanBeBlocked = false