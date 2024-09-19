function Arknights.ToggleGameFrame(vis)
	if(!IsValid(Arknights.GameFrame)) then return end
	Arknights.GameFrame.BasePanel:SetVisible(vis)
end