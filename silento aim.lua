local players = game.GetService(game, "Players")
	local guiservice = game.GetService(game, "GuiService")
	local runservice = game.GetService(game, "RunService")
	local renderstepped = runservice.RenderStepped
	local localPlayer = players.LocalPlayer
	local currentCamera = game.GetService(game, "Workspace").CurrentCamera
	local mouse = localPlayer.GetMouse(localPlayer)

	-- // MT Vars + Funcs
	local mt = getrawmetatable(game)
	local backupnamecall = mt.__namecall
	local backupnewindex = mt.__newindex
	local backupindex = mt.__index
	local setreadonly = setreadonly or make_writeable
	local getnamecallmethod = getnamecallmethod or get_namecall_method
	local newcclosure = newcclosure or function(f) return f end
	setreadonly(mt, false)

	game.Players.LocalPlayer.Character.BodyEffects.Armor:Destroy()
	-- // Silent Aim Vars
	getgenv().SilentAim = {
		Enabled = true,
		FOVRep = true,
		TeamCheck = false,
		VisibleCheck = true,
		FOV = 30,
		HitChance = 100,
	}

	local circle = Drawing.new("Circle")
	function updateCircle()
		if circle.__OBJECT_EXISTS then
			circle.Transparency = 1
			circle.Visible = SilentAim["FOVRep"]
			circle.Thickness = 2
			circle.Color = Color3.fromRGB(231, 84, 128)
			circle.NumSides = 12
			circle.Radius = (SilentAim["FOV"] * 6) / 2
			circle.Filled = false
			circle.Position = Vector2.new(mouse.X, mouse.Y + (guiservice.GetGuiInset(guiservice).Y))
		end
	end
	renderstepped.Connect(renderstepped, updateCircle)


	-- // Silent Aim Funcs
	function isPartVisible(part)
		local camera = game.GetService(game, "Workspace").CurrentCamera
		local character = game.GetService(game, "Players").LocalPlayer.Character.GetDescendants(game.GetService(game, "Players").LocalPlayer.Character)
		local castPoints = {part.Position}
		return camera.GetPartsObscuringTarget(camera, castPoints, character)
	end

	setreadonly(math, false) math.chance = function(percentage) local percentage = math.floor(percentage) local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)/100 return chance <= percentage/100 end setreadonly(math, true)

	local getClosestPlayerToCursor = function()
		local closestPlayer = nil
		local chance = math.chance(SilentAim["HitChance"])
		local shortestDistance = math.huge
		for i, v in pairs(players.GetPlayers(players)) do
			if v ~= localPlayer and v.Character and v.Character.FindFirstChild(v.Character, "Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character.PrimaryPart ~= nil and v.Character.FindFirstChild(v.Character, "Head") then
				if SilentAim["VisibleCheck"] and not isPartVisible(v.Character.PrimaryPart) then
					return (chance and closestPlayer or localPlayer)
				end
				if SilentAim["TeamCheck"] then
					if v.Team ~= localPlayer.Team then      
						local pos = currentCamera.WorldToViewportPoint(currentCamera, v.Character.PrimaryPart.Position)
						local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
						if magnitude < (SilentAim["FOV"] * 6 - 8) then
							if magnitude < shortestDistance then
								closestPlayer = v
								shortestDistance = magnitude
							end
						end
					end
				else
					local pos = currentCamera.WorldToViewportPoint(currentCamera, v.Character.PrimaryPart.Position)
					local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
					if magnitude < (SilentAim["FOV"] * 6 - 8) then
						if magnitude < shortestDistance then
							closestPlayer = v
							shortestDistance = magnitude
						end
					end
				end
			end
		end  
		return (chance and closestPlayer or localPlayer)
	end
	local e
	runservice.Stepped:connect(function()
		if e then 
			game.ReplicatedStorage.MainEvent:FireServer("UpdateMousePos", e.Character.Head.Position)
		end
	end)
	while wait(1) do
		e = getClosestPlayerToCursor()
	end



	setreadonly(mt, false)
end)
Combat:addButton("Anti Aim", function()
	local UniversalAnimation = Instance.new("Animation")

	function stopTracks()
		for _, v in next, game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks() do
			if (v.Animation.AnimationId:match("rbxassetid")) then
				v:Stop()
			end
		end
	end

	function loadAnimation(id)
		if UniversalAnimation.AnimationId == id then
			stopTracks()
			UniversalAnimation.AnimationId = "1"
		else
			UniversalAnimation.AnimationId = id
			local animationTrack = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(UniversalAnimation)
			animationTrack:Play()
		end
	end

	while wait() do
		stopTracks()
		loadAnimation("rbxassetid://3152378852")
	end
