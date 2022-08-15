local plr, char, mouse, human, torso
repeat wait(); plr = game.Players.LocalPlayer until plr
repeat wait(); mouse = plr:GetMouse() until mouse
local input = game:GetService("UserInputService")

local ui_toggle_fly
local flying = false
local flyspeed = 65
local oldproperties = {}

do
    function UpdateCharacter ()
        char = plr.Character
        human = char:WaitForChild("Humanoid")
        torso = human.Torso
    end
    repeat wait() until plr.Character
    UpdateCharacter()
    plr.CharacterAdded:Connect(UpdateCharacter)
    plr.CharacterRemoving:Connect(function()
        ui_toggle_fly:Set(false)
    end)
end

function SetOldProperty (obj, prop)
    if not oldproperties[prop] then
        oldproperties[prop] = {}
    end
    oldproperties[prop][obj] = obj[prop]
end

function RestoreOldProperties (prop)
    for obj,oldv in pairs(oldproperties[prop]) do
        obj[prop] = oldv
        oldproperties[prop][obj] = nil
    end
end

function SetAllPropertiesIf (inherits, prop, newvalue, canchange)
    for _,v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA(inherits) and (canchange==nil or canchange(v[prop])) then
            SetOldProperty(v, prop)
            v[prop] = newvalue
        end
    end
end

function SetAllProperties (inherits, prop, newvalue)
     SetAllPropertiesIf(inherits, prop, newvalue, nil)
end

--[[
--
-- UI
--
--]]

local pepsi = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)():CreateWindow({
    Name = "Epic",
    Themeable = {
        Info = "Discord Server: VzYTJ7Y"
    }
})
local general = pepsi:CreateTab({ Name="General" })

--[[
--
-- EPIC
--
--]]

do
    local epic = general:CreateSection({ Name="Epic" })
    
    epic:AddToggle({ Name="Neons", Key=true, Value=true, Callback=function(yes)
        if yes then RestoreOldProperties("Material")
        else SetAllPropertiesIf("BasePart", "Material", Enum.Material.Plastic, function(v) return v==Enum.Material.Neon end)
        end
    end})
    
    epic:AddToggle({ Name="Moving Parts", Key=true, Value=true, Callback=function(yes)
        if yes then RestoreOldProperties("Velocity")
        else SetAllProperties("BasePart", "Velocity", Vector3.zero)
        end
    end})
    epic:AddSlider({ Name="Walk speed", Value=human.WalkSpeed, Min=1, Max=1000, Callback=function(v)
        human.WalkSpeed = v
    end})
end

--[[
--
-- FLY
--
--]]

do
    local useplatformstand = true
    local left, right, up, down, frwd, back, x2, x3
    
    function Fly ()
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        local bv = Instance.new("BodyVelocity", torso)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        if useplatformstand then human.PlatformStand = true end
        
        repeat
            local camframe = game.Workspace.CurrentCamera.CoordinateFrame
            bg.cframe = camframe
            bv.velocity = Vector3.zero
            local markiplier = (input:IsKeyDown(x3:Get()) and 3) or (input:IsKeyDown(x2:Get()) and 2) or 1
            if input:IsKeyDown(frwd:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector end
            if input:IsKeyDown(left:Get())  then bv.velocity += flyspeed * markiplier * camframe.RightVector * -1 end
            if input:IsKeyDown(back:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector * -1 end
            if input:IsKeyDown(right:Get()) then bv.velocity += flyspeed * markiplier * camframe.RightVector end
            if input:IsKeyDown(up:Get())    then bv.velocity += flyspeed * markiplier * camframe.UpVector end
            if input:IsKeyDown(down:Get())  then bv.velocity += flyspeed * markiplier * camframe.UpVector * -1 end
            wait()
        until not flying
        bg:Destroy()
        bv:Destroy()
        
        if useplatformstand then human.PlatformStand = false end
    end
    
    local fly = general:CreateSection({ Name="Fly" })
    
    ui_toggle_fly = fly:AddToggle({ Name="Fly", Key=Enum.KeyCode.F, Callback=function(yes)
        flying = yes
        if yes then Fly() end
    end, UnloadFunc = function()
        ui_toggle_fly:Set(false)
    end})
    
    fly:AddSlider({ Name="Fly Speed", Value=flyspeed, Min=1, Max=1000, Callback=function(v)
        flyspeed = v
    end})
    
    fly:AddToggle({ Name="Use PlatformStand", Value=useplatformstand, Callback=function(yes)
        useplatformstand = yes
    end})
    
    frwd  = fly:AddKeybind({ Name="forwards", Value=Enum.KeyCode.W })
    back  = fly:AddKeybind({ Name="backwards", Value=Enum.KeyCode.S })
    left  = fly:AddKeybind({ Name="left",  Value=Enum.KeyCode.A })
    right = fly:AddKeybind({ Name="right", Value=Enum.KeyCode.D })
    up    = fly:AddKeybind({ Name="up",    Value=Enum.KeyCode.Space })
    down  = fly:AddKeybind({ Name="down",  Value=Enum.KeyCode.LeftShift })
    x2    = fly:AddKeybind({ Name="2x speed (hold)", Value=Enum.KeyCode.LeftControl })
    x3    = fly:AddKeybind({ Name="3x speed (hold)", Value=Enum.KeyCode.LeftAlt })
end
