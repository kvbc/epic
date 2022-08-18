local plr, char, mouse, human, torso
repeat wait(); plr = game.Players.LocalPlayer until plr
repeat wait(); mouse = plr:GetMouse() until mouse
local input = game:GetService("UserInputService")

local ui_toggle_fly
local flying = false
local flyspeed = 65
local aimbot = false
local aimbottarget

--[[
--
-- Character
--
--]]

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

--[[
--
-- Properties
--
--]]

local SetProperty
local RestoreProperty
do
    --
    -- Instance
    -- 
    
    local InstanceHasProperty
    local GetCustomInstanceProperty
    local SetCustomInstanceProperty
    do
        local customprops = {}
        
        -- why is there no function for this, roblox?
        InstanceHasProperty = function (obj, prop)
            return pcall(function() return obj[prop] end) 
        end
        
        GetCustomInstanceProperty = function (obj, key)
            customprops[obj] = customprops[obj] or {}
            return customprops[obj][key]
        end
        
        SetCustomInstanceProperty = function (obj, key, value)
            customprops[obj] = customprops[obj] or {}
            customprops[obj][key] = value
        end
    end
    
    --
    -- Properties
    --
    
    function Get (obj, prop)
        if type(obj) == 'table' then
            return rawget(obj, prop)
        elseif typeof(obj) == 'Instance' then
            if InstanceHasProperty(obj, prop) then
                return obj[prop]
            end
            return GetCustomInstanceProperty(obj, prop)
        end
        error(typeof(obj))
    end
    
    function Set (obj, prop, value)
        if type(obj) == 'table' then
            rawset(obj, prop, value) 
        elseif typeof(obj) == 'Instance' then
            if InstanceHasProperty(obj, prop) then
                obj[prop] = value
            else
                SetCustomInstanceProperty(obj, prop, value)
            end
        else
            error(typeof(obj))
        end
    end
    
    local GetCached
    local SetCached
    do
        function CachedProperty (prop)
            return 'epic_cached_' .. prop
        end
        GetCached = function(obj, prop)        return Get(obj, CachedProperty(prop))        end
        SetCached = function(obj, prop, value)        Set(obj, CachedProperty(prop), value) end
    end
    
    RestoreProperty = function (obj, prop)
        local cached = GetCached(obj, prop)
        if cached then
            Set(obj, prop, cached)
            SetCached(obj, prop, nil)
        end
    end
    
    SetProperty = function (obj, prop, value)
        if Get(obj, prop) then
            if not GetCached(obj, prop) then
                SetCached(obj, prop, Get(obj, prop))
            end
            Set(obj, prop, value)
        end
    end
end

--[[
--
-- Aimbot
--
--]]

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbot then
        local cam = game:GetService("Workspace").CurrentCamera
        if not aimbottarget then
            local closest
            local mpos = Vector2.new(mouse.X, mouse.Y)
            for _,p in pairs(game:GetService("Players"):GetChildren()) do
                if p ~= plr and p.Character then
                    local t = p.Character.Head
                    local scrpos, onscr = cam:WorldToViewportPoint(t.Position)
                    scrpos = Vector2.new(scrpos.X, scrpos.Y)
                    if onscr and (closest==nil or (scrpos-mpos).Magnitude < (closest-mpos).Magnitude) then
                        closest = scrpos
                        aimbottarget = t
                    end
                end
            end
        end
        if aimbottarget then
            cam.CFrame = CFrame.new(cam.CFrame.Position, aimbottarget.Position)
        end
    else
        aimbottarget = nil 
    end
end)

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
    
    function SetAllBasepartProperties (prop, value, ifobjfunc)
        for _,v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (ifobjfunc==nil or ifobjfunc(v)) then
                SetProperty(v, prop, value)
            end
        end
    end
    
    function RestoreAllBasepartProperties (prop)
        for _,v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                RestoreProperty(v, prop)
            end
        end
    end
    
    epic:AddToggle({ Name="Neons", Key=true, Value=true, Callback=function(yes)
        if yes then RestoreAllBasepartProperties("Material")
        else SetAllBasepartProperties("Material", Enum.Material.Plastic, function(obj) return obj.Material==Enum.Material.Neon end)
        end
    end})
    
    epic:AddToggle({ Name="Moving Parts", Key=true, Value=true, Callback=function(yes)
        if yes then RestoreAllBasepartProperties("Velocity")
        else SetAllBasepartProperties("Velocity", Vector3.zero)
        end
    end})
    
    epic:AddSlider({ Name="Walk speed", Value=human.WalkSpeed, Min=1, Max=1000, Callback=function(v)
        human.WalkSpeed = v
    end})
    
    epic:AddToggle({ Name="Aimbot / Aimlock", Key=Enum.KeyCode.Q, Value=false, Callback=function(yes)
        aimbot = yes
    end})
end

--[[
--
-- FLY
--
--]]

do
    local useplatformstand = true
    local left, right, up, down, frwd, back, x2, x4
    
    function Fly ()
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        local bv = Instance.new("BodyVelocity", torso)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        if useplatformstand then human.PlatformStand = true end
        
        while flying do
            local camframe = game.Workspace.CurrentCamera.CoordinateFrame
            bg.cframe = camframe
            bv.velocity = Vector3.zero
            local markiplier = (input:IsKeyDown(x4:Get()) and 4) or (input:IsKeyDown(x2:Get()) and 2) or 1
            if input:IsKeyDown(frwd:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector end
            if input:IsKeyDown(left:Get())  then bv.velocity += flyspeed * markiplier * camframe.RightVector * -1 end
            if input:IsKeyDown(back:Get())  then bv.velocity += flyspeed * markiplier * camframe.LookVector * -1 end
            if input:IsKeyDown(right:Get()) then bv.velocity += flyspeed * markiplier * camframe.RightVector end
            if input:IsKeyDown(up:Get())    then bv.velocity += flyspeed * markiplier * Vector3.new(0,1,0) end
            if input:IsKeyDown(down:Get())  then bv.velocity += flyspeed * markiplier * Vector3.new(0,-1,0) end
            wait()
        end
        
        bg:Destroy()
        bv:Destroy()
        if useplatformstand then human.PlatformStand = false end
    end
    
    local fly = general:CreateSection({ Name="Fly" })
    
    ui_toggle_fly = fly:AddToggle({ Name="Fly", Key=Enum.KeyCode.F, Callback=function(yes)
        flying = yes
        if yes then Fly() end
    end, UnloadFunc = function()
        flying = false
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
    x4    = fly:AddKeybind({ Name="4x speed (hold)", Value=Enum.KeyCode.LeftAlt })
end

--[[
--
-- JAILBREAK
--
--]]

do
    local jb = pepsi:CreateTab({ Name="JailBreak" })
    local g = jb:CreateSection({ Name="General" })
    
    function SetGCProperties (prop, value)
        for _,v in pairs(getgc(true)) do
            if type(v) == 'table' then
                SetProperty(v, prop, value)
            end
        end
    end
    
    function RestoreGCProperties (prop)
        for _,v in pairs(getgc(true)) do
            if type(v) == 'table' then
                RestoreProperty(v, prop)
            end
        end
    end
    
    g:AddToggle({ Name="Keycard", Key=true,  Callback=function(yes)
        if yes then
            SetGCProperties("hasKey", function() return true end) 
        else
            RestoreGCProperties("hasKey") 
        end
    end})

    g:AddToggle({ Name="Insane Firerate", Key=true, Callback=function(yes)
        if yes then
            SetGCProperties("FireFreq", 9e9)
            SetGCProperties("IgnoreVerifyFireFreq", true)
        else
            RestoreGCProperties("FireFreq")
            RestoreGCProperties("IgnoreVerifyFireFreq")
        end
    end})
    
    g:AddToggle({ Name="No camera shake", Key=true, Callback=function(yes)
        if yes then
            SetGCProperties("CamShakeMagnitude", 0)
        else
            RestoreGCProperties("CamShakeMagnitude")
        end
    end})
    
    g:AddToggle({ Name="No bullet spread", Key=true, Callback=function(yes)
        if yes then
            SetGCProperties("BulletSpread", 0)
        else
            RestoreGCProperties("BulletSpread")
        end
    end})
end
