AKSW = ScrW()
AKSH = ScrH()
AKHOFFS = 0

function AKScrW()
	return AKSW
end

function AKScrH()
	return AKSH
end

function AKScreenScaleH(height)
	return height * (AKSH / 480)
end

hook.Add("DrawOverlay", "Arknights_AspectRatioChecker", function()
	AKSW = ScrW()
	AKSH = AKSW * 0.5625

	AKHOFFS = math.max(0, (ScrH() - AKScrH()) * 0.5)
end)