("This script is way too long"):rep(#'1954real & Knightingale')

local vars = {};

vars.success, vars.err = pcall(function()

vars.getService = function(name)	local ok, service = pcall(function()
		local s = game:GetService(name)
		return (type(cloneref) == "function") and cloneref(s) or s
	end)
	return ok and service or game:GetService(name)
end

vars.UI_FONT_FAMILY = "rbxasset://fonts/families/BuilderExtended.json"
vars.UI_WEIGHT = Enum.FontWeight.SemiBold
_=`why the hell does every text feel off`

vars.Players = vars.getService("Players")
vars.HttpService = vars.getService("HttpService")
vars.UserInputService = vars.getService("UserInputService")
vars.RunService = vars.getService("RunService")
vars.ContentProvider = vars.getService("ContentProvider")
vars.TweenService = vars.getService("TweenService")
vars.Workspace = vars.getService("Workspace")
vars.CoreGui = vars.getService("CoreGui")
vars.InsertService = vars.getService("InsertService")
vars.StarterGui = vars.getService("StarterGui")
vars.ReplicatedStorage = vars.getService("ReplicatedStorage")

vars.IS_CATALOG_AVATAR_CREATOR = (game.PlaceId == 7041939546)
vars.CATALOG_EVENTS = vars.ReplicatedStorage:FindFirstChild("Events")
vars.CATALOG_GUI_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("CatalogGuiRemote")
vars.SAVED_OUTFITS_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("SavedOutfitsRemote")

vars.LocalPlayer = vars.Players.LocalPlayer
if not vars.LocalPlayer then
	error("LocalPlayer was not available.")
end

vars.FOLDER_NAME = "Avatar Saver v2"
vars.FILE_PATH = vars.FOLDER_NAME .. "/SavedAvatars.json" 
vars.AVATARS_FOLDER = "Avatars"
vars.AVATAR_FILE_PREFIX = "Avatar"
vars.AVATAR_FILE_EXTENSION = ".ava"
vars.SCREEN_GUI_NAME = "LocalWearer_UI"

vars.uiFont = function(weight)
	local ok, font = pcall(function()
		return Font.new(vars.UI_FONT_FAMILY, weight or Enum.FontWeight.Regular)
	end)
	if ok then return font end
	return Font.new(Enum.Font.Gotham, weight or Enum.FontWeight.Regular)
end

vars.runtimeConnections = {}
vars.scriptAlive = true
vars.tryOnActive = false
vars.localTryOnModel = nil
vars.localTryOnToolVisual = nil
vars.localTryOnToolSource = nil
vars.localTryOnToolVisualEntries = {}
vars.localTryOnAttachedPropVisualEntries = {}
vars.localTryOnAppliedAvatarAccessoryAssetIds = {}
vars.localTryOnToolVisualOriginals = {}
vars.localTryOnExternalWorldPropVisualEntries = {}
vars.localTryOnReferencedDisplayRoots = {}
vars.localTryOnToolVisualHidden = false
vars.localTryOnToolExpectedHandleOffset = nil

-- v28.6: structural discovery is event/interval driven. The per-frame callback only
-- moves visual instances that already exist. Heavy tree/assembly queries stay off it.
vars.localTryOnLoadoutVisualDirty = true
vars.localTryOnLoadoutVisualNextScan = 0
vars.localTryOnLoadoutVisualScanInterval = 1.0
vars.hiddenCharacterParts = {}
vars.hiddenCharacterDecals = {}
vars.localTryOnConnections = {}
vars.localCharacterAnimationBackup = nil
vars.replicatedCharacterAnimationTracks = {}
vars.localTryOnRootPart = nil
vars.localTryOnGroundOffset = Vector3.zero
vars.localTryOnGroundOffsetValid = false
vars.localTryOnNeutralCloneFeetRootOffsetY = nil
vars.localTryOnSwimOffset = Vector3.zero
vars.currentVerticalOffset = Vector3.zero
vars.localTryOnSeatedHipOffsetLocal = Vector3.zero
vars.localTryOnSeatedHipOffsetValid = false
vars.localTryOnSeatTransitionActive = false
vars.localTryOnSeatTransitionStartLocal = Vector3.zero
vars.localTryOnSeatTransitionStartedAt = 0
vars.localTryOnSwimTransitionActive = false
vars.localTryOnSwimTransitionStart = Vector3.zero
vars.localTryOnSwimTransitionStartedAt = 0
vars.localTryOnLastSwimming = false
vars.localTryOnSeatPart = nil
vars.localTryOnPositionMode = "Ground"
vars.localTryOnSeatCalibrationPending = false
vars.localTryOnSeatCalibrationToken = 0
vars.localTryOnGroundCalibrationFrames = 0
vars.localTryOnHiddenInFirstPerson = false
vars.localTryOnBuilding = false
vars.localTryOnBuildId = 0
vars.localTryOnMissingRecoveryPending = false
vars.localTryOnCollisionParts = {}
vars.placeholderMode = false
vars.placeholderR6Active = false
vars.placeholderR6Building = false
vars.placeholderR6Backup = nil
vars.deathConnection = nil
vars.characterAddedConnection = nil
vars.searchDebounceThread = nil

vars.activeCloneTracks = {}
vars.activeCloneStopConnections = {}
vars.activeCloneEmoteAnimations = {}
vars.activeCloneHeldPropTracks = {}
vars.activeCloneHeldPropStopConnections = {}
vars.activeCloneHeldPropSpeedConnections = {}
vars.activeCloneHeldPropAnimations = {}
vars.activeEmotePlayerTrack = nil
vars.animPlayedConnection = nil
vars.emoteAssetAnimationCache = {}

vars.parseAssetId = function(val)	if not val then return nil end
	if type(val) == "number" then return val > 0 and val or nil end
	local digits = string.match(tostring(val), "%d+")
	return digits and tonumber(digits) or nil
end

vars.cloneEmoteTable = function(emotes)	local copy = {}
	if type(emotes) ~= "table" then return copy end
	for name, ids in pairs(emotes) do
		if type(name) == "string" and type(ids) == "table" then
			local idList = {}
			for _, assetId in ipairs(ids) do
				local parsed = vars.parseAssetId(assetId)
				if parsed then idList[#idList + 1] = parsed end
			end
			if #idList > 0 then copy[name] = idList end
		end
	end
	return copy
end

vars.BLUE_NORMAL = Color3.fromRGB(25, 115, 230)
vars.BLUE_HOVER = Color3.fromRGB(45, 135, 255)
vars.GREEN_NORMAL = Color3.fromRGB(35, 175, 80)
vars.GREEN_HOVER = Color3.fromRGB(50, 200, 95)

vars.R6_DEFAULTS = {
	Idle = "rbxassetid://180435571",
	Walk = "rbxassetid://180426354",
	Run = "rbxassetid://180426354",
	Jump = "rbxassetid://125750702",
	Fall = "rbxassetid://180436148",
	Climb = "rbxassetid://180436334",
	Swim = "rbxassetid://180426354",
	SwimIdle = "rbxassetid://180435571",
	Sit = "rbxassetid://178130996"
}

vars.R15_DEFAULTS = {
	Idle = "rbxassetid://507766388",
	Walk = "rbxassetid://913403211",
	Run = "rbxassetid://913384386",
	Jump = "rbxassetid://507765000",
	Fall = "rbxassetid://507767968",
	Climb = "rbxassetid://507765644",
	Swim = "rbxassetid://913389285",
	SwimIdle = "rbxassetid://507785072",
	Sit = "rbxassetid://507768133"
}

vars.R6_EMOTE_LIBRARY = {
	wave = { "rbxassetid://128777973" },
	point = { "rbxassetid://128853357" },
	dance = {
		"rbxassetid://182435998",
		"rbxassetid://182491037",
		"rbxassetid://182491065"
	},
	dance1 = {
		"rbxassetid://182435998",
		"rbxassetid://182491037",
		"rbxassetid://182491065"
	},
	dance2 = {
		"rbxassetid://182436842",
		"rbxassetid://182491248",
		"rbxassetid://182491277"
	},
	dance3 = {
		"rbxassetid://182436935",
		"rbxassetid://182491368",
		"rbxassetid://182491423"
	},
	laugh = { "rbxassetid://129423131" },
	cheer = { "rbxassetid://129423030" }
}

vars.R6_EMOTE_LOOPED = {
	wave = false,
	point = false,
	dance = true,
	dance1 = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}

vars.PLAYER_LEGACY_EMOTE_IDS = {
	["507770239"] = "wave",
	["507770453"] = "point",
	["507771019"] = "dance",
	["507771955"] = "dance",
	["507772104"] = "dance",
	["507776043"] = "dance2",
	["507776720"] = "dance2",
	["507776879"] = "dance2",
	["507777268"] = "dance3",
	["507777451"] = "dance3",
	["507777623"] = "dance3",
	["507770818"] = "laugh",
	["507770677"] = "cheer",
}

for emoteName, assetList in pairs(vars.R6_EMOTE_LIBRARY) do
	for _, assetId in ipairs(assetList) do
		local parsed = vars.parseAssetId(assetId)
		if parsed then vars.PLAYER_LEGACY_EMOTE_IDS[tostring(parsed)] = emoteName end
	end
end

vars.previewQueue = {}
vars.previewQueueRunning = false
vars.previewQueueGeneration = 0
vars.previewStates = {}

vars.previewModelCache = {}
vars.previewCacheOrder = {}
vars.PREVIEW_CACHE_LIMIT = 24

vars.getPreviewCacheKey = function(data)	if not data then return nil end
	local stableId = data.Signature or data.FileName or data.UserId or data.Name
	if stableId ~= nil then
		return tostring(stableId) .. "|" .. tostring(data.RigType)
	end
	local ok, encoded = pcall(function()
		return vars.HttpService:JSONEncode({
			Properties = data.Properties,
			RigType = tostring(data.RigType)
		})
	end)
	if ok and encoded then return encoded end
	return tostring(data)
end

vars.clearPreviewModelCache = function()	for key, model in pairs(vars.previewModelCache) do
		pcall(function() if model then model:Destroy() end end)
		vars.previewModelCache[key] = nil
	end
	table.clear(vars.previewCacheOrder)
end

vars.touchPreviewCache = function(key)	for i = #vars.previewCacheOrder, 1, -1 do
		if vars.previewCacheOrder[i] == key then table.remove(vars.previewCacheOrder, i) end
	end
	table.insert(vars.previewCacheOrder, key)
	while #vars.previewCacheOrder > vars.PREVIEW_CACHE_LIMIT do
		local oldKey = table.remove(vars.previewCacheOrder, 1)
		local oldModel = vars.previewModelCache[oldKey]
		vars.previewModelCache[oldKey] = nil
		pcall(function() if oldModel then oldModel:Destroy() end end)
	end
end

vars.wire = function(signal, callback)	local connection = signal:Connect(callback)
	vars.runtimeConnections[#vars.runtimeConnections + 1] = connection
	return connection
end

vars.disconnectConnection = function(connection)	if connection then
		pcall(function()
			if connection.Connected then connection:Disconnect() end
		end)
	end
end

vars.setLocalTryOnConnection = function(name, signal, callback)	vars.disconnectConnection(vars.localTryOnConnections[name])
	if signal and callback then
		vars.localTryOnConnections[name] = signal:Connect(callback)
	else
		vars.localTryOnConnections[name] = nil
	end
	return vars.localTryOnConnections[name]
end

vars.disconnectLocalTryOnConnections = function()	for name, connection in pairs(vars.localTryOnConnections) do
		vars.disconnectConnection(connection)
		vars.localTryOnConnections[name] = nil
	end
	table.clear(vars.localTryOnCollisionParts)
end

vars.resetLocalTryOnState = function()	vars.localTryOnRootPart = nil
	vars.localTryOnGroundOffset = Vector3.zero
	vars.localTryOnGroundOffsetValid = false
	vars.localTryOnNeutralCloneFeetRootOffsetY = nil
	vars.localTryOnSwimOffset = Vector3.zero
	vars.currentVerticalOffset = Vector3.zero
	vars.localTryOnSeatedHipOffsetLocal = Vector3.zero
	vars.localTryOnSeatedHipOffsetValid = false
	vars.localTryOnSeatTransitionActive = false
	vars.localTryOnSeatTransitionStartLocal = Vector3.zero
	vars.localTryOnSeatTransitionStartedAt = 0
	vars.localTryOnSwimTransitionActive = false
	vars.localTryOnSwimTransitionStart = Vector3.zero
	vars.localTryOnSwimTransitionStartedAt = 0
	vars.localTryOnLastSwimming = false
	vars.localTryOnSeatPart = nil
	vars.localTryOnPositionMode = "Ground"
	vars.localTryOnSeatCalibrationPending = false
	vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
	vars.localTryOnGroundCalibrationFrames = 0
	vars.localTryOnHiddenInFirstPerson = false
end

vars.vector3FromSaved = function(value, fallback)	if typeof(value) == "Vector3" then return value end
	if type(value) == "table" then
		return Vector3.new(
			tonumber(value.X or value.x) or fallback.X,
			tonumber(value.Y or value.y) or fallback.Y,
			tonumber(value.Z or value.z) or fallback.Z
		)
	end
	return fallback
end

vars.getEnumRigType = function(value)	if typeof(value) == "EnumItem" then return value end
	local text = tostring(value or "")
	if text:find("R6") then return Enum.HumanoidRigType.R6 end
	return Enum.HumanoidRigType.R15
end

vars.activeCloneToolActionTracks = {}
vars.activeCloneToolActionAnimations = {}
vars.activeCloneToolActionConnections = {}
vars.activeCloneToolActionTools = {}
vars.animationToolConnections = {}
vars.animationToolStates = {}
vars.animationToolAnimationIds = {}

vars.stopCloneEmoteTracks = function(fadeTime)
	for _, stoppedConnection in pairs(vars.activeCloneStopConnections) do
		vars.disconnectConnection(stoppedConnection)
	end
	table.clear(vars.activeCloneStopConnections)

	for playerTrack, cloneTrack in pairs(vars.activeCloneTracks) do
		pcall(function() cloneTrack:Stop(fadeTime or 0.05) end)
		local animation = vars.activeCloneEmoteAnimations[playerTrack]
		if animation then pcall(function() animation:Destroy() end) end
		vars.activeCloneEmoteAnimations[playerTrack] = nil
	end
	table.clear(vars.activeCloneTracks)
	table.clear(vars.activeCloneEmoteAnimations)
	vars.activeEmotePlayerTrack = nil
end

vars.stopCloneHeldPropTracks = function(fadeTime)
	for _, stoppedConnection in pairs(vars.activeCloneHeldPropStopConnections) do
		vars.disconnectConnection(stoppedConnection)
	end
	table.clear(vars.activeCloneHeldPropStopConnections)

	for _, speedConnection in pairs(vars.activeCloneHeldPropSpeedConnections) do
		vars.disconnectConnection(speedConnection)
	end
	table.clear(vars.activeCloneHeldPropSpeedConnections)

	for playerTrack, cloneTrack in pairs(vars.activeCloneHeldPropTracks) do
		pcall(function() cloneTrack:Stop(fadeTime or 0.05) end)
		local animation = vars.activeCloneHeldPropAnimations[playerTrack]
		if animation then pcall(function() animation:Destroy() end) end
		vars.activeCloneHeldPropAnimations[playerTrack] = nil
	end
	table.clear(vars.activeCloneHeldPropTracks)
	table.clear(vars.activeCloneHeldPropAnimations)
end

vars.stopCloneToolActionTrack = function(playerTrack, fadeTime)
	local connections = vars.activeCloneToolActionConnections[playerTrack]
	if connections then
		for _, connection in ipairs(connections) do
			vars.disconnectConnection(connection)
		end
	end
	vars.activeCloneToolActionConnections[playerTrack] = nil

	local cloneTrack = vars.activeCloneToolActionTracks[playerTrack]
	vars.activeCloneToolActionTracks[playerTrack] = nil
	if cloneTrack then pcall(function() cloneTrack:Stop(fadeTime or 0.05) end) end

	local animation = vars.activeCloneToolActionAnimations[playerTrack]
	vars.activeCloneToolActionAnimations[playerTrack] = nil
	vars.activeCloneToolActionTools[playerTrack] = nil
	if animation then pcall(function() animation:Destroy() end) end
end

vars.stopCloneToolActionTracks = function(fadeTime)
	local playerTracks = {}
	for playerTrack in pairs(vars.activeCloneToolActionTracks) do
		playerTracks[#playerTracks + 1] = playerTrack
	end
	for _, playerTrack in ipairs(playerTracks) do
		vars.stopCloneToolActionTrack(playerTrack, fadeTime)
	end
	table.clear(vars.activeCloneToolActionTracks)
	table.clear(vars.activeCloneToolActionAnimations)
	table.clear(vars.activeCloneToolActionConnections)
	table.clear(vars.activeCloneToolActionTools)
end

vars.stopCloneToolActionsForTool = function(tool, fadeTime)
	if not tool then return end
	local playerTracks = {}
	for playerTrack, actionTool in pairs(vars.activeCloneToolActionTools) do
		if actionTool == tool then
			playerTracks[#playerTracks + 1] = playerTrack
		end
	end
	for _, playerTrack in ipairs(playerTracks) do
		vars.stopCloneToolActionTrack(playerTrack, fadeTime)
	end
end

-- Full reset (respawn / rebuild / cleanup). Emote and movement paths use the
-- scoped functions above so they no longer destroy unrelated layers.
vars.stopAllCloneTracks = function(fadeTime)
	vars.stopCloneEmoteTracks(fadeTime)
	vars.stopCloneHeldPropTracks(fadeTime)
	vars.stopCloneToolActionTracks(fadeTime)
end

vars.cleanupAnimationSync = function()
	vars.stopAllCloneTracks()
	vars.disconnectConnection(vars.animPlayedConnection)
	vars.animPlayedConnection = nil

	-- Pose mirroring has its own frame lifecycle and must be removed together
	-- with the animation listeners when the clone is rebuilt or destroyed.
	vars.setLocalTryOnConnection("animationPoseSync", nil)
	vars.setLocalTryOnConnection("animationPoseSourceChanged", nil)
	vars.setLocalTryOnConnection("animationPoseSourceChangedRemoved", nil)
	vars.setLocalTryOnConnection("animationPoseCloneChanged", nil)
	vars.setLocalTryOnConnection("animationPoseCloneChangedRemoved", nil)

	local toolList = {}
	for tool in pairs(vars.animationToolConnections) do
		toolList[#toolList + 1] = tool
	end
	for _, tool in ipairs(toolList) do
		local connections = vars.animationToolConnections[tool]
		if connections then
			for _, connection in ipairs(connections) do
				vars.disconnectConnection(connection)
			end
		end
		vars.animationToolConnections[tool] = nil
	end
	table.clear(vars.animationToolStates)
	table.clear(vars.animationToolAnimationIds)
end

vars.cleanup = function()	vars.scriptAlive = false
	if vars.ui and vars.stopPlayerSelection then pcall(vars.stopPlayerSelection) end
	vars.localTryOnBuildId = vars.localTryOnBuildId + 1
	vars.localTryOnBuilding = false
	vars.tryOnActive = false
	vars.cleanupAnimationSync()

	if vars.searchDebounceThread then
		task.cancel(vars.searchDebounceThread)
		vars.searchDebounceThread = nil
	end

	vars.previewQueueGeneration = vars.previewQueueGeneration + 1
	vars.clearPreviewModelCache()
	table.clear(vars.previewQueue)
	table.clear(vars.previewStates)
	vars.previewQueueRunning = false

	vars.disconnectConnection(vars.deathConnection)
	vars.deathConnection = nil
	vars.disconnectConnection(vars.characterAddedConnection)
	vars.characterAddedConnection = nil
	vars.disconnectLocalTryOnConnections()

	pcall(function() if vars.localTryOnModel then vars.localTryOnModel:Destroy() end end)
	vars.localTryOnModel = nil
	vars.resetLocalTryOnState()

	for part, oldTransparency in pairs(vars.hiddenCharacterParts) do
		pcall(function()
			if part and part.Parent then
				part.LocalTransparencyModifier = oldTransparency
			end
		end)
	end
	table.clear(vars.hiddenCharacterParts)

	for decal, oldTransparency in pairs(vars.hiddenCharacterDecals) do
		pcall(function()
			if decal and decal.Parent then
				decal.Transparency = oldTransparency
			end
		end)
	end
	table.clear(vars.hiddenCharacterDecals)

	for _, connection in ipairs(vars.runtimeConnections) do
		vars.disconnectConnection(connection)
	end
	table.clear(vars.runtimeConnections)

	pcall(function()
		local roots = {}
		if type(gethui) == "function" then table.insert(roots, gethui()) end
		table.insert(roots, vars.CoreGui)
		if vars.LocalPlayer then table.insert(roots, vars.LocalPlayer:FindFirstChildOfClass("PlayerGui")) end
		for _, root in ipairs(roots) do
			if root then
				local screenUi = root:FindFirstChild(vars.SCREEN_GUI_NAME)
				if screenUi then screenUi:Destroy() end
			end
		end
	end)

	pcall(function()
		if type(getgenv) == "function" and getgenv().__LocalWearerCleanup == vars.cleanup then
			getgenv().__LocalWearerCleanup = nil
		end
	end)
end

pcall(function()
	if type(getgenv) == "function" and type(getgenv().__LocalWearerCleanup) == "function" then
		pcall(getgenv().__LocalWearerCleanup)
	end
end)

vars.cleanup()
vars.scriptAlive = true

pcall(function()
	if type(getgenv) == "function" then
		getgenv().__LocalWearerCleanup = vars.cleanup
	end
end)

vars.mainCamera = vars.Workspace.CurrentCamera
vars.viewportSize = vars.mainCamera and vars.mainCamera.ViewportSize or Vector2.new(1024, 768)
vars.mainWidth = 500
vars.mainHeight = 400
vars.minimizedWidth = 180

vars.COLORS = {
	Background = Color3.fromRGB(9, 9, 10),
	Surface = Color3.fromRGB(15, 15, 17),
	Surface2 = Color3.fromRGB(21, 21, 23),
	Surface3 = Color3.fromRGB(28, 28, 31),
	Border = Color3.fromRGB(58, 58, 62),
	Text = Color3.fromRGB(242, 242, 242),
	Muted = Color3.fromRGB(145, 145, 150),
	Accent = Color3.fromRGB(205, 205, 210),
	AccentHover = Color3.fromRGB(190, 190, 190),
	Accent2 = Color3.fromRGB(105, 105, 110),
	Success = Color3.fromRGB(82, 130, 120),
	SuccessHover = Color3.fromRGB(105, 170, 142),
	Danger = Color3.fromRGB(225, 65, 80),
	DangerHover = Color3.fromRGB(245, 82, 98),
}

vars.ScreenGui = Instance.new("ScreenGui")
vars.ScreenGui.Name = vars.SCREEN_GUI_NAME
vars.ScreenGui.ResetOnSpawn = false
vars.ScreenGui.IgnoreGuiInset = true

vars.parented = false
if type(gethui) == "function" then
	pcall(function() vars.ScreenGui.Parent = gethui() vars.parented = true end)
end
if not vars.parented then
	pcall(function() vars.ScreenGui.Parent = vars.CoreGui vars.parented = true end)
end
if not vars.parented then
	local playerGui = vars.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then vars.ScreenGui.Parent = playerGui vars.parented = true end
end
if not vars.parented then error("Unable to create Local Wearer UI.") end

vars.UI_REFERENCE_SIZE = Vector2.new(1920, 1080)
vars.UI_CONTENT_SIZE = Vector2.new(880, 420)

vars.UIRoot = Instance.new("Frame")
vars.UIRoot.Name = "UIRoot"
vars.UIRoot.AnchorPoint = Vector2.new(0.5, 0.5)
vars.UIRoot.Size = UDim2.fromOffset(vars.UI_REFERENCE_SIZE.X, vars.UI_REFERENCE_SIZE.Y)
vars.UIRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
vars.UIRoot.BackgroundTransparency = 1
vars.UIRoot.BorderSizePixel = 0
vars.UIRoot.ClipsDescendants = false
vars.UIRoot.Parent = vars.ScreenGui

vars.UIScale = Instance.new("UIScale")
vars.UIScale.Scale = 1
vars.UIScale.Parent = vars.UIRoot

vars.updateDeviceScale = function()
    local camera = vars.Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or vars.viewportSize
    local width = math.max(viewport.X, 1)
    local height = math.max(viewport.Y, 1)
    local horizontalScale = (width - 24) / vars.UI_CONTENT_SIZE.X
    local verticalScale = (height - 24) / vars.UI_CONTENT_SIZE.Y
    vars.UIScale.Scale = math.clamp(math.min(horizontalScale, verticalScale), 0.1, 1)
end

vars.bindViewportScale = function(camera)
    vars.updateDeviceScale()
    if camera then
        vars.wire(camera:GetPropertyChangedSignal("ViewportSize"), vars.updateDeviceScale)
    end
end

vars.bindViewportScale(vars.mainCamera)
vars.wire(vars.Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    vars.bindViewportScale(vars.Workspace.CurrentCamera)
end)

vars.ui = {
    savedAvatars = {},
    selectedAvatar = nil,
    avatarRows = {},
    hoverModel = nil,
    hoverViewport = nil,
    hoverConnection = nil,
    hoverButton = nil,
    selectingPlayer = false,
    selectionHighlight = nil,
    selectionPlayer = nil,
}

vars.addCorner = function(parent, radius)	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

vars.addStroke = function(parent, color, thickness, transparency)	local stroke = Instance.new("UIStroke")
	stroke.Color = color or vars.COLORS.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.4
	stroke.Parent = parent
	return stroke
end

vars.addGradient = function(parent, color1, color2, rotation)	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(color1, color2)
	gradient.Rotation = rotation or 0
	gradient.Parent = parent
	return gradient
end

vars.addPadding = function(parent, left, right, top, bottom)	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, left or 0)
	pad.PaddingRight = UDim.new(0, right or left or 0)
	pad.PaddingTop = UDim.new(0, top or 0)
	pad.PaddingBottom = UDim.new(0, bottom or top or 0)
	pad.Parent = parent
	return pad
end

vars.BUILDER_ICONS_FONT = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
vars.BUILDER_ICONS = {
	Rename = "pencil-square", 
	Preview3D = "cube-vertexes", 
	Delete = "trash-can", 
	Refresh = "arrow-spin-clockwise",
	Minimize = "two-arrows-to-center",
	Maximize = "two-arrows-from-center",
	Close = "x"
}

vars.createBuilderIcon = function(parent, name, code, size, color)
	local label = Instance.new("TextLabel")
	label.Name = name or "Icon"
	label.BackgroundTransparency = 1
	label.Text = code or ""
	label.TextColor3 = color or vars.COLORS.Text
	label.TextScaled = true
	label.Size = UDim2.fromOffset(size or 18, size or 18)
	label.Font = Enum.Font.GothamBold
	if code and code ~= "" then
		pcall(function()
			label.FontFace = Font.new(vars.BUILDER_ICONS_FONT, Enum.FontWeight.Bold)
		end)
	end
	label.Parent = parent
	return label
end

vars.createButton = function(parent, name, text, baseColor, hoverColor)	local button = Instance.new("TextButton")
	button.Name = name
	local normalColor = baseColor or vars.COLORS.Surface3
	local hover = hoverColor or Color3.fromRGB(38, 45, 62)

	button.BackgroundColor3 = normalColor
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = vars.COLORS.Text
	button.TextSize = 12
	button.FontFace = vars.uiFont(vars.UI_WEIGHT)
	button.AutoButtonColor = false
	button.Active = true
	button.Parent = parent
	vars.addCorner(button, 7)
	vars.addStroke(button, vars.COLORS.Border, 1)

	vars.wire(button.MouseEnter, function()
		vars.TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {BackgroundColor3 = hover}):Play()
	end)
	vars.wire(button.MouseLeave, function()
		vars.TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {BackgroundColor3 = normalColor}):Play()
	end)

	return button
end

vars.Main = Instance.new("Frame")
vars.Main.Name = "Main"
vars.Main.Size = UDim2.new(0, vars.mainWidth, 0, vars.mainHeight)
vars.previewWidth = 340
vars.previewGap = 12
vars.previewCameraDistanceMultiplier = 1.80 
vars.Main.Position = UDim2.new(0.5, -(vars.mainWidth + vars.previewGap + vars.previewWidth) / 2, 0.5, -vars.mainHeight / 2)
vars.Main.BackgroundColor3 = vars.COLORS.Background
vars.Main.BorderSizePixel = 0
vars.Main.ClipsDescendants = true
vars.Main.Active = true

vars.MainShadowOuter = Instance.new("Frame")
vars.MainShadowOuter.Name = "MainShadowOuter"
vars.MainShadowOuter.Size = UDim2.new(0, vars.mainWidth + 14, 0, vars.mainHeight + 14)
vars.MainShadowOuter.Position = UDim2.new(
	vars.Main.Position.X.Scale, vars.Main.Position.X.Offset - 7,
	vars.Main.Position.Y.Scale, vars.Main.Position.Y.Offset - 7
)
vars.MainShadowOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vars.MainShadowOuter.BackgroundTransparency = 0.84
vars.MainShadowOuter.BorderSizePixel = 0
vars.MainShadowOuter.ZIndex = 0
vars.MainShadowOuter.Parent = vars.UIRoot
vars.addCorner(vars.MainShadowOuter, 12)

vars.MainShadowInner = Instance.new("Frame")
vars.MainShadowInner.Name = "MainShadowInner"
vars.MainShadowInner.Size = UDim2.new(0, vars.mainWidth + 8, 0, vars.mainHeight + 8)
vars.MainShadowInner.Position = UDim2.new(
	vars.Main.Position.X.Scale, vars.Main.Position.X.Offset - 4,
	vars.Main.Position.Y.Scale, vars.Main.Position.Y.Offset - 4
)
vars.MainShadowInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vars.MainShadowInner.BackgroundTransparency = 0.72
vars.MainShadowInner.BorderSizePixel = 0
vars.MainShadowInner.ZIndex = 0
vars.MainShadowInner.Parent = vars.UIRoot
vars.addCorner(vars.MainShadowInner, 10)

vars.Main.Parent = vars.UIRoot
vars.Main.ZIndex = 1
vars.addCorner(vars.Main, 6)
vars.addStroke(vars.Main, vars.COLORS.Border, 1)

vars.MainShadowOuter.Size = UDim2.new(0, vars.mainWidth + 14, 0, vars.mainHeight + 14)
vars.MainShadowInner.Size = UDim2.new(0, vars.mainWidth + 8, 0, vars.mainHeight + 8)

vars.MainGradient = Instance.new("UIGradient")
vars.MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 13)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 9))
})
vars.MainGradient.Rotation = 90
vars.MainGradient.Parent = vars.Main

vars.TitleBar = Instance.new("Frame")
vars.TitleBar.Name = "TitleBar"
vars.TitleBar.Size = UDim2.new(1, 0, 0, 44)
vars.TitleBar.BackgroundColor3 = vars.COLORS.Surface
vars.TitleBar.BorderSizePixel = 0
vars.TitleBar.ZIndex = 10
vars.TitleBar.Active = true
vars.TitleBar.Parent = vars.Main
vars.addCorner(vars.TitleBar, 6)

vars.HeaderShade = Instance.new("Frame")
vars.HeaderShade.Size = UDim2.new(1, 0, 0, 18)
vars.HeaderShade.Position = UDim2.new(0, 0, 1, -18)
vars.HeaderShade.BackgroundColor3 = vars.COLORS.Surface
vars.HeaderShade.BorderSizePixel = 0
vars.HeaderShade.ZIndex = 10
vars.HeaderShade.Parent = vars.TitleBar

vars.Title = Instance.new("TextLabel")
vars.Title.Name = "Title"
vars.Title.Size = UDim2.new(1, -120, 1, 0)
vars.Title.Position = UDim2.new(0, 12, 0, 0)
vars.Title.BackgroundTransparency = 1
vars.Title.Text = "Avatar - Z"
vars.Title.TextColor3 = vars.COLORS.Text
vars.Title.TextSize = 15
vars.Title.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.Title.TextXAlignment = Enum.TextXAlignment.Left
vars.Title.ZIndex = 12
vars.Title.Parent = vars.TitleBar

vars.MinimizeButton = vars.createButton(vars.TitleBar, "Minimize", "")
vars.MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
vars.MinimizeButton.Position = UDim2.new(1, -68, 0, 8)
vars.MinimizeButton.TextSize = 16
vars.MinimizeButton.ZIndex = 13

vars.MinimizeIcon = vars.createBuilderIcon(
	vars.MinimizeButton,
	"Icon",
	vars.BUILDER_ICONS.Minimize,
	15,
	vars.COLORS.Muted
)
vars.MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
vars.MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
vars.MinimizeIcon.ZIndex = 14

vars.DestroyButton = vars.createButton(
	vars.TitleBar,
	"Destroy",
	"",
	vars.COLORS.Danger,
	vars.COLORS.DangerHover
)
vars.DestroyButton.Size = UDim2.new(0, 28, 0, 28)
vars.DestroyButton.Position = UDim2.new(1, -34, 0, 8)
vars.DestroyButton.TextSize = 16
vars.DestroyButton.ZIndex = 13

vars.DestroyIcon = vars.createBuilderIcon(
	vars.DestroyButton,
	"Icon",
	vars.BUILDER_ICONS.Close,
	15,
	vars.COLORS.Text
)
vars.DestroyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
vars.DestroyIcon.Position = UDim2.new(0.481, 0, 0.495, 0)
vars.DestroyIcon.ZIndex = 14

vars.ConfirmOverlay = Instance.new("TextButton")
vars.ConfirmOverlay.Name = "ConfirmOverlay"
vars.ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
vars.ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(5, 7, 11)
vars.ConfirmOverlay.BackgroundTransparency = 0.18
vars.ConfirmOverlay.BorderSizePixel = 0
vars.ConfirmOverlay.ZIndex = 50
vars.ConfirmOverlay.Visible = false
vars.ConfirmOverlay.Active = true
vars.ConfirmOverlay.AutoButtonColor = false
vars.ConfirmOverlay.Text = ""
vars.ConfirmOverlay.Parent = vars.Main
vars.addCorner(vars.ConfirmOverlay, 14)

vars.ConfirmBox = Instance.new("Frame")
vars.ConfirmBox.Name = "ConfirmBox"
vars.ConfirmBox.Size = UDim2.new(0.4, 0, 0, 132)
vars.ConfirmBox.Position = UDim2.new(0.28, 0, 0.5, -66)
vars.ConfirmBox.BackgroundColor3 = vars.COLORS.Surface2
vars.ConfirmBox.BorderSizePixel = 0
vars.ConfirmBox.ZIndex = 51
vars.ConfirmBox.Parent = vars.ConfirmOverlay
vars.addCorner(vars.ConfirmBox, 12)
vars.addStroke(vars.ConfirmBox, vars.COLORS.Border, 1)

vars.ConfirmAccent = Instance.new("Frame")
vars.ConfirmAccent.Size = UDim2.new(1, 0, 0, 3)
vars.ConfirmAccent.BackgroundColor3 = vars.COLORS.Accent
vars.ConfirmAccent.BorderSizePixel = 0
vars.ConfirmAccent.ZIndex = 52
vars.ConfirmAccent.Parent = vars.ConfirmBox
vars.addCorner(vars.ConfirmAccent, 4)

vars.ConfirmText = Instance.new("TextLabel")
vars.ConfirmText.Name = "ConfirmText"
vars.ConfirmText.Size = UDim2.new(1, -24, 0, 60)
vars.ConfirmText.Position = UDim2.new(0, 12, 0, 18)
vars.ConfirmText.BackgroundTransparency = 1
vars.ConfirmText.Text = "Are you sure?"
vars.ConfirmText.TextColor3 = vars.COLORS.Text
vars.ConfirmText.TextSize = 13
vars.ConfirmText.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.ConfirmText.TextWrapped = true
vars.ConfirmText.ZIndex = 52
vars.ConfirmText.Parent = vars.ConfirmBox

vars.ConfirmYesBtn = vars.createButton(vars.ConfirmBox, "YesButton", "CONFIRM", vars.COLORS.Danger, vars.COLORS.DangerHover)
vars.ConfirmYesBtn.Size = UDim2.new(0.43, 0, 0, 28)
vars.ConfirmYesBtn.Position = UDim2.new(0.04, 0, 1, -38)
vars.ConfirmYesBtn.ZIndex = 53

vars.ConfirmNoBtn = vars.createButton(vars.ConfirmBox, "NoButton", "CANCEL", vars.COLORS.Surface3, Color3.fromRGB(52, 52, 55))
vars.ConfirmNoBtn.Size = UDim2.new(0.43, 0, 0, 28)
vars.ConfirmNoBtn.Position = UDim2.new(0.53, 0, 1, -38)
vars.ConfirmNoBtn.ZIndex = 53

vars.currentConfirmAction = nil
vars.minimized = false
vars.savedMainHeight = vars.mainHeight

vars.showConfirmation = function(message, onConfirm)	vars.ConfirmText.Text = tostring(message or "Are you sure?")
	vars.currentConfirmAction = onConfirm
	vars.ConfirmOverlay.Visible = not vars.minimized
end

vars.hideConfirmation = function()	vars.ConfirmOverlay.Visible = false
	vars.currentConfirmAction = nil
end

vars.wire(vars.ConfirmYesBtn.Activated, function()
	local action = vars.currentConfirmAction
	vars.hideConfirmation()
	if type(action) == "function" then action() end
end)

vars.wire(vars.ConfirmNoBtn.Activated, vars.hideConfirmation)

vars.RenameOverlay = Instance.new("Frame")
vars.RenameOverlay.Name = "RenameOverlay"
vars.RenameOverlay.Size = UDim2.new(1, 0, 1, 0)
vars.RenameOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vars.RenameOverlay.BackgroundTransparency = 0.38
vars.RenameOverlay.BorderSizePixel = 0
vars.RenameOverlay.Visible = false
vars.RenameOverlay.ZIndex = 70
vars.RenameOverlay.Parent = vars.Main

vars.RenameBox = Instance.new("Frame")
vars.RenameBox.Name = "RenameBox"
vars.RenameBox.Size = UDim2.new(0, 390, 0, 154)
vars.RenameBox.Position = UDim2.new(0.5, -195, 0.5, -77)
vars.RenameBox.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
vars.RenameBox.BorderSizePixel = 0
vars.RenameBox.ZIndex = 71
vars.RenameBox.Parent = vars.RenameOverlay
vars.addCorner(vars.RenameBox, 7)
vars.addStroke(vars.RenameBox, vars.COLORS.Border, 1)

vars.RenameTitle = Instance.new("TextLabel")
vars.RenameTitle.Size = UDim2.new(1, -24, 0, 28)
vars.RenameTitle.Position = UDim2.new(0, 12, 0, 10)
vars.RenameTitle.BackgroundTransparency = 1
vars.RenameTitle.Text = "RENAME AVATAR"
vars.RenameTitle.TextColor3 = vars.COLORS.Text
vars.RenameTitle.TextSize = 14
vars.RenameTitle.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.RenameTitle.TextXAlignment = Enum.TextXAlignment.Left
vars.RenameTitle.ZIndex = 72
vars.RenameTitle.Parent = vars.RenameBox

vars.RenameInput = Instance.new("TextBox")
vars.RenameInput.Name = "RenameInput"
vars.RenameInput.Size = UDim2.new(1, -24, 0, 38)
vars.RenameInput.Position = UDim2.new(0, 12, 0, 46)
vars.RenameInput.BackgroundColor3 = vars.COLORS.Surface2
vars.RenameInput.BorderSizePixel = 0
vars.RenameInput.TextColor3 = vars.COLORS.Text
vars.RenameInput.PlaceholderText = "Display Name"
vars.RenameInput.PlaceholderColor3 = vars.COLORS.Muted
vars.RenameInput.TextSize = 13
vars.RenameInput.FontFace = vars.uiFont(Enum.FontWeight.Medium)
vars.RenameInput.ClearTextOnFocus = false
vars.RenameInput.TextXAlignment = Enum.TextXAlignment.Left
vars.RenameInput.ZIndex = 72
vars.RenameInput.Parent = vars.RenameBox
vars.addPadding(vars.RenameInput, 4)
vars.addCorner(vars.RenameInput, 5)
vars.addStroke(vars.RenameInput, vars.COLORS.Border, 1)

vars.RenameCancel = vars.createButton(vars.RenameBox, "RenameCancel", "CANCEL", vars.COLORS.Surface3, Color3.fromRGB(46, 46, 49))
vars.RenameCancel.Size = UDim2.new(0, 110, 0, 30)
vars.RenameCancel.Position = UDim2.new(1, -236, 1, -42)
vars.RenameCancel.ZIndex = 72
vars.RenameSave = vars.createButton(vars.RenameBox, "RenameSave", "SAVE", Color3.fromRGB(130, 130, 130), Color3.fromRGB(90, 90, 90))
vars.RenameSave.Size = UDim2.new(0, 110, 0, 30)
vars.RenameSave.Position = UDim2.new(1, -122, 1, -42)
vars.RenameSave.ZIndex = 72

vars.RenameTarget = nil
vars.wire(vars.RenameCancel.Activated, function() vars.RenameOverlay.Visible = false vars.RenameTarget = nil end)
vars.wire(vars.RenameSave.Activated, function()
	local target = vars.RenameTarget
	local newName = tostring(vars.RenameInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if not target or newName == "" then return end

	if target.Source == "ava" then
		local ok, result = vars.renameAvatarFile(target, newName)
		if not ok then vars.showDiagnostics("Failed to rename avatar.", tostring(result)) return end
		vars.RenameOverlay.Visible = false
		vars.RenameTarget = nil
		vars.populateAvatarList()
		vars.Status.Text = "[OK] Renamed file to: " .. tostring(target.FileName)
		return
	end

	if target.Source == "legacy" then
		if type(writefile) ~= "function" then
			vars.showDiagnostics("Cannot rename avatar.", "The executor does not provide writefile().")
			return
		end
		local legacyList = {}
		for _, entry in ipairs(vars.ui.savedAvatars) do
			if entry == target then entry.DisplayName = newName end
			if entry.Source == "legacy" then
				local copy = {}
				for key, value in pairs(entry) do
					if key ~= "Source" and key ~= "FilePath" and not (key == "FileName" and value == "SavedAvatars.json") then
						copy[key] = value
					end
				end
				legacyList[#legacyList + 1] = copy
			end
		end
		local ok, err = pcall(function()
			writefile(vars.FILE_PATH, vars.HttpService:JSONEncode(legacyList))
		end)
		if not ok then vars.showDiagnostics("Failed to rename avatar.", tostring(err)) return end
		vars.RenameOverlay.Visible = false
		vars.RenameTarget = nil
		vars.populateAvatarList()
		vars.Status.Text = "[OK] Renamed legacy avatar to: " .. newName
		return
	end
end)

vars.SearchRow = Instance.new("Frame")
vars.SearchRow.Name = "SearchRow"
vars.SearchRow.Size = UDim2.new(1, -24, 0, 36)
vars.SearchRow.Position = UDim2.new(0, 12, 0, 54)
vars.SearchRow.BackgroundTransparency = 1
vars.SearchRow.Parent = vars.Main

vars.SearchBox = Instance.new("TextBox")
vars.SearchBox.Name = "SearchBox"
vars.SearchBox.Size = UDim2.new(1, -44, 1, 0)
vars.SearchBox.Position = UDim2.new(0, 0, 0, 0)
vars.SearchBox.BackgroundColor3 = vars.COLORS.Surface2
vars.SearchBox.BorderSizePixel = 0
vars.SearchBox.PlaceholderText = "Search Avatars..."
vars.SearchBox.PlaceholderColor3 = Color3.fromRGB(105, 105, 108)
vars.SearchBox.Text = ""
vars.SearchBox.TextColor3 = vars.COLORS.Text
vars.SearchBox.TextSize = 12
vars.SearchBox.FontFace = vars.uiFont(Enum.FontWeight.Regular)
vars.SearchBox.ClearTextOnFocus = false
vars.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
vars.SearchBox.Parent = vars.SearchRow
vars.addPadding(vars.SearchBox, 5)
vars.addCorner(vars.SearchBox, 9)
vars.addStroke(vars.SearchBox, vars.COLORS.Border, 1)

vars.RefreshButton = vars.createButton(vars.SearchRow, "RefreshButton", "", vars.COLORS.Surface3, Color3.fromRGB(52, 52, 55))
vars.RefreshButton.Size = UDim2.new(0, 38, 1, 0)
vars.RefreshButton.Position = UDim2.new(1, -38, 0, 0)
vars.RefreshButton.TextSize = 17
vars.RefreshButton.ZIndex = 5
vars.createBuilderIcon(vars.RefreshButton, "p", vars.BUILDER_ICONS.Refresh, 16, vars.COLORS.Muted).AnchorPoint = Vector2.new(0.5, 0.5)
vars.RefreshButton:FindFirstChild("p").Position = UDim2.new(0.5, 0, 0.5, 0)
vars.RefreshButton:FindFirstChild("p").ZIndex = 6

vars.List = Instance.new("ScrollingFrame")
vars.List.Name = "AvatarList"
vars.List.Size = UDim2.new(1, -24, 1, -148)
vars.List.Position = UDim2.new(0, 12, 0, 100)
vars.List.BackgroundTransparency = 1
vars.List.BorderSizePixel = 0
vars.List.ScrollBarThickness = 3
vars.List.ScrollBarImageColor3 = Color3.fromRGB(95, 95, 98)
vars.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
vars.List.ScrollingDirection = Enum.ScrollingDirection.Y
vars.List.Parent = vars.Main

vars.ListLayout = Instance.new("UIListLayout")
vars.ListLayout.Padding = UDim.new(0, 7)
vars.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
vars.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
vars.ListLayout.Parent = vars.List

vars.ListPadding = Instance.new("UIPadding")
vars.ListPadding.PaddingTop = UDim.new(0, 2)
vars.ListPadding.PaddingBottom = UDim.new(0, 4)
vars.ListPadding.Parent = vars.List

vars.SaveBar = Instance.new("Frame")
vars.SaveBar.Name = "SaveBar"
vars.SaveBar.Size = UDim2.new(1, -24, 0, 32)
vars.SaveBar.Position = UDim2.new(0, 12, 1, -44)
vars.SaveBar.BackgroundTransparency = 1
vars.SaveBar.Parent = vars.Main

vars.SaveSelfButton = Instance.new("TextButton")
vars.SaveSelfButton.Name = "SaveSelfButton"
vars.SaveSelfButton.Size = UDim2.new(0.20, -3, 1, 0)
vars.SaveSelfButton.Position = UDim2.new(0.38, 3, 0.075, 0)
vars.SaveSelfButton.BackgroundColor3 = vars.COLORS.Surface3
vars.SaveSelfButton.BorderSizePixel = 0
vars.SaveSelfButton.Text = "SAVE SELF"
vars.SaveSelfButton.TextColor3 = vars.COLORS.Text
vars.SaveSelfButton.TextSize = 12
vars.SaveSelfButton.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.SaveSelfButton.AutoButtonColor = false
vars.SaveSelfButton.Active = true
vars.SaveSelfButton.Selectable = true
vars.SaveSelfButton.Parent = vars.SaveBar
vars.addCorner(vars.SaveSelfButton, 6)
vars.addStroke(vars.SaveSelfButton, vars.COLORS.Border, 1, 0.15)

vars.UsernameBox = Instance.new("TextBox")
vars.UsernameBox.Name = "UsernameBox"
vars.UsernameBox.Size = UDim2.new(0.38, -3, 1, 0)
vars.UsernameBox.Position = UDim2.new(0, 0, 0.075, 0)
vars.UsernameBox.BackgroundColor3 = vars.COLORS.Surface3
vars.UsernameBox.BorderSizePixel = 0
vars.UsernameBox.Text = ""
vars.UsernameBox.PlaceholderText = "Username..."
vars.UsernameBox.PlaceholderColor3 = vars.COLORS.Muted
vars.UsernameBox.TextColor3 = vars.COLORS.Text
vars.UsernameBox.TextSize = 12
vars.UsernameBox.FontFace = vars.uiFont(Enum.FontWeight.Medium)
vars.UsernameBox.ClearTextOnFocus = false
vars.UsernameBox.TextXAlignment = Enum.TextXAlignment.Left
vars.UsernameBox.Parent = vars.SaveBar
vars.addPadding(vars.UsernameBox, 4)
vars.addCorner(vars.UsernameBox, 6)
vars.addStroke(vars.UsernameBox, vars.COLORS.Border, 1, 0.15)

vars.SaveClickedButton = Instance.new("TextButton")
vars.SaveClickedButton.Name = "SaveClickedButton"
vars.SaveClickedButton.Size = UDim2.new(0.20, -3, 1, 0)
vars.SaveClickedButton.Position = UDim2.new(0.58, 3, 0.075, 0)
vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Surface3
vars.SaveClickedButton.BorderSizePixel = 0
vars.SaveClickedButton.Text = "SAVE OTHER"
vars.SaveClickedButton.TextColor3 = vars.COLORS.Text
vars.SaveClickedButton.TextSize = 12
vars.SaveClickedButton.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.SaveClickedButton.AutoButtonColor = false
vars.SaveClickedButton.Active = true
vars.SaveClickedButton.Selectable = true
vars.SaveClickedButton.Parent = vars.SaveBar
vars.addCorner(vars.SaveClickedButton, 6)
vars.addStroke(vars.SaveClickedButton, vars.COLORS.Border, 1, 0.15)

vars.PlaceholderToggle = Instance.new("TextButton")
vars.PlaceholderToggle.Name = "Placeholder"
vars.PlaceholderToggle.Size = UDim2.new(0.22, -3, 1, 0)
vars.PlaceholderToggle.Position = UDim2.new(0.78, 3, 0.075, 0)
vars.PlaceholderToggle.BackgroundColor3 = vars.COLORS.Surface3
vars.PlaceholderToggle.BorderSizePixel = 0
vars.PlaceholderToggle.Text = "CHANGE METHOD"
vars.PlaceholderToggle.TextColor3 = vars.COLORS.Muted
vars.PlaceholderToggle.TextSize = 10
vars.PlaceholderToggle.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.PlaceholderToggle.AutoButtonColor = false
vars.PlaceholderToggle.Active = true
vars.PlaceholderToggle.Selectable = true
vars.PlaceholderToggle.Parent = vars.SaveBar
vars.addCorner(vars.PlaceholderToggle, 6)
vars.addStroke(vars.PlaceholderToggle, vars.COLORS.Border, 1, 0.15)

vars.Footer = Instance.new("Frame")
vars.Footer.Name = "Footer"
vars.Footer.Size = UDim2.fromOffset(0, 0)
vars.Footer.Position = UDim2.fromOffset(0, 0)
vars.Footer.BackgroundTransparency = 1
vars.Footer.Visible = false
vars.Footer.Parent = vars.Main

vars.StatusDot = Instance.new("Frame")
vars.StatusDot.Name = "StatusDot"
vars.StatusDot.Size = UDim2.fromOffset(0, 0)
vars.StatusDot.Visible = false
vars.StatusDot.Parent = vars.Footer

vars.Status = Instance.new("TextLabel")
vars.Status.Name = "Status"
vars.Status.Size = UDim2.fromOffset(0, 0)
vars.Status.Visible = false
vars.Status.Text = "Initializing..."
vars.Status.Parent = vars.Footer

vars.WearButton = Instance.new("TextButton")
vars.WearButton.Name = "WearButton"
vars.WearButton.Size = UDim2.fromOffset(0, 0)
vars.WearButton.Visible = false
vars.WearButton.Text = "TRY ON"
vars.WearButton.Parent = vars.Footer

vars.updateWearButtonState = function()
	
end

vars.ErrorPopup = Instance.new("Frame")
vars.ErrorPopup.Name = "WearDiagnostics"
vars.ErrorPopup.Size = UDim2.new(0.88, 0, 0, 168)
vars.ErrorPopup.Position = UDim2.new(0.06, 0, 0.5, -84)
vars.ErrorPopup.BackgroundColor3 = Color3.fromRGB(24, 17, 23)
vars.ErrorPopup.BorderSizePixel = 0
vars.ErrorPopup.Visible = false
vars.ErrorPopup.ZIndex = 60
vars.ErrorPopup.Parent = vars.Main
vars.addCorner(vars.ErrorPopup, 12)
vars.addStroke(vars.ErrorPopup, Color3.fromRGB(126, 57, 74), 1)

vars.ErrorTitle = Instance.new("TextLabel")
vars.ErrorTitle.Name = "ErrorTitle"
vars.ErrorTitle.Size = UDim2.new(1, -44, 0, 28)
vars.ErrorTitle.Position = UDim2.new(0, 12, 0, 6)
vars.ErrorTitle.BackgroundTransparency = 1
vars.ErrorTitle.Text = "error or warning stuff"
vars.ErrorTitle.TextColor3 = Color3.fromRGB(255, 128, 148)
vars.ErrorTitle.TextSize = 12
vars.ErrorTitle.FontFace = vars.uiFont(vars.UI_WEIGHT)
vars.ErrorTitle.TextXAlignment = Enum.TextXAlignment.Left
vars.ErrorTitle.ZIndex = 61
vars.ErrorTitle.Parent = vars.ErrorPopup
vars.addPadding(vars.ErrorTitle, 1)

vars.ErrorCloseBtn = vars.createButton(vars.ErrorPopup, "ErrorClose", "X", Color3.fromRGB(60, 29, 38), Color3.fromRGB(90, 40, 52))
vars.ErrorCloseBtn.Size = UDim2.new(0, 24, 0, 24)
vars.ErrorCloseBtn.Position = UDim2.new(1, -31, 0, 8)
vars.ErrorCloseBtn.TextSize = 15
vars.ErrorCloseBtn.ZIndex = 62

vars.ErrorScroll = Instance.new("ScrollingFrame")
vars.ErrorScroll.Name = "ErrorScroll"
vars.ErrorScroll.Size = UDim2.new(1, -20, 1, -44)
vars.ErrorScroll.Position = UDim2.new(0, 10, 0, 38)
vars.ErrorScroll.BackgroundTransparency = 1
vars.ErrorScroll.BorderSizePixel = 0
vars.ErrorScroll.ScrollBarThickness = 3
vars.ErrorScroll.ScrollBarImageColor3 = Color3.fromRGB(160, 80, 95)
vars.ErrorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
vars.ErrorScroll.ZIndex = 61
vars.ErrorScroll.Parent = vars.ErrorPopup

vars.ErrorText = Instance.new("TextLabel")
vars.ErrorText.Name = "FullError"
vars.ErrorText.Size = UDim2.new(1, -6, 0, 0)
vars.ErrorText.AutomaticSize = Enum.AutomaticSize.Y
vars.ErrorText.BackgroundTransparency = 1
vars.ErrorText.Text = ""
vars.ErrorText.TextColor3 = Color3.fromRGB(255, 210, 220)
vars.ErrorText.TextSize = 11
vars.ErrorText.Font = Enum.Font.Code
vars.ErrorText.TextWrapped = true
vars.ErrorText.TextXAlignment = Enum.TextXAlignment.Left
vars.ErrorText.TextYAlignment = Enum.TextYAlignment.Top
vars.ErrorText.ZIndex = 62
vars.ErrorText.Parent = vars.ErrorScroll
vars.addPadding(vars.ErrorText, 1)

vars.wire(vars.ErrorCloseBtn.Activated, function() vars.ErrorPopup.Visible = false end)

vars.clearDiagnostics = function()	vars.ErrorPopup.Visible = false
	vars.ErrorText.Text = ""
	vars.ErrorScroll.CanvasPosition = Vector2.zero
end

vars.showDiagnostics = function(summary, detail)	vars.Status.Text = tostring(summary or "Wear failed.")
	vars.ErrorText.Text = tostring(detail or "No additional error text was returned.")
	vars.ErrorPopup.Visible = true
	task.defer(function()
		if vars.ErrorScroll.Parent then vars.ErrorScroll.CanvasPosition = Vector2.zero end
	end)
end

vars.SEATED_TRY_ON_BLOCK_MESSAGE = "Please wear avatars while standing still. Cannot wear avatars while sitting at the moment because of the avatar placement glitch similar to wearing while flying and wearing while doing a forward/backward swim. The bug/glitch is under maintenance and is fixing right away. Thank you for understanding.\n\nKnightingale."

vars.isCharacterCurrentlySitting = function(character, humanoid)	humanoid = humanoid or (character and character:FindFirstChildOfClass("Humanoid"))
	if not humanoid then return false end

	local state = humanoid:GetState()
	return humanoid.Sit
		or humanoid.SeatPart ~= nil
		or state == Enum.HumanoidStateType.Seated
end

vars.showSeatedTryOnBlocked = function()	vars.showDiagnostics("[!] Cannot wear avatars while sitting.", vars.SEATED_TRY_ON_BLOCK_MESSAGE)
end

vars.accessoryPropertyNames = {
	"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
	"ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
	"JacketAccessory", "ShortsAccessory", "SweaterAccessory", "TShirtAccessory",
	"PantsAccessory", "ShoesAccessory", "DressSkirtAccessory", "EyelashAccessory",
	"EyebrowAccessory", "MoodAccessory"
}

vars.rgbForSave = function(color)
	if not color then return {r = 255, g = 255, b = 255} end
	return {
		r = math.floor(color.R * 255 + 0.5),
		g = math.floor(color.G * 255 + 0.5),
		b = math.floor(color.B * 255 + 0.5)
	}
end

vars.vectorForSave = function(value, fallback)
	fallback = fallback or Vector3.zero
	if typeof(value) == "Vector3" then
		return {X = value.X, Y = value.Y, Z = value.Z}
	end
	if type(value) == "table" then
		return {
			X = tonumber(value.X or value.x) or fallback.X,
			Y = tonumber(value.Y or value.y) or fallback.Y,
			Z = tonumber(value.Z or value.z) or fallback.Z
		}
	end
	return {X = fallback.X, Y = fallback.Y, Z = fallback.Z}
end

vars.getSavedHeadShape = function(desc)
	local shape = ""
	pcall(function()
		for _, child in ipairs(desc:GetChildren()) do
			if child:IsA("BodyPartDescription") and child.BodyPart == Enum.BodyPart.Head then
				local value = tostring(child.HeadShape or "")
				if value ~= "" then shape = value break end
			end
		end
	end)
	return shape
end

vars.getSavedMakeups = function(desc)
	local result, seen = {}, {}
	local function addMakeup(makeup)
		if not makeup then return end
		local assetId = tonumber(makeup.AssetId)
		if not assetId or assetId <= 0 then return end
		local makeupType = makeup.MakeupType
		local typeName = makeupType and makeupType.Name or tostring(makeupType or "")
		local order = tonumber(makeup.Order) or 1
		local key = tostring(assetId) .. "|" .. typeName .. "|" .. tostring(order)
		if seen[key] then return end
		seen[key] = true
		result[#result + 1] = {Order = order, AssetId = assetId, MakeupType = typeName}
	end
	pcall(function()
		for _, child in ipairs(desc:GetChildren()) do
			if child:IsA("MakeupDescription") then addMakeup(child) end
		end
	end)
	pcall(function()
		if #result == 0 and type(desc.GetMakeups) == "function" then
			for _, makeup in ipairs(desc:GetMakeups()) do addMakeup(makeup) end
		end
	end)
	return result
end

vars.getSavedLayeredAccessories = function(desc)
	local result = {}
	pcall(function()
		if type(desc.GetAccessories) ~= "function" then return end
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			if accessory.IsLayered then
				result[#result + 1] = {
					Rotation = vars.vectorForSave(accessory.Rotation),
					AssetId = accessory.AssetId,
					AccessoryType = accessory.AccessoryType and accessory.AccessoryType.Name or "Unknown",
					Position = vars.vectorForSave(accessory.Position),
					Order = accessory.Order or 1,
					IsLayered = true,
					Puffiness = accessory.Puffiness or 0.5,
					Scale = vars.vectorForSave(accessory.Scale, Vector3.one)
				}
			end
		end
	end)
	return result
end

vars.getSavedAccessoryRefinements = function(desc, character)
	local refinements = {}
	pcall(function()
		if character then
			local raw = character:GetAttribute("AccessoryRefinements") or desc:GetAttribute("AccessoryRefinements")
			if raw then
				local decoded = type(raw) == "string" and vars.HttpService:JSONDecode(raw) or raw
				if type(decoded) == "table" then
					for id, value in pairs(decoded) do refinements[tostring(id)] = value end
				end
			end
		end
	end)
	pcall(function()
		if type(desc.GetAccessories) ~= "function" then return end
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			local id = tostring(accessory.AssetId or 0)
			if id ~= "0" then
				local pos = accessory.Position
				local scale = accessory.Scale
				local rot = accessory.Rotation
				local hasPos = pos and pos.Magnitude > 0.0001
				local hasScale = scale and (math.abs(scale.X - 1) > 0.0001 or math.abs(scale.Y - 1) > 0.0001 or math.abs(scale.Z - 1) > 0.0001)
				local hasRot = rot and rot.Magnitude > 0.0001
				if hasPos or hasScale or hasRot then
					local ref = type(refinements[id]) == "table" and refinements[id] or {}
					if hasPos then ref.Position = vars.vectorForSave(pos) end
					if hasScale then ref.Scale = vars.vectorForSave(scale, Vector3.one) end
					if hasRot then ref.Rotation = vars.vectorForSave(rot) end
					refinements[id] = ref
				end
			end
		end
	end)
	return refinements
end

vars.createCopiedProperties = function(desc, character)
	if not desc then return nil end
	local categories = {
		"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory",
		"FrontAccessory", "BackAccessory", "WaistAccessory", "JacketAccessory", "ShortsAccessory",
		"SweaterAccessory", "TShirtAccessory", "PantsAccessory", "ShoesAccessory", "DressSkirtAccessory",
		"EyelashAccessory", "EyebrowAccessory", "MoodAccessory"
	}
	local accLists = {}
	for _, category in ipairs(categories) do accLists[category] = {} end
	local function add(category, id)
		if not accLists[category] then return end
		id = tostring(id or "")
		if id ~= "" and id ~= "0" and not table.find(accLists[category], id) then table.insert(accLists[category], id) end
	end
	for _, category in ipairs(categories) do
		pcall(function()
			for id in tostring(desc[category] or ""):gmatch("%d+") do add(category, id) end
		end)
	end
	pcall(function()
		if type(desc.GetAccessories) == "function" then
			local typeToCategory = {
				[Enum.AccessoryType.Hat] = "HatAccessory", [Enum.AccessoryType.Hair] = "HairAccessory",
				[Enum.AccessoryType.Face] = "FaceAccessory", [Enum.AccessoryType.Neck] = "NeckAccessory",
				[Enum.AccessoryType.Shoulder] = "ShouldersAccessory", [Enum.AccessoryType.Front] = "FrontAccessory",
				[Enum.AccessoryType.Back] = "BackAccessory", [Enum.AccessoryType.Waist] = "WaistAccessory",
				[Enum.AccessoryType.TShirt] = "TShirtAccessory", [Enum.AccessoryType.Shirt] = "ShirtAccessory",
				[Enum.AccessoryType.Pants] = "PantsAccessory", [Enum.AccessoryType.Jacket] = "JacketAccessory",
				[Enum.AccessoryType.Sweater] = "SweaterAccessory", [Enum.AccessoryType.Shorts] = "ShortsAccessory",
				[Enum.AccessoryType.LeftShoe] = "ShoesAccessory", [Enum.AccessoryType.RightShoe] = "ShoesAccessory",
				[Enum.AccessoryType.DressSkirt] = "DressSkirtAccessory", [Enum.AccessoryType.Eyebrow] = "EyebrowAccessory",
				[Enum.AccessoryType.Eyelash] = "EyelashAccessory"
			}
			for _, accessory in ipairs(desc:GetAccessories(true)) do
				if not accessory.IsLayered then
					local category = typeToCategory[accessory.AccessoryType]
					if category then add(category, accessory.AssetId) end
				end
			end
		end
	end)
	local props = {
		WalkAnimation = desc.WalkAnimation or 0, MoodAnimation = desc.MoodAnimation or 0,
		ClimbAnimation = desc.ClimbAnimation or 0, FallAnimation = desc.FallAnimation or 0,
		RunAnimation = desc.RunAnimation or 0, SwimAnimation = desc.SwimAnimation or 0,
		IdleAnimation = desc.IdleAnimation or 0, JumpAnimation = desc.JumpAnimation or 0,
		Face = desc.Face or 0, Shirt = desc.Shirt or 0, Pants = desc.Pants or 0, GraphicTShirt = desc.GraphicTShirt or 0,
		RightArmColor = vars.rgbForSave(desc.RightArmColor), TorsoColor = vars.rgbForSave(desc.TorsoColor),
		RightLegColor = vars.rgbForSave(desc.RightLegColor), LeftLegColor = vars.rgbForSave(desc.LeftLegColor),
		LeftArmColor = vars.rgbForSave(desc.LeftArmColor), HeadColor = vars.rgbForSave(desc.HeadColor),
		Head = desc.Head or 0, Torso = desc.Torso or 0, LeftArm = desc.LeftArm or 0, RightArm = desc.RightArm or 0,
		LeftLeg = desc.LeftLeg or 0, RightLeg = desc.RightLeg or 0, HeadShape = vars.getSavedHeadShape(desc),
		MakeupItems = vars.getSavedMakeups(desc), ProportionScale = desc.ProportionScale or 0, DepthScale = desc.DepthScale or 1,
		HeightScale = desc.HeightScale or 1, WidthScale = desc.WidthScale or 1, BodyTypeScale = desc.BodyTypeScale or 0,
		HeadScale = desc.HeadScale or 1, LayeredAccessories = vars.getSavedLayeredAccessories(desc),
		AccessoryRefinements = vars.getSavedAccessoryRefinements(desc, character), StaticFacialAnimation = false
	}
	for _, category in ipairs(categories) do props[category] = table.concat(accLists[category], ",") end
	pcall(function() props.StaticFacialAnimation = desc.StaticFacialAnimation == true end)
	pcall(function()
		local all = {}
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			local entry = {AssetId = accessory.AssetId, AccessoryType = accessory.AccessoryType and accessory.AccessoryType.Name or "Unknown", IsLayered = accessory.IsLayered == true}
			if accessory.Order ~= nil then entry.Order = accessory.Order end
			if accessory.Puffiness ~= nil then entry.Puffiness = accessory.Puffiness end
			all[#all + 1] = entry
		end
		props.AllAccessories = all
	end)
	pcall(function() if type(desc.GetEmotes) == "function" then props.Emotes = desc:GetEmotes() end end)
	pcall(function() if type(desc.GetEquippedEmotes) == "function" then props.EquippedEmotes = desc:GetEquippedEmotes() end end)
	return props
end

vars.getAvatarSignature = function(properties, rigType)
	local ok, result = pcall(function()
		return vars.HttpService:JSONEncode({Properties = properties, RigType = tostring(rigType)})
	end)
	return ok and result or tostring(properties)
end

vars.ensureAvatarFolder = function()
	if type(makefolder) ~= "function" then return false end
	if type(isfolder) ~= "function" then return false end
	local ok = pcall(function() if not isfolder(vars.AVATARS_FOLDER) then makefolder(vars.AVATARS_FOLDER) end end)
	return ok
end

vars.getAvatarFilePath = function(index)
	return vars.AVATARS_FOLDER .. "/" .. vars.AVATAR_FILE_PREFIX .. tostring(index) .. vars.AVATAR_FILE_EXTENSION
end

vars.getNextAvatarFilePath = function(displayName)
	vars.ensureAvatarFolder()
	if type(isfile) ~= "function" then return nil end

	local baseName = vars.sanitizeAvatarFileName(displayName or "Avatar")
	if not baseName then return nil end
	baseName = baseName:sub(1, -5)

	for index = 1, 10000 do
		local candidateName = baseName
		if index > 1 then
			candidateName = baseName .. tostring(index)
		end
		local path = vars.AVATARS_FOLDER .. "/" .. candidateName .. vars.AVATAR_FILE_EXTENSION
		local exists = false
		pcall(function() exists = isfile(path) end)
		if not exists then return path end
	end
	return nil
end

vars.readAvatarFiles = function()
	local result = {}
	if type(readfile) ~= "function" then return result end
	vars.ensureAvatarFolder()
	local paths = {}
	if type(listfiles) == "function" then
		pcall(function()
			for _, path in ipairs(listfiles(vars.AVATARS_FOLDER)) do
				if tostring(path):lower():match("%.ava$") then paths[#paths + 1] = path end
			end
		end)
	end
	if #paths == 0 and type(isfile) == "function" then
		for index = 1, 10000 do
			local path = vars.getAvatarFilePath(index)
			local exists = false
			pcall(function() exists = isfile(path) end)
			if exists then paths[#paths + 1] = path end
		end
	end
	table.sort(paths, function(a, b)
		return tostring(a):lower() < tostring(b):lower()
	end)
	for _, path in ipairs(paths) do
		local ok, data = pcall(function() return vars.HttpService:JSONDecode(readfile(path)) end)
		if ok and type(data) == "table" and type(data.Properties) == "table" then
			data.FileName = data.FileName or tostring(path):match("([^/\\]+)$")
			data.Source = "ava"
			result[#result + 1] = data
		end
	end
	return result
end

vars.writeAvatarFile = function(data)
	if type(writefile) ~= "function" then return false, "The executor does not provide writefile()." end
	vars.ensureAvatarFolder()
	local path = data.FilePath or vars.getNextAvatarFilePath(data.DisplayName or data.Name)
	if not path then return false, "No free avatar filename was found." end
	data.FilePath = path
	data.FileName = tostring(path):match("([^/\\]+)$") or path
	data.Source = "ava"
	local ok, err = pcall(function() writefile(path, vars.HttpService:JSONEncode(data)) end)
	if not ok then return false, tostring(err) end
	return true, path
end

vars.sanitizeAvatarFileName = function(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[<>:\"/\\|%?%*]", "-")
	name = name:gsub("[%. ]+$", "")
	if name == "" then return nil end
	if name:lower():sub(-4) == ".ava" then name = name:sub(1, -5) end
	if name == "" then return nil end
	return name .. ".ava"
end

vars.renameAvatarFile = function(data, newName)
	if not data or data.Source ~= "ava" then
		return false, "This is not a .ava avatar file."
	end
	if type(writefile) ~= "function" or type(isfile) ~= "function" or type(delfile) ~= "function" then
		return false, "The executor must provide writefile(), isfile(), and delfile()."
	end
	local fileName = vars.sanitizeAvatarFileName(newName)
	if not fileName then return false, "The filename is empty or invalid." end
	vars.ensureAvatarFolder()
	local oldPath = data.FilePath
	if not oldPath and data.FileName then oldPath = vars.AVATARS_FOLDER .. "/" .. tostring(data.FileName) end
	if not oldPath then return false, "The avatar file path is unavailable." end
	local newPath = vars.AVATARS_FOLDER .. "/" .. fileName

	if oldPath:lower() ~= newPath:lower() then
		local exists = false
		pcall(function() exists = isfile(newPath) end)
		if exists then return false, "An avatar with that filename already exists." end
	end

	local displayName = tostring(newName):gsub("^%s+", ""):gsub("%s+$", "")
	local rewritten = {}
	for key, value in pairs(data) do rewritten[key] = value end
	rewritten.FilePath = newPath
	rewritten.FileName = fileName
	rewritten.DisplayName = displayName
	rewritten.Source = "ava"

	local encodedOk, encoded = pcall(function()
		return vars.HttpService:JSONEncode(rewritten)
	end)
	if not encodedOk then return false, tostring(encoded) end

	
	
	local wroteNew, writeErr = pcall(function() writefile(newPath, encoded) end)
	if not wroteNew then return false, tostring(writeErr) end

	if oldPath:lower() ~= newPath:lower() then
		local deletedOld, deleteErr = pcall(function() delfile(oldPath) end)
		if not deletedOld then
			
			pcall(function() delfile(newPath) end)
			return false, tostring(deleteErr)
		end
	end

	for key, value in pairs(rewritten) do data[key] = value end
	return true, newPath
end

vars.buildSavedAvatarData = function(player)
	if not player or not player.Character then return nil, "Player character is unavailable." end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil, "Humanoid is unavailable." end
	local ok, desc = pcall(function() return humanoid:GetAppliedDescription() end)
	if not ok or not desc then return nil, "Could not read the currently applied avatar." end
	local properties = vars.createCopiedProperties(desc, player.Character)
	if type(properties) ~= "table" then return nil, "Could not serialize the avatar." end
	local rigType = humanoid.RigType
	local data = {
		Name = player.Name,
		UserId = player.UserId,
		DisplayName = player.DisplayName,
		Properties = properties,
		RigType = (rigType == Enum.HumanoidRigType.R6) and "R6" or "R15",
		Signature = vars.getAvatarSignature(properties, rigType),
		Order = 1
	}
	return data
end

vars.notifyCatalogAvatarCreator = function()
	if not vars.IS_CATALOG_AVATAR_CREATOR then return end
	local payload = {
		Title = "Avatar Thingy",
		Text = "You are in Catalog Avatar Creator, therefore your avatars will be FE and will be saved to \"Saved Outfits\"",
		Duration = 8
	}
	task.spawn(function()
		for _ = 1, 12 do
			if not vars.scriptAlive then return end
			local ok = pcall(function()
				vars.StarterGui:SetCore("SendNotification", payload)
			end)
			if ok then return end
			task.wait(0.5)
		end
	end)
end

vars.getCatalogWearRemotes = function()
	if not vars.IS_CATALOG_AVATAR_CREATOR then return nil, nil end
	if not vars.CATALOG_EVENTS or not vars.CATALOG_EVENTS.Parent then
		vars.CATALOG_EVENTS = vars.ReplicatedStorage:FindFirstChild("Events")
	end
	vars.CATALOG_GUI_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("CatalogGuiRemote")
	vars.SAVED_OUTFITS_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("SavedOutfitsRemote")
	return vars.CATALOG_GUI_REMOTE, vars.SAVED_OUTFITS_REMOTE
end

vars.wearAvatarThroughCatalog = function(data)
	if not vars.IS_CATALOG_AVATAR_CREATOR then return false, "Not in Catalog Avatar Creator." end
	if not data or type(data.Properties) ~= "table" then return false, "Avatar has no saved properties." end
	local catalogGuiRemote = vars.getCatalogWearRemotes()
	if not catalogGuiRemote then return false, "CatalogGuiRemote was not found." end

	local rigTypeEnum = (tostring(data.RigType):find("R6") and Enum.HumanoidRigType.R6) or Enum.HumanoidRigType.R15
	local cleanProps = {}
	for key, value in pairs(data.Properties) do
		if key ~= "Emotes" and key ~= "EquippedEmotes" and key ~= "AllAccessories" then
			cleanProps[key] = value
		end
	end

	local payload = {
		Properties = cleanProps,
		Action = "CreateAndWearHumanoidDescription",
		RigType = rigTypeEnum
	}
	local ok, result = pcall(function()
		return catalogGuiRemote:InvokeServer(payload)
	end)
	if not ok then return false, tostring(result) end
	return true, result
end

vars.saveAvatarToCatalogOutfit = function(data)
	if not vars.IS_CATALOG_AVATAR_CREATOR then return false, "Not in Catalog Avatar Creator." end
	if not data or not data.Properties then return false, "Avatar has no saved properties." end
	local _, savedOutfitsRemote = vars.getCatalogWearRemotes()
	if not savedOutfitsRemote then return false, "SavedOutfitsRemote was not found." end

	local okWear, wearErr = vars.wearAvatarThroughCatalog(data)
	if not okWear then return false, wearErr end

	local username = tostring(data.Name or data.Username or "Unknown")
	local outfitName = "Avatar Saver: " .. username
	local ok, result = pcall(function()
		return savedOutfitsRemote:InvokeServer({
			OutfitName = outfitName,
			Configs = {},
			Action = "CreateNewOutfit"
		})
	end)
	if not ok then return false, tostring(result) end
	return true, outfitName, result
end

vars.notifyCatalogAvatarCreator()

vars.buildSavedAvatarDataFromUsername = function(username)
	username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", "")
	username = username:gsub("^@", "")
	if username == "" then return nil, "Enter a Roblox username first." end

	local okId, userId = pcall(function()
		return vars.Players:GetUserIdFromNameAsync(username)
	end)
	if not okId or not userId then
		return nil, "Could not find Roblox user @" .. username .. "."
	end

	local desc
	local descOk, descResult = pcall(function()
		if type(vars.Players.GetHumanoidDescriptionFromUserIdAsync) == "function" then
			return vars.Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end
		return vars.Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not descOk or not descResult then
		return nil, "Could not load the profile avatar for @" .. username .. "."
	end
	desc = descResult

	local properties = vars.createCopiedProperties(desc, nil)
	if type(properties) ~= "table" then
		return nil, "Could not serialize the profile avatar for @" .. username .. "."
	end

	local localHumanoid = vars.LocalPlayer.Character and vars.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local rigType = localHumanoid and localHumanoid.RigType or Enum.HumanoidRigType.R6
	local displayName = username
	pcall(function()
		local fetchedPlayer = vars.Players:GetPlayerByUserId(userId)
		if fetchedPlayer then displayName = fetchedPlayer.DisplayName end
	end)

	local data = {
		Name = username,
		Username = username,
		UserId = userId,
		DisplayName = displayName,
		Properties = properties,
		RigType = (rigType == Enum.HumanoidRigType.R6) and "R6" or "R15",
		Signature = vars.getAvatarSignature(properties, rigType),
		Order = 1
	}
	return data
end

vars.findExactSavedAvatarMatch = function(data)
	if type(data) ~= "table" then return nil end
	local targetSignature = data.Signature
	if not targetSignature and data.Properties then
		targetSignature = vars.getAvatarSignature(data.Properties, data.RigType or "R6")
	end
	for _, existing in ipairs(vars.ui.savedAvatars or {}) do
		local existingSignature = existing.Signature
		if not existingSignature and existing.Properties then
			existingSignature = vars.getAvatarSignature(existing.Properties, existing.RigType or "R6")
			existing.Signature = existingSignature
		end
		if targetSignature and existingSignature and targetSignature == existingSignature then
			return existing
		end
	end
	return nil
end

vars.saveAndWearUsernameAvatar = function(rawUsername)
	local username = tostring(rawUsername or ""):gsub("^%s+", ""):gsub("%s+$", "")
	username = username:gsub("^@", "")
	if username == "" then
		return false, "Enter a Roblox username first."
	end

	if vars.ui.selectingPlayer then vars.stopPlayerSelection() end
	if vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
	end
	vars.ui.selectedAvatar = nil
	vars.updateRowVisuals(nil)

	local data, buildErr = vars.buildSavedAvatarDataFromUsername(username)
	if not data then return false, buildErr end

	-- Exact 1:1 duplicate check. Never create a second file/outfit for an identical avatar.
	local existingMatch = vars.findExactSavedAvatarMatch(data)
	if existingMatch then
		data = existingMatch
		vars.ui.selectedAvatar = data
		vars.populateAvatarList()
		vars.updateRowVisuals(data)

		if vars.IS_CATALOG_AVATAR_CREATOR then
			local wearOk, wearErr = vars.wearAvatarThroughCatalog(data)
			if not wearOk then
				vars.showDiagnostics("Existing avatar could not be equipped.", tostring(wearErr))
				return false, wearErr
			end
			vars.Status.Text = "[FE] Already saved — equipped existing avatar: " .. tostring(data.Name or data.Username or username)
		else
			vars.Status.Text = "[OK] Already saved — equipped existing avatar: " .. tostring(data.Name or data.Username or username)
			task.defer(function()
				if vars.scriptAlive and vars.ui.selectedAvatar == data then
					vars.tryOnSelectedAvatarLocally()
				end
			end)
		end
		vars.clearDiagnostics()
		return true, data
	end

	local isNewFile = data.Source ~= "ava" or not data.FilePath
	if isNewFile then
		local okWrite, pathOrErr = vars.writeAvatarFile(data)
		if not okWrite then return false, pathOrErr end
		data.FilePath = pathOrErr
		data.FileName = tostring(pathOrErr):match("([^/\\]+)$") or pathOrErr
		data.Source = "ava"
		vars.ui.savedAvatars = vars.ui.savedAvatars or {}
		table.insert(vars.ui.savedAvatars, 1, data)
	end

	vars.ui.selectedAvatar = data
	vars.populateAvatarList()
	vars.updateRowVisuals(data)

	if vars.IS_CATALOG_AVATAR_CREATOR then
		local catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(data)
		if not catalogOk then
			vars.showDiagnostics("CAC avatar save/wear failed.", tostring(catalogErr))
			return false, catalogErr
		end
		vars.Status.Text = "[FE] Wore @" .. username .. " and saved to Saved Outfits as " .. tostring(catalogName)
		vars.clearDiagnostics()
		return true, data
	end

	vars.Status.Text = "[...] Wearing profile avatar: @" .. username
	vars.clearDiagnostics()
	task.defer(function()
		if vars.scriptAlive and vars.ui.selectedAvatar == data then
			vars.tryOnSelectedAvatarLocally()
		end
	end)
	return true, data
end

vars.savePlayerAvatar = function(player)
	local data, err = vars.buildSavedAvatarData(player)
	if not data then return false, err end
	if vars.findExactSavedAvatarMatch(data) then
		return false, "you already have that exact avatar"
	end
	local ok, pathOrErr = vars.writeAvatarFile(data)
	if not ok then return false, pathOrErr end
	data.FilePath = pathOrErr
	data.FileName = tostring(pathOrErr):match("([^/\\]+)$") or pathOrErr
	vars.ui.savedAvatars = vars.ui.savedAvatars or {}
	table.insert(vars.ui.savedAvatars, 1, data)
	vars.ui.selectedAvatar = data
	return true, data
end

vars.stopPlayerSelection = function()
	vars.ui.selectingPlayer = false
	vars.ui.selectionPlayer = nil
	if vars.ui.selectionHighlight then
		pcall(function() vars.ui.selectionHighlight:Destroy() end)
		vars.ui.selectionHighlight = nil
	end
	if vars.SaveClickedButton then
		vars.SaveClickedButton.Text = "SAVE OTHER"
		vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Surface3
	end
end

vars.setPlayerSelectionHighlight = function(player)
	if not player or player == vars.LocalPlayer or not player.Character then
		if vars.ui.selectionHighlight then pcall(function() vars.ui.selectionHighlight:Destroy() end) vars.ui.selectionHighlight = nil end
		vars.ui.selectionPlayer = nil
		return
	end
	if vars.ui.selectionPlayer == player and vars.ui.selectionHighlight and vars.ui.selectionHighlight.Parent then return end
	if vars.ui.selectionHighlight then pcall(function() vars.ui.selectionHighlight:Destroy() end) end
	local highlight = Instance.new("Highlight")
	highlight.Name = "AvatarSaveSelectionHighlight"
	highlight.Adornee = player.Character
	highlight.FillColor = vars.COLORS.Accent
	highlight.FillTransparency = 0.72
	highlight.OutlineColor = vars.COLORS.AccentHover
	highlight.OutlineTransparency = 0.05
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = vars.ScreenGui
	vars.ui.selectionHighlight = highlight
	vars.ui.selectionPlayer = player
end

vars.getPlayerFromScreenPosition = function(position)
	local camera = vars.Workspace.CurrentCamera
	if not camera then return nil end
	local ray = camera:ScreenPointToRay(position.X, position.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {vars.LocalPlayer.Character}
	local result = vars.Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	local target = result and result.Instance
	if not target then return nil end
	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local player = vars.Players:GetPlayerFromCharacter(model)
	return (player and player ~= vars.LocalPlayer) and player or nil
end

vars.getPlayerFromMouseTarget = function()
	local mouse = vars.LocalPlayer:GetMouse()
	if not mouse then return nil end
	return vars.getPlayerFromScreenPosition(Vector2.new(mouse.X, mouse.Y))
end

vars.loadSavedAvatars = function()
	local previousSignature = vars.ui.selectedAvatar and vars.ui.selectedAvatar.Signature
	local previousName = vars.ui.selectedAvatar and vars.ui.selectedAvatar.Name
	table.clear(vars.ui.savedAvatars)
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		vars.Status.Text = "[!] File API unavailable."
		return false
	end

	local loaded = 0
	for _, data in ipairs(vars.readAvatarFiles()) do
		vars.ui.savedAvatars[#vars.ui.savedAvatars + 1] = data
		loaded += 1
	end

	
	
	local exists, legacyExists = pcall(isfile, vars.FILE_PATH)
	if exists and legacyExists then
		local ok, result = pcall(function() return vars.HttpService:JSONDecode(readfile(vars.FILE_PATH)) end)
		if ok and type(result) == "table" then
			for _, data in ipairs(result) do
				if type(data) == "table" and type(data.Properties) == "table" then
					local duplicate = false
					if data.Signature then
						for _, current in ipairs(vars.ui.savedAvatars) do
							if current.Signature == data.Signature then duplicate = true break end
						end
					end
					if not duplicate then
						data.Source = "legacy"
						data.FileName = data.FileName or "SavedAvatars.json"
						vars.ui.savedAvatars[#vars.ui.savedAvatars + 1] = data
						loaded += 1
					end
				end
			end
		end
	end

	if previousSignature or previousName then
		vars.ui.selectedAvatar = nil
		for _, data in ipairs(vars.ui.savedAvatars) do
			if (previousSignature and data.Signature == previousSignature) or (not previousSignature and previousName and data.Name == previousName) then
				vars.ui.selectedAvatar = data
				break
			end
		end
	end
	vars.Status.Text = "[File] " .. tostring(loaded) .. " avatar(s) loaded."
	vars.clearDiagnostics()
	return true
end

vars.applyBodyColors = function(character, props)	if not character or type(props) ~= "table" then return end
	local bodyColors = character:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
	bodyColors.Parent = character
	local colorProps = {
		HeadColor = "HeadColor3", TorsoColor = "TorsoColor3", LeftArmColor = "LeftArmColor3",
		RightArmColor = "RightArmColor3", LeftLegColor = "LeftLegColor3", RightLegColor = "RightLegColor3"
	}
	for propKey, colorKey in pairs(colorProps) do
		local colorData = props[propKey]
		if type(colorData) == "table" then
			pcall(function()
				bodyColors[colorKey] = Color3.fromRGB(
					colorData.r or colorData.R or 255,
					colorData.g or colorData.G or 255,
					colorData.b or colorData.B or 255
				)
			end)
		end
	end
end

vars.applyHeadShapeToModel = function(model, props)	if not model or type(props) ~= "table" or props.HeadShape == nil then return end
	local head = model:FindFirstChild("Head")
	if not head then return end

	local shapeStr = tostring(props.HeadShape):lower()
	local specialMesh = head:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		if shapeStr:find("block") then
			specialMesh.MeshType = Enum.MeshType.Brick
		elseif shapeStr:find("round") or shapeStr:find("standard") then
			specialMesh.MeshType = Enum.MeshType.Head
		end
	end
end

vars.applyHeadShapeToDescription = function(description, props)	if not description or type(props) ~= "table" then return false end

	local rawShape = props.HeadShape
	local shape = tostring(rawShape or "")
	shape = string.match(shape, "^%s*(.-)%s*$")
	if shape == "" then return false end

	local headAssetId = vars.parseAssetId(props.Head)
		or vars.parseAssetId(props.HeadAssetId)
		or vars.parseAssetId(props.HeadId)
		or (type(props.BodyParts) == "table" and vars.parseAssetId(props.BodyParts.Head))
		or (type(props.EquippedAssets) == "table" and vars.parseAssetId(props.EquippedAssets.Head))
	if not headAssetId then return false end

	local ok = pcall(function()
		local headDescription = Instance.new("BodyPartDescription")
		headDescription.BodyPart = Enum.BodyPart.Head
		headDescription.AssetId = headAssetId
		headDescription.HeadShape = shape
		headDescription.Parent = description
	end)

	return ok
end

vars.reconstructHumanoidDescription = function(props)	local desc = Instance.new("HumanoidDescription")
	if type(props) ~= "table" then return desc end

	local headShape = tostring(props.HeadShape or "")
	headShape = string.match(headShape, "^%s*(.-)%s*$")
	local hasHeadShape = headShape ~= ""
	local headShapeApplied = vars.applyHeadShapeToDescription(desc, props)

	local directProps = {
		"Face", "Shirt", "Pants", "GraphicTShirt", "Head", "Torso",
		"LeftArm", "RightArm", "LeftLeg", "RightLeg", "WalkAnimation",
		"MoodAnimation", "ClimbAnimation", "FallAnimation", "RunAnimation",
		"SwimAnimation", "IdleAnimation", "JumpAnimation"
	}
	for _, prop in ipairs(directProps) do
		local parsedId = vars.parseAssetId(props[prop])
		if parsedId and not (prop == "Head" and hasHeadShape and headShapeApplied) then
			pcall(function() desc[prop] = parsedId end)
		end
	end

	if not headShapeApplied and (desc.Head == 0 or not desc.Head) then
		local fallbackHeadId = vars.parseAssetId(props.HeadAssetId) or vars.parseAssetId(props.HeadId)
			or (type(props.BodyParts) == "table" and vars.parseAssetId(props.BodyParts.Head))
			or (type(props.EquippedAssets) == "table" and vars.parseAssetId(props.EquippedAssets.Head))
		if fallbackHeadId then pcall(function() desc.Head = fallbackHeadId end) end
	end

	if props.StaticFacialAnimation ~= nil then
		pcall(function() desc.StaticFacialAnimation = props.StaticFacialAnimation == true end)
	end
	if type(props.Emotes) == "table" then pcall(function() desc:SetEmotes(props.Emotes) end) end
	if type(props.EquippedEmotes) == "table" then pcall(function() desc:SetEquippedEmotes(props.EquippedEmotes) end) end

	if type(props.MakeupItems) == "table" then
		for _, makeup in ipairs(props.MakeupItems) do
			pcall(function()
				local assetId = vars.parseAssetId(makeup.AssetId)
				local makeupType = Enum.MakeupType[tostring(makeup.MakeupType)]
				if assetId and makeupType then
					local makeupDescription = Instance.new("MakeupDescription")
					makeupDescription.AssetId = assetId
					makeupDescription.Order = tonumber(makeup.Order) or 1
					makeupDescription.MakeupType = makeupType
					makeupDescription.Parent = desc
				end
			end)
		end
	end

	local refinements = props.AccessoryRefinements or {}
	if props.AllAccessories and type(props.AllAccessories) == "table" then
		local accessories = {}
		for _, entry in ipairs(props.AllAccessories) do
			if type(entry) == "table" and entry.AssetId and entry.AccessoryType then
				local parsedAssetId = vars.parseAssetId(entry.AssetId)
				local accessoryType = Enum.AccessoryType[entry.AccessoryType]
				if parsedAssetId and accessoryType then
					local accessory = { AssetId = parsedAssetId, AccessoryType = accessoryType }
					local refData = refinements[tostring(parsedAssetId)] or entry
					if refData then
						if refData.Position then accessory.Position = vars.vector3FromSaved(refData.Position, Vector3.zero) end
						if refData.Rotation then accessory.Rotation = vars.vector3FromSaved(refData.Rotation, Vector3.zero) end
						if refData.Scale then accessory.Scale = vars.vector3FromSaved(refData.Scale, Vector3.one) end
					end
					if entry.IsLayered then
						accessory.IsLayered = true
						accessory.Order = tonumber(entry.Order) or 0
						if entry.Puffiness ~= nil then accessory.Puffiness = tonumber(entry.Puffiness) or 0 end
					end
					table.insert(accessories, accessory)
				end
			end
		end
		pcall(function() desc:SetAccessories(accessories, true) end)
	else
		for _, propertyName in ipairs(vars.accessoryPropertyNames) do
			if props[propertyName] ~= nil then
				pcall(function() desc[propertyName] = tostring(props[propertyName]) end)
			end
		end
	end

	local colorProps = { "RightArmColor", "TorsoColor", "RightLegColor", "LeftLegColor", "LeftArmColor", "HeadColor" }
	for _, colorName in ipairs(colorProps) do
		local colorData = props[colorName]
		if type(colorData) == "table" then
			pcall(function()
				desc[colorName] = Color3.fromRGB(
					colorData.r or colorData.R or 255,
					colorData.g or colorData.G or 255,
					colorData.b or colorData.B or 255
				)
			end)
		end
	end

	local scaleProps = { "ProportionScale", "DepthScale", "HeightScale", "WidthScale", "BodyTypeScale", "HeadScale" }
	for _, scaleName in ipairs(scaleProps) do
		if props[scaleName] ~= nil then pcall(function() desc[scaleName] = tonumber(props[scaleName]) or 1 end) end
	end

	return desc
end

vars.applyRigidAccessoryRefinements = function(model, props)	local refinements = props and props.AccessoryRefinements
	if type(refinements) ~= "table" then return 0 end
	local matched = 0
	local used = {}
	for _, accessory in ipairs(model:GetDescendants()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				local assetId = nil
				pcall(function() assetId = vars.parseAssetId(accessory:GetAttribute("AssetId")) end)
				if not assetId then pcall(function() assetId = vars.parseAssetId(handle:GetAttribute("AssetId")) end) end
				if not assetId then
					local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")
					if specialMesh and specialMesh.MeshId then assetId = vars.parseAssetId(specialMesh.MeshId) end
				end
				if not assetId and handle:IsA("MeshPart") and handle.MeshId then assetId = vars.parseAssetId(handle.MeshId) end

				local ref = (assetId and refinements[tostring(assetId)]) or refinements[accessory.Name]
				if ref and type(ref) == "table" then
					local key = assetId or accessory.Name
					if not used[key] then
						local position = vars.vector3FromSaved(ref.Position, Vector3.zero)
						local rotation = vars.vector3FromSaved(ref.Rotation, Vector3.zero)
						local scale = vars.vector3FromSaved(ref.Scale, Vector3.one)

						local offsetCF = CFrame.new(position) * CFrame.Angles(
							math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)
						)

						local attachment = handle:FindFirstChildOfClass("Attachment")
						if attachment then
							attachment.CFrame = attachment.CFrame * offsetCF
						else
							local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("WeldConstraint") or handle:FindFirstChildOfClass("ManualWeld")
							if weld and weld:IsA("Weld") then weld.C0 = weld.C0 * offsetCF end
						end

						if scale ~= Vector3.one then
							handle.Size = handle.Size * scale
							local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")
							if specialMesh then specialMesh.Scale = specialMesh.Scale * scale end
						end
						used[key] = true
						matched = matched + 1
					end
				end
			end
		end
	end
	return matched
end

vars.getAnimationIdFromFolder = function(container, animName)	if not container then return nil end
	local target = container:FindFirstChild(animName)
		or container:FindFirstChild(string.lower(animName))
		or (animName == "SwimIdle" and (container:FindFirstChild("swimidle") or container:FindFirstChild("SwimIdle")))
		or (animName == "Swim" and (container:FindFirstChild("swim") or container:FindFirstChild("Swim")))
	if not target then return nil end

	if target:IsA("Animation") and target.AnimationId ~= "" then return target.AnimationId
	elseif target:IsA("StringValue") and target.Value ~= "" then return target.Value end

	for _, child in ipairs(target:GetChildren()) do
		if child:IsA("Animation") and child.AnimationId ~= "" then return child.AnimationId
		elseif child:IsA("StringValue") and child.Value ~= "" then return child.Value end
	end
	return nil
end

vars.resolveAnimationIds = function(cloneModel, savedProps, isR6)
	local defaults = isR6 and vars.R6_DEFAULTS or vars.R15_DEFAULTS
	local animFolder = cloneModel and cloneModel:FindFirstChild("Animate")
	local animIds = {}
	local animKeys = {"Idle", "Walk", "Run", "Jump", "Fall", "Climb", "Swim", "SwimIdle", "Sit"}

	for _, key in ipairs(animKeys) do
		if key == "Sit" then
			local cloneSitId = vars.getAnimationIdFromFolder(animFolder, "Sit")
			animIds[key] = cloneSitId or defaults[key]
		else
			local idFromAnimate = vars.getAnimationIdFromFolder(animFolder, key)
			local propKey = key .. "Animation"
			local rawPropVal = savedProps and savedProps[propKey]
			local parsedPropId = vars.parseAssetId(rawPropVal)

			local finalId = (idFromAnimate and idFromAnimate ~= "") and idFromAnimate or nil
			if not finalId and parsedPropId then
				finalId = "rbxassetid://" .. tostring(parsedPropId)
			end
			if not finalId or finalId == "" then
				finalId = defaults[key]
			end

			animIds[key] = finalId
		end
	end

	return animIds
end

vars.applySelectedAvatarAnimationsToCharacter = function(character, savedProps, cloneModel)
	if not character or not character.Parent or type(savedProps) ~= "table" then
		return false, "Invalid character or animation data."
	end

	local animateScript = character:FindFirstChild("Animate")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not animateScript or not humanoid then
		return false, "Character Animate/Humanoid was not found."
	end

	-- FE animation replication depends on using the Animator that was created
	-- for the real player Character. Never let this path proceed without it.
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = humanoid:WaitForChild("Animator", 5)
	end
	if not animator or not animator:IsA("Animator") then
		return false, "Server-created Character Animator was not available."
	end

	-- ROOT CAUSE FIX:
	-- savedProps.IdleAnimation / WalkAnimation / ... are HumanoidDescription
	-- catalog package asset IDs, NOT playable Animation asset IDs. Writing them
	-- into Animate.*.AnimationId makes the real Character's Animate fail to load
	-- every track, so other clients see a static character.
	-- The playable IDs are the ones Roblox already wrote into the generated
	-- clone's Animate tree (the same IDs the clone sync plays locally), so the
	-- real Character must copy them from there, slot by slot.
	local cloneAnimate = cloneModel and cloneModel:FindFirstChild("Animate")
	if not cloneAnimate then
		return false, "Generated avatar Animate tree was not available; playable animation IDs are unknown."
	end

	vars.restoreSelectedAvatarAnimations()

	local enumRig = vars.getEnumRigType(humanoid.RigType)
	local isR6 = enumRig == Enum.HumanoidRigType.R6
		or (character:FindFirstChild("Torso") ~= nil and character:FindFirstChild("UpperTorso") == nil)

	local cloneHumanoid = cloneModel:FindFirstChildOfClass("Humanoid")
	local cloneIsR6 = (cloneHumanoid ~= nil and vars.getEnumRigType(cloneHumanoid.RigType) == Enum.HumanoidRigType.R6)
		or (cloneModel:FindFirstChild("Torso") ~= nil and cloneModel:FindFirstChild("UpperTorso") == nil)

	if cloneIsR6 ~= isR6 then
		-- R15 keyframes cannot drive an R6 rig (and vice versa). Leave the real
		-- Character on its own working animations instead of freezing it.
		return false, "Rig mismatch between real Character and selected avatar; real Character animations were left unchanged."
	end

	local function getCloneSlotAnimationId(folderName, childName, animationKey)
		local cloneFolder = cloneAnimate:FindFirstChild(folderName)
		if cloneFolder then
			local cloneChild = cloneFolder:FindFirstChild(childName)
			if cloneChild and cloneChild:IsA("Animation") and cloneChild.AnimationId ~= "" then
				return cloneChild.AnimationId
			end
		end
		return vars.getAnimationIdFromFolder(cloneAnimate, animationKey)
	end

	local backup = {}
	local changed = false

	local function setAnimation(animationObject, folderName, animationKey)
		if not animationObject or not animationObject:IsA("Animation") then
			return
		end

		local animationId = getCloneSlotAnimationId(folderName, animationObject.Name, animationKey)
		if not animationId or animationId == "" then
			return
		end

		local parsedId = vars.parseAssetId(animationId)
		if not parsedId then
			return
		end

		if backup[animationObject] == nil then
			backup[animationObject] = animationObject.AnimationId
		end

		-- Match the exact FE path used by the old working script.
		animationObject.AnimationId = "http://www.roblox.com/asset/?id=" .. tostring(parsedId)
		changed = true
	end

	-- Exact order from the old script's known-working FE animation method:
	-- 1. Disable Animate.
	-- 2. Re-enable it through StopAnim's behavior, then stop every current track.
	-- 3. Disable Animate again before replacing its AnimationIds.
	-- 4. Force a Humanoid state refresh.
	-- 5. Re-enable Animate so its normal state machine takes over.
	pcall(function()
		animateScript.Disabled = true
	end)

	pcall(function()
		animateScript.Disabled = false
	end)

	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		pcall(function()
			track:Stop()
		end)
	end

	pcall(function()
		animateScript.Disabled = true
	end)

	-- Any unexpected error here must never leave Animate disabled.
	local slotsOk, slotsError = pcall(function()
		local idleFolder = animateScript:FindFirstChild("idle")
		if idleFolder then
			setAnimation(idleFolder:FindFirstChild("Animation1"), "idle", "Idle")
			setAnimation(idleFolder:FindFirstChild("Animation2"), "idle", "Idle")
		end

		local walkFolder = animateScript:FindFirstChild("walk")
		if walkFolder then
			setAnimation(walkFolder:FindFirstChild("WalkAnim"), "walk", "Walk")
		end

		local runFolder = animateScript:FindFirstChild("run")
		if runFolder then
			setAnimation(runFolder:FindFirstChild("RunAnim"), "run", "Run")
		end

		local jumpFolder = animateScript:FindFirstChild("jump")
		if jumpFolder then
			setAnimation(jumpFolder:FindFirstChild("JumpAnim"), "jump", "Jump")
		end

		local fallFolder = animateScript:FindFirstChild("fall")
		if fallFolder then
			setAnimation(fallFolder:FindFirstChild("FallAnim"), "fall", "Fall")
		end

		local climbFolder = animateScript:FindFirstChild("climb")
		if climbFolder then
			setAnimation(climbFolder:FindFirstChild("ClimbAnim"), "climb", "Climb")
		end

		local swimFolder = animateScript:FindFirstChild("swim")
		if swimFolder then
			setAnimation(swimFolder:FindFirstChild("Swim"), "swim", "Swim")
		end

		local swimIdleFolder = animateScript:FindFirstChild("swimidle")
		if swimIdleFolder then
			setAnimation(swimIdleFolder:FindFirstChild("SwimIdle"), "swimidle", "SwimIdle")
		end
	end)

	if not slotsOk or not changed then
		for animationObject, originalId in pairs(backup) do
			pcall(function()
				animationObject.AnimationId = originalId
			end)
		end
		pcall(function()
			animateScript.Disabled = false
		end)
		if not slotsOk then
			return false, "Failed while replacing Animate slots: " .. tostring(slotsError)
		end
		return false, "No compatible character animation slots were found."
	end

	vars.localCharacterAnimationBackup = {
		Character = character,
		Animate = animateScript,
		Humanoid = humanoid,
		Values = backup,
		Destroyed = false,
	}

	-- Same refresh call used by the old working FE script.
	pcall(function()
		humanoid:ChangeState(3)
	end)

	pcall(function()
		animateScript.Disabled = false
	end)

	return true
end

vars.restoreSelectedAvatarAnimations = function()
	local data = vars.localCharacterAnimationBackup
	vars.localCharacterAnimationBackup = nil
	if not data then
		return
	end

	local animateScript = data.Animate
	local humanoid = data.Humanoid
	local values = data.Values or {}

	if humanoid and humanoid.Parent then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			pcall(function()
				track:Stop()
			end)
		end
	end

	if animateScript and animateScript.Parent then
		pcall(function()
			animateScript.Disabled = true
		end)
	end

	for animationObject, originalId in pairs(values) do
		if animationObject and animationObject.Parent then
			pcall(function()
				animationObject.AnimationId = originalId
			end)
		end
	end

	if animateScript and animateScript.Parent then
		pcall(function()
			animateScript.Disabled = false
		end)
	end
end

vars.getAppliedPlayerEmoteData = function(humanoid)	if not humanoid then return {}, {} end
	local description = nil
	local ok = pcall(function()
		description = humanoid:GetAppliedDescription()
	end)
	if not ok or not description then return {}, {} end

	local emotes = {}
	local equipped = {}
	pcall(function()
		emotes = vars.cloneEmoteTable(description:GetEmotes())
	end)
	pcall(function()
		local value = description:GetEquippedEmotes()
		if type(value) == "table" then
			for _, entry in ipairs(value) do
				if type(entry) == "table" and type(entry.Name) == "string" and entry.Name ~= "" then
					equipped[#equipped + 1] = {
						Slot = tonumber(entry.Slot) or (#equipped + 1),
						Name = entry.Name
					}
				end
			end
		end
	end)
	pcall(function() description:Destroy() end)
	return emotes, equipped
end

vars.mergePlayerEmotesIntoDescription = function(description, playerHumanoid, rigType)	if not description or vars.getEnumRigType(rigType) ~= Enum.HumanoidRigType.R15 then
		return
	end

	local playerEmotes, playerEquippedEmotes = vars.getAppliedPlayerEmoteData(playerHumanoid)
	local merged = {}
	pcall(function()
		merged = vars.cloneEmoteTable(description:GetEmotes())
	end)
	for name, ids in pairs(playerEmotes) do
		merged[name] = ids
	end

	if next(merged) ~= nil then
		pcall(function() description:SetEmotes(merged) end)
	end

	if #playerEquippedEmotes > 0 then
		local validEquipped = {}
		for _, entry in ipairs(playerEquippedEmotes) do
			if merged[entry.Name] then
				validEquipped[#validEquipped + 1] = entry
			end
		end
		if #validEquipped > 0 then
			pcall(function() description:SetEquippedEmotes(validEquipped) end)
		end
	end
end

vars.bindAnimationSync = function(playerCharacter, cloneModel, savedProps, rigType)	vars.cleanupAnimationSync()

	local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")
	local cloneHumanoid = cloneModel and cloneModel:FindFirstChildOfClass("Humanoid")
	if not playerHumanoid or not cloneHumanoid then return function() end end

	local playerAnimator = playerHumanoid:FindFirstChildOfClass("Animator")
	if not playerAnimator then
		playerAnimator = playerHumanoid:WaitForChild("Animator", 5)
	end
	local cloneAnimator = cloneHumanoid:FindFirstChildOfClass("Animator")
	if not cloneAnimator then
		cloneAnimator = Instance.new("Animator")
		cloneAnimator.Parent = cloneHumanoid
	end

	for _, track in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
		pcall(function() track:Stop(0) end)
	end

	local enumRig = vars.getEnumRigType(rigType)
	local isR6 = (enumRig == Enum.HumanoidRigType.R6)
		or (cloneModel:FindFirstChild("Torso") ~= nil and cloneModel:FindFirstChild("UpperTorso") == nil)
	local defaults = isR6 and vars.R6_DEFAULTS or vars.R15_DEFAULTS
	local animIds = vars.resolveAnimationIds(cloneModel, savedProps, isR6)

	local playerEmoteByAssetId = {}
	local playerEmoteByAnimationId = {}
	local playerEmotePlayNameByCanonical = {}
	local equippedEmoteNames = {}

	local function normalizeEmoteName(rawName)
		local value = string.lower(tostring(rawName or ""))
		value = string.match(value, "^%s*(.-)%s*$") or value
		value = value:gsub("[^%w]+", "")
		return value
	end

	local function rememberEmoteAsset(assetId, emoteName, exactNameForPlayback)
		local parsed = vars.parseAssetId(assetId)
		if not parsed then return end
		local normalized = normalizeEmoteName(emoteName)
		if normalized == "" then return end
		playerEmoteByAssetId[tostring(parsed)] = normalized
		local exactName = exactNameForPlayback or emoteName
		if type(exactName) == "string" and exactName ~= "" then
			playerEmotePlayNameByCanonical[normalized] = exactName
		end
	end

	local function rememberResolvedAnimation(emoteAnimationId, emoteName, exactNameForPlayback)
		local parsed = vars.parseAssetId(emoteAnimationId)
		if not parsed then return end
		local normalized = normalizeEmoteName(emoteName)
		if normalized == "" then return end
		playerEmoteByAnimationId[tostring(parsed)] = normalized
		local exactName = exactNameForPlayback or emoteName
		if type(exactName) == "string" and exactName ~= "" then
			playerEmotePlayNameByCanonical[normalized] = exactName
		end
	end

	local function extractAnimationIdFromLoadedEmoteAsset(root)
		if not root then return nil end
		if root:IsA("Animation") and root.AnimationId ~= "" then
			return root.AnimationId
		end
		for _, instance in ipairs(root:GetDescendants()) do
			if instance:IsA("Animation") and instance.AnimationId ~= "" then
				return instance.AnimationId
			end
		end
		return nil
	end

	local function resolveEmoteCatalogAssetToAnimationId(catalogAssetId)
		local parsed = vars.parseAssetId(catalogAssetId)
		if not parsed then return nil end
		local key = tostring(parsed)
		if vars.emoteAssetAnimationCache[key] ~= nil then
			return vars.emoteAssetAnimationCache[key]
		end

		local animationId = nil

		pcall(function()
			if type(game.GetObjects) == "function" then
				local objects = game:GetObjects("rbxassetid://" .. key)
				if type(objects) == "table" then
					for _, root in ipairs(objects) do
						animationId = extractAnimationIdFromLoadedEmoteAsset(root)
						if animationId then
							pcall(function() root:Destroy() end)
							break
						end
					end
				end
			end
		end)

		if not animationId and vars.InsertService then
			pcall(function()
				local root = vars.InsertService:LoadAsset(parsed)
				animationId = extractAnimationIdFromLoadedEmoteAsset(root)
				if root then root:Destroy() end
			end)
		end

		if animationId then
			vars.emoteAssetAnimationCache[key] = animationId
		end
		return animationId
	end

	local appliedDescription = nil
	local appliedDescriptionOk = pcall(function()
		appliedDescription = playerHumanoid:GetAppliedDescription()
	end)
	if appliedDescriptionOk and appliedDescription then
		pcall(function()
			local equipped = appliedDescription:GetEquippedEmotes()
			if type(equipped) == "table" then
				for _, entry in ipairs(equipped) do
					if type(entry) == "table" and type(entry.Name) == "string" then
						equippedEmoteNames[normalizeEmoteName(entry.Name)] = entry.Name
					end
				end
			end
		end)

		pcall(function()
			local emotes = appliedDescription:GetEmotes()
			if type(emotes) == "table" then
				for name, ids in pairs(emotes) do
					if type(ids) == "table" then
						local exactName = type(name) == "string" and name or tostring(name)
						for _, assetId in ipairs(ids) do
							rememberEmoteAsset(assetId, exactName, exactName)
							local actualAnimationId = resolveEmoteCatalogAssetToAnimationId(assetId)
							if actualAnimationId then
								rememberResolvedAnimation(actualAnimationId, exactName, exactName)
							end
						end
					end
				end
			end
		end)
		pcall(function() appliedDescription:Destroy() end)
	end

	for emoteName, assetList in pairs(vars.R6_EMOTE_LIBRARY) do
		for _, assetId in ipairs(assetList) do
			rememberEmoteAsset(assetId, emoteName)
		end
	end

	local playerAnimate = playerCharacter:FindFirstChild("Animate")
	local knownEmoteNames = {}
	for emoteName in pairs(vars.R6_EMOTE_LIBRARY) do
		knownEmoteNames[normalizeEmoteName(emoteName)] = emoteName
	end
	for normalized, exactName in pairs(equippedEmoteNames) do
		knownEmoteNames[normalized] = exactName
	end

	local function getNamedEmoteFromHierarchy(animation)
		if not animation then return nil end

		local function checkName(instance)
			if not instance then return nil end
			local normalized = normalizeEmoteName(instance.Name)
			return knownEmoteNames[normalized]
		end

		local direct = checkName(animation)
		if direct then return direct end

		local parent = animation.Parent
		while parent and parent ~= playerCharacter do
			local named = checkName(parent)
			if named then return named end
			if parent == playerAnimate then break end
			parent = parent.Parent
		end
		return nil
	end

	local locomotionFolderNames = {
		idle = true,
		walk = true,
		run = true,
		jump = true,
		fall = true,
		climb = true,
		swim = true,
		swimidle = true,
		sit = true,
		seated = true,
		tool = true,
		toolnone = true,
		toolnoneanim = true,
		toolslash = true,
		toollunge = true,
		slash = true,
		lunge = true,
	}

	local function hasLocomotionOrToolAncestor(animation)
		if not animation then return false end
		local normalizedName = normalizeEmoteName(animation.Name)
		if locomotionFolderNames[normalizedName] then return true end

		local parent = animation.Parent
		while parent and parent ~= playerCharacter do
			local parentName = normalizeEmoteName(parent.Name)
			if locomotionFolderNames[parentName] then return true end
			parent = parent.Parent
		end
		return false
	end

	local function isLikelyR15EmoteTrack(playerTrack)
		if isR6 or not playerTrack or not playerTrack.Animation then return false end
		if hasLocomotionOrToolAncestor(playerTrack.Animation) then return false end


		local priority = playerTrack.Priority
		local isCore = priority == Enum.AnimationPriority.Core
		local isAction = priority == Enum.AnimationPriority.Action
			or priority == Enum.AnimationPriority.Action2
			or priority == Enum.AnimationPriority.Action3
			or priority == Enum.AnimationPriority.Action4
		if not isCore and not isAction then return false end

		local animationId = vars.parseAssetId(playerTrack.Animation.AnimationId)
		if not animationId then return false end

		if next(equippedEmoteNames) ~= nil
			or next(playerEmoteByAnimationId) ~= nil
			or next(playerEmoteByAssetId) ~= nil then
			return true
		end

		return false
	end

	if playerAnimate then
		for _, instance in ipairs(playerAnimate:GetDescendants()) do
			if instance:IsA("Animation") then
				local emoteName = getNamedEmoteFromHierarchy(instance)
				if emoteName then
					rememberEmoteAsset(instance.AnimationId, emoteName)
				end
			end
		end
	end

	local function resolvePlayerEmoteName(playerTrack)
		if not playerTrack or not playerTrack.Animation then return nil, false end
		if vars.replicatedCharacterAnimationTracks[playerTrack] then return nil, false end

		local assetId = vars.parseAssetId(playerTrack.Animation.AnimationId)
		if assetId then
			local assetKey = tostring(assetId)

			local resolvedAnimationMapped = playerEmoteByAnimationId[assetKey]
			if resolvedAnimationMapped then
				return resolvedAnimationMapped, true
			end

			local legacyMapped = vars.PLAYER_LEGACY_EMOTE_IDS[assetKey]
			if legacyMapped then return legacyMapped, true end

			local mapped = playerEmoteByAssetId[assetKey]
			if mapped then return mapped, true end
		end

		local named = getNamedEmoteFromHierarchy(playerTrack.Animation)
		if named then return normalizeEmoteName(named), true end

		if isLikelyR15EmoteTrack(playerTrack) then
			return "__direct_r15_emote_track__", false
		end

	return nil, false
	end

	local function chooseR6EmoteAnimation(emoteName)
		local list = vars.R6_EMOTE_LIBRARY[emoteName]
		if type(list) ~= "table" or #list == 0 then return nil end

		if #list == 1 then return list[1] end
		local index = (math.floor(os.clock() * 1000) % #list) + 1
		return list[index]
	end
	local function findFreshCloneEmoteTrack(beforeTracks, expectedAssetId)
		local expectedParsed = vars.parseAssetId(expectedAssetId)
		local expectedKey = expectedParsed and tostring(expectedParsed) or nil
		local fallback = nil

		for _, candidate in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
			if candidate and candidate.IsPlaying and not beforeTracks[candidate] then
				local candidateId = candidate.Animation and vars.parseAssetId(candidate.Animation.AnimationId)
				if expectedKey and candidateId and tostring(candidateId) == expectedKey then
					return candidate
				end
				fallback = fallback or candidate
			end
		end

		return fallback
	end

	local function syncInitialEmotePhase(playerTrack, cloneTrack)
		if not playerTrack or not cloneTrack then return end
		if not playerTrack.IsPlaying or not cloneTrack.IsPlaying then return end

		local playerAnimation = playerTrack.Animation
		local cloneAnimation = cloneTrack.Animation
		local playerId = playerAnimation and vars.parseAssetId(playerAnimation.AnimationId)
		local cloneId = cloneAnimation and vars.parseAssetId(cloneAnimation.AnimationId)

		if not playerId or not cloneId or playerId ~= cloneId then return end

		local function applyPhase()
			if not playerTrack.IsPlaying or not cloneTrack.IsPlaying then return true end
			if playerTrack.Length <= 0 or cloneTrack.Length <= 0 then return false end

			local playerPhase = math.clamp(playerTrack.TimePosition / playerTrack.Length, 0, 0.999999)
			local targetPosition = playerPhase * cloneTrack.Length
			pcall(function()
				cloneTrack.TimePosition = targetPosition
			end)
			return true
		end

		if applyPhase() then return end

		task.spawn(function()
			for _ = 1, 4 do
				vars.RunService.Heartbeat:Wait()
				if not vars.scriptAlive then return end
				if applyPhase() then return end
			end
		end)
	end

	local function tryPlayRegisteredR15Emote(emoteName, playerTrack)
		if isR6 then return nil, nil end

		local playbackName = playerEmotePlayNameByCanonical[emoteName]
		if not playbackName then return nil, nil end

		local beforeTracks = {}
		for _, track in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
			beforeTracks[track] = true
		end

		local ok, result = pcall(function()
			return cloneHumanoid:PlayEmoteAsync(playbackName)
		end)
		if not ok or result ~= true then return nil, nil end

		local expectedAssetId = playerTrack
			and playerTrack.Animation
			and playerTrack.Animation.AnimationId

		local cloneTrack = nil
		local deadline = os.clock() + 0.35
		repeat
			cloneTrack = findFreshCloneEmoteTrack(beforeTracks, expectedAssetId)
			if cloneTrack then break end
			vars.RunService.Heartbeat:Wait()
		until os.clock() >= deadline

		if not cloneTrack then
			local expectedParsed = vars.parseAssetId(expectedAssetId)
			if expectedParsed then
				pcall(function()
					cloneTrack = cloneAnimator:GetTrackByAnimationId("rbxassetid://" .. tostring(expectedParsed))
				end)
			end
		end

		if cloneTrack then
			pcall(function() cloneTrack.Priority = Enum.AnimationPriority.Action end)
			pcall(function() cloneTrack.Looped = true end)
			syncInitialEmotePhase(playerTrack, cloneTrack)
		end

		return cloneTrack
	end

	local function loadDirectCloneEmote(animationId, emoteName, playerTrack)
		if not animationId or animationId == "" then return nil, nil end

		local animation = Instance.new("Animation")
		animation.AnimationId = animationId

		local ok, cloneTrack = pcall(function()
			return cloneAnimator:LoadAnimation(animation)
		end)
		if not ok or not cloneTrack then
			animation:Destroy()
			return nil, nil
		end

		cloneTrack.Priority = Enum.AnimationPriority.Action
		if isR6 then
			if emoteName == "__direct_r15_emote_track__" then
				cloneTrack.Looped = playerTrack.Looped
			else
				cloneTrack.Looped = vars.R6_EMOTE_LOOPED[emoteName] == true
			end
		else
			cloneTrack.Looped = playerTrack.Looped
		end

		local playedOk = pcall(function()
			cloneTrack:Play(0.08, 1, 1)
		end)
		if not playedOk then
			pcall(function() cloneTrack:Stop(0) end)
			animation:Destroy()
			return nil, nil
		end

		syncInitialEmotePhase(playerTrack, cloneTrack)
		return cloneTrack, animation
	end

	local catchEmoteTrack
	local isToolActionTrack
	local playCloneToolAction

	-- Restored generic emote playback path. v27.4 referenced this function from
	-- catchEmoteTrack but no longer defined it, so every recognized emote could
	-- fail at runtime before the clone ever received the animation.
	local function playCloneEmote(playerTrack, emoteName, isDirectR15Track)
		if not playerTrack or not playerTrack.IsPlaying or not playerTrack.Animation then
			return false
		end

		vars.stopCloneEmoteTracks(0.08)

		local cloneTrack = nil
		local animationObject = nil

		if not isR6 and not isDirectR15Track and emoteName then
			cloneTrack = tryPlayRegisteredR15Emote(emoteName, playerTrack)
		end

		if not cloneTrack then
			local animationId = nil
			if isR6 then
				animationId = chooseR6EmoteAnimation(emoteName)
			else
				animationId = playerTrack.Animation.AnimationId
			end

			cloneTrack, animationObject = loadDirectCloneEmote(animationId, emoteName, playerTrack)
		end

		if not cloneTrack then
			if animationObject then
				pcall(function() animationObject:Destroy() end)
			end
			return false
		end

		pcall(function() cloneTrack.Priority = playerTrack.Priority end)
		if not isR6 then
			pcall(function() cloneTrack.Looped = playerTrack.Looped end)
		end

		vars.activeCloneTracks[playerTrack] = cloneTrack
		vars.activeCloneEmoteAnimations[playerTrack] = animationObject
		vars.activeEmotePlayerTrack = playerTrack

		vars.activeCloneStopConnections[playerTrack] = playerTrack.Stopped:Connect(function()
			if not vars.scriptAlive then return end
			local active = vars.activeCloneTracks[playerTrack]
			if active and active ~= cloneTrack then return end
			vars.stopCloneEmoteTracks(0.08)
		end)

		return true
	end

	local function getEquippedTool()
		for _, child in ipairs(playerCharacter:GetChildren()) do
			if child:IsA("Tool") then
				return child
			end
		end
		return nil
	end

	local function getToolNoneAnimation()
		if not playerAnimate then return nil end

		local toolNoneFolder = playerAnimate:FindFirstChild("toolnone")
			or playerAnimate:FindFirstChild("ToolNone")
		if not toolNoneFolder then return nil end

		local animation = toolNoneFolder:FindFirstChild("ToolNoneAnim")
			or toolNoneFolder:FindFirstChild("toolNoneAnim")
		if animation and animation:IsA("Animation") and animation.AnimationId ~= "" then
			return animation
		end

		for _, descendant in ipairs(toolNoneFolder:GetDescendants()) do
			if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
				return descendant
			end
		end
		return nil
	end

	local function stopCloneToolNone(tool)
		local cloneTrack = vars.activeCloneHeldPropTracks[tool]
		if cloneTrack then
			pcall(function() cloneTrack:Stop(0.08) end)
		end

		local animation = vars.activeCloneHeldPropAnimations[tool]
		if animation then pcall(function() animation:Destroy() end) end

		local connection = vars.activeCloneHeldPropStopConnections[tool]
		if connection then vars.disconnectConnection(connection) end

		local speedConnection = vars.activeCloneHeldPropSpeedConnections[tool]
		if speedConnection then vars.disconnectConnection(speedConnection) end

		vars.activeCloneHeldPropTracks[tool] = nil
		vars.activeCloneHeldPropAnimations[tool] = nil
		vars.activeCloneHeldPropStopConnections[tool] = nil
		vars.activeCloneHeldPropSpeedConnections[tool] = nil
	end

	local function getPlayingToolNoneTrack(toolNoneAnimation)
		if not playerAnimator or not toolNoneAnimation then return nil end
		local animationId = toolNoneAnimation.AnimationId
		if not animationId or animationId == "" then return nil end

		for _, playerTrack in ipairs(playerAnimator:GetPlayingAnimationTracks()) do
			local playerAnimation = playerTrack.Animation
			if playerTrack.IsPlaying and playerAnimation
				and (playerAnimation == toolNoneAnimation or playerAnimation.AnimationId == animationId) then
				return playerTrack
			end
		end
		return nil
	end

	local function playCloneToolNone(tool)
		if not tool or not tool:IsA("Tool") or tool.Parent ~= playerCharacter then return false end
		local toolNoneAnimation = getToolNoneAnimation()
		if not toolNoneAnimation then return false end
		if vars.activeCloneHeldPropTracks[tool] then return true end

		local playerToolNoneTrack = getPlayingToolNoneTrack(toolNoneAnimation)
		if not playerToolNoneTrack then return false end
		local originalSpeed = playerToolNoneTrack.Speed
		if type(originalSpeed) ~= "number" then return false end

		local animation = Instance.new("Animation")
		animation.AnimationId = toolNoneAnimation.AnimationId
		local ok, cloneTrack = pcall(function()
			return cloneAnimator:LoadAnimation(animation)
		end)
		if not ok or not cloneTrack then
			animation:Destroy()
			return false
		end

		cloneTrack.Priority = Enum.AnimationPriority.Action2
		cloneTrack.Looped = true
		local played = pcall(function()
			cloneTrack:Play(0.08, 1, originalSpeed)
		end)
		if not played then
			pcall(function() cloneTrack:Stop(0) end)
			animation:Destroy()
			return false
		end

		vars.activeCloneHeldPropTracks[tool] = cloneTrack
		vars.activeCloneHeldPropAnimations[tool] = animation
		vars.activeCloneHeldPropStopConnections[tool] = tool.AncestryChanged:Connect(function(_, parent)
			if parent ~= playerCharacter then stopCloneToolNone(tool) end
		end)
		vars.activeCloneHeldPropSpeedConnections[tool] = playerToolNoneTrack:GetPropertyChangedSignal("Speed"):Connect(function()
			if not vars.scriptAlive or vars.activeCloneHeldPropTracks[tool] ~= cloneTrack or not cloneTrack.IsPlaying then return end
			local currentSpeed = playerToolNoneTrack.Speed
			if type(currentSpeed) == "number" then
				pcall(function() cloneTrack:AdjustSpeed(currentSpeed) end)
			end
		end)
		return true
	end

	local lastToolNoneRecoveryAt = 0

	local function getCloneToolActionPriority(realPriority)
		if realPriority == Enum.AnimationPriority.Action4 then
			return Enum.AnimationPriority.Action4
		end
		if realPriority == Enum.AnimationPriority.Action
			or realPriority == Enum.AnimationPriority.Action2
			or realPriority == Enum.AnimationPriority.Action3 then
			return Enum.AnimationPriority.Action3
		end
		return realPriority
	end

	local baseAnimationIds = {}
	for _, animationId in pairs(animIds) do
		local parsed = vars.parseAssetId(animationId)
		if parsed then
			baseAnimationIds[tostring(parsed)] = true
		end
	end
	for _, animationId in pairs(defaults) do
		local parsed = vars.parseAssetId(animationId)
		if parsed then
			baseAnimationIds[tostring(parsed)] = true
		end
	end

	local function animationIdKey(animation)
		if not animation or not animation:IsA("Animation") then return nil end
		local parsed = vars.parseAssetId(animation.AnimationId)
		return parsed and tostring(parsed) or nil
	end

	local function rememberToolAnimationIds(tool)
		local ids = {}
		if not tool or not tool:IsA("Tool") then
			return ids
		end
		for _, descendant in ipairs(tool:GetDescendants()) do
			if descendant:IsA("Animation") then
				local key = animationIdKey(descendant)
				if key then ids[key] = true end
			end
		end
		vars.animationToolAnimationIds[tool] = ids
		return ids
	end

	local function disconnectToolLifecycle(tool)
		local connections = vars.animationToolConnections[tool]
		if connections then
			for _, connection in ipairs(connections) do
				vars.disconnectConnection(connection)
			end
		end
		vars.animationToolConnections[tool] = nil
		vars.animationToolStates[tool] = nil
		vars.animationToolAnimationIds[tool] = nil
	end

	local function scheduleToolNone(tool)
		task.defer(function()
			if not vars.scriptAlive or not tool or tool.Parent ~= playerCharacter then return end
			for _ = 1, 10 do
				if not vars.scriptAlive or tool.Parent ~= playerCharacter then return end
				if playCloneToolNone(tool) then return end
				vars.RunService.Heartbeat:Wait()
			end
		end)
	end

	local function bindToolLifecycle(tool)
		if not tool or not tool:IsA("Tool") then return end
		if vars.animationToolConnections[tool] then return end

		local state = {
			equipped = tool.Parent == playerCharacter,
			activated = false,
			activationSerial = 0,
			lastActivatedAt = 0,
		}
		vars.animationToolStates[tool] = state
		rememberToolAnimationIds(tool)

		local connections = {}
		connections[#connections + 1] = tool.Equipped:Connect(function()
			state.equipped = true
			state.activated = false
			state.activationSerial += 1
			scheduleToolNone(tool)
		end)

		connections[#connections + 1] = tool.Unequipped:Connect(function()
			state.equipped = false
			state.activated = false
			state.activationSerial += 1
			vars.stopCloneToolActionsForTool(tool, 0.08)
			stopCloneToolNone(tool)
		end)

		connections[#connections + 1] = tool.Activated:Connect(function()
			state.equipped = tool.Parent == playerCharacter
			state.activated = true
			state.activationSerial += 1
			state.lastActivatedAt = os.clock()
		end)

		connections[#connections + 1] = tool.Deactivated:Connect(function()
			state.activated = false
		end)

		connections[#connections + 1] = tool.AncestryChanged:Connect(function(_, parent)
			state.equipped = parent == playerCharacter
			if parent ~= playerCharacter then
				state.activated = false
				vars.stopCloneToolActionsForTool(tool, 0.08)
				stopCloneToolNone(tool)
				disconnectToolLifecycle(tool)
			end
		end)

		vars.animationToolConnections[tool] = connections
	end

	local function isKnownBaseAnimation(playerTrack)
		local animation = playerTrack and playerTrack.Animation
		local key = animationIdKey(animation)
		return key ~= nil and baseAnimationIds[key] == true
	end

	local function isToolNoneTrack(playerTrack)
		local animation = getToolNoneAnimation()
		local current = playerTrack and playerTrack.Animation
		if not animation or not current then return false end
		if current == animation then return true end
		local expectedId = animationIdKey(animation)
		local currentId = animationIdKey(current)
		return expectedId ~= nil and expectedId == currentId
	end

	local function getToolContextForTrack(playerTrack, capturedTool)
		if capturedTool and capturedTool:IsA("Tool") then
			local state = vars.animationToolStates[capturedTool]
			if state and (state.equipped or state.activated) then
				return capturedTool
			end
		end

		local currentTool = getEquippedTool()
		if currentTool then return currentTool end

		local animationKey = animationIdKey(playerTrack and playerTrack.Animation)
		if animationKey then
			for tool, ids in pairs(vars.animationToolAnimationIds) do
				local state = vars.animationToolStates[tool]
				if state and (state.equipped or state.activated) and ids[animationKey] then
					return tool
				end
			end
		end

		return nil
	end

	isToolActionTrack = function(playerTrack, toolContext)
		if not playerTrack or not playerTrack.IsPlaying or not playerTrack.Animation then
			return false
		end

		if isToolNoneTrack(playerTrack) then
			return false
		end

		if isKnownBaseAnimation(playerTrack) then
			return false
		end

		local animationKey = animationIdKey(playerTrack.Animation)
		local equippedTool = getToolContextForTrack(playerTrack, toolContext)
		if not equippedTool then
			return false
		end

		local toolIds = vars.animationToolAnimationIds[equippedTool]
		if animationKey and toolIds and toolIds[animationKey] then
			return true
		end

		local priority = playerTrack.Priority
		local actionPriority = priority == Enum.AnimationPriority.Action
			or priority == Enum.AnimationPriority.Action2
			or priority == Enum.AnimationPriority.Action3
			or priority == Enum.AnimationPriority.Action4

		-- Action+ is the normal layer for temporary Tool animations. We do not
		-- reject Animate descendants here because the actual base-animation ID
		-- check above already filters Jump/Fall/Sit/locomotion tracks.
		return actionPriority
	end

	local function playCloneToolActionInternal(playerTrack, toolContext)
		if not playerTrack or not playerTrack.IsPlaying or not playerTrack.Animation then
			return false
		end

		if vars.activeCloneToolActionTracks[playerTrack] then
			return true
		end

		local actionTool = getToolContextForTrack(playerTrack, toolContext)
		if not actionTool then return false end

		local animationId = playerTrack.Animation.AnimationId
		if not animationId or animationId == "" then return false end

		local animationObject = Instance.new("Animation")
		animationObject.AnimationId = animationId

		local ok, cloneTrack = pcall(function()
			return cloneAnimator:LoadAnimation(animationObject)
		end)
		if not ok or not cloneTrack then
			pcall(function() animationObject:Destroy() end)
			return false
		end

		local realPriority = playerTrack.Priority
		local clonePriority = getCloneToolActionPriority(realPriority)
		cloneTrack.Priority = clonePriority
		cloneTrack.Looped = playerTrack.Looped

		local weight = playerTrack.WeightCurrent
		if type(weight) ~= "number" or weight <= 0 then
			weight = playerTrack.WeightTarget
		end
		if type(weight) ~= "number" or weight <= 0 then weight = 1 end

		local speed = playerTrack.Speed
		if type(speed) ~= "number" or speed == 0 then speed = 1 end

		local played = pcall(function()
			cloneTrack:Play(0.08, weight, speed)
		end)
		if not played then
			pcall(function() cloneTrack:Stop(0) end)
			pcall(function() animationObject:Destroy() end)
			return false
		end

		vars.activeCloneToolActionTracks[playerTrack] = cloneTrack
		vars.activeCloneToolActionAnimations[playerTrack] = animationObject
		vars.activeCloneToolActionTools[playerTrack] = actionTool

		local connections = {}
		connections[#connections + 1] = playerTrack.Stopped:Connect(function()
			if vars.scriptAlive then
				local tool = vars.activeCloneToolActionTools[playerTrack]
				vars.stopCloneToolActionTrack(playerTrack, 0.08)
				if tool and tool.Parent == playerCharacter then
					scheduleToolNone(tool)
				end
			end
		end)

		connections[#connections + 1] = playerTrack:GetPropertyChangedSignal("Priority"):Connect(function()
			local active = vars.activeCloneToolActionTracks[playerTrack]
			if active then
				pcall(function() active.Priority = getCloneToolActionPriority(playerTrack.Priority) end)
			end
		end)

		connections[#connections + 1] = playerTrack:GetPropertyChangedSignal("Speed"):Connect(function()
			local active = vars.activeCloneToolActionTracks[playerTrack]
			if active and active.IsPlaying then
				local currentSpeed = playerTrack.Speed
				if type(currentSpeed) == "number" then
					pcall(function() active:AdjustSpeed(currentSpeed) end)
				end
			end
		end)

		connections[#connections + 1] = playerTrack:GetPropertyChangedSignal("WeightTarget"):Connect(function()
			local active = vars.activeCloneToolActionTracks[playerTrack]
			if active and active.IsPlaying then
				local target = playerTrack.WeightTarget
				if type(target) == "number" then
					pcall(function() active:AdjustWeight(math.max(target, 0), 0.03) end)
				end
			end
		end)

		connections[#connections + 1] = playerTrack:GetPropertyChangedSignal("Looped"):Connect(function()
			local active = vars.activeCloneToolActionTracks[playerTrack]
			if active then
				pcall(function() active.Looped = playerTrack.Looped end)
			end
		end)

		vars.activeCloneToolActionConnections[playerTrack] = connections
		syncInitialEmotePhase(playerTrack, cloneTrack)

		-- The source and clone load the same Animation asset, so actual
		-- TimePosition is the authoritative phase. The per-frame synchronizer
		-- below corrects any later loading drift.
		return true
	end

	playCloneToolAction = playCloneToolActionInternal

	catchEmoteTrack = function(playerTrack, toolContext)
		if not playerTrack or not playerTrack.IsPlaying then return false end
		if vars.activeCloneTracks[playerTrack] or vars.activeCloneToolActionTracks[playerTrack] then return true end

		-- ToolNone is a dedicated persistent layer. It must never enter either
		-- the emote route or the generic action classifier.
		if isToolNoneTrack(playerTrack) then return false end

		-- Resolve explicit/named emotes first. This preserves the original
		-- Avatar-Z emote behavior and prevents the Tool classifier from stealing
		-- a real emote track.
		local emoteName, isKnownEmote = resolvePlayerEmoteName(playerTrack)
		local directR15 = (emoteName == "__direct_r15_emote_track__")
		if (isKnownEmote and emoteName) or directR15 then
			return playCloneEmote(playerTrack, emoteName, directR15)
		end

		-- Never classify the character's own locomotion/jump/sit tracks as an
		-- emote or Tool action. The real AnimationId map is authoritative here.
		if isKnownBaseAnimation(playerTrack) then return false end

		-- Safe fallback for an unclassified emote/action track when NO Tool is
		-- equipped. This restores the old direct-clone behavior without allowing
		-- an unknown Tool action to enter this path.
		local priority = playerTrack.Priority
		local isActionPriority = priority == Enum.AnimationPriority.Action
			or priority == Enum.AnimationPriority.Action2
			or priority == Enum.AnimationPriority.Action3
			or priority == Enum.AnimationPriority.Action4
		if not toolContext and not getEquippedTool() and isActionPriority then
			return playCloneEmote(playerTrack, "__direct_r15_emote_track__", true)
		end

		if isToolActionTrack(playerTrack, toolContext) then
			return playCloneToolAction(playerTrack, toolContext)
		end

		return false
	end

	-- Register every currently equipped Tool and every later Tool before the
	-- AnimationPlayed listener is connected. This gives the classifier an
	-- explicit lifecycle source instead of inferring everything from names.
	for _, child in ipairs(playerCharacter:GetChildren()) do
		if child:IsA("Tool") then
			bindToolLifecycle(child)
		end
	end

	vars.setLocalTryOnConnection("animationToolAdded", playerCharacter.ChildAdded, function(child)
		if not child:IsA("Tool") then return end
		bindToolLifecycle(child)
		scheduleToolNone(child)
	end)

	vars.setLocalTryOnConnection("animationToolRemoved", playerCharacter.ChildRemoved, function(child)
		if not child:IsA("Tool") then return end
		vars.stopCloneToolActionsForTool(child, 0.08)
		stopCloneToolNone(child)
		disconnectToolLifecycle(child)
	end)

	if playerAnimator then
		for _, track in ipairs(playerAnimator:GetPlayingAnimationTracks()) do
			local toolContext = getEquippedTool()
			catchEmoteTrack(track, toolContext)
		end

		vars.animPlayedConnection = playerAnimator.AnimationPlayed:Connect(function(playerTrack)
			-- Capture and classify synchronously. A short-lived Tool action can
			-- finish before a deferred callback reaches this AnimationTrack.
			if not vars.scriptAlive then return end
			local toolContext = getEquippedTool()
			catchEmoteTrack(playerTrack, toolContext)
		end)
	end

	local loadedTracks = {}
	for key, animId in pairs(animIds) do
		if animId and animId ~= "" then
			local animObj = Instance.new("Animation")
			animObj.AnimationId = animId
			local ok, track = pcall(function() return cloneAnimator:LoadAnimation(animObj) end)

			if (not ok or not track) and isR6 and defaults[key] then
				local fallbackObj = Instance.new("Animation")
				fallbackObj.AnimationId = defaults[key]
				ok, track = pcall(function() return cloneAnimator:LoadAnimation(fallbackObj) end)
			end

			if ok and track then
				if key == "Idle" then track.Priority = Enum.AnimationPriority.Idle
				elseif key == "Walk" or key == "Run" or key == "Climb" or key == "Swim" or key == "SwimIdle" then track.Priority = Enum.AnimationPriority.Movement
				elseif key == "Jump" or key == "Fall" or key == "Sit" then track.Priority = Enum.AnimationPriority.Action
				else track.Priority = Enum.AnimationPriority.Core end

				track.Looped = (key ~= "Jump")
				loadedTracks[key] = track
			end
		end
	end

	local activeKey = nil

	-- The real character is the authoritative source for the final evaluated
	-- pose. Recreating every short-lived AnimationTrack on a second Animator is
	-- timing-sensitive, and the clone can therefore miss an action even while
	-- the real character is visibly animating.
	--
	-- Roblox evaluates animations after PreAnimation and before PreSimulation.
	-- Motor6D.Transform and AnimationConstraint.Transform contain that evaluated
	-- pose, so the clone receives the same transforms in PreSimulation. This is
	-- intentionally independent from Tool/emote classification.
	local poseSyncPairs = nil
	local poseSyncDirty = true

	local bodyPartNames = {
		HumanoidRootPart = true,
		Head = true,
		Torso = true,
		UpperTorso = true,
		LowerTorso = true,
		LeftArm = true,
		RightArm = true,
		LeftLeg = true,
		RightLeg = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
		LeftUpperArm = true,
		LeftLowerArm = true,
		LeftHand = true,
		RightUpperArm = true,
		RightLowerArm = true,
		RightHand = true,
		LeftUpperLeg = true,
		LeftLowerLeg = true,
		LeftFoot = true,
		RightUpperLeg = true,
		RightLowerLeg = true,
		RightFoot = true,
	}

	local function getPoseJointEndpoints(joint)
		if not joint then return nil, nil end

		if joint:IsA("Motor6D") then
			local part0 = joint.Part0
			local part1 = joint.Part1
			return part0 and part0.Name or nil, part1 and part1.Name or nil
		end

		if joint:IsA("AnimationConstraint") then
			local attachment0 = joint.Attachment0
			local attachment1 = joint.Attachment1
			local part0 = attachment0 and attachment0.Parent
			local part1 = attachment1 and attachment1.Parent
			return part0 and part0.Name or nil, part1 and part1.Name or nil
		end

		return nil, nil
	end

	local function isPoseJoint(joint)
		if not joint then return false end
		if not (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then
			return false
		end

		local part0Name, part1Name = getPoseJointEndpoints(joint)
		return bodyPartNames[part0Name] == true and bodyPartNames[part1Name] == true
	end

	local function getPoseJointKey(joint)
		if not isPoseJoint(joint) then return nil end
		local part0Name, part1Name = getPoseJointEndpoints(joint)
		return part0Name .. "|" .. part1Name
	end

	local function rebuildPoseSyncPairs()
		local sourceMap = {}
		local cloneMap = {}

		for _, sourceJoint in ipairs(playerCharacter:GetDescendants()) do
			local key = getPoseJointKey(sourceJoint)
			if key then
				sourceMap[key] = sourceJoint
			end
		end

		for _, cloneJoint in ipairs(cloneModel:GetDescendants()) do
			local key = getPoseJointKey(cloneJoint)
			if key then
				cloneMap[key] = cloneJoint
			end
		end

		local pairsList = {}
		for key, sourceJoint in pairs(sourceMap) do
			local cloneJoint = cloneMap[key]
			if cloneJoint then
				pairsList[#pairsList + 1] = {
					source = sourceJoint,
					clone = cloneJoint,
				}
			end
		end

		poseSyncPairs = pairsList
		poseSyncDirty = false
	end

	local function markPoseSyncDirty(instance)
		if not instance then
			poseSyncDirty = true
			return
		end

		if instance:IsA("Motor6D") or instance:IsA("AnimationConstraint") then
			poseSyncDirty = true
			return
		end

		if instance:IsA("BasePart") and bodyPartNames[instance.Name] then
			poseSyncDirty = true
		end
	end

	local function syncEvaluatedPoseToClone()
		if not cloneModel or not cloneModel.Parent or not playerCharacter or not playerCharacter.Parent then
			return
		end

		-- Always mirror the final evaluated source pose, not only while a
		-- temporary track is classified as active. The critical frames are the
		-- transition frames: when Sit/Action stops, Roblox is blending into
		-- Walk/Idle/ToolNone and there may be no "transient" track left for the
		-- old gate to detect. Gating this function caused the clone to keep its
		-- last temporary pose and then snap to the next state.
		if poseSyncDirty or not poseSyncPairs then
			rebuildPoseSyncPairs()
		end

		for _, pair in ipairs(poseSyncPairs) do
			local sourceJoint = pair.source
			local cloneJoint = pair.clone
			if sourceJoint and sourceJoint.Parent and cloneJoint and cloneJoint.Parent then
				local ok, sourceTransform = pcall(function()
					return sourceJoint.Transform
				end)
				if ok and typeof(sourceTransform) == "CFrame" then
					pcall(function()
						cloneJoint.Transform = sourceTransform
					end)
				end
			end
		end
	end

	vars.setLocalTryOnConnection("animationPoseSourceChanged", playerCharacter.DescendantAdded, function(instance)
		markPoseSyncDirty(instance)
	end)
	vars.setLocalTryOnConnection("animationPoseSourceChangedRemoved", playerCharacter.DescendantRemoving, function(instance)
		markPoseSyncDirty(instance)
	end)
	vars.setLocalTryOnConnection("animationPoseCloneChanged", cloneModel.DescendantAdded, function(instance)
		markPoseSyncDirty(instance)
	end)
	vars.setLocalTryOnConnection("animationPoseCloneChangedRemoved", cloneModel.DescendantRemoving, function(instance)
		markPoseSyncDirty(instance)
	end)
	vars.setLocalTryOnConnection("animationPoseSync", vars.RunService.PreSimulation, function()
		if vars.scriptAlive then
			syncEvaluatedPoseToClone()
		end
	end)

	rebuildPoseSyncPairs()

	return function()
		if not vars.scriptAlive or not cloneModel or not cloneModel.Parent then return end

		local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart") or playerCharacter.PrimaryPart
		local moveSpeed, verticalVel, totalVel = 0, 0, 0
		local moveDirectionMagnitude = 0

		if playerRoot then
			local vel = playerRoot.AssemblyLinearVelocity or playerRoot.Velocity
			moveSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
			verticalVel = vel.Y
			totalVel = vel.Magnitude
		end

		if playerHumanoid then
			moveDirectionMagnitude = playerHumanoid.MoveDirection.Magnitude
		end

		local state = playerHumanoid and playerHumanoid:GetState()
		local isSeated = playerHumanoid and (playerHumanoid.Sit or playerHumanoid.SeatPart ~= nil or state == Enum.HumanoidStateType.Seated) or false

		if not isR6 and vars.activeEmotePlayerTrack then
			local activePlayerEmoteTrack = vars.activeEmotePlayerTrack
			local activeCloneEmoteTrack = vars.activeCloneTracks[activePlayerEmoteTrack]
			if activePlayerEmoteTrack.IsPlaying and activeCloneEmoteTrack and activeCloneEmoteTrack.IsPlaying then
				pcall(function() activeCloneEmoteTrack.Looped = true end)
			end
		end

		local intentionalMovement = moveDirectionMagnitude > 0.05 and moveSpeed > 1.2

		local shouldReleaseEmote = isSeated or intentionalMovement
			or state == Enum.HumanoidStateType.Jumping
			or state == Enum.HumanoidStateType.Freefall
			or state == Enum.HumanoidStateType.Climbing
			or state == Enum.HumanoidStateType.Swimming

		if shouldReleaseEmote and next(vars.activeCloneTracks) ~= nil then
			vars.stopCloneEmoteTracks(0.08)
		end

		-- Tool Action tracks are independent from emotes and locomotion.
		for playerTrack, cloneTrack in pairs(vars.activeCloneToolActionTracks) do
			if not playerTrack or not playerTrack.IsPlaying or not cloneTrack or not cloneTrack.Parent then
				vars.stopCloneToolActionTrack(playerTrack, 0.08)
			else
				pcall(function()
					cloneTrack.Priority = getCloneToolActionPriority(playerTrack.Priority)
					cloneTrack.Looped = playerTrack.Looped
					cloneTrack:AdjustWeight(math.max(playerTrack.WeightCurrent, 0), 0.05)
				end)

				local currentSpeed = playerTrack.Speed
				if type(currentSpeed) == "number" then
					pcall(function() cloneTrack:AdjustSpeed(currentSpeed) end)
				end

				if playerTrack.Length > 0 and cloneTrack.Length > 0 then
					local targetPosition = math.clamp(playerTrack.TimePosition, 0, math.max(cloneTrack.Length - 0.001, 0))
					local drift = math.abs(cloneTrack.TimePosition - targetPosition)
					local threshold = math.max(0.08, math.min(cloneTrack.Length * 0.03, 0.20))
					if drift > threshold then
						pcall(function() cloneTrack.TimePosition = targetPosition end)
					end
				end
			end
		end

		-- If a temporary action or emote cleared ToolNone, recover it without
		-- requiring the player to unequip and equip the Tool again.
		if os.clock() - lastToolNoneRecoveryAt >= 0.20
			and next(vars.activeCloneToolActionTracks) == nil
			and vars.activeEmotePlayerTrack == nil then
			local equippedTool = getEquippedTool()
			if equippedTool and not vars.activeCloneHeldPropTracks[equippedTool] then
				lastToolNoneRecoveryAt = os.clock()
				playCloneToolNone(equippedTool)
			end
		end

		local desiredKey = "Idle"
		local climbPlaybackSpeed = 0

		if isSeated and isR6 then
			local sitTrack = loadedTracks.Sit
			if sitTrack then
				for key, track in pairs(loadedTracks) do
					if key ~= "Sit" and track.IsPlaying then
						pcall(function() track:Stop(0.05) end)
					end
				end
				sitTrack.Priority = Enum.AnimationPriority.Action4
				sitTrack.Looped = true
				if not sitTrack.IsPlaying then
					pcall(function() sitTrack:Play(0.08, 1, 1) end)
				else
					pcall(function() sitTrack:AdjustWeight(1, 0.05) end)
				end
				activeKey = "Sit"
				return
			end
			desiredKey = "Sit"
		elseif isSeated then
			desiredKey = "Sit"
		elseif state == Enum.HumanoidStateType.Climbing then
			desiredKey = "Climb"

			if verticalVel > 0.1 then
				climbPlaybackSpeed = math.clamp(verticalVel / 8, 0.4, 2.0)
			elseif verticalVel < -0.1 then
				climbPlaybackSpeed = -math.clamp(math.abs(verticalVel) / 8, 0.4, 2.0)
			end
		elseif state == Enum.HumanoidStateType.Swimming then
			desiredKey = (totalVel > 0.75) and "Swim" or "SwimIdle"
		elseif state == Enum.HumanoidStateType.Jumping then
			desiredKey = "Jump"
		elseif state == Enum.HumanoidStateType.Freefall then
			desiredKey = (activeKey == "Jump" and loadedTracks["Jump"] and loadedTracks["Jump"].IsPlaying and verticalVel > 0.1) and "Jump" or "Fall"
		else
			local hasMovementInput = moveDirectionMagnitude > 0.05

			if hasMovementInput then
				if moveSpeed > 12 and loadedTracks["Run"] then
					desiredKey = "Run"
				elseif moveSpeed > 1.2 then
					desiredKey = loadedTracks["Walk"] and "Walk" or "Run"
				elseif activeKey == "Run" and loadedTracks["Run"] then
					desiredKey = "Run"
				elseif activeKey == "Walk" and loadedTracks["Walk"] then
					desiredKey = "Walk"
				else
					desiredKey = loadedTracks["Walk"] and "Walk" or "Run"
				end
			else
				desiredKey = "Idle"
			end
		end

		if not loadedTracks[desiredKey] then
			if desiredKey == "SwimIdle" then
				desiredKey = loadedTracks["Swim"] and "Swim" or (loadedTracks["Idle"] and "Idle" or "Walk")
			elseif desiredKey == "Swim" then
				desiredKey = loadedTracks["SwimIdle"] and "SwimIdle" or (loadedTracks["Walk"] and "Walk" or "Idle")
			elseif desiredKey == "Run" then
				desiredKey = "Walk"
			end

			if not loadedTracks[desiredKey] then
				desiredKey = "Idle"
			end
		end

		local activeTrack = activeKey and loadedTracks[activeKey]
		local desiredTrack = desiredKey and loadedTracks[desiredKey]

		local sameAnimationAsset = activeTrack
			and desiredTrack
			and activeTrack.Animation
			and desiredTrack.Animation
			and activeTrack.Animation.AnimationId == desiredTrack.Animation.AnimationId

		if activeKey ~= desiredKey and not sameAnimationAsset then
			if activeTrack then
				pcall(function()
					activeTrack:Stop(0.15)
				end)
			end

			activeKey = desiredKey
			activeTrack = loadedTracks[activeKey]

			if activeTrack then
				if activeKey == "Climb" then
					pcall(function()
						activeTrack:Play(0.15, 1, 0)
					end)

					if activeTrack.Length > 0 then
						pcall(function()
							activeTrack.TimePosition = (climbPlaybackSpeed < 0)
								and math.max(activeTrack.Length - 0.001, 0)
								or 0
						end)
					end

					pcall(function()
						activeTrack:AdjustSpeed(climbPlaybackSpeed)
					end)
				else
					pcall(function()
						activeTrack:Play(0.15)
					end)
				end
			end
		elseif activeTrack and not activeTrack.IsPlaying then
			if activeKey == "Climb" then
				pcall(function()
					activeTrack:Play(0.15, 1, 0)
				end)

				if activeTrack.Length > 0 then
					pcall(function()
						activeTrack.TimePosition = (climbPlaybackSpeed < 0)
							and math.max(activeTrack.Length - 0.001, 0)
							or 0
					end)
				end

				pcall(function()
					activeTrack:AdjustSpeed(climbPlaybackSpeed)
				end)
			else
				pcall(function()
					activeTrack:Play(0.15)
				end)
			end
		end

		if activeKey == "Walk" or activeKey == "Run" then
			local currentTrack = loadedTracks[activeKey]

			if currentTrack and currentTrack.IsPlaying then
				pcall(function()
					currentTrack:AdjustSpeed(
						math.clamp(moveSpeed / 14, 0.6, 2.0)
					)
				end)
			end
		elseif activeKey == "Climb" then
			local currentTrack = loadedTracks[activeKey]

			if currentTrack and currentTrack.IsPlaying then
				pcall(function()
					currentTrack:AdjustSpeed(climbPlaybackSpeed)
				end)
			end
		elseif activeKey == "Swim" or activeKey == "SwimIdle" then
			local currentTrack = loadedTracks[activeKey]

			if currentTrack and currentTrack.IsPlaying then
				local targetSpeed = isR6
					and math.clamp(totalVel / 12, 0.5, 1.8)
					or math.clamp(totalVel / 10, 0.6, 2.0)

				if activeKey == "SwimIdle" and totalVel < 0.5 then
					targetSpeed = 1.0
				end

				pcall(function()
					currentTrack:AdjustSpeed(targetSpeed)
				end)
			end
		end
	end
end

vars.queuePreview = function(card, data)	if not vars.scriptAlive or not card or not data or not card.Parent then return end
	local state = vars.previewStates[data]
	if state == "queued" or state == "loading" or state == "ready" then return end

	vars.previewStates[data] = "queued"
	vars.previewQueue[#vars.previewQueue + 1] = {
		Card = card,
		Data = data,
		Generation = vars.previewQueueGeneration
	}
end

vars.preloadAvatarVisualContent = function(model)	if not model then return false end
	local targets = {}
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("MeshPart")
			or instance:IsA("SpecialMesh")
			or instance:IsA("Decal")
			or instance:IsA("Texture") then
			targets[#targets + 1] = instance
		end
	end
	if #targets == 0 then return true end
	return pcall(function() vars.ContentProvider:PreloadAsync(targets) end)
end

vars.createPreviewViewport = function(parentContainer)	if not parentContainer or not parentContainer.Parent then return nil end

	local oldPreview = parentContainer:FindFirstChild("Preview")
	if oldPreview then oldPreview:Destroy() end

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Preview"
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	viewport.BorderSizePixel = 0
	viewport.ZIndex = parentContainer.ZIndex + 1
	viewport.Parent = parentContainer

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local previewCamera = Instance.new("Camera")
	previewCamera.FieldOfView = 30
	previewCamera.Parent = viewport
	viewport.CurrentCamera = previewCamera

	return viewport, worldModel, previewCamera
end

vars.positionPreviewCamera = function(previewCamera, model)	if not previewCamera or not model then return end
	local head = model:FindFirstChild("Head", true)
	local root = model:FindFirstChild("HumanoidRootPart", true) or head or model.PrimaryPart
	if not root then return end

	local cf, size = model:GetBoundingBox()
	if size.Magnitude <= 0 then return end

	local targetPosition = cf.Position + Vector3.new(0, size.Y * 0.04, 0)
	local lookVector = head and head.CFrame.LookVector or root.CFrame.LookVector
	if lookVector.Magnitude == 0 then lookVector = Vector3.new(0, 0, -1) end

	local distance = math.max(math.max(size.Y, size.X, size.Z) * 1.85, 5.5)
	previewCamera.CFrame = CFrame.lookAt(targetPosition + lookVector.Unit * distance, targetPosition)
end

vars.buildPreviewTemplate = function(data, cacheKey)	if not data or not data.Properties then return nil end

	local description = vars.reconstructHumanoidDescription(data.Properties)
	local rigType = vars.getEnumRigType(data.RigType)
	local ok, model = pcall(function()
		if type(vars.Players.CreateHumanoidModelFromDescriptionAsync) == "function" then
			return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
		end
		return vars.Players:CreateHumanoidModelFromDescription(description, rigType)
	end)
	pcall(function() description:Destroy() end)

	if not ok or not model or not model:IsA("Model") then
		if model and typeof(model) == "Instance" then pcall(function() model:Destroy() end) end
		return nil
	end

	model.Parent = nil
	model:PivotTo(CFrame.new(0, 0, 0))
	vars.applyBodyColors(model, data.Properties)
	vars.applyHeadShapeToModel(model, data.Properties)

	if cacheKey then
		vars.previewModelCache[cacheKey] = model
		vars.touchPreviewCache(cacheKey)
	end
	return model
end

vars.renderPreview = function(card, data)	if not card or not card.Parent or not data then return false end
	local previewContainer = card:FindFirstChild("PreviewContainer")
	if not previewContainer then return false end

	local cacheKey = vars.getPreviewCacheKey(data)
	local template = cacheKey and vars.previewModelCache[cacheKey]
	if template and template.Parent ~= nil then
		vars.previewModelCache[cacheKey] = nil
		template = nil
	elseif template then
		vars.touchPreviewCache(cacheKey)
	end

	for attempt = 1, 3 do
		if not vars.scriptAlive or not card.Parent then return false end

		local viewport, worldModel, camera = vars.createPreviewViewport(previewContainer)
		if not viewport then return false end

		if not template then
			template = vars.buildPreviewTemplate(data, cacheKey)
		end

		if template then
			local model
			local cloneOk = pcall(function() model = template:Clone() end)
			if cloneOk and model then
				model.Parent = worldModel
				model:PivotTo(CFrame.new(0, 0, 0))
				task.wait()
				if model.Parent == worldModel and model:FindFirstChildOfClass("Humanoid") then
					local cf, size = model:GetBoundingBox()
			local center = cf.Position + Vector3.new(0, size.Y * 0.03, 0)
			local distance = math.max(size.X, size.Y, size.Z) * vars.previewCameraDistanceMultiplier
			camera.FieldOfView = 35
			camera.CFrame = CFrame.lookAt(center + Vector3.new(0, size.Y * 0.02, distance), center)
					return true
				end
				pcall(function() model:Destroy() end)
			end
		end

		pcall(function() viewport:Destroy() end)
		if attempt < 3 then task.wait(0.12 * attempt) end
	end

	return false
end

vars.processPreviewQueue = function()	if vars.previewQueueRunning then return end
	vars.previewQueueRunning = true

	while vars.scriptAlive and #vars.previewQueue > 0 do
		local taskData = table.remove(vars.previewQueue, 1)
		if taskData and taskData.Generation == vars.previewQueueGeneration then
			local card = taskData.Card
			local data = taskData.Data
			if card and card.Parent and data then
				vars.previewStates[data] = "loading"
				local ok, rendered = pcall(function()
					return vars.renderPreview(card, data)
				end)
				if ok and rendered then
					vars.previewStates[data] = "ready"
				else
					vars.previewStates[data] = "unavailable"
				end
			end
		end
		task.wait(0.04)
	end

	vars.previewQueueRunning = false
end

vars.getAccessoryCount = function(data)	local props = data and data.Properties
	if type(props) ~= "table" then return 0 end

	if type(props.AllAccessories) == "table" then
		local count = 0
		for _, entry in ipairs(props.AllAccessories) do
			if type(entry) == "table" and vars.parseAssetId(entry.AssetId) then
				count += 1
			end
		end
		return count
	end

	local count = 0
	for _, propertyName in ipairs(vars.accessoryPropertyNames) do
		local value = props[propertyName]
		if value ~= nil and tostring(value) ~= "" and tostring(value) ~= "0" then
			for _ in tostring(value):gmatch("%d+") do
				count += 1
			end
		end
	end
	return count
end

vars.hoverPreviewToken = vars.hoverPreviewToken or 0

vars.stopHoverPreview = function()	vars.hoverPreviewToken += 1
	vars.ui.hoverButton = nil
	if vars.ui.hoverConnection then
		vars.disconnectConnection(vars.ui.hoverConnection)
		vars.ui.hoverConnection = nil
	end

	if vars.ui.hoverModel then
		pcall(function() vars.ui.hoverModel:Destroy() end)
		vars.ui.hoverModel = nil
	end

	vars.ui.hoverViewport = nil

	local popup = vars.HoverPreview
	if popup then
		popup.Visible = false
	end
end

vars.createHoverPreviewUI = function()
	local popup = Instance.new("Frame")
	popup.Name = "AvatarHoverPreview"
	popup.Size = UDim2.new(0, vars.previewWidth, 0, vars.mainHeight)
	popup.Position = UDim2.new(0.5, (vars.mainWidth + vars.previewGap + vars.previewWidth) / 2 - vars.previewWidth, 0.5, -vars.mainHeight / 2)
	popup.BackgroundColor3 = vars.COLORS.Background
	popup.BorderSizePixel = 0
	popup.Visible = false
	popup.ZIndex = 30
	popup.Parent = vars.UIRoot
	vars.addCorner(popup, 6)
	vars.addStroke(popup, vars.COLORS.Border, 1)

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 14, 1, 14)
	shadow.Position = UDim2.new(0, -7, 0, -7)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.58
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 29
	shadow.Parent = popup
	vars.addCorner(shadow, 7)

	local title = Instance.new("TextLabel")
	title.Name = "OutfitName"
	title.Size = UDim2.new(1, -28, 0, 30)
	title.Position = UDim2.new(0, 14, 0, 12)
	title.BackgroundTransparency = 1
	title.Text = "3D PREVIEW"
	title.TextColor3 = vars.COLORS.Muted
	title.TextSize = 12
	title.FontFace = vars.uiFont(vars.UI_WEIGHT)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 32
	title.Parent = popup

	local viewportHolder = Instance.new("Frame")
	viewportHolder.Name = "ViewportHolder"
	viewportHolder.Size = UDim2.new(1, -28, 1, -108)
	viewportHolder.Position = UDim2.new(0, 14, 0, 48)
	viewportHolder.BackgroundColor3 = Color3.fromRGB(7, 10, 16)
	viewportHolder.BorderSizePixel = 0
	viewportHolder.ClipsDescendants = true
	viewportHolder.ZIndex = 31
	viewportHolder.Parent = popup
	vars.addCorner(viewportHolder, 5)
	vars.addStroke(viewportHolder, Color3.fromRGB(25, 38, 58), 1)

	local info = Instance.new("TextLabel")
	info.Name = "Info"
	info.Size = UDim2.new(1, -28, 0, 20)
	info.Position = UDim2.new(0, 14, 1, -55)
	info.BackgroundTransparency = 1
	info.Text = "R15  •  0 accessories"
	info.TextColor3 = vars.COLORS.Muted
	info.TextSize = 11
	info.FontFace = vars.uiFont(Enum.FontWeight.Medium)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.ZIndex = 32
	info.Parent = popup

	local previewStatus = Instance.new("TextLabel")
	previewStatus.Name = "PreviewStatus"
	previewStatus.Size = UDim2.new(1, -24, 1, -24)
	previewStatus.Position = UDim2.new(0, 12, 0, 12)
	previewStatus.BackgroundTransparency = 1
	previewStatus.Text = ""
	previewStatus.TextColor3 = vars.COLORS.Muted
	previewStatus.TextSize = 12
	previewStatus.FontFace = vars.uiFont(Enum.FontWeight.Medium)
	previewStatus.TextWrapped = true
	previewStatus.TextXAlignment = Enum.TextXAlignment.Center
	previewStatus.TextYAlignment = Enum.TextYAlignment.Center
	previewStatus.Visible = false
	previewStatus.ZIndex = 34
	previewStatus.Parent = viewportHolder

	local bottomName = Instance.new("TextLabel")
	bottomName.Name = "BottomOutfitName"
	bottomName.Size = UDim2.new(1, -28, 0, 25)
	bottomName.Position = UDim2.new(0, 14, 1, -34)
	bottomName.BackgroundTransparency = 1
	bottomName.Text = "Outfit"
	bottomName.TextColor3 = vars.COLORS.Text
	bottomName.TextSize = 13
	bottomName.FontFace = vars.uiFont(vars.UI_WEIGHT)
	bottomName.TextXAlignment = Enum.TextXAlignment.Left
	bottomName.TextTruncate = Enum.TextTruncate.AtEnd
	bottomName.ZIndex = 32
	bottomName.Parent = popup

	return popup
end
vars.HoverPreview = vars.createHoverPreviewUI()

vars.updateHoverPreviewPosition = function()
	local popup = vars.HoverPreview
	if not popup or not vars.Main then return end

	popup.Position = UDim2.new(
		vars.Main.Position.X.Scale,
		vars.Main.Position.X.Offset + vars.mainWidth + vars.previewGap,
		vars.Main.Position.Y.Scale,
		vars.Main.Position.Y.Offset
	)
end

vars.showHoverPreview = function(data)
	if not vars.scriptAlive or not data then return end

	vars.stopHoverPreview()
	local token = vars.hoverPreviewToken

	local popup = vars.HoverPreview
	vars.updateHoverPreviewPosition()
	local title = popup:FindFirstChild("OutfitName")
	local bottomName = popup:FindFirstChild("BottomOutfitName")
	local info = popup:FindFirstChild("Info")
	local holder = popup:FindFirstChild("ViewportHolder")
	local status = holder and holder:FindFirstChild("PreviewStatus")
	if not title or not bottomName or not info or not holder or not status then return end

	local outfitName = tostring(data.DisplayName or data.Name or "Unnamed Outfit")
	title.Text = "3D PREVIEW"
	bottomName.Text = outfitName
	info.Text = string.upper(tostring(data.RigType or "Unknown"))
		.. "  •  " .. tostring(vars.getAccessoryCount(data)) .. " accessories"

	
	
	popup.Visible = true
	status.Text = "Loading preview..."
	status.Visible = true

	local viewport, worldModel, camera = vars.createPreviewViewport(holder)
	if not viewport then
		status.Text = "Preview error:\nCould not create the viewport."
		status.Visible = true
		return
	end

	task.spawn(function()
		local ok, err = xpcall(function()
			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then return end

			local cacheKey = vars.getPreviewCacheKey(data)
			local template = cacheKey and vars.previewModelCache[cacheKey]

			if template and template.Parent ~= nil then
				vars.previewModelCache[cacheKey] = nil
				template = nil
			elseif template then
				vars.touchPreviewCache(cacheKey)
			end

			if not template then
				template = vars.buildPreviewTemplate(data, cacheKey)
			end

			if not template then
				error("buildPreviewTemplate returned no model")
			end

			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then return end

			local cloneOk, model = pcall(function()
				return template:Clone()
			end)
			if not cloneOk or not model then
				error("failed to clone the preview model: " .. tostring(model))
			end

			model.Parent = worldModel
			model:PivotTo(CFrame.new(0, 0, 0))
			vars.ui.hoverModel = model
			vars.ui.hoverViewport = viewport

			local cameraOk, cameraErr = pcall(function()
				vars.positionPreviewCamera(camera, model)
				camera.FieldOfView = 35
			end)
			if not cameraOk then
				pcall(function() model:Destroy() end)
				error("camera setup failed: " .. tostring(cameraErr))
			end

			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then
				pcall(function() model:Destroy() end)
				return
			end

			status.Text = ""
			status.Visible = false

			local angle = 0
			vars.ui.hoverConnection = vars.RunService.RenderStepped:Connect(function(dt)
				if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible or not model.Parent then
					vars.stopHoverPreview()
					return
				end

				vars.updateHoverPreviewPosition()
				angle += dt * math.rad(75)
				pcall(function()
					model:PivotTo(CFrame.Angles(0, angle, 0))
				end)
			end)
		end, debug.traceback)

		if not ok and vars.scriptAlive and token == vars.hoverPreviewToken and popup.Visible then
			pcall(function()
				if vars.ui.hoverModel then
					vars.ui.hoverModel:Destroy()
					vars.ui.hoverModel = nil
				end
			end)
			vars.ui.hoverViewport = nil
			status.Text = "Preview error:\n" .. tostring(err)
			status.Visible = true
		end
	end)
end

vars.clearAvatarCards = function()	vars.previewQueueGeneration += 1
	table.clear(vars.previewQueue)
	table.clear(vars.previewStates)
	table.clear(vars.ui.avatarRows)
	vars.clearPreviewModelCache()
	vars.stopHoverPreview()

	for _, child in ipairs(vars.List:GetChildren()) do
		if child:IsA("Frame") and child.Name == "AvatarRow" then
			child:Destroy()
		end
	end
end

vars.updateRowVisuals = function(selectedData)	for data, row in pairs(vars.ui.avatarRows) do
		if row and row.Parent then
			local button = row:FindFirstChild("AvatarName")
			local selected = data == selectedData

			if button then
				button.BackgroundColor3 = vars.COLORS.Surface2
				button.Text = tostring(data.DisplayName or data.Name or "Unnamed Avatar")
				local marker = button:FindFirstChild("SelectionMarker")
				if marker then marker.Visible = selected end
			end
		end
	end
end

vars.deleteAvatar = function(data)
	if not data then return end
	if data.Source == "legacy" then
		if type(writefile) ~= "function" then
			vars.showDiagnostics("Cannot delete avatar.", "The executor does not provide writefile().")
			return
		end
		local newList = {}
		local removed = false
		for _, entry in ipairs(vars.ui.savedAvatars) do
			if entry == data then
				removed = true
			else
				newList[#newList + 1] = entry
			end
		end
		if not removed then return end
		local ok, err = pcall(function()
			local legacyOnly = {}
			for _, entry in ipairs(newList) do
				if entry.Source == "legacy" then
					local copy = {}
					for key, value in pairs(entry) do
						if key ~= "Source" and key ~= "FilePath" and not (key == "FileName" and value == "SavedAvatars.json") then
							copy[key] = value
						end
					end
					legacyOnly[#legacyOnly + 1] = copy
				end
			end
			writefile(vars.FILE_PATH, vars.HttpService:JSONEncode(legacyOnly))
		end)
		if not ok then
			vars.showDiagnostics("Failed to delete avatar.", tostring(err))
			return
		end
		vars.ui.savedAvatars = newList
		if vars.ui.selectedAvatar == data then vars.ui.selectedAvatar = nil end
		vars.Status.Text = "[OK] Deleted legacy avatar: " .. tostring(data.DisplayName or data.Name or "avatar")
		vars.StatusDot.BackgroundColor3 = vars.COLORS.Success
		vars.clearDiagnostics()
		vars.populateAvatarList()
		return
	end
	local path = data.FilePath
	if not path and data.FileName then path = vars.AVATARS_FOLDER .. "/" .. tostring(data.FileName) end
	if not path or type(delfile) ~= "function" then
		vars.showDiagnostics("Cannot delete avatar.", "The executor does not provide delfile().")
		return
	end
	local ok, err = pcall(function() delfile(path) end)
	if not ok then vars.showDiagnostics("Failed to delete avatar.", tostring(err)) return end
	for index = #vars.ui.savedAvatars, 1, -1 do
		if vars.ui.savedAvatars[index] == data then table.remove(vars.ui.savedAvatars, index) break end
	end
	if vars.ui.selectedAvatar == data then vars.ui.selectedAvatar = nil end
	vars.Status.Text = "[OK] Deleted: " .. tostring(data.DisplayName or data.Name or "avatar")
	vars.StatusDot.BackgroundColor3 = vars.COLORS.Success
	vars.clearDiagnostics()
	vars.populateAvatarList()
end

vars.showRenameDialog = function(data)
	if not data then return end
	vars.RenameTarget = data
	vars.RenameInput.Text = tostring(data.DisplayName or data.Name or "")
	vars.RenameOverlay.Visible = true
	task.defer(function()
		vars.RenameInput:CaptureFocus()
		vars.RenameInput.CursorPosition = #vars.RenameInput.Text + 1
	end)
end

vars.createAvatarCard = function(data, index)
	local Row = Instance.new("Frame")
	Row.Name = "AvatarRow"
	Row.Size = UDim2.new(1, -2, 0, 44)
	Row.BackgroundColor3 = vars.COLORS.Surface
	Row.BorderSizePixel = 0
	Row.LayoutOrder = index
	Row.Parent = vars.List
	vars.addCorner(Row, 5)
	vars.addStroke(Row, vars.COLORS.Border, 1)

	local AvatarName = Instance.new("TextButton")
	AvatarName.Name = "AvatarName"
	AvatarName.Size = UDim2.new(1, -123, 1, -8)
	AvatarName.Position = UDim2.new(0, 5, 0, 4)
	AvatarName.BackgroundColor3 = vars.COLORS.Surface2
	AvatarName.BorderSizePixel = 0
	AvatarName.Text = tostring(data.DisplayName or data.Name or "Unnamed Avatar")
	AvatarName.TextColor3 = vars.COLORS.Text
	AvatarName.TextSize = 13
	AvatarName.TextScaled = true
	AvatarName.FontFace = vars.uiFont(vars.UI_WEIGHT)
	AvatarName.TextXAlignment = Enum.TextXAlignment.Left
	AvatarName.TextTruncate = Enum.TextTruncate.AtEnd
	AvatarName.AutoButtonColor = false
	AvatarName.Parent = Row
	vars.addPadding(AvatarName, 4)
	vars.addCorner(AvatarName, 5)
	vars.addStroke(AvatarName, vars.COLORS.Border, 1)

	local nameConstraint = Instance.new("UITextSizeConstraint")
	nameConstraint.MaxTextSize = 16
	nameConstraint.MinTextSize = 12
	nameConstraint.Parent = AvatarName

	local selectionMarker = Instance.new("Frame")
	selectionMarker.Name = "SelectionMarker"
	selectionMarker.Size = UDim2.new(0, 42, 1, 0)
	selectionMarker.Position = UDim2.new(1, -42, 0, 0)
	selectionMarker.BackgroundColor3 = vars.COLORS.Accent
	selectionMarker.BackgroundTransparency = 0.15
	selectionMarker.BorderSizePixel = 0
	selectionMarker.Visible = vars.ui.selectedAvatar == data
	selectionMarker.ZIndex = AvatarName.ZIndex + 1
	selectionMarker.Active = false
	selectionMarker.Parent = AvatarName
	vars.addGradient(selectionMarker, Color3.fromRGB(80,80,80), 0).Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})

	local Rename = Instance.new("TextButton")
	Rename.Name = "Rename"
	Rename.Size = UDim2.fromOffset(32, 28)
	Rename.Position = UDim2.new(1, -112, 0.5, -14)
	Rename.BackgroundColor3 = vars.COLORS.Surface3
	Rename.BorderSizePixel = 0
	Rename.Text = ""
	Rename.AutoButtonColor = false
	Rename.Parent = Row
	vars.addCorner(Rename, 5)
	vars.addStroke(Rename, vars.COLORS.Border, 1)
	local renameIcon = vars.createBuilderIcon(Rename, "Icon", vars.BUILDER_ICONS.Rename, 15, vars.COLORS.Muted)
	renameIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	renameIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	local Hover3D = Instance.new("TextButton")
	Hover3D.Name = "Hover3D"
	Hover3D.Size = UDim2.fromOffset(32, 28)
	Hover3D.Position = UDim2.new(1, -76, 0.5, -14)
	Hover3D.BackgroundColor3 = vars.COLORS.Surface3
	Hover3D.Text = ""
	Hover3D.AutoButtonColor = false
	Hover3D.Parent = Row
	vars.addCorner(Hover3D, 5)
	vars.addStroke(Hover3D, vars.COLORS.Border, 1)
	local previewIcon = vars.createBuilderIcon(Hover3D, "Icon", vars.BUILDER_ICONS.Preview3D, 15, vars.COLORS.Muted)
	previewIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	previewIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	local DeleteButton = Instance.new("TextButton")
	DeleteButton.Name = "Delete"
	DeleteButton.Size = UDim2.fromOffset(32, 28)
	DeleteButton.Position = UDim2.new(1, -40, 0.5, -14)
	DeleteButton.BackgroundColor3 = Color3.fromRGB(34, 22, 29)
	DeleteButton.BorderSizePixel = 0
	DeleteButton.Text = ""
	DeleteButton.AutoButtonColor = false
	DeleteButton.Parent = Row
	vars.addCorner(DeleteButton, 5)
	vars.addStroke(DeleteButton, Color3.fromRGB(78, 42, 52), 1)
	local deleteIcon = vars.createBuilderIcon(DeleteButton, "Icon", vars.BUILDER_ICONS.Delete, 15, Color3.fromRGB(220, 100, 120))
	deleteIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	deleteIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	vars.wire(AvatarName.MouseEnter, function()
		vars.TweenService:Create(AvatarName, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 30, 32)}):Play()
	end)
	vars.wire(AvatarName.MouseLeave, function()
		vars.TweenService:Create(AvatarName, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface2}):Play()
	end)
	vars.wire(AvatarName.Activated, function()
		if vars.ui.selectedAvatar == data and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding) then
			
			vars.tryOnActive = false
			vars.stopLocalTryOn(false)
			vars.ui.selectedAvatar = nil
			vars.updateRowVisuals(nil)
			vars.Status.Text = "Local try-on cleared."
			vars.clearDiagnostics()
			return
		end

		if vars.ui.selectedAvatar ~= data and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding) then
			vars.tryOnActive = false
			vars.stopLocalTryOn(false)
		end

		vars.ui.selectedAvatar = data
		vars.updateRowVisuals(data)
		vars.Status.Text = "[...] Wearing: " .. tostring(data.DisplayName or data.Name or "avatar")
		vars.StatusDot.BackgroundColor3 = vars.COLORS.Accent
		vars.clearDiagnostics()
		task.defer(function()
			if vars.scriptAlive and vars.ui.selectedAvatar == data then vars.tryOnSelectedAvatarLocally() end
		end)
	end)

	vars.wire(Rename.MouseEnter, function()
		vars.TweenService:Create(Rename, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 48)}):Play()
		vars.TweenService:Create(renameIcon, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Text}):Play()
	end)
	vars.wire(Rename.MouseLeave, function()
		vars.TweenService:Create(Rename, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface3}):Play()
		vars.TweenService:Create(renameIcon, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Muted}):Play()
	end)
	vars.wire(Rename.Activated, function() vars.showRenameDialog(data) end)

	vars.wire(Hover3D.MouseEnter, function()
		vars.ui.hoverButton = Hover3D
		vars.TweenService:Create(Hover3D, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 48)}):Play()
		vars.TweenService:Create(previewIcon, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Text}):Play()
		vars.showHoverPreview(data)
	end)
	vars.wire(Hover3D.MouseLeave, function()
		if vars.ui.hoverButton == Hover3D then vars.ui.hoverButton = nil end
		vars.TweenService:Create(Hover3D, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface3}):Play()
		vars.TweenService:Create(previewIcon, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Muted}):Play()
		vars.stopHoverPreview()
	end)
	vars.wire(Hover3D.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			vars.stopHoverPreview()
		end
	end)

	vars.wire(DeleteButton.MouseEnter, function()
		vars.TweenService:Create(DeleteButton, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Danger}):Play()
		vars.TweenService:Create(deleteIcon, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Text}):Play()
	end)
	vars.wire(DeleteButton.MouseLeave, function()
		vars.TweenService:Create(DeleteButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34, 22, 29)}):Play()
		vars.TweenService:Create(deleteIcon, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(220, 100, 120)}):Play()
	end)
	vars.wire(DeleteButton.Activated, function()
		vars.showConfirmation('Delete "' .. tostring(data.DisplayName or data.Name or "this avatar") .. '" from your saved avatars?', function() vars.deleteAvatar(data) end)
	end)

	vars.ui.avatarRows[data] = Row
end
vars.filterAvatarCards = function(query)	query = string.lower(string.match(tostring(query or ""), "^%s*(.-)%s*$"))
	local shown = 0

	for _, data in ipairs(vars.ui.savedAvatars) do
		local matches = query == ""
			or string.lower(tostring(data.DisplayName or "")):find(query, 1, true)
			or string.lower(tostring(data.Name or "")):find(query, 1, true)
			or string.lower(tostring(data.FileName or "")):find(query, 1, true)
			or string.lower(tostring(data.UserId or "")):find(query, 1, true)
			or string.lower(tostring(data.RigType or "")):find(query, 1, true)

		local row = vars.ui.avatarRows[data]
		if row and row.Parent then
			row.Visible = matches
			if matches then shown += 1 end
		end
	end

	vars.Status.Text = "[File] " .. tostring(shown) .. "/" .. tostring(#vars.ui.savedAvatars) .. " avatar(s) shown"
end

vars.populateAvatarList = function()	vars.clearAvatarCards()
	for index, data in ipairs(vars.ui.savedAvatars) do
		vars.createAvatarCard(data, index)
	end
	vars.filterAvatarCards(vars.SearchBox.Text)
end

vars.restoreLocalCharacter = function()	for part, oldTransparency in pairs(vars.hiddenCharacterParts) do
		pcall(function()
			if part and part.Parent then part.LocalTransparencyModifier = oldTransparency end
		end)
	end
	table.clear(vars.hiddenCharacterParts)

	for decal, oldTransparency in pairs(vars.hiddenCharacterDecals) do
		pcall(function()
			if decal and decal.Parent then decal.Transparency = oldTransparency end
		end)
	end
	table.clear(vars.hiddenCharacterDecals)
end

vars.destroyOrphanedLocalTryOnModels = function(exceptModel)	for _, instance in ipairs(vars.Workspace:GetDescendants()) do
		if instance:IsA("Model") and instance.Name == "LocalWearer_LocalTryOn" and instance ~= exceptModel then
			pcall(function() instance:Destroy() end)
		end
	end
end

vars.capturePlaceholderR6Backup = function(character)
	if not character or not character.Parent then return nil end
	local backup = {Character = character, Items = {}, PartAppearance = {}, HeadVisuals = {}}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants")
			or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
			local ok, clone = pcall(function() return child:Clone() end)
			if ok and clone then backup.Items[#backup.Items + 1] = clone end
		end
	end
	for _, name in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			backup.PartAppearance[name] = {Color = part.Color, Material = part.Material}
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
				local ok, clone = pcall(function() return child:Clone() end)
				if ok and clone then backup.HeadVisuals[#backup.HeadVisuals + 1] = clone end
			end
		end
	end
	return backup
end

vars.clearPlaceholderR6Appearance = function(character)
	if not character then return end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants")
			or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
			pcall(function() child:Destroy() end)
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
				pcall(function() child:Destroy() end)
			end
		end
	end
end

vars.restorePlaceholderR6 = function()
	local backup = vars.placeholderR6Backup
	vars.placeholderR6Backup = nil
	vars.placeholderR6Active = false
	vars.placeholderR6Building = false
	if not backup then return end
	local character = backup.Character
	if not character or not character.Parent then
		for _, item in ipairs(backup.Items or {}) do pcall(function() item:Destroy() end) end
		for _, item in ipairs(backup.HeadVisuals or {}) do pcall(function() item:Destroy() end) end
		return
	end
	vars.clearPlaceholderR6Appearance(character)
	for name, appearance in pairs(backup.PartAppearance or {}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			pcall(function() part.Color = appearance.Color end)
			pcall(function() part.Material = appearance.Material end)
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, item in ipairs(backup.HeadVisuals or {}) do pcall(function() item.Parent = head end) end
	end
	for _, item in ipairs(backup.Items or {}) do pcall(function() item.Parent = character end) end
end

vars.applyPlaceholderR6 = function(selectedData)
	if vars.placeholderR6Building then return false, "Already applying placeholder mode." end
	
	if vars.placeholderR6Active or vars.placeholderR6Backup then
		vars.restorePlaceholderR6()
	end
	local character = vars.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not character.Parent or not humanoid then return false, "Your character is not available." end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return false, "R15 uses the normal local try-on path."
	end
	if not selectedData or not selectedData.Properties then return false, "The selected avatar has no saved properties." end

	vars.placeholderR6Building = true
	vars.placeholderR6Backup = vars.capturePlaceholderR6Backup(character)
	if not vars.placeholderR6Backup then
		vars.placeholderR6Building = false
		return false, "Could not back up your current R6 appearance."
	end

	local description = vars.reconstructHumanoidDescription(selectedData.Properties)
	local okCreate, modelOrError = pcall(function()
		return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R6)
	end)
	pcall(function() description:Destroy() end)
	if not okCreate or not modelOrError or not modelOrError:IsA("Model") then
		vars.restorePlaceholderR6()
		return false, tostring(modelOrError)
	end

	local model = modelOrError
	local ok, err = xpcall(function()
		vars.clearPlaceholderR6Appearance(character)
		local bp = {
			Head = character:FindFirstChild("Head"), Torso = character:FindFirstChild("Torso"),
			["Left Arm"] = character:FindFirstChild("Left Arm"), ["Right Arm"] = character:FindFirstChild("Right Arm"),
			["Left Leg"] = character:FindFirstChild("Left Leg"), ["Right Leg"] = character:FindFirstChild("Right Leg"),
		}
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("Accessory") then
				local a = child:Clone()
				local handle = a:FindFirstChild("Handle")
				if handle then
					handle.Anchored = false
					handle.CanCollide = false
					handle.CanTouch = false
					handle.CanQuery = false
					handle.Massless = true
					local at = handle:FindFirstChildWhichIsA("Attachment")
					local targetAttachment = at and character:FindFirstChild(at.Name, true)
					local part = targetAttachment and targetAttachment.Parent:IsA("BasePart") and targetAttachment.Parent or bp.Head or bp.Torso
					if targetAttachment and targetAttachment.Parent:IsA("BasePart") then
						handle.CFrame = targetAttachment.WorldCFrame * at.CFrame:Inverse()
					elseif at and part then
						handle.CFrame = part.CFrame * CFrame.new(at.Position)
					elseif part then
						handle.CFrame = part.CFrame
					end
					if part then
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = handle; weld.Part1 = part; weld.Parent = handle
					end
					for _, q in ipairs(a:GetDescendants()) do
						if q:IsA("BasePart") and q ~= handle then
							q.CanCollide = false; q.CanTouch = false; q.CanQuery = false; q.Massless = true
							if part then
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = q; weld.Part1 = handle; weld.Parent = q
							end
						end
					end
					a.Parent = character
				else a:Destroy() end
			elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
				child:Clone().Parent = character
			end
		end
		for _, name in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
			local sourcePart, targetPart = model:FindFirstChild(name), character:FindFirstChild(name)
			if sourcePart and targetPart and sourcePart:IsA("BasePart") and targetPart:IsA("BasePart") then
				targetPart.Color = sourcePart.Color
				targetPart.Material = sourcePart.Material
			end
		end
		local sourceHead, targetHead = model:FindFirstChild("Head"), character:FindFirstChild("Head")
		if sourceHead and targetHead then
			for _, child in ipairs(sourceHead:GetChildren()) do
				if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
					child:Clone().Parent = targetHead
				end
			end
		end
	end, debug.traceback)
	pcall(function() model:Destroy() end)
	if not ok then
		vars.restorePlaceholderR6()
		return false, tostring(err)
	end
	vars.placeholderR6Building = false
	vars.placeholderR6Active = true
	return true
end

vars.stopLocalTryOn = function(preserveActiveState)
	vars.localTryOnBuildId = vars.localTryOnBuildId + 1

	if vars.placeholderR6Active or vars.placeholderR6Backup then
		vars.restorePlaceholderR6()
	end

	vars.localTryOnBuilding = false
	vars.localTryOnMissingRecoveryPending = false

	if not preserveActiveState then
		vars.tryOnActive = false
	end

	vars.cleanupAnimationSync()
	vars.destroyLocalTryOnToolVisual()
	vars.disconnectLocalTryOnConnections()

	if vars.localTryOnModel then
		pcall(function()
			vars.localTryOnModel:Destroy()
		end)

		vars.localTryOnModel = nil
	end

	vars.destroyOrphanedLocalTryOnModels(nil)

	-- Stop using the real character as the replication source and restore its
	-- original Animate asset IDs before the local try-on ends.
	vars.restoreSelectedAvatarAnimations()

	vars.resetLocalTryOnState()
	vars.restoreLocalCharacter()
	vars.updateWearButtonState()
end

vars.abortLocalTryOnForSeatedPlayer = function()	vars.stopLocalTryOn(false)
	vars.WearButton.Active = true
	vars.updateWearButtonState()
	vars.showSeatedTryOnBlocked()
end

vars.CHARACTER_BODY_PART_NAMES = {
	Head = true,
	HumanoidRootPart = true,
	Torso = true,
	UpperTorso = true,
	LowerTorso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

vars.getCharacterTopLevel = function(instance, character)	local current = instance
	while current and current.Parent and current.Parent ~= character do
		current = current.Parent
	end
	return current and current.Parent == character and current or nil
end

vars.isExternalCharacterAttachment = function(instance, character)	if instance:FindFirstAncestorOfClass("Tool") or instance:FindFirstAncestorOfClass("VehicleSeat") then
		return true
	end

	local topLevel = vars.getCharacterTopLevel(instance, character)
	if not topLevel then return true end

	if topLevel:IsA("Accessory") then
		return false
	end

	local modelAncestor = instance:FindFirstAncestorOfClass("Model")
	if modelAncestor and modelAncestor ~= character then
		return true
	end

	if topLevel:IsA("BasePart") and vars.CHARACTER_BODY_PART_NAMES[topLevel.Name] then
		if instance:IsA("BasePart") and instance ~= topLevel and instance.Parent == topLevel and not vars.CHARACTER_BODY_PART_NAMES[instance.Name] then
			return true
		end
		return false
	end

	return true
end

vars.hideCharacterInstance = function(instance)	if not instance then return end
	local character = vars.LocalPlayer.Character
	if not character or not instance:IsDescendantOf(character) then return end

	-- The real character is never allowed to remain visible behind the local
	-- try-on avatar. Every original visual part, including normal Accessories
	-- and game-owned props, is hidden here. The prop layer below is responsible
	-- for recreating only the game-owned visuals that must survive the outfit.
	if instance:IsA("BasePart") then
		if vars.hiddenCharacterParts[instance] == nil then
			vars.hiddenCharacterParts[instance] = instance.LocalTransparencyModifier
		end
		instance.LocalTransparencyModifier = 1
	elseif instance:IsA("Decal") or instance:IsA("Texture") then
		if vars.hiddenCharacterDecals[instance] == nil then
			vars.hiddenCharacterDecals[instance] = instance.Transparency
		end
		instance.Transparency = 1
	end
end

vars.hideCharacterLocally = function(character)	if not character then return end
	for _, instance in ipairs(character:GetDescendants()) do
		vars.hideCharacterInstance(instance)
	end
	vars.setLocalTryOnConnection("visibility", character.DescendantAdded, vars.hideCharacterInstance)
end

vars.enforceCharacterHidden = function()	for part in pairs(vars.hiddenCharacterParts) do
		if part and part.Parent and part.LocalTransparencyModifier ~= 1 then
			part.LocalTransparencyModifier = 1
		end
	end
	for decal in pairs(vars.hiddenCharacterDecals) do
		if decal and decal.Parent and decal.Transparency ~= 1 then
			decal.Transparency = 1
		end
	end
end

vars.isFirstPersonCamera = function(character)	local camera = vars.Workspace.CurrentCamera
	local head = character and character:FindFirstChild("Head", true)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not camera or not head or not humanoid then return false end

	local cameraDistance = (camera.CFrame.Position - head.Position).Magnitude
	local cameraFollowsCharacter = camera.CameraSubject == humanoid or (camera.CameraSubject and camera.CameraSubject:IsDescendantOf(character))
	return cameraFollowsCharacter and cameraDistance <= 1.65
end

vars.setLocalTryOnFirstPersonVisibility = function(hidden)	if not vars.localTryOnModel or vars.localTryOnHiddenInFirstPerson == hidden then return end
	vars.localTryOnHiddenInFirstPerson = hidden

	for _, instance in ipairs(vars.localTryOnModel:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = hidden and 1 or 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = hidden and 1 or 0 end)
		end
	end
end

vars.disableLocalTryOnCollision = function(instance)	if not instance or not instance:IsA("BasePart") then return end
	vars.localTryOnCollisionParts[instance] = true
	pcall(function()
		if instance.CanCollide then instance.CanCollide = false end
		if instance.CanTouch then instance.CanTouch = false end
		if instance.CanQuery then instance.CanQuery = false end
		if not instance.Massless then instance.Massless = true end
	end)
end

vars.enforceLocalTryOnNoCollision = function()	for instance in pairs(vars.localTryOnCollisionParts) do
		if instance and instance.Parent then
			pcall(function()
				if instance.CanCollide then instance.CanCollide = false end
				if instance.CanTouch then instance.CanTouch = false end
				if instance.CanQuery then instance.CanQuery = false end
				if not instance.Massless then instance.Massless = true end
			end)
		else
			vars.localTryOnCollisionParts[instance] = nil
		end
	end
end

vars.isLocalTryOnModelValid = function(model)	if not model or not model:IsA("Model") then return false end
	if not model:IsDescendantOf(vars.Workspace) then return false end
	if not model:FindFirstChildOfClass("Humanoid") then return false end
	local root = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
	return root ~= nil and root:IsA("BasePart")
end

vars.isLocalTryOnTool = function(tool)
	return tool and tool:IsA("Tool")
end

vars.getLocalTryOnEquippedTool = function(character)
	if not character then return nil end
	for _, child in ipairs(character:GetChildren()) do
		if vars.isLocalTryOnTool(child) then
			return child
		end
	end
	return nil
end

local function getAllLocalTryOnCharacterTools(character)
	local tools = {}
	local seen = {}
	if not character then return tools end
	-- Some experiences keep persistent Tools inside a small folder/model under
	-- Character instead of parenting the Tool directly to Character. Discover
	-- the whole Character tree, but never duplicate the same Tool twice.
	for _, instance in ipairs(character:GetDescendants()) do
		if vars.isLocalTryOnTool(instance) and not seen[instance] then
			seen[instance] = true
			tools[#tools + 1] = instance
		end
	end
	return tools
end

local function getToolHand(character)
	return character and (character:FindFirstChild("RightHand", true) or character:FindFirstChild("Right Arm", true)) or nil
end

local function getToolHandle(tool)
	if not tool then return nil end
	local handle = tool:FindFirstChild("Handle", true)
	return handle and handle:IsA("BasePart") and handle or nil
end

local function getFirstToolBasePart(tool)
	if not tool then return nil end
	for _, instance in ipairs(tool:GetDescendants()) do
		if instance:IsA("BasePart") then
			return instance
		end
	end
	return nil
end

local function buildVisualPairMap(sourceRoot, visualRoot)
	local pairs = {}
	local function recurse(source, visual)
		pairs[source] = visual
		local sourceChildren = source:GetChildren()
		local visualChildren = visual:GetChildren()
		local used = {}
		for _, sourceChild in ipairs(sourceChildren) do
			local selected = nil
			for _, visualChild in ipairs(visualChildren) do
				if not used[visualChild]
					and visualChild.Name == sourceChild.Name
					and visualChild.ClassName == sourceChild.ClassName then
					selected = visualChild
					break
				end
			end
			if selected then
				used[selected] = true
				recurse(sourceChild, selected)
			end
		end
	end
	recurse(sourceRoot, visualRoot)
	return pairs
end

local function destroyVisualToolJoints(root)
	for _, instance in ipairs(root:GetDescendants()) do
		if instance:IsA("JointInstance") or instance:IsA("WeldConstraint") or instance:IsA("Constraint") then
			pcall(function() instance:Destroy() end)
		end
	end
end

local function setVisualToolAppearance(sourceTool, visualTool, visible)
	for _, instance in ipairs(visualTool:GetDescendants()) do
		if instance:IsA("BasePart") then
			local sourceInstance = nil
			for _, candidate in ipairs(sourceTool:GetDescendants()) do
				if candidate.Name == instance.Name and candidate.ClassName == instance.ClassName and candidate:IsA("BasePart") then
					sourceInstance = candidate
					break
				end
			end
			if visible then
				pcall(function() instance.LocalTransparencyModifier = sourceInstance and sourceInstance.LocalTransparencyModifier or 0 end)
			else
				pcall(function() instance.LocalTransparencyModifier = 1 end)
			end
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			if not visible then
				pcall(function() instance.Transparency = 1 end)
			end
		end
	end
end

local function cloneArchivableInstance(source)
	if not source then return nil end
	local changed = {}
	local function rememberAndEnable(instance)
		local ok, archivable = pcall(function() return instance.Archivable end)
		if ok and archivable == false then
			changed[#changed + 1] = instance
			pcall(function() instance.Archivable = true end)
		end
	end
	rememberAndEnable(source)
	for _, descendant in ipairs(source:GetDescendants()) do
		rememberAndEnable(descendant)
	end
	local ok, clone = pcall(function() return source:Clone() end)
	for _, instance in ipairs(changed) do
		pcall(function() instance.Archivable = false end)
	end
	return ok and clone or nil
end

local function cloneOneLocalTryOnTool(character, cloneModel, sourceTool)
	if not sourceTool or not sourceTool:IsA("Tool") or not sourceTool:IsDescendantOf(character) then return nil end
	-- Tools used as persistent back/waist props are frequently marked
	-- Archivable=false by the experience. Use the same safe cloning path as
	-- the working Accessory/Model visual layer instead of silently failing.
	local visualTool = cloneArchivableInstance(sourceTool)
	if not visualTool then return nil end

	visualTool.Name = "LocalWearer_ToolVisual_" .. tostring(sourceTool.Name)
	local entry = {
		source = sourceTool,
		visual = visualTool,
		pairs = nil,
		sourceAnchor = getToolHandle(sourceTool) or getFirstToolBasePart(sourceTool),
		visualAnchor = nil,
		lastRelativePairs = {},
	}

	entry.pairs = buildVisualPairMap(sourceTool, visualTool)

	for _, instance in ipairs(visualTool:GetDescendants()) do
		if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("ParticleEmitter")
			or instance:IsA("Trail")
			or instance:IsA("Beam")
			or instance:IsA("Smoke")
			or instance:IsA("Fire")
			or instance:IsA("Sparkles")
			or instance:IsA("Light") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("BasePart") then
			instance.Anchored = false
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
		end
	end

	destroyVisualToolJoints(visualTool)
	visualTool.Parent = cloneModel
	entry.visualAnchor = getToolHandle(visualTool) or getFirstToolBasePart(visualTool)
	if not entry.sourceAnchor or not entry.visualAnchor then
		pcall(function() visualTool:Destroy() end)
		return nil
	end

	vars.localTryOnToolVisualEntries[sourceTool] = entry
	return entry
end

local function updateOneLocalTryOnToolVisual(character, entry)
	local sourceTool = entry and entry.source
	local visualTool = entry and entry.visual
	local sourceAnchor = entry and entry.sourceAnchor
	local visualAnchor = entry and entry.visualAnchor
	if not sourceTool or not visualTool or not visualTool.Parent then
		return false
	end
	if not sourceAnchor or not sourceAnchor.Parent or not visualAnchor or not visualAnchor.Parent then
		return false
	end

	local pairMap = entry.pairs or {}
	local sourceRoot = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local cloneRoot = vars.localTryOnModel and (vars.localTryOnRootPart or vars.localTryOnModel.PrimaryPart)
	local sourceStillLive = sourceTool:IsDescendantOf(character)

	-- While the experience rebuilds/equips the outfit, the source Tool can be
	-- briefly reparented. Keep the last body-relative pose instead of dropping
	-- the visual copy during that gap.
	if not sourceStillLive then
		-- A Tool visual belongs to the avatar only while the real Tool is in Character.
		-- Once it leaves Character, remove the clone instead of freezing it on the body.
		return false
	end

	if sourceStillLive and sourceRoot and cloneRoot and sourceAnchor and sourceAnchor.Parent then
		local anchorCFrame = sourceAnchor.CFrame
		for sourceInstance, visualInstance in pairs(pairMap) do
			if sourceInstance and sourceInstance.Parent
				and visualInstance and visualInstance.Parent then
				if sourceInstance:IsA("BasePart") and visualInstance:IsA("BasePart") then
					local relative = sourceRoot.CFrame:ToObjectSpace(sourceInstance.CFrame)
					entry.lastRelativePairs[sourceInstance] = relative
					pcall(function() visualInstance.CFrame = cloneRoot.CFrame * relative end)
					pcall(function() visualInstance.Transparency = sourceInstance.Transparency end)
					pcall(function() visualInstance.Color = sourceInstance.Color end)
					pcall(function() visualInstance.Material = sourceInstance.Material end)
					pcall(function() visualInstance.Reflectance = sourceInstance.Reflectance end)
					pcall(function() visualInstance.Size = sourceInstance.Size end)
				elseif (sourceInstance:IsA("Decal") or sourceInstance:IsA("Texture"))
					and (visualInstance:IsA("Decal") or visualInstance:IsA("Texture")) then
					pcall(function() visualInstance.Transparency = sourceInstance.Transparency end)
					pcall(function() visualInstance.Color3 = sourceInstance.Color3 end)
					pcall(function() visualInstance.Texture = sourceInstance.Texture end)
				end
			end
		end
		return true
	end

	return false
end

vars.setLocalTryOnToolVisualVisible = function(visible)
	for _, entry in pairs(vars.localTryOnToolVisualEntries) do
		local visualTool = entry.visual
		if visualTool and visualTool.Parent then
			for _, instance in ipairs(visualTool:GetDescendants()) do
				if instance:IsA("BasePart") then
					pcall(function() instance.LocalTransparencyModifier = visible and 0 or 1 end)
				elseif instance:IsA("Decal") or instance:IsA("Texture") then
					pcall(function() instance.Transparency = visible and instance.Transparency or 1 end)
				end
			end
		end
	end
	vars.localTryOnToolVisualHidden = not visible
end

vars.restoreLocalTryOnToolSource = function(tool)
	if not tool then return end
	for _, instance in ipairs(tool:GetDescendants()) do
		if instance:IsA("BasePart") then
			local oldTransparency = vars.hiddenCharacterParts[instance]
			if oldTransparency ~= nil then
				instance.LocalTransparencyModifier = oldTransparency
				vars.hiddenCharacterParts[instance] = nil
			end
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			local oldTransparency = vars.hiddenCharacterDecals[instance]
			if oldTransparency ~= nil then
				instance.Transparency = oldTransparency
				vars.hiddenCharacterDecals[instance] = nil
			end
		end
	end
end


local function getAccessoryHandle(accessory)
	if not accessory then return nil end
	local handle = accessory:FindFirstChild("Handle", true)
	return handle and handle:IsA("BasePart") and handle or nil
end

local function getAppliedAvatarAccessoryAssetIds(character)
	local ids = {}
	if not character then return ids end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return ids end

	local description = nil
	pcall(function() description = humanoid:GetAppliedDescription() end)
	if not description then return ids end

	pcall(function()
		if type(description.GetAccessories) == "function" then
			for _, info in ipairs(description:GetAccessories(true)) do
				local id = tonumber(info.AssetId)
				if id and id > 0 then ids[tostring(id)] = true end
			end
		end
	end)

	for _, propertyName in ipairs({
		"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
		"ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
		"JacketAccessory", "ShortsAccessory", "SweaterAccessory", "TShirtAccessory",
		"PantsAccessory", "ShoesAccessory", "DressSkirtAccessory", "EyelashAccessory",
		"EyebrowAccessory", "MoodAccessory"
	}) do
		local value = nil
		pcall(function() value = description[propertyName] end)
		for token in tostring(value or ""):gmatch("%d+") do
			ids[token] = true
		end
	end

	pcall(function() description:Destroy() end)
	return ids
end

local function accessoryLooksLikeGameAttachedProp(character, accessory, appliedAvatarAccessoryAssetIds)
	if not accessory or not accessory:IsA("Accessory") then return false end

	-- Accessory itself does not expose the catalog AssetId as a normal scriptable
	-- property. Roblox documents AccessoryType as Unknown for Accessories that
	-- were not inserted through the player spawning/ApplyDescription pipeline.
	-- That makes Unknown the safe discriminator for custom game-owned props,
	-- while normal avatar cosmetics remain out of this visual layer.
	local accessoryType = nil
	pcall(function() accessoryType = accessory.AccessoryType end)
	return accessoryType == nil or accessoryType == Enum.AccessoryType.Unknown
end

local function selectedCloneAlreadyHasAccessory(cloneModel, sourceAccessory)
	if not cloneModel or not sourceAccessory then return false end
	for _, child in ipairs(cloneModel:GetChildren()) do
		if child:IsA("Accessory") and child.Name == sourceAccessory.Name then
			return true
		end
	end
	return false
end


local function modelLooksAttachedToCharacter(model, character)
	if not model or not character or not model:IsA("Model") or not model:IsDescendantOf(character) then
		return false
	end
	if model:FindFirstChildOfClass("Humanoid") then return false end

	local bodyParts = {}
	for _, name in ipairs({
		"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
		"Left Arm", "Right Arm", "Left Leg", "Right Leg",
		"LeftUpperArm", "LeftLowerArm", "LeftHand",
		"RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
		"RightUpperLeg", "RightLowerLeg", "RightFoot"
	}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then bodyParts[part] = true end
	end

	local hasPart = false
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			hasPart = true
			break
		end
	end
	if not hasPart then return false end

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("JointInstance") then
			if bodyParts[instance.Part0] or bodyParts[instance.Part1] then
				return true
			end
		elseif instance:IsA("WeldConstraint") or instance:IsA("RigidConstraint") or instance:IsA("RopeConstraint") then
			local p0 = instance.Part0
			local p1 = instance.Part1
			if bodyParts[p0] or bodyParts[p1] then
				return true
			end
		end
	end

	-- Some games attach props using matching Attachments rather than a visible
	-- JointInstance/Constraint. Treat a model with an Attachment that matches
	-- an attachment on a character body part as attached as well.
	local characterAttachmentNames = {}
	for bodyPart in pairs(bodyParts) do
		for _, child in ipairs(bodyPart:GetChildren()) do
			if child:IsA("Attachment") then
				characterAttachmentNames[child.Name] = true
			end
		end
	end
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("Attachment") and characterAttachmentNames[instance.Name] then
			return true
		end
	end

	return false
end

local function getExternalDirectCharacterParts(character)
	local result = {}
	if not character then return result end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") and not vars.CHARACTER_BODY_PART_NAMES[child.Name] then
			result[#result + 1] = child
		end
	end
	return result
end

local function isExternalDirectCharacterPart(character, part)
	if not character or not part or not part:IsA("BasePart") or part.Parent ~= character then
		return false
	end
	return not vars.CHARACTER_BODY_PART_NAMES[part.Name]
end

local function cloneAttachedBasePart(character, cloneModel, sourcePart)
	if not isExternalDirectCharacterPart(character, sourcePart) then return nil end
	local visualPart = cloneArchivableInstance(sourcePart)
	if not visualPart or not visualPart:IsA("BasePart") then
		if visualPart then pcall(function() visualPart:Destroy() end) end
		return nil
	end
	visualPart.Name = "LocalWearer_AttachedPropVisual_" .. tostring(sourcePart.Name)
	visualPart.Anchored = false
	visualPart.CanCollide = false
	visualPart.CanTouch = false
	visualPart.CanQuery = false
	visualPart.Massless = true

	local entry = {
		source = sourcePart,
		visual = visualPart,
		pairs = buildVisualPairMap(sourcePart, visualPart),
		sourceAnchor = sourcePart,
		visualAnchor = visualPart,
		lastRelativePairs = {},
	}

	visualPart.Parent = cloneModel
	vars.localTryOnAttachedPropVisualEntries[sourcePart] = entry
	return entry
end

local function updateOneLocalTryOnAttachedBasePart(character, entry)
	local sourcePart = entry and entry.source
	local visualPart = entry and entry.visual
	if not sourcePart or not sourcePart.Parent or not visualPart or not visualPart.Parent then
		return false
	end
	if not isExternalDirectCharacterPart(character, sourcePart) then
		return false
	end

	local sourceRoot = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local cloneRoot = vars.localTryOnModel and (vars.localTryOnRootPart or vars.localTryOnModel.PrimaryPart)
	if not sourceRoot or not cloneRoot then return false end

	local relative = sourceRoot.CFrame:ToObjectSpace(sourcePart.CFrame)
	entry.lastRelativePairs[sourcePart] = relative
	pcall(function() visualPart.CFrame = cloneRoot.CFrame * relative end)
	pcall(function() visualPart.Transparency = sourcePart.Transparency end)
	pcall(function() visualPart.Color = sourcePart.Color end)
	pcall(function() visualPart.Material = sourcePart.Material end)
	pcall(function() visualPart.Reflectance = sourcePart.Reflectance end)
	pcall(function() visualPart.Size = sourcePart.Size end)
	return true
end

local function cloneAttachedModel(character, cloneModel, sourceModel)
	if not modelLooksAttachedToCharacter(sourceModel, character) then return nil end
	local visualModel = cloneArchivableInstance(sourceModel)
	if not visualModel then return nil end
	visualModel.Name = "LocalWearer_AttachedPropVisual_" .. tostring(sourceModel.Name)

	local entry = {
		source = sourceModel,
		visual = visualModel,
		pairs = nil,
		sourceAnchor = nil,
		visualAnchor = nil,
		lastRelativePairs = {},
	}
	entry.pairs = buildVisualPairMap(sourceModel, visualModel)

	for _, instance in ipairs(visualModel:GetDescendants()) do
		if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("ParticleEmitter")
			or instance:IsA("Trail")
			or instance:IsA("Beam")
			or instance:IsA("Smoke")
			or instance:IsA("Fire")
			or instance:IsA("Sparkles")
			or instance:IsA("Light") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("BasePart") then
			instance.Anchored = false
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
			if not entry.sourceAnchor then entry.sourceAnchor = sourceModel.PrimaryPart or instance end
			if not entry.visualAnchor then entry.visualAnchor = visualModel.PrimaryPart or instance end
		end
	end

	destroyVisualToolJoints(visualModel)
	visualModel.Parent = cloneModel
	if not visualModel.PrimaryPart then
		visualModel.PrimaryPart = visualModel:FindFirstChildWhichIsA("BasePart", true)
	end
	if not entry.sourceAnchor or not entry.sourceAnchor:IsA("BasePart") then
		entry.sourceAnchor = sourceModel.PrimaryPart or sourceModel:FindFirstChildWhichIsA("BasePart", true)
	end
	if not entry.visualAnchor or not entry.visualAnchor:IsA("BasePart") then
		entry.visualAnchor = visualModel.PrimaryPart or visualModel:FindFirstChildWhichIsA("BasePart", true)
	end
	if not entry.sourceAnchor or not entry.visualAnchor then
		pcall(function() visualModel:Destroy() end)
		return nil
	end

	vars.localTryOnAttachedPropVisualEntries[sourceModel] = entry
	return entry
end

local function updateOneLocalTryOnAttachedModel(character, entry)
	local sourceModel = entry and entry.source
	local visualModel = entry and entry.visual
	if not sourceModel or not visualModel or not visualModel.Parent then return false end

	local sourceRoot = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local cloneRoot = vars.localTryOnModel and (vars.localTryOnRootPart or vars.localTryOnModel.PrimaryPart)
	if not sourceRoot or not cloneRoot then return false end

	local pairMap = entry.pairs or {}
	local sourceStillLive = sourceModel:IsDescendantOf(character)
	if not sourceStillLive then
		return false
	end
	if sourceStillLive then
		for sourceInstance, visualInstance in pairs(pairMap) do
			if sourceInstance and sourceInstance.Parent and visualInstance and visualInstance.Parent
				and sourceInstance:IsA("BasePart") and visualInstance:IsA("BasePart") then
				local relative = sourceRoot.CFrame:ToObjectSpace(sourceInstance.CFrame)
				entry.lastRelativePairs[sourceInstance] = relative
				pcall(function() visualInstance.CFrame = cloneRoot.CFrame * relative end)
				pcall(function() visualInstance.Transparency = sourceInstance.Transparency end)
				pcall(function() visualInstance.Color = sourceInstance.Color end)
				pcall(function() visualInstance.Material = sourceInstance.Material end)
				pcall(function() visualInstance.Reflectance = sourceInstance.Reflectance end)
				pcall(function() visualInstance.Size = sourceInstance.Size end)
			end
		end
		return true
	end

	return false
end

local function cloneAttachedAccessory(character, cloneModel, sourceAccessory)
	if not character or not cloneModel or not sourceAccessory then return nil end
	if not sourceAccessory:IsDescendantOf(character) then return nil end
	if selectedCloneAlreadyHasAccessory(cloneModel, sourceAccessory) then return nil end

	local handle = getAccessoryHandle(sourceAccessory)
	if not handle then return nil end

	local visualAccessory = cloneArchivableInstance(sourceAccessory)
	if not visualAccessory then return nil end
	visualAccessory.Name = "LocalWearer_AttachedPropVisual_" .. tostring(sourceAccessory.Name)

	local entry = {
		source = sourceAccessory,
		visual = visualAccessory,
		pairs = nil,
		sourceAnchor = handle,
		visualAnchor = nil,
		lastRelativePairs = {},
	}
	entry.pairs = buildVisualPairMap(sourceAccessory, visualAccessory)

	for _, instance in ipairs(visualAccessory:GetDescendants()) do
		if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("ParticleEmitter")
			or instance:IsA("Trail")
			or instance:IsA("Beam")
			or instance:IsA("Smoke")
			or instance:IsA("Fire")
			or instance:IsA("Sparkles")
			or instance:IsA("Light") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("BasePart") then
			instance.Anchored = false
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
		end
	end

	destroyVisualToolJoints(visualAccessory)
	visualAccessory.Parent = cloneModel
	entry.visualAnchor = getAccessoryHandle(visualAccessory)
	if not entry.visualAnchor then
		pcall(function() visualAccessory:Destroy() end)
		return nil
	end

	vars.localTryOnAttachedPropVisualEntries[sourceAccessory] = entry
	return entry
end

local function updateOneLocalTryOnAttachedAccessory(character, entry)
	local sourceAccessory = entry and entry.source
	local visualAccessory = entry and entry.visual
	if not sourceAccessory or not visualAccessory or not visualAccessory.Parent then
		return false
	end

	local cloneModel = vars.localTryOnModel
	local sourceRoot = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local cloneRoot = cloneModel and (cloneModel:FindFirstChild("HumanoidRootPart", true) or cloneModel.PrimaryPart)
	if not sourceRoot or not cloneRoot then return false end

	local sourceStillLive = sourceAccessory:IsDescendantOf(character)
	local pairMap = entry.pairs or {}

	if not sourceStillLive then
		return false
	end

	if sourceStillLive then
		for sourceInstance, visualInstance in pairs(pairMap) do
			if sourceInstance and sourceInstance.Parent and visualInstance and visualInstance.Parent then
				if sourceInstance:IsA("BasePart") and visualInstance:IsA("BasePart") then
					local relative = sourceRoot.CFrame:ToObjectSpace(sourceInstance.CFrame)
					entry.lastRelativePairs[sourceInstance] = relative
					pcall(function() visualInstance.CFrame = cloneRoot.CFrame * relative end)
					pcall(function() visualInstance.Transparency = sourceInstance.Transparency end)
					pcall(function() visualInstance.Color = sourceInstance.Color end)
					pcall(function() visualInstance.Material = sourceInstance.Material end)
					pcall(function() visualInstance.Reflectance = sourceInstance.Reflectance end)
					pcall(function() visualInstance.Size = sourceInstance.Size end)
				end
			end
		end
		return true
	end

	return false
end

local function getGenericCharacterPropRoot(character, sourcePart)
	if not character or not sourcePart or not sourcePart:IsA("BasePart") then return nil end
	if not sourcePart:IsDescendantOf(character) then return nil end
	if vars.CHARACTER_BODY_PART_NAMES[sourcePart.Name] then return nil end

	local accessory = sourcePart:FindFirstAncestorWhichIsA("Accessory")
	if accessory and accessory:IsDescendantOf(character) then return nil end
	local tool = sourcePart:FindFirstAncestorWhichIsA("Tool")
	if tool and tool:IsDescendantOf(character) then return nil end

	local root = sourcePart
	local parent = sourcePart.Parent
	while parent and parent ~= character do
		if parent:IsA("Model") or parent:IsA("Folder") then
			root = parent
		end
		if parent:IsA("BasePart") and vars.CHARACTER_BODY_PART_NAMES[parent.Name] then
			break
		end
		if parent:IsA("Accessory") or parent:IsA("Tool") then
			return nil
		end
		parent = parent.Parent
	end
	return root
end

local function cloneAttachedGenericContainer(character, cloneModel, sourceRoot)
	if not character or not cloneModel or not sourceRoot then return nil end
	if not sourceRoot:IsDescendantOf(character) or sourceRoot == character then return nil end
	if sourceRoot:IsA("Accessory") or sourceRoot:IsA("Tool") then return nil end
	if sourceRoot:IsA("BasePart") and vars.CHARACTER_BODY_PART_NAMES[sourceRoot.Name] then return nil end

	local visual = cloneArchivableInstance(sourceRoot)
	if not visual then return nil end
	visual.Name = "LocalWearer_CustomLoadoutVisual_" .. tostring(sourceRoot.Name)
	local entry = {
		source = sourceRoot,
		visual = visual,
		generic = true,
		pairs = buildVisualPairMap(sourceRoot, visual),
		sourceAnchor = nil,
		visualAnchor = nil,
		lastRelativePairs = {},
	}

	for _, instance in ipairs(visual:GetDescendants()) do
		if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("ParticleEmitter")
			or instance:IsA("Trail")
			or instance:IsA("Beam")
			or instance:IsA("Smoke")
			or instance:IsA("Fire")
			or instance:IsA("Sparkles")
			or instance:IsA("Light") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("BasePart") then
			instance.Anchored = false
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
			if not entry.visualAnchor then entry.visualAnchor = instance end
		end
	end

	entry.sourceAnchor = sourceRoot:IsA("BasePart") and sourceRoot or sourceRoot:FindFirstChildWhichIsA("BasePart", true)
	if not entry.sourceAnchor or not entry.visualAnchor then
		pcall(function() visual:Destroy() end)
		return nil
	end

	destroyVisualToolJoints(visual)
	visual.Parent = cloneModel
	vars.localTryOnAttachedPropVisualEntries[sourceRoot] = entry
	return entry
end

local function updateOneLocalTryOnGenericContainer(character, entry)
	local sourceRoot = entry and entry.source
	local visualRoot = entry and entry.visual
	if not sourceRoot or not visualRoot or not visualRoot.Parent then return false end
	if not sourceRoot:IsDescendantOf(character) then return false end

	local sourceCharacterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local cloneRoot = vars.localTryOnModel and (vars.localTryOnRootPart or vars.localTryOnModel.PrimaryPart)
	if not sourceCharacterRoot or not cloneRoot then return false end

	for sourceInstance, visualInstance in pairs(entry.pairs or {}) do
		if sourceInstance and sourceInstance.Parent and visualInstance and visualInstance.Parent
			and sourceInstance:IsA("BasePart") and visualInstance:IsA("BasePart") then
			local relative = sourceCharacterRoot.CFrame:ToObjectSpace(sourceInstance.CFrame)
			pcall(function() visualInstance.CFrame = cloneRoot.CFrame * relative end)
		end
	end
	return true
end

local function discoverNestedCharacterLoadoutRoots(character, alreadySeen)
	local roots = {}
	local seen = alreadySeen or {}
	if not character then return roots end

	for _, instance in ipairs(character:GetDescendants()) do
		if instance:IsA("BasePart") and not vars.CHARACTER_BODY_PART_NAMES[instance.Name] then
			local root = getGenericCharacterPropRoot(character, instance)
			if root and root ~= character and not seen[root] then
				seen[root] = true
				roots[#roots + 1] = root
			end
		end
	end
	return roots
end

vars.destroyLocalTryOnAttachedPropVisuals = function()
	for sourceAccessory, entry in pairs(vars.localTryOnAttachedPropVisualEntries) do
		if entry and entry.visual then
			pcall(function() entry.visual:Destroy() end)
		end
	end
	table.clear(vars.localTryOnAttachedPropVisualEntries)
	table.clear(vars.localTryOnAppliedAvatarAccessoryAssetIds)
end

vars.mountLocalTryOnAttachedPropVisuals = function(character, cloneModel)
	if not character or not cloneModel then return false end

	vars.destroyLocalTryOnAttachedPropVisuals()
	local created = 0
	local appliedAvatarAccessoryAssetIds = getAppliedAvatarAccessoryAssetIds(character)
	vars.localTryOnAppliedAvatarAccessoryAssetIds = appliedAvatarAccessoryAssetIds
	local seen = {}

	-- Scan the complete Character tree. The game's persistent loadout props may
	-- be Accessories parented under a folder/body part instead of direct children.
	for _, instance in ipairs(character:GetDescendants()) do
		if instance:IsA("Accessory") and not seen[instance]
			and accessoryLooksLikeGameAttachedProp(character, instance, appliedAvatarAccessoryAssetIds) then
			seen[instance] = true
			if cloneAttachedAccessory(character, cloneModel, instance) then
				created += 1
			end
		end
	end

	-- Persistent props are also sometimes a raw BasePart welded/connected to
	-- the Character instead of being wrapped in an Accessory or Model.
	for _, sourcePart in ipairs(getExternalDirectCharacterParts(character)) do
		if cloneAttachedBasePart(character, cloneModel, sourcePart) then
			created += 1
		end
	end

	-- Keep the original Model path from v27.9, but also recognize Models nested
	-- below folders/body parts when the game uses a custom container.
	local modelSeen = {}
	for _, instance in ipairs(character:GetDescendants()) do
		if instance:IsA("Model") and not modelSeen[instance]
			and modelLooksAttachedToCharacter(instance, character) then
			local ancestorModel = instance.Parent
			local nestedInSeen = false
			while ancestorModel and ancestorModel ~= character do
				if modelSeen[ancestorModel] then
					nestedInSeen = true
					break
				end
				ancestorModel = ancestorModel.Parent
			end
			if not nestedInSeen then
				modelSeen[instance] = true
				if cloneAttachedModel(character, cloneModel, instance) then
					created += 1
				end
			end
		end
	end

	local genericSeen = {}
	for sourceObject in pairs(vars.localTryOnAttachedPropVisualEntries) do
		genericSeen[sourceObject] = true
	end
	for _, sourceRoot in ipairs(discoverNestedCharacterLoadoutRoots(character, genericSeen)) do
		if (sourceRoot:IsA("Folder") or sourceRoot:IsA("Model") or sourceRoot:IsA("BasePart"))
			and not vars.localTryOnAttachedPropVisualEntries[sourceRoot] then
			if cloneAttachedGenericContainer(character, cloneModel, sourceRoot) then
				created += 1
			end
		end
	end

	return created > 0
end

vars.updateLocalTryOnAttachedPropVisuals = function(character)
	if not character or not vars.localTryOnModel then return end

	for sourceObject, entry in pairs(vars.localTryOnAttachedPropVisualEntries) do
		local source = entry and entry.source
		local ok = false
		if entry and entry.generic then
			ok = updateOneLocalTryOnGenericContainer(character, entry)
		elseif source and source:IsA("Accessory") then
			ok = accessoryLooksLikeGameAttachedProp(character, source, vars.localTryOnAppliedAvatarAccessoryAssetIds)
				and updateOneLocalTryOnAttachedAccessory(character, entry)
		elseif source and source:IsA("Model") then
			ok = updateOneLocalTryOnAttachedModel(character, entry)
		elseif source and source:IsA("BasePart") then
			ok = isExternalDirectCharacterPart(character, source)
				and updateOneLocalTryOnAttachedBasePart(character, entry)
		elseif source and source:IsA("Folder") then
			ok = updateOneLocalTryOnGenericContainer(character, entry)
		end

		if not ok then
			if entry and entry.visual then pcall(function() entry.visual:Destroy() end) end
			vars.localTryOnAttachedPropVisualEntries[sourceObject] = nil
			vars.localTryOnLoadoutVisualDirty = true
		end
	end
end



local function isCharacterBodyPart(character, part)
	return character and part and part:IsA("BasePart") and part:IsDescendantOf(character)
		and vars.CHARACTER_BODY_PART_NAMES[part.Name] == true
end

local function getExternalVisualContainerFromPart(character, part)
	if not part or not part:IsA("BasePart") or part:IsDescendantOf(character) then return nil end
	local tool = part:FindFirstAncestorWhichIsA("Tool")
	if tool and not tool:IsDescendantOf(character) then return tool end
	local accessory = part:FindFirstAncestorWhichIsA("Accessory")
	if accessory and not accessory:IsDescendantOf(character) then return accessory end
	local model = part:FindFirstAncestorWhichIsA("Model")
	if model and model ~= character and not model:IsA("WorldRoot") and not model:IsDescendantOf(character) then return model end
	return part
end

local function appendExternalConnectedPart(result, seenParts, part, character)
	if not part or not part:IsA("BasePart") or part:IsDescendantOf(character) then return end
	if seenParts[part] then return end
	seenParts[part] = true
	local root = getExternalVisualContainerFromPart(character, part)
	if root then result[root] = true end
end

local function getExternalConnectedLoadoutPropRoots(character)
	local roots = {}
	local seenParts = {}
	if not character then return roots end
	local bodyParts = {}
	for _, instance in ipairs(character:GetDescendants()) do
		if isCharacterBodyPart(character, instance) then bodyParts[#bodyParts + 1] = instance end
	end
	for _, bodyPart in ipairs(bodyParts) do
		pcall(function()
			for _, connected in ipairs(bodyPart:GetConnectedParts(true)) do
				appendExternalConnectedPart(roots, seenParts, connected, character)
			end
		end)
		pcall(function()
			for _, joint in ipairs(bodyPart:GetJoints()) do
				if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
					local p0, p1
					pcall(function() p0 = joint.Part0 end)
					pcall(function() p1 = joint.Part1 end)
					if p0 and not p0:IsDescendantOf(character) then appendExternalConnectedPart(roots, seenParts, p0, character) end
					if p1 and not p1:IsDescendantOf(character) then appendExternalConnectedPart(roots, seenParts, p1, character) end
				elseif joint:IsA("RigidConstraint") then
					local a0, a1 = joint.Attachment0, joint.Attachment1
					local p0, p1 = a0 and a0.Parent, a1 and a1.Parent
					if p0 and p0:IsA("BasePart") and not p0:IsDescendantOf(character) then appendExternalConnectedPart(roots, seenParts, p0, character) end
					if p1 and p1:IsA("BasePart") and not p1:IsDescendantOf(character) then appendExternalConnectedPart(roots, seenParts, p1, character) end
				end
			end
		end)
	end
	for root in pairs(roots) do
		if root == vars.localTryOnModel or root:IsDescendantOf(character) or root:IsA("WorldRoot") then
			roots[root] = nil
		end
	end
	return roots
end

-- Generic display-reference resolver: the ref's Value identifies the live visual Instance.
-- The concrete names used by the game are treated only as Explorer identifiers, never as type checks.
local function resolveDisplayReferenceTarget(displays, ref)
	if not displays or not ref then return nil end
	if ref:IsA("ObjectValue") then
		local target
		pcall(function() target = ref.Value end)
		-- For an ObjectValue, the Value is the authoritative live Instance. Never replace a nil
		-- reference with a name-based guess.
		if target and target.Parent then return target end
		return nil
	end
	if ref:IsA("StringValue") then
		local raw = ""
		pcall(function() raw = tostring(ref.Value or "") end)
		if raw == "" then return nil end
		local target = displays:FindFirstChild(raw, true)
		if not target then
			local cleaned = raw:gsub("^%s+", ""):gsub("%s+$", "")
			if cleaned ~= raw then target = displays:FindFirstChild(cleaned, true) end
		end
		return target
	end
	return nil
end

local function getPlayerDisplayReferenceFolder(character, displays)
	if not character or not displays then return nil end
	local names = {
		tostring(vars.LocalPlayer.Name),
		tostring(vars.LocalPlayer.UserId),
		tostring(character.Name),
	}
	for _, name in ipairs(names) do
		if name ~= "" then
			local folder = displays:FindFirstChild(name)
			if folder then return folder end
		end
	end
	return nil
end

vars.extDisplay = vars.extDisplay or {}
vars.extDisplay.refIds = vars.extDisplay.refIds or setmetatable({}, {__mode = "k"})
vars.extDisplay.refSeq = vars.extDisplay.refSeq or 0
vars.extDisplay.boundContainer = nil
vars.extDisplay.boundPlayerFolder = nil
vars.EXTERNAL_DISPLAY_DEBUG = false
vars.EXTERNAL_DISPLAY_DEBUG_HINT = "Set vars.EXTERNAL_DISPLAY_DEBUG = true for one in-Studio diagnostic run."

vars.extDisplay.describe = vars.extDisplay.describe or function(inst)
	if typeof(inst) ~= "Instance" then return tostring(inst) end
	local ok, name = pcall(function() return inst:GetFullName() end)
	return (ok and name or inst.Name) .. " [" .. inst.ClassName .. "]"
end

local function getPlayerReferencedDisplayRoots(character, diag)
	local roots = {}
	if not character then return roots end
	local displays = vars.Workspace:FindFirstChild("WeaponDisplays")
	if diag then diag.container = displays and vars.extDisplay.describe(displays) or "MISSING" end
	if not displays then return roots end
	local playerFolder = getPlayerDisplayReferenceFolder(character, displays)
	if diag then diag.folder = playerFolder and vars.extDisplay.describe(playerFolder) or "MISSING" end
	if not playerFolder then return roots end

	for _, ref in ipairs(playerFolder:GetDescendants()) do
		if ref:IsA("ObjectValue") or ref:IsA("StringValue") then
			local raw
			pcall(function() raw = ref.Value end)
			local target = resolveDisplayReferenceTarget(displays, ref)
			local accepted = target ~= nil and target.Parent ~= nil and target ~= vars.localTryOnModel
				and not target:IsA("WorldRoot") and not target:IsDescendantOf(character)
			if accepted then roots[target] = ref end
			if diag then
				diag.refs[#diag.refs + 1] = vars.extDisplay.describe(ref) .. " Value=" .. vars.extDisplay.describe(raw)
					.. " -> " .. (target and vars.extDisplay.describe(target) or "nil")
					.. (accepted and "" or " (REJECTED)")
			end
		end
	end
	return roots
end

local function getExternalDisplayReferenceBindings(character, diag)
	local bindings = {}
	if not character then return bindings, false end

	local displays = vars.Workspace:FindFirstChild("WeaponDisplays")
	if diag then diag.container = displays and vars.extDisplay.describe(displays) or "MISSING" end
	if not displays then return bindings, false end

	local folder = getPlayerDisplayReferenceFolder(character, displays)
	if diag then diag.folder = folder and vars.extDisplay.describe(folder) or "MISSING" end
	if not folder then
		return bindings, false
	end

	-- The live reference folder is authoritative. When it exists, do not merge it with
	-- connected-part discovery. Mixing both identities was the source of duplicate visual copies.
	for _, ref in ipairs(folder:GetDescendants()) do
		if ref:IsA("ObjectValue") or ref:IsA("StringValue") then
			local raw
			pcall(function() raw = ref.Value end)
			local target = resolveDisplayReferenceTarget(displays, ref)
			local accepted = target ~= nil
				and target.Parent ~= nil
				and target ~= vars.localTryOnModel
				and not target:IsA("WorldRoot")
				and not target:IsDescendantOf(character)
			if accepted then
				bindings[ref] = {ref = ref, source = target}
			end
			if diag then
				diag.refs[#diag.refs + 1] = vars.extDisplay.describe(ref)
					.. " Value=" .. vars.extDisplay.describe(raw)
					.. " -> " .. (target and vars.extDisplay.describe(target) or "nil")
					.. (accepted and "" or " (REJECTED)")
			end
		end
	end

	return bindings, true
end

local function getExternalLoadoutPropRoots(character, diag)
	local bindings, hasReferenceFolder = getExternalDisplayReferenceBindings(character, diag)
	if hasReferenceFolder then
		local roots = {}
		for ref, binding in pairs(bindings) do
			if binding and binding.source then roots[binding.source] = ref end
		end
		return roots
	end

	-- Legacy fallback only when the game exposes no reference folder at all.
	local roots = getExternalConnectedLoadoutPropRoots(character)
	for root in pairs(roots) do
		if root == vars.localTryOnModel or root:IsA("WorldRoot") or root:IsDescendantOf(character) then
			roots[root] = nil
		end
	end
	return roots
end

local function externalPropAnchor(root)
	if not root then return nil end
	if root:IsA("BasePart") then return root end
	if root:IsA("Model") and root.PrimaryPart then return root.PrimaryPart end
	return root:FindFirstChildWhichIsA("BasePart", true)
end

local function getSourceRootCFrame(root)
	if not root then return nil end
	if root:IsA("Model") then
		local ok, cf = pcall(function() return root:GetPivot() end)
		if ok then return cf end
	elseif root:IsA("BasePart") then
		return root.CFrame
	end
	local anchor = externalPropAnchor(root)
	return anchor and anchor.CFrame or nil
end

local function getExternalRootToAnchorCFrame(root)
	local rootCF = getSourceRootCFrame(root)
	local anchor = externalPropAnchor(root)
	if not rootCF or not anchor then return CFrame.new() end
	return rootCF:ToObjectSpace(anchor.CFrame)
end

local function getExternalDisplayParts(root)
	local parts = {}
	if not root then return parts end
	if root:IsA("BasePart") then
		parts[1] = root
		return parts
	end
	for _, instance in ipairs(root:GetDescendants()) do
		if instance:IsA("BasePart") then
			parts[#parts + 1] = instance
		end
	end
	return parts
end

local function findDirectBodyPartMount(character, sourceRoot)
	if not character or not sourceRoot then return nil end
	local bodyParts = {}
	for _, instance in ipairs(character:GetDescendants()) do
		if isCharacterBodyPart(character, instance) then bodyParts[instance] = true end
	end

	local rootCF = getSourceRootCFrame(sourceRoot)
	if not rootCF then return nil end

	local function inspectJoint(joint)
		if not joint then return nil end
		local p0, p1, a0, a1
		pcall(function() p0 = joint.Part0 end)
		pcall(function() p1 = joint.Part1 end)
		if p0 and p1 then
			if bodyParts[p0] and p1:IsDescendantOf(sourceRoot) then
				return p0, p0.CFrame:ToObjectSpace(rootCF), "Joint"
			elseif bodyParts[p1] and p0:IsDescendantOf(sourceRoot) then
				return p1, p1.CFrame:ToObjectSpace(rootCF), "Joint"
			end
		end
		pcall(function() a0 = joint.Attachment0 end)
		pcall(function() a1 = joint.Attachment1 end)
		if a0 and a1 then
			local ap0, ap1 = a0.Parent, a1.Parent
			if ap0 and ap0:IsA("BasePart") and bodyParts[ap0] and ap1 and ap1:IsDescendantOf(sourceRoot) then
				return ap0, ap0.CFrame:ToObjectSpace(rootCF), "Constraint"
			elseif ap1 and ap1:IsA("BasePart") and bodyParts[ap1] and ap0 and ap0:IsDescendantOf(sourceRoot) then
				return ap1, ap1.CFrame:ToObjectSpace(rootCF), "Constraint"
			end
		end
		return nil
	end

	-- First inspect connections coming directly from the visual's parts.
	for _, sourcePart in ipairs(getExternalDisplayParts(sourceRoot)) do
		local ok, connected = pcall(function() return sourcePart:GetConnectedParts(false) end)
		if ok and connected then
			for _, connectedPart in ipairs(connected) do
				if bodyParts[connectedPart] then
					return connectedPart, connectedPart.CFrame:ToObjectSpace(rootCF), "DirectConnection"
				end
			end
		end
		local okJoints, joints = pcall(function() return sourcePart:GetJoints() end)
		if okJoints and joints then
			for _, joint in ipairs(joints) do
				local bodyPart, localMount, evidence = inspectJoint(joint)
				if bodyPart then return bodyPart, localMount, evidence end
			end
		end
		for _, child in ipairs(sourcePart:GetChildren()) do
			if child:IsA("Constraint") or child:IsA("WeldConstraint") then
				local bodyPart, localMount, evidence = inspectJoint(child)
				if bodyPart then return bodyPart, localMount, evidence end
			end
		end
	end

	-- Some games parent the mount object under the body part instead of the display.
	-- Inspect only the body's direct joints/constraints, not the whole Character hierarchy.
	for bodyPart in pairs(bodyParts) do
		local okJoints, joints = pcall(function() return bodyPart:GetJoints() end)
		if okJoints and joints then
			for _, joint in ipairs(joints) do
				local mountedBody, localMount, evidence = inspectJoint(joint)
				if mountedBody then return mountedBody, localMount, evidence end
			end
		end
		for _, child in ipairs(bodyPart:GetChildren()) do
			if child:IsA("Constraint") or child:IsA("WeldConstraint") then
				local mountedBody, localMount, evidence = inspectJoint(child)
				if mountedBody then return mountedBody, localMount, evidence end
			end
		end
	end

	return nil
end

local function stripExternalDisplayConnections(visual)
	if not visual then return end
	local function inside(inst)
		return inst and (inst == visual or inst:IsDescendantOf(visual))
	end
	for _, instance in ipairs(visual:GetDescendants()) do
		if instance:IsA("JointInstance") or instance:IsA("WeldConstraint") then
			local p0, p1
			pcall(function() p0 = instance.Part0 end)
			pcall(function() p1 = instance.Part1 end)
			-- Keep internal assembly links. Remove only links crossing from the clone to the real tree.
			if (p0 and not inside(p0)) or (p1 and not inside(p1)) then
				pcall(function() instance:Destroy() end)
			end
		elseif instance:IsA("Constraint") then
			local p0, p1, a0, a1
			pcall(function() p0 = instance.Part0 end)
			pcall(function() p1 = instance.Part1 end)
			pcall(function() a0 = instance.Attachment0 end)
			pcall(function() a1 = instance.Attachment1 end)
			local externalParts = (p0 and not inside(p0)) or (p1 and not inside(p1))
			local externalAttachments = (a0 and not inside(a0)) or (a1 and not inside(a1))
			if externalParts or externalAttachments then
				pcall(function() instance:Destroy() end)
			end
		end
	end
end

local function hideExternalWorldProp(root)
	if not root then return end
	local function hideOne(instance)
		if instance:IsA("BasePart") then
			if vars.hiddenCharacterParts[instance] == nil then vars.hiddenCharacterParts[instance] = instance.LocalTransparencyModifier end
			pcall(function() instance.LocalTransparencyModifier = 1 end)
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			if vars.hiddenCharacterDecals[instance] == nil then vars.hiddenCharacterDecals[instance] = instance.Transparency end
			pcall(function() instance.Transparency = 1 end)
		end
	end
	if root:IsA("BasePart") then hideOne(root) end
	for _, instance in ipairs(root:GetDescendants()) do hideOne(instance) end
end

local function restoreExternalWorldProp(root)
	if not root then return end
	local function restoreOne(instance)
		if instance:IsA("BasePart") then
			local old = vars.hiddenCharacterParts[instance]
			if old ~= nil then
				pcall(function() instance.LocalTransparencyModifier = old end)
				vars.hiddenCharacterParts[instance] = nil
			end
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			local old = vars.hiddenCharacterDecals[instance]
			if old ~= nil then
				pcall(function() instance.Transparency = old end)
				vars.hiddenCharacterDecals[instance] = nil
			end
		end
	end
	if root:IsA("BasePart") then restoreOne(root) end
	for _, instance in ipairs(root:GetDescendants()) do restoreOne(instance) end
end

local function prepareExternalDisplayVisual(visual)
	local parts = {}
	if not visual then return parts end
	local function preparePart(part)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function() part.LocalTransparencyModifier = 0 end)
		parts[#parts + 1] = part
	end
	if visual:IsA("BasePart") then preparePart(visual) end
	for _, instance in ipairs(visual:GetDescendants()) do
		if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript")
			or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")
			or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") or instance:IsA("Light") then
			pcall(function() instance:Destroy() end)
		elseif instance:IsA("BasePart") then
			preparePart(instance)
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = 0 end)
		end
	end
	return parts
end

local function setExternalDisplayVisible(entry, visible)
	if not entry or entry.visible == visible then return end
	entry.visible = visible
	for _, part in ipairs(entry.parts or {}) do
		if part.Parent then pcall(function() part.LocalTransparencyModifier = visible and 0 or 1 end) end
	end
end

local function buildExternalDisplayPartPairs(sourceRoot, visual)
	local list = {}
	local mapped = buildVisualPairMap(sourceRoot, visual)
	for sourcePart, visualPart in pairs(mapped) do
		if sourcePart:IsA("BasePart") and visualPart:IsA("BasePart") then
			list[#list + 1] = {sourcePart, visualPart}
		end
	end
	return list
end

local function cloneExternalWorldProp(character, cloneModel, sourceRoot, ref)
	if not character or not cloneModel or not sourceRoot or not sourceRoot.Parent then return nil end
	if sourceRoot:IsDescendantOf(character) or sourceRoot == vars.localTryOnModel or sourceRoot:IsA("WorldRoot") then return nil end

	local bodyPart, bodyLocalMount, mountEvidence = findDirectBodyPartMount(character, sourceRoot)
	local bodyAttachment, sourceAttachment, attachmentLocalMount

	local visual = cloneArchivableInstance(sourceRoot)
	if not visual then return nil end
	visual.Name = "LocalWearer_LoadoutDisplayVisual_" .. tostring(sourceRoot.Name)
	local parts = prepareExternalDisplayVisual(visual)
	visual.Parent = cloneModel

	-- Critical physics boundary: preserve joints that belong entirely to the cloned visual,
	-- but remove only references that still point into the real Character or another tree.
	stripExternalDisplayConnections(visual)

	if not bodyPart then
		local bodyAttachments = findMatchingCloneBodyAttachments(cloneModel)
		sourceAttachment, bodyAttachment = findDisplayMountAttachment(sourceRoot, bodyAttachments)
		if sourceAttachment and bodyAttachment then
			attachmentLocalMount = getSourceLocalMountCFrame(sourceRoot, sourceAttachment)
		end
	end

	local entry = {
		key = ref or sourceRoot,
		ref = ref,
		source = sourceRoot,
		visual = visual,
		parts = parts,
		pairs = buildExternalDisplayPartPairs(sourceRoot, visual),
		kind = visual:IsA("Model") and "Model" or (visual:IsA("BasePart") and "BasePart" or "Parts"),
		visible = false,
		hidSource = false,
		mountMode = "None",
		bodyPartName = nil,
		cloneBodyPart = nil,
		bodyLocalMount = nil,
		mountEvidence = mountEvidence,
		sourceAttachment = sourceAttachment,
		bodyAttachment = bodyAttachment,
		sourceLocalMount = attachmentLocalMount,
		rootToAnchor = getExternalRootToAnchorCFrame(sourceRoot),
	}

	if bodyPart and bodyLocalMount then
		local cloneBodyPart = cloneModel:FindFirstChild(bodyPart.Name, true)
		if cloneBodyPart and cloneBodyPart:IsA("BasePart") then
			entry.mountMode = "BodyPartRelative"
			entry.bodyPartName = bodyPart.Name
			entry.cloneBodyPart = cloneBodyPart
			entry.bodyLocalMount = bodyLocalMount
		end
	elseif bodyAttachment and attachmentLocalMount then
		entry.mountMode = "Attachment"
	end

	-- Hide only a live source that is actually physically attached to this Character.
	-- A shared storage/template object is never hidden.
	if entry.mountMode == "BodyPartRelative" or entry.mountMode == "Attachment" then
		hideExternalWorldProp(sourceRoot)
		entry.hidSource = true
	end

	return entry
end

local function restoreExternalEntrySource(entry)
	if entry and entry.hidSource and entry.source then
		restoreExternalWorldProp(entry.source)
		entry.hidSource = false
	end
end

local function destroyOneExternalEntry(key, entry)
	if not entry then return end
	restoreExternalEntrySource(entry)
	if entry.visual then pcall(function() entry.visual:Destroy() end) end
	if vars.localTryOnExternalWorldPropVisualEntries[key] == entry then
		vars.localTryOnExternalWorldPropVisualEntries[key] = nil
	end
end

local function placeExternalDisplayEntry(entry)
	if not entry or not entry.visual or not entry.visual.Parent then return false end
	local desiredRoot
	if entry.mountMode == "BodyPartRelative" and entry.cloneBodyPart and entry.bodyLocalMount then
		if not entry.cloneBodyPart.Parent then return false end
		desiredRoot = entry.cloneBodyPart.CFrame * entry.bodyLocalMount
	elseif entry.mountMode == "Attachment" and entry.bodyAttachment and entry.sourceLocalMount then
		desiredRoot = entry.bodyAttachment.WorldCFrame * entry.sourceLocalMount:Inverse()
	end

	if not desiredRoot then
		setExternalDisplayVisible(entry, false)
		return true
	end

	if entry.kind == "Model" then
		local ok = pcall(function() entry.visual:PivotTo(desiredRoot) end)
		if ok then setExternalDisplayVisible(entry, true) end
		return ok
	elseif entry.kind == "BasePart" then
		local ok = pcall(function() entry.visual.CFrame = desiredRoot end)
		if ok then setExternalDisplayVisible(entry, true) end
		return ok
	end

	local sourceAnchor = externalPropAnchor(entry.source)
	local visualAnchor = externalPropAnchor(entry.visual)
	if not sourceAnchor or not visualAnchor then return false end
	local desiredAnchor = desiredRoot * entry.rootToAnchor
	for _, pair in ipairs(entry.pairs or {}) do
		local sourcePart, visualPart = pair[1], pair[2]
		if sourcePart and sourcePart.Parent and visualPart and visualPart.Parent then
			local rel = sourceAnchor.CFrame:ToObjectSpace(sourcePart.CFrame)
			visualPart.CFrame = desiredAnchor * rel
		end
	end
	setExternalDisplayVisible(entry, true)
	return true
end

local function reconcileExternalWorldDisplayVisuals(character, cloneModel)
	if not character or not cloneModel then return end
	local diagnostics = vars.EXTERNAL_DISPLAY_DEBUG and {refs = {}, clones = {}, removed = {}} or nil
	local bindings, hasReferenceFolder = getExternalDisplayReferenceBindings(character, diagnostics)

	-- Remove orphaned visuals from an older reconciliation/build before the live reference set is rebuilt.
	-- This prefix belongs exclusively to this external-display layer.
	local trackedVisuals = {}
	for _, tracked in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
		if tracked and tracked.visual then trackedVisuals[tracked.visual] = true end
	end
	for _, child in ipairs(cloneModel:GetChildren()) do
		if string.sub(child.Name, 1, 33) == "LocalWearer_LoadoutDisplayVisual_" and not trackedVisuals[child] then
			pcall(function() child:Destroy() end)
		end
	end

	-- Explicit reference slots are keyed by the reference object itself. Replacing Value replaces
	-- the visual in that same slot instead of leaving the old source and creating a trail.
	if hasReferenceFolder then
		for key, entry in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
			if not bindings[key] then
				if diagnostics then diagnostics.removed[#diagnostics.removed + 1] = vars.extDisplay.describe(entry.source) end
				destroyOneExternalEntry(key, entry)
			end
		end
		for ref, binding in pairs(bindings) do
			local entry = vars.localTryOnExternalWorldPropVisualEntries[ref]
			if not entry or entry.source ~= binding.source or not entry.visual or not entry.visual.Parent then
				if entry then destroyOneExternalEntry(ref, entry) end
				entry = cloneExternalWorldProp(character, cloneModel, binding.source, ref)
				if entry then vars.localTryOnExternalWorldPropVisualEntries[ref] = entry end
				if diagnostics then
					diagnostics.clones[#diagnostics.clones + 1] = vars.extDisplay.describe(binding.source)
						.. " mount=" .. tostring(entry and entry.mountMode or "CLONE_FAILED")
						.. " body=" .. tostring(entry and entry.bodyPartName or "-")
						.. " evidence=" .. tostring(entry and entry.mountEvidence or "-")
				end
			end
		end
	else
		local liveRoots = getExternalLoadoutPropRoots(character, diagnostics)
		vars.localTryOnReferencedDisplayRoots = liveRoots
		for sourceRoot, entry in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
			if not liveRoots[sourceRoot] or not sourceRoot.Parent or not entry.visual or not entry.visual.Parent then
				destroyOneExternalEntry(sourceRoot, entry)
			end
		end
		for sourceRoot in pairs(liveRoots) do
			if not vars.localTryOnExternalWorldPropVisualEntries[sourceRoot] then
				local entry = cloneExternalWorldProp(character, cloneModel, sourceRoot, nil)
				if entry then vars.localTryOnExternalWorldPropVisualEntries[sourceRoot] = entry end
			end
		end
	end

	vars.localTryOnLoadoutVisualDirty = false
	vars.localTryOnLoadoutVisualNextScan = os.clock() + (vars.localTryOnLoadoutVisualScanInterval or 1.0)
	if diagnostics and vars.showDiagnostics then
		local lines = {
			"Container: " .. tostring(diagnostics.container),
			"Player folder: " .. tostring(diagnostics.folder),
			"References: " .. tostring(#diagnostics.refs),
		}
		for _, value in ipairs(diagnostics.refs) do lines[#lines + 1] = "  " .. value end
		for _, value in ipairs(diagnostics.clones) do lines[#lines + 1] = "  CLONE " .. value end
		for _, value in ipairs(diagnostics.removed) do lines[#lines + 1] = "  REMOVED " .. value end
		vars.showDiagnostics("External display diagnostics", table.concat(lines, "\n"))
	end

	for _, entry in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
		placeExternalDisplayEntry(entry)
	end
end

vars.destroyLocalTryOnExternalWorldPropVisuals = function()
	for key, entry in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
		destroyOneExternalEntry(key, entry)
	end
	table.clear(vars.localTryOnExternalWorldPropVisualEntries)
end

vars.mountLocalTryOnExternalWorldPropVisuals = function(character, cloneModel)
	reconcileExternalWorldDisplayVisuals(character, cloneModel)
end

vars.updateLocalTryOnExternalWorldPropVisuals = function(character)
	if not character or not vars.localTryOnModel then return end
	local now = os.clock()
	if vars.localTryOnLoadoutVisualDirty or now >= vars.localTryOnLoadoutVisualNextScan then
		reconcileExternalWorldDisplayVisuals(character, vars.localTryOnModel)
	end
end

vars.syncLocalTryOnExternalWorldPropVisuals = function(character)
	if not character or not vars.localTryOnModel then return end
	for key, entry in pairs(vars.localTryOnExternalWorldPropVisualEntries) do
		if not entry or not entry.visual or not entry.visual.Parent or not entry.source or not entry.source.Parent then
			destroyOneExternalEntry(key, entry)
			vars.localTryOnLoadoutVisualDirty = true
		else
			placeExternalDisplayEntry(entry)
		end
	end
end

vars.ensureLocalTryOnExternalDisplayListeners = function(character)
	if not character then return end
	local conns = vars.localTryOnConnections
	local dirty = function() vars.localTryOnLoadoutVisualDirty = true end

	if not conns.externalDisplayContainerAdded then
		vars.setLocalTryOnConnection("externalDisplayContainerAdded", vars.Workspace.ChildAdded, function(child)
			if child.Name == "WeaponDisplays" then
				vars.extDisplay.boundContainer = nil
				vars.extDisplay.boundPlayerFolder = nil
				dirty()
				vars.ensureLocalTryOnExternalDisplayListeners(character)
			end
		end)
	end
	if not conns.externalDisplayContainerRemoved then
		vars.setLocalTryOnConnection("externalDisplayContainerRemoved", vars.Workspace.ChildRemoved, function(child)
			if child == vars.extDisplay.boundContainer then
				vars.extDisplay.boundContainer = nil
				vars.extDisplay.boundPlayerFolder = nil
				dirty()
			end
		end)
	end

	local displays = vars.Workspace:FindFirstChild("WeaponDisplays")
	if displays ~= vars.extDisplay.boundContainer then
		vars.extDisplay.boundContainer = displays
		vars.extDisplay.boundPlayerFolder = nil
		vars.setLocalTryOnConnection("externalDisplayChildAdded", displays and displays.ChildAdded, displays and function()
			dirty()
			vars.ensureLocalTryOnExternalDisplayListeners(character)
		end)
		vars.setLocalTryOnConnection("externalDisplayChildRemoved", displays and displays.ChildRemoved, displays and function()
			dirty()
		end)
	end

	local folder = displays and getPlayerDisplayReferenceFolder(character, displays)
	if folder ~= vars.extDisplay.boundPlayerFolder then
		vars.extDisplay.boundPlayerFolder = folder
		for name in pairs(conns) do
			if string.sub(name, 1, 22) == "externalDisplayRefValue" then
				vars.setLocalTryOnConnection(name, nil)
			end
		end
		vars.setLocalTryOnConnection("externalDisplayRefAdded", folder and folder.DescendantAdded, folder and function(child)
			if child:IsA("ObjectValue") or child:IsA("StringValue") then dirty() end
			vars.ensureLocalTryOnExternalDisplayListeners(character)
		end)
		vars.setLocalTryOnConnection("externalDisplayRefRemoved", folder and folder.DescendantRemoving, folder and dirty)
	end

	if folder then
		for _, ref in ipairs(folder:GetDescendants()) do
			if ref:IsA("ObjectValue") or ref:IsA("StringValue") then
				local id = vars.extDisplay.refIds[ref]
				if not id then
					vars.extDisplay.refSeq = vars.extDisplay.refSeq + 1
					id = vars.extDisplay.refSeq
					vars.extDisplay.refIds[ref] = id
				end
				local connectionName = "externalDisplayRefValue_" .. tostring(id)
				if not conns[connectionName] then
					vars.setLocalTryOnConnection(connectionName, ref:GetPropertyChangedSignal("Value"), dirty)
				end
			end
		end
	end
end

vars.destroyLocalTryOnToolVisual = function(keepExternal)
	vars.destroyLocalTryOnAttachedPropVisuals()
	if not keepExternal then vars.destroyLocalTryOnExternalWorldPropVisuals() end
	for sourceTool, entry in pairs(vars.localTryOnToolVisualEntries) do
		if sourceTool then
			vars.restoreLocalTryOnToolSource(sourceTool)
		end
		if entry and entry.visual then
			pcall(function() entry.visual:Destroy() end)
		end
	end
	table.clear(vars.localTryOnToolVisualEntries)
	vars.localTryOnToolVisual = nil
	vars.localTryOnToolSource = nil
	vars.localTryOnToolGrip = nil
	vars.localTryOnToolSourceGrip = nil
	vars.localTryOnToolHandle = nil
	vars.localTryOnToolVisualPairs = nil
	vars.localTryOnToolExpectedHandleOffset = nil
	vars.localTryOnToolVisualHidden = false
	table.clear(vars.localTryOnToolVisualOriginals)
end

vars.hideLocalTryOnToolSource = function(tool)
	if not tool then return end
	for _, instance in ipairs(tool:GetDescendants()) do
		if instance:IsA("BasePart") then
			if vars.hiddenCharacterParts[instance] == nil then
				vars.hiddenCharacterParts[instance] = instance.LocalTransparencyModifier
			end
			instance.LocalTransparencyModifier = 1
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			if vars.hiddenCharacterDecals[instance] == nil then
				vars.hiddenCharacterDecals[instance] = instance.Transparency
			end
			instance.Transparency = 1
		end
	end
end

vars.mountLocalTryOnToolVisual = function(character, cloneModel)
	if not character or not cloneModel then return false end
	vars.localTryOnLoadoutVisualDirty = false
	vars.localTryOnLoadoutVisualNextScan = os.clock() + (vars.localTryOnLoadoutVisualScanInterval or 0.45)

	-- The generated outfit model does not contain the game's live Tools. Keep
	-- those Tools as an independent visual layer so unequipped back/waist props
	-- survive outfit changes just like equipped props do.
	vars.destroyLocalTryOnToolVisual(true)

	local created = 0
	for _, sourceTool in ipairs(getAllLocalTryOnCharacterTools(character)) do
		local entry = cloneOneLocalTryOnTool(character, cloneModel, sourceTool)
		if entry then
			vars.hideLocalTryOnToolSource(sourceTool)
			updateOneLocalTryOnToolVisual(character, entry)
			created = created + 1
		end
	end

	-- Preserve the old singular aliases for diagnostics/legacy callers.
	for sourceTool, entry in pairs(vars.localTryOnToolVisualEntries) do
		vars.localTryOnToolSource = sourceTool
		vars.localTryOnToolVisual = entry.visual
		vars.localTryOnToolHandle = entry.sourceAnchor
		vars.localTryOnToolVisualPairs = entry.pairs
		break
	end

	vars.mountLocalTryOnAttachedPropVisuals(character, cloneModel)
	vars.mountLocalTryOnExternalWorldPropVisuals(character, cloneModel)
	return created > 0 or next(vars.localTryOnAttachedPropVisualEntries) ~= nil or next(vars.localTryOnExternalWorldPropVisualEntries) ~= nil
end

local function reconcileLocalTryOnToolVisuals(character)
	if not character or not vars.localTryOnModel then return end

	local now = os.clock()
	local shouldScan = vars.localTryOnLoadoutVisualDirty or now >= vars.localTryOnLoadoutVisualNextScan
	if not shouldScan then return end

	vars.localTryOnLoadoutVisualDirty = false
	vars.localTryOnLoadoutVisualNextScan = now + (vars.localTryOnLoadoutVisualScanInterval or 0.45)

	local liveTools = {}
	for _, sourceTool in ipairs(getAllLocalTryOnCharacterTools(character)) do
		liveTools[sourceTool] = true
	end

	local removedTools = {}
	for sourceTool, entry in pairs(vars.localTryOnToolVisualEntries) do
		if not liveTools[sourceTool] or not entry.visual or not entry.visual.Parent then
			removedTools[#removedTools + 1] = sourceTool
		end
	end

	for _, sourceTool in ipairs(removedTools) do
		local entry = vars.localTryOnToolVisualEntries[sourceTool]
		if entry then
			vars.restoreLocalTryOnToolSource(sourceTool)
			if entry.visual then pcall(function() entry.visual:Destroy() end) end
			vars.localTryOnToolVisualEntries[sourceTool] = nil
		end
	end

	local needToolRebuild = false
	for sourceTool in pairs(liveTools) do
		if not vars.localTryOnToolVisualEntries[sourceTool] then
			needToolRebuild = true
			break
		end
	end

	if needToolRebuild then
		vars.mountLocalTryOnToolVisual(character, vars.localTryOnModel)
	else
		vars.destroyLocalTryOnAttachedPropVisuals()
		vars.mountLocalTryOnAttachedPropVisuals(character, vars.localTryOnModel)
		vars.mountLocalTryOnExternalWorldPropVisuals(character, vars.localTryOnModel)
	end
end

-- Per-frame visual synchronization. This intentionally runs after the clone root
-- and clone animation pose have been updated in RenderStepped, so equipped Tools
-- sample the current Character pose instead of the previous Heartbeat state.
vars.syncLocalTryOnToolVisuals = function(character)
	if not character or not vars.localTryOnModel then return end

	for _, entry in pairs(vars.localTryOnToolVisualEntries) do
		if not updateOneLocalTryOnToolVisual(character, entry) then
			vars.localTryOnLoadoutVisualDirty = true
		end
	end
end

vars.updateLocalTryOnToolVisual = function(character)
	if not character or not vars.localTryOnModel then return end
	reconcileLocalTryOnToolVisuals(character)
	vars.syncLocalTryOnToolVisuals(character)
	vars.updateLocalTryOnAttachedPropVisuals(character)
end


vars.bindLocalTryOnToolVisual = function(character, cloneModel)
	vars.setLocalTryOnConnection("toolAdded", character.DescendantAdded, function(child)
		if not vars.isLocalTryOnTool(child) then return end
		task.defer(function()
			if vars.scriptAlive and vars.tryOnActive and cloneModel and cloneModel.Parent then
				vars.mountLocalTryOnToolVisual(character, cloneModel)
			end
		end)
	end)

	vars.setLocalTryOnConnection("toolRemoved", character.DescendantRemoving, function(child)
		if not vars.isLocalTryOnTool(child) then return end
		task.defer(function()
			if not vars.scriptAlive or not vars.tryOnActive or not cloneModel or not cloneModel.Parent then
				return
			end
			-- Attached non-Tool props have strict Character ownership; a removed
			-- source must not leave a floating visual behind.
			vars.updateLocalTryOnToolVisual(character)
		end)
	end)

	vars.setLocalTryOnConnection("propAdded", character.ChildAdded, function(child)
		if not child:IsA("Accessory") and not child:IsA("Model") and not child:IsA("BasePart") then return end
		if child:IsA("Accessory") and not accessoryLooksLikeGameAttachedProp(character, child, vars.localTryOnAppliedAvatarAccessoryAssetIds) then return end
		if child:IsA("BasePart") and not isExternalDirectCharacterPart(character, child) then return end
		task.defer(function()
			if vars.scriptAlive and vars.tryOnActive and cloneModel and cloneModel.Parent then
				vars.mountLocalTryOnAttachedPropVisuals(character, cloneModel)
			end
		end)
	end)

	vars.setLocalTryOnConnection("propRemoved", character.ChildRemoved, function(child)
		if not child:IsA("Accessory") and not child:IsA("Model") and not child:IsA("BasePart") then return end
		if child:IsA("Accessory") and not accessoryLooksLikeGameAttachedProp(character, child, vars.localTryOnAppliedAvatarAccessoryAssetIds) then return end
		if child:IsA("BasePart") and not vars.CHARACTER_BODY_PART_NAMES[child.Name] then
			-- A direct custom part leaving Character is a real removal.
		else
			return
		end
		task.defer(function()
			if vars.scriptAlive and vars.tryOnActive and cloneModel and cloneModel.Parent then
				vars.updateLocalTryOnAttachedPropVisuals(character)
			end
		end)
	end)

	vars.setLocalTryOnConnection("loadoutDirtyAdded", character.DescendantAdded, function()
		vars.localTryOnLoadoutVisualDirty = true
	end)

	vars.setLocalTryOnConnection("loadoutDirtyRemoved", character.DescendantRemoving, function()
		vars.localTryOnLoadoutVisualDirty = true
	end)

	task.defer(function()
		if vars.scriptAlive and vars.tryOnActive and cloneModel and cloneModel.Parent then
			vars.ensureLocalTryOnExternalDisplayListeners(character)
		end
	end)

	vars.setLocalTryOnConnection("toolVisualSync", vars.RunService.Heartbeat, function()
		if not vars.scriptAlive or not vars.tryOnActive or not cloneModel or not cloneModel.Parent then
			return
		end
		-- Heartbeat is reserved for throttled loadout reconciliation. The actual
		-- equipped-Tool pose is synchronized after the clone is positioned in
		-- RenderStepped, matching the already-correct DisplayRef render path.
		reconcileLocalTryOnToolVisuals(character)
	end)

	task.defer(function()
		if vars.scriptAlive and vars.tryOnActive and cloneModel and cloneModel.Parent then
			vars.mountLocalTryOnToolVisual(character, cloneModel)
		end
	end)
end

vars.prepareLocalModel = function(model)	local modelHumanoid = model:FindFirstChildOfClass("Humanoid")
	if modelHumanoid then
		modelHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		modelHumanoid.RequiresNeck = false
		modelHumanoid.AutomaticScalingEnabled = false
		pcall(function() modelHumanoid.EvaluateStateMachine = false end)
		pcall(function()
			for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
				if state ~= Enum.HumanoidStateType.None then modelHumanoid:SetStateEnabled(state, false) end
			end
			modelHumanoid:ChangeState(Enum.HumanoidStateType.None)
		end)
	end

	local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.Anchored = (instance == rootPart)
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
			instance.LocalTransparencyModifier = 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = 0 end)
		elseif instance:IsA("Script") or instance:IsA("LocalScript") then
			pcall(function() instance.Disabled = true end)
		end
	end
end

vars.setLocalTryOnStagingVisibility = function(model, hidden)	if not model then return end
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = hidden and 1 or 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = hidden and 1 or 0 end)
		end
	end
end

vars.getPartBottomY = function(part)	local halfSize = part.Size / 2
	local lowestY = math.huge
	for _, x in ipairs({-halfSize.X, halfSize.X}) do
		for _, y in ipairs({-halfSize.Y, halfSize.Y}) do
			for _, z in ipairs({-halfSize.Z, halfSize.Z}) do
				lowestY = math.min(lowestY, part.CFrame:PointToWorldSpace(Vector3.new(x, y, z)).Y)
			end
		end
	end
	return lowestY
end

vars.getFeetBottomY = function(model)	local footNames = {"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}
	local lowestY = math.huge
	local foundFoot = false
	local seen = {}

	for _, footName in ipairs(footNames) do
		local foot = model:FindFirstChild(footName, true)
		if foot and foot:IsA("BasePart") and not seen[foot] then
			seen[foot] = true
			foundFoot = true
			lowestY = math.min(lowestY, vars.getPartBottomY(foot))
		end
	end
	return foundFoot and lowestY or nil
end

vars.calculateLocalTryOnSwimOffset = function(character, model, characterRoot, generatedRoot)	local charTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or characterRoot
	local modelTorso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or generatedRoot
	local charTorsoY = characterRoot.CFrame:ToObjectSpace(charTorso.CFrame).Y
	local modelTorsoY = generatedRoot.CFrame:ToObjectSpace(modelTorso.CFrame).Y
	return Vector3.new(0, charTorsoY - modelTorsoY, 0)
end

vars.calculateGroundOffsetFromCurrentPlacement = function(character, model, currentOffset)	if not character or not model then return nil end
	local characterFeetY = vars.getFeetBottomY(character)
	local modelFeetY = vars.getFeetBottomY(model)
	if not characterFeetY or not modelFeetY then return nil end

	local currentOffsetY = currentOffset and currentOffset.Y or 0
	return Vector3.new(0, characterFeetY - modelFeetY + currentOffsetY, 0)
end

vars.calculateGroundOffsetFromNeutralCloneFeet = function(character, characterRoot)	if not character or not characterRoot or vars.localTryOnNeutralCloneFeetRootOffsetY == nil then return nil end
	local characterFeetY = vars.getFeetBottomY(character)
	if not characterFeetY then return nil end
	return Vector3.new(0, characterFeetY - characterRoot.Position.Y - vars.localTryOnNeutralCloneFeetRootOffsetY, 0)
end

vars.getLocalTryOnHipReference = function(model)	if not model then return nil end

	local lowerTorso = model:FindFirstChild("LowerTorso", true)
	if lowerTorso and lowerTorso:IsA("BasePart") then
		local leftHipRigAttachment = lowerTorso:FindFirstChild("LeftHipRigAttachment")
		local rightHipRigAttachment = lowerTorso:FindFirstChild("RightHipRigAttachment")
		if leftHipRigAttachment and leftHipRigAttachment:IsA("Attachment")
			and rightHipRigAttachment and rightHipRigAttachment:IsA("Attachment") then
			return (leftHipRigAttachment.WorldPosition + rightHipRigAttachment.WorldPosition) * 0.5
		end

		local leftUpperLeg = model:FindFirstChild("LeftUpperLeg", true)
		local rightUpperLeg = model:FindFirstChild("RightUpperLeg", true)
		local leftHipAttachment = leftUpperLeg and leftUpperLeg:FindFirstChild("LeftHipAttachment")
		local rightHipAttachment = rightUpperLeg and rightUpperLeg:FindFirstChild("RightHipAttachment")
		if leftHipAttachment and leftHipAttachment:IsA("Attachment")
			and rightHipAttachment and rightHipAttachment:IsA("Attachment") then
			return (leftHipAttachment.WorldPosition + rightHipAttachment.WorldPosition) * 0.5
		end
	end

	local torso = model:FindFirstChild("Torso", true)
	if torso and torso:IsA("BasePart") then
		local leftHip = torso:FindFirstChild("Left Hip")
		local rightHip = torso:FindFirstChild("Right Hip")
		if leftHip and leftHip:IsA("Motor6D") and rightHip and rightHip:IsA("Motor6D") then
			local leftPart0 = leftHip.Part0 or torso
			local rightPart0 = rightHip.Part0 or torso
			local leftJointWorld = leftPart0.CFrame * leftHip.C0 * leftHip.Transform
			local rightJointWorld = rightPart0.CFrame * rightHip.C0 * rightHip.Transform
			return (leftJointWorld.Position + rightJointWorld.Position) * 0.5
		end
	end

	return nil
end

vars.calculateLocalTryOnSeatedHipOffset = function(character, model, currentOffset)	if not vars.scriptAlive or not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then return nil end
	if not character or not character.Parent then return nil end

	local characterHip = vars.getLocalTryOnHipReference(character)
	local modelHip = vars.getLocalTryOnHipReference(model)
	if not characterHip or not modelHip then return nil end

	local baseOffset = currentOffset or Vector3.zero
	return baseOffset + (characterHip - modelHip)
end

vars.getLocalTryOnSeatedHipOffsetLocal = function(characterRoot, worldOffset)	if not characterRoot or not worldOffset then return Vector3.zero end
	return characterRoot.CFrame:VectorToObjectSpace(worldOffset)
end

vars.isCloneSitAnimationSettled = function(model)	if not model then return false end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return false end

	local enumRig = humanoid.RigType
	local isR6 = enumRig == Enum.HumanoidRigType.R6
		or (model:FindFirstChild("Torso") ~= nil and model:FindFirstChild("UpperTorso") == nil)
	local resolved = vars.resolveAnimationIds(model, nil, isR6)
	local sitId = vars.parseAssetId(resolved and resolved.Sit)
	if not sitId then return false end

	local sitTrack = nil
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track and track.Animation then
			local trackId = vars.parseAssetId(track.Animation.AnimationId)
			if trackId == sitId and track.IsPlaying then
				sitTrack = track
				break
			end
		end
	end
	if not sitTrack then return false end

	if sitTrack.WeightTarget < 0.95 then return false end
	if math.abs(sitTrack.WeightCurrent - sitTrack.WeightTarget) > 0.02 then return false end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track ~= sitTrack and track.IsPlaying and track.WeightCurrent > 0.05 then
			return false
		end
	end

	return true
end

vars.isPlayerSitAnimationCleared = function(character)	if not character then return true end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return true end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return true end

	local isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
		or (character:FindFirstChild("Torso") ~= nil and character:FindFirstChild("UpperTorso") == nil)
	local resolved = vars.resolveAnimationIds(character, nil, isR6)
	local sitId = vars.parseAssetId(resolved and resolved.Sit)
	if not sitId then return true end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track and track.Animation then
			local trackId = vars.parseAssetId(track.Animation.AnimationId)
			if trackId == sitId and (track.IsPlaying or track.WeightCurrent > 0.05 or track.WeightTarget > 0.05) then
				return false
			end
		end
	end

	return true
end

vars.waitForCloneSitAnimationToSettle = function(character, model, playerHumanoid, seatPart, timeoutSeconds)	local deadline = os.clock() + (timeoutSeconds or 0.6)

	while vars.scriptAlive and os.clock() < deadline do
		if not character or not character.Parent or not playerHumanoid then return false end
		if not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then return false end

		local state = playerHumanoid:GetState()
		local stillSeated = playerHumanoid.Sit
			or playerHumanoid.SeatPart ~= nil
			or state == Enum.HumanoidStateType.Seated
		if not stillSeated or playerHumanoid.SeatPart ~= seatPart then return false end

		if vars.isCloneSitAnimationSettled(model) then
			return true
		end

		vars.RunService.Heartbeat:Wait()
	end

	return false
end

vars.scheduleSeatHipCalibrationAfterHeartbeat = function(character, model, playerHumanoid, seatPart, baseGroundOffset)	vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
	local calibrationToken = vars.localTryOnSeatCalibrationToken
	vars.localTryOnSeatCalibrationPending = true

	task.spawn(function()
		local settled = vars.waitForCloneSitAnimationToSettle(character, model, playerHumanoid, seatPart, 0.6)

		if not vars.scriptAlive or calibrationToken ~= vars.localTryOnSeatCalibrationToken then return end
		if not settled then
			vars.localTryOnSeatCalibrationPending = false
			return
		end
		if not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then
			vars.localTryOnSeatCalibrationPending = false
			return
		end
		if not character or not character.Parent or not playerHumanoid then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local state = playerHumanoid:GetState()
		local stillSeated = playerHumanoid.Sit or playerHumanoid.SeatPart ~= nil or state == Enum.HumanoidStateType.Seated
		if not stillSeated or playerHumanoid.SeatPart ~= seatPart then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
		if not characterRoot then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local seatedOffset = vars.calculateLocalTryOnSeatedHipOffset(character, model, baseGroundOffset)
		if seatedOffset then
			vars.localTryOnSeatedHipOffsetLocal = vars.getLocalTryOnSeatedHipOffsetLocal(characterRoot, seatedOffset)
			vars.localTryOnSeatedHipOffsetValid = true
			vars.localTryOnPositionMode = "Seat"
		end
		vars.localTryOnSeatCalibrationPending = false
	end)
end

vars.isGroundPlacementState = function(state)	return state == Enum.HumanoidStateType.Running
		or state == Enum.HumanoidStateType.Landed
		or state == Enum.HumanoidStateType.Standing
		or state == Enum.HumanoidStateType.PlatformStanding
end

vars.tryOnSelectedAvatarLocally = function()	if vars.localTryOnBuilding then return end

	local selectedData = vars.ui.selectedAvatar
	if not selectedData or not selectedData.Properties then
		vars.Status.Text = "[!] Select an avatar first."
		vars.clearDiagnostics()
		return
	end

	if vars.IS_CATALOG_AVATAR_CREATOR then
		local ok, err = vars.wearAvatarThroughCatalog(selectedData)
		if ok then
			vars.tryOnActive = true
			vars.Status.Text = "[FE] Avatar worn through Catalog Avatar Creator."
			vars.clearDiagnostics()
			return
		end
		vars.tryOnActive = false
		vars.showDiagnostics("CAC avatar wear failed.", tostring(err))
		return
	end

	local character = vars.LocalPlayer.Character
	local initialHumanoid = character and character:FindFirstChildOfClass("Humanoid")
	if vars.placeholderMode and initialHumanoid and initialHumanoid.RigType == Enum.HumanoidRigType.R6 then
		vars.tryOnActive = true
		vars.Status.Text = "[...] Applying R6 placeholder..."
		vars.clearDiagnostics()
		local ok, err = vars.applyPlaceholderR6(selectedData)
		if ok then
			vars.Status.Text = "[OK] R6 placeholder active!"
			return
		end
		vars.tryOnActive = false
		vars.showDiagnostics("R6 placeholder failed.", tostring(err))
		return
	end
	if not character or not character.Parent then
		vars.showDiagnostics("Local try-on failed.", "Your character is not available yet. Waiting for spawn...")
		return
	end

	if vars.isCharacterCurrentlySitting(character, initialHumanoid) then
		vars.abortLocalTryOnForSeatedPlayer()
		return
	end

	vars.tryOnActive = true
	vars.stopLocalTryOn(true)
	vars.localTryOnBuildId = vars.localTryOnBuildId + 1
	local currentBuildId = vars.localTryOnBuildId
	vars.localTryOnBuilding = true
	vars.WearButton.Active = false
	vars.updateWearButtonState()
	vars.Status.Text = "[...] Building local avatar..."
	vars.clearDiagnostics()

	local rigType = vars.getEnumRigType(selectedData.RigType)
	local playerHumanoidForEmotes = initialHumanoid
	local lastTryOnError = "Unknown local avatar creation failure."
	local seatDetectedDuringBuild = false

	if initialHumanoid then
		vars.setLocalTryOnConnection("buildSeat", initialHumanoid.Seated, function(active)
			if active then
				seatDetectedDuringBuild = true
			end
		end)
	end

	local function seatBlockedDuringBuild()
		return seatDetectedDuringBuild or vars.isCharacterCurrentlySitting(character, initialHumanoid)
	end

	for attempt = 1, 3 do
		if seatBlockedDuringBuild() then
			vars.abortLocalTryOnForSeatedPlayer()
			return
		end
		if not vars.scriptAlive or currentBuildId ~= vars.localTryOnBuildId then
			vars.localTryOnBuilding = false
			vars.WearButton.Active = true
			vars.updateWearButtonState()
			return
		end

		if attempt > 1 then
			vars.Status.Text = string.format("[...] Retrying local avatar... (%d/3)", attempt)
			task.wait(0.1 * (attempt - 1))
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end
			if not vars.scriptAlive or currentBuildId ~= vars.localTryOnBuildId then
				vars.localTryOnBuilding = false
				vars.WearButton.Active = true
				vars.updateWearButtonState()
				return
			end
		end

		local description = vars.reconstructHumanoidDescription(selectedData.Properties)
		vars.mergePlayerEmotesIntoDescription(description, playerHumanoidForEmotes, rigType)

		local okCreate, modelOrError = pcall(function()
			return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
		end)
		pcall(function() description:Destroy() end)

		if seatBlockedDuringBuild() then
			if typeof(modelOrError) == "Instance" then
				pcall(function() modelOrError:Destroy() end)
			end
			vars.abortLocalTryOnForSeatedPlayer()
			return
		end

		if not okCreate or typeof(modelOrError) ~= "Instance" or not modelOrError:IsA("Model") then
			lastTryOnError = tostring(modelOrError)
			if modelOrError and typeof(modelOrError) == "Instance" then
				pcall(function() modelOrError:Destroy() end)
			end
			continue
		end

		local model = modelOrError
		local updateCloneAnims = nil
		local okSetup, setupError = pcall(function()
			model.Name = "LocalWearer_LocalTryOn"
			vars.applyBodyColors(model, selectedData.Properties)
			vars.applyHeadShapeToModel(model, selectedData.Properties)
			vars.applyRigidAccessoryRefinements(model, selectedData.Properties)

			local generatedRoot = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
			local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

			if not generatedRoot then error("Generated avatar missing root part.") end
			if not characterRoot then error("Your character missing root part.") end

			vars.prepareLocalModel(model)

			for _, instance in ipairs(model:GetDescendants()) do
				vars.disableLocalTryOnCollision(instance)
			end

			vars.setLocalTryOnConnection("collision", model.DescendantAdded, vars.disableLocalTryOnCollision)

			vars.setLocalTryOnConnection("preSimulation", vars.RunService.PreSimulation, vars.enforceLocalTryOnNoCollision)
			vars.enforceLocalTryOnNoCollision()

			vars.setLocalTryOnStagingVisibility(model, true)
			generatedRoot.CFrame = characterRoot.CFrame + Vector3.new(0, 100, 0)
			model.Parent = vars.Workspace
			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar was removed or invalid immediately after entering Workspace.")
			end

			vars.localTryOnModel = model

			vars.RunService.Heartbeat:Wait()
			if seatBlockedDuringBuild() then
				error("Local try-on blocked: player became seated during avatar build.")
			end
			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar did not survive initial rig settling.")
			end

			generatedRoot = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
			if not generatedRoot then error("Generated avatar root disappeared after rig settling.") end

			generatedRoot.CFrame = characterRoot.CFrame

			local initialState = initialHumanoid and initialHumanoid:GetState()
			local initiallySwimming = initialState == Enum.HumanoidStateType.Swimming

			vars.currentVerticalOffset = Vector3.zero
			vars.localTryOnRootPart = generatedRoot
			vars.localTryOnSwimOffset = vars.calculateLocalTryOnSwimOffset(character, model, characterRoot, generatedRoot)
			local cloneFeetY = vars.getFeetBottomY(model)
			vars.localTryOnNeutralCloneFeetRootOffsetY = cloneFeetY and (cloneFeetY - characterRoot.Position.Y) or nil
			vars.localTryOnGroundOffset = vars.calculateGroundOffsetFromCurrentPlacement(character, model, Vector3.zero)
			if not vars.localTryOnGroundOffset then
				error("Could not establish initial feet-to-feet ground alignment.")
			end
			vars.localTryOnGroundOffsetValid = true
			vars.localTryOnSeatedHipOffsetValid = false
			vars.localTryOnPositionMode = "Ground"
			vars.localTryOnSeatCalibrationPending = false
			vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
			vars.localTryOnGroundCalibrationFrames = 0
			vars.localTryOnSwimTransitionActive = false
			vars.localTryOnSwimTransitionStart = Vector3.zero
			vars.localTryOnSwimTransitionStartedAt = 0
			vars.localTryOnLastSwimming = initiallySwimming
			vars.localTryOnSeatPart = nil

			vars.currentVerticalOffset = initiallySwimming and vars.localTryOnSwimOffset or vars.localTryOnGroundOffset
			vars.localTryOnRootPart.CFrame = characterRoot.CFrame + vars.currentVerticalOffset

			vars.enforceLocalTryOnNoCollision()
			vars.setLocalTryOnStagingVisibility(model, false)
			vars.localTryOnHiddenInFirstPerson = false
			vars.setLocalTryOnFirstPersonVisibility(vars.isFirstPersonCamera(character))

			-- Apply the proven FE animation sequence to the real Character first.
			-- The standalone old script does exactly this before anything else
			-- starts listening to the player's Animator.
			local realAnimationOk, realAnimationError = vars.applySelectedAvatarAnimationsToCharacter(
				character,
				selectedData.Properties,
				model
			)

			if not realAnimationOk then
				warn("[Local Wearer] Could not apply selected avatar animations to replicated character: " .. tostring(realAnimationError))
			end

			-- Only after the real Character is using the selected FE animations do
			-- we attach the local clone synchronizer. This keeps the working FE
			-- animation path isolated from the clone's AnimationPlayed listener.
			updateCloneAnims = vars.bindAnimationSync(
				character,
				model,
				selectedData.Properties,
				selectedData.RigType
			)

			if seatBlockedDuringBuild() then
				error("Local try-on blocked: player became seated during avatar build.")
			end

			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar did not survive animation setup.")
			end

			vars.hideCharacterLocally(character)
			vars.bindLocalTryOnToolVisual(character, model)

			task.spawn(function()
				if vars.scriptAlive and model.Parent and model:IsDescendantOf(vars.Workspace) then
					vars.preloadAvatarVisualContent(model)
				end
			end)
		end)

		if not okSetup then
			vars.restoreSelectedAvatarAnimations()
			if vars.localTryOnModel == model then vars.localTryOnModel = nil end
			vars.setLocalTryOnConnection("collision", nil)
			vars.setLocalTryOnConnection("preSimulation", nil)
			pcall(function() model:Destroy() end)
			lastTryOnError = tostring(setupError)
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end
		end

		if okSetup and vars.scriptAlive and currentBuildId == vars.localTryOnBuildId and vars.isLocalTryOnModelValid(model) then
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end

			vars.destroyOrphanedLocalTryOnModels(model)
			vars.enforceLocalTryOnNoCollision()
			vars.setLocalTryOnConnection("buildSeat", nil)
			vars.localTryOnBuilding = false
			vars.WearButton.Active = true
						vars.setLocalTryOnConnection("position", vars.RunService.RenderStepped, function()
				if not vars.scriptAlive then return end

				if not vars.localTryOnModel or not vars.localTryOnModel:IsDescendantOf(vars.Workspace) then
					if vars.tryOnActive and not vars.localTryOnBuilding and not vars.localTryOnMissingRecoveryPending then
						vars.localTryOnMissingRecoveryPending = true
						local missingBuildId = vars.localTryOnBuildId

						task.delay(0.15, function()
							vars.localTryOnMissingRecoveryPending = false

							if not vars.scriptAlive
								or missingBuildId ~= vars.localTryOnBuildId
								or vars.localTryOnBuilding
								or not vars.tryOnActive then
								return
							end

							if not vars.localTryOnModel or not vars.localTryOnModel:IsDescendantOf(vars.Workspace) then
								vars.stopLocalTryOn(false)
								vars.Status.Text = "[!] Local try-on was removed by this experience. Original avatar restored."
								vars.showDiagnostics(
									"Local try-on unavailable in this experience.",
									"The generated avatar was removed after creation. Your real avatar has been restored. Try again; some games replace or restrict local Humanoid models."
								)
							end
						end)
					end

					return
				end

				vars.localTryOnMissingRecoveryPending = false
				vars.enforceLocalTryOnNoCollision()

				if not character or not character.Parent then
					vars.stopLocalTryOn(vars.tryOnActive)
					vars.updateWearButtonState()

					if vars.tryOnActive then
						vars.Status.Text = "[...] Character respawning..."
					end

					return
				end

				local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
				local playerHumanoid = character:FindFirstChildOfClass("Humanoid")

				if not characterRoot or not vars.localTryOnRootPart then
					vars.stopLocalTryOn(vars.tryOnActive)
					vars.updateWearButtonState()

					if vars.tryOnActive then
						vars.Status.Text = "[...] Waiting for character..."
					end

					return
				end

				local currentState = playerHumanoid and playerHumanoid:GetState()
				local isSwimming = currentState == Enum.HumanoidStateType.Swimming
				local isSeated = playerHumanoid
					and (
						playerHumanoid.Sit
						or playerHumanoid.SeatPart ~= nil
						or currentState == Enum.HumanoidStateType.Seated
					)
					or false
				local seatPart = playerHumanoid and playerHumanoid.SeatPart or nil

				if not isSeated and isSwimming ~= vars.localTryOnLastSwimming then
					vars.localTryOnLastSwimming = isSwimming
					vars.localTryOnSwimTransitionActive = isSwimming or vars.localTryOnGroundOffsetValid
					vars.localTryOnSwimTransitionStart = vars.currentVerticalOffset
					vars.localTryOnSwimTransitionStartedAt = os.clock()
				elseif isSeated then
					vars.localTryOnLastSwimming = isSwimming
					vars.localTryOnSwimTransitionActive = false
				end

				if updateCloneAnims then
					updateCloneAnims()
				end

				local targetOffset = vars.currentVerticalOffset

				if isSeated then
					if (vars.localTryOnPositionMode ~= "Seat" and not vars.localTryOnSeatCalibrationPending)
						or vars.localTryOnSeatPart ~= seatPart then

						vars.localTryOnPositionMode = "SeatCalibration"
						vars.localTryOnGroundCalibrationFrames = 0
						vars.localTryOnSeatPart = seatPart
						vars.localTryOnSeatedHipOffsetValid = false
						vars.localTryOnSeatTransitionActive = false

						if not vars.localTryOnSeatCalibrationPending then
							vars.scheduleSeatHipCalibrationAfterHeartbeat(
								character,
								vars.localTryOnModel,
								playerHumanoid,
								seatPart,
								vars.localTryOnGroundOffset
							)
						end
					end

					if vars.localTryOnSeatedHipOffsetValid then
						if not vars.localTryOnSeatTransitionActive then
							vars.localTryOnSeatTransitionActive = true
							vars.localTryOnSeatTransitionStartLocal =
								characterRoot.CFrame:VectorToObjectSpace(vars.currentVerticalOffset)
							vars.localTryOnSeatTransitionStartedAt = os.clock()
						end

						local alpha = math.clamp(
							(os.clock() - vars.localTryOnSeatTransitionStartedAt) / 0.16,
							0,
							1
						)

						local eased = alpha * alpha * (3 - 2 * alpha)

						local blendedLocalOffset =
							vars.localTryOnSeatTransitionStartLocal:Lerp(
								vars.localTryOnSeatedHipOffsetLocal,
								eased
							)

						targetOffset =
							characterRoot.CFrame:VectorToWorldSpace(blendedLocalOffset)
					else
						targetOffset = vars.currentVerticalOffset
					end
				else
					if vars.localTryOnPositionMode == "Seat"
						or vars.localTryOnPositionMode == "SeatCalibration" then

						vars.localTryOnSeatCalibrationToken =
							vars.localTryOnSeatCalibrationToken + 1

						vars.localTryOnSeatCalibrationPending = false
						vars.localTryOnSeatPart = nil
						vars.localTryOnSeatedHipOffsetValid = false
						vars.localTryOnSeatTransitionActive = false
						vars.localTryOnSeatTransitionStartLocal = Vector3.zero
						vars.localTryOnSeatTransitionStartedAt = 0

						if vars.localTryOnGroundOffsetValid then
							vars.localTryOnPositionMode = "Ground"
							vars.localTryOnGroundCalibrationFrames = 0
							targetOffset =
								isSwimming
								and vars.localTryOnSwimOffset
								or vars.localTryOnGroundOffset
						else
							vars.localTryOnPositionMode = "GroundCalibration"
							vars.localTryOnGroundCalibrationFrames = 2
						end
					end

					if vars.localTryOnPositionMode == "GroundCalibration" then
						if not isSwimming and vars.isGroundPlacementState(currentState) then
							if not vars.isPlayerSitAnimationCleared(character) then
								vars.localTryOnGroundCalibrationFrames = 2
							elseif vars.localTryOnGroundCalibrationFrames > 0 then
								vars.localTryOnGroundCalibrationFrames =
									vars.localTryOnGroundCalibrationFrames - 1
							end

							if vars.localTryOnGroundCalibrationFrames == 0
								and vars.isPlayerSitAnimationCleared(character) then

								local groundOffset =
									vars.calculateGroundOffsetFromNeutralCloneFeet(
										character,
										characterRoot
									)

								if groundOffset then
									vars.localTryOnGroundOffset = groundOffset
									vars.localTryOnGroundOffsetValid = true
									vars.localTryOnPositionMode = "Ground"
									targetOffset = groundOffset
								else
									vars.localTryOnGroundCalibrationFrames = 1
								end
							end
						else
							vars.localTryOnGroundCalibrationFrames = 2
						end

						targetOffset =
							(vars.localTryOnPositionMode == "Ground")
							and vars.localTryOnGroundOffset
							or targetOffset

					elseif isSwimming then
						local desiredSwimOffset = vars.localTryOnSwimOffset

						if vars.localTryOnSwimTransitionActive then
							local alpha = math.clamp(
								(os.clock() - vars.localTryOnSwimTransitionStartedAt) / 0.16,
								0,
								1
							)

							local eased = alpha * alpha * (3 - 2 * alpha)

							targetOffset =
								vars.localTryOnSwimTransitionStart:Lerp(
									desiredSwimOffset,
									eased
								)

							if alpha >= 1 then
								vars.localTryOnSwimTransitionActive = false
								targetOffset = desiredSwimOffset
							end
						else
							targetOffset = desiredSwimOffset
						end
					else
						local desiredGroundOffset = vars.localTryOnGroundOffset

						if vars.localTryOnSwimTransitionActive then
							local alpha = math.clamp(
								(os.clock() - vars.localTryOnSwimTransitionStartedAt) / 0.16,
								0,
								1
							)

							local eased = alpha * alpha * (3 - 2 * alpha)

							targetOffset =
								vars.localTryOnSwimTransitionStart:Lerp(
									desiredGroundOffset,
									eased
								)

							if alpha >= 1 then
								vars.localTryOnSwimTransitionActive = false
								targetOffset = desiredGroundOffset
							end
						else
							targetOffset = desiredGroundOffset
						end
					end
				end

				vars.currentVerticalOffset = targetOffset

				-- Position still follows the real character, but when Shift Lock
				-- is active the clone rotation follows the camera directly.
				local targetPosition =
					characterRoot.Position + vars.currentVerticalOffset

				local camera = vars.Workspace.CurrentCamera
				local targetCFrame = characterRoot.CFrame

				if camera
					and vars.UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
					and not vars.isFirstPersonCamera(character) then

					local cameraLook = camera.CFrame.LookVector
					local flatLook = Vector3.new(cameraLook.X, 0, cameraLook.Z)

					if flatLook.Magnitude > 0.0001 then
						flatLook = flatLook.Unit
						targetCFrame = CFrame.lookAt(
							targetPosition,
							targetPosition + flatLook
						)
					else
						targetCFrame = CFrame.new(targetPosition) * CFrame.Angles(
							0,
							characterRoot.Orientation.Y * math.pi / 180,
							0
						)
					end
				else
					targetCFrame = characterRoot.CFrame + vars.localTryOnRootPart.CFrame:ToObjectSpace(
						characterRoot.CFrame
					).Position

					targetCFrame = CFrame.new(targetPosition) * CFrame.fromMatrix(
						Vector3.zero,
						characterRoot.CFrame.RightVector,
						characterRoot.CFrame.UpVector,
						-characterRoot.CFrame.LookVector
					)
				end

				vars.localTryOnRootPart.CFrame =
					CFrame.new(targetPosition)
					* CFrame.fromMatrix(
						Vector3.zero,
						targetCFrame.RightVector,
						targetCFrame.UpVector,
						-targetCFrame.LookVector
					)

				-- The clone root has just been moved for this render frame. DisplayRef
				-- toys must be placed immediately afterward, otherwise a Heartbeat
				-- update samples the previous clone position and produces the exact
				-- one-frame backwards TP/delay seen during movement.
				vars.syncLocalTryOnExternalWorldPropVisuals(character)
				vars.syncLocalTryOnToolVisuals(character)

				vars.enforceCharacterHidden()
				vars.setLocalTryOnFirstPersonVisibility(
					vars.isFirstPersonCamera(character)
				)
			end)

			vars.updateWearButtonState()
			vars.Status.Text = "[OK] Local try-on active!"
			return
		end

		lastTryOnError = tostring(setupError)
		pcall(function() model:Destroy() end)
		vars.localTryOnModel = nil
		vars.localTryOnRootPart = nil
		vars.localTryOnGroundOffset = Vector3.zero
		vars.localTryOnSwimOffset = Vector3.zero
		vars.currentVerticalOffset = Vector3.zero
		vars.localTryOnSeatedHipOffsetValid = false
		vars.localTryOnSeatPart = nil
		vars.localTryOnPositionMode = "Ground"
		vars.localTryOnSeatCalibrationPending = false
		vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
		vars.resetLocalTryOnState()
		vars.disconnectLocalTryOnConnections()
	end

	vars.setLocalTryOnConnection("buildSeat", nil)
	vars.localTryOnBuilding = false
	vars.WearButton.Active = true
	vars.updateWearButtonState()
	vars.showDiagnostics("Local try-on failed.", lastTryOnError)
end

vars.toggleLocalTryOn = function()	if vars.localTryOnBuilding then return end
	if vars.localTryOnModel or vars.tryOnActive then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
		vars.updateWearButtonState()
		vars.Status.Text = "Local try-on cleared."
		vars.clearDiagnostics()
	else
		vars.tryOnSelectedAvatarLocally()
	end
end

vars.characterLifecycleToken = 0

vars.bindCharacterLifecycle = function(character)
	vars.disconnectConnection(vars.deathConnection)
	vars.deathConnection = nil

	vars.characterLifecycleToken += 1
	local lifecycleToken = vars.characterLifecycleToken

	if not character then return end

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		local animator = humanoid and humanoid:WaitForChild("Animator", 10)
		local animateScript = character:WaitForChild("Animate", 10)

		if not humanoid or not root or not animator or not animateScript or not vars.scriptAlive then return end
		if lifecycleToken ~= vars.characterLifecycleToken then return end

		vars.deathConnection = humanoid.Died:Connect(function()
			local shouldRestoreTryOn = vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding
			if shouldRestoreTryOn then
				-- Keep the try-on state alive across the death. The old character is
				-- discarded, and the next CharacterAdded must reinstall the same FE set.
				vars.tryOnActive = true
				vars.stopLocalTryOn(true)
				vars.tryOnActive = true
				vars.WearButton.Active = false
				vars.updateWearButtonState()
				vars.Status.Text = "[...] Character died. Respawning try-on..."
			end
		end)

		if vars.tryOnActive and vars.ui.selectedAvatar and vars.scriptAlive then
			vars.WearButton.Active = false
			vars.updateWearButtonState()

			-- The original script loses its animation changes on respawn because
			-- Roblox gives us a brand-new Character/Animate tree. Wait until that
			-- tree is complete, then reinstall the saved animation set.
			for attempt = 1, 6 do
				if not vars.scriptAlive
					or lifecycleToken ~= vars.characterLifecycleToken
					or vars.LocalPlayer.Character ~= character
					or not vars.tryOnActive
				then
					return
				end

				if not vars.localTryOnBuilding then
					vars.tryOnSelectedAvatarLocally()
				end

				task.wait(0.15 * attempt)

				local backup = vars.localCharacterAnimationBackup
				local currentAnimator = humanoid:FindFirstChildOfClass("Animator")
				if backup
					and backup.Character == character
					and not backup.Destroyed
					and currentAnimator == animator
					and vars.localTryOnModel
					and vars.localTryOnModel.Parent
					then
					vars.WearButton.Active = true
					vars.updateWearButtonState()
					return
				end
			end

			-- Last direct reinstall against this fresh Character. It uses the same
			-- proven FE method and does not depend on the local clone.
			if vars.scriptAlive
				and lifecycleToken == vars.characterLifecycleToken
				and vars.LocalPlayer.Character == character
				and vars.tryOnActive
				and vars.ui.selectedAvatar
				and not vars.localTryOnBuilding
				and vars.localTryOnModel
				and vars.localTryOnModel.Parent
				then
				pcall(function()
					vars.applySelectedAvatarAnimationsToCharacter(
						character,
						vars.ui.selectedAvatar.Properties,
						vars.localTryOnModel
					)
				end)
			end

			vars.WearButton.Active = true
			vars.updateWearButtonState()
		else
			vars.WearButton.Active = true
			vars.updateWearButtonState()
		end
	end)
end

vars.characterAddedConnection = vars.LocalPlayer.CharacterAdded:Connect(vars.bindCharacterLifecycle)

vars.wire(vars.WearButton.Activated, vars.toggleLocalTryOn)

vars.updatePlaceholderToggleVisual = function()
	local on = vars.placeholderMode
	local bg = on and Color3.fromRGB(230,230,230) or vars.COLORS.Surface3
	local txt = on and Color3.fromRGB(0,0,0) or vars.COLORS.Muted
	local strokeColor = on and Color3.fromRGB(245, 245, 248) or vars.COLORS.Border
	vars.TweenService:Create(vars.PlaceholderToggle, TweenInfo.new(0.12), {BackgroundColor3 = bg, TextColor3 = txt}):Play()
	local stroke = vars.PlaceholderToggle:FindFirstChildOfClass("UIStroke")
	if stroke then vars.TweenService:Create(stroke, TweenInfo.new(0.12), {Color = strokeColor}):Play() end
end

vars.wire(vars.PlaceholderToggle.MouseEnter, function()
	if not vars.placeholderMode then
		vars.TweenService:Create(vars.PlaceholderToggle, TweenInfo.new(0.12), {
			BackgroundColor3 = Color3.fromRGB(45, 45, 48), TextColor3 = vars.COLORS.Text
		}):Play()
	end
end)
vars.wire(vars.PlaceholderToggle.MouseLeave, vars.updatePlaceholderToggleVisual)
vars.wire(vars.PlaceholderToggle.Activated, function()
	if vars.placeholderR6Building then return end
	vars.placeholderMode = not vars.placeholderMode
	vars.updatePlaceholderToggleVisual()
	if vars.ui.selectedAvatar and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active) then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
		task.defer(function()
			if vars.scriptAlive and vars.ui.selectedAvatar then vars.tryOnSelectedAvatarLocally() end
		end)
	else
		vars.Status.Text = vars.placeholderMode and "Placeholder mode enabled." or "Placeholder mode disabled."
		vars.clearDiagnostics()
	end
end)
vars.updatePlaceholderToggleVisual()

vars.usernameAvatarBusy = false
vars.wire(vars.UsernameBox.FocusLost, function()
	if vars.usernameAvatarBusy then return end
	local username = tostring(vars.UsernameBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if username == "" then return end

	vars.usernameAvatarBusy = true
	vars.UsernameBox.Active = false
	vars.SaveSelfButton.Active = false
	vars.SaveClickedButton.Active = false
	vars.PlaceholderToggle.Active = false
	vars.UsernameBox.TextColor3 = vars.COLORS.Muted
	vars.Status.Text = "[...] Loading profile avatar: @" .. username
	vars.clearDiagnostics()

	task.spawn(function()
		local ok, success, result = pcall(function()
			return vars.saveAndWearUsernameAvatar(username)
		end)
		if not ok then
			vars.showDiagnostics("Profile avatar failed.", tostring(success))
		elseif not success then
			vars.showDiagnostics("Profile avatar failed.", tostring(result))
		end

		if vars.UsernameBox and vars.UsernameBox.Parent then
			vars.UsernameBox.Active = true
			vars.UsernameBox.TextColor3 = vars.COLORS.Text
			vars.SaveSelfButton.Active = true
			vars.SaveClickedButton.Active = not vars.ui.selectingPlayer
			vars.PlaceholderToggle.Active = true
			vars.usernameAvatarBusy = false
		end
	end)
end)

vars.wire(vars.SearchBox:GetPropertyChangedSignal("Text"), function()
	if not vars.scriptAlive then return end
	if vars.searchDebounceThread then task.cancel(vars.searchDebounceThread) vars.searchDebounceThread = nil end
	vars.searchDebounceThread = task.delay(0.15, function()
		if vars.scriptAlive then vars.filterAvatarCards(vars.SearchBox.Text) end
	end)
end)

vars.wire(vars.SaveSelfButton.MouseEnter, function()
	vars.TweenService:Create(vars.SaveSelfButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(79,79,79)}):Play()
end)
vars.wire(vars.SaveSelfButton.MouseLeave, function()
	vars.TweenService:Create(vars.SaveSelfButton, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface3}):Play()
end)
vars.wire(vars.SaveSelfButton.Activated, function()
	if vars.ui.selectingPlayer then vars.stopPlayerSelection() end
	vars.SaveSelfButton.Active = false
	vars.SaveSelfButton.Text = "SAVING..."
	local ok, result = vars.savePlayerAvatar(vars.LocalPlayer)
	if ok then
		local catalogOk, catalogName, catalogErr
		if vars.IS_CATALOG_AVATAR_CREATOR then
			catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(result)
		end
		vars.SaveSelfButton.Text = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and "SAVED!" or "LOCAL SAVED"
		vars.SaveSelfButton.BackgroundColor3 = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and vars.COLORS.Success or vars.COLORS.Danger
		vars.loadSavedAvatars()
		vars.populateAvatarList()
		if vars.IS_CATALOG_AVATAR_CREATOR and catalogOk then
			vars.Status.Text = "[FE] Saved to Saved Outfits as " .. tostring(catalogName)
		elseif vars.IS_CATALOG_AVATAR_CREATOR then
			vars.Status.Text = "[LOCAL] Saved, but CAC outfit save failed."
			vars.showDiagnostics("CAC outfit save failed.", tostring(catalogErr))
		else
			vars.Status.Text = "[OK] Saved your current avatar as " .. tostring(result.FileName)
		end
	else
		vars.SaveSelfButton.Text = "FAILED"
		vars.SaveSelfButton.BackgroundColor3 = vars.COLORS.Danger
		vars.showDiagnostics("Failed to save your avatar.", tostring(result))
	end
	task.delay(1.1, function()
		if vars.SaveSelfButton and vars.SaveSelfButton.Parent then
			vars.SaveSelfButton.Text = "SAVE SELF"
			vars.SaveSelfButton.BackgroundColor3 = vars.COLORS.Surface3
			vars.SaveSelfButton.Active = true
		end
	end)
end)

vars.wire(vars.SaveClickedButton.MouseEnter, function()
	if not vars.ui.selectingPlayer then
		vars.TweenService:Create(vars.SaveClickedButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(79,79,79)}):Play()
	end
end)
vars.wire(vars.SaveClickedButton.MouseLeave, function()
	if not vars.ui.selectingPlayer then
		vars.TweenService:Create(vars.SaveClickedButton, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface3}):Play()
	end
end)
vars.wire(vars.SaveClickedButton.Activated, function()
	if vars.ui.selectingPlayer then
		vars.stopPlayerSelection()
		return
	end
	vars.ui.selectingPlayer = true
	vars.ui.selectionPlayer = nil
	vars.SaveClickedButton.Text = "CLICK A PLAYER"
	vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Accent
	vars.Status.Text = "Select a player to save their current avatar."
	vars.clearDiagnostics()
end)

vars.isRefreshing = false
vars.wire(vars.RefreshButton.MouseEnter, function()
		local ic = vars.RefreshButton:FindFirstChild("RefreshIcon")
		vars.TweenService:Create(vars.RefreshButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 48)}):Play()
		if ic then vars.TweenService:Create(ic, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Text}):Play() end
	end)
vars.wire(vars.RefreshButton.MouseLeave, function()
		local ic = vars.RefreshButton:FindFirstChild("RefreshIcon")
		vars.TweenService:Create(vars.RefreshButton, TweenInfo.new(0.12), {BackgroundColor3 = vars.COLORS.Surface3}):Play()
		if ic then vars.TweenService:Create(ic, TweenInfo.new(0.12), {TextColor3 = vars.COLORS.Muted}):Play() end
	end)
vars.wire(vars.RefreshButton.Activated, function()
	if vars.isRefreshing then return end
	vars.showConfirmation("Refresh Avatar Lists?", function()
		vars.isRefreshing = true
		vars.RefreshButton.Text = ""
		vars.Status.Text = "Refreshing saved avatars..."
		vars.previewQueueGeneration = vars.previewQueueGeneration + 1
		table.clear(vars.previewQueue)
		table.clear(vars.previewStates)
		task.wait(0.1)
		vars.loadSavedAvatars()
		vars.populateAvatarList()
		vars.RefreshButton.Text = ""
		task.delay(0.5, function() vars.isRefreshing = false end)
	end)
end)

vars.updateMainShadow = function()
	local pos = vars.Main.Position
	local size = vars.Main.Size
	local width = size.X.Offset
	local height = size.Y.Offset
	vars.MainShadowOuter.Size = UDim2.new(0, width + 14, 0, height + 14)
	vars.MainShadowOuter.Position = UDim2.new(pos.X.Scale, pos.X.Offset - 7, pos.Y.Scale, pos.Y.Offset - 7)
	vars.MainShadowInner.Size = UDim2.new(0, width + 8, 0, height + 8)
	vars.MainShadowInner.Position = UDim2.new(pos.X.Scale, pos.X.Offset - 4, pos.Y.Scale, pos.Y.Offset - 4)
end

getgenv().__AvatarWearDrag = getgenv().__AvatarWearDrag or {dragging = false, start = nil, position = nil}



vars.wire(vars.UserInputService.InputChanged, function(input)
	if not vars.ui.selectingPlayer then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		vars.setPlayerSelectionHighlight(vars.getPlayerFromMouseTarget())
	end
end)

vars.wire(vars.UserInputService.InputBegan, function(input, gameProcessed)
	if vars.ui.selectingPlayer and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		if gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then return end
		local player
		if input.UserInputType == Enum.UserInputType.Touch then
			player = vars.getPlayerFromScreenPosition(input.Position)
		else
			player = vars.getPlayerFromMouseTarget()
		end
		if player then
			vars.SaveClickedButton.Text = "SAVING..."
			vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Surface3
			vars.SaveClickedButton.Active = false
			local ok, result = vars.savePlayerAvatar(player)
			vars.stopPlayerSelection()
			if ok then
				local catalogOk, catalogName, catalogErr
				if vars.IS_CATALOG_AVATAR_CREATOR then
					catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(result)
				end
				vars.loadSavedAvatars()
				vars.populateAvatarList()
				vars.SaveClickedButton.Text = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and "SAVED!" or "LOCAL SAVED"
				vars.SaveClickedButton.BackgroundColor3 = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and vars.COLORS.Success or vars.COLORS.Danger
				if vars.IS_CATALOG_AVATAR_CREATOR and catalogOk then
					vars.Status.Text = "[FE] Saved @" .. tostring(player.Name) .. " to Saved Outfits as " .. tostring(catalogName)
				elseif vars.IS_CATALOG_AVATAR_CREATOR then
					vars.Status.Text = "[LOCAL] Saved @" .. tostring(player.Name) .. ", but CAC outfit save failed."
					vars.showDiagnostics("CAC outfit save failed.", tostring(catalogErr))
				else
					vars.Status.Text = "[OK] Saved @" .. tostring(player.Name) .. " as " .. tostring(result.FileName)
				end
			else
				vars.SaveClickedButton.Text = "FAILED"
				vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Danger
				vars.showDiagnostics("Failed to save " .. tostring(player.Name) .. ".", tostring(result))
			end
			task.delay(1.1, function()
				if vars.SaveClickedButton and vars.SaveClickedButton.Parent then
					vars.SaveClickedButton.Text = "SAVE OTHER"
					vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Surface3
					vars.SaveClickedButton.Active = true
				end
			end)
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			vars.Status.Text = "No player found there. Tap a player to save them."
			return
		end
		vars.stopPlayerSelection()
		vars.Status.Text = "Player selection cancelled."
		return
	end
end)

vars.wire(vars.UserInputService.InputBegan, function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		and input.Position.X >= vars.TitleBar.AbsolutePosition.X
		and input.Position.Y >= vars.TitleBar.AbsolutePosition.Y
		and input.Position.X <= vars.TitleBar.AbsolutePosition.X + vars.TitleBar.AbsoluteSize.X
		and input.Position.Y <= vars.TitleBar.AbsolutePosition.Y + vars.TitleBar.AbsoluteSize.Y then
		getgenv().__AvatarWearDrag.dragging = true
		getgenv().__AvatarWearDrag.start = input.Position
		getgenv().__AvatarWearDrag.position = vars.Main.Position
	end
end)

vars.wire(vars.UserInputService.InputChanged, function(input)
	if not getgenv().__AvatarWearDrag.dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local scale = math.max(vars.UIScale.Scale, 0.0001)
		local delta = input.Position - getgenv().__AvatarWearDrag.start
		vars.Main.Position = UDim2.new(
			getgenv().__AvatarWearDrag.position.X.Scale,
			getgenv().__AvatarWearDrag.position.X.Offset + delta.X / scale,
			getgenv().__AvatarWearDrag.position.Y.Scale,
			getgenv().__AvatarWearDrag.position.Y.Offset + delta.Y / scale
		)
		vars.updateMainShadow()
		vars.updateHoverPreviewPosition()
	end
end)

vars.wire(vars.UserInputService.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		getgenv().__AvatarWearDrag.dragging = false
		getgenv().__AvatarWearDrag.start = nil
		getgenv().__AvatarWearDrag.position = nil
	end
end)

vars.wire(vars.UserInputService.TouchEnded, function()
	getgenv().__AvatarWearDrag.dragging = false
	getgenv().__AvatarWearDrag.start = nil
	getgenv().__AvatarWearDrag.position = nil
	if vars.ui.hoverButton then
		vars.stopHoverPreview()
	end
end)

vars.wire(vars.MinimizeButton.Activated, function()
	vars.minimized = not vars.minimized
	if vars.minimized then
		vars.MinimizeIcon.Text = vars.BUILDER_ICONS.Maximize
		vars.stopHoverPreview()
		vars.Main.Size = UDim2.new(0, vars.minimizedWidth, 0, 44)
		vars.SearchBox.Visible, vars.RefreshButton.Visible, vars.List.Visible = false, false, false
		vars.Status.Visible, vars.ErrorPopup.Visible, vars.WearButton.Visible, vars.ConfirmOverlay.Visible = false, false, false, false
	else
		vars.MinimizeIcon.Text = vars.BUILDER_ICONS.Minimize
		vars.Main.Size = UDim2.new(0, vars.mainWidth, 0, vars.savedMainHeight)
		vars.SearchBox.Visible, vars.RefreshButton.Visible, vars.List.Visible = true, true, true
		vars.Status.Visible, vars.WearButton.Visible = false, false
		if vars.currentConfirmAction then vars.ConfirmOverlay.Visible = true end
	end
	vars.updateMainShadow()
end)

vars.wire(vars.DestroyButton.Activated, function()
	vars.showConfirmation("Unload and Destroy script?", function()
		vars.stopLocalTryOn(false)
		vars.cleanup()
	end)
end)

if vars.LocalPlayer.Character then vars.bindCharacterLifecycle(vars.LocalPlayer.Character) end

vars.loadSavedAvatars()
vars.populateAvatarList()
task.defer(function()
	if vars.scriptAlive and not vars.previewQueueRunning then task.spawn(vars.processPreviewQueue) end
end)

end)

if not vars.success then
	warn("[Local Wearer] " .. tostring(vars.err))
end
