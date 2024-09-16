function Arknights.NextFrameFunc(func)
	timer.Simple(0, function()
		func()
	end)
end