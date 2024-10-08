-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1005_yokai_2"

--[[ Animation IDs
		attack
		die
		idle
		move_begin
		move_end
		move_loop
]]

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
		timing = 0.3,
		attacked = false,
	}
}
ENT.RenderOffset = Vector(0, 0, 128)
ENT.CanBeBlocked = false