-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1017_defdrn"

--[[ Animation IDs
		die
		idle
		move
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "",
		attack_end = "",

		combat = "",

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
ENT.RenderOffset = Vector(0, 0, 86)
ENT.CanAttack = false