local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local AutoCtx = nil
local localPlayer = Players.LocalPlayer
local player = localPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fluent = {}
Fluent.__index = Fluent

local Config = {
    Title = "T1nkq",
    WindowSize = Vector2.new(620, 450),
    AccentColor = Color3.fromRGB(88, 101, 242),
    ErrorColor = Color3.fromRGB(237, 66, 69),
    Colors = {
        Background = Color3.fromRGB(30, 31, 34),
        Secondary  = Color3.fromRGB(43, 45, 49),
        Tertiary   = Color3.fromRGB(54, 57, 63),
        Text       = Color3.fromRGB(242, 243, 245),
        TextSecondary = Color3.fromRGB(185, 187, 190),
        Border     = Color3.fromRGB(66, 69, 75),
        Hover      = Color3.fromRGB(70, 73, 80),
    },
    Fonts = {
        Title = Enum.Font.GothamBold,
        Body  = Enum.Font.GothamSemibold,
        Light = Enum.Font.Gotham,
    },
    Rounding = 10,
}

-- ⭐ БАЗОВЫЕ HELPER ФУНКЦИИ (определяем в самом начале)
local function Create(className, properties)
    local element = Instance.new(className)
    local children = properties.Children
    properties.Children = nil
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = element
        end
    end
    return element
end

local function AttachStrokeGradient(uiStroke)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    grad.Rotation = 0
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 0.35),
    })
    grad.Parent = uiStroke
    return grad
end

-- ⭐ UI HELPER ФУНКЦИИ (определяем ПЕРЕД их использованием)
local function CreateIconButton(CreateFn, ConfigTbl, props)
    local btn = CreateFn("TextButton", {
        Parent = props.Parent,
        Name = props.Name or "Icon",
        Size = UDim2.fromOffset(props.Size or 28, props.Size or 28),
        BackgroundColor3 = props.BackgroundColor3 or ConfigTbl.Colors.Secondary,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Text = props.Text or "",
        Font = props.Font or ConfigTbl.Fonts.Body,
        TextSize = props.TextSize or 18,
        TextColor3 = props.TextColor3 or ConfigTbl.Colors.Text,
        Children = {
            CreateFn("UICorner", { CornerRadius = UDim.new(0, ConfigTbl.Rounding - 4) }),
            CreateFn("UIStroke", { Color = ConfigTbl.Colors.Border, Thickness = 1.2 }),
        }
    })
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if stroke then AttachStrokeGradient(stroke) end

    local hoverTI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local clickTI = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local origBg = btn.BackgroundColor3
    local hoverBg = props.HoverColor3 or ConfigTbl.Colors.Hover

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, hoverTI, {BackgroundColor3 = hoverBg}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, hoverTI, {BackgroundColor3 = origBg}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, clickTI, {Size = UDim2.fromOffset((props.Size or 28)-2, (props.Size or 28)-2)}):Play()
        task.delay(0.09, function()
            TweenService:Create(btn, clickTI, {Size = UDim2.fromOffset((props.Size or 28), (props.Size or 28))}):Play()
        end)
        if props.OnClick then
            task.spawn(function()
                local ok, err = pcall(props.OnClick)
                if not ok then warn(err) end
            end)
        end
    end)
    return btn
end

local function ToggleButton(button, opts)
    local state, busy = false, false
    button.Text = opts.startText or "Запустить"

    local function setVisual(on)
        state = on
        if state then
            button.Text = opts.stopText or "Остановить"
        else
            button.Text = opts.startText or "Запустить"
        end
    end

    local function safeCall(fn)
        if typeof(fn) == "function" then
            local ok, err = pcall(fn)
            if not ok then warn(err) end
        end
    end

    button.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        if not state then
            setVisual(true);  safeCall(opts.onStart)
        else
            setVisual(false); safeCall(opts.onStop)
        end
        task.delay(0.15, function() busy = false end)
    end)

    return {
        Set = function(on)
            if state ~= on then
                setVisual(on)
                if on then safeCall(opts.onStart) else safeCall(opts.onStop) end
            end
        end,
        Get = function() return state end,
        On = function() if not state then setVisual(true); safeCall(opts.onStart) end end,
        Off = function() if state then setVisual(false); safeCall(opts.onStop) end end
    }
end

-- ⭐ ИГРОВЫЕ ФУНКЦИИ
local function teleport(pos)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local PLOTS = {
    { min = Vector3.new(123, 1, 758),  max = Vector3.new(28, 100, 500),  name = "Plot 1" },
    { min = Vector3.new(18, 1, 758),   max = Vector3.new(-72, 100, 500), name = "Plot 2" },
    { min = Vector3.new(-80, 1, 758),  max = Vector3.new(-170, 100, 500),name = "Plot 3" },
    { min = Vector3.new(-182, 1, 758), max = Vector3.new(-278, 100, 500),name = "Plot 4" },
    { min = Vector3.new(-284, 1, 758), max = Vector3.new(-376, 100, 500),name = "Plot 5" },
    { min = Vector3.new(-383, 1, 758), max = Vector3.new(-477, 100, 500),name = "Plot 6" },
}

local Boxes = {}
for i,b in ipairs(PLOTS) do
    local minX, maxX = math.min(b.min.X, b.max.X), math.max(b.min.X, b.max.X)
    local minY, maxY = math.min(b.min.Y, b.max.Y), math.max(b.min.Y, b.max.Y)
    local minZ, maxZ = math.min(b.min.Z, b.max.Z), math.max(b.min.Z, b.max.Z)
    Boxes[i] = { min = Vector3.new(minX,minY,minZ), max = Vector3.new(maxX,maxY,maxZ), name = b.name }
end

local function inAABB(pos, box)
    local yMin = box.min.Y - 50
    local yMax = box.max.Y + 50
    return pos.X >= box.min.X and pos.X <= box.max.X
        and pos.Z >= box.min.Z and pos.Z <= box.max.Z
        and pos.Y >= yMin and pos.Y <= yMax
end

local function getMyPlotIndex()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local p = hrp.Position
    for i, box in ipairs(Boxes) do
        if inAABB(p, box) then return i end
    end
    return nil
end

local PLOT_POS = {
    [1] = Vector3.new(46.06, 10, 652),
    [2] = Vector3.new(-54,   10, 652),
    [3] = Vector3.new(-156,  10, 652),
    [4] = Vector3.new(-257,  10, 652),
    [5] = Vector3.new(-358,  10, 652),
    [6] = Vector3.new(-459,  10, 652),
}

local SeedsCatalog = {
    { ui = "Cactus Seed",              id = "CactusSeed" },
    { ui = "Grape Seed",              id = "GrapeSeed" },
    { ui = "Cocotank Seed",           id = "CocotankSeed" },
    { ui = "Carnivorous Plant Seed",  id = "CarnivorousPlantSeed" },
    { ui = "Mr Carrot Seed",          id = "MrCarrotSeed" },
    { ui = "Tomatrio Seed",           id = "TomatrioSeed" },
    { ui = "Shroombino Seed",         id = "ShroombinoSeed" },
}

local SelectedSeeds = {}
local PurchaseCount = 1

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:FindFirstChild("Remotes") or RS
local BuyItem   = Remotes:FindFirstChild("BuyItem")
local BuyRow    = Remotes:FindFirstChild("BuyRow")

-- ⭐ ФУНКЦИИ ПОКУПКИ
local function purchaseSeed(uiName)
    local currency = "Cash"
    local altId = nil
    for _, s in ipairs(SeedsCatalog) do
        if s.ui == uiName then altId = s.id break end
    end
    if not altId then 
        warn("Unknown seed ui:", uiName)
        return false
    end

    print("Покупаю:", uiName)
    
    local success = false
    if BuyItem then
        success = pcall(function()
            BuyItem:FireServer(uiName, currency)
        end)
        if not success then
            success = pcall(function() 
                BuyItem:FireServer(altId, currency) 
            end)
        end
        if not success then
            success = pcall(function() 
                BuyItem:FireServer({id = uiName, currency = currency}) 
            end)
        end
    end

    if not success and BuyRow then
        pcall(function() BuyRow:FireServer(uiName, currency) end)
    end
    
    return success
end

local function autoPurchaseSelected()
    local selectedList = {}
    for uiName, isSelected in pairs(SelectedSeeds) do
        if isSelected then
            table.insert(selectedList, uiName)
        end
    end
    
    if #selectedList == 0 then
        print("❌ Не выбраны семена для покупки!")
        return
    end
    
    print("🛒 Начинаю покупку " .. PurchaseCount .. " раз(а) для " .. #selectedList .. " семян")
    
    task.spawn(function()
        for round = 1, PurchaseCount do
            if AutoCtx and AutoCtx.stopFlag then 
                print("❌ Покупка прервана пользователем")
                break 
            end
            
            print("🔄 Раунд покупок " .. round .. "/" .. PurchaseCount)
            
            for _, seedName in ipairs(selectedList) do
                if AutoCtx and AutoCtx.stopFlag then break end
                
                purchaseSeed(seedName)
                task.wait(0.5) -- Задержка между покупками
            end
            
            if round < PurchaseCount then
                task.wait(1) -- Задержка между раундами
            end
        end
        
        print("✅ Все покупки завершены!")
    end)
end

-- ⭐ АВТОФАРМ ФУНКЦИИ
local function getTargetPosForMyPlot()
    local idx = getMyPlotIndex()
    if idx and PLOT_POS[idx] then
        return PLOT_POS[idx], idx
    end
    return nil, nil
end

local function onRestockTriggered()
    local target = select(1, getTargetPosForMyPlot())
    if target then
        teleport(target)
        task.wait(0.4)
        autoPurchaseSelected()
    else
        warn("Restock: не удалось определить участок")
    end
end

local function containsRestockText(gui)
    if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text then
        local t = gui.Text
        if t:find("Your Seeds Store has been restocked") or t:find("Your Gears Store has been restocked") then
            return true
        end
    end
    return false
end

local restockConnA, restockConnB
local function hookRestockWatcher(ctx)
    for _, d in ipairs(playerGui:GetDescendants()) do
        if containsRestockText(d) then
            onRestockTriggered()
            break
        end
    end
    restockConnA = playerGui.DescendantAdded:Connect(function(inst)
        task.defer(function()
            if containsRestockText(inst) then
                onRestockTriggered()
            end
        end)
    end)
    restockConnB = playerGui.DescendantAdded:Connect(function(inst)
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                if containsRestockText(inst) then
                    onRestockTriggered()
                end
            end)
        end
    end)
    ctx.connections = ctx.connections or {}
    table.insert(ctx.connections, restockConnA)
    table.insert(ctx.connections, restockConnB)
end

local function StartAutoFarmLoop(ctx)
    task.spawn(function()
        while not ctx.stopFlag do
            local target, idx = getTargetPosForMyPlot()
            if not target then
                warn("Не удалось определить участок: вне зон или нет точки для него")
            else
                hookRestockWatcher(ctx)
                print("AutoFarm: ждём рестока магазина...")
                teleport(target)
                task.wait(0.4)
                autoPurchaseSelected()
            end

            local t = 300
            while t > 0 and not ctx.stopFlag do
                task.wait(0.5); t -= 0.5
            end
        end
    end)
end

local function StopAutoFarmLoop(ctx)
    ctx.stopFlag = true
    if ctx.connections then
        for _, c in ipairs(ctx.connections) do
            if typeof(c) == "RBXScriptConnection" then 
                pcall(function() c:Disconnect() end) 
            end
        end
        ctx.connections = {}
    end
end

-- ⭐ ФУНКЦИИ UI (определяем ПЕРЕД созданием UI)
function Fluent:CreateButton(props)
    local btn = Create("TextButton", {
        Parent = props.Parent, Name = props.Name or "Button", Size = props.Size, Position = props.Position,
        BackgroundColor3 = props.BackgroundColor or Config.Colors.Tertiary, Text = props.Text or "", Font = props.Font or Config.Fonts.Body,
        TextColor3 = props.TextColor or Config.Colors.Text, TextSize = props.TextSize or 16, Visible = (props.Visible == nil) and true or props.Visible,
        AutoButtonColor = false, LayoutOrder = props.LayoutOrder, AnchorPoint = Vector2.new(0.5, 0.5),
        Children = { Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding - 2) }), Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1 }) }
    })
    if props.Parent and not props.Parent:IsA("GuiObjectWithLayout") then
        btn.Position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
    end

    local originalColor = btn.BackgroundColor3
    local hoverColor = props.HoverColor or Config.Colors.Hover
    local ti = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, ti, {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, ti, {BackgroundColor3 = originalColor}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if props.OnClick then pcall(props.OnClick) end
    end)

    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if stroke then AttachStrokeGradient(stroke) end

    return btn
end

function Fluent:SetupUserPanel()
    local userFrame = Create("Frame", {
        Name = "UserPanel",
        Parent = self.Sidebar,
        Size = UDim2.new(1, -8, 0, 50),
        BackgroundColor3 = Config.Colors.Background,
        Position = UDim2.new(0.5, 0, 1, -10),
        AnchorPoint = Vector2.new(0.5, 1),
        BorderSizePixel = 0,
        Children = { Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding - 2) }) }
    })

    local thumb = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Create("ImageLabel", {
        Parent = userFrame, Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 5, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        Image = thumb, BackgroundTransparency = 1,
        Children = { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) }
    })

    Create("TextLabel", {
        Parent = userFrame, Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 60, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1, Font = Config.Fonts.Body,
        Text = localPlayer.DisplayName, TextColor3 = Config.Colors.Text, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center
    })
end

function Fluent:MakeDraggable(guiObject, dragArea)
    local dragging, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, guiObject.Position
            local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)
end

-- ⭐ ОСНОВНАЯ ФУНКЦИЯ UI
function Fluent.new()
    local self = setmetatable({}, Fluent)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    self.ScreenGui = Create("ScreenGui", {
        Name = "FluentUI_" .. math.random(1000, 9999),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
    })

    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 600, 0, 300),
        Position = UDim2.new(0.5, 0, 0.05, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding) }),
            Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1.5 }),
        }
    })
    local outerStroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    if outerStroke then AttachStrokeGradient(outerStroke) end

    self.TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding) }),
            Create("Frame", {
                Name = "BottomLine",
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundTransparency = 1,
                Children = {
                    Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Color = Config.Colors.Border })
                }
            }),
        }
    })
    local blStroke = self.TopBar.BottomLine:FindFirstChildOfClass("UIStroke")
    if blStroke then AttachStrokeGradient(blStroke) end

    self.TitleLabel = Create("TextLabel", {
        Parent = self.TopBar,
        Size = UDim2.new(0, 240, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Config.Fonts.Title,
        Text = Config.Title,
        TextColor3 = Config.Colors.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    self.TopRight = Create("Frame", {
        Parent = self.TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -88, 0, 0),
        Children = {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right
            })
        }
    })

    self.MinBtn = CreateIconButton(Create, Config, {
        Parent = self.TopRight, Text = "–", Size = 28,
        OnClick = function()
            self.MainFrame.Visible = false
            self.RestoreButton.Visible = true
        end
    })

    self.CloseBtn = CreateIconButton(Create, Config, {
        Parent = self.TopRight, Text = "×", Size = 28,
        BackgroundColor3 = Config.ErrorColor,
        HoverColor3 = Config.ErrorColor:lerp(Color3.new(1,1,1), 0.15),
        OnClick = function()
            if self.ScreenGui then self.ScreenGui:Destroy() end
        end
    })

    self.RestoreButton = Create("TextButton", {
        Parent = self.ScreenGui,
        Size = UDim2.fromOffset(48, 48),
        Position = UDim2.fromOffset(20, 20),
        Text = "🚀",
        TextSize = 24,
        AutoButtonColor = false,
        Visible = false,
        BackgroundColor3 = Config.AccentColor,
        TextColor3 = Config.Colors.Text,
        Font = Config.Fonts.Body,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding - 2) }),
            Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1 })
        }
    })
    
    -- Drag functionality for RestoreButton
    do
        local dragging, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            self.RestoreButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        self.RestoreButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, self.RestoreButton.Position
                local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                update(input)
            end
        end)
        self.RestoreButton.MouseButton1Click:Connect(function()
            self.RestoreButton.Visible = false
            self.MainFrame.Visible = true
        end)
    end

    self.Sidebar = Create("Frame", {
        Name = "SidebarContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 180, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    Create("Frame", {
        Parent = self.Sidebar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding) }),
            Create("Frame", {
                Name = "RightCornerCover",
                BackgroundColor3 = Config.Colors.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(0, Config.Rounding, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
            })
        }
    })

    self.SidebarButtonContainer = Create("ScrollingFrame", {
        Name = "ButtonContainer",
        Parent = self.Sidebar,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.AccentColor,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, FillDirection = Enum.FillDirection.Vertical }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 12) }),
        }
    })

    self.ContentFrame = Create("Frame", {
        Name = "ContentFrame",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -180, 1, -40),
        Position = UDim2.new(0, 180, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    self.PagesHolder = Create("Frame", {
        Name = "PagesHolder",
        Parent = self.ContentFrame,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })

    self.UIPageLayout = Create("UIPageLayout", {
        Parent = self.PagesHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        TweenTime = 0.2,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
        Circular = false,
        ScrollWheelInputEnabled = true,
        TouchInputEnabled = true,
    })

    -- MAIN PAGE
    self.Page_Main = Create("Frame", {
        Name = "Page_Main",
        Parent = self.PagesHolder,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10) }),
        }
    })
    
    local startStopBtn = self:CreateButton({
        Parent = self.Page_Main,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "🚀 Запустить Auto Farm",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() end
    })
    
    self.AutoFarmController = ToggleButton(startStopBtn, {
        startText = "🚀 Запустить Auto Farm",
        stopText  = "⛔ Остановить Auto Farm",
        onStart = function()
            warn("Auto Farm активирован")
            AutoCtx = { stopFlag = false }
            StartAutoFarmLoop(AutoCtx)
        end,
        onStop = function()
            warn("Auto Farm остановлен")
            if AutoCtx then AutoCtx.stopFlag = true end
        end
    })

    -- SETTINGS PAGE
    self.Page_Settings = Create("Frame", {
        Name = "Page_Settings",
        Parent = self.PagesHolder,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10) }),
        }
    })
    
    -- Seeds selection panel
    do
        local header = self:CreateButton({
            Parent = self.Page_Settings,
            Size = UDim2.new(1, -20, 0, 38),
            Text = "🌱 Выбор семян",
            BackgroundColor = Config.Colors.Secondary,
            OnClick = function() end
        })

        local wrap = Create("Frame", {
            Parent = self.Page_Settings,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        local panel = Create("ScrollingFrame", {
            Parent = wrap,
            Name = "SeedsScroll",
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            BackgroundTransparency = 1,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Children = {
                Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
                Create("UIPadding", { PaddingTop = UDim.new(0, 6) }),
            }
        })

        local opened = false
        local function togglePanel()
            opened = not opened
            wrap.Visible = opened
            header.Text = opened and "🌱 Выбор семян" or "🌱 Выбор семян"
            wrap.Size = opened and UDim2.new(1, -20, 0, 250) or UDim2.new(1, -20, 0, 0)
            RunService.Heartbeat:Wait()
            self.SidebarButtonContainer.CanvasSize = UDim2.new(0,0,0, self.SidebarButtonContainer.UIListLayout.AbsoluteContentSize.Y)
        end
        header.MouseButton1Click:Connect(togglePanel)

        for _, item in ipairs(SeedsCatalog) do
            local btn = self:CreateButton({
                Parent = panel,
                Size = UDim2.new(1, -20, 0, 34),
                Text = "❌ " .. item.ui,
                BackgroundColor = Config.Colors.Tertiary,
                OnClick = function() end
            })
            SelectedSeeds[item.ui] = SelectedSeeds[item.ui] or false
            btn.MouseButton1Click:Connect(function()
                SelectedSeeds[item.ui] = not SelectedSeeds[item.ui]
                btn.Text = (SelectedSeeds[item.ui] and "✔️ " or "❌ ") .. item.ui
            end)
        end
        
        local countInput = Create("TextBox", {
            Parent = countFrame,
            Size = UDim2.new(0.4, -5, 1, 0),
            Position = UDim2.new(0.6, 5, 0, 0),
            BackgroundColor3 = Config.Colors.Background,
            Font = Config.Fonts.Body,
            TextColor3 = Config.Colors.Text,
            Text = tostring(PurchaseCount),
            ClearTextOnFocus = false,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding - 4) }),
                Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1 })
            }
        })

        countInput.FocusLost:Connect(function(enterPressed)
            local num = tonumber(countInput.Text)
            if num and num > 0 and num <= 50 then
                PurchaseCount = math.floor(num)
            else
                PurchaseCount = 1
            end
            countInput.Text = tostring(PurchaseCount)
        end)

        -- Buy button
        self:CreateButton({
            Parent = panel,
            LayoutOrder = 100,
            Size = UDim2.new(1, -20, 0, 34),
            Text = "🛒 Купить выбранные",
            BackgroundColor = Config.Colors.Secondary,
            OnClick = function()
                autoPurchaseSelected()
            end
        })
    end
    
    -- Navigation buttons
    local function addNavButton(label, targetPage)
        local button = self:CreateButton({
            Parent = self.SidebarButtonContainer,
            Size = UDim2.new(1, -20, 0, 40),
            Text = label,
            BackgroundColor = Config.Colors.Tertiary,
            OnClick = function()
                self.UIPageLayout:JumpTo(targetPage)
            end
        })
        RunService.Heartbeat:Wait()
        self.SidebarButtonContainer.CanvasSize = UDim2.new(0,0,0,self.SidebarButtonContainer.UIListLayout.AbsoluteContentSize.Y)
        return button
    end

    self.Btn_Main = addNavButton("🖕 Main", self.Page_Main)
    self.Btn_Settings  = addNavButton("⚙️ Autofarm Settings", self.Page_Settings)

    -- Active button system
    local activeBtn = nil
    local function setActive(btn)
        if activeBtn and activeBtn ~= btn then
            activeBtn.BackgroundColor3 = Config.Colors.Tertiary
            activeBtn.TextColor3 = Config.Colors.TextSecondary
        end
        activeBtn = btn
        activeBtn.BackgroundColor3 = Config.AccentColor
        activeBtn.TextColor3 = Config.Colors.Text
    end

    self.Btn_Main.MouseButton1Click:Connect(function() setActive(self.Btn_Main) end)
    self.Btn_Settings.MouseButton1Click:Connect(function() setActive(self.Btn_Settings) end)

    self.UIPageLayout:JumpTo(self.Page_Main)
    setActive(self.Btn_Main)

    self:SetupUserPanel()
    self:MakeDraggable(self.MainFrame, self.TopBar)

    self.ScreenGui.Parent = playerGui
    return self
end

-- ⭐ ЗАПУСК UI
local MyUI = Fluent.new()
