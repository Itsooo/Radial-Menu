local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local PI = math.pi
local TAU = 2*PI

local MOUSE_CLICK = Enum.UserInputType.MouseButton1

local GRAY = Color3.new(0.5, 0.5, 0.5)
local WHITE = Color3.new(1, 1, 1)

local OFFSET = 1/4 -- since angle 0 is pointing to the right, we can begin our origin 90 degrees counter clockwise so its perfectly up
-- we normalized offset so we have to use decimals (0, 1)
-- 1/4 is one quarter counter clockwise

local baseFrame = script.Parent
local radialLimit = baseFrame.AbsoluteSize.X/2 -- we assume the baseframe is the limit

local mouse = Players.LocalPlayer:GetMouse() -- to account for gui Inset offset (you couldve hard coded it but I like the abstraction)

local list = { -- going counter clockwise
	baseFrame.RadialLeft,
	baseFrame.RadialBottom,
	baseFrame.RadialRight
}

local selected
local checkConn
local clickConn

local function selectRadial(clicked)
	if not clicked then return end
	
	print(clicked)
end

local function onHover(hovered)
	if not hovered then return end
	
	hovered.ImageColor3 = GRAY
end

local function onHoverLeave(hovered)
	if not hovered then return end

	hovered.ImageColor3 = WHITE
end

local function activate() -- I would assume you would activate and unavtivate with like a keybind or someth[ing]
	
	checkConn = RunService.RenderStepped:Connect(function() 
		local center = baseFrame.AbsolutePosition + baseFrame.AbsoluteSize/2
		
		local direction = Vector2.new(mouse.X, mouse.Y) - center
		
		print(selected)
		if direction.Magnitude <= radialLimit then -- checking if out of bounds
			local angle = math.atan2(-direction.Y, direction.X)/TAU -- we flip Y cause of how Gui is positioned
			-- we divide by TAU to normalize the units so its [0, 1]
			angle = (angle - OFFSET)%1
			
			local index = math.floor(angle*#list) + 1 
			-- this works because the amount we have in the list is 
			
			local pickedFrame = list[index]
			
			if selected ~= pickedFrame then -- its a new pick so we can hover
				onHoverLeave(selected) -- make sure to unhover the one we had before
				onHover(pickedFrame)
				
				selected = pickedFrame
			end
			
		elseif selected then
			onHoverLeave(selected)
			selected = nil
		end
	end)
	
	clickConn = UserInputService.InputBegan:Connect(function(inputType, isTyping)
		if isTyping or inputType.UserInputType ~= MOUSE_CLICK then return end
		
		selectRadial(selected)
	end)
	
end; activate()

local function unactivate()
	if checkConn then
		checkConn:Disconnect()
		clickConn:Disconnect()
		selected = nil
	end
end