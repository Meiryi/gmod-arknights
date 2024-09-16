local timeoffs = 0
local ptime = SysTime()
hook.Add("Think", "Arknights_TimeSys", function()
	local t = (SysTime() - ptime) * Arknights.TimeScale
	Arknights.CurTime = Arknights.CurTime + t
	ptime = SysTime()
	Arknights.CurTimeUnScaled = SysTime()
end)