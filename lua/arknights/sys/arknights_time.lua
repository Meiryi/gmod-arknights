local timeoffs = 0
local ptime = SysTime()
hook.Add("Think", "Arknights_TimeSys", function()
	local t = (SysTime() - ptime) * Arknights.TimeScale
	Arknights.CurTime = Arknights.CurTime + t
	ptime = SysTime()
	if(Arknights.Stage.StartTimer) then
		Arknights.Stage.CurrentTime = Arknights.Stage.CurrentTime + t
		if(Arknights.Stage.CurrentTime >= Arknights.Stage.MaxTime) then
			Arknights.Stage.CurrentTime = Arknights.Stage.MaxTime
		end
	end

	Arknights.CurTimeUnScaled = SysTime()
end)