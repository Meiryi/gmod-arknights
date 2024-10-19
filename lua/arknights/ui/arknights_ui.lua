Arknights.GameActive = Arknights.GameActive || false
Arknights.GameFrame = Arknights.GameFrame || nil

local skip = false
local reload = true
function Arknights.Launch()
	if(IsValid(Arknights.GameFrame)) then
		if(!reload) then
			return
		else
			Arknights.GameFrame:Remove()
		end
	end
	if(skip) then
		Arknights.DirectToHome()
		return
	end
	Arknights.ReadNames()
	local basepanel = Arknights.CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
	basepanel:MakePopup()
	local ui = Arknights.CreateFrame(basepanel, 0, math.max(0, (ScrH() - AKScrH()) * 0.5), AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	ui.BasePanel = basepanel
	basepanel.Think = function()
		basepanel.Alpha = math.Clamp(basepanel.Alpha + Arknights.GetFixedValue(10), 0, 255)
		if(!IsValid(ui)) then
			basepanel:Remove()
		end
	end
	Arknights.GameFrame = ui
	ui.SequenceStarted = false
	ui.Exiting = false
	ui.Alpha = 0
	ui.Think = function()
		ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(10), 0, 255)
		if(ui.Alpha >= 255 && !ui.SequenceStarted) then
			Arknights.StartupSequence({
				"arknights/meiryi/arts/ui/startup01-v2.png",
				"arknights/meiryi/arts/ui/startup02.png",
				"arknights/meiryi/arts/ui/startupfinal.png",
			})
			ui.SequenceStarted = true
		end
	end
	ui.Exit = function()
		local exit = Arknights.CreateFrame(ui, 0, 0, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		exit.Think = function()
			exit.Alpha = math.Clamp(exit.Alpha + Arknights.GetFixedValue(5), 0, 255)
			if(exit.Alpha >= 255) then
				ui:Remove()
			end
		end
	end
end

function Arknights.IsGameActive()
	return IsValid(Arknights.GameFrame)
end

function Arknights.IsGameFrameVisible()
	return Arknights.GameFrame.BasePanel:IsVisible()
end

function Arknights.DirectToHome()
	local basepanel = Arknights.CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
	basepanel:MakePopup()
	local ui = Arknights.CreateFrame(basepanel, 0, math.max(0, (ScrH() - AKScrH()) * 0.5), AKScrW(), AKScrH(), Color(0, 0, 0, 0))
	ui.BasePanel = basepanel
	basepanel.Think = function()
		basepanel.Alpha = math.Clamp(basepanel.Alpha + Arknights.GetFixedValue(10), 0, 255)
		if(!IsValid(ui)) then
			basepanel:Remove()
		end
	end
	Arknights.GameFrame = ui
	ui.SequenceStarted = false
	ui.Exiting = false
	ui.Alpha = 0
	ui.Think = function()
		ui.Alpha = math.Clamp(ui.Alpha + Arknights.GetFixedValue(10), 0, 255)
	end
	ui.Exit = function()
		local exit = Arknights.CreateFrame(ui, 0, 0, AKScrW(), AKScrH(), Color(0, 0, 0, 0))
		exit.Think = function()
			exit.Alpha = math.Clamp(exit.Alpha + Arknights.GetFixedValue(5), 0, 255)
			if(exit.Alpha >= 255) then
				ui:Remove()
			end
		end
	end
	Arknights.StartMusic("void")
	Arknights.HomePage()
end

hook.Add("PreDrawViewModel", "Arknights_HideVM", function()
	local hide = Arknights.IsGameActive()
	LocalPlayer():DrawViewModel(!hide)
	return hide
end)