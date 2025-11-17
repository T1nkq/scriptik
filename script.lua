-- ================================
-- MODERN ROBLOX EXECUTOR UI v3
-- Premium Dark Theme
-- ================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local AutoCtx = nil

-- ================================
-- ПРЕМИУМ ТЕМНАЯ ТЕМА
-- ================================

local Theme = {
    Background = {
        Primary   = Color3.fromRGB(13, 13, 18),       -- Главный фон (очень темный)
        Secondary = Color3.fromRGB(18, 18, 24),       -- Sidebar
        Tertiary  = Color3.fromRGB(24, 24, 32),       -- Кнопки/карточки
        Elevated  = Color3.fromRGB(28, 28, 36),       -- Поднятые элементы
        Content   = Color3.fromRGB(16, 16, 22),       -- Контент-область
    },
    
    Accent = {
        Primary   = Color3.fromRGB(88, 101, 242),     -- Discord Blurple
        Secondary = Color3.fromRGB(114, 137, 218),    
        Success   = Color3.fromRGB(67, 181, 129),     
        Warning   = Color3.fromRGB(250, 166, 26),     
        Error     = Color3.fromRGB(237, 66, 69),      
    },
    
    Text = {
        Primary   = Color3.fromRGB(255, 255, 255),    
        Secondary = Color3.fromRGB(148, 155, 164),    
        Disabled  = Color3.fromRGB(79, 84, 92),       
        OnAccent  = Color3.fromRGB(255, 255, 255),    
    },
    
    State = {
        Hover     = Color3.fromRGB(32, 34, 42),       
        Active    = Color3.fromRGB(42, 44, 52),       
    },
    
    Border = {
        Default   = Color3.fromRGB(32, 34, 42),       
        Subtle    = Color3.fromRGB(26, 28, 36),       
        Accent    = Color3.fromRGB(88, 101, 242),     
    },
}

local Animations = {
    Quick = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
}

local Fonts = {
    Bold = Enum.Font.GothamBold,
    Semibold = Enum.Font.GothamSemibold,
    Regular = Enum.Font.Gotham,
}

-- ================================
-- УТИЛИТЫ
-- ================================

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

local function ApplyGradientStroke(stroke)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(114, 137, 218)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242)),
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.7),
    })
    gradient.Rotation = 45
    gradient.Parent = stroke
    return gradient
end

local function CreatePressEffect(button, originalSize)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, Animations.Press, {
            Size = UDim2.new(
                originalSize.X.Scale, originalSize.X.Offset - 3,
                originalSize.Y.Scale, originalSize.Y.Offset - 3
            )
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, Animations.Press, {
            Size = originalSize
        }):Play()
    end)
end

-- ================================
-- BACKEND ФУНКЦИИ
-- ================================

local function teleport(pos)
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
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
for i, b in ipairs(PLOTS) do
    local minX = math.min(b.min.X, b.max.X)
    local maxX = math.max(b.min.X, b.max.X)
    local minY = math.min(b.min.Y, b.max.Y)
    local maxY = math.max(b.min.Y, b.max.Y)
    local minZ = math.min(b.min.Z, b.max.Z)
    local maxZ = math.max(b.min.Z, b.max.Z)
    Boxes[i] = {
        min = Vector3.new(minX, minY, minZ),
        max = Vector3.new(maxX, maxY, maxZ),
        name = b.name
    }
end

local function inAABB(pos, box)
    local yMin = box.min.Y - 50
    local yMax = box.max.Y + 50
    return pos.X >= box.min.X and pos.X <= box.max.X
        and pos.Z >= box.min.Z and pos.Z <= box.max.Z
        and pos.Y >= yMin and pos.Y <= yMax
end

local function getMyPlotIndex()
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local p = hrp.Position
    for i, box in ipairs(Boxes) do
        if inAABB(p, box) then return i end
    end
    return nil
end

local PLOT_POS = {
    [1] = Vector3.new(46.06, 10, 652),
    [2] = Vector3.new(-54, 10, 652),
    [3] = Vector3.new(-156, 10, 652),
    [4] = Vector3.new(-257, 10, 652),
    [5] = Vector3.new(-358, 10, 652),
    [6] = Vector3.new(-459, 10, 652),
}

local SeedsCatalog = {
    { ui = "Cactus Seed", id = "CactusSeed" },
    { ui = "Grape Seed", id = "GrapeSeed" },
    { ui = "Cocotank Seed", id = "CocotankSeed" },
    { ui = "Carnivorous Plant Seed", id = "CarnivorousPlantSeed" },
    { ui = "Mr Carrot Seed", id = "MrCarrotSeed" },
    { ui = "Tomatrio Seed", id = "TomatrioSeed" },
    { ui = "Shroombino Seed", id = "ShroombinoSeed" },
    { ui = "Mango Seed", id = "MangoSeed" },
    { ui = "King Limone Seed", id = "KingLimoneSeed" },
    { ui = "Starfruit Seed", id = "StarfruitSeed" },
}

local SelectedSeeds = {}
local PurchaseCount = 1

local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
local BuyItem = Remotes:FindFirstChild("BuyItem")
local BuyRow = Remotes:FindFirstChild("BuyRow")

local function purchaseSeed(uiName)
    local currency = "Cash"
    local altId = nil
    for _, s in ipairs(SeedsCatalog) do
        if s.ui == uiName then altId = s.id break end
    end
    if not altId then return false end

    local success = false
    if BuyItem then
        success = pcall(function() BuyItem:FireServer(uiName, currency) end)
        if not success then
            success = pcall(function() BuyItem:FireServer(altId, currency) end)
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
        if isSelected then table.insert(selectedList, uiName) end
    end
    
    if #selectedList == 0 then
        print("❌ Не выбраны семена для покупки!")
        return
    end
    
    print("🛒 Начинаю покупку " .. PurchaseCount .. " раз(а) для " .. #selectedList .. " семян")
    
    task.spawn(function()
        for round = 1, PurchaseCount do
            if AutoCtx and AutoCtx.stopFlag then break end
            
            print("🔄 Раунд покупок " .. round .. "/" .. PurchaseCount)
            
            for _, seedName in ipairs(selectedList) do
                if AutoCtx and AutoCtx.stopFlag then break end
                purchaseSeed(seedName)
                task.wait(0.5)
            end
            
            if round < PurchaseCount then task.wait(1) end
        end
        
        print("✅ Все покупки завершены!")
    end)
end

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
    end
end

local function containsRestockText(gui)
    if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text then
        local t = gui.Text
        if t:find("Your Plants Shop has been restocked") or t:find("Your Gear Shop has been restocked") then
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
            if containsRestockText(inst) then onRestockTriggered() end
        end)
    end)
    
    restockConnB = playerGui.DescendantAdded:Connect(function(inst)
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                if containsRestockText(inst) then onRestockTriggered() end
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
            if target then
                hookRestockWatcher(ctx)
                print("🌾 AutoFarm активен. Ожидание рестока...")
                teleport(target)
                task.wait(0.4)
                autoPurchaseSelected()
            end

            local t = 300
            while t > 0 and not ctx.stopFlag do
                task.wait(0.5)
                t = t - 0.5
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

-- ================================
-- UI КОМПОНЕНТЫ
-- ================================

local UI = {}

function UI:CreateButton(props)
    local btn = Create("TextButton", {
        Parent = props.Parent,
        Name = props.Name or "Button",
        Size = props.Size,
        Position = props.Position,
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        BackgroundColor3 = props.BackgroundColor or Theme.Background.Tertiary,
        Text = props.Text or "",
        Font = props.Font or Fonts.Semibold,
        TextColor3 = props.TextColor or Theme.Text.Primary,
        TextSize = props.TextSize or 15,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { 
                Color = props.StrokeColor or Theme.Border.Default, 
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })

    local stroke = btn:FindFirstChildOfClass("UIStroke")

    if props.Gradient then
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent.Primary),
            ColorSequenceKeypoint.new(1, Theme.Accent.Secondary)
        })
        grad.Rotation = 45
        grad.Parent = btn
        
        if stroke then
            stroke.Color = Theme.Accent.Primary
            stroke.Transparency = 0.5
        end
    end

    local originalColor = btn.BackgroundColor3
    local hoverColor = props.HoverColor or (props.Gradient and Theme.Accent.Primary:lerp(Color3.new(1,1,1), 0.1) or Theme.State.Hover)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, Animations.Quick, {
            BackgroundColor3 = hoverColor
        }):Play()
        if stroke then
            TweenService:Create(stroke, Animations.Quick, {
                Transparency = 0.4
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, Animations.Quick, {
            BackgroundColor3 = originalColor
        }):Play()
        if stroke then
            TweenService:Create(stroke, Animations.Quick, {
                Transparency = props.Gradient and 0.5 or 0.8
            }):Play()
        end
    end)

    CreatePressEffect(btn, btn.Size)

    if props.OnClick then
        btn.MouseButton1Click:Connect(function()
            pcall(props.OnClick)
        end)
    end

    return btn
end

function UI:CreateToggle(parent, labelText, defaultState, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -24, 0, 48),
        BackgroundColor3 = Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", {
                Color = Theme.Border.Default,
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })

    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        Font = Fonts.Semibold,
        TextSize = 14,
        TextColor3 = Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local switch = Create("Frame", {
        Parent = container,
        Size = UDim2.fromOffset(48, 26),
        Position = UDim2.new(1, -60, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultState and Theme.Accent.Primary or Theme.Background.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        }
    })

    local knob = Create("Frame", {
        Name = "Knob",
        Parent = switch,
        Size = UDim2.fromOffset(20, 20),
        Position = defaultState and UDim2.new(1, -23, 0.5, 0) or UDim2.fromOffset(3, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        }
    })

    local state = defaultState
    local button = Create("TextButton", {
        Parent = container,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = ""
    })

    button.MouseButton1Click:Connect(function()
        state = not state
        
        local info = state and Animations.Bounce or Animations.Standard
        
        TweenService:Create(switch, Animations.Quick, {
            BackgroundColor3 = state and Theme.Accent.Primary or Theme.Background.Secondary
        }):Play()
        
        TweenService:Create(knob, info, {
            Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.fromOffset(3, 0)
        }):Play()
        
        if callback then callback(state) end
    end)

    return container, function() return state end
end

function UI:CreateCheckbox(parent, labelText, defaultChecked, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -24, 0, 38),
        BackgroundTransparency = 1
    })

    local box = Create("Frame", {
        Parent = container,
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.fromOffset(0, 8),
        BackgroundColor3 = defaultChecked and Theme.Accent.Primary or Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
            Create("UIStroke", {
                Color = defaultChecked and Theme.Accent.Primary or Theme.Border.Default,
                Thickness = 1.5,
                Transparency = defaultChecked and 0.5 or 0.8
            })
        }
    })

    local check = Create("TextLabel", {
        Parent = box,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "✓",
        Font = Fonts.Bold,
        TextSize = 16,
        TextColor3 = Theme.Text.OnAccent,
        Visible = defaultChecked
    })

    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.fromOffset(32, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        Font = Fonts.Regular,
        TextSize = 14,
        TextColor3 = Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local button = Create("TextButton", {
        Parent = container,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = ""
    })

    local checked = defaultChecked
    local boxStroke = box:FindFirstChildOfClass("UIStroke")

    button.MouseButton1Click:Connect(function()
        checked = not checked
        
        TweenService:Create(box, Animations.Quick, {
            BackgroundColor3 = checked and Theme.Accent.Primary or Theme.Background.Tertiary
        }):Play()
        
        if boxStroke then
            TweenService:Create(boxStroke, Animations.Quick, {
                Color = checked and Theme.Accent.Primary or Theme.Border.Default,
                Transparency = checked and 0.5 or 0.8
            }):Play()
        end
        
        check.Visible = checked
        if callback then callback(checked) end
    end)

    return container, function() return checked end
end

function UI:CreatePanel(parent, titleText, height)
    local panel = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -24, 0, height or 200),
        BackgroundColor3 = Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
            Create("UIStroke", {
                Color = Theme.Border.Subtle,
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })

    if titleText then
        local title = Create("TextLabel", {
            Parent = panel,
            Size = UDim2.new(1, -24, 0, 36),
            Position = UDim2.fromOffset(12, 8),
            BackgroundTransparency = 1,
            Text = titleText,
            Font = Fonts.Bold,
            TextSize = 15,
            TextColor3 = Theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })

        local divider = Create("Frame", {
            Parent = panel,
            Size = UDim2.new(1, -24, 0, 1),
            Position = UDim2.fromOffset(12, 44),
            BackgroundColor3 = Theme.Border.Default,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0
        })
    end

    local content = Create("Frame", {
        Parent = panel,
        Size = UDim2.new(1, -24, 1, titleText and -56 or -16),
        Position = UDim2.fromOffset(12, titleText and 52 or 8),
        BackgroundTransparency = 1,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        }
    })

    return panel, content
end

function UI:CreateInputField(parent, labelText, placeholderText, defaultText, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -24, 0, 44),
        BackgroundColor3 = Theme.Background.Tertiary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", {
                Color = Theme.Border.Default,
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })

    if labelText then
        Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(0.35, 0, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Text = labelText,
            Font = Fonts.Semibold,
            TextSize = 14,
            TextColor3 = Theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local input = Create("TextBox", {
        Parent = container,
        Size = labelText and UDim2.new(0.6, -12, 1, -8) or UDim2.new(1, -24, 1, -8),
        Position = labelText and UDim2.new(0.4, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = defaultText or "",
        PlaceholderText = placeholderText or "",
        Font = Fonts.Regular,
        TextSize = 14,
        TextColor3 = Theme.Text.Primary,
        PlaceholderColor3 = Theme.Text.Disabled,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    local stroke = container:FindFirstChildOfClass("UIStroke")

    input.Focused:Connect(function()
        if stroke then
            TweenService:Create(stroke, Animations.Quick, {
                Color = Theme.Accent.Primary,
                Transparency = 0.3
            }):Play()
        end
    end)

    input.FocusLost:Connect(function(enterPressed)
        if stroke then
            TweenService:Create(stroke, Animations.Quick, {
                Color = Theme.Border.Default,
                Transparency = 0.8
            }):Play()
        end
        if callback then callback(input.Text, enterPressed) end
    end)

    return container, input
end

function UI:MakeDraggable(guiObject, dragArea)
    local dragging, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)
end

-- ================================
-- СОЗДАНИЕ ГЛАВНОГО ОКНА
-- ================================

local function CreateMainUI()
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernExecutorUI_" .. math.random(1000, 9999),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
    })

    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        Name = "MainFrame",
        Size = UDim2.fromOffset(650, 480),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            Create("UIStroke", {
                Color = Theme.Border.Default,
                Thickness = 1.5,
                Transparency = 0.7
            })
        }
    })

    local mainStroke = MainFrame:FindFirstChildOfClass("UIStroke")
    if mainStroke then ApplyGradientStroke(mainStroke) end

    local TopBar = Create("Frame", {
        Parent = MainFrame,
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) })
        }
    })

    Create("Frame", {
        Parent = TopBar,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Fonts.Bold,
        Text = "🚀 Modern Executor",
        TextColor3 = Theme.Text.Primary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent.Primary),
        ColorSequenceKeypoint.new(0.5, Theme.Accent.Secondary),
        ColorSequenceKeypoint.new(1, Theme.Accent.Primary)
    })
    titleGrad.Parent = TitleLabel

    local TopRight = Create("Frame", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        Children = {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right
            })
        }
    })

    local MinBtn = UI:CreateButton({
        Parent = TopRight,
        Size = UDim2.fromOffset(32, 32),
        Text = "–",
        TextSize = 20,
        BackgroundColor = Theme.Background.Tertiary,
        OnClick = function()
            MainFrame.Visible = false
        end
    })

    local CloseBtn = UI:CreateButton({
        Parent = TopRight,
        Size = UDim2.fromOffset(32, 32),
        Text = "×",
        TextSize = 22,
        BackgroundColor = Theme.Accent.Error,
        StrokeColor = Theme.Accent.Error,
        HoverColor = Theme.Accent.Error:lerp(Color3.new(1, 1, 1), 0.15),
        OnClick = function()
            ScreenGui:Destroy()
        end
    })

    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) })
        }
    })

    Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0
    })
    Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0
    })

    local SidebarScroll = Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
        }
    })

    local UserPanel = Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -12, 0, 54),
        Position = UDim2.new(0.5, 0, 1, -8),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Theme.Background.Primary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        }
    })

    local thumb = Players:GetUserThumbnailAsync(
        localPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size48x48
    )

    Create("ImageLabel", {
        Parent = UserPanel,
        Size = UDim2.fromOffset(42, 42),
        Position = UDim2.new(0, 6, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = thumb,
        BackgroundTransparency = 1,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        }
    })

    Create("TextLabel", {
        Parent = UserPanel,
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 54, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Fonts.Semibold,
        Text = localPlayer.DisplayName,
        TextColor3 = Theme.Text.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local ContentFrame = Create("Frame", {
        Parent = MainFrame,
        Name = "ContentFrame",
        Size = UDim2.new(1, -200, 1, -48),
        Position = UDim2.new(0, 200, 0, 48),
        BackgroundColor3 = Theme.Background.Content,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    local PagesHolder = Create("Frame", {
        Parent = ContentFrame,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    local PageLayout = Create("UIPageLayout", {
        Parent = PagesHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        TweenTime = 0.25,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
        ScrollWheelInputEnabled = true,
        TouchInputEnabled = true
    })

    -- ================================
    -- СТРАНИЦЫ
    -- ================================

    local MainPage = Create("ScrollingFrame", {
        Parent = PagesHolder,
        Name = "MainPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
        }
    })

    local autoFarmBtn = UI:CreateButton({
        Parent = MainPage,
        Size = UDim2.new(1, -24, 0, 50),
        Text = "🚀 Запустить Auto Farm",
        BackgroundColor = Theme.Accent.Primary,
        Gradient = true,
        TextSize = 16,
        Font = Fonts.Bold
    })

    local autoFarmActive = false
    autoFarmBtn.MouseButton1Click:Connect(function()
        autoFarmActive = not autoFarmActive
        
        if autoFarmActive then
            autoFarmBtn.Text = "⛔ Остановить Auto Farm"
            AutoCtx = { stopFlag = false }
            StartAutoFarmLoop(AutoCtx)
            print("🌾 Auto Farm запущен!")
        else
            autoFarmBtn.Text = "🚀 Запустить Auto Farm"
            if AutoCtx then StopAutoFarmLoop(AutoCtx) end
            print("⛔ Auto Farm остановлен!")
        end
    end)

    local infoPanel, infoContent = UI:CreatePanel(MainPage, "📊 Информация", 140)
    
    Create("TextLabel", {
        Parent = infoContent,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "✅ Статус: Готов к работе",
        Font = Fonts.Regular,
        TextSize = 13,
        TextColor3 = Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("TextLabel", {
        Parent = infoContent,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "🏡 Участок: " .. (getMyPlotIndex() or "Не определен"),
        Font = Fonts.Regular,
        TextSize = 13,
        TextColor3 = Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("TextLabel", {
        Parent = infoContent,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "📦 Версия: 1.0 Premium",
        Font = Fonts.Regular,
        TextSize = 13,
        TextColor3 = Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SettingsPage = Create("ScrollingFrame", {
        Parent = PagesHolder,
        Name = "SettingsPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
        }
    })

    local seedsPanel, seedsContent = UI:CreatePanel(SettingsPage, "🌱 Выбор семян", 400)
    
    local seedsScroll = Create("ScrollingFrame", {
        Parent = seedsContent,
        Size = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        }
    })

    for _, seed in ipairs(SeedsCatalog) do
        SelectedSeeds[seed.ui] = SelectedSeeds[seed.ui] or false
        
        UI:CreateCheckbox(seedsScroll, seed.ui, SelectedSeeds[seed.ui], function(checked)
            SelectedSeeds[seed.ui] = checked
            print((checked and "✓" or "✗") .. " " .. seed.ui)
        end)
    end

    local countContainer = Create("Frame", {
        Parent = seedsContent,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        LayoutOrder = 100
    })

    UI:CreateInputField(countContainer, "Кол-во покупок:", "1", tostring(PurchaseCount), function(text)
        local num = tonumber(text)
        if num and num > 0 and num <= 50 then
            PurchaseCount = math.floor(num)
        else
            PurchaseCount = 1
        end
    end)

    UI:CreateButton({
        Parent = seedsContent,
        Size = UDim2.new(1, 0, 0, 44),
        Text = "🛒 Купить выбранные семена",
        BackgroundColor = Theme.Accent.Success,
        LayoutOrder = 101,
        OnClick = function()
            autoPurchaseSelected()
        end
    })

    local TeleportsPage = Create("ScrollingFrame", {
        Parent = PagesHolder,
        Name = "TeleportsPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
        }
    })

    local tpPanel, tpContent = UI:CreatePanel(TeleportsPage, "📍 Телепорты на участки", 320)

    for i, pos in pairs(PLOT_POS) do
        UI:CreateButton({
            Parent = tpContent,
            Size = UDim2.new(1, 0, 0, 40),
            Text = "🏡 Участок " .. i,
            BackgroundColor = Theme.Background.Elevated,
            OnClick = function()
                teleport(pos)
                print("✈️ Телепорт на участок " .. i)
            end
        })
    end

    -- ================================
    -- НАВИГАЦИЯ
    -- ================================

    local activeBtn = nil

    local function createNavButton(text, icon, page)
        local btn = UI:CreateButton({
            Parent = SidebarScroll,
            Size = UDim2.new(1, -20, 0, 44),
            Text = icon .. " " .. text,
            BackgroundColor = Theme.Background.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("UIPadding", {
            Parent = btn,
            PaddingLeft = UDim.new(0, 12)
        })

        btn.MouseButton1Click:Connect(function()
            PageLayout:JumpTo(page)
            
            if activeBtn and activeBtn ~= btn then
                TweenService:Create(activeBtn, Animations.Quick, {
                    BackgroundColor3 = Theme.Background.Tertiary
                }):Play()
            end
            
            activeBtn = btn
            TweenService:Create(btn, Animations.Quick, {
                BackgroundColor3 = Theme.Accent.Primary
            }):Play()
        end)

        return btn
    end

    local mainBtn = createNavButton("Главная", "🏠", MainPage)
    local settingsBtn = createNavButton("Настройки", "⚙️", SettingsPage)
    local tpBtn = createNavButton("Телепорты", "📍", TeleportsPage)

    PageLayout:JumpTo(MainPage)
    activeBtn = mainBtn
    mainBtn.BackgroundColor3 = Theme.Accent.Primary

    UI:MakeDraggable(MainFrame, TopBar)

    ScreenGui.Parent = playerGui
    
    print("✅ Modern Executor UI v3 загружен!")
    return ScreenGui
end

-- ================================
-- ЗАПУСК
-- ================================

local success, err = pcall(function()
    CreateMainUI()
end)

if not success then
    warn("❌ Ошибка загрузки UI:", err)
end
