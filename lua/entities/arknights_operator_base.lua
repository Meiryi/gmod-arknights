AddCSLuaFile()

ENT.Type = "anim"
ENT.WantsTranslucency = true

if(CLIENT) then

else
	function ENT:Initialize()
		print("[Arknights] Trying to create a clientsided entity on server, removing!")
		self:Remove()
	end
end