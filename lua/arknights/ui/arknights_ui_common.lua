Arknights.RespondingMenu = nil
Arknights.SkipIntro = false

function Arknights.GetScreenTexture()
	return Arknights.RenderTarget
end

function Arknights.FadeTransition(func)
	local ui = Arknights.CreatePanel(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
	ui:MakePopup()
	ui:SetZPos(32767)
	local switch = false
	local alpha = 0
	ui.Think = function()
		if(!switch) then
			alpha = math.Clamp(alpha + Arknights.GetFixedValue(14), 0, 255)
			if(alpha >= 255) then
				func()
				switch = true
			end
		else
			alpha = math.Clamp(alpha - Arknights.GetFixedValue(14), 0, 255)
			if(alpha <= 0) then
				ui:Remove()
			end
		end
	end
	ui.Paint = function()
		draw.RoundedBox(0, 0, 0, ui:GetWide(), ui:GetTall(), Color(0, 0, 0, alpha))
	end
end

function Arknights.IsWaitingRespond()
	return IsValid(Arknights.FetchingPanel)
end

--[[
	fulldim
	midloading
	finishedloading
]]
function Arknights.LoadingScreen(loadingbg, funcs)
	local ui = Arknights.CreatePanel(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	ui:MakePopup()
	local mat = Arknights.GetCachedMaterial(loadingbg)
	local alpha = 0
	local staytime = 0
	local switch = false
	local finishedloading = false
	local fadeout = false
	local funcstate = {}
	local killtime = Arknights.CurTimeUnScaled + 5
	ui.Paint = function()
		if(!switch) then
			alpha = math.Clamp(alpha + Arknights.GetFixedValue(10), 0, 255)
			staytime = Arknights.CurTimeUnScaled + 1
			if(alpha >= 255) then
				if(funcs.fulldim && !funcstate.fulldim) then
					Arknights.NextFrameFunc(funcs.fulldim)
					funcstate.fulldim = true
				end
				switch = true
			end
		else
			if(staytime < Arknights.CurTimeUnScaled && finishedloading) then
				if(!fadeout) then
					alpha = math.Clamp(alpha + Arknights.GetFixedValue(10), 0, 255)
					if(alpha >= 255) then
						if(funcs.finishedloading && !funcstate.finishedloading) then
							Arknights.NextFrameFunc(funcs.finishedloading)
							funcstate.midloading = true
						end
						fadeout = true
					end
				else
					alpha = math.Clamp(alpha - Arknights.GetFixedValue(10), 0, 255)
					if(alpha <= 0) then
						ui:Remove()
					end
				end
			else
				alpha = math.Clamp(alpha - Arknights.GetFixedValue(10), 0, 255)
			end
			if(alpha <= 0) then
				if(funcs.midloading && !funcstate.midloading) then
					Arknights.NextFrameFunc(funcs.midloading)
					funcstate.midloading = true
				end
				finishedloading = true
			end
			if(!fadeout) then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, AKScrW(), AKScrH())
			end
		end
		draw.RoundedBox(0, 0, 0, AKScrW(), AKScrH(), Color(0, 0, 0, alpha))
	end
end

function Arknights.StartupSequence(data, skip, suppressMusic)
	local login_ui = Arknights.CreatePanel(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Color(255, 255, 255, 255))
	local playsd = false
	--[[
		local cangle = Angle()
		local angle = AngleRand()
		local lerptime = math.random(2, 3)
		local tlerp = Arknights.CurTimeUnScaled + lerptime
		local v1, v2 = 6, 6
	]]
	local spheres = {}
	for i = 1, 2 do
		local lerptime = math.random(2, 3)
		local rangle = AngleRand()
		table.insert(spheres, {
			cangle = rangle,
			angle = rangle,
			lerptime = lerptime,
			tlerp = 0,
			v1 = math.random(5, 7),
			v2 = math.random(5, 7),
			size = 45,
		})
	end
	local offsmax = 40
	local offs = 40
	local offs2max = 200
	local offs2min = 100
	local offs2 = 100
	local clr = 190
	local barheight = AKScreenScaleH(54)
	local rhdsize = AKScreenScaleH(200)
	local barcolor = Color(0, 0, 0, 230)
	local aklogo = Arknights.GetCachedMaterial("arknights/meiryi/arts/arknights-black.png")
	local top, bottom = Arknights.GetCachedMaterial("arknights/torappu/[uc]rhine/top_gradient.png"), Arknights.GetCachedMaterial("arknights/torappu/[uc]rhine/bottom_gradient.png")
	local particle = Arknights.GetCachedMaterial("arknights/torappu/[uc]rhine/particle.png")
	local rhd = Arknights.GetCachedMaterial("arknights/meiryi/arts/rhodeisland.png")
	local hyperg = Arknights.GetCachedMaterial("arknights/meiryi/arts/hypergryph.png")
	local smontagne = Arknights.GetCachedMaterial("arknights/meiryi/arts/studio_montagne.png")
	local particles = {}
	local nextparticle = 0
	local dimsize = AKScreenScaleH(600)
	local sidegap = AKScreenScaleH(8)
	local objectalpha = 255
	local startconnecting = false
	local fetching = false
	local failedcount = 0
	local nextfetch = 0
	local progress = 0
	local __ok = false
	local started = false
	local h = AKScrH() * 0.1
	local w = h * 3
	local dimalpha = 0
	local btn1 = Arknights.CreateButtonOutline(login_ui, AKScrW() * 0.5 - w * 0.5, AKScrH() * 0.7 - h * 0.5, w, h, "Start", "Arknights_TitleButton", Color(255, 255, 255, 255), Color(85, 85, 85, 255), Color(255, 255, 255, 255), 1, function()
		startconnecting = true
		Arknights.ButtonClickSound("confirm")
	end)
	local h = AKScrH() * 0.05
	local w = h * 3.5
	local btn2 = Arknights.CreateButtonOutline(login_ui, AKScrW() * 0.85 - w * 0.5, AKScrH() - barheight + (barheight - h) * 0.5, w, h, "Exit", "Arknights_TitleButton", Color(255, 255, 255, 255), Color(85, 85, 85, 255), Color(255, 255, 255, 255), 1, function()
		if(Arknights.GameFrame.Exiting) then return end
		Arknights.GameFrame.Exit()
		Arknights.ButtonClickSound("back")
	end)
	local ui = Arknights.CreateFrame(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	login_ui:SetVisible(false)
	login_ui.Paint = function()
		if(!playsd && !suppressMusic) then
			Arknights.ShouldPlayMusic = true
			Arknights.ResetMusicState()
			Arknights.IdealMusic = "title02"
			playsd = true
		end
		if(startconnecting) then
			objectalpha = math.Clamp(objectalpha - Arknights.GetFixedValue(10), 0, 255)
			clr = math.Clamp(clr - Arknights.GetFixedValue(5), 30, 190)
			btn1:SetVisible(false)
			btn2:SetVisible(false)
			offs = math.Clamp(offs - Arknights.GetFixedValue(offs * 0.08), 0, offsmax)
			offs2 = math.Clamp(offs2 + Arknights.GetFixedValue((offs2max - offs2) * 0.08), offs2min, offs2max)
		else
			objectalpha = math.Clamp(objectalpha + Arknights.GetFixedValue(10), 0, 255)
			clr = math.Clamp(clr + Arknights.GetFixedValue(5), 30, 190)
			btn1:SetVisible(true)
			btn2:SetVisible(true)
			offs = math.Clamp(offs + Arknights.GetFixedValue((offsmax - offs) * 0.08), 0, offsmax)
			offs2 = math.Clamp(offs2 - Arknights.GetFixedValue((offs2 - offs2min) * 0.08), offs2min, offs2max)
		end
		if(nextparticle < Arknights.CurTimeUnScaled) then
			local offs = AKScrW() * 0.25
			local offs2 = AKScrW() * 0.1
			local sx = AKScreenScaleH(math.random(6, 11))
			if(startconnecting) then
				sx = sx * 0.5
			end
			local startx = AKScrW() * 0.5 - math.random(-offs, offs)
			table.insert(particles, {
				currentpos = Vector(startx, AKScrH() + sx, 0),
				targetpos = Vector(startx - math.random(-offs2, offs2), -AKScrH() * 0.1, 0),
				sx = sx,
			})
			if(startconnecting) then
				nextparticle = Arknights.CurTimeUnScaled + 0.05
			else
				nextparticle = Arknights.CurTimeUnScaled + 0.1
			end
		end
		draw.RoundedBox(0, 0, 0, AKScrW(), AKScrH(), Color(clr, clr, clr, 255))
		local revclr = (255 - objectalpha) * 0.6
		surface.SetDrawColor(revclr, revclr, revclr, 100)
		surface.SetMaterial(particle)
		surface.DrawTexturedRect(AKScrW() * 0.5 - dimsize * 0.5, -dimsize * 0.5, dimsize, dimsize)
		surface.SetDrawColor(255, 255, 255, 255)
		for k,v in pairs(particles) do
			if(v.currentpos.y <= -64) then
				table.remove(particles, k)
				continue
			end
			local offs = Arknights.GetFixedValue(v.targetpos - v.currentpos) * 0.1
			v.currentpos.x = v.currentpos.x + offs.x
			v.currentpos.y = v.currentpos.y + offs.y
			v.currentpos.z = v.currentpos.z + offs.z
			surface.DrawTexturedRect(v.currentpos.x, v.currentpos.y, v.sx, v.sx)
		end
		for k,v in ipairs(spheres) do
			if(Arknights.CurTimeUnScaled <= v.tlerp) then
				local offset = Arknights.GetFixedValue(v.angle - v.cangle) * 0.01
				v.cangle = v.cangle + offset
			else
				v.angle = v.angle + AngleRand(-30, 30)
				v.lerptime = math.random(2, 3)
				v.tlerp = Arknights.CurTimeUnScaled + v.lerptime
			end
			local pos = v.cangle:Forward() * offs2
			cam.Start3D(pos, (-pos):Angle() + Angle(offs, 0, 0), 75, 0, AKHOFFS, AKScrW(), AKScrH())
				render.SetColorMaterial()
				render.DrawWireframeSphere(Vector(0, 0, 0), v.size, v.v1, v.v2, Color(255, 215, 0, 255))
			cam.End3D()
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetMaterial(bottom)
		surface.DrawTexturedRect(0, 0, AKScrW(), barheight)
		surface.SetMaterial(top)
		surface.DrawTexturedRect(0, AKScrH() - barheight, AKScrW(), barheight + 2)
		draw.RoundedBox(0, 0, 0, AKScrW(), barheight, barcolor)
		draw.RoundedBox(0, 0, AKScrH() - barheight, AKScrW(), barheight, barcolor)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(hyperg)
		local _h = barheight * 0.8
		local _w = _h * 2.1
		local padding = (barheight - _h) * 0.5
		surface.DrawTexturedRect(sidegap, AKScrH() - _h - padding, _w, _h)
		surface.SetMaterial(smontagne)
		local _h = barheight * 0.55
		local _w = _h * 4.62
		local padding = (barheight - _h) * 0.5
		surface.DrawTexturedRect(sidegap * 2 + _w * 0.65, AKScrH() - _h - padding * 0.75, _w, _h)
		surface.SetDrawColor(255, 255, 255, 30 + (objectalpha / 255) * 225)
		surface.SetMaterial(rhd)
		surface.DrawTexturedRect((AKScrW() * 0.5) - rhdsize * 0.5, (AKScrH() * 0.325) - rhdsize * 0.5, rhdsize, rhdsize)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(aklogo)
		surface.SetDrawColor(255, 255, 255, objectalpha)
		local h = AKScrH() * 0.33
		local w = h * 2.8
		surface.DrawTexturedRect((AKScrW() * 0.5) - w * 0.5, (AKScrH() * 0.45) - h * 0.5, w, h)
		draw.DrawText("Ver : "..Arknights.Version, "Arknights_Common_Small", AKScrW() - sidegap, AKScrH() - sidegap * 2.5, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		local alp = 255 - objectalpha
		local out = 1
		local _w = AKScreenScaleH(74)
		local _h = _w * 2
		draw.RoundedBox(0, AKScrW() * 0.5 - _w * 0.5, AKScrH() * 0.5 - _h * 0.5, _w, _h, Color(45, 45, 45, alp * 0.95))
		surface.SetDrawColor(255, 255, 255, alp)
		surface.DrawOutlinedRect(AKScrW() * 0.5 - _w * 0.5, AKScrH() * 0.5 - _h * 0.5, _w, _h, out)
		draw.DrawText("Server", "Arknights_Common_Small_2x", AKScrW() * 0.5, (AKScrH() * 0.5) - _h * 0.5 + sidegap * 2, Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
		draw.DrawText("Terra", "Arknights_Common", AKScrW() * 0.5, (AKScrH() * 0.5) - _h * 0.5 + sidegap * 2 + AKScreenScaleH(6), Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
		draw.DrawText("#1", "Arknights_Common_Big_Arial", AKScrW() * 0.5, AKScrH() * 0.5 - _h * 0.1, Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
		if(startconnecting) then
			if(!fetching && nextfetch < Arknights.CurTimeUnScaled) then
				--[[
					http.Fetch("https://meiryiservice.xyz/arknights/status/fetch.txt",
						function(body, length, headers, code)
							if(body == "STATUS_OK") then
								__ok = true
							else
								fetching = false
								failedcount = failedcount + 1
							end
						end,
						function(message)
							fetching = false
							failedcount = failedcount + 1
						end
					)
				]]
				HTTP({
					failed = function(reason)
						fetching = false
						failedcount = failedcount + 1
					end,
					success = function(code, body, headers)
						if(body == "STATUS_OK") then
							__ok = true
						else
							fetching = false
							failedcount = failedcount + 1
						end
					end,
					timeout = 10,
					method = "GET",
					url = "https://meiryiservice.xyz/arknights/status/status.txt"
				})
				nextfetch = Arknights.CurTimeUnScaled + 3
				fetching = true
			end
			if(!__ok) then
				progress = math.Clamp(progress + Arknights.GetFixedValue(0.008), 0, 0.3)
			else
				progress = math.Clamp(progress + Arknights.GetFixedValue(0.02), 0, 1)
			end
		else
			progress = math.Clamp(progress - Arknights.GetFixedValue(0.015), 0, 1)
			fetching = false
		end
		if(!__ok) then
			if(failedcount >= 7) then
				failedcount = 0
				startconnecting = false
				fetching = false
				return
			end
			if(failedcount <= 1) then
				draw.DrawText("Connecting to the neural network of Rhodes Island.", "Arknights_Common_Small_2x", AKScrW() * 0.5, AKScrH() * 0.85, Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
			else
				draw.DrawText("Connecting to the neural network of Rhodes Island. [Retrying.. "..(failedcount - 1).."]", "Arknights_Common_Small_2x", AKScrW() * 0.5, AKScrH() * 0.85, Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
			end
		else
			draw.DrawText("Connected to the neural network of Rhodes Island.", "Arknights_Common_Small_2x", AKScrW() * 0.5, AKScrH() * 0.85, Color(255, 255, 255, alp), TEXT_ALIGN_CENTER)
		end
		if(progress > 0) then
			local prog = math.Round(progress, 2) * 100
			local w = (AKScrW() * 0.5) * progress
			local h = AKScreenScaleH(3)
			local scl = 0.575
			draw.RoundedBox(0, 0, AKScrH() * scl - h * 0.5, w, h, Color(255, 215, 0, 255))
			draw.DrawText(prog.."%", "Arknights_Common_Small_2x", w, AKScrH() * scl - h - AKScreenScaleH(8), Color(255, 215, 0, 255), TEXT_ALIGN_CENTER)
			draw.DrawText(prog.."%", "Arknights_Common_Small_2x", AKScrW() - w, AKScrH() * scl - h - AKScreenScaleH(8), Color(255, 215, 0, 255), TEXT_ALIGN_CENTER)
			draw.RoundedBox(0, AKScrW() - w, AKScrH() * scl - h * 0.5, w, h, Color(255, 215, 0, 255))
			if(progress >= 1 && !started) then
				Arknights.LoadingScreen("arknights/torappu/loadingillusts/default.png", {
					fulldim = function()
						ui:Remove()
						login_ui:Remove()
					end,
					finishedloading = function()
						Arknights.IdealMusic = "void"
						Arknights.HomePage()
					end
				})
				started = true
			end
		end
	end
	if(skip) then
		login_ui:SetVisible(true)
		ui:Remove()
		return
	end
	local mats = {}
	for k,v in ipairs(data) do
		mats[k] = {
			material = Arknights.GetCachedMaterial(v),
			switch = false,
			alpha = 0,
		}
	end
	local index = 1
	local max = #mats
	local switch = false
	local blank_stay = 0
	local image_stay = 0
	local stop = false
	login_ui:SetVisible(Arknights.SkipIntro)
	ui.Paint = function()
		local data = mats[index]
		surface.SetDrawColor(255, 255, 255, data.alpha)
		surface.SetMaterial(data.material)
		surface.DrawTexturedRect(0, 0, AKScrW(), AKScrH())
		if(!Arknights.SkipIntro) then
			if(!switch) then
				if(blank_stay < Arknights.CurTimeUnScaled) then
					data.alpha = math.Clamp(data.alpha + Arknights.GetFixedValue(10), 0, 255)
					if(data.alpha >= 255) then
						if(index >= max) then
							login_ui:SetVisible(true)
						end
						switch = true
					end
				end
				image_stay = Arknights.CurTimeUnScaled + 0.65
			else
				if(image_stay < Arknights.CurTimeUnScaled) then
					data.alpha = math.Clamp(data.alpha - Arknights.GetFixedValue(10), 0, 255)
					if(data.alpha <= 0) then
						if(index >= max) then
							stop = true
							ui:Remove()
						end
						index = math.min(index + 1, max)
						if(!stop) then
							switch = false
						end
					end
				end
				blank_stay = Arknights.CurTimeUnScaled + 0.2
			end
		end
		if(Arknights.SkipIntro) then
			ui:Remove()
		end
	end
end

function Arknights.HomePage()
	local ui = Arknights.CreatePanelMat(Arknights.GameFrame, 0, 0, AKScrW(), AKScrH(), Arknights.GetCachedMaterial("arknights/torappu/homepage/homebg.png"), Color(255, 255, 255, 255))
	local docter = Arknights.GetCachedMaterial("arknights/torappu/homepage/homepg/bg_rhodes_day_player.png")
	local dx, dy, dw = AKScrW() * 0.175, AKScrH() * 0.315, AKScrW() * 0.07
	local dh = dw * 3.6
	ui:SetZPos(-1)
	local buttons = {}
	local elems = {}
	local w = AKScrW() * 0.5
	local h = w * 0.275
	ui.Active = true
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.1, AKScrH() * 0.205, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_battle.png"), {
		x1 = AKScrW() * 0.535,
		x2 = AKScrW(),
		y1 = AKScrH() * 0.205,
		y2 = AKScrH() * 0.4475,
	}, function()
	if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		ui.Active = false
		Arknights.ModeSelectionMenu(ui)
		Arknights.ButtonClickSound("select")
	end))
	local w = AKScrW() * 0.1775
	local h = w * 0.435
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.325, AKScrH() * 0.455, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_char_repo.png"), {
		x1 = AKScrW() * 0.745,
		x2 = AKScrW(),
		y1 = AKScrH() * 0.455,
		y2 = AKScrH() * 0.5825,
	}, function()
		if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		Arknights.ButtonClickSound("select")
	end))
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.145, AKScrH() * 0.455, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_squad.png"), {
		x1 = AKScrW() * 0.575,
		x2 = AKScrW() * 0.75,
		y1 = AKScrH() * 0.455,
		y2 = AKScrH() * 0.5825,
	}, function()
		if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		ui.Active = false
		Arknights.ButtonClickSound("select")
		Arknights.SquadUI(ui)
	end))
	local w = AKScrW() * 0.1065
	local h = w * 0.725
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.425, AKScrH() * 0.595, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_recruit_advanced.png"), {
		x1 = AKScrW() * 0.74,
		x2 = AKScrW() * 0.8605,
		y1 = AKScrH() * 0.6,
		y2 = AKScrH() * 0.7225,
	}, function()
		if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		Arknights.ButtonClickSound("select")
	end))
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.425 - (w - AKScreenScaleH(1)), AKScrH() * 0.595, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_recruit_normal.png"), {
		x1 = AKScrW() * 0.86,
		x2 = AKScrW(),
		y1 = AKScrH() * 0.6,
		y2 = AKScrH() * 0.735,
	}, function()
		if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		Arknights.ButtonClickSound("select")
	end))
	local ow = w
	local w = AKScrW() * 0.1355
	local h = w * 0.569
	table.insert(buttons, Arknights.CreateMatButton3D2D(ui, AKScrW() * 0.435 - ow - w, AKScrH() * 0.595, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/btn_shop.png"), {
		x1 = AKScrW() * 0.62,
		x2 = AKScrW() * 0.74,
		y1 = AKScrH() * 0.595,
		y2 = AKScrH() * 0.715,
	}, function()
		if(!ui.Active || Arknights.IsWaitingRespond()) then return end
		Arknights.ButtonClickSound("select")
	end))
	local w = AKScrW() * 0.2015
	local h = w * 0.132
	local sidepadding = AKScreenScaleH(2)
	table.insert(buttons, Arknights.CreateMat3D2D(ui, AKScrW() * 0.425 - ((w * 0.5)) + sidepadding, (AKScrH() * 0.595) + AKScreenScaleH(4), w - sidepadding * 2, h - sidepadding * 2, Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/band_recruit.png")))

	local w = AKScrW() * 0.035
	local h = w * 0.96
	Arknights.CreateMat3D2D(ui, AKScrW() * 0.02, AKScrH() * 0.035, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/common/img_shadow.png"))
	Arknights.CreateMatButton(ui, AKScrW() * 0.02, AKScrH() * 0.035, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/common/leave.png"), function()
		if(!ui.Active) then return end
		Arknights.GameFrame.Exit()
		Arknights.ButtonClickSound("back")
	end)
	local w = AKScrW() * 0.045
	local h = w * 0.73
	Arknights.CreateMat3D2D(ui, AKScrW() * 0.075, AKScrH() * 0.035, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/common/img_shadow.png"))
	Arknights.CreateMatButton(ui, AKScrW() * 0.075, AKScrH() * 0.035, w, h, Arknights.GetCachedMaterial("arknights/torappu/homepage/common/batch.png"), function()
		if(!ui.Active) then return end
		Arknights.ButtonClickSound("select")
	end)

	local sx = AKScreenScaleH(64)
	Arknights.CircleAvatar(ui, AKScrW() * 0.05, AKScrH() * 0.4625 - sx * 0.5, sx, sx, LocalPlayer(), 186)
	local _, th, t = Arknights.CreateLabel(ui, AKScrW() * 0.05 + sx * 0.5, AKScrH() * 0.4625 + sx * 0.5 + AKScreenScaleH(2), LocalPlayer():Nick(), "Arknights_Common", Color(220, 220, 220, 255))
	t:CentHor()
	local _, _, t = Arknights.CreateLabel(ui, AKScrW() * 0.05 + sx * 0.5, AKScrH() * 0.4625 + sx * 0.5 + AKScreenScaleH(4) + th, "ID : "..LocalPlayer():SteamID64(), "Arknights_Common_Small_2x", Color(220, 220, 220, 255))
	t:CentHor()

	local yawoffset = 0
	local currentoffset = 0
	local maxoffset = 1
	local offs = {x = AKScrW() * -0.5, y = AKScrH() * -0.5}
	local sw, sh = AKScrW(), AKScrH()
	local cent = AKScrW() * 0.5
	local debugdrawing = false
	local rhodeslogo = Arknights.GetCachedMaterial("arknights/torappu/homepage/[uc]tm_rhodes_day/icon_rhodes.png")
	local rhodeslogosw = AKScreenScaleH(128)
	local rhodeslogosh = rhodeslogosw * 0.85
	ui.Paint2x = function()
		local mouseX, mouseY = input.GetCursorPos()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(docter)
		surface.DrawTexturedRect(dx, dy, dw, dh)

		local cangle = Angle(0, 25 + currentoffset, 0)
		local vvector = Vector(AKScrW(), -offs.x, -offs.y)
		local vangle = Angle(0, -90, 87)
		cam.Start3D(Vector(0, 0, 0), cangle, 55, 0, 0, AKScrW(), AKScrH())
			vgui.Start3D2D(vvector, vangle, 1)
				for k,v in ipairs(buttons) do
					v:Paint3D2D(cangle, vvector, vangle)
				end
			vgui.End3D2D()
		cam.End3D()
		if(debugdrawing) then
			surface.SetDrawColor(255, 80, 80, 100)
			for k,v in ipairs(buttons) do
				if(!v.pts) then continue end
				surface.DrawRect(v.pts.x1, v.pts.y1, v.pts.x2 - v.pts.x1, v.pts.y2 - v.pts.y1)
			end
		end
		local offset_fraction = math.Clamp((mouseX - cent) / cent, -1, 1)
		yawoffset = maxoffset * offset_fraction
		currentoffset = math.Clamp(currentoffset - Arknights.GetFixedValue((currentoffset - yawoffset) * 0.1), -maxoffset, maxoffset)

		surface.SetDrawColor(100, 100, 100, 255)
		surface.SetMaterial(rhodeslogo)
		surface.DrawTexturedRect(-AKScrW() * 0.04, AKScrH() * 0.5 - rhodeslogosh * 0.5, rhodeslogosw, rhodeslogosh)
	end
	Arknights.GameFrame.MainMenu = ui
end

function Arknights.BackButton(parent, func)
	local margin = AKScreenScaleH(16)
	local w = AKScreenScaleH(73)
	local h = w * 0.42
	local button = Arknights.CreatePanelMat(parent, margin, margin, w, h, Arknights.GetCachedMaterial("arknights/torappu/arts/[uc]common/ui/btn_backbutton.png"), Color(255, 255, 255, 255))
	function button:OnMousePressed()
		func()
		Arknights.ButtonClickSound("back")
	end
end

function Arknights.ModeSelectionMenu(attachUI)
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

	local w = AKScrW() * 0.35
	local h = w * 0.5
	local x = AKScrW() * 0.25
	local y = AKScrH() * 0.45
	local customLevel = Arknights.CreateMatButton(ui, x - w * 0.5, y - h * 0.5, w, h, Arknights.GetCachedMaterial("arknights/meiryi/arts/ui/modeselect/customlevels.png"), function()
		Arknights.ButtonClickSound("select")
		Arknights.FadeTransition(function()
			Arknights.CustomLevelUI()
		end)
	end)
	x = AKScrW() * 0.75
	local levelMaker = Arknights.CreateMatButton(ui, x - w * 0.5, y - h * 0.5, w, h, Arknights.GetCachedMaterial("arknights/meiryi/arts/ui/modeselect/levelmaker.png"), function()
		Arknights.ButtonClickSound("select")
		Arknights.FadeTransition(function()
			Arknights.LevelMakerUI()
		end)
	end)

	Arknights.BackButton(ui, function()
		ui.Exiting = true
		attachUI.Active = true
	end)
end

local okmaterial = Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_confirm.png")
function Arknights.PopupNotify(text, clickfunc)
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		ui.BlurPasses = 0
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui:MakePopup() -- So DTextEntry can receive inputs
		ui.Paint = function()
			ui.BlurPasses = math.Clamp(ui.BlurPasses + Arknights.GetFixedValue(1), 0, 6)
			Arknights.DrawBlur(ui, ui.BlurPasse, ui.BlurPasses * 1.5)
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(15), 0, 255)
				if(ui.Alpha <= 0) then
					ui:Remove()
				end
			else
				ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(15), 0, 255)
			end
			ui:SetAlpha(ui.Alpha)
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
		end
		local vertical_margin = AKScrH() * 0.35
		local inner = Arknights.CreatePanelMat(ui, 0, vertical_margin, AKScrW(), AKScrH() - (vertical_margin * 2), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"),Color(50, 50, 50, 255))
		local _, _, t = Arknights.CreateLabel(inner, inner:GetWide() * 0.5, inner:GetTall() * 0.5, text, "Arknights_Popup_2x", Color(220, 220, 220, 255))
		t.CentPos()
		local buttonTall = AKScreenScaleH(24)
		local okbutton = Arknights.InvisButton(inner, 0, inner:GetTall() - buttonTall, AKScrW(), buttonTall, function()
			if(ui.Exiting) then return end
			if(clickfunc) then
				clickfunc()
			end
			ui.Exiting = true
			Arknights.ButtonClickSound("select")
		end)
		local materialsize = okbutton:GetTall() * 0.65
		local offset = (okbutton:GetTall() - materialsize)
		okbutton.Paint = function()
			draw.RoundedBox(0, 0, 0, okbutton:GetWide(), okbutton:GetTall(), Color(0, 0, 0, 200))
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(okmaterial)
			surface.DrawTexturedRect(okbutton:GetWide() * 0.5 - materialsize * 0.5, offset * 0.5, materialsize, materialsize)
		end
end

function Arknights.PopupConfirm(data)
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		ui.BlurPasses = 0
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui:MakePopup() -- So DTextEntry can receive inputs
		ui.Paint = function()
			ui.BlurPasses = math.Clamp(ui.BlurPasses + Arknights.GetFixedValue(1), 0, 6)
			Arknights.DrawBlur(ui, ui.BlurPasse, ui.BlurPasses * 1.5)
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(15), 0, 255)
				if(ui.Alpha <= 0) then
					ui:Remove()
				end
			else
				ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(15), 0, 255)
			end
			ui:SetAlpha(ui.Alpha)
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
		end
		local iconoffs = AKScreenScaleH(2)
		local vertical_margin = AKScrH() * 0.4
		local horizontal_margin = AKScrW() * 0.2
		local inner = Arknights.CreatePanelMat(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"),Color(50, 50, 50, 255))
		local text_margin = AKScreenScaleH(8)
		local text1 = Arknights.CreateLabelBG(inner, text_margin, text_margin, data.t1, "Arknights_Popup_1x", data.tcolor, data.t1color, nil)
		Arknights.CreateLabelBG(inner, Arknights.GetGUINextPos(text1).x, text_margin, data.t2, "Arknights_Popup_1x", data.tcolor2 || data.tcolor, data.t2color, Arknights.GetCachedMaterial(data.tmat || "arknights/torappu/common_icon/icon_input.png"))
		local _, _, text = Arknights.CreateLabel(inner, inner:GetWide() * 0.5, inner:GetTall() * 0.5, data.centertext, "Arknights_ConfirmText", color_white)
		text.CentPos()
		local buttonWidth, buttonHeight = inner:GetWide() * 0.5, AKScreenScaleH(28)
		local cancel_button = Arknights.CreateMatButtonTextIcon(ui, inner:GetX(), inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_cancel_bkg.png"), "Cancel", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		local confirmbutton = Arknights.CreateMatButtonTextIcon(ui, inner:GetX() + inner:GetWide() * 0.5, inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_confirm_blue_bkg.png"), "Confirm", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_confirm.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			if(data.passfunc) then
				data.passfunc()
			end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		ui.InnerPanel = inner
end

function Arknights.PopupTextEntryMenu(data)
	local ui = Arknights.CreateFrame(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		ui.BlurPasses = 0
		ui.Alpha = 0
		ui.Exiting = false
		ui:SetAlpha(0)
		ui:MakePopup() -- So DTextEntry can receive inputs
		ui.Paint = function()
			ui.BlurPasses = math.Clamp(ui.BlurPasses + Arknights.GetFixedValue(1), 0, 6)
			Arknights.DrawBlur(ui, ui.BlurPasse, ui.BlurPasses * 1.5)
			if(ui.Exiting) then
				ui.Alpha = math.Clamp(ui.Alpha - Arknights.GetFixedValue(15), 0, 255)
				if(ui.Alpha <= 0) then
					ui:Remove()
				end
			else
				ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(15), 0, 255)
			end
			ui:SetAlpha(ui.Alpha)
			Arknights.StageMaker.StopClickTime = SysTime() + 0.25
		end
		local iconoffs = AKScreenScaleH(2)
		local vertical_margin = AKScrH() * 0.4
		local horizontal_margin = AKScrW() * 0.2
		local inner = Arknights.CreatePanelMat(ui, horizontal_margin, vertical_margin, AKScrW() - (horizontal_margin * 2), AKScrH() - (vertical_margin * 2), Arknights.GetCachedMaterial("arknights/torappu/bg/bg9.png"),Color(50, 50, 50, 255))
		local text_margin = AKScreenScaleH(8)
		local text1 = Arknights.CreateLabelBG(inner, text_margin, text_margin, data.t1, "Arknights_Popup_1x", data.tcolor, data.t1color, nil)
		Arknights.CreateLabelBG(inner, Arknights.GetGUINextPos(text1).x, text_margin, data.t2, "Arknights_Popup_1x", data.tcolor2 || data.tcolor, data.t2color, Arknights.GetCachedMaterial(data.tmat || "arknights/torappu/common_icon/icon_input.png"))
		local textentry_margin = AKScreenScaleH(32)
		local textentry_wide, textentry_tall = inner:GetWide() - (textentry_margin * 2), AKScreenScaleH(18)
		local text_entry = Arknights.CreateTextEntry(inner, textentry_margin, inner:GetTall() * 0.5 - textentry_tall * 0.5, textentry_wide, textentry_tall, data.ptext, "Arknights_TextEntry_PlaceHolder_1x", Color(255, 255, 255, 255), Color(120, 120, 120, 255), Color(80, 80, 80, 255))
		if(data.deftext) then
			text_entry:SetValue(data.deftext)
		end
		local buttonWidth, buttonHeight = inner:GetWide() * 0.5, AKScreenScaleH(28)
		local cancel_button = Arknights.CreateMatButtonTextIcon(ui, inner:GetX(), inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_cancel_bkg.png"), "Cancel", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_cancel.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			ui.Exiting = true
		end)
		local confirmbutton = Arknights.CreateMatButtonTextIcon(ui, inner:GetX() + inner:GetWide() * 0.5, inner:GetY() + inner:GetTall(), buttonWidth, buttonHeight, Arknights.GetCachedMaterial("arknights/torappu/button/btn_confirm_blue_bkg.png"), "Confirm", "Arknights_Popup_1x", Color(255, 255, 255, 255), Arknights.GetCachedMaterial("arknights/torappu/common_icon/btn_icon_confirm.png"), {x = 0, y = -iconoffs}, function()
			if(ui.Exiting) then return end
			Arknights.ButtonClickSound("select")
			if(data.condfunc) then
				if(!data.condfunc(text_entry:GetValue())) then
					return
				else
					if(data.passfunc) then
						data.passfunc(text_entry:GetValue())
					end
				end
			end
			ui.Exiting = true
		end)
		ui.InnerPanel = inner
end

function Arknights.RespondWaiting()
	if(!IsValid(Arknights.FetchingPanel)) then return end
	Arknights.FetchingPanel.Respond()
end

Arknights.FetchingPanel = Arknights.FetchingPanel || nil
function Arknights.WaitingIndicator(supppressFallback)
	local ui = Arknights.CreatePanel(nil, 0, AKHOFFS, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	ui:MakePopup()
	local tall = 0
	local target_tall = AKScrH() * 0.125
	local alphamul = 0
	local timeout = Arknights.CurTimeUnScaled + 10
	local responded = false
	local timedout = false
	local static_flash_size = AKScreenScaleH(28)
	local static_X, static_Y = (AKScrW() * 0.5) - static_flash_size * 0.5,  (AKScrH() - target_tall) + (target_tall - static_flash_size) * 0.5
	local flash_size = static_flash_size
	local flash_alpha = 0
	local flash_interval = 0.75
	local flash_next_t = Arknights.CurTimeUnScaled + flash_interval
	local flash_target_s = static_flash_size * 4
	local flashmat = Arknights.GetCachedMaterial("arknights/torappu/loading/white_t.png")
	ui:SetZPos(32767)
	ui.Paint = function()
		if(!responded && !timedout) then
			tall = math.Clamp(tall + Arknights.GetFixedValue(12), 0, target_tall)
			if(timeout < Arknights.CurTimeUnScaled) then
				timedout = true
			end
		else
			tall = math.Clamp(tall - Arknights.GetFixedValue(12), 0, target_tall)
			if(tall <= 0) then
				if(timedout && !supppressFallback) then -- Lost connection
					Arknights.LoadingScreen("arknights/torappu/loadingillusts/default.png", {
						finishedloading = function()
							if(!IsValid(Arknights.GameFrame) || !IsValid(Arknights.GameFrame.MainMenu)) then return end
							Arknights.GameFrame.MainMenu:Remove()
							Arknights.StartupSequence({}, true, true)
							Arknights.IdealMusic = "title02"
						end
					})
				end
				ui:Remove()
			end
		end
		draw.RoundedBox(0, 0, AKScrH() - tall, AKScrW(), tall, Color(0, 0, 0, 150))
		alphamul = math.Clamp(tall / target_tall, 0, 1)
		surface.SetMaterial(flashmat)
		surface.SetDrawColor(255, 255, 255, 255 * alphamul)
		surface.DrawTexturedRect(static_X, static_Y, static_flash_size, static_flash_size)
		if(flash_next_t < Arknights.CurTimeUnScaled) then
			flash_size = static_flash_size
			flash_alpha = 255
			flash_next_t = Arknights.CurTimeUnScaled + flash_interval
		else
			flash_size =	math.Clamp(flash_size + Arknights.GetFixedValue((flash_target_s - flash_size) * 0.085), static_flash_size, flash_target_s)
			flash_alpha = math.Clamp((0.9 - math.Clamp((flash_size / flash_target_s), 0, 1)) * 255, 0, 255)
		end
		surface.SetDrawColor(255, 255, 255, flash_alpha * alphamul)
		surface.DrawTexturedRect((AKScrW() * 0.5) - (flash_size * 0.5), (AKScrH() - target_tall * 0.5) - flash_size * 0.5, flash_size, flash_size)
		draw.DrawText("Submitting feedback to neural network...", "Arknights_Common_Small_3x", static_X + flash_target_s * 0.65, AKScrH() - ((target_tall * 0.5) + AKScreenScaleH(5)), Color(255, 255, 255, 255 * alphamul), TEXT_ALIGN_LEFT)
	end
	ui.Respond = function()
		responded = true
	end

	Arknights.FetchingPanel = ui
end