Arknights.RunScreenEffects = false
Arknights.ScreenEffectDatas = {}
Arknights.ScreenEffects = {}

local fps = 0
local nextfpsupdate = 0
function Arknights.FPSCounter()
	local offset = AKScreenScaleH(16)
	if(nextfpsupdate < SysTime()) then
		fps = math.floor(1 / RealFrameTime())
		nextfpsupdate = SysTime() + 0.5
	end
	draw.DrawText("FPS : "..fps, "Arknights_Popup_1x", AKScrW() - offset, AKHOFFS + offset, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
end

hook.Add("DrawOverlay", "Arknights_ScreenEffects", function()
	if(!Arknights.IsGameActive()) then return end
	Arknights.FPSCounter()
end)