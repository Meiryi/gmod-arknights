local mat = Material("arknights/meiryi/invis")
local angle = Angle(0, 180, 0)
hook.Add("CalcView", "Arknights_CalcView", function(ply, pos, angles, fov)
	if(!Arknights.IsGameActive()) then return end
	local view = {
		origin = Arknights.Stage.ViewPointOrigin,
		angles = angle,
		fov = fov,
		drawviewer = true
	}
	return view
end)

Arknights_DrawHUD = true

hook.Add( "HUDShouldDraw", "Arknights_DisableHUD", function(name)
	return Arknights_DrawHUD
end)

	Arknights_DisableHUD = Arknights_DisableHUD || false
function Arknights.AddManualPainting(ent, isEffect)
	table.insert(Arknights.Stage.ManualPaintEnities, {
		ent = ent,
		isEffect = isEffect,
	})
end

function Arknights.EditmodeRendering()

end

hook.Add("PostDrawOpaqueRenderables", "Arknights_PostDrawOpaqueRenderables", function()
	Arknights_DrawHUD = !Arknights.IsGameActive()
	for k,v in pairs(Arknights.Stage.ManualPaintEnities) do
		if(!IsValid(v.ent)) then
			Arknights.Stage.ManualPaintEnities[k] = nil
			continue
		end
		v.ent:Draw(true, true)
	end

	Arknights.EditmodeRendering()
end)