Arknights.UserData = Arknights.UserData || {}
Arknights.UserData.Squads = {
	"char_009_12fce", "char_501_durin", "char_500_noirc", "char_503_rang", "char_502_nblade", "char_473_mberry", "char_476_blkngt", "char_237_gravel", "char_208_melan", "char_209_ardign", "null", "null"
}
Arknights.UserData.OperatorDatas = Arknights.UserData.OperatorDatas || {}

function Arknights.UserData.GetOperatorData(operator)
	local data = Arknights.UserData.OperatorDatas[operator]
	if(!data) then
		local template = {
			skill = 1,
			skillphases = {},
			elite = 0,
			level = 1,
			exp = 0,
		}
		Arknights.UserData.OperatorDatas[operator] = template
		return template
	else
		return data
	end
end