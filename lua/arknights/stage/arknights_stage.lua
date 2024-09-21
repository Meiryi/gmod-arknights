Arknights.Stage = Arknights.Stage || {}
Arknights.Stage.Editmode = Arknights.Stage.Editmode || false
Arknights.Stage.ViewPointOrigin = Vector(0, 0, -25000)
Arknights.Stage.ViewPointAngle = Angle(50, 180, 0)
Arknights.Stage.ViewPointFOV = 60
Arknights.Stage.StructureOrigin = Vector(0, 0, -25200)

Arknights.Stage.GridSize = 48
Arknights.Stage.StructureID = 0

Arknights.Stage.Music = Arknights.Stage.Music || "indust"
Arknights.Stage.MapID = Arknights.Stage.MapID || "NULL"
Arknights.Stage.MapName = Arknights.Stage.MapName || "NULL"
Arknights.Stage.Author = Arknights.Stage.Author || "NULL"
Arknights.Stage.Background = Arknights.Stage.Background || "arknights/torappu/map/TX_LMC_BG.png"
Arknights.Stage.CreationDate = Arknights.Stage.CreationDate || -1

Arknights.Stage.Data = Arknights.Stage.Data || {}
Arknights.Stage.Size = Arknights.Stage.Size || {w = 16, h = 16}
Arknights.Stage.Enemies = Arknights.Stage.Enemies || {}
Arknights.Stage.Paths = Arknights.Stage.Paths || {}
Arknights.Stage.Structures = Arknights.Stage.Structures || {}
Arknights.Stage.Structures_Details = Arknights.Stage.Structures_Details || {}

function Arknights.CreateDebugOperator()
	if(IsValid(AKT)) then
		AKT:Remove()
		return
	end
	AKT = ents.CreateClientside("arknights_operator_base")
	AKT:Spawn()
end

function Arknights.MoveDebugOperator()
	if(!IsValid(AKT)) then return end
	AKT:SetPos(LocalPlayer():GetPos())
end

function Arknights.MoveDebugOperatorToViewOrigin(offset)
	if(!IsValid(AKT)) then return end
	AKT:SetPos(Arknights.Stage.ViewPointOrigin + (offset || Vector(0, 0, 0)))
end

function Arknights.RemoveDebugOperator()
	if(!IsValid(AKT)) then return end
	AKT:Remove()
end
