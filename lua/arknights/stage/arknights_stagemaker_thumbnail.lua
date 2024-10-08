Arknights.TakingScreenshot = false
Arknights.Thumbnails = Arknights.Thumbnails || {}

function Arknights.GetLevelThumbnail(mapID)
	return Arknights.Thumbnails[mapID] || false
end

function Arknights.TakeScreenshot()
	gui.HideGameUI()
	Arknights.TakingScreenshot = true
end

hook.Add("PostRender", "Arknights_Screenshot", function()
	if(!Arknights.TakingScreenshot || gui.IsGameUIVisible()) then
		return
	end
	local img = render.Capture({
		format = "jpeg",
		x = 0,
		y = AKHOFFS,
		quality = 85,
		w = AKScrW(),
		h = AKScrH(),
        alpha = false
	})
	Arknights.Thumbnails[Arknights.Stage.MapID] = img
	file.Write("arknights/levelthumbnails/"..Arknights.Stage.MapID..".png", img)
	Arknights.TakingScreenshot = false
end)