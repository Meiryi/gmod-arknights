Arknights.CachedMaterial = Arknights.CachedMaterial || {}
Arknights.CachedSpineAnimation = Arknights.CachedSpineAnimation || {}

function Arknights.GetCachedMaterial(material)
	if(!Arknights.CachedMaterial[material]) then
		Arknights.CachedMaterial[material] = Material(material, "smooth")
	end
	return Arknights.CachedMaterial[material]
end