-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1171_durokt"

--[[ Animation IDs
		attack1
		attack2
		change
		die1
		die2
		idle1
		idle2
		move1
		move2
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack1",
		attack_end = "",

		combat = "",

		idle = "idle1",
		die = "die1",

		move_pre = "",
		move = "move1",
		move_end = "",

}

ENT.AttackTimings = {
	{
		timing = 0.5,
		attacked = false,
	}
}
		