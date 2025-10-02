local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
        Secondary = Color3.fromRGB(43, 45, 49),
        Tertiary = Color3.fromRGB(54, 57, 63),
        Text = Color3.fromRGB(242, 243, 245),
        TextSecondary = Color3.fromRGB(185, 187, 190),
        Border = Color3.fromRGB(66, 69, 75),
        Hover = Color3.fromRGB(70, 73, 80),
    },
    Fonts = {
        Title = Enum.Font.GothamBold,
        Body = Enum.Font.GothamSemibold,
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

function Fluent.new()
    local self = setmetatable({}, Fluent)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

    self.ScreenGui = Create("ScreenGui", {
        Name = "FluentUI_" .. math.random(1000, 9999),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
    })

    local mainFrameSize, mainFramePosition, mainFrameAnchorPoint
    if isMobile then
        mainFrameSize = UDim2.new(0.9, 0, 0, 300)
        mainFramePosition = UDim2.new(0.5, 0, 0.05, 0)
        mainFrameAnchorPoint = Vector2.new(0.5, 0)
    else
        mainFrameSize = UDim2.fromOffset(Config.WindowSize.X, Config.WindowSize.Y)
        mainFramePosition = UDim2.fromScale(0.5, 0.5)
        mainFrameAnchorPoint = Vector2.new(0.5, 0.5)
    end

    self.MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = self.ScreenGui, Size = mainFrameSize,
        Position = mainFramePosition, AnchorPoint = mainFrameAnchorPoint,
        BackgroundColor3 = Config.Colors.Background, BorderSizePixel = 0, ClipsDescendants = true, Visible = true,
        Children = {
            Create("UIAspectRatioConstraint", {
                AspectRatio = Config.WindowSize.X / Config.WindowSize.Y,
                DominantAxis = Enum.DominantAxis.Width,
            }),
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding) }),
            Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1.5 }),
        },
    })
    
    self.DragFrame = Create("Frame", { Name = "DragFrame", Parent = self.MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 })
    self.Sidebar = Create("Frame", { Name = "SidebarContainer", Parent = self.MainFrame, Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true })

    Create("Frame", { Parent = self.Sidebar, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Config.Colors.Secondary, BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding) }),
            Create("Frame", { Name = "RightCornerCover", BackgroundColor3 = Config.Colors.Secondary, BorderSizePixel = 0, Size = UDim2.new(0, Config.Rounding, 1, 0), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
        }
    })
    
    self.SidebarButtonContainer = Create("ScrollingFrame", {
        Name = "ButtonContainer", Parent = self.Sidebar, Size = UDim2.new(1, 0, 1, -60), BackgroundTransparency = 1,
        BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3, ScrollBarImageColor3 = Config.AccentColor,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, FillDirection = Enum.FillDirection.Vertical }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 12) })
        }
    })

    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame", Parent = self.MainFrame, Size = UDim2.new(1, -180, 1, -40), Position = UDim2.new(0, 180, 0, 40), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 6, ScrollBarImageColor3 = Config.AccentColor,
        Children = {
            Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
        }
    })

    self.TitleLabel = Create("TextLabel", {
        Name = "TitleLabel", Parent = self.MainFrame, Size = UDim2.new(1, -250, 0, 40), Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Font = Config.Fonts.Title, Text = Config.Title,
        TextColor3 = Config.Colors.Text, TextSize = 20,
    })

    self:SetupWindowControls()
    self:SetupUserPanel()
    self:MakeDraggable(self.MainFrame, self.DragFrame)
    self.ScreenGui.Parent = playerGui
    return self
end

function Fluent:SetupWindowControls()
    local controlsFrame = Create("Frame", {
        Name = "ControlsFrame", Parent = self.MainFrame, Size = UDim2.fromOffset(60, 24), Position = UDim2.new(1, -15, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1,
        Children = { Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center }) }
    })
    self:CreateButton({ Parent = controlsFrame, Size = UDim2.fromOffset(24, 24), Text = "–", BackgroundColor = Config.Colors.Secondary,
        OnClick = function() self.MainFrame.Visible = false; self.RestoreButton.Visible = true end
    })
    self:CreateButton({ Parent = controlsFrame, Size = UDim2.fromOffset(24, 24), Text = "×", BackgroundColor = Config.ErrorColor, HoverColor = Config.ErrorColor:Lerp(Color3.new(1,1,1), 0.2),
        OnClick = function() if self.ScreenGui then self.ScreenGui:Destroy() end end
    })
    self.RestoreButton = self:CreateButton({ Parent = self.ScreenGui, Name = "RestoreButton", Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(20, 20),
        Text = "🚀", TextSize = 24, Visible = false, BackgroundColor = Config.AccentColor,
        OnClick = function() self.RestoreButton.Visible = false; self.MainFrame.Visible = true end
    })
    self:MakeDraggable(self.RestoreButton, self.RestoreButton)
end

function Fluent:SetupUserPanel()
    local userFrame = Create("Frame", { Name = "UserPanel", Parent = self.Sidebar, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1, 0), AnchorPoint = Vector2.new(0.5, 1) })
    local avatar = Create("ImageLabel", { Parent = userFrame, Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Image = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48), BackgroundTransparency = 1, Children = { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) } })
    local nameLabel = Create("TextLabel", { Parent = userFrame, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 70, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Config.Fonts.Body, Text = localPlayer.DisplayName, TextColor3 = Config.Colors.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center })
end

function Fluent:MakeDraggable(guiObject, dragArea)
    local dragging, dragInput, dragStart, startPos
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
    UserInputService.InputChanged:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then update(input) end end)
end

function Fluent:AddSidebarButton(text, onClick)
    local button = self:CreateButton({ Parent = self.SidebarButtonContainer, Size = UDim2.new(1, -20, 0, 40), Text = text, BackgroundColor = Config.Colors.Tertiary, OnClick = onClick })
    RunService.Heartbeat:Wait()
    self.SidebarButtonContainer.CanvasSize = UDim2.new(0,0,0,self.SidebarButtonContainer.UIListLayout.AbsoluteContentSize.Y)
    return button
end

function Fluent:AddContentButton(text, onClick)
    local button = self:CreateButton({ Parent = self.ContentFrame, Size = UDim2.new(1, -20, 0, 38), Text = text, BackgroundColor = Config.Colors.Secondary, OnClick = onClick })
    RunService.Heartbeat:Wait()
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.ContentFrame.UIListLayout.AbsoluteContentSize.Y)
    return button
end

function Fluent:CreateButton(props)
    local btn = Create("TextButton", {
        Parent = props.Parent, Name = props.Name or "Button", Size = props.Size, Position = props.Position,
        BackgroundColor3 = props.BackgroundColor or Config.Colors.Tertiary, Text = props.Text or "", Font = props.Font or Config.Fonts.Body,
        TextColor3 = props.TextColor or Config.Colors.Text, TextSize = props.TextSize or 16, Visible = (props.Visible == nil) and true or props.Visible,
        AutoButtonColor = false, LayoutOrder = props.LayoutOrder, AnchorPoint = Vector2.new(0.5, 0.5),
        Children = { Create("UICorner", { CornerRadius = UDim.new(0, Config.Rounding - 2) }), Create("UIStroke", { Color = Config.Colors.Border, Thickness = 1 }) }
    })
    if props.Parent and not props.Parent:IsA("GuiObjectWithLayout") then btn.Position = props.Position or UDim2.new(0.5, 0, 0.5, 0) end
    local originalColor, hoverColor = btn.BackgroundColor3, props.HoverColor or Config.Colors.Hover
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hoverColor end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = originalColor end)
    btn.MouseButton1Click:Connect(function() if props.OnClick then pcall(props.OnClick) end end)
    return btn
end

--// ===== ИСПОЛЬЗОВАНИЕ БИБЛИОТЕКИ =====
local MyUI = Fluent.new()
MyUI:AddSidebarButton("💰 AutoFarm", function() print("Открыта главная вкладка") end)
MyUI:AddSidebarButton("⚙️ Settings", function() print("Открыты настройки") end)
MyUI:AddSidebarButton("ℹ️ Info", function() print("Открыта информация") end)
MyUI:AddContentButton("🚀 Запустить Auto Farm", function() warn("Функция Auto Farm активирована!") end)
MyUI:AddContentButton("💰 Собрать все монеты", function() warn("Собираем монеты...") end)
MyUI:AddContentButton("⚡ Включить Speed Hack", function() warn("Скорость увеличена!") end)
MyUI:AddContentButton("👁️ Включить ESP", function() warn("ESP включен.") end)
