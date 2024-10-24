Arknights.WarningPanel = Arknights.WarningPanel || nil
Arknights.UnAffectedCurTime = Arknights.UnAffectedCurTime || 0
ARKNIGHTS_LASTFRAMETIME = 0.001

local forcePause = true
local forcePopup = false
local timeoffs = 0
local ptime = SysTime()
hook.Add("DrawOverlay", "Arknights_TimeSys", function()
	if(!Arknights.IsGameActive()) then
		if(IsValid(Arknights.WarningPanel)) then
			Arknights.WarningPanel:Remove()
		end
		return
	end
	local paused = gui.IsGameUIVisible()
	local t = (SysTime() - ptime)
	local _t = t
	ARKNIGHTS_LASTFRAMETIME = t
	Arknights.UnAffectedCurTime = Arknights.UnAffectedCurTime + t
	if(paused && forcePause) then
		t = 0
		_t = 0
		if(!IsValid(Arknights.WarningPanel) && forcePopup) then
			local pnl = vgui.Create("DPanel")
			pnl:SetSize(ScrW(), ScrH())
			pnl:SetPos(0, 0)
			pnl:MakePopup()
			local w, h, t = Arknights.CreateLabel(pnl, pnl:GetWide() * 0.5, pnl:GetTall() * 0.5, "PAUSED", "Arknights_Paused_1X", Color(255, 255, 255, 255))
			t.CentPos()
			local _, _, t = Arknights.CreateLabel(pnl, pnl:GetWide() * 0.5, pnl:GetTall() * 0.5 + h * 0.75, "--- Press ESC again to unpause ---", "Arknights_Paused_0.5X", Color(255, 255, 255, 255))
			t.CentPos()
			pnl.Paint = function()
				draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 100))
			end
			Arknights.WarningPanel = pnl
		else
			if(!forcePopup) then
				draw.DrawText("- Game paused -", "Arknights_Paused_0.5X", ScrW() * 0.5, ScrH() * 0.85, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			end
		end
	else
		if(IsValid(Arknights.WarningPanel)) then
			Arknights.WarningPanel:Remove()
		end
	end
	local scaled = t * Arknights.TimeScale
	Arknights.CurTime = Arknights.CurTime + scaled
	if(Arknights.Stage.StartTimer) then
		Arknights.Stage.CurrentTime = Arknights.Stage.CurrentTime + scaled
		if(Arknights.Stage.CurrentTime >= Arknights.Stage.MaxTime) then
			Arknights.Stage.CurrentTime = Arknights.Stage.MaxTime
		end
	end
	ptime = SysTime()
	Arknights.CurTimeUnScaled = Arknights.CurTimeUnScaled + _t
end)