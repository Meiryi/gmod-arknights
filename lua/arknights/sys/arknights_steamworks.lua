Arknights.NameFetchingList = {}
Arknights.NameList = {}

function Arknights.ReadNames()
	local data = file.Read("arknights/multiplayer/playernames.txt", "DATA")
	if(!data) then return end
	Arknights.NameList = util.JSONToTable(data, true, true)
end

function Arknights.SaveNames()
	local names = {}
	local tab = util.TableToJSON(Arknights.NameList, true)
	if(tab) then
		names = tab
	end
	file.Write("arknights/multiplayer/playernames.txt", names)
end

function Arknights.GetName(steamid64)
	if(!Arknights.NameList[steamid64]) then
		if(!Arknights.NameFetchingList[steamid64]) then
			Arknights.FetchName(steamid64)
		end
	else
		return Arknights.NameList[steamid64]
	end
end

function Arknights.FetchName(steamid64)
	steamworks.RequestPlayerInfo(steamid64, function(steamName)
		Arknights.NameList[steamid64] = steamName
		Arknights.SaveNames()
	end)
end

function Arknights.LabelNameFunc(label)
	if(!label.TargetID || (label.NextThink && label.NextThink > SysTime())) then return end
	local name = Arknights.GetName(label.TargetID)
	if(name) then
		label.UpdateText((label.ConcText || "")..name)
		label.Think = function() end
	end
	label.NextThink = SysTime() + 0.2
end