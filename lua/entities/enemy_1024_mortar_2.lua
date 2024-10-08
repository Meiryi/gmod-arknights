-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1024_mortar_2"

--[[ Animation IDs
		attack
		die
		idle_1
		idle_2
		move
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack",
		attack_end = "",

		combat = "",

		idle = "idle_2",
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
ENT.RangedAttack = true
ENT.AttackProjectileEntity = ""
ENT.IsFirstTimeAttacking = false

function ENT:CustomOnAttack(attackcount)
	if(self.IsFirstTimeAttacking) then return end
	self.StayTime = Arknights.CurTime + 20
	self.IsFirstTimeAttacking = true
end

function ENT:CustomOnThink()
	if(self.StayTime > Arknights.CurTime && #self.Enemies > 0) then
		self.AnimTable.idle = "idle_1"
	else
		self.AnimTable.idle = "idle_2"
	end
end