function Arknights.GetFixedValue(inputNum) 
    local target = 0.016666
    return inputNum / (target / RealFrameTime())
end

function Arknights.GetTextSize(font, text)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

function Arknights.CreateImage(parent, x, y, w, h, image, color)
    if(!color) then color = color_white end
    local img = vgui.Create("DImage", parent)
        img:SetPos(x, y)
        img:SetSize(w, h)
        img:SetImage(image)
        img:SetImageColor(color)

    return img
end

function Arknights.CreateFrame(parent, x, y, w, h, color)
    local panel = vgui.Create("DFrame", parent)
        panel:SetPos(x, y)
        panel:SetSize(w, h)
        panel:SetDraggable(false)
        panel:SetTitle("")
        panel:ShowCloseButton(false)
        panel.Alpha = color.a
        panel.Paint = function()
            draw.RoundedBox(0, 0, 0, w, h, Color(color.r, color.g, color.b, panel.Alpha))
        end
    return panel
end

function Arknights.CreatePanelMat(parent, x, y, w, h, mat, color)
    local panel = vgui.Create("DPanel", parent)
        panel:SetPos(x, y)
        panel:SetSize(w, h)
        panel.Paint2x = function() end
        panel.Paint = function()
            surface.SetDrawColor(color.r, color.g, color.b, color.a)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, w, h)
            panel.Paint2x()
        end
    return panel
end

function Arknights.CreatePanel(parent, x, y, w, h, color, r)
    r = r || 0
    local panel = vgui.Create("DPanel", parent)
        panel:SetPos(x, y)
        panel:SetSize(w, h)
        panel.Paint = function()
            draw.RoundedBox(r, 0, 0, w, h, color)
        end
    return panel
end

function Arknights.CreateLabel(parent, x, y, text, font, color, bg, bgcolor)
    local label = vgui.Create("DLabel", parent)
        label.oPos = Vector(x, y)
        label:SetPos(x, y)
        label:SetFont(font)
        label:SetText(text)
        label:SetColor(color)
        local w, h = Arknights.GetTextSize(font, label:GetText())
        label:SetSize(w, h)

        label.CentHor = function()
            local w, h = Arknights.GetTextSize(font, label:GetText())
            label:SetPos(label.oPos.x - w / 2, label.oPos.y)
            label:SetSize(w, h)
        end

        label.CentVer = function()
            local w, h = Arknights.GetTextSize(font, label:GetText())
            label:SetPos(label.oPos.x, label.oPos.y - h / 2)
            label:SetSize(w, h)
        end

        label.CentPos = function()
            local w, h = Arknights.GetTextSize(font, label:GetText())
            label:SetPos(label.oPos.x - w / 2, label.oPos.y - h / 2)
            label:SetSize(w, h)
        end

        label.UpdateText = function(text)
            label:SetText(text)
            local w, h = Arknights.GetTextSize(font, label:GetText())
            label:SetSize(w, h)
        end

        if(bg) then
            label.oPaint = label.Paint
            label.Paint = function()
                draw.RoundedBox(0, 0, 0, label:GetWide(), label:GetTall(), bgcolor)
                label.oPaint(label)
            end
        end

    local tw, th = Arknights.GetTextSize(font, label:GetText())
    return tw, th, label
end

function Arknights.CreateScroll(parent, x, y, w, h, color)
    local frame = vgui.Create("DScrollPanel", parent)
    frame:SetPos(x, y)
    frame:SetSize(w, h)
    frame.Paint = function() draw.RoundedBox(0, 0, 0, w, h, color) end

    frame.ScrollAmount = AKScreenScaleH(64) -- You can change it with returned panel object
    frame.Smoothing = 0.2

    frame.CurrrentScroll = 0
    frame.MaximumScroll = 0 -- Don't touch this value

    local DVBar = frame:GetVBar()
    local down = false
    local clr = 0

    DVBar:SetWide(AKScreenScaleH(4))
    DVBar:SetX(DVBar:GetX() - DVBar:GetWide())

    DVBar.Think = function()
        frame.MaximumScroll = DVBar.CanvasSize
        if(down) then return end
        local dvscroll = DVBar:GetScroll()
        local step = frame.CurrrentScroll - dvscroll
        if(math.abs(step) > 1) then
            clr = 125
        end
        DVBar:SetScroll(dvscroll + Arknights.GetFixedValue(step * frame.Smoothing))
    end

    function frame:OnMouseWheeled(delta)
        frame.CurrrentScroll = math.Clamp(frame.CurrrentScroll + frame.ScrollAmount * -delta, 0, frame.MaximumScroll)
    end

    function DVBar:Paint(drawW, drawH)
        draw.RoundedBox(0, 0, 0, drawW, drawH, Color(0, 0, 0, 150))
    end

    function DVBar.btnUp:Paint() return end
    function DVBar.btnDown:Paint() return end

    DVBar.btnGrip.oOnMousePressed = DVBar.btnGrip.OnMousePressed
    function DVBar.btnGrip.OnMousePressed(self, code)
        down = true
        DVBar.btnGrip.oOnMousePressed(self, code)
        frame.CurrrentScroll = DVBar:GetScroll()
    end
    DVBar.oOnMousePressed = DVBar.OnMousePressed
    function DVBar.OnMousePressed(self, code)
        down = true
        DVBar.oOnMousePressed(self, code)
    end

    function DVBar.btnGrip:Paint(drawW, drawH)
        local roundWide = drawW * 0.5
        if(DVBar.btnGrip:IsHovered()) then
            clr = math.Clamp(clr + Arknights.GetFixedValue(8), 0, 80)
            if(input.IsMouseDown(107) && !down) then
                down = true
            end
        else
            clr = math.Clamp(clr - Arknights.GetFixedValue(8), 0, 80)
        end

        if(down && !input.IsMouseDown(107)) then
            down = false
        end

        if(down) then
            frame.CurrrentScroll = DVBar:GetScroll()
            clr = 125
        end

        local _color = 130 + clr
        draw.RoundedBox(roundWide, 0, 0, drawW, drawH, Color(_color, _color, _color, 255))
    end
    return frame
end

function Arknights.InvisButton(parent, x, y, w, h, func)
    local btn = vgui.Create("DButton", parent)
        btn:SetPos(x, y)
        btn:SetSize(w, h)
        btn:SetText("")
        btn.Paint = function() end
        btn.DoClick = func
        
        return btn
end

function Arknights.CreateButton(parent, x, y, w, h, text, font, tcolor, bcolor, func, r)
    if(!r) then r = 0 end
    local b = vgui.Create("DButton", parent)
    b:SetPos(x, y)
    b:SetSize(w, h)
    b:SetText(text)
    b:SetFont(font)
    b:SetTextColor(tcolor)
    b.Paint = function() draw.RoundedBox(r, 0, 0, b:GetWide(), b:GetTall(), bcolor) end
    b.DoClick = func
    return b
end

function Arknights.CreateButtonOutline(parent, x, y, w, h, text, font, tcolor, color, ocolor, os, func)
    local button = vgui.Create("DPanel", parent)
        button:SetPos(x, y)
        button:SetSize(w, h)
        local tw, th = Arknights.GetTextSize(font, text)
        local _x, _y = w * 0.5, (h * 0.5) - (th * 0.5)
        button.Paint = function()
            draw.RoundedBox(0, 0, 0, w, h, ocolor)
            draw.RoundedBox(0, os, os, w - os * 2, h - os * 2, color)
            draw.DrawText(text, font, _x, _y, tcolor, TEXT_ALIGN_CENTER)
        end
        function button:OnMousePressed()
            func()
        end
    return button
end

function Arknights.CreateMatButton(parent, x, y, w, h, mat, func)
    local bg = Arknights.CreateFrame(parent, x, y, w, h, Color(0, 0, 0, 0))
    local clr = 255
    local keydown = false
    local hovered = false
    bg:NoClipping(false)
    bg.Paint2x = function() end
    bg.Paint = function()
        surface.SetDrawColor(clr, clr, clr, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
        bg.Paint2x()
    end
    function bg:OnMousePressed()
        func()
    end
    return bg
end

function Arknights.CreateMatButton3D2D(parent, x, y, w, h, mat, buttonpts, func)
    local bg = Arknights.CreateFrame(parent, x, y, w, h, Color(0, 0, 0, 0))
    local clr = 255
    local keydown = false
    local hovered = false
    bg:NoClipping(false)
    bg.Paint2x = function() end
    bg.Paint = function()
        surface.SetDrawColor(clr, clr, clr, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
        local state = input.IsMouseDown(107)
        local cx, cy = input.GetCursorPos()
        cy = cy - AKHOFFS
        if(cx > buttonpts.x1 && cx < buttonpts.x2 && cy > buttonpts.y1 && cy < buttonpts.y2) then
            if(state && !keydown) then
                func()
            end
            hovered = true
        else
            hovered = false
        end
        keydown = state
        bg.Paint2x()
    end
    bg.pts = buttonpts
    return bg
end

function Arknights.CreateMat3D2D(parent, x, y, w, h, mat)
    local bg = Arknights.CreateFrame(parent, x, y, w, h, Color(0, 0, 0, 0))
    local clr = 255
    local keydown = false
    local hovered = false
    bg:NoClipping(false)
    bg.Paint2x = function() end
    bg.Paint = function()
        surface.SetDrawColor(clr, clr, clr, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    return bg
end

function Arknights.CircleAvatar(parent, x, y, w, h, player, resolution)
    local base = Arknights.CreatePanel(parent, x, y, w, h, Color(30, 30, 30, 255))
    local av = base:Add("AvatarImage")
    local c = Arknights.BuildCircle(base:GetWide() / 2, base:GetTall() / 2, base:GetWide() * 0.5)
    av:SetSize(w, h)
    av:SetPlayer(player, resolution)
    av:SetPaintedManually(true)
    base.Paint = function()
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilTestMask(0xFF)
        render.SetStencilWriteMask(0xFF)
        render.SetStencilReferenceValue(0x01)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_REPLACE)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawPoly(c)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        av:PaintManual()
        render.SetStencilEnable(false)
    end
    return base
end

local circle_seg = 64
function Arknights.BuildCircle(x, y, radius)
    local c = {}
    table.insert(c, {x = x, y = y})

    for i = 0, circle_seg do
        local a = math.rad(i / circle_seg * -360)
        table.insert(c, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius
        })
    end

    local a = math.rad(0)
    table.insert(c, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius
    })
    return c
end

local blur = Material("pp/blurscreen")
function Arknights.DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)
    for i = 1, 6 do
        blur:SetFloat("$blur", (i / 6) * amount)
        blur:Recompute()
        render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(x * -1, y * -1, AKScrW(), AKScrH())
    end
end

function Arknights.DrawFilledCircle(x, y, radius, scl)
    local cir = {}
    local seg = 30
    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * (-360 * scl))
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end
    surface.DrawPoly( cir )
end

function Arknights.CircleTimerAnimation(x, y, radius, thickness, t, color)
    draw.NoTexture()
    surface.SetDrawColor(color.r, color.g, color.b, color.a) -- Don't use Color(), it's slow af, check wiki

    render.ClearStencil()

    render.SetStencilEnable(true)
    render.SetStencilTestMask(0xFF)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilReferenceValue(0x01)

    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_REPLACE)
    Arknights.DrawFilledCircle(x, y, radius - thickness, 1)
    render.SetStencilCompareFunction(STENCIL_GREATER)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    Arknights.DrawFilledCircle(x, y, radius, t)
    render.SetStencilEnable(false)
end