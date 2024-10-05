AddCSLuaFile()

ENT.Type = "anim"
ENT.WantsTranslucency = true

ENT.BaseFolder = "enemies"
ENT.EntityID = "enemy_1037_lunsabr"
ENT.IsMoving = false

ENT.AnimationFPS = 1 / 30
ENT.Animations = nil
ENT.AnimationFrame = 1
ENT.AnimationTime = nil

ENT.CurrentAnimation = "idle"

ENT.RenderSize = 64
ENT.RenderOffset = Vector(0, 0, 0)

ENT.Attributes = {
	"massLevel", "stunImmune", "epResistance", "levitateImmune",
	"tauntLevel", "massLevel", "silenceImmune", "attackSpeed",
	"frozenImmune", "baseAttackTime", "cost", "maxDeployCount",
	"spRecoveryPerSec", "disarmedCombatImmune", "sleepImmune",
	"atk", "respawnTime", "damageHitrateMagical", "damageHitratePhysical",
	"epDamageResistance", "moveSpeed", "blockCnt", "hpRecoveryPerSec",
	"maxHp", "magicResistance", "def", "baseForceLevel"
}

ENT.stunImmune = false
ENT.levitateImmune = false
ENT.silenceImmune = false
ENT.frozenImmune = false
ENT.sleepImmune = false
ENT.disarmedCombatImmune = false

ENT.massLevel = 1 -- Weight
ENT.attackSpeed = 100 -- Attack speed scaling
ENT.baseAttackTime = 2 -- Attack interval
ENT.atk = 200 -- ATK
ENT.moveSpeed = 0.5 -- SPD (*48)
ENT.maxHp = 1650 -- HP
ENT.magicResistance = 0 -- RES
ENT.def = 100 -- DEF
ENT.epResistance = 0 -- ER?
ENT.rangeRadius = 0 -- Attack Range

ENT.tauntLevel = 0
ENT.cost = 0
ENT.maxDeployCount = 0
ENT.spRecoveryPerSec = 0
ENT.respawnTime = 0
ENT.damageHitrateMagical = 0
ENT.damageHitratePhysical = 0
ENT.epDamageResistance = 0
ENT.blockCnt = 0
ENT.hpRecoveryPerSec = 0
ENT.baseForceLevel = 0
ENT.attackHighGround = false

ENT.StayTime = 0
ENT.TargetDestination = nil
ENT.IdealSide = 1
ENT.CurrentSide = 1
ENT.DrawingWidthScale = 1

ENT.MoveToCursor = true
ENT.AnimationFinished = false
ENT.CanAttack = true
ENT.IsBlocked = false

ENT.BaseRange = Vector(24, 24, 0)
ENT.Enemies = {}
ENT.MaxTargets = 1
ENT.NextAttackTime = 0
ENT.AnimationLength = 1
ENT.ArrivedDestination = false

ENT.AnimTable = {
	attack_pre = nil,
	attack_loop = "attack",
	attack_end = nil,

	comat = nil,

	idle = "idle",
	die = "die",

	move_pre = nil,
	move = "run_loop",
	move_end = nil,
}

ENT.AttackTimings = {

}

ENT.DebugInfo = true

if(CLIENT) then
	function ENT:InitializeSpineAnimations()
		self.Animations = Arknights.CacheSpineAnimations(self.BaseFolder, self.EntityID)
		self.AnimationInited = true
	end

	function ENT:GetAnimationLength(anim)
		return #self.Animations["front"][self.AnimTable[anim]] * self.AnimationFPS
	end

	ENT.lastanim = nil
	function ENT:DecideAnimation()
		local animtable = self.Animations["front"][self.CurrentAnimation]
		local frames = #animtable
		local animtime = (frames * self.AnimationFPS)
		self.AnimationLength = animtime

		if(self.lastanim != self.CurrentAnimation) then -- Restart animation
			self.AnimationTime = Arknights.CurTime + animtime
			self.lastanim = self.CurrentAnimation
		end

		local fraction = math.Clamp((1 - ((self.AnimationTime - Arknights.CurTime) / animtime)), 0, 1)
		local frame = math.floor(fraction * frames)
		if(frame == frames) then
			self.AnimationFinished = true
		end
		if(!self.AnimationTime) then
			self.AnimationTime = Arknights.CurTime + animtime
		else
			if(self.AnimationTime < Arknights.CurTime) then
				self.AnimationTime = Arknights.CurTime + animtime
			end
		end
		fraction = (1 - ((self.AnimationTime - Arknights.CurTime) / animtime))
		self.AnimationFrame = math.floor(math.Clamp(fraction * frames, 1, frames))
		return true
	end

	local renderNormal = Vector(1, 0, 0)--Vector(0.819152, 0.000000, 0.5735767)
	function ENT:Draw(flags, manual)
		if(!manual) then return end
		if(!self.Animations) then
			self:InitializeSpineAnimations()
			return
		end
		local pos = self:GetPos()
		local size = self.RenderSize * self.DrawingWidthScale
		local size_y = self.RenderSize
		local sizehalf = size * 0.5
		if(!self:DecideAnimation()) then
			render.SetColorMaterial()
			render.DrawQuadEasy(pos + Vector(0, 0, size * 0.5) + self.RenderOffset, renderNormal, size, size, Color(255, 0, 0, 255), 180)
			return
		end
		if(self.CurrentSide != self.IdealSide) then
			self.DrawingWidthScale = math.Clamp(self.DrawingWidthScale - Arknights.GetFixedValue((0.075 * Arknights.TimeScale)), 0, 1)
			if(self.DrawingWidthScale <= 0) then
				self.CurrentSide = self.IdealSide
			end
		else
			self.DrawingWidthScale = math.Clamp(self.DrawingWidthScale + Arknights.GetFixedValue((0.075 * Arknights.TimeScale)), 0, 1)
		end
		--[[
			render.SetMaterial(self.Animations["front"][self.CurrentAnimation][self.AnimationFrame])
			render.DrawQuadEasy(pos + Vector(0, 0, size * 0.5) + self.RenderOffset, renderNormal, size * self.DrawingWidthScale, size, Color(255, 255, 255, 255), 180)
		]]
		cam.Start3D2D(pos + self.RenderOffset, Angle(0, 90, 90), 1)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Animations["front"][self.CurrentAnimation][self.AnimationFrame])
			if(self.CurrentSide == 1) then
				surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 0, 0, 1, 1)
			else
				surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 1, 0, 0, 1)
			end
		cam.End3D2D()
		if(self.DebugInfo) then
			cam.Start3D2D(pos + self.RenderOffset, Angle(0, 90, 90), 0.25)
				local x, y = size, -size_y * 2.5
				draw.DrawText(self.CurrentAnimation, "Arknights_OperatorDebugFont", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				y = y + 20
				local wide, tall = 96, 4
				local t = self.AnimationTime - Arknights.CurTime
				local fraction = math.Clamp((1 - (t / self.AnimationLength)), 0, 1)
				draw.RoundedBox(0, x, y, wide, tall, Color(0, 0, 0, 200))
				draw.RoundedBox(0, x, y, wide * fraction, tall, Color(50, 255, 50, 200))
				y = y + 8
				draw.DrawText(math.Round(1 - t, 3).." / "..self.AnimationLength.." (x"..Arknights.TimeScale..")", "Arknights_OperatorDebugFont", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
			cam.End3D2D()
		end
	end

	function ENT:SetTargetDestination(pos)
		self.TargetDestination = pos
	end

	function ENT:SetTargetDestination_Debug()
		self.TargetDestination = LocalPlayer():GetPos()
	end

	function ENT:AbleToStartMoving()
		return (self.CurrentAnimation == self.AnimTable.idle || self.CurrentAnimation == self.AnimTable.move_pre || self.CurrentAnimation == self.AnimTable.move_end)
	end

	function ENT:IsMovingAnimation()
		return self.CurrentAnimation == self.AnimTable.move
	end

	function ENT:IsMovementAnimation()
		local canim = self.CurrentAnimation
		return (canim == self.AnimTable.move || canim == self.AnimTable.move_pre || canim == self.AnimTable.move_end)
	end

	function ENT:IsIdleAnimation()
		return self.CurrentAnimation == self.AnimTable.idle
	end

	function ENT:IsAttackingAnimation()
		local canim = self.CurrentAnimation
		return (canim == self.AnimTable.attack_loop || canim == self.AnimTable.attack_pre || canim == self.AnimTable.attack_end)
	end


	function ENT:IsStartingMoving()
		return self.CurrentAnimation == self.AnimTable.move_pre
	end

	function ENT:CheckCancelVelocity()

	end

	function ENT:Move()
		if(!self:IsMovingAnimation()) then
			if(!self:AbleToStartMoving()) then
				return
			end
			if(!self:IsStartingMoving()) then
				if(self.AnimTable.move_pre) then
					self.CurrentAnimation = self.AnimTable.move_pre
				else
					self.CurrentAnimation = self.AnimTable.move
				end
			else
				if(self.AnimationFinished) then
					self.CurrentAnimation = self.AnimTable.move
				end
			end
		end
		if(self:IsMovingAnimation()) then
			local pos = self:GetPos()
			local dst = pos:Distance(self.TargetDestination)
			local vecforward = Arknights.GetFixedValue(self.moveSpeed * Arknights.TimeScale)
			local vel = (self.TargetDestination - pos)
			vel:Normalize()
			vel = vel * vecforward
			self:SetPos(pos + vel)
			if(self.TargetDestination.y > pos.y) then
				self.IdealSide = 1
			else
				self.IdealSide = 0
			end
		end
	end

	local function IsInRange(ent, a, b)
		return ent:GetPos():WithinAABox(a, b)
	end

	function ENT:FindEnemy()
		local pos = self:GetPos()
		local rg = self.rangeRadius
		local extend = Vector(48 * rg, 48 * rg, 0)
		local p1 = pos + (self.BaseRange + extend)
		local p2 = pos - (self.BaseRange + extend)
		local b1 = pos + self.BaseRange
		local b2 = pos - self.BaseRange
		p1.z = p1.z - 32
		p2.z = p2.z + 256
		b1.z = b1.z - 32
		b2.z = b2.z + 32
		self.Enemies = {}
		local count = 0
		local blocked = false
		for _, ent in ents.Iterator() do
			if(!ent.IsOperator && !ent:IsPlayer()) then continue end
			if(ent == self || !IsInRange(ent, p1, p2)) then continue end
			if(!blocked && IsInRange(ent, b1, b2)) then
				blocked = true
			end
			table.insert(self.Enemies, ent)
			count = count + 1
			if(count >= self.MaxTargets) then
				break
			end
		end
		self.IsBlocked = blocked
	end

	function ENT:Attack()
		if(self.CurrentAnimation != self.AnimTable.attack_loop) then return end
		local anim = self.AnimationLength
		local fraction = 1 - ((self.AnimationTime - Arknights.CurTime) / anim)
		
	end

	function ENT:Think()
		if(self.Dead) then return end
		local pos = self:GetPos()
		if(self.MoveToCursor) then
			if(input.IsMouseDown(107)) then
				self.TargetDestination = LocalPlayer():GetEyeTrace().HitPos
			end
		end
		self:FindEnemy()
		if(#self.Enemies > 0) then
			self:Attack()
			if(self:IsIdleAnimation() && !self:IsAttackingAnimation()) then
				if(self.NextAttackTime < Arknights.CurTime) then
					if(self.AnimTable.attack_pre) then
						if(self.CurrentAnimation != self.AnimTable.attack_loop) then
							self.CurrentAnimation = self.AnimTable.attack_pre
						else
							self.CurrentAnimation = self.AnimTable.attack_loop
							self.NextAttackTime = Arknights.CurTime + (self.baseAttackTime + self:GetAnimationLength("attack_loop"))
						end
					else
						self.CurrentAnimation = self.AnimTable.attack_loop
						self.NextAttackTime = Arknights.CurTime + (self.baseAttackTime + self:GetAnimationLength("attack_loop"))
					end
				else
					if(self.IsBlocked) then
						if(self.AnimationFinished) then
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						if(!self:IsMovementAnimation()) then
							self.CurrentAnimation = self.AnimTable.idle
						end
						goto move
					end
				end
			else
				if(!self:IsAttackingAnimation()) then
					if(self:IsMovementAnimation()) then
						if(self.AnimTable.move_end) then
							self.CurrentAnimation = self.AnimTable.move_end
							if(self.AnimationFinished) then
								self.CurrentAnimation = self.AnimTable.idle
							end
						else
							self.CurrentAnimation = self.AnimTable.idle
							if(!self.IsBlocked && self.NextAttackTime > Arknights.CurTime) then
								goto move
							end
						end
					else
						self.CurrentAnimation = self.AnimTable.idle
					end
				else
					if(self.NextAttackTime > Arknights.CurTime) then
						if(self.AnimationFinished) then
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						if(self.CurrentAnimation == self.AnimTable.attack_pre && self.AnimationFinished) then
							self.CurrentAnimation = self.AnimTable.attack_loop
						end
					end
				end
			end
			goto eof
		else
			if(self:IsAttackingAnimation()) then
				if(self.AnimationFinished) then
					if(self.CurrentAnimation != self.AnimTable.attack_end) then
						if(self.AnimTable.attack_end) then
							self.CurrentAnimation = self.AnimTable.attack_end
						else
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						self.CurrentAnimation = self.AnimTable.idle
					end
				end
			end
			self.NextAttackTime = 0
		end
		::move::
		if(self.TargetDestination && self.StayTime < Arknights.CurTime && !self:IsAttackingAnimation()) then
			if(pos:Distance(self.TargetDestination) > 8) then
				self:Move()
			else
				if(self.CurrentAnimation != self.AnimTable.idle) then
					if(self.AnimTable.move_pre) then
						self.CurrentAnimation = self.AnimTable.move_end
						if(self.AnimationFinished) then
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						self.CurrentAnimation = self.AnimTable.idle
					end
				end
			end
		else
			self.ArrivedDestination = true
		end
		::eof::
		self.AnimationFinished = false
	end

	function ENT:Initialize()
		Arknights.AddManualPainting(self)
		Arknights.SetEnemyStats(self)
	end
else
	function ENT:Initialize()
		print("[Arknights] Trying to create a clientsided entity on server, removing!")
		self:Remove()
	end
end