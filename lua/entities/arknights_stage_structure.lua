AddCSLuaFile()

ENT.Type = "anim"
ENT.WantsTranslucency = true

if(!SERVER) then
	function ENT:Think()
	end
	
	ENT.RenderOffset = Vector(0, 0, 0)
	ENT.OriginalOrigin = nil
	function ENT:Draw(_, _, manualPaint)
		self:SetRenderOrigin(self.OriginalOrigin)
		self:DrawModel()
	end

	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube1x1x1.mdl")
		Arknights.AddManualPainting(self)
	end
else
	function ENT:Initialize()
		print("[Arknights] Trying to create a clientsided entity on server, removing!")
		self:Remove()
	end
end