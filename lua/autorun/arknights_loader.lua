Arknights = Arknights || {}
Arknights.CurTime = SysTime()
Arknights.CurTimeUnScaled = SysTime()
Arknights.TimeScale = 1
Arknights.Version = "dev"
Arknights.EnemyStats = Arknights.EnemyStats || {}
Arknights.EnemyDatas = Arknights.EnemyDatas || {}
Arknights.EnemyStatsRating = Arknights.EnemyStatsRating || {}
Arknights.DataInited = Arknights.DataInited || false

local f, d = file.Find("lua/arknights/*", "GAME")

for k,v in pairs(d) do
	if(v == "server") then continue end
	local fn = file.Find("lua/arknights/"..v.."/*.lua", "GAME")
	for x,y in pairs(fn) do
		if(CLIENT) then
			include("arknights/"..v.."/"..y)
		else
			AddCSLuaFile("arknights/"..v.."/"..y)
		end
	end
end

if(SERVER) then
	for k,v in pairs(file.Find("lua/arknights/server/*.lua", "GAME")) do
		include("arknights/server/"..v)
	end
end

if(CLIENT) then -- This is a fully clientsided game, don't need to create dirctories on server
	file.CreateDir("arknights")
	file.CreateDir("arknights/locallevels")
	file.CreateDir("arknights/levelthumbnails/")
	file.CreateDir("arknights/user")
	file.CreateDir("arknights/cache")
	file.CreateDir("arknights/multiplayer")
	file.CreateDir("arknights/avatars")
	file.CreateDir("arknights/batching")
	local reload = true
	if(!Arknights.DataInited || reload) then
		local data = util.JSONToTable(file.Read("data_static/arknights/enemy_database.json", "GAME"), true)
		Arknights.EnemyStats = data
		local data = util.JSONToTable(file.Read("data_static/arknights/enemy_handbook_table.json", "GAME"), true)
		Arknights.EnemyDatas = data.enemyData
		Arknights.EnemyStatsRating = data.levelInfoList
		Arknights.DataInited = true

	end
end