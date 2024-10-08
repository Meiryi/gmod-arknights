-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1072_dlancer"

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
		timing = 0.25,
		attacked = false,
	}
}

function ENT:CustomOnThink()
	if(self:IsMovementAnimation()) then
		self.moveSpeed = math.Clamp(self.moveSpeed + Arknights.GetFixedValue(0.0095), 0, 6.5)
		self.atk = math.Clamp(self.atk + Arknights.GetFixedValue(1.25), 0, 2500)
	end
end

function ENT:CustomOnAttack(attackcount)
	self.moveSpeed = self.def_moveSpeed
	self.atk = self.def_atk
end