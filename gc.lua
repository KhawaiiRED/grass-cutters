-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- PREVENT DUPLICATE GUI
if CoreGui:FindFirstChild("AutoLoopGUI") then return end

-- ARGS
local args = {
	buffer.fromstring("\021\205\204\f?")
}

-- STATE
local running = false
local speedMin, speedMax = 16, 100
local currentSpeed = 16
local draggingSlider = false
local infiniteJump = false

-- COLORS (Modern Sakura)
local SAKURA = Color3.fromRGB(255, 183, 197)
local BG = Color3.fromRGB(28, 28, 32)
local PANEL = Color3.fromRGB(36, 36, 42)
local BTN = Color3.fromRGB(45, 45, 52)
local BTN_ON = Color3.fromRGB(255, 183, 197)
local TEXT = Color3.fromRGB(235, 235, 240)
local SUBTEXT = Color3.fromRGB(190, 190, 200)

-- SCREEN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoLoopGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = CoreGui

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(260, 265)
frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(130, 132)
frame.BackgroundColor3 = BG
frame.Active = true
frame.ClipsDescendants = false
frame.ZIndex = 10

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = SAKURA
frameStroke.Thickness = 1

-- TITLE BAR
local titleBar = Instance.new("TextLabel", frame)
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.Text = "🌸  SAKURA • Grass Cutters"
titleBar.TextColor3 = SAKURA
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 14
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.ZIndex = 11
titleBar.Active = true

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titlePadding = Instance.new("UIPadding", titleBar)
titlePadding.PaddingLeft = UDim.new(0, 12)

-- DRAGGING
local draggingUI = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingUI = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingUI = false
	end
end)

-- BUTTON STYLE FUNCTION
local function styleButton(btn)
	btn.BackgroundColor3 = BTN
	btn.TextColor3 = TEXT
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(80, 80, 90)
	stroke.Thickness = 1
end

-- AUTO LOOP BUTTON
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(220, 32)
toggleBtn.Position = UDim2.fromOffset(20, 46)
toggleBtn.Text = "AUTO CUT : OFF"
toggleBtn.ZIndex = 11
styleButton(toggleBtn)

-- DELETE BUTTON
local deleteBtn = Instance.new("TextButton", frame)
deleteBtn.Size = UDim2.fromOffset(220, 28)
deleteBtn.Position = UDim2.fromOffset(20, 86)
deleteBtn.Text = "DELETE GrassMap"
deleteBtn.ZIndex = 11
styleButton(deleteBtn)

-- INFINITE JUMP BUTTON
local jumpBtn = Instance.new("TextButton", frame)
jumpBtn.Size = UDim2.fromOffset(220, 28)
jumpBtn.Position = UDim2.fromOffset(20, 120)
jumpBtn.Text = "INF JUMP : OFF"
jumpBtn.ZIndex = 11
styleButton(jumpBtn)

-- SPEED LABEL
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.fromOffset(220, 20)
speedLabel.Position = UDim2.fromOffset(20, 154)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed : 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextColor3 = SUBTEXT
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.ZIndex = 11

-- SLIDER BAR
local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.fromOffset(220, 6)
sliderBar.Position = UDim2.fromOffset(20, 178)
sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
sliderBar.BorderSizePixel = 0
sliderBar.ZIndex = 11
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

-- SLIDER KNOB
local sliderKnob = Instance.new("Frame", sliderBar)
sliderKnob.Size = UDim2.fromOffset(14, 14)
sliderKnob.Position = UDim2.fromScale(0, -0.7)
sliderKnob.BackgroundColor3 = SAKURA
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 12
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

-- AUTO LOOP LOGIC
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "AUTO CUT : ON" or "AUTO CUT : OFF"
	toggleBtn.BackgroundColor3 = running and BTN_ON or BTN

	if running then
		task.spawn(function()
			while running do
				remote:FireServer(unpack(args))
				task.wait(0.2)
			end
		end)
	end
end)

-- DELETE GrassMap
deleteBtn.MouseButton1Click:Connect(function()
	local folder = Workspace:FindFirstChild("GrassMap")
	if folder then folder:Destroy() end
end)

-- INFINITE JUMP
jumpBtn.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	jumpBtn.Text = infiniteJump and "INF JUMP : ON" or "INF JUMP : OFF"
	jumpBtn.BackgroundColor3 = infiniteJump and BTN_ON or BTN
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local hum = player.Character and player.Character:FindFirstChild("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- SPEED SLIDER
local function setSpeedFromX(x)
	local r = math.clamp((x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
	sliderKnob.Position = UDim2.fromScale(r, -0.7)
	currentSpeed = math.floor(speedMin + (speedMax - speedMin) * r)
	speedLabel.Text = "Speed : " .. currentSpeed

	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then hum.WalkSpeed = currentSpeed end
end

sliderKnob.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
		draggingUI = false
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
		setSpeedFromX(i.Position.X)
	end
end)

-- APPLY SPEED ON RESPAWN
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").WalkSpeed = currentSpeed
end)
