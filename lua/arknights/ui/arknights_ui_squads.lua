local rarity_str = {
	TIER_1 = 1,
	TIER_2 = 2,
	TIER_3 = 3,
	TIER_4 = 4,
	TIER_5 = 5,
	TIER_6 = 6,
}
local rarity_bgs = {
	Material("arknights/torappu/character_container/sprite_char_background1_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_char_background1_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_char_background1_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_char_background4.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_char_background5.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_char_background7.png", "smooth"),
}
local rarity_lights = {
	Material("arknights/torappu/character_container/sprite_rartylight_1.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_rartylight_2.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_rartylight_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_rartylight_4.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_rartylight_5.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_rartylight_6.png", "smooth"),
}
local rarity_shadows = {
	Material("arknights/torappu/character_container/sprite_lowerhub1_3shadowoff.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_lowerhub1_3shadowoff.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_lowerhub1_3shadowoff.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_lowerhub4shadowoff.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_lowerhub5shadowoff.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_lowerhub6shadowoff.png", "smooth"),
}
local rarity_stars = {
	Material("arknights/torappu/character_container/sprite_star_1.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_star_2.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_star_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_star_4.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_star_5.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_star_6.png", "smooth"),
}
local rarity_upper = {
	Material("arknights/torappu/character_container/sprite_upperhub_1.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_upperhub_2.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_upperhub_3.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_upperhub_4.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_upperhub_5.png", "smooth"),
	Material("arknights/torappu/character_container/sprite_upperhub_6.png", "smooth"),
}
local profession_icons = {
	TANK =  Material("arknights/torappu/profession/icon_profession_tank_large.png"),
	SNIPER =  Material("arknights/torappu/profession/icon_profession_sniper_large.png"),
	CASTER =  Material("arknights/torappu/profession/icon_profession_caster_large.png"),
	MEDIC =  Material("arknights/torappu/profession/icon_profession_medic_large.png"),
	SUPPORT =  Material("arknights/torappu/profession/icon_profession_support_large.png"),
	PIONEER = Material("arknights/torappu/profession/icon_profession_pioneer_large.png"),
	WARRIOR =  Material("arknights/torappu/profession/icon_profession_warrior_large.png"),
	SPECIAL =  Material("arknights/torappu/profession/icon_profession_special_large.png"),
	UNKNOWN = Material("arknights/torappu/common/empty_noback.png"),
}
function Arknights.GetRarity(str)
	return rarity_str[str] || 1
end

function Arknights.GetSkillIcon(skill)
	if(skill == "null") then
		return profession_icons.UNKNOWN
	end
	local mat = Arknights.GetCachedMaterial("arknights/operators/skills/skill_icon_"..skill..".png")
	if(mat:GetTexture("$basetexture"):IsErrorTexture()) then
		return profession_icons.UNKNOWN
	end
	return mat
end

Arknights.CachedPortraitsFonts = Arknights.CachedPortraitsFonts || {}
function Arknights.BuildOperatorPortraits(parent, x, y, w, operator)
	local h = w * 2
	local opData = Arknights.OperatorDatas[operator]
	local profession = "null"
	local subprofession = "null"
	local skill = "null"
	local name = "?"
	local rarity = 1
	local charspr = rarity_bgs[1]
	local operatorStats = Arknights.UserData.GetOperatorData(operator)

	if(opData) then
		profession = opData.profession
		subprofession = opData.subProfession
		name = opData.name
		rarity = Arknights.GetRarity(opData.rarity)
		charspr = Arknights.GetCachedMaterial("arknights/assets/charportraits/"..operator.."_1.png")

		local skills = opData.skills
		if(#skills > 0 && skills[operatorStats.skill]) then
			skill = skills[operatorStats.skill].skillId
		end

		if(charspr:GetTexture("$basetexture"):IsErrorTexture()) then
			charspr = rarity_bgs[rarity]
		end
	end

	local fontindex = math.floor(w)
	local fontname = nil
	if(!Arknights.CachedPortraitsFonts[fontindex]) then
		local fn = "Arknights_Internal_Portraits_"..fontindex
		surface.CreateFont(fn, {
			font = "Bender",
			extended = false,
			size = w * 0.15,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
		})
		fontname = fn
		Arknights.CachedPortraitsFonts[fontindex] = fontname
	else
		fontname = Arknights.CachedPortraitsFonts[fontindex]
	end

	local gap = w * 0.025
	local professionSize = w * 0.25
	local ui = Arknights.CreatePanelMat(parent, x, y, w, h, rarity_bgs[rarity], Color(255, 255, 255, 255))
	local _w, _h = ui:GetWide(), ui:GetTall()
	local char = Arknights.CreatePanelMat(ui, 0, 0, _w, _h, charspr, Color(255, 255, 255, 255))
	local upper = Arknights.CreatePanelMat(ui, 0, 0, _w * 0.5, _h * 0.15, rarity_upper[rarity], Color(255, 255, 255, 255))
	if(operator != "null") then
		local profession = Arknights.CreatePanelMat(ui, gap, gap, professionSize, professionSize, profession_icons[profession] || profession_icons.UNKNOWN, Color(255, 255, 255, 255))
		local unit = w * 0.15
		local unit_h = unit * 0.5
		local star_w, star_h = unit + (unit_h * (rarity - 1)), h * 0.075
		local stars = Arknights.CreatePanelMat(ui, profession:GetX() + profession:GetWide() + gap, gap, star_w, star_h, rarity_stars[rarity], Color(255, 255, 255, 255))
		local light_h = w * 0.823
		local light = Arknights.CreatePanelMat(ui, 0, h - light_h * 1.15, _w, light_h, rarity_lights[rarity], Color(255, 255, 255, 255))
	end
	local shadow_h =  w * 0.774
	local shadow = Arknights.CreatePanelMat(ui, 0, h - shadow_h, _w, shadow_h, rarity_shadows[rarity], Color(255, 255, 255, 255))
	shadow.w = _w
	shadow.h = (shadow_h * 0.33) + 2
	shadow.drawY = shadow_h - shadow.h
	shadow.drawclr = Color(20, 20, 20, 255)
	shadow.oPaint = shadow.Paint
	shadow.Paint = function()
		draw.RoundedBox(0, 0, shadow.drawY, _w, shadow.h, shadow.drawclr)
		shadow.oPaint()
	end
	if(operator != "null") then
		local bottom_gap = h * 0.1
		local skillsize = w * 0.25
		local skill = Arknights.CreatePanelMat(ui, w - (skillsize + gap), h - bottom_gap - skillsize, skillsize, skillsize, Arknights.GetSkillIcon(skill), Color(255, 255, 255, 255))
		local textw, texth, text = Arknights.CreateLabel(ui, w, h, name, fontname, Color(255, 255, 255, 255))
		text:SetPos(w - textw - gap, h - texth - gap)
	else
		local size = w * 0.5
		Arknights.CreatePanelMat(ui, w * 0.5 - size * 0.5, h * 0.5 - size * 0.5, size, size, Arknights.GetCachedMaterial("arknights/torappu/common_icon/plus.png"), Color(255, 255, 255, 255))
	end
end

function Arknights.SquadUI(attachUI)
	local ui = Arknights.CreatePanelMat(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Arknights.GetCachedMaterial("arknights/torappu/homepage/homebg.png"), Color(255, 255, 255, 255))
	ui:SetAlpha(0)
	ui.Alpha = 0
	ui.Exiting = false
	ui.Think = function()
		if(!ui.Exiting) then
			ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(15), 0, 255)
		else
			ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(15), 0, 255)
			if(ui.Alpha <= 0) then
				ui:Remove()
			end
		end
		ui:SetAlpha(ui.Alpha)
	end
	ui.Paint2x = function()
		draw.RoundedBox(0, 0, 0, AKScrW(), AKScrH(), Color(200, 200, 200, 100))
	end
	ui.Exit = function()
		ui.Exiting = true
	end

	local rhodeslogosw = AKScreenScaleH(200)
	local rhodeslogosh = rhodeslogosw * 0.85
	Arknights.CreatePanelMat(ui, -rhodeslogosw * 0.5, AKScrH() - rhodeslogosh, rhodeslogosw, rhodeslogosh, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/icon_rhodes.png"), Color(255, 255, 255, 125))

	local portraitSize = AKScreenScaleH(90)
	local portraitTall = portraitSize * 2
	local gap = AKScreenScaleH(4)
	local gap_w = AKScreenScaleH(16)
	local gap_h = AKScreenScaleH(8)
	local maxColNum = 6
	local maxRowNum = 2
	local totalWide, totalTall = portraitSize * maxColNum + gap_w * (maxColNum - 1), portraitTall * maxRowNum + gap_h * (maxRowNum - 1)
	local startX, startY = AKScrW() * 0.5 - totalWide * 0.5, AKScrH() * 0.5 - totalTall * 0.5
	local originalX = startX

	for index, operator in ipairs(Arknights.UserData.Squads) do
		Arknights.BuildOperatorPortraits(ui, startX, startY, portraitSize, operator)
		startX = startX + portraitSize + gap_w
		if(index == 6) then
			startX = originalX
			startY = startY + portraitTall + gap_h
		end
	end

	--Arknights.BuildOperatorPortraits(ui, 0, 0, portraitSize, "char_4004_pudd")

	Arknights.BackButton(ui, function()
		ui.Exiting = true
		attachUI.Active = true
	end)
end