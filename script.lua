-- Полный рабочий код со слайдами справа и навигацией слева

local UserInputService = game:GetService("UserInputService") -- ввод [web:72]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

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

-- Блик на обводке [web:41]
local function AttachStrokeGradient(uiStroke: UIStroke)
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

-- Иконка в топбаре [web:85]
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
    if outerStroke then AttachStrokeGradient(outerStroke) end -- блик [web:41]

    -- Top Bar без табов
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
    if blStroke then AttachStrokeGradient(blStroke) end -- линия [web:41]

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

    -- Sidebar слева: кнопки-вкладки
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

    -- Content справа: страницы с UIPageLayout
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
        ClipsDescendants = true, -- не торчат страницы [web:72]
    })

    self.UIPageLayout = Create("UIPageLayout", {
        Parent = self.PagesHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        TweenTime = 0.2,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
        Circular = false,
        ScrollWheelInputEnabled = true,
        TouchInputEnabled = true, -- swipe/скролл [web:38]
    })

    self.Page_AutoFarm = Create("Frame", {
        Name = "Page_AutoFarm",
        Parent = self.PagesHolder,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10) }),
        }
    })

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

    -- Кнопки в левом сайдбаре переключают страницы [web:50]
    local function addNavButton(label, targetPage)
        local button = self:CreateButton({
            Parent = self.SidebarButtonContainer,
            Size = UDim2.new(1, -20, 0, 40),
            Text = label,
            BackgroundColor = Config.Colors.Tertiary,
            OnClick = function()
                self.UIPageLayout:JumpTo(targetPage) -- плавный переход [web:57]
            end
        })
        RunService.Heartbeat:Wait()
        self.SidebarButtonContainer.CanvasSize = UDim2.new(0,0,0,self.SidebarButtonContainer.UIListLayout.AbsoluteContentSize.Y)
        return button
    end

    self.Btn_AutoFarm = addNavButton("💰 Auto Farm", self.Page_AutoFarm)
    self.Btn_Settings  = addNavButton("⚙️ Settings", self.Page_Settings)

    -- Содержимое страниц (пример)
    self:CreateButton({
        Parent = self.Page_AutoFarm,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "🚀 Запустить Auto Farm",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() warn("Auto Farm активирован") end
    })
    self:CreateButton({
        Parent = self.Page_AutoFarm,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "💰 Собрать все монеты",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() warn("Собираем монеты") end
    })
    self:CreateButton({
        Parent = self.Page_AutoFarm,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "⚡ Включить Speed Hack",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() warn("Скорость увеличена") end
    })

    self:CreateButton({
        Parent = self.Page_Settings,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "🎚️ Интенсивность фарма: Норм",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() warn("Изменение интенсивности") end
    })
    self:CreateButton({
        Parent = self.Page_Settings,
        Size = UDim2.new(1, -20, 0, 38),
        Text = "🎛️ Авто‑сохранение: Вкл",
        BackgroundColor = Config.Colors.Secondary,
        OnClick = function() warn("Переключение автосохранения") end
    })

    -- Подсветка активной кнопки в сайдбаре
    local activeBtn: TextButton? = nil
    local function setActive(btn: TextButton)
        if activeBtn and activeBtn ~= btn then
            activeBtn.BackgroundColor3 = Config.Colors.Tertiary
            activeBtn.TextColor3 = Config.Colors.TextSecondary
        end
        activeBtn = btn
        activeBtn.BackgroundColor3 = Config.AccentColor
        activeBtn.TextColor3 = Config.Colors.Text
    end

    -- Привязать клик к подсветке
    self.Btn_AutoFarm.MouseButton1Click:Connect(function() setActive(self.Btn_AutoFarm) end)
    self.Btn_Settings.MouseButton1Click:Connect(function() setActive(self.Btn_Settings) end)

    -- Инициализация страницы и подсветки
    self.UIPageLayout:JumpTo(self.Page_AutoFarm) -- старт с Auto Farm [web:72]
    setActive(self.Btn_AutoFarm)

    self:SetupUserPanel()
    self:MakeDraggable(self.MainFrame, self.TopBar)

    self.ScreenGui.Parent = playerGui
    return self
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

function Fluent:MakeDraggable(guiObject: GuiObject, dragArea: GuiObject)
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

-- Инициализация
local MyUI = Fluent.new()
