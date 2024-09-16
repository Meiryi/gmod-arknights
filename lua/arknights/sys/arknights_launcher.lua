net.Receive("Arknights-LaunchGame", function()
	Arknights.Launch()
end)

concommand.Add("arknights", function(ply, cmd, args)
	Arknights.Launch()
end)