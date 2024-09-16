function Arknights.GetFixedValue(input)
    local target = 0.016666
    return input / (target / RealFrameTime())
end

function Arknights.ConsoleCommand(cmd)
    LocalPlayer():ConCommand(cmd)
end