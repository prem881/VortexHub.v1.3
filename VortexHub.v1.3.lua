
-- Import Libraries
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Window Settings
local Window = Fluent:CreateWindow({
    Title = "VortexHub",
    SubTitle = "Optimized GUI with Features",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main Features", Icon = "rbxassetid://4483345998" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://4483345998" })
}

-- Services and LocalPlayer
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")

-- Global Variables
_G.FreezeCharacter = false
_G.AutoCast = false
_G.AutoShake = false
_G.AutoReel = false
_G.AutoEquipRod = false
_G.AutoFish = false

-- Function: Freeze Character
local function freezeCharacter()
    local oldPos = Char.HumanoidRootPart.CFrame
    while _G.FreezeCharacter do
        task.wait(0.1)
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.CFrame = oldPos
        else
            break
        end
    end
end

-- Toggle: Freeze Character
Tabs.Main:AddToggle("FreezeCharacter", { Title = "Freeze Character", Default = false }):OnChanged(function(v)
    _G.FreezeCharacter = v
    if v then
        spawn(freezeCharacter)
    end
end)

-- Function: AutoCast
local function autoCast()
    while _G.AutoFish do
        task.wait(0.1)
        local Rod = Char:FindFirstChildOfClass("Tool")
        if Rod and Rod:FindFirstChild("events") and Rod.events:FindFirstChild("cast") then
            Rod.events.cast:FireServer(100, 1)
        end
    end
end

-- Toggle: AutoCast
Tabs.Main:AddToggle("AutoCast", { Title = "Enable AutoCast", Default = false }):OnChanged(function(v)
    _G.AutoCast = v
    if v then
        spawn(autoCast)
    end
end)

-- Function: AutoShake
local function autoShake()
    while _G.AutoFish do
        task.wait(0.01)
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local shakeUI = playerGui:FindFirstChild("shakeui")
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                if safezone then
                    local button = safezone:FindFirstChild("button")
                    if button and button:IsA("ImageButton") and button.Visible then
                        GuiService.SelectedCoreObject = button
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                end
            end
        end)
    end
end

-- Toggle: AutoShake
Tabs.Main:AddToggle("AutoShake", { Title = "Enable AutoShake", Default = false }):OnChanged(function(v)
    _G.AutoShake = v
    if v then
        spawn(autoShake)
    end
end)

-- Function: AutoReel
local function autoReel()
    while _G.AutoReel do
        task.wait(0.15)
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name == "reel" then
                if gui:FindFirstChild("bar") then
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        end
    end
end

-- Toggle: AutoReel
Tabs.Main:AddToggle("AutoReel", { Title = "Enable AutoReel", Default = false }):OnChanged(function(v)
    _G.AutoReel = v
    if v then
        spawn(autoReel)
    end
end)

-- Function: Auto Equip Rod
local function equipItem(itemName)
    local item = LocalPlayer.Backpack:FindFirstChild(itemName)
    if item then
        Char.Humanoid:EquipTool(item)
    end
end

local function autoEquipRod()
    while _G.AutoEquipRod do
        task.wait(0.5)
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                equipItem(tool.Name)
            end
        end
    end
end

-- Toggle: AutoEquipRod
Tabs.Main:AddToggle("AutoEquipRod", { Title = "Auto Equip Rod", Default = false }):OnChanged(function(v)
    _G.AutoEquipRod = v
    if v then
        spawn(autoEquipRod)
    end
end)

-- Function: AutoFish
local function autoFish()
    while _G.AutoFish do
        task.wait(0.1)
        local rod = Char:FindFirstChildOfClass("Tool")
        if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
            rod.events.cast:FireServer(100, 1)
        end
        autoShake()
        autoReel()
    end
end

-- Toggle: AutoFish
Tabs.Main:AddToggle("AutoFish", { Title = "Enable AutoFish", Default = false }):OnChanged(function(v)
    _G.AutoFish = v
    if v then
        spawn(autoFish)
    end
end)

-- SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("VortexHub")
SaveManager:SetFolder("VortexHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Load Settings
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
