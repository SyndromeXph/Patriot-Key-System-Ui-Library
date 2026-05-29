local Patriot = loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/expert-octo-doodle/refs/heads/main/PatriotlUi.luau"))()                                                        
-- local Patriot = loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/expert-octo-doodle/refs/heads/main/PatriotUi-luarmor.luau"))()
-- Use this version only when you need to use luarmor
-- 仅在需要使用luarmor时使用此版本。

-- local LuarmorAPI = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
-- Patriot.LuarmorScriptId = "YOUR_SCRIPT_ID_HERE"
-- Patriot.Callbacks.OnVerify = function(key)
--    local status = LuarmorAPI.check_key(key)
--    if status.code == "KEY_VALID" then
--        return { valid = true }
--   else
--       local errMsg = status.message
--        if status.code == "KEY_HWID_LOCKED" then
--           errMsg = "Key is locked to a different HWID. Please reset it."
--      elseif status.code == "KEY_INCORRECT" then
--         errMsg = "Key is invalid or does not exist."
--        elseif status.code == "KEY_EXPIRED" then
--          errMsg = "Key has expired."
--      end
--        return { valid = false, message = errMsg }
-- end
--end
-- luarmor system invoke｜卢阿莫系统调用



-- LaunchJunkie(config)｜Junkie SDK integration with automatic validation
-- LaunchJunkie(config) Junkie SDK集成，具备自动验证功能。
-- Patriot:LaunchJunkie({
--    Service = "YOUR_SERVICE_NAME",
--    Identifier = "YOUR_IDENTIFIER",
--    Provider = "YOUR_PROVIDER_NAME"
--})
-- Keys are automatically validated through Junkie



-- local HttpService = game:GetService("HttpService")
-- Patriot.Callbacks.OnVerify = function(key)
--    local success, response = pcall(function()
--        return game:HttpGet("https://api.yoursite.com/validate?key=" .. key)
--    end)    
--    if success then
--        local data = HttpService:JSONDecode(response)
--        return {
--            valid = data.valid,
--            error = data.error or "UNKNOWN",
--            message = data.message or "Invalid key"
--        }
--    end  
--    return false
-- end
-- HTTP API Validation | Validate keys through your own API endpoint



Patriot.Callbacks.OnVerify = function(key)
    return key == ""----Set key｜设置密钥
end
-- ↑↑↑↑↑Simple Validation｜简单验证
-- OnVerify｜Called when a key is submitted for validation. Return true for valid keys, or a detailed response object.
-- 当提交密钥进行验证时，会调用OnVerify。对于有效密钥，返回true，否则返回一个详细的响应对象。

-- ↓↓↓↓↓Detailed Response｜详细答复
-- Patriot.Callbacks.OnVerify = function(key)
--    return {
--        valid = false,
--        error = "KEY_EXPIRED",
--        message = "Your key has expired"
--    }
-- end



-- Appearance｜外观
Patriot.Appearance = { 
    Title = "Patriot",
    Subtitle = "Verify Key to enjoy",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}



-- Links｜链接
Patriot.Links = {
    GetKey = "",
    Discord = "https://discord.gg/xxxxxxx"
}



-- Storage｜存储
Patriot.Storage = {
    FileName = "Patriot_Key",
    Remember = true,
    AutoLoad = false
}



-- Options｜选项
Patriot.Options = {
    Keyless = false,-- Keyless Mode｜Skip the key system entirely. Perfect for free scripts.
-- Keyless = true      
-- KeylessUI = false,
-- Keyless Mode Without UI｜Completely bypass the UI and run your script immediately.
    Blur = true,
    Draggable = true
}



-- Utility Functions｜实用函数
-- local savedKey = Patriot:GetSavedKey()  -- Returns saved key or nil｜返回保存的键或 nil
-- Patriot:ClearSavedKey()                  -- Deletes saved key｜删除已保存的密钥



-- Purple theme
-- Patriot.Theme.Accent = Color3.fromRGB(138, 43, 226)
-- Patriot.Theme.AccentHover = Color3.fromRGB(159, 95, 226)
-- Patriot.Theme.Background = Color3.fromRGB(10, 10, 15)
-- Custom Theme｜Override the default theme colors to match your branding
-- 自定义主题 替换默认主题颜色，以匹配您的项目风格。



-- Theme｜主题
Patriot.Theme = {
    Accent = Color3.fromRGB(220, 20, 60),
    AccentHover = Color3.fromRGB(255, 30, 80),
    Background = Color3.fromRGB(0, 0, 0), 
    Header = Color3.fromRGB(10, 10, 10),
    Input = Color3.fromRGB(20, 20, 20),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(50, 255, 50),
    Error = Color3.fromRGB(255, 30, 80),
    Warning = Color3.fromRGB(255, 255, 0),
    StatusIdle = Color3.fromRGB(180, 40, 60),
    Discord = Color3.fromRGB(220, 20, 60),
    DiscordHover = Color3.fromRGB(255, 30, 80),
    Divider = Color3.fromRGB(30, 30, 30),
    Pending = Color3.fromRGB(40, 40, 40)
}


-- Notification System｜通知系统弹窗
-- Patriot:Notify(title, message, duration, iconType)
-- Icon Types: "info", "success", "error", "warning", "shield", "key", "copy", "discord", "close"
-- Patriot:Notify("Success", "Key validated!", 2, "success")
-- Patriot:Notify("Error", "Invalid key", 4, "error")


-- local KEYS = {
--    ["BASIC_KEY"] = "basic",
--    ["PREMIUM_KEY"] = "premium"
-- }

-- Patriot.Callbacks.OnVerify = function(key)
--    local tier = KEYS[key]
--    if tier then
--        getgenv().USER_TIER = tier
--        return true
--    end
--    return false
-- end
-- Patriot.Callbacks.OnSuccess = function()
--    if getgenv().USER_TIER == "premium" then
-- ↓↓↓↓↓PREMIUM Source code placement↓↓↓↓↓
--        loadstring(game:HttpGet("PREMIUM_URL"))()
-- ↑↑↑↑↑↑高级版源码放置↑↑↑↑↑↑↑
--    else
-- ↓↓↓↓↓BASIC Source code placement↓↓↓↓↓
--        loadstring(game:HttpGet("BASIC_URL"))()
--↑↑↑↑↑↑基本版源码放置↑↑↑↑↑↑↑
--    end
-- end
-- Multiple Key Tiers｜Implement a tiered key system where different keys unlock different features.
--多级密钥系统 实施一种分级密钥系统，其中不同的密钥可解锁不同的功能。



Patriot.Callbacks.OnSuccess = function()
    print("✅ Verification successful, loading cript")
    ----↓↓↓↓↓Source code placement↓↓↓↓↓
-- loadstring(game:HttpGet("YOUR_SCRIPT_URL"))()   
    ----↑↑↑↑↑↑源码放置↑↑↑↑↑↑↑
end
-- OnSuccess｜Called when key validation succeeds. Load your main script here.
-- OnSuccess 键验证成功时调用。请在此处加载您的主脚本。



Patriot.Callbacks.OnFail = function(errorMsg)
    print("Failed:", errorMsg)
end
-- OnFail｜Called when key validation fails
-- OnFail 当密钥验证失败时调用。



Patriot.Callbacks.OnClose = function()
    print("User closed the verification window")
end
-- OnClose｜Called when the user closes the UI without validating
-- OnClose 在用户未验证就关闭用户界面时调用。



-- local HttpService = game:GetService("HttpService")
-- Patriot.Callbacks.OnSuccess = function()
--    pcall(function()
--        HttpService:PostAsync("WEBHOOK_URL", HttpService:JSONEncode({
--            embeds = {{
--                title = "Login",
--                description = "User: " .. game.Players.LocalPlayer.Name,
--                color = 3066993
--            }}
--        }))
--    end)
-- end
--Webhook Logging｜Log successful key validations to a Discord webhook
-- Webhook日志记录 将成功的密钥验证记录到Discord Webhook中。



-- Changelog｜更新日志
-- Changelog button only appears when entries exist
-- 只有存在条目时，更新日志按钮才会显示。
Patriot.Changelog = {
    {Version = "v0.0.3", Date = "May 27, 2026", Changes = {"Add Key System Ui"}},
    {Version = "v0.0.2", Date = "May 27, 2026", Changes = {"Support luarmor", "Fixed bug"}},
    {Version = "v0.0.1", Date = "May 27, 2026", Changes = {"Add Something"}},
    {Version = "v0.0.0", Date = "May 10, 2026", Changes = {"Initial release"}}
}



-- Patriot.Shop.Enabled = true
-- Patriot.Shop.Icon = "rbxassetid://123456789"
-- Patriot.Shop.Title = "Premium Upgrade"
-- Patriot.Shop.Subtitle = "Unlock all features"
-- Patriot.Shop.ButtonText = "Get Now"
-- Patriot.Shop.Link = "https://shop.example.com"
-- Shop with Custom Icon｜Configure the shop section with a custom icon and branding
-- 使用自定义图标购物 使用自定义图标和品牌配置商店部分。

-- Shop｜商店
-- Note: Shop section only appears when Enabled = true
-- 注意：仅当Enabled（启用）设置为true时，商店部分才会显示。
Patriot.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium Access",
    Subtitle = "Instant delivery • 24/7 support",
    ButtonText = "Buy",
    Link = ""
}
-- Patriot.Shop.Enabled = true
-- Patriot.Shop.Link = "https://yourshop.com/buy"
-- Minimal Shop Setup｜The simplest way to add a shop link to your UI
-- 极简店铺设置 将店铺链接添加到用户界面的最简单方法。



Patriot:Launch()-- Launch()｜Standard key system with custom validation.
-- 启动() 带有自定义验证的标准按键系统
