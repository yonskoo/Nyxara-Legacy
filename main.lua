-- rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Function to start/restart the entire UI
local function startYonskoHub()

-- Notify & Feature Check
local function rayfieldNotify(msg)
    pcall(function()
        Rayfield:Notify({
            Title = "Executor Incompatibility",
            Content = msg,
            Duration = 10
        })
    end)
end
local function featureCheck()
    local missing = {}
    if not (writefile and readfile) and not (syn and syn.write_file and syn.read_file) then
        table.insert(missing, "File save/load ('writefile', 'readfile')")
    end
    if not setclipboard then
        table.insert(missing, "Clipboard ('setclipboard')")
    end
    if #missing > 0 then
        local message = "⚠️ Your executor is missing these:\n"
        for _, m in ipairs(missing) do
            message = message .. "- " .. m .. "\n"
        end
        message = message .. "Some UI may not refresh or save properly.\nTry another executor for best results."
        rayfieldNotify(message)
        print(message)
    end
end
featureCheck()

-- Rayfield GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local SETTINGS_FILE = "yonsko_Settings.json"

local DEFAULTS = {
    RememberSettings = false,
    AutoExecute = false,
    InfJumpUI = false,
	WalkSpeed = 16,
    InvisibleUI = false,
    TPWalkSpeed = 0,
    JumpPower = 50,
    Gravity = 196.2,
    FOV = 70,
    NoClipUI = false,
    FlyUI = false,
    FlySpeed = 30,
    ESPUI = false,
    ESPColor = Color3.fromRGB(0,255,0),
    TPToMouseUI = false,
    TPKeybind = "R",
    SelectedPlayer = nil,
    Theme = "Light",
    espSettings = {
        HideTeammates = false,
        BoxesEnabled = true,
        TracersEnabled = true,
        TextEnabled = true,
        ShowNames = true,
        DisplayName = true,
        HealthShown = true,
        DistanceShown = true,
        BoxThickness = 2,
        TracerTransparency = 1,
        TracerThickness = 2,
        TextSize = 14
    },
    aimbotSettings = {
        TargetPart = "Head",
        FOV = 80,
        Thickness = 3,
        Filled = false,
        CircleColor = Color3.fromRGB(255,0,0),
        Silent = false,
        Smooth = false,
        Smoothness = 0.20,
        IgnoreFriends = true,
        AutoFire = false,
        Prediction = false,
        Priority = "Closest",
        ShowSnapLine = true,
        ShowAimList = false,
        Blacklist = {}
    }
}

local function copyDefaults()
    local t = {}; for k,v in pairs(DEFAULTS) do t[k]=v end; return t
end
local uiState = copyDefaults()
local function writeSettings(tbl)
    local ok, err = pcall(function()
        local json = HttpService:JSONEncode(tbl)
        if writefile then writefile(SETTINGS_FILE, json)
        elseif syn and syn.write_file then syn.write_file(SETTINGS_FILE, json) end
    end)
    return ok
end
local function readSettings()
    local ok, data = pcall(function()
        if isfile and isfile(SETTINGS_FILE) then return readfile(SETTINGS_FILE)
        elseif syn and syn.read_file and syn.exists and syn.exists(SETTINGS_FILE) then return syn.read_file(SETTINGS_FILE)
        end
        return nil
    end)
    if ok and data then
        local suc, tbl = pcall(function() return HttpService:JSONDecode(data) end)
        if suc and type(tbl)=="table" then return tbl end
    end
    return nil
end
local function readColor3(tbl)
    return Color3.fromRGB(tbl.r*255, tbl.g*255, tbl.b*255)
end
local saved = readSettings()

if saved and saved.RememberSettings then
    for k,v in pairs(saved) do
        if k=="ESPColor" and typeof(v)=="table" then 
            uiState.ESPColor=readColor3(v)
        elseif k=="aimbotSettings" and typeof(v)=="table" then
            uiState.aimbotSettings = v
            if v.CircleColor and typeof(v.CircleColor)=="table" then
                uiState.aimbotSettings.CircleColor = readColor3(v.CircleColor)
            end
        else 
            uiState[k]=v 
        end
    end
end


local function persistUIState()
    local tosave = {}
    for k,v in pairs(uiState) do
        if typeof(v)=="Color3" then 
            tosave[k]={r=v.R,g=v.G,b=v.B}
        elseif k=="aimbotSettings" and typeof(v)=="table" then
            tosave.aimbotSettings = {}
            for ak, av in pairs(v) do
                if typeof(av)=="Color3" then
                    tosave.aimbotSettings[ak] = {r=av.R, g=av.G, b=av.B}
                else
                    tosave.aimbotSettings[ak] = av
                end
            end
        else 
            tosave[k]=v 
        end
    end
    pcall(function() writeSettings(tosave) end)
end

local safeNotify = function(title,content)
    pcall(function() Rayfield:Notify({Title=title,Content=content,Duration=3}) end)
end

-- FIXED: Read theme from saved settings first
local selectedTheme = "Light"
if saved and saved.Theme then
    selectedTheme = saved.Theme
elseif uiState.Theme then
    selectedTheme = uiState.Theme
end

local Window = Rayfield:CreateWindow({
   Name = "Nyxara ⚡️",
   Icon = 0,
   LoadingTitle = "Loading Nyx⚡️...",
   LoadingSubtitle = "Built For Almost All Executors",
   Theme = selectedTheme,
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Your Saved Configuration",
      FileName = "Nyxara Legacy⚡️"
   },
   Discord = {
      Enabled = true,
      Invite = "y38jfB9PTx",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Nyxara Key  System",
      Subtitle = "Key System",
      Note = "Key in disord, ", 
      FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
      Key = {"Kx7mP9qR2tV4nL8jW"} 
   }
})

local MainTab = Window:CreateTab("Home","home")
local TeleportTab = Window:CreateTab("Teleport","send")
local ESPTab = Window:CreateTab("ESP","eye")
local AimbotTab = Window:CreateTab("Aimbot","target")
local ConfigTab = Window:CreateTab("Config","list")
local OtherTab = Window:CreateTab("Other","Settings")

-- Toggles
_G.InfJumpEnabled = uiState.InfJumpUI
_G.NoClipEnabled  = uiState.NoClipUI
_G.FlyEnabled     = uiState.FlyUI
local ESPEnabled  = uiState.ESPUI
local TPEnabled   = uiState.TPToMouseUI
local ESPColor    = uiState.ESPColor
local ESPObjects  = {}

-- HOME TAB
_G.InvisibleEnabled = uiState.InvisibleUI or false

-- Clean up existing invis connections
if _G.a then
    for Index, Connection in pairs(_G.a) do
        Connection:Disconnect()
    end
    _G.a = nil
end

local LocalPlayer = game.Players.LocalPlayer
local Character = nil
local Humanoid = nil
local RootPart = nil
local Parts = {}

local function InitCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Parts = {}
    for Index, Descendant in pairs(Character:GetDescendants()) do
        if Descendant:IsA("BasePart") and Descendant.Transparency == 0 then
            Parts[#Parts + 1] = Descendant
        end
    end
end
MainTab:CreateSection("Press V to toggle the invisible on and off.")

local InvisibleToggle = MainTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = uiState.InvisibleUI or false,
    Callback = function(val)
        _G.InvisibleEnabled = val
        uiState.InvisibleUI = val
        if uiState.RememberSettings then persistUIState() end
        
        if val then
            -- Toggle ON - set transparency and start position trick
            for Index, Item in pairs(Parts) do
                if Item.Parent then
                    Item.Transparency = 0.5
                end
            end
        else
            -- Toggle OFF - reset transparency
            for Index, Item in pairs(Parts) do
                if Item.Parent then
                    Item.Transparency = 0
                end
            end
        end
    end
})

-- Main invis connections (V keybind + position trick)
_G.a = {
    [1] = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.V then
            _G.InvisibleEnabled = not _G.InvisibleEnabled
            uiState.InvisibleUI = _G.InvisibleEnabled
            InvisibleToggle:Set(_G.InvisibleEnabled)
            if uiState.RememberSettings then persistUIState() end
            
            if _G.InvisibleEnabled then
                for Index, Item in pairs(Parts) do
                    if Item.Parent then Item.Transparency = 0.5 end
                end
            else
                for Index, Item in pairs(Parts) do
                    if Item.Parent then Item.Transparency = 0 end
                end
            end
        end
    end),
    [2] = game:GetService("RunService").Heartbeat:Connect(function()
        if _G.InvisibleEnabled and Character and RootPart and Humanoid then
            local RootCFrame = RootPart.CFrame
            local CameraOffset = Humanoid.CameraOffset
            local OffsetCFrame = RootCFrame * CFrame.new(0, -200000, 0)
            local LocalPosition = OffsetCFrame:ToObjectSpace(CFrame.new(RootCFrame.Position)).Position
            
            RootPart.CFrame = OffsetCFrame
            Humanoid.CameraOffset = LocalPosition
            game:GetService("RunService").RenderStepped:Wait()
            
            RootPart.CFrame = RootCFrame
            Humanoid.CameraOffset = CameraOffset
        end
    end)
}

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    InitCharacter()
    if _G.InvisibleEnabled then
        task.wait(0.5)
        for Index, Item in pairs(Parts) do
            if Item.Parent then Item.Transparency = 0.5 end
        end
    end
end)

InitCharacter()

-- HOME TAB
local NoClipToggle = MainTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = uiState.NoClipUI,
    Callback = function(val)
        _G.NoClipEnabled = val
        uiState.NoClipUI = val
        if uiState.RememberSettings then persistUIState() end
        safeNotify("NoClip", val and "✅ Enabled" or "❌ Disabled")

        -- NoClip logic
        if _G.NoClipConn then
            _G.NoClipConn:Disconnect()
            _G.NoClipConn = nil
        end
        if val then
            _G.NoClipConn = game:GetService("RunService").Stepped:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                if player and player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

local InfJumpToggle = MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = uiState.InfJumpUI,
    Callback = function(val)
        _G.InfJumpEnabled = val
        uiState.InfJumpUI = val
        if uiState.RememberSettings then persistUIState() end
        safeNotify("Infinite Jump", val and "✅ Enabled" or "❌ Disabled")

        -- Infinite Jump logic
        if _G.InfJumpConn then
            _G.InfJumpConn:Disconnect()
            _G.InfJumpConn = nil
        end
        if val then
            _G.InfJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                if player and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

local FlyToggle = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(val)
        if val then
            startFly()
        else
            stopFly()
        end
    end
})

local flyBV, flyBG, flyConn
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, LeftShift=false}

function startFly()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    flyBG = Instance.new("BodyGyro")
    flyBG.P = 9e4
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.new(0, 0.1, 0)
    flyBV.Parent = hrp

    local UIS = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera

    -- Input handlers for fly keys
    local inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.LeftShift = true
        end
    end)

    local inputEndedConn = UIS.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.LeftShift = false
        end
    end)

    flyConn = game:GetService("RunService").RenderStepped:Connect(function()
        local speed = tonumber(uiState.FlySpeed) or 50
        local lookVector = Camera.CFrame.LookVector
        local rightVector = Camera.CFrame.RightVector
        
        flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
        
        local moveDir = Vector3.new(0, 0, 0)

        if not UIS.TouchEnabled then
            -- PC Controls
            if flyKeys.W then moveDir = moveDir + lookVector end
            if flyKeys.S then moveDir = moveDir - lookVector end
            if flyKeys.A then moveDir = moveDir - rightVector end
            if flyKeys.D then moveDir = moveDir + rightVector end
            if flyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if flyKeys.LeftShift then moveDir = moveDir - Vector3.new(0, 1, 0) end
        else
            -- Mobile Controls
            local moveDirection = hum.MoveDirection
            if moveDirection.Magnitude > 0 then
                moveDir = (lookVector * -moveDirection.Z) + (rightVector * -moveDirection.X)
            end
        end

        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * speed
        else
            flyBV.Velocity = Vector3.new(0, 0.1, 0) -- Hover in place
        end
    end)
    
    -- Store connections for cleanup
    flyBV.AncestryChanged:Connect(function()
        if not flyBV.Parent then
            if inputBeganConn then inputBeganConn:Disconnect() end
            if inputEndedConn then inputEndedConn:Disconnect() end
        end
    end)
end

function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    
    -- Reset fly keys
    for k, _ in pairs(flyKeys) do
        flyKeys[k] = false
    end
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local FlySpeedSlider = MainTab:CreateSlider({
    Name = "Fly Speed Slider",
    Range = {30, 240},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = uiState.FlySpeed,
    Callback = function(Value)
        uiState.FlySpeed = Value
        FlySpeed = Value
        if uiState.RememberSettings then persistUIState() end
    end
})

local JumpPowerSlider = MainTab:CreateSlider({
    Name="JumpPower Slider",Range={50,500},Increment=1,Suffix="JumpPower",CurrentValue=uiState.JumpPower,
    Callback=function(Value)
        uiState.JumpPower=Value
        local char=player.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower=Value end
        if uiState.RememberSettings then persistUIState() end
    end
})

local WalkSpeedSlider = MainTab:CreateSlider({
    Name="WalkSpeed Slider",Range={16,200},Increment=1,Suffix="Speed",CurrentValue=uiState.WalkSpeed,
    Callback=function(Value)
        uiState.WalkSpeed=Value
        local char=player.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed=Value end
        if uiState.RememberSettings then persistUIState() end
    end
})

local TPConnection
local SpeedMultiplier = 0.15

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

function startTPWalk()
    if TPConnection then return end

    TPConnection = RunService.Heartbeat:Connect(function()
        if not uiState or uiState.TPWalkSpeed <= 0 then return end

        local root = getRoot()
        local cam = workspace.CurrentCamera

        local moveDir = Vector3.zero
        local look = flat(cam.CFrame.LookVector)
        local right = flat(cam.CFrame.RightVector)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= look end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end

        if moveDir.Magnitude > 0 then
            root.CFrame = root.CFrame + (moveDir.Unit * uiState.TPWalkSpeed * SpeedMultiplier)
        end
    end)
end

function stopTPWalk()
    if TPConnection then
        TPConnection:Disconnect()
        TPConnection = nil
    end
end

MainTab:CreateSlider({
    Name = "TPWalk Slider",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = uiState.TPWalkSpeed,
    Callback = function(Value)

        uiState.TPWalkSpeed = Value

        if Value > 0 then
            startTPWalk()
        else
            stopTPWalk()
        end

        persistUIState()
    end
})

local GravitySlider = MainTab:CreateSlider({
    Name="Gravity Slider",Range={0,196.2},Increment=1,Suffix="Gravity",CurrentValue=uiState.Gravity,
    Callback=function(Value)
        uiState.Gravity=Value; workspace.Gravity=Value
        if uiState.RememberSettings then persistUIState() end
    end
})

MainTab:CreateSection("Visual & Utility")

local FOVSlider = MainTab:CreateSlider({
    Name="FOV Changer",Range={70,120},Increment=1,Suffix="FOV",CurrentValue=workspace.CurrentCamera.FieldOfView,
    Callback=function(Value)
        workspace.CurrentCamera.FieldOfView = Value
        uiState.FOV = Value
        if uiState.RememberSettings then persistUIState() end
    end
})

MainTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(val)
        if val then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

-- Anti-AFK
local antiAFKConnection
MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Callback = function(val)
        if val then
            antiAFKConnection = player.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
            safeNotify("Anti-AFK", "✅ Enabled - You won't be kicked for being idle")
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            safeNotify("Anti-AFK", "❌ Disabled")
        end
    end
})

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.JumpPower = uiState.JumpPower
    hum.WalkSpeed = uiState.WalkSpeed
    workspace.Gravity = uiState.Gravity
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.JumpPower ~= uiState.JumpPower then
                hum.JumpPower = uiState.JumpPower
            end
            if hum.WalkSpeed ~= uiState.WalkSpeed then
                hum.WalkSpeed = uiState.WalkSpeed
            end
        end
    end
    if workspace.Gravity ~= uiState.Gravity then
        workspace.Gravity = uiState.Gravity
    end
end)


local selectedPlayer = uiState.SelectedPlayer
local TPKeybind = uiState.TPKeybind or "R"
local loopGotoEnabled = false
local loopGotoConnection = nil

local function getPlayerList()
    local list = {}; for _,p in pairs(Players:GetPlayers()) do if p~=player then table.insert(list,p.Name) end end; return list
end

local PlayerDropdown=TeleportTab:CreateDropdown({
    Name="Select Player",Options=getPlayerList(),CurrentOption=selectedPlayer and {selectedPlayer} or {},MultipleOptions=false,
    Callback=function(Option) selectedPlayer=Option[1];uiState.SelectedPlayer=selectedPlayer; if uiState.RememberSettings then persistUIState() end end})

Players.PlayerAdded:Connect(function() PlayerDropdown:Refresh(getPlayerList(),true) end)
Players.PlayerRemoving:Connect(function() PlayerDropdown:Refresh(getPlayerList(),true) end)

TeleportTab:CreateButton({
    Name="Teleport To Selected Player",
    Callback=function()
        if not selectedPlayer then safeNotify("Teleport","No player selected") return end
        local target=Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=target.Character.HumanoidRootPart.CFrame+target.Character.HumanoidRootPart.CFrame.LookVector*-2+Vector3.new(0,3,0)
            safeNotify("Teleport","Teleported near "..selectedPlayer) end
        else safeNotify("Teleport","Player not available") end
    end
})

TeleportTab:CreateButton({
    Name="Spectate Selected Player",
    Callback=function()
        if not selectedPlayer then safeNotify("Spectate","No player selected") return end
        local target=Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            safeNotify("Spectate","Now spectating "..selectedPlayer)
        else 
            safeNotify("Spectate","Player not available") 
        end
    end
})

TeleportTab:CreateButton({
    Name="Stop Spectating (Return to Self)",
    Callback=function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
            safeNotify("Spectate","Returned to your character")
        end
    end
})

TeleportTab:CreateToggle({
    Name="Loop Goto Selected Player",
    CurrentValue=false,
    Callback=function(val)
        loopGotoEnabled = val
        
        if val then
            if loopGotoConnection then loopGotoConnection:Disconnect() end
            
            loopGotoConnection = RunService.Heartbeat:Connect(function()
                if not loopGotoEnabled then return end
                if not selectedPlayer then return end
                
                local target = Players:FindFirstChild(selectedPlayer)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + target.Character.HumanoidRootPart.CFrame.LookVector*-3 + Vector3.new(0,2,0)
                    end
                end
            end)
            
            safeNotify("Loop Goto","Following "..selectedPlayer)
        else
            if loopGotoConnection then
                loopGotoConnection:Disconnect()
                loopGotoConnection = nil
            end
            safeNotify("Loop Goto","Stopped following")
        end
    end
})

TeleportTab:CreateSection("Teleport to Mouse")

-- TP to Mouse keybind handler
local currentTPKeybind = uiState.TPKeybind or "R"
TPKeybind = currentTPKeybind
local tpConnection = nil

local function setupTPKeybind()
    if tpConnection then
        tpConnection:Disconnect()
        tpConnection = nil
    end
    
    if not TPEnabled then return end
    
    tpConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not TPEnabled then return end
        
        -- Try to match the keybind
        local inputKeyName = input.KeyCode.Name
        
        if inputKeyName:upper() == currentTPKeybind:upper() then
            local character = player.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local mouse = player:GetMouse()
            if not mouse then return end
            
            local targetPosition = mouse.Hit.Position
            if targetPosition then
                -- Teleport to mouse position (no notification)
                hrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
            end
        end
    end)
end

-- Setup initial keybind only if TP is enabled
if TPEnabled then
    setupTPKeybind()
end

-- Update keybind input to refresh the connection
local TPKeybindInput = TeleportTab:CreateInput({
    Name = "TP Keybind (Single Key)",
    PlaceholderText = "e.g., R, E, Q",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and Text ~= "" then
            currentTPKeybind = Text:upper()
            TPKeybind = currentTPKeybind
            uiState.TPKeybind = TPKeybind
            if uiState.RememberSettings then persistUIState() end
            if TPEnabled then
                setupTPKeybind() -- Reconnect with new keybind only if enabled
            end
            safeNotify("Keybind Set", "TP keybind set to: " .. TPKeybind)
        end
    end,
})

local TP_Toggle = TeleportTab:CreateToggle({
    Name="Teleport To Mouse",
    CurrentValue=uiState.TPToMouseUI,
    Callback=function(v) 
        TPEnabled=v
        uiState.TPToMouseUI=TPEnabled
        if uiState.RememberSettings then persistUIState() end
        if v then
            setupTPKeybind() -- Setup keybind when enabled
        else
            if tpConnection then
                tpConnection:Disconnect()
                tpConnection = nil
            end
        end
    end
})

ESPObjects = ESPObjects or {}
ESPEnabled = ESPEnabled or false
ESPColor = uiState.ESPColor or Color3.fromRGB(255, 255, 255)

-- ESP Settings with defaults
if not uiState.espSettings then
    uiState.espSettings = {
        HideTeammates = false,
        BoxesEnabled = true,
        TracersEnabled = true,
        TextEnabled = true,
        ShowNames = true,
        DisplayName = true,
        HealthShown = true,
        DistanceShown = true,
        BoxThickness = 2,
        TracerTransparency = 1,
        TracerThickness = 2,
        TextSize = 14
    }
end

local espSettings = uiState.espSettings

-- Main Section
ESPTab:CreateSection("Main")

local ESPToggle = ESPTab:CreateToggle({
    Name = "ESP Toggle",
    CurrentValue = uiState.ESPUI,
    Callback = function(enabled)
        ESPEnabled = enabled
        uiState.ESPUI = enabled

        if uiState.RememberSettings then
            persistUIState()
        end

        if not enabled then
            -- Clean up all ESP elements
            for _, data in pairs(ESPObjects) do
                if data.BoxLines then
                    for _, line in pairs(data.BoxLines) do
                        pcall(function() line.Remove() end)
                    end
                end
                if data.Tracer then pcall(function() data.Tracer.Remove() end) end
                if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
            end
            ESPObjects = {}
        end
    end
})

ESPTab:CreateToggle({
    Name = "Hide Teammates",
    CurrentValue = espSettings.HideTeammates,
    Callback = function(val)
        espSettings.HideTeammates = val
        uiState.espSettings.HideTeammates = val
        if uiState.RememberSettings then persistUIState() end
    end
})

-- Features Section
ESPTab:CreateSection("Features")

ESPTab:CreateToggle({
    Name = "Boxes Enabled",
    CurrentValue = espSettings.BoxesEnabled,
    Callback = function(val)
        espSettings.BoxesEnabled = val
        uiState.espSettings.BoxesEnabled = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Tracers Enabled",
    CurrentValue = espSettings.TracersEnabled,
    Callback = function(val)
        espSettings.TracersEnabled = val
        uiState.espSettings.TracersEnabled = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Text Enabled",
    CurrentValue = espSettings.TextEnabled,
    Callback = function(val)
        espSettings.TextEnabled = val
        uiState.espSettings.TextEnabled = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = espSettings.ShowNames,
    Callback = function(val)
        espSettings.ShowNames = val
        uiState.espSettings.ShowNames = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Display Name Shown",
    CurrentValue = espSettings.DisplayName,
    Callback = function(val)
        espSettings.DisplayName = val
        uiState.espSettings.DisplayName = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Health Shown",
    CurrentValue = espSettings.HealthShown,
    Callback = function(val)
        espSettings.HealthShown = val
        uiState.espSettings.HealthShown = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateToggle({
    Name = "Distance Shown",
    CurrentValue = espSettings.DistanceShown,
    Callback = function(val)
        espSettings.DistanceShown = val
        uiState.espSettings.DistanceShown = val
        if uiState.RememberSettings then persistUIState() end
    end
})

-- Customize Section
ESPTab:CreateSection("Customize")

local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = uiState.ESPColor,
    Callback = function(color)
        ESPColor = color
        uiState.ESPColor = color

        -- Update all ESP elements with new color
        for _, data in pairs(ESPObjects) do
            if data.BoxLines then
                for _, line in pairs(data.BoxLines) do
                    line.Color = color
                end
            end
            if data.Tracer then data.Tracer.Color = color end
            if data.Text then data.Text.TextColor3 = color end
        end

        if uiState.RememberSettings then
            persistUIState()
        end
    end
})

ESPTab:CreateSlider({
    Name = "Box Thickness",
    Range = {0, 10},
    Increment = 1,
    CurrentValue = espSettings.BoxThickness,
    Callback = function(val)
        espSettings.BoxThickness = val
        uiState.espSettings.BoxThickness = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateSlider({
    Name = "Tracer Transparency",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = espSettings.TracerTransparency,
    Callback = function(val)
        espSettings.TracerTransparency = val
        uiState.espSettings.TracerTransparency = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateSlider({
    Name = "Tracer Thickness",
    Range = {0, 5},
    Increment = 1,
    CurrentValue = espSettings.TracerThickness,
    Callback = function(val)
        espSettings.TracerThickness = val
        uiState.espSettings.TracerThickness = val
        if uiState.RememberSettings then persistUIState() end
    end
})

ESPTab:CreateSlider({
    Name = "Text Size",
    Range = {0, 25},
    Increment = 1,
    CurrentValue = espSettings.TextSize,
    Callback = function(val)
        espSettings.TextSize = val
        uiState.espSettings.TextSize = val
        if uiState.RememberSettings then persistUIState() end
    end
})

-- Enhanced ESP rendering using Drawing library for tracers
local Camera = workspace.CurrentCamera

-- Enhanced ESP rendering loop
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then
        return
    end

    -- Clean up dead/left players
    for playerName, data in pairs(ESPObjects) do
        local targetPlayer = game.Players:FindFirstChild(playerName)
        local char = targetPlayer and targetPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not targetPlayer or not char or not hrp or not hum or hum.Health <= 0 then
            if data.BoxLines then
                for _, line in pairs(data.BoxLines) do
                    pcall(function() line.Remove() end)
                end
            end
            if data.Tracer then pcall(function() data.Tracer.Remove() end) end
            if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
            ESPObjects[playerName] = nil
        end
    end

    -- Update ESP for all valid players
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= game.Players.LocalPlayer then
            local char = targetPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            -- Check teammate filter
            if espSettings.HideTeammates and targetPlayer.Team == player.Team then
                if ESPObjects[targetPlayer.Name] then
                    if ESPObjects[targetPlayer.Name].BoxLines then
                        for _, line in pairs(ESPObjects[targetPlayer.Name].BoxLines) do
                            pcall(function() line.Remove() end)
                        end
                    end
                    if ESPObjects[targetPlayer.Name].Tracer then pcall(function() ESPObjects[targetPlayer.Name].Tracer.Remove() end) end
                    if ESPObjects[targetPlayer.Name].Billboard then pcall(function() ESPObjects[targetPlayer.Name].Billboard:Destroy() end) end
                    ESPObjects[targetPlayer.Name] = nil
                end
                continue
            end

            if char and hrp and hum and hum.Health > 0 then
                local playerName = targetPlayer.Name

                if not ESPObjects[playerName] then
                    ESPObjects[playerName] = {}
                end

                -- Box ESP using Drawing library for proper outlines
                if espSettings.BoxesEnabled then
                    if not ESPObjects[playerName].BoxLines then
                        local Drawing = Drawing or getgenv().Drawing
                        if Drawing then
                            -- Create 4 lines for box outline
                            ESPObjects[playerName].BoxLines = {}
                            for i = 1, 4 do
                                local line = Drawing.new("Line")
                                line.Visible = false
                                line.Thickness = espSettings.BoxThickness
                                line.Color = ESPColor
                                line.Transparency = 1
                                table.insert(ESPObjects[playerName].BoxLines, line)
                            end
                        end
                    end

                    if ESPObjects[playerName].BoxLines then
                        -- Calculate box corners in 2D space
                        local hrpPos = hrp.Position
                        local headPos = char:FindFirstChild("Head") and char.Head.Position or hrpPos + Vector3.new(0, 2, 0)
                        
                        -- Get screen positions with much more padding above and below
                        local topPos, topOnScreen = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 2.5, 0))  -- Much more space above head
                        local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(hrpPos - Vector3.new(0, 4, 0))  -- More space below feet
                        
                        if topOnScreen and bottomOnScreen then
                            -- Calculate box dimensions with much wider width
                            local height = math.abs(topPos.Y - bottomPos.Y)
                            local width = height / 1.2  -- Even wider box (was 1.5, now 1.2)
                            local centerX = topPos.X
                            local centerY = (topPos.Y + bottomPos.Y) / 2
                            
                            -- Box corners
                            local topLeft = Vector2.new(centerX - width/2, topPos.Y)
                            local topRight = Vector2.new(centerX + width/2, topPos.Y)
                            local bottomLeft = Vector2.new(centerX - width/2, bottomPos.Y)
                            local bottomRight = Vector2.new(centerX + width/2, bottomPos.Y)
                            
                            -- Update box lines
                            local lines = ESPObjects[playerName].BoxLines
                            
                            -- Top line
                            lines[1].From = topLeft
                            lines[1].To = topRight
                            lines[1].Color = ESPColor
                            lines[1].Thickness = espSettings.BoxThickness
                            lines[1].Visible = true
                            
                            -- Bottom line
                            lines[2].From = bottomLeft
                            lines[2].To = bottomRight
                            lines[2].Color = ESPColor
                            lines[2].Thickness = espSettings.BoxThickness
                            lines[2].Visible = true
                            
                            -- Left line
                            lines[3].From = topLeft
                            lines[3].To = bottomLeft
                            lines[3].Color = ESPColor
                            lines[3].Thickness = espSettings.BoxThickness
                            lines[3].Visible = true
                            
                            -- Right line
                            lines[4].From = topRight
                            lines[4].To = bottomRight
                            lines[4].Color = ESPColor
                            lines[4].Thickness = espSettings.BoxThickness
                            lines[4].Visible = true
                        else
                            -- Hide if off screen
                            for _, line in pairs(ESPObjects[playerName].BoxLines) do
                                line.Visible = false
                            end
                        end
                    end
                else
                    if ESPObjects[playerName].BoxLines then
                        for _, line in pairs(ESPObjects[playerName].BoxLines) do
                            pcall(function() line.Remove() end)
                        end
                        ESPObjects[playerName].BoxLines = nil
                    end
                end

                -- Tracer ESP using Drawing library
                if espSettings.TracersEnabled then
                    if not ESPObjects[playerName].Tracer then
                        local Drawing = Drawing or getgenv().Drawing
                        if Drawing then
                            local tracer = Drawing.new("Line")
                            tracer.Visible = true
                            tracer.Thickness = espSettings.TracerThickness
                            tracer.Color = ESPColor
                            tracer.Transparency = espSettings.TracerTransparency
                            ESPObjects[playerName].Tracer = tracer
                        end
                    end

                    if ESPObjects[playerName].Tracer then
                        local tracer = ESPObjects[playerName].Tracer
                        local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        
                        if onScreen then
                            -- Tracer from bottom center of screen to player
                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                            tracer.Color = ESPColor
                            tracer.Thickness = espSettings.TracerThickness
                            tracer.Transparency = espSettings.TracerTransparency
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    end
                else
                    if ESPObjects[playerName].Tracer then
                        pcall(function() ESPObjects[playerName].Tracer.Remove() end)
                        ESPObjects[playerName].Tracer = nil
                    end
                end

                -- Text ESP (Billboard)
                if espSettings.TextEnabled then
                    if not ESPObjects[playerName].Billboard or not ESPObjects[playerName].Billboard.Parent then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESPBillboard_" .. playerName
                        billboard.Adornee = hrp
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 4.5, 0)  -- Position above the box (box top is at 2.5 + 2 = 4.5)
                        billboard.AlwaysOnTop = true

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = ESPColor
                        textLabel.Font = Enum.Font.Code
                        textLabel.TextScaled = false
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextXAlignment = Enum.TextXAlignment.Left
                        textLabel.Parent = billboard

                        billboard.Parent = hrp
                        ESPObjects[playerName].Billboard = billboard
                        ESPObjects[playerName].Text = textLabel
                    end

                    -- Build text string
                    local displayText = ""
                    
                    if espSettings.ShowNames then
                        if espSettings.DisplayName then
                            displayText = targetPlayer.DisplayName
                        else
                            displayText = targetPlayer.Name
                        end
                    end

                    if espSettings.HealthShown then
                        local healthPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                        displayText = displayText .. (displayText ~= "" and "\n" or "") .. "[" .. healthPercent .. "%]"
                    end

                    if espSettings.DistanceShown then
                        local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            local dist = math.floor((hrp.Position - playerHRP.Position).Magnitude)
                            displayText = displayText .. (displayText ~= "" and " | " or "") .. "[" .. dist .. " studs]"
                        end
                    end

                    if ESPObjects[playerName].Text then
                        ESPObjects[playerName].Text.Text = displayText
                        ESPObjects[playerName].Text.TextSize = espSettings.TextSize
                        ESPObjects[playerName].Text.TextColor3 = ESPColor
                    end
                else
                    if ESPObjects[playerName].Billboard then
                        pcall(function() ESPObjects[playerName].Billboard:Destroy() end)
                        ESPObjects[playerName].Billboard = nil
                        ESPObjects[playerName].Text = nil
                    end
                end
            end
        end
    end
end)

-- Clean up on player leaving
Players.PlayerRemoving:Connect(function(targetPlayer)
    if ESPObjects[targetPlayer.Name] then
        if ESPObjects[targetPlayer.Name].BoxLines then
            for _, line in pairs(ESPObjects[targetPlayer.Name].BoxLines) do
                pcall(function() line.Remove() end)
            end
        end
        if ESPObjects[targetPlayer.Name].Tracer then pcall(function() ESPObjects[targetPlayer.Name].Tracer.Remove() end) end
        if ESPObjects[targetPlayer.Name].Billboard then pcall(function() ESPObjects[targetPlayer.Name].Billboard:Destroy() end) end
        ESPObjects[targetPlayer.Name] = nil
    end
end)

local Drawing = Drawing or getgenv().Drawing
local fovCircle, aimSnapLine
if Drawing then
fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Position = workspace.CurrentCamera.ViewportSize / 2
fovCircle.Radius = 80
fovCircle.Color = Color3.fromRGB(255,0,0)
fovCircle.Thickness = 3
fovCircle.Filled = false
fovCircle.Transparency = 1
aimSnapLine = Drawing.new("Line")
aimSnapLine.Visible = false
aimSnapLine.Thickness = 2
aimSnapLine.Transparency = 0.9
aimSnapLine.Color = Color3.fromRGB(255,0,0)
end

AimbotTab:CreateSection("HumanoidRootPart is the Torso!")

if not uiState.aimbotSettings then
    uiState.aimbotSettings = {
        TargetPart = "Head", FOV = 80, Thickness = 3,
        Filled = false, CircleColor = Color3.fromRGB(255,0,0), Silent = false,
        Smooth = false, Smoothness = 0.20, IgnoreFriends = true, AutoFire = false,
        Prediction = false, Priority = "Closest", ShowSnapLine = true,
        ShowAimList = false, Blacklist = {}
    }
end

local aimbotSettings = {
    Enabled = false,
    TargetPart = uiState.aimbotSettings.TargetPart,
    FOV = uiState.aimbotSettings.FOV,
    Thickness = uiState.aimbotSettings.Thickness,
    Filled = uiState.aimbotSettings.Filled,
    CircleColor = uiState.aimbotSettings.CircleColor,
    Silent = uiState.aimbotSettings.Silent,
    Smooth = uiState.aimbotSettings.Smooth,
    Smoothness = uiState.aimbotSettings.Smoothness,
    IgnoreFriends = uiState.aimbotSettings.IgnoreFriends,
    AutoFire = uiState.aimbotSettings.AutoFire,
    Prediction = uiState.aimbotSettings.Prediction,
    Priority = uiState.aimbotSettings.Priority,
    ShowSnapLine = uiState.aimbotSettings.ShowSnapLine,
    ShowAimList = uiState.aimbotSettings.ShowAimList,
    Blacklist = uiState.aimbotSettings.Blacklist or {}
}

if fovCircle then
    fovCircle.Radius = aimbotSettings.FOV
    fovCircle.Thickness = aimbotSettings.Thickness
    fovCircle.Filled = aimbotSettings.Filled
    fovCircle.Color = aimbotSettings.CircleColor
end

local availableParts={"Head","HumanoidRootPart","Right Arm","Left Arm","Right Leg","Left Leg"}
local priorities={"Closest","Lowest HP","Highest HP"}

AimbotTab:CreateToggle({Name="Aimbot Lock-On",CurrentValue=aimbotSettings.Enabled,Callback=function(val)aimbotSettings.Enabled=val;if fovCircle then fovCircle.Visible=val end end})
AimbotTab:CreateDropdown({Name="Target Body Part",Options=availableParts,CurrentOption={aimbotSettings.TargetPart},MultipleOptions=false,Callback=function(option)aimbotSettings.TargetPart=option[1];uiState.aimbotSettings.TargetPart=option[1];if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateDropdown({Name="Target Priority",Options=priorities,CurrentOption={aimbotSettings.Priority},MultipleOptions=false,Callback=function(option)aimbotSettings.Priority=option[1];uiState.aimbotSettings.Priority=option[1];if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateColorPicker({Name="FOV Circle Color",Color=aimbotSettings.CircleColor,Callback=function(color)aimbotSettings.CircleColor=color;uiState.aimbotSettings.CircleColor=color;if fovCircle then fovCircle.Color=color end;if aimSnapLine then aimSnapLine.Color=color end;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateSlider({Name="FOV Radius",Range={20,350},Increment=1,Suffix="px",CurrentValue=aimbotSettings.FOV,Callback=function(v)aimbotSettings.FOV=v;uiState.aimbotSettings.FOV=v;if fovCircle then fovCircle.Radius=v end;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateSlider({Name="Circle Thickness",Range={1,7},Increment=1,Suffix="px",CurrentValue=aimbotSettings.Thickness,Callback=function(v)aimbotSettings.Thickness=v;uiState.aimbotSettings.Thickness=v;if fovCircle then fovCircle.Thickness=v end;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Circle Filled",CurrentValue=aimbotSettings.Filled,Callback=function(v)aimbotSettings.Filled=v;uiState.aimbotSettings.Filled=v;if fovCircle then fovCircle.Filled=v end;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Smoothing",CurrentValue=aimbotSettings.Smooth,Callback=function(v)aimbotSettings.Smooth=v;uiState.aimbotSettings.Smooth=v;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateSlider({Name="Smoothness",Range={0.05,0.85},Increment=0.01,Suffix="",CurrentValue=aimbotSettings.Smoothness,Callback=function(v)aimbotSettings.Smoothness=v;uiState.aimbotSettings.Smoothness=v;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Ignore Friends",CurrentValue=aimbotSettings.IgnoreFriends,Callback=function(v)aimbotSettings.IgnoreFriends=v;uiState.aimbotSettings.IgnoreFriends=v;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Auto Fire",CurrentValue=aimbotSettings.AutoFire,Callback=function(v)aimbotSettings.AutoFire=v;uiState.aimbotSettings.AutoFire=v;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Prediction (for fast games)",CurrentValue=aimbotSettings.Prediction,Callback=function(v)aimbotSettings.Prediction=v;uiState.aimbotSettings.Prediction=v;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateToggle({Name="Show SnapLine",CurrentValue=aimbotSettings.ShowSnapLine,Callback=function(v)aimbotSettings.ShowSnapLine=v;uiState.aimbotSettings.ShowSnapLine=v;if aimSnapLine then aimSnapLine.Visible=v end;if uiState.RememberSettings then persistUIState() end end})
AimbotTab:CreateInput({Name="Blacklist Player",PlaceholderText="Username",RemoveTextAfterFocusLost=false,Callback=function(txt)aimbotSettings.Blacklist[txt]=true;uiState.aimbotSettings.Blacklist[txt]=true;if uiState.RememberSettings then persistUIState() end end})

local mouse = player:GetMouse()
RunService.RenderStepped:Connect(function()
if fovCircle then fovCircle.Position = workspace.CurrentCamera.ViewportSize / 2; fovCircle.Visible = aimbotSettings.Enabled end
if aimSnapLine and not aimbotSettings.ShowSnapLine then aimSnapLine.Visible = false end
if not aimbotSettings.Enabled then if fovCircle then fovCircle.Visible = false end; if aimSnapLine then aimSnapLine.Visible = false end; return end
local best, bestDist, bestPart = nil, aimbotSettings.FOV, nil
local aimables = {}
for _,plr in ipairs(Players:GetPlayers()) do
if plr~=player and plr.Character and plr.Character:FindFirstChild(aimbotSettings.TargetPart)
and not aimbotSettings.Blacklist[plr.Name]
and (not aimbotSettings.IgnoreFriends or not player:IsFriendsWith(plr.UserId)) then
local part = plr.Character[aimbotSettings.TargetPart]
local vec,onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
if onScreen then
local dist = (Vector2.new(vec.X,vec.Y)-fovCircle.Position).Magnitude
local hum = plr.Character:FindFirstChildOfClass("Humanoid")
if aimbotSettings.Priority=="Closest" and dist < bestDist then best, bestDist, bestPart = plr, dist, part
elseif aimbotSettings.Priority=="Lowest HP" and hum and (not best or hum.Health < ((best.Character and best.Character:FindFirstChildOfClass("Humanoid")or{Health=999}).Health)) then best, bestDist, bestPart = plr, dist, part
elseif aimbotSettings.Priority=="Highest HP" and hum and (not best or hum.Health > ((best.Character and best.Character:FindFirstChildOfClass("Humanoid")or{Health=-1}).Health)) then best, bestDist, bestPart = plr, dist, part
end
if dist < fovCircle.Radius then table.insert(aimables,{name=plr.Name,dist=math.floor(dist),vec=vec}) end
end
end
end
if bestPart then
if aimbotSettings.Silent and mousemoverel then mousemoverel((workspace.CurrentCamera:WorldToViewportPoint(bestPart.Position).X-fovCircle.Position.X),(workspace.CurrentCamera:WorldToViewportPoint(bestPart.Position).Y-fovCircle.Position.Y))
elseif aimbotSettings.Smooth then
local cam=workspace.CurrentCamera.CFrame.Position; local tar=bestPart.Position;
workspace.CurrentCamera.CFrame=workspace.CurrentCamera.CFrame:Lerp(CFrame.new(cam,tar),aimbotSettings.Smoothness)
else workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,bestPart.Position) end
if aimSnapLine and aimbotSettings.ShowSnapLine then
aimSnapLine.From=fovCircle.Position
local vect=workspace.CurrentCamera:WorldToViewportPoint(bestPart.Position)
aimSnapLine.To=Vector2.new(vect.X,vect.Y)
aimSnapLine.Color=aimbotSettings.CircleColor
aimSnapLine.Visible=true
end
if aimbotSettings.AutoFire and mouse1click then pcall(function() mouse1click() end) end
else if aimSnapLine then aimSnapLine.Visible=false end end
if aimbotSettings.ShowAimList then
local txt="Aimables:\n"; for _,target in ipairs(aimables)do txt=txt..target.name.." ("..target.dist.." px)\n" end
if not game.CoreGui:FindFirstChild("YonAimList")then
local gui=Instance.new("ScreenGui",game.CoreGui)gui.Name="YonAimList"
local lb=Instance.new("TextLabel",gui)
lb.Name="AimLabel"; lb.Size=UDim2.new(0.2,0,0.4,0); lb.Position=UDim2.new(0.75,0,0,0)
lb.BackgroundTransparency=0.4; lb.BackgroundColor3=Color3.fromRGB(10,20,30)
lb.TextColor3=aimbotSettings.CircleColor; lb.TextStrokeTransparency=0.8
lb.TextScaled=false; lb.Font=Enum.Font.Code; lb.TextWrapped=true
end
local g=game.CoreGui:FindFirstChild("YonAimList")
if g and g:FindFirstChild("AimLabel")then g.AimLabel.Text=txt end
elseif game.CoreGui:FindFirstChild("YonAimList") then game.CoreGui.YonAimList:Destroy() end
end)

-- other tab

OtherTab:CreateSection("UI Controls")

OtherTab:CreateButton({
    Name = "Terminate UI",
    Callback = function()
        safeNotify("Terminating", "Closing UI...")
        task.wait(0.5)
        Rayfield:Destroy()
    end
})

OtherTab:CreateSection("Utility Features")

OtherTab:CreateButton({
    Name = "Remove Death Barriers",
    Callback = function()
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:lower():find("kill") or obj.Name:lower():find("death") then
                obj:Destroy()
                count = count + 1
            end
        end
        safeNotify("Death Barriers", "Removed " .. count .. " death parts")
    end
})

local spamJumpEnabled = false
local spamJumpConn
OtherTab:CreateToggle({
    Name = "Spam Jump",
    CurrentValue = false,
    Callback = function(val)
        spamJumpEnabled = val
        if val then
            spamJumpConn = RunService.RenderStepped:Connect(function()
                if spamJumpEnabled then
                    local char = player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if spamJumpConn then
                spamJumpConn:Disconnect()
                spamJumpConn = nil
            end
        end
    end
})

OtherTab:CreateButton({
    Name = "Unlock FPS",
    Callback = function()
        setfpscap(999)
        safeNotify("FPS", "✅ FPS cap set to 999")
    end
})

OtherTab:CreateSection("Credits")
OtherTab:CreateParagraph({Title="Credits",Content="Yonsko ツ"})
OtherTab:CreateSection("Note")
OtherTab:CreateParagraph({Title="Mobile",Content="Some features may not work on mobile (e.g., TP to mouse, aimbot). PC recommended for best experience."})
OtherTab:CreateSection("Discord")
OtherTab:CreateButton({
    Name="Copy Discord Invite",
    Callback=function() setclipboard("https://discord.gg/y38jfB9PTx"); safeNotify("Copied","Discord invite copied!") end
})
OtherTab:CreateSection("Character")
OtherTab:CreateButton({
    Name="Reset Character",
    Callback=function() local player=game.Players.LocalPlayer; if player.Character then player.Character:BreakJoints(); safeNotify("Reset","Character has been reset!") end end
})

-- CONFIG TAB
ConfigTab:CreateSection("Settings")

ConfigTab:CreateToggle({
    Name = "Remember Settings",
    CurrentValue = uiState.RememberSettings or false,
    Callback = function(val)
        uiState.RememberSettings = val
        persistUIState()
        
        if val then
            safeNotify("Settings", "Settings will be remembered")
        else
            uiState.RememberSettings = false
            persistUIState()
            safeNotify("Settings", "Will reset on next run")
        end
    end
})

ConfigTab:CreateToggle({
    Name = "Auto Execute Script",
    CurrentValue = uiState.AutoExecute or false,
    Callback = function(val)
        uiState.AutoExecute = val
        persistUIState()
        
        -- FIXED: Use the exact auto-execute script you provided
        local scriptContent = [[queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/yonskoo/yonsko-hub-main-script/refs/heads/main/main.lua'))()")]]
        
        if val then
            -- Execute the queue teleport script
            pcall(function()
                loadstring(scriptContent)()
            end)
            safeNotify("Auto Execute", "✅ Enabled - Script will auto-execute on teleport!")
        else
            safeNotify("Auto Execute", "❌ Disabled - Script will not auto-execute")
        end
    end
})

ConfigTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        -- Store theme before reset
        local savedTheme = uiState.Theme
        
        -- Reset all settings to defaults
        for key, value in pairs(DEFAULTS) do
            uiState[key] = value
        end

        -- Restore theme only
        uiState.Theme = savedTheme

        -- Save the reset state
        persistUIState()

        -- Reset global variables
        _G.InfJumpEnabled = DEFAULTS.InfJumpUI
        _G.NoClipEnabled  = DEFAULTS.NoClipUI
        _G.FlyEnabled     = DEFAULTS.FlyUI
        ESPEnabled        = DEFAULTS.ESPUI
        TPEnabled         = DEFAULTS.TPToMouseUI
        TPKeybind         = DEFAULTS.TPKeybind
        currentTPKeybind  = DEFAULTS.TPKeybind

        -- Clean up ESP visuals properly
        for _, data in pairs(ESPObjects) do
            if data.BoxLines then
                for _, line in pairs(data.BoxLines) do
                    pcall(function() line.Remove() end)
                end
            end
            if data.Tracer then pcall(function() data.Tracer.Remove() end) end
            if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
        end
        ESPObjects = {}

        safeNotify("Settings Reset", "✅ All settings reset! Restarting UI...")
        
        task.wait(1)
        
        -- Destroy and restart UI
        Rayfield:Destroy()
        Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
        
        task.wait(0.2)
        
        startYonskoHub()
    end
})

ConfigTab:CreateSection("Server Options")

ConfigTab:CreateButton({
    Name="Rejoin Server",
    Callback=function() 
        safeNotify("Rejoin","Rejoining...") 
        TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) 
    end
})

ConfigTab:CreateButton({
    Name="Server Hop",
    Callback=function()
        safeNotify("Server Hop", "Finding new server...")
        
        local success, result = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            
            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
                        return
                    end
                end
                safeNotify("Server Hop", "No available servers found")
            end
        end)
        
        if not success then
            safeNotify("Server Hop", "Failed to hop servers")
        end
    end
})

ConfigTab:CreateSection("Themes (Warning: Changing themes will reset UI)")

local ThemeDropdown = ConfigTab:CreateDropdown({
    Name = "Select Theme",
    Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = {uiState.Theme or "Light"},
    MultipleOptions = false,
    Callback = function(Option)
        local selectedTheme = Option[1]
        if selectedTheme == uiState.Theme then return end
        
        uiState.Theme = selectedTheme
        persistUIState()
        
        safeNotify("Theme Changing", "Reloading UI in 1 second...")
        
        task.wait(1)
        
        Rayfield:Destroy()
        Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
        
        task.wait(0.2)
        
        startYonskoHub()
    end,
})

ConfigTab:CreateSection("Save/Load Configs")

local savedConfigs = {}
local CONFIGS_FOLDER = "yonsko_configs"
local currentConfigName = ""

-- Load existing configs
local function loadConfigsList()
    local configs = {}
    if listfiles then
        local files = listfiles(CONFIGS_FOLDER)
        for _, file in ipairs(files) do
            local name = file:gsub(CONFIGS_FOLDER .. "\\", ""):gsub(CONFIGS_FOLDER .. "/", ""):gsub(".json", "")
            table.insert(configs, name)
        end
    end
    return configs
end

-- Create configs folder if it doesn't exist
if not isfolder or not isfolder(CONFIGS_FOLDER) then
    if makefolder then makefolder(CONFIGS_FOLDER) end
end

savedConfigs = loadConfigsList()

local ConfigInput = ConfigTab:CreateInput({
    Name = "Config Name",
    PlaceholderText = "e.g., Rivals",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        currentConfigName = Text
    end,
})

ConfigTab:CreateButton({
    Name = "Save Current Config",
    Callback = function()
        local configName = currentConfigName
        if configName == "" then configName = "Default" end
        
        local configPath = CONFIGS_FOLDER .. "/" .. configName .. ".json"
        
        if writefile then
            writefile(configPath, HttpService:JSONEncode(uiState))
            safeNotify("Config Saved", "✅ Saved as: " .. configName)
            savedConfigs = loadConfigsList()
        else
            safeNotify("Config Save", "❌ Your executor doesn't support file saving")
        end
    end
})

local ConfigDropdown = ConfigTab:CreateDropdown({
    Name = "Load Config",
    Options = savedConfigs,
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        local configName = Option[1]
        local configPath = CONFIGS_FOLDER .. "/" .. configName .. ".json"
        
        if readfile and isfile(configPath) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(configPath))
            end)
            
            if success and data then
                -- Load all settings from config
                for k, v in pairs(data) do
                    if k == "ESPColor" and typeof(v) == "table" then
                        uiState.ESPColor = readColor3(v)
                    elseif k == "aimbotSettings" and typeof(v) == "table" then
                        uiState.aimbotSettings = v
                        if v.CircleColor and typeof(v.CircleColor) == "table" then
                            uiState.aimbotSettings.CircleColor = readColor3(v.CircleColor)
                        end
                    else
                        uiState[k] = v
                    end
                end
                
                if uiState.RememberSettings then
                    persistUIState()
                end
                
                safeNotify("Config Loaded", "✅ Loaded: " .. configName .. " - Restart recommended")
            else
                safeNotify("Config Load", "❌ Failed to load config")
            end
        else
            safeNotify("Config Load", "❌ Config file not found")
        end
    end
})

ConfigTab:CreateButton({
    Name = "Refresh Config List",
    Callback = function()
        savedConfigs = loadConfigsList()
        ConfigDropdown:Refresh(savedConfigs, true)
        safeNotify("Configs", "✅ Config list refreshed")
    end
})

end -- End of startYonskoHub function

-- Start the hub for the first time
startYonskoHub()

local infJumpConn, noClipConn
local function enableInfJump()
    if infJumpConn then infJumpConn:Disconnect() end
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        if _G.InfJumpEnabled then
            local char = player.Character
            if char and char:FindFirstChildWhichIsA("Humanoid") then
                char:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end
local function disableInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
end
local function enableNoClip()
    if noClipConn then noClipConn:Disconnect() end
    noClipConn = RunService.Stepped:Connect(function()
        if _G.NoClipEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
end
local function disableNoClip()
    if noClipConn then noClipConn:Disconnect(); noClipConn = nil end
    if player and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end
if _G.InfJumpEnabled then enableInfJump() end
if _G.NoClipEnabled then enableNoClip() end

-- settings on character 
local function applyAllSettingsToCharacter()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = uiState.WalkSpeed
        char.Humanoid.JumpPower = uiState.JumpPower
        workspace.Gravity = uiState.Gravity
        _G.InfJumpEnabled = uiState.InfJumpUI
        _G.NoClipEnabled   = uiState.NoClipUI
        _G.FlyEnabled      = uiState.FlyUI
        ESPEnabled         = uiState.ESPUI
        TPEnabled          = uiState.TPToMouseUI
        if _G.FlyEnabled then startFly() else stopFly() end
    end
end

player.CharacterAdded:Connect(function() wait(0.5); applyAllSettingsToCharacter() end)

task.delay(1, function()
    if uiState.TPWalkSpeed and uiState.TPWalkSpeed > 0 then
        startTPWalk()
    end
end)
