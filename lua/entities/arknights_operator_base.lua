AddCSLuaFile()

ENT.Type = "anim"
ENT.WantsTranslucency = true

ENT.OperatorName = "Amiya"
ENT.OperatorInternalAnimID = "amiya"

ENT.AttackRange = {
	Vector(0, 0, 0),
	Vector(0, 1, 0),
	Vector(0, 2, 0),
	Vector(1, 0, 0),
	Vector(1, 1, 0),
	Vector(1, 2, 0),
	Vector(-1, 0, 0),
	Vector(-1, 1, 0),
	Vector(-1, 2, 0),
}

-- Animations
ENT.Anim_InvalidMaterial = Material("models/debug/debugwhite")
ENT.Anim_IdealHorizontal = Arknights.ENUM_Right
ENT.Anim_IdealVertical = Arknights.ENUM_Down
ENT.Anim_AnimationInited = false
ENT.Anim_CurrentRenderMaterial = nil
ENT.Anim_Animations = {}
ENT.Anim_AnimationDetails = {}

ENT.Anim_NextLoopTime = 0
ENT.Anim_SpriteRenderSize = 86
ENT.Anim_SpriteWRenderScale = 1
ENT.Anim_CurrentDirection = 1
ENT.Anim_CurrentAnimation = "idle"
ENT.Anim_CurrentSide = "front"
ENT.Anim_CurrentHorSide = "right"
ENT.Anim_TotalFrames = 1
ENT.Anim_TargetFrameTime = 0

ENT.Anim_AnimData = {
	attack_pre = "attack_begin",
	attack_end = "attack_end",
	attack_ranged = "attack",
	attack = "attack",
	idle = "idle",
	die = "die",
	start = "start",

	skill = "skill",
	skill_pre = "skill_begin",
	skill_end = "skill_end",
}

ENT.Data_HaveBackAnimation = false
ENT.Data_HaveDownAttack = false
ENT.Data_HaveAttack = true
ENT.Data_HaveSkill = true
ENT.Data_HaveIdle = true

ENT.Data_SkillPre = false
ENT.Data_SkillEnd = false
ENT.Data_SkillEndTime = 0

ENT.Logic_NextThinkTime = 0
ENT.Logic_ThinkInterval = 1 / 20
ENT.Logic_Dead = false
ENT.Logic_ShouldTurnSide = false
ENT.Logic_ShouldDisplayRange = false

-- Defaut value of lv1 amiya
ENT.Stats_AttackDamage = 390
ENT.Stats_DEF = 81
ENT.Stats_RES = 10
ENT.Stats_BLK = 1
ENT.Stats_AttackSpeed = 100
ENT.Stats_BaseAttackTime = 1.6
ENT.Stats_Health = 958

ENT.Debug_DebugInfo = true

if(CLIENT) then
	surface.CreateFont("Arknights-OperatorDebugFont", {
		font = "Arial",
		extended = false,
		size = 16,
		weight = 100,
		blursize = 0,
		scanlines = 0,
	})
	surface.CreateFont("Arknights-OperatorDebugFont-Small", {
		font = "Arial",
		extended = false,
		size = 10,
		weight = 100,
		blursize = 0,
		scanlines = 0,
	})

	function ENT:InitializeAnimations(op)
		if(!IsValid(op) || !op.OperatorInternalAnimID) then return end
		local id = op.OperatorInternalAnimID
		local anims = {}
		local animdetails = {}
		local fn, di = file.Find("materials/arknights/assets/operators/"..id.."/*", "GAME")
		for k,v in pairs(di) do -- Check for front and back animations
			anims[v] = {}
			animdetails[v] = {}
			local f, d = file.Find("materials/arknights/assets/operators/"..id.."/"..v.."/*", "GAME")
			for x,y in pairs(d) do -- Actual animation folder
				anims[v][y] = {}
				local frames = file.Find("materials/arknights/assets/operators/"..id.."/"..v.."/"..y.."/*.png", "GAME")
				for index, frame in pairs(frames) do
					local mat = Material("arknights/assets/operators/"..id.."/"..v.."/"..y.."/"..frame, "smooth")
					table.insert(anims[v][y], mat)
				end
				animdetails[v][y] = {
					frames = #frames,
					totaltime = #frames / 30,
				}
			end
			if(v == "back") then
				op.Data_HaveBackAnimation = true
			end
			op.Anim_Animations = anims
			op.Anim_AnimationDetails = animdetails
		end
	end

	function ENT:OpSetSequenceFast(canim)
		local anim = self.Anim_AnimData[canim]
		local side = self.Anim_CurrentSide
		local data = self.Anim_AnimationDetails[side][anim]
		self.Anim_NextLoopTime = Arknights.CurTime + data.totaltime
		self.Anim_TargetFrameTime = data.totaltime
		self.Anim_TotalFrames = data.frames
		self.Anim_CurrentAnimation = canim
	end

	function ENT:OpSetSequence(side, canim)
		local anim = self.Anim_AnimData[canim]
		local data = self.Anim_AnimationDetails[side][anim]
		self.Anim_NextLoopTime = Arknights.CurTime + data.totaltime
		self.Anim_TargetFrameTime = data.totaltime
		self.Anim_TotalFrames = data.frames
		self.Anim_CurrentAnimation = canim
	end

	function ENT:OpSetRenderTexture(side, canim, index)
		local anim = self.Anim_AnimData[canim]
		if(!self.Anim_Animations[side] || !self.Anim_Animations[side][anim] || !self.Anim_Animations[side][anim][index]) then
			self.Anim_CurrentRenderMaterial = nil
			return
		end
		self.Anim_CurrentRenderMaterial = self.Anim_Animations[side][anim][index]
	end

	function ENT:OpTurnSideHorizontal(right)
		if(right) then
			self.Anim_IdealHorizontal = Arknights.ENUM_Right
		else
			self.Anim_IdealHorizontal = Arknights.ENUM_Right
		end
	end

	function ENT:OpStartSkillAnimation(anim, duration)

	end

	function ENT:OpAttackCode(target)
		local damage = self.Stats_AttackDamage
	end

	function ENT:OpAnimationController()
		local seq = self.Anim_CurrentAnimation
		local side = self.Anim_CurrentSide
		local nextLoop = self.Anim_NextLoopTime
		local targettime = self.Anim_TargetFrameTime
		local totalframes = self.Anim_TotalFrames
		local curtime = Arknights.CurTime
		local fraction = 0
		local index = 1
		if(nextLoop == 0 || targettime == 0) then
			self:OpSetSequence(self.Anim_CurrentSide, seq)
		else
			fraction = math.Clamp(1 - (nextLoop - Arknights.CurTime) / targettime, 0, 1)
			index = math.floor(math.max(1, totalframes * fraction))
		end
		if(seq == "idle") then
			self:OpSetRenderTexture(side, seq, index)
			if(curtime > nextLoop) then
				self:OpSetSequence(side, seq)
			end
		end
		if(seq == "attack_pre") then
			self:OpSetRenderTexture(side, seq, index)
			if(fraction == 1) then
				self:OpSetSequence(side, "attack")
			end
		end
		if(seq == "attack") then
			self:OpSetRenderTexture(side, seq, index)
			if(fraction == 1) then
				self:OpSetSequence(side, seq)
			end
		end
		if(seq == "die") then
			self:OpSetRenderTexture(side, seq, index)
		end
		if(seq == "start") then
			self:OpSetRenderTexture(side, seq, index)
			if(fraction == 1) then
				self:OpSetSequence(self.Anim_CurrentSide, "idle")
			end
		end
	end

	function ENT:Think()
	end

	function ENT:OpThink()
		if(self.Logic_NextThinkTime > Arknights.CurTime) then return end
		if(!self.Anim_AnimationInited) then
			self:InitializeAnimations(self)
			self.Anim_AnimationInited = true
		end
		self.Logic_NextThinkTime = Arknights.CurTime + self.Logic_ThinkInterval
	end

	ENT.Var_TurnFinished = false
	function ENT:OpTurnAnimation()
		if(!self.Logic_ShouldTurnSide) then self.Var_TurnFinished = false return end
		if(!self.Var_TurnFinished) then
			self.Anim_SpriteWRenderScale = math.Clamp(self.Anim_SpriteWRenderScale - Arknights.GetFixedValue(0.045), 0, 1)
			if(self.Anim_SpriteWRenderScale <= 0) then
				self.Var_TurnFinished = true
				self.Anim_CurrentSide = self.Anim_IdealVertical
				self.Anim_CurrentHorSide = self.Anim_IdealHorizontal
			end
		else
			self.Anim_SpriteWRenderScale = math.Clamp(self.Anim_SpriteWRenderScale + Arknights.GetFixedValue(0.045), 0, 1)
			if(self.Anim_SpriteWRenderScale >= 1) then
				self.Logic_ShouldTurnSide = false
			end
		end
	end

	local rndmins, rndmaxs = Vector(-24, -24, 0), Vector(24, 24, 0)
	function ENT:Draw()
		self:OpThink()
		self:OpAnimationController()
		self:OpTurnAnimation()
		surface.SetDrawColor(255, 255, 255, 255)
		if(!self.Anim_CurrentRenderMaterial) then
			surface.SetMaterial(self.Anim_InvalidMaterial)
		else
			surface.SetMaterial(self.Anim_CurrentRenderMaterial)
		end
		local baseangle = Angle(0, 90, 90)
		local basesize = self.Anim_SpriteRenderSize * 0.5
		local offset = basesize - (basesize * self.Anim_SpriteWRenderScale)
		cam.IgnoreZ(true)
		if(self.Logic_ShouldDisplayRange) then
			render.SetColorMaterial()
			local pos = self:GetPos() + Vector(0, self.Anim_SpriteRenderSize * 0.5, 0)
			for k,v in ipairs(self.AttackRange) do
				local b = pos + v * 48
				render.DrawBox(b, angle_zero, rndmins, rndmaxs, Color(200, 45, 45, 100))
			end
		end
		cam.Start3D2D(self:GetPos() + Vector(0, -self.Anim_SpriteRenderSize * 0.5, self.Anim_SpriteRenderSize), baseangle, 1)
			if(self.Anim_CurrentHorSide == Arknights.ENUM_Right) then
				surface.DrawTexturedRectUV(offset, 0, self.Anim_SpriteRenderSize * self.Anim_SpriteWRenderScale, self.Anim_SpriteRenderSize, 0, 0, 1, 1)
			else
				surface.DrawTexturedRectUV(offset, 0, self.Anim_SpriteRenderSize * self.Anim_SpriteWRenderScale, self.Anim_SpriteRenderSize, 1, 0, 0, 1)
			end
		cam.End3D2D()
		if(self.Debug_DebugInfo) then
			local fraction = math.Clamp(1 - (self.Anim_NextLoopTime - Arknights.CurTime) / self.Anim_TargetFrameTime, 0, 1)
			cam.Start3D2D(self:GetPos() + Vector(0, -self.Anim_SpriteRenderSize * 0.5, self.Anim_SpriteRenderSize), baseangle, 0.25)
				draw.DrawText("Current Sequence : "..self.Anim_CurrentAnimation, "Arknights-OperatorDebugFont", 220, 80, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				draw.RoundedBox(0, 220, 95, 128, 6, Color(20, 20, 20, 150))
				draw.RoundedBox(0, 220, 95, 128 * fraction, 6, Color(20, 255, 20, 150))
			cam.End3D2D()
		end
		cam.IgnoreZ(false)
	end
else
	function ENT:Initialize()
		print("[Arknights] Trying to create a clientsided entity on server, removing!")
		self:Remove()
	end
end