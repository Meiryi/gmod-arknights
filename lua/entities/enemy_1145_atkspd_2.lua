-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1145_atkspd_2"

--[[ Animation IDs
		attack
		die
		idle
		move
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
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.125,
		attacked = false,
	}
}
ENT.RangedAttack = true
ENT.AttackProjectileEntity = ""
ENT.RenderOffset = Vector(0, 0, 86)
ENT.CanBeBlocked = false