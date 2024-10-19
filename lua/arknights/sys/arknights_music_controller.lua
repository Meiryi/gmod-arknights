Arknights.SoundChannel = Arknights.SoundChannel || nil
Arknights.MusicPlayed = Arknights.MusicPlayed || false
Arknights.MusicLooped = Arknights.MusicLooped || false
Arknights.Soundtracks = Arknights.Soundtracks || {}
Arknights.CurrentMusic = Arknights.CurrentMusic || "null"
Arknights.IdealMusic = Arknights.IdealMusic || "void"
Arknights.MusicVolume = Arknights.MusicVolume || 1
Arknights.ShouldPlayMusic = Arknights.ShouldPlayMusic || false
Arknights.UnAffectedCurTime = Arknights.UnAffectedCurTime || 0

function Arknights.RegisterMusic(name, intro, loop)
	Arknights.Soundtracks[name] = {
		intro = intro,
		loop = loop,
	}
end

function Arknights.ResetMusicState()
	Arknights.ConsoleCommand("stopsound")
	Arknights.MusicPlayed = false
	Arknights.MusicLooped = false
	Arknights.CurrentMusic = "null"
	Arknights.IdealMusic = "void"
	Arknights.MusicVolume = 1
end

function Arknights.StartMusic(music)
	Arknights.ResetMusicState()
	Arknights.ShouldPlayMusic = true
	Arknights.IdealMusic = music
end

function Arknights.SetMusic(id)
	Arknights.IdealMusic = id
end

function Arknights.IsValidMusivID(id)
	return Arknights.Soundtracks[id] != nil
end

function Arknights.VolumeLerping(input)
    local target = 0.016666
    return input / (target / ARKNIGHTS_LASTFRAMETIME)
end

local nextplaysd = 0
function Arknights.PlayMusic(id, loop)
	if(nextplaysd > Arknights.UnAffectedCurTime) then return end
	local music = Arknights.Soundtracks[id]
	local index = "intro"
	if(loop) then index = "loop" end
	if(!music) then return end
	--if(IsValid(Arknights.SoundChannel)) then Arknights.SoundChannel:Stop() end
	sound.PlayFile(music[index], "noplay", function(station, errCode, errStr)
		Arknights.SoundChannel = station
		if(IsValid(station)) then
			station:Play()
		end
	end)
	nextplaysd = Arknights.UnAffectedCurTime + 0.1
	Arknights.CurrentMusic = id
end
Arknights.RegisterMusic("lungmenbat",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_longmenbat_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_longmenbat_loop.mp3")
Arknights.RegisterMusic("lungmenbatimp",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_longmenbatimp_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_longmenbatimp_loop.mp3")
Arknights.RegisterMusic("chasing",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_chasing_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_chasing_loop.mp3")
Arknights.RegisterMusic("epic",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_epic_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_epic_loop.mp3")
Arknights.RegisterMusic("escapebattle",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_escapebattle_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_escapebattle_loop.mp3")
Arknights.RegisterMusic("failed",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_failed_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_failed_loop.mp3")
Arknights.RegisterMusic("frostnova",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_frostnova_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_frostnova_loop.mp3")
Arknights.RegisterMusic("indust",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_indust_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_indust_loop.mp3")
Arknights.RegisterMusic("normal01",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal01_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal01_loop.mp3")
Arknights.RegisterMusic("normal02",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal02_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal02_loop.mp3")
Arknights.RegisterMusic("normal03",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal03_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normal03_loop.mp3")
Arknights.RegisterMusic("normalbattle",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normalbattle_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_normalbattle_loop.mp3")
Arknights.RegisterMusic("qiecheng",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_qiecheng_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_qiecheng_loop.mp3")
Arknights.RegisterMusic("qiechengimp",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_qiechengimp_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_qiechengimp_loop.mp3")
Arknights.RegisterMusic("victory",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_victory_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_bat_victory_loop.mp3")
Arknights.RegisterMusic("base",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_science_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_science_loop.mp3")
Arknights.RegisterMusic("shop",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_shop_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_shop_loop.mp3")
Arknights.RegisterMusic("title01",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_title_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_title_loop.mp3")
Arknights.RegisterMusic("title02",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_title2022_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_title2022_loop.mp3")
Arknights.RegisterMusic("void",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_void_intro.mp3",
	"sound/arknights/mp3/sound_beta_02/music/m_sys_void_loop.mp3")

hook.Add("DrawOverlay", "Arknights_MusicController", function()
	local music = Arknights.Soundtracks[Arknights.CurrentMusic]
	if(!IsValid(Arknights.GameFrame)) then
		Arknights.ShouldPlayMusic = false
	end
	if(!Arknights.ShouldPlayMusic) then
		if(IsValid(Arknights.SoundChannel) && Arknights.SoundChannel:GetState() != 2) then
			Arknights.MusicVolume = math.Clamp(Arknights.MusicVolume - Arknights.VolumeLerping(0.03), 0, 1)
			Arknights.SoundChannel:SetVolume(Arknights.MusicVolume)
			if(Arknights.MusicVolume <= 0) then
				Arknights.SoundChannel:Pause()
			end
		end
		return
	else
		if(IsValid(Arknights.SoundChannel) && (Arknights.SoundChannel:GetState() == 2 || Arknights.SoundChannel:GetState() == 0) && Arknights.MusicVolume > 0 && Arknights.CurrentMusic == Arknights.IdealMusic) then
			Arknights.SoundChannel:Play()
		end
	end
	if(!Arknights.MusicPlayed) then
		Arknights.PlayMusic("void")
		Arknights.MusicPlayed = true
	end
	if(!IsValid(Arknights.SoundChannel)) then
		Arknights.PlayMusic(Arknights.IdealMusic)
		return
	end
	--print(Arknights.SoundChannel:GetTime(), Arknights.SoundChannel:GetLength())
	if(Arknights.CurrentMusic != Arknights.IdealMusic) then
		Arknights.MusicVolume = math.Clamp(Arknights.MusicVolume - Arknights.VolumeLerping(0.03), 0, 1)
		Arknights.SoundChannel:SetVolume(Arknights.MusicVolume)
		if(Arknights.MusicVolume <= 0) then
			if(Arknights.IsValidMusivID(Arknights.IdealMusic)) then
				Arknights.SoundChannel:Stop()
			end
			Arknights.CurrentMusic = Arknights.IdealMusic
			Arknights.PlayMusic(Arknights.CurrentMusic)
		end
	else
		Arknights.MusicVolume = math.Clamp(Arknights.MusicVolume + Arknights.VolumeLerping(0.03), 0, 1)
		Arknights.SoundChannel:SetVolume(Arknights.MusicVolume)
		if(Arknights.SoundChannel:GetTime() >= Arknights.SoundChannel:GetLength() - (0.05 + math.min(FrameTime() * 2, 0.1)) && !Arknights.MusicLooped) then
			Arknights.PlayMusic(Arknights.CurrentMusic, true)
			Arknights.MusicLooped = true
		else
			Arknights.MusicLooped = false
		end
	end
end)

hook.Add("EntityEmitSound", "Arknights_SoundRemover", function(t)
	if(Arknights.ShouldPlayMusic) then return false end
end)