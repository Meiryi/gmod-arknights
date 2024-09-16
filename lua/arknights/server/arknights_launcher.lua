util.AddNetworkString("Arknights-LaunchGame")

hook.Add( "PlayerSay", "Arknights_LaunchGame", function(ply, text)
	if(string.lower(text) == "/arknights" || string.lower(text) == "!arknights") then
		net.Start("Arknights-LaunchGame")
		net.Send(ply)
		return ""
	end
end)