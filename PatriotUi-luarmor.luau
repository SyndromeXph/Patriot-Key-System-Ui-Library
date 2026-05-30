--[[
 ________   ________   ________   _______    ___        ___  ___   ___     
|\   __  \ |\   __  \ |\   __  \ |\  ___ \  |\  \      |\  \|\  \ |\  \    
\ \  \|\  \\ \  \|\  \\ \  \|\  \\ \   __/| \ \  \     \ \  \\\  \\ \  \   
 \ \   __  \\ \   _  _\\ \  \\\  \\ \  \_|/__\ \  \     \ \  \\\  \\ \  \  
  \ \  \ \  \\ \  \\  \|\ \  \\\  \\ \  \_|\ \\ \  \____ \ \  \\\  \\ \  \ 
   \ \__\ \__\\ \__\\ _\ \ \_____  \\ \_______\\ \_______\\ \_______\\ \__\
    \|__|\|__| \|__|\|__| \|___| \__\\|_______| \|_______| \|_______| \|__|
                                \|__|                                      
                                                                           
     This version is only for luarmor

     Github - https://github.com/Cobruhehe/expert-octo-doodle
     Author: Cobru (Cobruhehe, .cobru)
     Modifier: Yuxingchen
     License: MIT
                                                                           

    
]]

repeat task.wait() until game:IsLoaded()


local LuarmorAPI = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
Patriot.LuarmorScriptId = Patriot.LuarmorScriptId or ""
LuarmorAPI.script_id = Patriot.LuarmorScriptId


function Patriot:SetScriptId(id)
    Patriot.LuarmorScriptId = id
    LuarmorAPI.script_id = id
end

function Patriot:GetScriptId()
    return Patriot.LuarmorScriptId
end

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

-- services
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

-- appearance
Patriot.Appearance = {
    Title = "Patriot",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}

-- links
Patriot.Links = {
    GetKey = "",
    Discord = ""
}

-- storage
Patriot.Storage = {
    FileName = "Patriot_Key",
    Remember = true,
    AutoLoad = true
}

-- options
Patriot.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true
}

-- theme
Patriot.Theme = {
    Accent = Color3.fromRGB(139, 0, 0),
    AccentHover = Color3.fromRGB(170, 20, 20),
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(20, 20, 20),
    Input = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(120, 120, 120),
    Success = Color3.fromRGB(50, 205, 110),
    Error = Color3.fromRGB(245, 70, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    StatusIdle = Color3.fromRGB(180, 80, 80),
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(45, 45, 70),
    Pending = Color3.fromRGB(60, 60, 60)
}

-- callbacks
Patriot.Callbacks = {
    OnVerify = nil,
    OnSuccess = nil,
    OnFail = nil,
    OnClose = nil
}

Patriot.Changelog = {}

-- shop
Patriot.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium Access",
    Subtitle = "Instant delivery • 24/7 support",
    ButtonText = "Buy",
    Link = ""
}

-- internal
local Internal = {
    Junkie = nil,
    BlurEffect = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode = false,
    IconsLoaded = false
}

-- LUARMOR MOD: 定义 Luarmor 验证函数
function Patriot:LuarmorVerify(key)
    if not key or key == "" then
        return { valid = false, error = "KEY_EMPTY", message = "Please enter a key" }
    end
    local status = LuarmorAPI.check_key(key)
    if status.code == "KEY_VALID" then
        return { valid = true }
    else
      
        local friendlyMsg = status.message
        if status.code == "KEY_HWID_LOCKED" then
            friendlyMsg = "Key linked to a different HWID. Please reset it."
        elseif status.code == "KEY_INCORRECT" then
            friendlyMsg = "Key is wrong or deleted!"
        elseif status.code == "KEY_EXPIRED" then
            friendlyMsg = "Key has expired."
        elseif status.code == "KEY_BLACKLISTED" then
            friendlyMsg = "This key has been blacklisted."
        end
        return { valid = false, error = status.code, message = friendlyMsg }
    end
end

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
    cart = "Cart.png"
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
    cart = "rbxassetid://114754518183872"
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
    return string.rep("•", count)
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

local function enableBlur()
    if not Patriot.Options.Blur then return end
    local existing = Lighting:FindFirstChild("PatriotKeySystemBlur")
    if existing then existing:Destroy() end
    Internal.BlurEffect = Instance.new("BlurEffect")
    Internal.BlurEffect.Name = "PatriotKeySystemBlur"
    Internal.BlurEffect.Size = 0
    Internal.BlurEffect.Parent = Lighting
    TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = 24}):Play()
end

local function disableBlur()
    if Internal.BlurEffect and Internal.BlurEffect.Parent then
        TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = 0}):Play()
        task.delay(0.3, function()
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
            loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/Nappypie/6244c406aa0686a8aaddcf565c7d98b7/raw/3b693642bda11336dc8ed9808c52c87d2a54ba99/Hello.lua"))()
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

    local rightDoor = Instance.new("Frame")
    rightDoor.Name = "RightDoor"
    rightDoor.Size = UDim2.new(0.5, 0, 1, 0)
    rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
    rightDoor.BackgroundColor3 = Patriot.Theme.Header
    rightDoor.BorderSizePixel = 0
    rightDoor.ZIndex = 51
    rightDoor.Parent = overlay

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

    local halfWidth = math.ceil(width / 2)

    local function openDoors(callback)
        TweenService:Create(logoImage, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 1}):Play()
        task.wait(0.25)
        TweenService:Create(leftDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, -halfWidth, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.45)
        overlay.Visible = false
        if callback then callback() end
    end

    local function closeDoors(callback)
        overlay.Visible = true
        leftDoor.Position = UDim2.new(0, -halfWidth, 0, 0)
        rightDoor.Position = UDim2.new(1, 0, 0, 0)
        logoImage.ImageTransparency = 1
        TweenService:Create(leftDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
        task.wait(0.38)
        TweenService:Create(logoImage, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {ImageTransparency = 0}):Play()
        task.wait(0.3)
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

    local linesContainer = Instance.new("Frame")
    linesContainer.Size = UDim2.new(1, 0, 1, 0)
    linesContainer.BackgroundTransparency = 1
    linesContainer.Parent = loadingScreen

    local longLines = {}
    local linePositions = {0.15, 0.35, 0.65, 0.85}
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.3, 0, 0, mobile and 2 or 3)
        line.Position = UDim2.new(1.3, 0, linePositions[i], 0)
        line.BackgroundColor3 = Patriot.Theme.Text
        line.BackgroundTransparency = 1
        line.BorderSizePixel = 0
        line.Parent = linesContainer
        Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
        longLines[i] = line
    end

    local shipSize = mobile and 18 or 28
    local shipContainer = Instance.new("Frame")
    shipContainer.Size = UDim2.new(0, mobile and 100 or 150, 0, mobile and 30 or 50)
    shipContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
    shipContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    shipContainer.BackgroundTransparency = 1
    shipContainer.Parent = loadingScreen

    local shipBody = Instance.new("Frame")
    shipBody.Size = UDim2.new(0, shipSize, 0, shipSize)
    shipBody.Position = UDim2.new(0.5, 10, 0.5, 0)
    shipBody.AnchorPoint = Vector2.new(0.5, 0.5)
    shipBody.BackgroundColor3 = Patriot.Theme.Text
    shipBody.BackgroundTransparency = 1
    shipBody.BorderSizePixel = 0
    shipBody.Parent = shipContainer
    Instance.new("UICorner", shipBody).CornerRadius = UDim.new(1, 0)

    local pointSize = mobile and 10 or 16
    local shipPoint = Instance.new("Frame")
    shipPoint.Size = UDim2.new(0, pointSize, 0, pointSize)
    shipPoint.Position = UDim2.new(1, 2, 0.5, 0)
    shipPoint.AnchorPoint = Vector2.new(0, 0.5)
    shipPoint.BackgroundColor3 = Patriot.Theme.Text
    shipPoint.BackgroundTransparency = 1
    shipPoint.BorderSizePixel = 0
    shipPoint.Rotation = 45
    shipPoint.Parent = shipBody
    Instance.new("UICorner", shipPoint).CornerRadius = UDim.new(0, 3)

    local trails = {}
    local trailConfigs = {
        {y = 0.20, width = mobile and 45 or 70},
        {y = 0.38, width = mobile and 60 or 95},
        {y = 0.62, width = mobile and 55 or 85},
        {y = 0.80, width = mobile and 40 or 65}
    }
    for i, config in ipairs(trailConfigs) do
        local trail = Instance.new("Frame")
        trail.Size = UDim2.new(0, config.width, 0, mobile and 2 or 3)
        trail.Position = UDim2.new(0.5, -15, config.y, 0)
        trail.AnchorPoint = Vector2.new(1, 0.5)
        trail.BackgroundColor3 = Patriot.Theme.Text
        trail.BackgroundTransparency = 1
        trail.BorderSizePixel = 0
        trail.Parent = shipContainer
        local gradient = Instance.new("UIGradient", trail)
        gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.5), NumberSequenceKeypoint.new(1, 0)})
        Instance.new("UICorner", trail).CornerRadius = UDim.new(1, 0)
        trails[i] = {frame = trail, config = config}
    end

    local phasesContainer = Instance.new("Frame")
    phasesContainer.Size = UDim2.new(0, mobile and 200 or 280, 0, mobile and 150 or 180)
    phasesContainer.Position = UDim2.new(0.5, 0, 0.62, 0)
    phasesContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    phasesContainer.BackgroundTransparency = 1
    phasesContainer.Parent = loadingScreen

    local phasesLayout = Instance.new("UIListLayout", phasesContainer)
    phasesLayout.Padding = UDim.new(0, mobile and 8 or 12)
    phasesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    phasesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    phasesLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local phases = {}
    local phaseNames = {"Initializing", "Creating folders", "Downloading assets", "Preparing interface", "Ready"}
    local phaseTextSize = mobile and 14 or 18

    for i, name in ipairs(phaseNames) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, mobile and 22 or 28)
        row.BackgroundTransparency = 1
        row.LayoutOrder = i
        row.Parent = phasesContainer

        local indicator = Instance.new("TextLabel")
        indicator.Size = UDim2.new(0, mobile and 22 or 28, 0, mobile and 22 or 28)
        indicator.BackgroundTransparency = 1
        indicator.Text = "○"
        indicator.TextColor3 = Patriot.Theme.Pending
        indicator.TextSize = phaseTextSize
        indicator.Font = Enum.Font.ArimoBold
        indicator.TextTransparency = 1
        indicator.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, mobile and -28 or -35, 1, 0)
        label.Position = UDim2.new(0, mobile and 28 or 35, 0, 0)
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
    local pulseThread = nil

    local function animateLongLines()
        local speeds = {0.8, 1.0, 0.7, 0.9}
        while animationRunning do
            for i, line in ipairs(longLines) do
                task.spawn(function()
                    line.Position = UDim2.new(1.3, 0, linePositions[i], 0)
                    line.BackgroundTransparency = 0.5
                    TweenService:Create(line, TweenInfo.new(speeds[i], Enum.EasingStyle.Linear), {Position = UDim2.new(-0.4, 0, linePositions[i], 0), BackgroundTransparency = 0.9}):Play()
                end)
            end
            task.wait(0.5)
        end
    end

    local function animateTrails()
        while animationRunning do
            for _, trail in ipairs(trails) do
                local newWidth = trail.config.width + math.random(-12, 12)
                TweenService:Create(trail.frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Size = UDim2.new(0, newWidth, 0, mobile and 2 or 3), BackgroundTransparency = 0.1 + math.random() * 0.3}):Play()
            end
            task.wait(0.1)
        end
    end

    local function animateShipShake()
        while animationRunning do
            local shakeAmount = mobile and 2 or 3
            TweenService:Create(shipContainer, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Position = UDim2.new(0.5, math.random(-shakeAmount, shakeAmount), 0.35, math.random(-1, 1))}):Play()
            task.wait(0.04)
        end
    end

    local function setPhase(num)
        if pulseThread then task.cancel(pulseThread) pulseThread = nil end
        for i = 1, 5 do
            local p = phases[i]
            if i < num then
                p.indicator.Text = "●"
                TweenService:Create(p.indicator, TweenInfo.new(0.2), {TextColor3 = Patriot.Theme.Success, TextTransparency = 0}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.2), {TextColor3 = Patriot.Theme.Success}):Play()
            elseif i == num then
                p.indicator.Text = "●"
                p.indicator.TextTransparency = 0
                TweenService:Create(p.indicator, TweenInfo.new(0.2), {TextColor3 = Patriot.Theme.Accent}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.2), {TextColor3 = Patriot.Theme.Text}):Play()
                currentPhase = num
                pulseThread = task.spawn(function()
                    while currentPhase == num do
                        TweenService:Create(p.indicator, TweenInfo.new(0.4), {TextTransparency = 0.5}):Play()
                        task.wait(0.4)
                        if currentPhase ~= num then break end
                        TweenService:Create(p.indicator, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
                        task.wait(0.4)
                    end
                end)
            else
                p.indicator.Text = "○"
                p.indicator.TextColor3 = Patriot.Theme.Pending
                p.label.TextColor3 = Patriot.Theme.Pending
            end
        end
    end

    task.spawn(function()
        TweenService:Create(blurEffect, TweenInfo.new(0.6), {Size = 24}):Play()
        TweenService:Create(loadingScreen, TweenInfo.new(0.5), {BackgroundTransparency = 0.25}):Play()
        task.wait(0.3)
        TweenService:Create(shipBody, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
        TweenService:Create(shipPoint, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
        task.spawn(animateLongLines)
        task.spawn(animateTrails)
        task.spawn(animateShipShake)
        task.wait(0.2)
        for i = 1, 5 do
            task.delay((i-1)*0.08, function()
                TweenService:Create(phases[i].indicator, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
                TweenService:Create(phases[i].label, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
            end)
        end
        task.wait(0.5)
        setPhase(1)
        runExternalScript()
        task.wait(0.3)
        setPhase(2) ensureFolders() task.wait(0.25)
        setPhase(3)
        local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
        if shouldDownloadLogo() then table.insert(iconNames, "logo") end
        for _, name in ipairs(iconNames) do downloadIcon(name) task.wait(0.06) end
        Internal.IconsLoaded = true
        setPhase(4) task.wait(0.25)
        setPhase(5) task.wait(0.5)
        animationRunning = false
        if pulseThread then task.cancel(pulseThread) end
        TweenService:Create(loadingScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(shipBody, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(shipPoint, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        for _, trail in pairs(trails) do TweenService:Create(trail.frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
        for _, line in pairs(longLines) do TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
        for i = 1, 5 do
            TweenService:Create(phases[i].indicator, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            TweenService:Create(phases[i].label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        end
        TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
        task.wait(0.5)
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
    frame.BackgroundColor3 = Patriot.Theme.Header
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Patriot.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Patriot.Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg

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
                TweenService:Create(n.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15 - yOffset)}):Play()
                yOffset = yOffset + n.height + 12
            end
        end
    end

    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15)}):Play()
    task.wait(0.1)
    restack()

    local function dismiss()
        for i, n in ipairs(Internal.NotificationList) do
            if n.id == id then table.remove(Internal.NotificationList, i) break end
        end
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, width + 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.3)
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
    panel.BackgroundColor3 = Patriot.Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Patriot.Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Patriot.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

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
    panelHeaderLine.BackgroundTransparency = 0.6
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
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Patriot.Theme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = panel

    local scrollPadding = Instance.new("UIPadding", scrollFrame)
    scrollPadding.PaddingLeft = UDim.new(0, 10)
    scrollPadding.PaddingRight = UDim.new(0, 10)
    scrollPadding.PaddingTop = UDim.new(0, 5)
    scrollPadding.PaddingBottom = UDim.new(0, 5)

    local contentLayout = Instance.new("UIListLayout", scrollFrame)
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, update in ipairs(Patriot.Changelog) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.LayoutOrder = i * 2
        entry.Parent = scrollFrame

        local entryLayout = Instance.new("UIListLayout", entry)
        entryLayout.Padding = UDim.new(0, 5)

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 22)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = update.Version .. "  •  " .. update.Date
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
            changeLabel.Text = "  •  " .. change
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
            divWrapper.Size = UDim2.new(1, 0, 0, 2)
            divWrapper.BackgroundTransparency = 1
            divWrapper.LayoutOrder = i * 2 + 1
            divWrapper.Parent = scrollFrame

            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 2)
            div.BackgroundColor3 = Patriot.Theme.Divider
            div.BorderSizePixel = 0
            div.Parent = divWrapper
        end
    end

    local function toggle(changelogIcon, container, currentContainerWidth)
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, currentContainerWidth + gap + panelWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 180}):Play() end
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, currentContainerWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 0}):Play() end
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
    panel.BackgroundColor3 = Patriot.Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Patriot.Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = isOpen and 0.4 or 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Patriot.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

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
    panelHeaderLine.BackgroundTransparency = 0.6
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
    avatarGlow.BackgroundTransparency = 0.5
    avatarGlow.BorderSizePixel = 0
    avatarGlow.Parent = avatarWrapper
    Instance.new("UICorner", avatarGlow).CornerRadius = UDim.new(0, 4)

    local avatarGlowStroke = Instance.new("UIStroke", avatarGlow)
    avatarGlowStroke.Color = Patriot.Theme.Accent
    avatarGlowStroke.Thickness = 1.5
    avatarGlowStroke.Transparency = 0.3

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
    divider1.Size = UDim2.new(1, 16, 0, 2)
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
    divider2.Size = UDim2.new(1, 16, 0, 2)
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
    divider3.Size = UDim2.new(1, 16, 0, 2)
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
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, baseWidth + gap + panelWidth, 0, panelHeight)}):Play()
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, baseWidth, 0, panelHeight)}):Play()
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
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Patriot.Theme.Accent
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.4

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
        if isChangelogOpen() then toggleCL(changelogIcon) task.wait(0.35) end
        if isUserOpen() then toggleUser(userIcon) task.wait(0.35) end
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
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

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
    headerLine.BackgroundTransparency = 0.6
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
    successBox.BackgroundTransparency = 0.85
    successBox.BorderSizePixel = 0
    successBox.Parent = main
    Instance.new("UICorner", successBox).CornerRadius = UDim.new(0, 4)

    local successStroke = Instance.new("UIStroke", successBox)
    successStroke.Color = Patriot.Theme.Success
    successStroke.Thickness = 1
    successStroke.Transparency = 0.5

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
    divider.Size = UDim2.new(1, 0, 0, 3)
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
    Instance.new("UICorner", launchBtn).CornerRadius = UDim.new(0, 4)

    local launchStroke = Instance.new("UIStroke", launchBtn)
    launchStroke.Color = Patriot.Theme.AccentHover
    launchStroke.Thickness = 1
    launchStroke.Transparency = 0.5

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

    launchBtn.MouseEnter:Connect(function() TweenService:Create(launchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Patriot.Theme.AccentHover}):Play() end)
    launchBtn.MouseLeave:Connect(function() TweenService:Create(launchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Patriot.Theme.Accent}):Play() end)

    local bottomY = contentY + 153

    local userBtn = Instance.new("TextButton")
    userBtn.Size = UDim2.new(0, 36, 0, 36)
    userBtn.Position = UDim2.new(0.5, -44, 0, bottomY)
    userBtn.AnchorPoint = Vector2.new(0.5, 0)
    userBtn.BackgroundColor3 = Patriot.Theme.Background
    userBtn.BorderSizePixel = 0
    userBtn.Text = ""
    userBtn.AutoButtonColor = false
    userBtn.Parent = main
    Instance.new("UICorner", userBtn).CornerRadius = UDim.new(0, 4)

    local userIcon = Instance.new("ImageLabel")
    userIcon.Size = UDim2.new(0, 18, 0, 18)
    userIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    userIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    userIcon.BackgroundTransparency = 1
    userIcon.Image = getIcon("user")
    userIcon.ImageColor3 = Patriot.Theme.TextDim
    userIcon.ScaleType = Enum.ScaleType.Fit
    userIcon.Parent = userBtn
    userBtn.MouseEnter:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Accent}):Play() end)
    userBtn.MouseLeave:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 36, 0, 36)
    discordBtn.Position = UDim2.new(0.5, 0, 0, bottomY)
    discordBtn.AnchorPoint = Vector2.new(0.5, 0)
    discordBtn.BackgroundColor3 = Patriot.Theme.Background
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = ""
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = main
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.new(0, 18, 0, 18)
    discordIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    discordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = getIcon("discord")
    discordIcon.ImageColor3 = Patriot.Theme.Discord
    discordIcon.ScaleType = Enum.ScaleType.Fit
    discordIcon.Parent = discordBtn
    discordBtn.MouseEnter:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.DiscordHover}):Play() end)
    discordBtn.MouseLeave:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Discord}):Play() end)

    local changelogBtn = Instance.new("TextButton")
    changelogBtn.Size = UDim2.new(0, 36, 0, 36)
    changelogBtn.Position = UDim2.new(0.5, 44, 0, bottomY)
    changelogBtn.AnchorPoint = Vector2.new(0.5, 0)
    changelogBtn.BackgroundColor3 = Patriot.Theme.Background
    changelogBtn.BorderSizePixel = 0
    changelogBtn.Text = ""
    changelogBtn.AutoButtonColor = false
    changelogBtn.Parent = main
    Instance.new("UICorner", changelogBtn).CornerRadius = UDim.new(0, 4)

    local changelogIcon = Instance.new("ImageLabel")
    changelogIcon.Size = UDim2.new(0, 18, 0, 18)
    changelogIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    changelogIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    changelogIcon.BackgroundTransparency = 1
    changelogIcon.Image = getIcon("changelog")
    changelogIcon.ImageColor3 = Patriot.Theme.TextDim
    changelogIcon.ScaleType = Enum.ScaleType.Fit
    changelogIcon.Parent = changelogBtn
    changelogBtn.MouseEnter:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Text}):Play() end)
    changelogBtn.MouseLeave:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

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
            doors.close(function() task.wait(0.3) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.4) gui:Destroy()
        end)
        if Patriot.Callbacks.OnClose then Patriot.Callbacks.OnClose() end
    end)

    launchBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Launching", "Script loaded successfully!", 2, "success")
        getgenv().SCRIPT_KEY = "KEYLESS"
        getgenv().PatriotLoaded = false
        closeDoorsThenExit(function()
            disableBlur()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.4) gui:Destroy()
            if not Internal.IsJunkieMode and Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
        end)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        if Patriot.Links.Discord ~= "" then
            Patriot:Notify("Discord", "Invite link copied!", 2, "discord")
            pcall(function() setclipboard(Patriot.Links.Discord) end)
        end
    end)

    setupDragging(header, container)
    TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.6)
    doors.open(function()
        checkIcon.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(checkIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 24, 0, 24)}):Play()
        task.wait(0.2)
        ui.toggleUser(userIcon)
        if #Patriot.Changelog > 0 then task.wait(0.3) ui.toggleCL(changelogIcon) end
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
    local statusHeight = mobile and math.clamp(60 * scale, 52, 68) or 60
    local userPanelWidth = 180
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
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

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
    headerLine.BackgroundTransparency = 0.6
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
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 4)

    local statusStroke = Instance.new("UIStroke", statusFrame)
    statusStroke.Color = Patriot.Theme.Accent
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.8

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
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)

    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = Patriot.Theme.Accent
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.7

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
    textBox.Focused:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play() end)
    textBox.FocusLost:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.7}):Play() end)

    local dividerY = inputStartY + elementHeight + 12

    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(1, 0, 0, 3)
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
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = isPrimary and Patriot.Theme.AccentHover or Patriot.Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = isPrimary and 0.5 or 0.7

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
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = origColor}):Play() end)
        return btn
    end

    local acquireBtn = createButton("Get Key", "user", false, acquireStartY)
    local redeemBtn = createButton("Verify Key", "shield", true, acquireStartY + buttonHeight + 5)
    local bottomY = acquireStartY + buttonHeight * 2 + 10

    local userBtn = Instance.new("TextButton")
    userBtn.Size = UDim2.new(0, 36, 0, 36)
    userBtn.Position = UDim2.new(0.5, -44, 0, bottomY)
    userBtn.AnchorPoint = Vector2.new(0.5, 0)
    userBtn.BackgroundColor3 = Patriot.Theme.Background
    userBtn.BorderSizePixel = 0
    userBtn.Text = ""
    userBtn.AutoButtonColor = false
    userBtn.Parent = mainFrame
    Instance.new("UICorner", userBtn).CornerRadius = UDim.new(0, 4)

    local userIcon = Instance.new("ImageLabel")
    userIcon.Size = UDim2.new(0, 18, 0, 18)
    userIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    userIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    userIcon.BackgroundTransparency = 1
    userIcon.Image = getIcon("user")
    userIcon.ImageColor3 = Patriot.Theme.TextDim
    userIcon.ScaleType = Enum.ScaleType.Fit
    userIcon.Parent = userBtn
    userBtn.MouseEnter:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Accent}):Play() end)
    userBtn.MouseLeave:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 36, 0, 36)
    discordBtn.Position = UDim2.new(0.5, 0, 0, bottomY)
    discordBtn.AnchorPoint = Vector2.new(0.5, 0)
    discordBtn.BackgroundColor3 = Patriot.Theme.Background
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = ""
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = mainFrame
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.new(0, 18, 0, 18)
    discordIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    discordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = getIcon("discord")
    discordIcon.ImageColor3 = Patriot.Theme.Discord
    discordIcon.ScaleType = Enum.ScaleType.Fit
    discordIcon.Parent = discordBtn
    discordBtn.MouseEnter:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.DiscordHover}):Play() end)
    discordBtn.MouseLeave:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Discord}):Play() end)

    local changelogBtn = Instance.new("TextButton")
    changelogBtn.Size = UDim2.new(0, 36, 0, 36)
    changelogBtn.Position = UDim2.new(0.5, 44, 0, bottomY)
    changelogBtn.AnchorPoint = Vector2.new(0.5, 0)
    changelogBtn.BackgroundColor3 = Patriot.Theme.Background
    changelogBtn.BorderSizePixel = 0
    changelogBtn.Text = ""
    changelogBtn.AutoButtonColor = false
    changelogBtn.Parent = mainFrame
    Instance.new("UICorner", changelogBtn).CornerRadius = UDim.new(0, 4)

    local changelogIcon = Instance.new("ImageLabel")
    changelogIcon.Size = UDim2.new(0, 18, 0, 18)
    changelogIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    changelogIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    changelogIcon.BackgroundTransparency = 1
    changelogIcon.Image = getIcon("changelog")
    changelogIcon.ImageColor3 = Patriot.Theme.TextDim
    changelogIcon.ScaleType = Enum.ScaleType.Fit
    changelogIcon.Parent = changelogBtn
    changelogBtn.MouseEnter:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.Text}):Play() end)
    changelogBtn.MouseLeave:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Patriot.Theme.TextDim}):Play() end)

    if #Patriot.Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    -- shop panel anchored to bottom of mainFrame with correct sizing
    if showShop then
        local shopDivider = Instance.new("Frame")
        shopDivider.Size = UDim2.new(1, 0, 0, shopDividerHeight)
        shopDivider.Position = UDim2.new(0, 0, 1, -shopHeight - shopDividerHeight)
        shopDivider.AnchorPoint = Vector2.new(0, 0)
        shopDivider.BackgroundColor3 = Patriot.Theme.Accent
        shopDivider.BackgroundTransparency = 0.6
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

        -- bottom corner fix so rounded corners only show on bottom
        local shopCorner = Instance.new("UICorner", shopFrame)
        shopCorner.CornerRadius = UDim.new(0, 4)

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
        shopIconWrapper.BackgroundTransparency = 0.7
        shopIconWrapper.BorderSizePixel = 0
        shopIconWrapper.Parent = shopFrame
        Instance.new("UICorner", shopIconWrapper).CornerRadius = UDim.new(0, 4)

        local shopIconStroke = Instance.new("UIStroke", shopIconWrapper)
        shopIconStroke.Color = Patriot.Theme.Accent
        shopIconStroke.Thickness = 1
        shopIconStroke.Transparency = 0.5

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
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 4)

        local buyBtnStroke = Instance.new("UIStroke", buyBtn)
        buyBtnStroke.Color = Patriot.Theme.AccentHover
        buyBtnStroke.Thickness = 1
        buyBtnStroke.Transparency = 0.5

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

        buyBtn.MouseEnter:Connect(function() TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Patriot.Theme.AccentHover}):Play() end)
        buyBtn.MouseLeave:Connect(function() TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Patriot.Theme.Accent}):Play() end)
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
        statusLabel.Text = text statusIcon.Image = icon
    end

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.3) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Patriot:Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.4) screenGui:Destroy()
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
                TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
                TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.4) screenGui:Destroy()
                if not Internal.IsJunkieMode and Patriot.Callbacks.OnSuccess then Patriot.Callbacks.OnSuccess() end
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
    TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.6)
    doors.open(function()
        task.wait(0.2)
        ui.toggleUser(userIcon)
        if #Patriot.Changelog > 0 then task.wait(0.3) ui.toggleCL(changelogIcon) end
    end)
end

function Patriot:Launch()
    Patriot.Callbacks.OnVerify = function(key) return Patriot:LuarmorVerify(key) end
    Internal.IsJunkieMode = false
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

function Patriot:GetSavedKey() return loadKey() end
function Patriot:ClearSavedKey() return clearKey() end

getgenv().Patriot = Patriot
return Patriot