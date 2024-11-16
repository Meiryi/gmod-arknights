AddCSLuaFile()

ENT.Type = "anim"
ENT.WantsTranslucency = true
ENT.IsArknightsEntity = true
ENT.IsOperator = true

ENT.BaseFolder = "operators"
ENT.EntityID = "char_124_kroos"

ENT.AnimationFPS = 1 / 30
ENT.Animations = nil
ENT.AnimationFrame = 1
ENT.AnimationTime = nil
ENT.DrawingWidthScale = 1

ENT.CurrentAnimation = -1

ENT.CurrentHorizontalSide = 0
ENT.CurrentVerticalSide = "front"

ENT.IdealHorizontalSide = 0
ENT.IdealVerticalSide = "front"

ENT.DeployedHorizontalSide = 0
ENT.DeployedVerticalSide = "front"
ENT.DeployedFacingSIde = 0

ENT.HasBothVerticalSide = true

ENT.RenderSize = 76
ENT.RenderOffset = Vector(0, 0, 0)
ENT.ColorMul = 1

ENT.Enemies = {}
ENT.AnimationLength = 1
ENT.StopThinkTime = 0

ENT.Dead = false
ENT.DeadTime = 0

ENT.StartFadingout = false
ENT.ColorFadingout = false
ENT.ColorVal = 0
ENT.Alpha = 255
ENT.AnimTable = {
	attack_pre = "",
	attack_loop = "attack",
	attack_end = "",

	start = "start",

	combat = "",

	skill_pre = "",
	skill_loop = "skill",
	skill_end = "",

	idle = "idle",
	die = "die",
}
ENT.NoRepeatAnimations = {}
ENT.RegisteredAttackAnim = {}

ENT.AttackSound = ""
ENT.AttackHitSound = ""
ENT.AttackTimings = {
	{
		timing = 0.5,
	}
}
ENT.NextAttackTime = 0
ENT.MaxTargets = 1

ENT.CanAttack = true

ENT.RangedAttack = false
ENT.AttackProjectileEntity = ""

ENT.AttackRange = {}
ENT.AttackRangeAABBs = {}

ENT.Attributes = {
	"stunImmune", "levitateImmune", "tauntLevel", "massLevel",
	"silenceImmune", "attackSpeed", "frozenImmune", "baseAttackTime",
	"cost", "maxDeployCount", "spRecoveryPerSec", "atk", "respawnTime",
	"disarmedCombatImmune", "sleepImmune", "baseForceLevel",
	"maxDeckStackCnt", "blockCnt", "moveSpeed", "maxHp",
	"hpRecoveryPerSec", "def", "magicResistance"
}

ENT.tauntLevel = 0
ENT.massLevel = 1
ENT.attackSpeed = 100
ENT.baseAttackTime = 1
ENT.cost = 10
ENT.maxDeployCount = 1
ENT.spRecoveryPerSec = 1
ENT.atk = 200
ENT.respawnTime = 90
ENT.baseForceLevel = 1
ENT.maxDeckStackCnt = 1
ENT.blockCnt = 1
ENT.moveSpeed = 0
ENT.maxHp = 200
ENT.hpRecoveryPerSec = 0
ENT.def = 100
ENT.magicResistance = 10

ENT.stunImmune = false
ENT.levitateImmune = false
ENT.disarmedCombatImmune = false
ENT.sleepImmune = false
ENT.silenceImmune = false
ENT.frozenImmune = false

ENT.DebugInfo = true

if(CLIENT) then
	function ENT:CustomOnThink() end
	function ENT:CustomOnAttack(attackcount) end
	function ENT:CustomOnAttackTarget(target, attackcount) end
	function ENT:CustomOnPaintWorld(fullsize, size, color) end
	function ENT:CustomOnPaint3D2D(fullsize, size, color) end
	function ENT:CustomOnDecideAnimation() end

	function ENT:InitializeSpineAnimations()
		self.Animations = Arknights.CacheSpineAnimations(self.BaseFolder, self.EntityID)
		self.AnimationInited = true

		self.AnimTable_Backup = table.Copy(self.Animations)
	end

	function ENT:GetAnimationLength(anim)
		return #self.Animations[self.CurrentVerticalSide][self.AnimTable[anim]] * self.AnimationFPS
	end

	function ENT:ConvertWorldPositionToGrid()
		local origin = Arknights.Stage.StructureOrigin
		local pos = self:GetPos()
		local size = Arknights.Stage.GridSize

		self.GridPos = Vector(math.floor((pos.x - origin.x) / size), math.floor((pos.y - origin.y) / size), 0)
	end

	ENT.lastanim = nil
	function ENT:DecideAnimation()
		self:CustomOnDecideAnimation()
		local animtable = self.Animations[self.CurrentVerticalSide][self.CurrentAnimation]
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
		if(!self.Dead) then
			if(!self.NoRepeatAnimations[self.CurrentAnimation]) then
				if(!self.AnimationTime) then
					self.AnimationTime = Arknights.CurTime + animtime
				else
					if(self.AnimationTime < Arknights.CurTime) then
						self.AnimationTime = Arknights.CurTime + animtime
					end
				end
			end
		else
			if(Arknights.CurTime - self.DeadTime > 0.5) then
				self.StartFadingout = true
			end
			if(Arknights.CurTime - self.DeadTime > 0.4) then
				self.ColorFadingout = true
			end
		end
		fraction = (1 - ((self.AnimationTime - Arknights.CurTime) / animtime))
		self.AnimationFrame = math.floor(math.Clamp(fraction * frames, 1, frames))
		return true
	end

	function ENT:DecideSide(vec)
		if(vec.y > self:GetPos().y) then
			self.IdealHorizontalSide = 1
		else
			self.IdealHorizontalSide = 0
		end
		if(self.HasBothVerticalSide) then
			local offset = math.abs(vec.x - self:GetPos().x)
			if(offset > 8) then
				if(vec.x > self:GetPos().x) then
					self.IdealVerticalSide = "front"
				else
					self.IdealVerticalSide = "back"
				end
			end
		end
	end

	local bounds = Vector(4, 4, 4)
	local renderNormal = Vector(0, 0, 1)
	local rangeMaterial = Material("arknights/torappu/arts/[uc]common/path_fx/sprite_attack_range.png", "noclamp smooth")
	function ENT:Draw(flags, manual)
		if(!manual) then return end
		if(!self.Animations) then
			for k,v in pairs(self.AnimTable) do
				if(v == "") then
					self.AnimTable[k] = nil
				end
			end

			self:InitializeSpineAnimations()
			return
		end
		if(self.CurrentAnimation == -1) then
			self.CurrentAnimation = self.AnimTable.idle
		end
		self:ConvertWorldPositionToGrid()
		local pos = self:GetPos()
		local size = self.RenderSize * self.DrawingWidthScale
		local size_y = self.RenderSize
		local sizehalf = size * 0.5
		if(!self:DecideAnimation()) then
			render.SetColorMaterial()
			render.DrawQuadEasy(pos + Vector(0, 0, size * 0.5) + self.RenderOffset, renderNormal, size, size, Color(255, 0, 0, 255), 180)
			return
		end
		if(!self.FirstFrameRendered) then
			if(self.AnimTable.start) then
				self.CurrentAnimation = self.AnimTable.start
			end
			self.FirstFrameRendered = true
		else
			if(self.CurrentAnimation == self.AnimTable.start && self.AnimationFinished) then
				self.CurrentAnimation = self.AnimTable.idle
			end
		end
		--[[
			ENT.CurrentHorizontalSide = 0
			ENT.CurrentVerticalSide = "front"

			ENT.IdealHorizontalSide = 0
			ENT.IdealVerticalSide = "front"

			ENT.DeployedHorizontalSide = 0
			ENT.DeployedVerticalSide = "front"
		]]
		if(self.CurrentHorizontalSide != self.IdealHorizontalSide || (self.CurrentVerticalSide != self.IdealVerticalSide && self.HasBothVerticalSide)) then
			self.DrawingWidthScale = math.Clamp(self.DrawingWidthScale - Arknights.GetFixedValue((0.075 * Arknights.TimeScale)), 0, 1)
			if(self.DrawingWidthScale <= 0) then
				self.CurrentHorizontalSide = self.IdealHorizontalSide
				if(self.HasBothVerticalSide) then
					self.CurrentVerticalSide = self.IdealVerticalSide
				end
			end
		else
			self.DrawingWidthScale = math.Clamp(self.DrawingWidthScale + Arknights.GetFixedValue((0.075 * Arknights.TimeScale)), 0, 1)
		end
		if(self.StartFadingout) then
			self.Alpha = math.Clamp(self.Alpha - (Arknights.GetFixedValue(12) * Arknights.TimeScale), 0, 255)
		else
			self.Alpha = math.Clamp(self.Alpha + (Arknights.GetFixedValue(12) * Arknights.TimeScale), 0, 255)
		end
		if(self.ColorFadingout) then
			self.ColorVal = math.Clamp(self.ColorVal - (Arknights.GetFixedValue(15) * Arknights.TimeScale), 0, 255)
		else
			self.ColorVal = math.Clamp(self.ColorVal + (Arknights.GetFixedValue(15) * Arknights.TimeScale), 0, 255)
		end
		if(self.IsInvisible) then
			self.ColorMul = math.Clamp(self.ColorMul - Arknights.GetFixedValue(0.025), 0.4, 1)
		else
			self.ColorMul = math.Clamp(self.ColorMul + Arknights.GetFixedValue(0.025), 0.4, 1)
		end
		local clr = self.ColorVal * self.ColorMul
		surface.SetDrawColor(clr, clr, clr, self.Alpha)
		surface.SetMaterial(self.Animations[self.CurrentVerticalSide][self.CurrentAnimation][self.AnimationFrame])
		self:CustomOnPaintWorld(size_y, size, color)
		local angle = Angle(0, 90, 90)
		local offset = Vector(8, 0, 0)
		cam.IgnoreZ(true)
		render.SetColorMaterial()
		cam.Start3D2D(pos + self.RenderOffset + offset, angle, 1)
			if(self.CurrentHorizontalSide == 1) then
				surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 0, 0, 1, 1)
			else
				surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 1, 0, 0, 1)
			end
			self:CustomOnPaint3D2D(size_y, size, color)
		cam.End3D2D()
		if(self.DebugInfo) then
			cam.Start3D2D(pos + self.RenderOffset, angle, 0.3)
				local x, y = size_y, -size_y * 1.75
				draw.DrawText(self.CurrentAnimation, "Arknights_OperatorDebugFont", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				y = y + 20
				local wide, tall = 96, 4
				local t = self.AnimationTime - Arknights.CurTime
				local fraction = math.Clamp((1 - (t / self.AnimationLength)), 0, 1)
				draw.RoundedBox(0, x, y, wide, tall, Color(0, 0, 0, 200))
				draw.RoundedBox(0, x, y, wide * fraction, tall, Color(50, 255, 50, 200))
				y = y + 8
				draw.DrawText(math.Round(1 - t, 3).." / "..math.Round(self.AnimationLength, 3).." (x"..Arknights.TimeScale..")", "Arknights_OperatorDebugFont", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				y = y + 16
				draw.DrawText("Col : "..self.GridPos.x.." Row : "..self.GridPos.y, "Arknights_OperatorDebugFont", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
			cam.End3D2D()
			cam.Start3D2D(self:GetPos(), Angle(0, 90, 0), 1)
				local size = Arknights.Stage.GridSize
				local sizehalf = size * 0.5
				local selfPos = self:GetPos() + Vector(0, 0, 0)
				surface.SetDrawColor(255, 100, 0, 255)
				surface.SetMaterial(rangeMaterial)
				local animtime = 2
				local anim = (SysTime() % animtime) / animtime
				local u1, v1, u2, v2 = anim, anim, 1 + anim, 1 + anim
				for _, vec in ipairs(self.AttackRange) do
					local pos = vec
					--render.SetColorMaterial()
					--render.DrawQuadEasy(pos, renderNormal, size, size, Color(255, 0, 0, 255), 0)
					surface.DrawTexturedRectUV(vec.x - sizehalf, vec.y - sizehalf, size, size, u1, v1, u2, v2)
				end
			cam.End3D2D()
		end
		cam.IgnoreZ(false)
	end

	function ENT:IsIdleAnimation()
		return self.CurrentAnimation == self.AnimTable.idle
	end

	function ENT:IsAttackingAnimation()
		local canim = self.CurrentAnimation
		return (canim == self.AnimTable.attack_loop || canim == self.AnimTable.attack_pre || canim == self.AnimTable.attack_end || canim == self.AnimTable.combat || self.RegisteredAttackAnim[canim])
	end

	function ENT:FindEnemy()
		self.Enemies = {}
		for _, enemy in ipairs(Arknights.CurrentEnemies) do
			if(!Arknights.ValidateEnemy(_, enemy)) then continue end
			if(!Arknights.IsInAttackRange(enemy, self.AttackRangeAABBs)) then continue end
			table.insert(self.Enemies, enemy)
		end
	end

	function ENT:Attack()

	end

	function ENT:DoKilled()
		self.Dead = true
		self.DeadTime = Arknights.CurTime
		self.CurrentVerticalSide = "front"
		self.IdealVerticalSide = "front"
		if(self.AnimTable.die) then
			self.CurrentAnimation = self.AnimTable.die
		end
		Arknights.PlaySound("sound/arknights/mp3/battle/b_char/b_char_dead.mp3", 1)
	end

	function ENT:Think()
		if(self.Dead || !self.AnimTable_Backup || self.CurrentAnimation == self.AnimTable.start || self.StopThinkTime > Arknights.CurTime) then
			if(self.Alpha <= 0) then
				self:Remove()
			end
			return
		end
		self:FindEnemy()
		self:CustomOnThink()

		if(#self.Enemies > 0 && self.CanAttack) then
			self:Attack()
			if(self:IsIdleAnimation() && !self:IsAttackingAnimation()) then
				self:DecideSide(self.Enemies[1]:GetPos())
				if(self.NextAttackTime < CurTime()) then
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
				end
			else
				if(self:IsAttackingAnimation()) then
					if(self.NextAttackTime > Arknights.CurTime) then
						if(self.AnimationFinished) then
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						if(self.AnimationFinished) then
							if(self.CurrentAnimation == self.AnimTable.attack_pre) then
								self.CurrentAnimation = self.AnimTable.attack_loop
							end
							if(self.CurrentAnimation == self.AnimTable.attack_end) then
								self.CurrentAnimation = self.AnimTable.idle
							end
							if(self.CurrentAnimation == self.AnimTable.attack_loop && !self.AnimTable.attack_pre) then
								self.CurrentAnimation = self.AnimTable.idle
							end
						end
					end
				end
			end
		else
			self.IdealHorizontalSide = self.DeployedHorizontalSide
			self.IdealVerticalSide = self.DeployedVerticalSide
			if(self:IsAttackingAnimation()) then
				if(self.AnimationFinished) then
					if(self.CurrentAnimation != self.AnimTable.attack_end) then
						if(self.AnimTable.attack_end) then
							self.CurrentAnimation = self.AnimTable.attack_end
						else
							self.CurrentAnimation = self.AnimTable.idle
						end
					else
						if(self.CurrentAnimation == self.AnimTable.attack_end) then
							self.CurrentAnimation = self.AnimTable.idle
						end
					end
				end
			end
		end

		self.AnimationFinished = false
	end

	function ENT:Initialize()
		Arknights.AddManualPainting(self)
		Arknights.SetOperatorStats(self)
		Arknights.PlaySound("sound/arknights/mp3/battle/b_char/b_char_set.mp3", 1)

		if(!self.HasBothVerticalSide) then
			self.IdealVerticalSide = "front"
			self.DeployedVerticalSide = "front"
		end
	end
else
	function ENT:Initialize()
		print("[Arknights] Trying to create a clientsided entity on server, removing!")
		self:Remove()
	end
end