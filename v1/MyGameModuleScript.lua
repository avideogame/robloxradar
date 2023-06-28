-- game.ServerScriptService.MyGameModuleScript
local aModule = {}

aModule.MyConfig = {}
-- Data Definition
aModule.MyConfig["MyLanguage"] = {
	MyType = {
		MyEnglish = {
			aKey = "aEnglish",
		},
		MyChinese = {
			aKey = "aChinese",
		},
	},
}
aModule.MyConfig["MyGame"] = {
	aScreenOrientation = Enum.ScreenOrientation.LandscapeSensor,
	aLanguageDefault = aModule.MyConfig.MyLanguage.MyType.MyEnglish.aKey,

	MyExperience = {
		aId = 1234567890,
	},
	MyPlace  = {
		aId = 12345678901,
		MyLabel = {
			aEnglish = "Roblox Radar",
			aChinese = "Roblox Radar",
		},
		MyTemplate = {
			aType = "Baseplate",
		},
	},

	MyBadge = {
		aName = "MyBadge",
		MyKeyMaster = {
			aId = "1234567890",
		},
	},
}

aModule.MyConfig["MyRemoteEvent"] = {
	MyServerClientTrigger = {
		MySetPlayerRadar = {
			aName = "MyRemoteEventServerClientSetPlayerRadar",
		},
	},
	MyClientServerTrigger = {
	},
}

aModule.MyConfig["MyPlayer"] = {
	MyAttribute = {
		MyLanguage = {
			aName = "MyLanguage",
			aKey = "aLanguage",
			MyValue = {
				aDefault = ""..aModule.MyConfig.MyGame.aLanguageDefault
			},
		},
	},

	MyRadar = {
		aName = "MyRadar",
		MySize = {
			aX = 100,
			aY = 100,
		},
		MyOverlay = {
			aName = "MyOverlay",
			aAssetId = "12345678", -- transparent
			MySize = {
				aX = 100,
				aY = 100,
			},
		},
		MyCenter = {
			aName = "MyCenter",
			aAssetId = "12345678", -- transparent
			MySize = {
				aX = 10,
				aY = 10,
			},
		},
		MyFrame = {
			aName = "MyFrame",
			MySize = {
				aX = 100,
				aY = 100,
			},
		},
		MyMask = {
			aName = "MyMask",
			aAssetId = "12345678", -- transparent
			MySize = {
				aX = 10,
				aY = 10,
			},
		},
	},

}
aModule.MyConfig["MyDataStore"] = {
	MyField = {
		MyPlayerLanguage = {
			aName = "MyPlayerLanguage",
		},
	},
}

-- Objects

aModule.MyGame = {}
-- Cache space
aModule.MyGame.MyState = {
	aTimestamp = nil,
}
aModule.MyGame.SetInit = function(aParam)
	local aConfig = aModule.MyConfig

	aModule.MyGame.SetSettingsInit(aParam)
	aModule.MyGame.SetPlayersInit(aParam)

	return
end

aModule.MyGame.SetFrameUpdate = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer

	if aModule.MyGame.MyState.aTimestamp == nil then
		aModule.MyGame.MyState.aTimestamp = os.time()
	end

	if aModule.MyGame.MyState.aTimestamp < os.time() then
		aModule.MyGame.MyState.aTimestamp = os.time()

		aService = game:GetService("Players")
		local playerList = aService:GetPlayers()
		for i = 1, #playerList  do
			local player = playerList[i]
			if player:GetAttribute("IsAlive") then
				local points = player.leaderstats.Points
				points.Value = points.Value + 1
			end
		end

		for i = 1, table.maxn(playerList), 1  do
			aPlayer = playerList[i]
			local aName2
			local aInstance2
			local aInstance3

			aInstance = aPlayer.Character
			if aInstance == nil then
				continue
			end
			aInstance = aInstance:FindFirstChild("HumanoidRootPart")
			if aInstance == nil then
				continue
			end
			aInstance2 = game:GetService("Workspace"):FindFirstChild("SpawnLocation")
			if aInstance2 == nil then
				continue
			end
			aName2 = aConfig.MyRemoteEvent.MyServerClientTrigger.MySetPlayerRadar.aName
			aInstance3 = game:GetService("ReplicatedStorage"):FindFirstChild(""..aName2)
			aInstance3:FireClient(aPlayer, {
				["aPart"]={
					["aPlayer"]=aInstance,
					["aOther"]=aInstance2,
				},
			})
		end
	end

	return
end

aModule.MyGame.SetOnPlayerAdded = function(aPlayer)
	local aConfig = aModule.MyConfig

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = aPlayer

	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Value = 0
	points.Parent = leaderstats

	aPlayer:SetAttribute("IsAlive", false)

	aPlayer.CharacterAdded:Connect(function(aCharacter)
		aModule.MyGame.SetOnCharacterAdded({character=aCharacter,player=aPlayer,})
	end)

	return
end

aModule.MyGame.SetOnCharacterAdded = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam.player
	local aCharacter = aParam.character
	aPlayer:SetAttribute("IsAlive", true)
	local humanoid = aCharacter:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		local points = aPlayer.leaderstats.Points
		points.Value = 0
		aPlayer:SetAttribute("IsAlive", false)
	end)

	return
end

aModule.MyGame.SetPlayersInit = function(aParam)
	local aService
	aService = game:GetService("Players")
	aService.PlayerAdded:Connect(aModule.MyGame.SetOnPlayerAdded)
	aService.PlayerAdded:Connect(aModule.MyGame.SetPlayerAddedInit)

end

aModule.MyGame.SetSettingsInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aScript
	local aInstance

	aService = game:GetService("StarterGui")
	aService.ScreenOrientation = aConfig.MyGame.aScreenOrientation

	aService = game:GetService("Lighting")
	aService.Brightness = 1

	-- Stage to script on ReplicatedStorage to share between player space and game space
	aScript = game:GetService("ServerScriptService"):WaitForChild("MyGameModuleScript"):Clone()
	aScript.Parent = game:GetService("ReplicatedStorage")

	aModule.MyGame.SetRemoteEventInit(aParam)

	return
end

aModule.MyGame.SetPlayerAddedInit = function(aPlayer)
	local aService
	local aConfig = aModule.MyConfig
	local aName
	local aInstance

	aModule.MyGame.SetPlayerLanguageInit({["aPlayer"] = aPlayer,})

	--	aModule.MyGame.SetPlayerBadgeInit({["aPlayer"] = aPlayer,})

	aPlayer.CharacterAdded:Connect(function(aCharacter)
		task.wait()
		aName = "Points"
		local aPoints
		aPoints = aPlayer.leaderstats:FindFirstChild(aName)
		if aPoints == nil then
			aPoints = Instance.new("IntValue")
			aPoints.Name = ""..aName
			aPoints.Parent = aPlayer.leaderstats
		end
		aPoints.Value = 0

	end)
end

aModule.MyGame.SetRemoteEventInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aInstance

	aInstance = Instance.new("RemoteEvent")
	aInstance.Name = aConfig.MyRemoteEvent.MyServerClientTrigger.MySetPlayerRadar.aName
	aInstance.Parent = game:GetService("ReplicatedStorage")
end

aModule.MyGame.SetPlayerLanguage = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer
	local aKey

	aPlayer = aParam["aPlayer"]
	aKey = aParam["aKey"]

	aName = aModule.MyConfig.MyDataStore.MyField.MyPlayerLanguage.aName
	aService = game:GetService("DataStoreService")
	aInstance = aService:GetDataStore(""..aName)

	if aInstance:GetAsync(aPlayer.UserId) == nil then
		aInstance:SetAsync(aPlayer.UserId, ""..aModule.MyConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault)
	end

	for k,v in pairs(aConfig.MyLanguage.MyType) do
		if aKey == nil then
			break
		end
		if v.aKey ~= aKey then
			continue
		end

		-- Set data store key

		local setSuccess, errorMessage = pcall(function()

			aInstance:SetAsync(aPlayer.UserId, ""..aKey)

		end)

		if not setSuccess then

			warn(errorMessage)

		end
		break
	end

	-- Read data store key

	local getSuccess, currentLanguage = pcall(function()

		return aInstance:GetAsync(aPlayer.UserId)

	end)

	if getSuccess then

		--		print(currentLanguage)

		aName = aConfig.MyPlayer.MyAttribute.MyLanguage.aKey
		aPlayer:SetAttribute(""..aName, currentLanguage)
	end
end

aModule.MyGame.SetPlayerLanguageInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aList
	local aInstance
	local aName
	local aPlayer = aParam["aPlayer"]
	local aLanguage

	aService = game:GetService("Players")

	aList = aService:GetPlayers()
	for i = 1, #aList  do
		aInstance = aList[i]
		if aPlayer.UserId ~= aInstance.UserId then
			continue
		end

		aLanguage = ""..aConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault 
		aService = game:GetService("DataStoreService")
		aName = aConfig.MyDataStore.MyField.MyPlayerLanguage.aName
		aInstance = aService:GetDataStore(""..aName)
		--		aInstance:RemoveAsync(aPlayer.UserId)
		local getSuccess, currentLanguage = pcall(function()
			return aInstance:GetAsync(aPlayer.UserId)
		end)

		if getSuccess then
			if  currentLanguage == nil then
			else
				aLanguage = ""..currentLanguage
			end
		else
		end

		aName = ""..aConfig.MyPlayer.MyAttribute.MyLanguage.aKey
		aPlayer:SetAttribute(""..aName, ""..aLanguage)
		aInstance:SetAsync(aPlayer.UserId, aPlayer:GetAttribute(""..aName))

		break
	end
end

aModule.MyGame.SetPlayerBadgeInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam["aPlayer"]
	local aService
	local aInstance
	local aName
	local aParent

	--
	local BadgeService = game:GetService("BadgeService")

	local function awardBadge(player, badgeId)
		-- Fetch Badge information
		local success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)
		if success then
			-- Confirm that badge can be awarded
			if badgeInfo.IsEnabled then
				-- Award badge
				local awarded, errorMessage = pcall(BadgeService.AwardBadge, BadgeService, player.UserId, badgeId)
				if not awarded then
					warn("Error while awarding Badge:", errorMessage)
				end
			end
		else
			warn("Error while fetching Badge info!")
		end
	end
	--
	if "0" ~= "" then
		local BadgeService = game:GetService("BadgeService")
		local Players = game:GetService("Players")

		local BADGE_ID = 00000000  -- Change this to your Badge ID

		--
		BADGE_ID = aConfig.MyGame.MyBadge.MyKeyMaster.aId

		local function onPlayerAdded(player)
			--
			local badgeID = BADGE_ID

			-- Check if the player has the Badge
			local success, hasBadge = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, badgeID)

			-- If there's an error, issue a warning and exit the function
			if not success then
				warn("Error while checking if player has Badge!")
				return
			end

			if hasBadge then
				-- Handle player's Badge ownership as needed
				--
				local BadgeService = game:GetService("BadgeService")

				local BADGE_ID = 00000000  -- Change this to your Badge ID
				--
				BADGE_ID = aConfig.MyGame.MyBadge.MyKeyMaster.aId

				-- Fetch Badge information
				local success, result = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, BADGE_ID)
				--								print(success, result)

				-- Output the information
				if success then
					if "0" == "" then
						print("Badge:", result.Name)
						print("Enabled:", result.IsEnabled)
						print("Description:", result.Description)
						print("Icon:", "rbxassetid://" .. result.IconImageId)
					end
				else
					warn("Error while fetching Badge info:", result)
				end
				--
			end

			if hasBadge ~= true then
				awardBadge(player, BADGE_ID)
				--				BadgeService:AwardBadge(player.UserId, badgeID)
			end
		end

		-- Connect "PlayerAdded" events to the "onPlayerAdded()" function
		--		Players.PlayerAdded:Connect(onPlayerAdded)
		onPlayerAdded(aPlayer)
	end
	--
end

aModule.MyGame.GetAngleBetweenTwoPointsByUpAxis = function(aParam)
	local aConfig = aModule.MyConfig
	local aAngle
	local aVectorA
	local aVectorB
	local aDotProduct
	local aDeterminant
	aVectorA = aParam["aPartA"].CFrame.LookVector
	aVectorB = CFrame.lookAt(aParam["aPartA"].Position, aParam["aPartB"].Position, Vector3.yAxis).LookVector

	aDotProduct = (aVectorA.X*aVectorB.X) + (aVectorA.Z*aVectorB.Z)
	aDeterminant = (aVectorA.X*aVectorB.Z) - (aVectorA.Z*aVectorB.X)
	aAngle = math.atan2(aDeterminant,aDotProduct)

	return aAngle
end

aModule.MyGame.GetPositionRotatedAroundPointByUpAxis = function(aParam)
	local aConfig = aModule.MyConfig
	local aAngle
	local aCenter
	local aFrom
	local aTo
	local aCos
	local aSin
	local aX
	local aZ
	aCenter = aParam["aCenter"]
	aFrom = aParam["aFrom"]

	aAngle = aParam["aAngle"]
	aCos = math.cos(aAngle)
	aSin = math.sin(aAngle)
	aX = (aCos * (aFrom.X-aCenter.X)) + (aSin * (aFrom.Z-aCenter.Z)) + aCenter.X
	aZ = (aCos * (aFrom.Z-aCenter.Z)) - (aSin * (aFrom.X-aCenter.X)) + aCenter.Z
	aTo = Vector3.new(aX,0,aZ)

	return aTo
end


-- Player space perspective
aModule.MyPlayer = {}

aModule.MyPlayer.SetLocalInit = function(aParam)
	aModule.MyPlayer.MyRemoteEvent.SetInit(aParam)

	aModule.MyPlayer.SetPlayerAddedInit(aParam)
end

aModule.MyPlayer.SetLocalUpdate = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aLanguage
	local aPlayer

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aLanguage = aModule.MyPlayer.MyLanguage.GetType({["aPlayer"]=aPlayer,})

end

aModule.MyPlayer.MyLanguage = {}
aModule.MyPlayer.MyLanguage.GetType = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam["aPlayer"]
	local aService
	local aKey
	local aList
	local aType

	aService = game:GetService("Players")
	aKey = aConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault
	aList = aService:GetPlayers()
	for i,aValue in ipairs(aList) do
		if aValue.UserId ~= aPlayer.UserId then
			continue
		end
		for k,v in pairs(aConfig.MyLanguage) do
			for aFieldKey, aFieldValue in pairs(v) do
				if aFieldValue.aKey == aValue:GetAttribute(aConfig.MyPlayer.MyAttribute.MyLanguage.aKey) then
					aKey = aFieldKey
					return aKey
				end
			end

		end
	end

	return aKey
end

aModule.MyPlayer.MyRemoteEvent = {}
aModule.MyPlayer.MyRemoteEvent.SetInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer
	local aLanguage

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aLanguage = aModule.MyPlayer.MyLanguage.GetType({["aPlayer"]=aPlayer,})


	aName = aConfig.MyRemoteEvent.MyServerClientTrigger.MySetPlayerRadar.aName
	aService = game:GetService("ReplicatedStorage")
	aInstance = aService:WaitForChild(aName)
	aInstance.OnClientEvent:Connect(function(aParam2)

		local aInstance2
		local aName2
		local aService2
		local aKey2
		local aDistance2
		local aPointA
		local aPointB
		local aProperty2
		local aBound
		local aParent2
		local aOffset2
		local aAngle2
		local aPartA
		local aPartB
		local aCoordinate
		local aBaseplate

		aInstance2 = aPlayer:FindFirstChild("PlayerGui")
		if aInstance2 == nil then
			return
		end
		aParent2 = aInstance2

		aName2 = aConfig.MyPlayer.MyRadar.aName
		aInstance2 = aParent2:FindFirstChild(""..aName2)
		if aInstance2 == nil then
			return
		end
		aParent2 = aInstance2

		aName2 = aConfig.MyPlayer.MyRadar.MyFrame.aName
		aInstance2 = aParent2:FindFirstChild(""..aName2)
		if aInstance2 == nil then
			return
		end
		aParent2 = aInstance2

		aName2 = aConfig.MyPlayer.MyRadar.MyMask.aName
		aInstance2 = aParent2:FindFirstChild(""..aName2)
		if aInstance2 ~= nil then
			aInstance2:Destroy()
			aInstance2 = nil
			return
		end

		aInstance2 = aPlayer.Character
		if aInstance2 == nil then
			return
		end
		aInstance2 = aInstance2:FindFirstChild("HumanoidRootPart")
		if aInstance2 == nil then
			return
		end

		aProperty2 = aParam2["aPart"]
		aPartA = aProperty2["aPlayer"]
		aPartB = aProperty2["aOther"]
		if aPartA == nil then
			return
		end
		if aPartB == nil then
			return
		end
		aPointA = aPartA.Position
		aPointB = aPartB.Position
		if aPointA == nil then
			return
		end
		if aPointB == nil then
			return
		end
		aDistance2 = (Vector3.new(aPointB.X,0,aPointB.Z) - Vector3.new(aPointA.X,0,aPointA.Z)).Magnitude

		aBaseplate = game:GetService("Workspace"):FindFirstChild("Baseplate")
		if aBaseplate == nil then
			return
		end
		aBound = aBaseplate.Size.X * 0.5
		if aDistance2 >= aBound then
			return
		end

		aOffset2 = (1-(math.abs(aBound - aDistance2)/aBound))*-0.5
		aAngle2 = aModule.MyGame.GetAngleBetweenTwoPointsByUpAxis({
			["aPartA"]=aProperty2["aPlayer"],
			["aPartB"]=aProperty2["aOther"],
		})
		aCoordinate = aModule.MyGame.GetPositionRotatedAroundPointByUpAxis({
			["aAngle"]=aAngle2,
			["aCenter"]=Vector3.zero,
			["aFrom"]=Vector3.zAxis*aOffset2,
		})

		aInstance2 = Instance.new("ImageLabel")
		aInstance2.Name = aName2
		aInstance2.Parent = aParent2
		aInstance2.Image = "rbxassetid://"..aConfig.MyPlayer.MyRadar.MyMask.aAssetId
		aInstance2.BackgroundColor3 = Color3.new(1, 0.0, 0)
		aInstance2.BackgroundTransparency = 0.5
		aInstance2.Position = UDim2.new(0.5+(aCoordinate.X*-1.0),0,0.5+(aCoordinate.Z),0)
		aProperty2 = aConfig.MyPlayer.MyRadar.MyMask.MySize
		aInstance2.Size = UDim2.new(
			0,aProperty2.aX,
			0,aProperty2.aY
		)
		aInstance2.AnchorPoint = Vector2.new(0.5,0.5)

	end)
end

aModule.MyPlayer.SetPlayerAddedInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aPlayer
	local aName
	local aInstance
	local aCharacter
	local aParent
	aPlayer = aParam["player"]
	--	aCharacter = aPlayer.Character or aPlayer.CharacterAdded:Wait()

	aPlayer.CharacterAdded:Connect(function(aCharacter2)

		coroutine.wrap(function(aParam)
			--			task.wait()
			local aHumanoid = aParam["aCharacter"]:WaitForChild("Humanoid")

			aHumanoid.Touched:Connect(function(aOtherPart)
				local aHitPlayer
				aHitPlayer = game.Players:GetPlayerFromCharacter(aOtherPart.Parent)
				if string.match(aOtherPart.Name,"^(.*)Foot") == nil then
					--					return
				end
			end)			
		end)({["aCharacter"]=aCharacter2,["aPlayer"]=aPlayer,})

		aModule.MyPlayer.MyRadar.SetInit(aParam)
	end)

	return
end

aModule.MyPlayer.MyRadar = {}
aModule.MyPlayer.MyRadar.SetInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer
	local aService
	local aInstance
	local aParent
	local aName
	local aOffset
	local aProperty
	local aZIndex
	local aFrame

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aPlayer = aService:GetPlayerByUserId(aPlayer.UserId)

	aParent = aPlayer:FindFirstChild("PlayerGui")
	aName = aConfig.MyPlayer.MyRadar.aName
	aInstance = aParent:FindFirstChild(""..aName)
	if aInstance ~= nil then
		--		aInstance:Destroy()
		--		aInstance = nil
		return
	end

	aInstance = Instance.new("ScreenGui")
	aInstance.Name = ""..aName
	aInstance.Parent = aParent
	aParent = aInstance

	aOffset = aConfig.MyPlayer.MyRadar.MySize.aX
	aZIndex = 0

	aInstance = Instance.new("Frame")
	aInstance.Name = aConfig.MyPlayer.MyRadar.MyFrame.aName
	aInstance.Parent = aParent
	aInstance.ClipsDescendants = true
	aInstance.BackgroundTransparency = 1.0
	aInstance.Position = UDim2.new(0.0,0.0,0.0,0.0)
	aProperty = aConfig.MyPlayer.MyRadar.MyFrame.MySize
	aInstance.Size = UDim2.new(
		0,aProperty.aX,
		0,aProperty.aY
	)
	aInstance.AnchorPoint = Vector2.new(0,0)
	aZIndex += 1;
	aInstance.ZIndex = aZIndex
	aFrame = aInstance

	aInstance = Instance.new("ImageLabel")
	aInstance.Parent = aFrame
	aInstance.Name = aConfig.MyPlayer.MyRadar.MyOverlay.aName
	aInstance.Image = "rbxassetid://"..aConfig.MyPlayer.MyRadar.MyOverlay.aAssetId
	aProperty = aConfig.MyPlayer.MyRadar.MyOverlay.MySize
	aInstance.BackgroundColor3 = Color3.new(0, 0.5, 0) -- Dark green
	aInstance.ImageColor3 = Color3.new(0.5, 0, 0) -- Dark red
	aInstance.ImageTransparency = 0.75
	aInstance.BackgroundTransparency = 0.75
	aInstance.Position = UDim2.new(0.0,0.0,0.0,0.0)
	aProperty = aConfig.MyPlayer.MyRadar.MyOverlay.MySize
	aInstance.Size = UDim2.new(
		0,aProperty.aX,
		0,aProperty.aY
	)
	aInstance.AnchorPoint = Vector2.new(0,0)
	aZIndex += 1;
	aInstance.ZIndex = aZIndex

	aInstance = Instance.new("ImageLabel")
	aInstance.Parent = aFrame
	aInstance.Name = aConfig.MyPlayer.MyRadar.MyCenter.aName
	aInstance.Image = "rbxassetid://"..aConfig.MyPlayer.MyRadar.MyCenter.aAssetId
	aInstance.BackgroundColor3 = Color3.new(0.0, 0.5, 0)
	aInstance.BackgroundTransparency = 0.5
	aInstance.Position = UDim2.new(0.5,0,0.5,0)
	aProperty = aConfig.MyPlayer.MyRadar.MyCenter.MySize
	aInstance.Size = UDim2.new(
		0,aProperty.aX,
		0,aProperty.aY
	)
	aInstance.AnchorPoint = Vector2.new(0.5,0.5)
	aZIndex += 1;
	aInstance.ZIndex = aZIndex
end

return aModule
