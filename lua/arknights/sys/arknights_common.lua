local bypassUI = true

function Arknights.GetFixedValue(input)
    if(gui.IsGameUIVisible() && !bypassUI) then
        return input * 0
    end
    local target = 0.016666
    return input / (target / ARKNIGHTS_LASTFRAMETIME)
end

function Arknights.GetFixedMovingSpeed(input)
    if(gui.IsGameUIVisible() && !bypassUI) then
        return input * 0
    end
    local target = 1
    return input / (target / ARKNIGHTS_LASTFRAMETIME)
end

function Arknights.ConsoleCommand(cmd)
    LocalPlayer():ConCommand(cmd)
end