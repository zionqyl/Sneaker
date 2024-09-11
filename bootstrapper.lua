getgenv().settings = {
    Controller = 59386847,
    Config = {
        AutoFarm = true,
        LowGraphics = true,
        AutoPCOffer = true,
        KeepMoney = 10000
    }
}

if QYL_LOADED or not getgenv().settings then
    return
end

pcall(function() getgenv().QYL_LOADED = true end)

queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

local tpCheck = false
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state, id)
    if (not tpCheck) and queueteleport then
        tpCheck = true
        if id == 12991635726 then
            queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/zionqyl/Sneaker/main/bootstrapper.lua'))()")
        end
    end
end)

local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local GuiService = game:GetService('GuiService')
local RunService = game:GetService('RunService')
local StarterGui = game:GetService('StarterGui')
local VirtualUser = game:GetService('VirtualUser')
local TextChatService = game:GetService('TextChatService')
local TeleportService = game:GetService('TeleportService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ProximityPromptService = game:GetService('ProximityPromptService')

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')
local PlayerInfo = LocalPlayer:WaitForChild('PlayerInfo')
local Leaderstats = LocalPlayer:WaitForChild('leaderstats')
local Inventory = LocalPlayer:WaitForChild('Inventory')
local SellableInventory = Inventory:WaitForChild('SellableInventory')
local UnsellableInventory = Inventory:WaitForChild('UnsellableInventory')
local Money = Leaderstats:WaitForChild('Money')
local PCProgress = LocalPlayer:WaitForChild('PcProgressOffer')
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Manager

local function sendNotification(...)
    return StarterGui:SetCore('SendNotification', ...)
end

local function lowGraphics()
    _G.Ignore = {}
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true,
            ["Ignore Tools"] = true
        },
        Meshes = {
            NoMesh = false,
            NoTexture = false,
            Destroy = false
        },
        Images = {
            Invisible = true,
            Destroy = false
        },
        Explosions = {
            Smaller = true,
            Invisible = false,
            Destroy = false
        },
        Particles = {
            Invisible = true,
            Destroy = false
        },
        TextLabels = {
            LowerQuality = true,
            Invisible = false,
            Destroy = false
        },
        MeshParts = {
            LowerQuality = true,
            Invisible = false,
            NoTexture = false,
            NoMesh = false,
            Destroy = false
        },
        Other = {
            ["FPS Cap"] = 360, -- true to uncap
            ["No Camera Effects"] = true,
            ["No Clothes"] = true,
            ["Low Water Graphics"] = true,
            ["No Shadows"] = true,
            ["Low Rendering"] = true,
            ["Low Quality Parts"] = true,
            ["Low Quality Models"] = true,
            ["Reset Materials"] = true,
        }
    }
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
end

local function sendMoney(amt, player)
    local args = {
        [1] = amt,
        [2] = player.Name
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("SendMoney"):FireServer(unpack(args))    
end

local function manageCmds(message)
    if not Manager then return end
    local seperated = string.split(string.lower(message), ' ')
    local cmd = seperated[2]
    local arg = seperated[3]
    if not seperated[1] or seperated[1] ~= '/e' or not cmd then
        return
    end
    if cmd == 's' or cmd == 'g' then
        local receiver = (not seperated[4] and Manager) or ((seperated[4] and seperated[4] == 'me') and Manager) or nil
        if receiver then
            local toSend = (Money.Value - getgenv().settings.Config.KeepMoney)
            if (toSend > 0) then
                sendMoney(toSend, receiver)
            end
        end
    end
end

local thread
local function autoFarm()
    if not thread then
        thread = coroutine.resume(coroutine.create(function()
            while true do
                if getgenv().settings.Config.AutoPCOffer then
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("BuyNewOfferFunction"):InvokeServer()
                    end)
                end
                local offers = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('RefreshPageFunction'):InvokeServer()
                for i = 1, PCProgress.Value do
                    task.spawn(function()
                        local args = {
                            [1] = 'Offer' .. i
                        }
                        pcall(function()
                            ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('BuySneakerFunction'):InvokeServer(unpack(args))
                        end)
                    end)
                end
                task.defer(function()
                    for index, sneaker in SellableInventory:GetChildren() do
                        local args = {
                            [1] = sneaker.Name,
                            [2] = sneaker.Value
                        }
                        ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('CashierEvents'):WaitForChild('SingleSellEvent'):FireServer(unpack(args))                    
                    end
                end)
                RunService.Heartbeat:Wait()
            end
        end))
    end
end

local gc = getconnections or get_signal_cons
if gc then
    for i, v in pairs(gc(LocalPlayer.Idled)) do
        if v['Disable'] then
            v['Disable'](v)
        elseif v['Disconnect'] then
            v['Disconnect'](v)
        end
    end
else
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

if getgenv().settings.Controller ~= Players.LocalPlayer.UserId then
    local check = Players:GetPlayerByUserId(getgenv().settings.Controller)
    if check then
        Manager = check
    end
    local playerChattedConnection
    local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if player.UserId == getgenv().settings.Controller then
            Manager = player
            if playerChattedConnection then playerChattedConnection:Disconnect(); playerChattedConnection = nil end
            playerChattedConnection = player.Chatted:Connect(manageCmds)
        end
    end)
    local playerRemovedConnection = Players.PlayerRemoving:Connect(function(player)
        if player.UserId == getgenv().settings.Controller then
            Manager = nil
        end
    end)
    if getgenv().settings.Config.AutoFarm then
        autoFarm()
    end
    if getgenv().settings.Config.LowGraphics then
        lowGraphics()
    end
    sendNotification({
        Title = "Bootstrapper",
        Text = "Thanks for using, successfully loaded",
        Duration = 4
    })
end
