-- Created using gmod arknights batch creating tool
AddCSLuaFile()
ENT.Base = "arknights_enemy_base"

ENT.AttackSound = ""
ENT.AttackHitSound = ""

ENT.EntityID = "enemy_1502_crowns"

--[[ Animation IDs
		appear
		attack
		die
		disappear
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
		timing = 0.5,
		attacked = false,
	}
}
ENT.NextSkillTriggerTime = 0
ENT.NextPosition = Vector()
ENT.SkillFrame = 1
ENT.SkillFrameTime = -1
ENT.SkillMaterial = nil
ENT.ResetFrameTime = false
ENT.DelayPaintTime = 0
ENT.SkillAnimationFinished = false
ENT.NoRepeatAnimations = {
	disappear = true,
}

function ENT:CustomOnDecideAnimation()
	if(self.DelayPaintTime > Arknights.CurTime) then self.SkillAnimationFinished = false return end
	local frames = #self.Animations["front"].appear
	local frametime = self.AnimationFPS * frames
	if(self.ResetFrameTime) then
		self.SkillFrameTime = Arknights.CurTime + frametime
		self.ResetFrameTime = false
	end
	local fraction = math.Clamp(1 - ((self.SkillFrameTime - Arknights.CurTime) / frametime), 0, 1)
	if(fraction >= 1) then
		self.SkillAnimationFinished = true
	end
	self.SkillFrame = math.floor(math.Clamp(frames * fraction, 1, frames))
	self.SkillMaterial = self.Animations["front"].appear[self.SkillFrame]
end

function ENT:CustomOnPaintWorld(fullsize, size, color)
	if(self.CurrentAnimation != "disappear" || self.DelayPaintTime > Arknights.CurTime) then return end
	local clr = color
	local sizehalf = size * 0.5
	local size_y = fullsize
	local pos = self:GetPos()
	local offset = Vector(0, 0, 64)
	surface.SetMaterial(self.SkillMaterial)
	cam.Start3D2D(pos + self.RenderOffset + self.NextPosition, Angle(0, 90, 90), 1)
		local clr = self.ColorVal * self.ColorMul
		surface.SetDrawColor(clr, clr, clr, self.Alpha)
		if(self.CurrentSide == 1) then
			surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 0, 0, 1, 1)
		else
			surface.DrawTexturedRectUV(-sizehalf, -size_y, size, size_y, 1, 0, 0, 1)
		end
		self:CustomOnPaint3D2D()
	cam.End3D2D()
	surface.SetMaterial(self.Animations["front"][self.CurrentAnimation][self.AnimationFrame])
end

function ENT:CustomOnThink()
	if(self.NextSkillTriggerTime < Arknights.CurTime && self.IsBlocked && #self.Enemies > 0) then
		self.CurrentAnimation = "disappear"
		self.NextPosition = Vector(0, 50, 0)
		self.ResetFrameTime = true
		self.NextRunAttackTime = Arknights.CurTime + 1.25
		self.StayTime = Arknights.CurTime + 1.25
		self.DelayPaintTime = Arknights.CurTime + 0.6
		self.NextSkillTriggerTime = Arknights.CurTime + 10
	end
	if(self.CurrentAnimation == "disappear" && self.SkillAnimationFinished && self.AnimationFinished && self.DelayPaintTime < Arknights.CurTime) then
		self.CurrentAnimation = "idle"
		self:SetPos(self:GetPos() + self.NextPosition)
	end
end