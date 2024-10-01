Arknights.CachedMaterial = Arknights.CachedMaterial || {}
Arknights.CachedSpineAnimation = Arknights.CachedSpineAnimation || {}

function Arknights.ClearCaches()
	Arknights.CachedMaterial = {}
end

function Arknights.RefreshMaterialCaches()
	for k,v in pairs(Arknights.CachedMaterial) do
		Arknights.CachedMaterial[k] = Material(k, "smooth")
	end
end

Arknights.MaterialIndex = Arknights.MaterialIndex || 0
function Arknights.GetCachedVMaterial(material)
	if(!Arknights.CachedMaterial[material]) then
		Arknights.CachedMaterial[material] = CreateMaterial("arknights_material"..Arknights.MaterialIndex, "VertexLitGeneric", {
			["$basetexture"] = material,
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
			--["$noclull"] = 0, -- This will messup meshes
		})
		Arknights.MaterialIndex = Arknights.MaterialIndex + 1
	end
	return Arknights.CachedMaterial[material]
end

function Arknights.GetCachedMaterial(material)
	if(!Arknights.CachedMaterial[material]) then
		Arknights.CachedMaterial[material] = Material(material, "smooth")
	end
	return Arknights.CachedMaterial[material]
end