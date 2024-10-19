Arknights.TakingScreenshot = false
Arknights.Thumbnails = Arknights.Thumbnails || {}

Arknights.ScreenshotRT = Arknights.ScreenshotRT || GetRenderTarget("AKScreenshotRT", AKScrW(), AKScrH())

function Arknights.GetLevelThumbnail(mapID)
	return Arknights.Thumbnails[mapID] || false
end

function Arknights.TakeScreenshot()
	Arknights.TakingScreenshot = true
end

function Arknights.CalculatePixels()
	local w, h = Arknights.ScreenshotRT:Width(), Arknights.ScreenshotRT:Height()
	local c = 0
	for x = 1, w do
		for y = 1, h do
			c = c + 1
			print(c)
		end
	end
end

hook.Add("PostRender", "Arknights_Screenshot", function()
	if(!Arknights.TakingScreenshot || gui.IsGameUIVisible()) then
		return
	end
	local img = render.Capture({
		format = "jpeg",
		x = 0,
		y = screenoffset,
		quality = 85,
		w = AKScrW(),
		h = AKScrH(),
        alpha = false
	})
	Arknights.Thumbnails[Arknights.Stage.MapID] = img
	file.Write("arknights/levelthumbnails/"..Arknights.Stage.MapID..".png", img)
	Arknights.TakingScreenshot = false
end)