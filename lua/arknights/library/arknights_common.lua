function Arknights.NextFrameFunc(func)
	timer.Simple(0, function()
		func()
	end)
end

local rand = {
	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f"
}
function Arknights.GetRandomHex(length)
	local str = ""
	for i = 1, length do
		str = str..rand[math.random(1, #rand)]
	end
	return str
end