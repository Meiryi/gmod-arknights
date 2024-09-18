Arknights.CachedMaterial = Arknights.CachedMaterial || {}
Arknights.CachedSpineAnimation = Arknights.CachedSpineAnimation || {}

function Arknights.RefreshMaterialCaches()
	for k,v in pairs(Arknights.CachedMaterial) do
		Arknights.CachedMaterial[k] = Material(k, "smooth")
	end
end

function Arknights.GetCachedMaterial(material)
	if(!Arknights.CachedMaterial[material]) then
		Arknights.CachedMaterial[material] = Material(material, "smooth")
	end
	return Arknights.CachedMaterial[material]
end