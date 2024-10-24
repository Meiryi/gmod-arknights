Arknights.CachedMaterial = Arknights.CachedMaterial || {}
Arknights.CachedSpineAnimation = Arknights.CachedSpineAnimation || {}

function Arknights.ClearCaches()
	Arknights.CachedMaterial = {}
	Arknights.CachedSpineAnimation = {}
	Arknights.Portraits = {}
end

function Arknights.CacheSpineAnimations(basefolder, entityid)
	if(Arknights.CachedSpineAnimation[entityid]) then
		return Arknights.CachedSpineAnimation[entityid]
	end
	local animations = {}
	local _, sides = file.Find("materials/arknights/assets/"..basefolder.."/"..entityid.."/*", "GAME")
	if(#sides <= 0) then -- Invalid path or entity id
		return nil
	end
	for _, side in pairs(sides) do
		animations[side] = {}
		local _, anims = file.Find("materials/arknights/assets/"..basefolder.."/"..entityid.."/"..side.."/*", "GAME")
		for _, anim in pairs(anims) do
			animations[side][anim] = {}
			local animation_frames = file.Find("materials/arknights/assets/"..basefolder.."/"..entityid.."/"..side.."/"..anim.."/*.png", "GAME")
			for _, frame in pairs(animation_frames) do
				local material = Material("arknights/assets/"..basefolder.."/"..entityid.."/"..side.."/"..anim.."/"..frame, "smooth")
				table.insert(animations[side][anim], material)
			end
		end
	end
	Arknights.CachedSpineAnimation[entityid] = animations
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
			["$noclull"] = 0,
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

function Arknights.CachePortraits()
	local f = file.Find("materials/arknights/operators/portraits/*.png", "GAME")
	for k,v in ipairs(f) do
		local n = string.Replace(v, ".png", "")
		Arknights.Portraits[n] = Material("materials/arknights/operators/portraits/"..v, "smooth")
	end
end
Arknights.CachePortraits()