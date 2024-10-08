-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1143_merrpg"

--[[ Animation IDs
		attack_a
		attack_b
		die_a
		die_b
		idle_a
		idle_b
		move_a
		move_b
]]

ENT.AnimTable = {
		attack_pre = "",
		attack_loop = "attack_a",
		attack_end = "",

		combat = "",

		idle = "idle_a",
		die = "die_a",

		move_pre = "",
		move = "move_a",
		move_end = "",
}

ENT.AttackTimings = {
	{
		timing = 0.3,
		attacked = false,
	}
}
ENT.RangedAttack = true
ENT.AttackProjectileEntity = ""
ENT.IsFirstAttack = true

function ENT:CustomOnAttack(attackcount)
	if(self.IsFirstAttack) then
		self.StopThinkTime = Arknights.CurTime + 0.8
		self.RegisteredAttackAnim.attack_a = true
		Arknights.NextFrameFunc(function()
			self.AnimTable.attack_loop = "attack_b"
			self.AnimTable.idle = "idle_b"
			self.AnimTable.die = "die_b"
			self.AnimTable.move = "move_b"
			self.AnimTable_Backup = table.Copy(self.AnimTable)
			self.AttackTimings = {
				{
					timing = 0.5,
					attacked = false,
				}
			}
		end)
		self.rangeRadius = 0
		self.RangedAttack = false
	end
	self.IsFirstAttack = false
end