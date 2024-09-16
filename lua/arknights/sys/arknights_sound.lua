local sd = {
	select = "sound/arknights/mp3/g_ui/g_ui_btn_n.mp3",
	confirm = "sound/arknights/mp3/g_ui/g_ui_confirm.mp3",
	back = "sound/arknights/mp3/g_ui/g_ui_back.mp3",
}

function Arknights.PlaySound(sd)
	sound.PlayFile(sd, "noplay", function(station, errCode, errStr)
		if(IsValid(station)) then
			station:Play()
		end
	end)
end

function Arknights.ButtonClickSound(type)
	local sd = sd[type]
	if(!sd) then return end
	Arknights.PlaySound(sd)
end