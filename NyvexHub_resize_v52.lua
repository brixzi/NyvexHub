local UI_URL = "https://raw.githubusercontent.com/brixzi/NyvexHub-BASE/refs/heads/main/main-fix.lua"

local source = game:HttpGet(UI_URL)

assert(
type(source) == "string" and #source > 0,
"Nyvex Hub: não foi possível carregar o main-fix.lua."
)

local animationStart = source:find(
"function Animation.Apply(theme, root, shineEnabled)",
1,
true
)

local animationEnd = source:find(
"\nend\nif not Animation then Animation = {Apply = function() end} end",
animationStart or 1,
true
)

assert(
animationStart and animationEnd,
"Nyvex Hub: não foi possível localizar Animation.Apply no main-fix.lua."
)

local customAnimation = [[
function Animation.Apply(theme, root, shineEnabled)
if not root then return end

local st = _state[root]  

if st and st.conn then  
    pcall(function()  
        st.conn:Disconnect()  
    end)  
end  

if st and st.reflectionConn then  
    pcall(function()  
        st.reflectionConn:Disconnect()  
    end)  
end  

    if st and st.reflectionLayerA and st.reflectionLayerA.Parent then  
    st.reflectionLayerA:Destroy()  
end  

if st and st.reflectionLayerB and st.reflectionLayerB.Parent then  
    st.reflectionLayerB:Destroy()  
end  

if st and st.secondaryReflectionLayer and st.secondaryReflectionLayer.Parent then  
    st.secondaryReflectionLayer:Destroy()  
end  

if st and st.thirdReflectionLayerA and st.thirdReflectionLayerA.Parent then  
    st.thirdReflectionLayerA:Destroy()  
end  

if st and st.thirdReflectionLayerB and st.thirdReflectionLayerB.Parent then  
    st.thirdReflectionLayerB:Destroy()  
end  

    if st and st.firstLayer and st.firstLayer.Parent then  
    st.firstLayer:Destroy()  
end  

if st and st.secondLayer and st.secondLayer.Parent then  
    st.secondLayer:Destroy()  
end  

if st and st.ambientLayer1 and st.ambientLayer1.Parent then  
    st.ambientLayer1:Destroy()  
end  

if st and st.ambientLayer2 and st.ambientLayer2.Parent then  
    st.ambientLayer2:Destroy()  
end  

if st and st.ambientLayer3 and st.ambientLayer3.Parent then  
    st.ambientLayer3:Destroy()  
end  

if st and st.ambientLayer4 and st.ambientLayer4.Parent then  
    st.ambientLayer4:Destroy()  
end  

if st and st.ambientLayer5 and st.ambientLayer5.Parent then  
    st.ambientLayer5:Destroy()  
end  

if st and st.ambientLayer6 and st.ambientLayer6.Parent then  
    st.ambientLayer6:Destroy()  
end  

if st and st.ambientLayer7 and st.ambientLayer7.Parent then  
    st.ambientLayer7:Destroy()  
end  

local prevGradients = st and st.gradients or {}  
local prevStrokes = st and st.strokes or {}  

for _, obj in ipairs(prevGradients) do  
    pcall(function()  
        if obj and obj.Parent then  
            obj:SetAttribute("_t", nil)  
            obj:SetAttribute("_ShineAnimated", nil)  
            obj:SetAttribute("_ShineDirection", nil)  
            obj:SetAttribute("_ShinePhase", nil)  
            obj:SetAttribute("_ShineSpeed", nil)  
            obj.Rotation = 0  
            obj.Offset = Vector2.new(0, 0)  
        end  
    end)  
end  

for _, obj in ipairs(prevStrokes) do  
    pcall(function()  
        if obj and obj.Parent then  
            obj:SetAttribute("_t", nil)  
            obj.Thickness = 1  
        end  
    end)  
end  

                    st = {  
                            conn = nil,  
    reflectionConn = nil,  
    gradients = {},  
    strokes = {},  
    ambientLayer1 = nil,  
    ambientLayer2 = nil,  
    ambientLayer3 = nil,  
    ambientLayer4 = nil,  
    ambientLayer5 = nil,  
    ambientLayer6 = nil,  
    ambientLayer7 = nil,  

            reflectionLayerA = nil,  
    reflectionGradientA = nil,  
    reflectionLayerB = nil,  
    reflectionGradientB = nil,  
    reflectionPhase = 0.52,  
    reflectionSpeed = 0.035,  
    reflectionCycle = 0,  

    thirdReflectionLayerA = nil,  
    thirdReflectionGradientA = nil,  
    thirdReflectionLayerB = nil,  
    thirdReflectionGradientB = nil,  
    thirdReflectionPhase = 0.48,  
    thirdReflectionSpeed = 0.028,  

    secondaryReflectionLayer = nil,  
    secondaryReflectionGradient = nil,  
    secondaryReflectionActive = false,  
    secondaryReflectionStartedAt = 0,  
    secondaryReflectionDuration = 0,  
    secondaryReflectionFrom = Vector2.zero,  
    secondaryReflectionTo = Vector2.zero,  
    secondaryReflectionCycle = -1,  

    secondLayer = nil,  
    secondGradient = nil,  
    secondT = 0,  
    firstRotation = 0,  
    secondRotation = 0,  
    random = Random.new(),  

    firstSpeed = 1,  
    firstSpeedTarget = 1,  
    firstSpeedChange = 0,  

    secondSpeed = 0.87,  
    secondSpeedTarget = 0.87,  
    secondSpeedChange = 0,  

    firstRotation = 0,  
    firstRotationSpeed = 1,  
    firstRotationSpeedTarget = 1,  
    firstRotationChange = 0,  

    secondRotation = 0,  
    secondRotationSpeed = 0.87,  
    secondRotationSpeedTarget = 0.87,  
    secondRotationChange = 0,  
}  

_state[root] = st  

if not theme or not shineEnabled or not theme.ShineEnabled or not theme.Shine then  
    return  
end  

local ShineConfig = theme.Shine  
local Speed = tonumber(ShineConfig.Speed) or 0.5  
local RotationSpeed = tonumber(ShineConfig.RotationSpeed) or 25  
local ColorSeq = ShineConfig.ColorSequence  
local StrokeShineOn = theme.StrokeShine  
local StrokeFrom = theme.StrokeDark or theme.AcrylicBorder  
local StrokeTo = theme.Accent  

local _gradients, _strokes = st.gradients, st.strokes  
local glowTime = 0  
local glowAccumulator = 0  

local glowSeedFirst =  
    Random.new():NextNumber(  
        -10000,  
        10000  
    )  

local glowSeedSecond =  
    Random.new():NextNumber(  
        -10000,  
        10000  
    )  

local function buildGlowSequences(  
    sequence,  
    minimumBrightness,  
    maximumBrightness  
)  
    if not sequence then  
        return nil  
    end  

    local levels = {}  
    local levelCount = 24  

    for level = 1, levelCount do  
        local alpha =  
            (level - 1)  
            / (levelCount - 1)  

        local brightness =  
            minimumBrightness  
            + (  
                maximumBrightness  
                - minimumBrightness  
            ) * alpha  

        local keypoints = {}  

        for _, keypoint in ipairs(  
            sequence.Keypoints  
        ) do  
            local h, s, v =  
                Color3.toHSV(  
                    keypoint.Value  
                )  

            v =  
                math.clamp(  
                    v * brightness,  
                    0,  
                    1  
                )  

            table.insert(  
                keypoints,  
                ColorSequenceKeypoint.new(  
                    keypoint.Time,  
                    Color3.fromHSV(  
                        h,  
                        s,  
                        v  
                    )  
                )  
            )  
        end  

        levels[level] =  
            ColorSequence.new(  
                keypoints  
            )  
    end  

    return levels  
end  

    local baseLayer = nil  
local baseGradient = nil  

for _, child in ipairs(root:GetChildren()) do  
    if child:IsA("Frame")  
        and child.Size.X.Scale == 1  
        and child.Size.X.Offset == 0  
        and child.Size.Y.Scale == 1  
        and child.Size.Y.Offset == 0 then  

        local gradient =  
            child:FindFirstChildOfClass(  
                "UIGradient"  
            )  

        if gradient  
            and not gradient:GetAttribute(  
                "_NyvexIndependentBeam"  
            ) then  

            baseLayer = child  
            baseGradient = gradient  
            break  
        end  
    end  
end  

if not baseLayer or not baseGradient then  
    return  
end  

pcall(function()  
    baseGradient:SetAttribute(  
        "_ShineAnimated",  
        nil  
    )  

    baseGradient:SetAttribute(  
        "_t",  
        nil  
    )  

    if theme.AcrylicGradient then  
        baseGradient.Color =  
            theme.AcrylicGradient  
    end  

    baseGradient.Rotation = 90  
    baseGradient.Offset =  
        Vector2.new(0, 0)  
end)  

    baseLayer.ZIndex = 0  

local ambientLayer1 =  
    Instance.new("Frame")  

ambientLayer1.Name =  
    "__NyvexAmbientA"  

ambientLayer1.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer1.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer1.BackgroundTransparency = 0  

ambientLayer1.BorderSizePixel = 0  

ambientLayer1.ZIndex = 0  

ambientLayer1.Archivable = false  

ambientLayer1.Parent =  
    baseLayer  

local ambientCorner1 =  
    Instance.new("UICorner")  

ambientCorner1.CornerRadius =  
    UDim.new(0, 8)  

ambientCorner1.Parent =  
    ambientLayer1  

local ambientGradient1 =  
    Instance.new("UIGradient")  

ambientGradient1.Name =  
    "__NyvexAmbientGradientA"  

ambientGradient1.Type =  
    Enum.GradientType.Radial  

ambientGradient1.Offset =  
    Vector2.new(-0.20, -0.18)  

ambientGradient1.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(255, 105, 168)  
        ),  
        ColorSequenceKeypoint.new(  
            0.34,  
            Color3.fromRGB(190, 51, 111)  
        ),  
        ColorSequenceKeypoint.new(  
            0.72,  
            Color3.fromRGB(100, 20, 62)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(65, 14, 39)  
        ),  
    })  

ambientGradient1.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.76),  
        NumberSequenceKeypoint.new(0.30, 0.84),  
        NumberSequenceKeypoint.new(0.62, 0.93),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

ambientGradient1.Parent =  
    ambientLayer1  

local ambientLayer2 =  
    Instance.new("Frame")  

ambientLayer2.Name =  
    "__NyvexAmbientB"  

ambientLayer2.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer2.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer2.BackgroundTransparency = 0  

ambientLayer2.BorderSizePixel = 0  

ambientLayer2.ZIndex = 0  

ambientLayer2.Archivable = false  

ambientLayer2.Parent =  
    baseLayer  

local ambientCorner2 =  
    Instance.new("UICorner")  

ambientCorner2.CornerRadius =  
    UDim.new(0, 8)  

ambientCorner2.Parent =  
    ambientLayer2  

local ambientGradient2 =  
    Instance.new("UIGradient")  

ambientGradient2.Name =  
    "__NyvexAmbientGradientB"  

ambientGradient2.Type =  
    Enum.GradientType.Radial  

ambientGradient2.Offset =  
    Vector2.new(0.24, 0.22)  

ambientGradient2.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(176, 91, 205)  
        ),  
        ColorSequenceKeypoint.new(  
            0.35,  
            Color3.fromRGB(119, 45, 145)  
        ),  
        ColorSequenceKeypoint.new(  
            0.72,  
            Color3.fromRGB(77, 22, 94)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(49, 13, 56)  
        ),  
    })  

ambientGradient2.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.83),  
        NumberSequenceKeypoint.new(0.30, 0.89),  
        NumberSequenceKeypoint.new(0.64, 0.96),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

ambientGradient2.Parent =  
    ambientLayer2  

    st.ambientLayer1 =  
    ambientLayer1  

st.ambientLayer2 =  
    ambientLayer2  

    local ambientLayer3 =  
    Instance.new("Frame")  

ambientLayer3.Name =  
    "__NyvexAmbientC"  

ambientLayer3.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer3.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer3.BackgroundTransparency = 0  
ambientLayer3.BorderSizePixel = 0  
ambientLayer3.ZIndex = 0  
ambientLayer3.Archivable = false  
ambientLayer3.Parent = baseLayer  

local ambientGradient3 =  
    Instance.new("UIGradient")  

ambientGradient3.Name =  
    "__NyvexAmbientGradientC"  

ambientGradient3.Type =  
    Enum.GradientType.Linear  

ambientGradient3.Rotation = 132  
ambientGradient3.Scale =  
    Vector2.new(1.25, 1.25)  

    ambientGradient3.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(76, 16, 40)  
        ),  
        ColorSequenceKeypoint.new(  
            0.12,  
            Color3.fromRGB(101, 23, 55)  
        ),  
        ColorSequenceKeypoint.new(  
            0.24,  
            Color3.fromRGB(79, 17, 48)  
        ),  
        ColorSequenceKeypoint.new(  
            0.37,  
            Color3.fromRGB(119, 29, 72)  
        ),  
        ColorSequenceKeypoint.new(  
            0.49,  
            Color3.fromRGB(91, 20, 61)  
        ),  
        ColorSequenceKeypoint.new(  
            0.61,  
            Color3.fromRGB(128, 32, 79)  
        ),  
        ColorSequenceKeypoint.new(  
            0.73,  
            Color3.fromRGB(86, 18, 58)  
        ),  
        ColorSequenceKeypoint.new(  
            0.85,  
            Color3.fromRGB(107, 24, 61)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(56, 12, 36)  
        ),  
    })  

ambientGradient3.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.93),  
        NumberSequenceKeypoint.new(0.12, 0.88),  
        NumberSequenceKeypoint.new(0.24, 0.84),  
        NumberSequenceKeypoint.new(0.37, 0.79),  
        NumberSequenceKeypoint.new(0.49, 0.74),  
        NumberSequenceKeypoint.new(0.61, 0.76),  
        NumberSequenceKeypoint.new(0.73, 0.81),  
        NumberSequenceKeypoint.new(0.85, 0.87),  
        NumberSequenceKeypoint.new(1, 0.94),  
    })  

ambientGradient3.Parent =  
    ambientLayer3  

local ambientLayer4 =  
    Instance.new("Frame")  

ambientLayer4.Name =  
    "__NyvexAmbientD"  

ambientLayer4.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer4.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer4.BackgroundTransparency = 0  
ambientLayer4.BorderSizePixel = 0  
ambientLayer4.ZIndex = 0  
ambientLayer4.Archivable = false  
ambientLayer4.Parent = baseLayer  

local ambientGradient4 =  
    Instance.new("UIGradient")  

ambientGradient4.Name =  
    "__NyvexAmbientGradientD"  

ambientGradient4.Type =  
    Enum.GradientType.Linear  

ambientGradient4.Rotation = 41  
ambientGradient4.Scale =  
    Vector2.new(1.15, 1.15)  

    ambientGradient4.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(82, 22, 58)  
        ),  
        ColorSequenceKeypoint.new(  
            0.20,  
            Color3.fromRGB(139, 46, 97)  
        ),  
        ColorSequenceKeypoint.new(  
            0.34,  
            Color3.fromRGB(194, 76, 130)  
        ),  
        ColorSequenceKeypoint.new(  
            0.43,  
            Color3.fromRGB(231, 116, 170)  
        ),  
        ColorSequenceKeypoint.new(  
            0.50,  
            Color3.fromRGB(250, 154, 201)  
        ),  
        ColorSequenceKeypoint.new(  
            0.57,  
            Color3.fromRGB(231, 116, 170)  
        ),  
        ColorSequenceKeypoint.new(  
            0.66,  
            Color3.fromRGB(187, 69, 125)  
        ),  
        ColorSequenceKeypoint.new(  
            0.80,  
            Color3.fromRGB(126, 38, 91)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(65, 16, 42)  
        ),  
    })  

ambientGradient4.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 1),  
        NumberSequenceKeypoint.new(0.24, 0.995),  
        NumberSequenceKeypoint.new(0.34, 0.985),  
        NumberSequenceKeypoint.new(0.42, 0.95),  
        NumberSequenceKeypoint.new(0.48, 0.90),  
        NumberSequenceKeypoint.new(0.50, 0.87),  
        NumberSequenceKeypoint.new(0.52, 0.90),  
        NumberSequenceKeypoint.new(0.58, 0.95),  
        NumberSequenceKeypoint.new(0.68, 0.985),  
        NumberSequenceKeypoint.new(0.78, 0.995),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

ambientGradient4.Parent =  
    ambientLayer4  

local ambientLayer5 =  
    Instance.new("Frame")  

ambientLayer5.Name =  
    "__NyvexAmbientE"  

ambientLayer5.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer5.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer5.BackgroundTransparency = 0  
ambientLayer5.BorderSizePixel = 0  
ambientLayer5.ZIndex = 0  
ambientLayer5.Archivable = false  
ambientLayer5.Parent = baseLayer  

local ambientGradient5 =  
    Instance.new("UIGradient")  

ambientGradient5.Name =  
    "__NyvexAmbientGradientE"  

ambientGradient5.Type =  
    Enum.GradientType.Radial  

ambientGradient5.Offset =  
    Vector2.new(0.38, -0.22)  

ambientGradient5.Scale =  
    Vector2.new(1.55, 1.15)  

ambientGradient5.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(255, 118, 180)  
        ),  
        ColorSequenceKeypoint.new(  
            0.20,  
            Color3.fromRGB(208, 69, 134)  
        ),  
        ColorSequenceKeypoint.new(  
            0.46,  
            Color3.fromRGB(139, 38, 91)  
        ),  
        ColorSequenceKeypoint.new(  
            0.72,  
            Color3.fromRGB(86, 21, 60)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(48, 12, 32)  
        ),  
    })  

ambientGradient5.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.84),  
        NumberSequenceKeypoint.new(0.20, 0.88),  
        NumberSequenceKeypoint.new(0.45, 0.94),  
        NumberSequenceKeypoint.new(0.72, 0.98),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

ambientGradient5.Parent =  
    ambientLayer5  

local ambientLayer6 =  
    Instance.new("Frame")  

ambientLayer6.Name =  
    "__NyvexAmbientF"  

ambientLayer6.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer6.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer6.BackgroundTransparency = 0  
ambientLayer6.BorderSizePixel = 0  
ambientLayer6.ZIndex = 0  
ambientLayer6.Archivable = false  
ambientLayer6.Parent = baseLayer  

local ambientGradient6 =  
    Instance.new("UIGradient")  

ambientGradient6.Name =  
    "__NyvexAmbientGradientF"  

ambientGradient6.Type =  
    Enum.GradientType.Radial  

ambientGradient6.Offset =  
    Vector2.new(-0.30, 0.30)  

ambientGradient6.Scale =  
    Vector2.new(1.70, 1.30)  

ambientGradient6.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(201, 93, 194)  
        ),  
        ColorSequenceKeypoint.new(  
            0.24,  
            Color3.fromRGB(145, 51, 139)  
        ),  
        ColorSequenceKeypoint.new(  
            0.48,  
            Color3.fromRGB(101, 31, 105)  
        ),  
        ColorSequenceKeypoint.new(  
            0.74,  
            Color3.fromRGB(67, 19, 74)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(42, 12, 44)  
        ),  
    })  

ambientGradient6.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.88),  
        NumberSequenceKeypoint.new(0.22, 0.92),  
        NumberSequenceKeypoint.new(0.46, 0.96),  
        NumberSequenceKeypoint.new(0.72, 0.985),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

ambientGradient6.Parent =  
    ambientLayer6  

local ambientLayer7 =  
    Instance.new("Frame")  

ambientLayer7.Name =  
    "__NyvexAmbientG"  

ambientLayer7.Size =  
    UDim2.fromScale(1, 1)  

ambientLayer7.Position =  
    UDim2.fromScale(0, 0)  

ambientLayer7.BackgroundTransparency = 0  
ambientLayer7.BorderSizePixel = 0  
ambientLayer7.ZIndex = 0  
ambientLayer7.Archivable = false  
ambientLayer7.Parent = baseLayer  

local ambientGradient7 =  
    Instance.new("UIGradient")  

ambientGradient7.Name =  
    "__NyvexAmbientGradientG"  

ambientGradient7.Type =  
    Enum.GradientType.Linear  

ambientGradient7.Rotation = 96  
ambientGradient7.Scale =  
    Vector2.new(1.35, 1.35)  

ambientGradient7.Color =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(44, 10, 30)  
        ),  
        ColorSequenceKeypoint.new(  
            0.30,  
            Color3.fromRGB(79, 18, 55)  
        ),  
        ColorSequenceKeypoint.new(  
            0.48,  
            Color3.fromRGB(123, 31, 78)  
        ),  
        ColorSequenceKeypoint.new(  
            0.60,  
            Color3.fromRGB(93, 23, 71)  
        ),  
        ColorSequenceKeypoint.new(  
            0.82,  
            Color3.fromRGB(61, 14, 45)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(33, 8, 25)  
        ),  
    })  

ambientGradient7.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 0.95),  
        NumberSequenceKeypoint.new(0.28, 0.91),  
        NumberSequenceKeypoint.new(0.44, 0.87),  
        NumberSequenceKeypoint.new(0.55, 0.89),  
        NumberSequenceKeypoint.new(0.70, 0.93),  
        NumberSequenceKeypoint.new(1, 0.97),  
    })  

ambientGradient7.Parent =  
    ambientLayer7  

st.ambientLayer3 =  
    ambientLayer3  

st.ambientLayer4 =  
    ambientLayer4  

st.ambientLayer5 =  
    ambientLayer5  

st.ambientLayer6 =  
    ambientLayer6  

    st.ambientLayer7 =  
    ambientLayer7  

            local function createReflectionPair(  
    prefix,  
    rotation,  
    axis,  
    phase,  
    colors,  
    transparency  
)  
    local layerA =  
        Instance.new("Frame")  

    layerA.Name =  
        prefix .. "A"  

    layerA.Size =  
        UDim2.fromScale(1, 1)  

    layerA.Position =  
        UDim2.fromScale(0, 0)  

    layerA.BackgroundColor3 =  
        Color3.fromRGB(255, 180, 220)  

    layerA.BackgroundTransparency = 0  
    layerA.BorderSizePixel = 0  
    layerA.ZIndex = 1  
    layerA.Archivable = false  
    layerA.Parent = baseLayer  

    local gradientA =  
        Instance.new("UIGradient")  

    gradientA.Name =  
        prefix .. "GradientA"  

    gradientA.Type =  
        Enum.GradientType.Linear  

    gradientA.Rotation =  
        rotation  

    gradientA.Scale =  
        1  

    gradientA.TileMode =  
        Enum.GradientTileMode.Clamp  

    gradientA.Color =  
        colors  

    gradientA.Transparency =  
        transparency  

    gradientA.Offset =  
        axis * phase  

    gradientA.Parent =  
        layerA  

    local layerB =  
        Instance.new("Frame")  

    layerB.Name =  
        prefix .. "B"  

    layerB.Size =  
        UDim2.fromScale(1, 1)  

    layerB.Position =  
        UDim2.fromScale(0, 0)  

    layerB.BackgroundColor3 =  
        Color3.fromRGB(255, 180, 220)  

    layerB.BackgroundTransparency = 0  
    layerB.BorderSizePixel = 0  
    layerB.ZIndex = 1  
    layerB.Archivable = false  
    layerB.Parent = baseLayer  

    local gradientB =  
        Instance.new("UIGradient")  

    gradientB.Name =  
        prefix .. "GradientB"  

    gradientB.Type =  
        Enum.GradientType.Linear  

    gradientB.Rotation =  
        rotation  

    gradientB.Scale =  
        1  

    gradientB.TileMode =  
        Enum.GradientTileMode.Clamp  

    gradientB.Color =  
        colors  

    gradientB.Transparency =  
        transparency  

    gradientB.Offset =  
        axis * (phase - 1)  

    gradientB.Parent =  
        layerB  

    return layerA, gradientA, layerB, gradientB  
end  

local reflectionColors =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(222, 156, 202)  
        ),  
        ColorSequenceKeypoint.new(  
            0.36,  
            Color3.fromRGB(239, 181, 220)  
        ),  
        ColorSequenceKeypoint.new(  
            0.47,  
            Color3.fromRGB(255, 226, 242)  
        ),  
        ColorSequenceKeypoint.new(  
            0.53,  
            Color3.fromRGB(255, 239, 248)  
        ),  
        ColorSequenceKeypoint.new(  
            0.64,  
            Color3.fromRGB(239, 181, 220)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(222, 156, 202)  
        ),  
    })  

local reflectionTransparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 1),  
        NumberSequenceKeypoint.new(0.27, 1),  
        NumberSequenceKeypoint.new(0.37, 0.96),  
        NumberSequenceKeypoint.new(0.43, 0.86),  
        NumberSequenceKeypoint.new(0.47, 0.74),  
        NumberSequenceKeypoint.new(0.50, 0.70),  
        NumberSequenceKeypoint.new(0.53, 0.74),  
        NumberSequenceKeypoint.new(0.57, 0.86),  
        NumberSequenceKeypoint.new(0.63, 0.96),  
        NumberSequenceKeypoint.new(0.73, 1),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

local reflectionLayerA,  
    reflectionGradientA,  
    reflectionLayerB,  
    reflectionGradientB =  
    createReflectionPair(  
        "__NyvexAmbientReflection",  
        24,  
        Vector2.new(1, 0),  
        st.reflectionPhase,  
        reflectionColors,  
        reflectionTransparency  
    )  

st.reflectionLayerA =  
    reflectionLayerA  

st.reflectionGradientA =  
    reflectionGradientA  

st.reflectionLayerB =  
    reflectionLayerB  

st.reflectionGradientB =  
    reflectionGradientB  

local thirdReflectionColors =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(215, 143, 199)  
        ),  
        ColorSequenceKeypoint.new(  
            0.35,  
            Color3.fromRGB(235, 177, 217)  
        ),  
        ColorSequenceKeypoint.new(  
            0.47,  
            Color3.fromRGB(255, 222, 242)  
        ),  
        ColorSequenceKeypoint.new(  
            0.53,  
            Color3.fromRGB(255, 237, 248)  
        ),  
        ColorSequenceKeypoint.new(  
            0.65,  
            Color3.fromRGB(235, 177, 217)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(215, 143, 199)  
        ),  
    })  

local thirdReflectionTransparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 1),  
        NumberSequenceKeypoint.new(0.27, 1),  
        NumberSequenceKeypoint.new(0.37, 0.97),  
        NumberSequenceKeypoint.new(0.43, 0.88),  
        NumberSequenceKeypoint.new(0.47, 0.77),  
        NumberSequenceKeypoint.new(0.50, 0.72),  
        NumberSequenceKeypoint.new(0.53, 0.77),  
        NumberSequenceKeypoint.new(0.57, 0.88),  
        NumberSequenceKeypoint.new(0.63, 0.97),  
        NumberSequenceKeypoint.new(0.73, 1),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

local thirdReflectionLayerA,  
    thirdReflectionGradientA,  
    thirdReflectionLayerB,  
    thirdReflectionGradientB =  
    createReflectionPair(  
        "__NyvexThirdReflection",  
        94,  
        Vector2.new(0, 1),  
        st.thirdReflectionPhase,  
        thirdReflectionColors,  
        thirdReflectionTransparency  
    )  

st.thirdReflectionLayerA =  
    thirdReflectionLayerA  

st.thirdReflectionGradientA =  
    thirdReflectionGradientA  

st.thirdReflectionLayerB =  
    thirdReflectionLayerB  

st.thirdReflectionGradientB =  
    thirdReflectionGradientB  

st.reflectionCycle =  
    0  

st.secondaryReflectionActive =  
    false  

st.secondaryReflectionCycle =  
    -1  

local function createSecondaryReflection()  
    if st.secondaryReflectionActive then  
        return  
    end  

    local random =  
        st.random  

    local variant =  
        random:NextInteger(1, 6)  

    local from  
    local to  
    local rotation  

    if variant == 1 then  
        from =  
            Vector2.new(  
                -1.05,  
                random:NextNumber(-0.20, 0.20)  
            )  

        to =  
            Vector2.new(  
                1.05,  
                random:NextNumber(-0.20, 0.20)  
            )  

        rotation =  
            random:NextNumber(12, 30)  

    elseif variant == 2 then  
        from =  
            Vector2.new(  
                1.05,  
                random:NextNumber(-0.20, 0.20)  
            )  

        to =  
            Vector2.new(  
                -1.05,  
                random:NextNumber(-0.20, 0.20)  
            )  

        rotation =  
            random:NextNumber(150, 168)  

    elseif variant == 3 then  
        from =  
            Vector2.new(  
                random:NextNumber(-0.20, 0.20),  
                -1.05  
            )  

        to =  
            Vector2.new(  
                random:NextNumber(-0.20, 0.20),  
                1.05  
            )  

        rotation =  
            random:NextNumber(78, 102)  

    elseif variant == 4 then  
        from =  
            Vector2.new(  
                random:NextNumber(-0.20, 0.20),  
                1.05  
            )  

        to =  
            Vector2.new(  
                random:NextNumber(-0.20, 0.20),  
                -1.05  
            )  

        rotation =  
            random:NextNumber(78, 102)  

    elseif variant == 5 then  
        from =  
            Vector2.new(-1.05, 1.05)  

        to =  
            Vector2.new(1.05, -1.05)  

        rotation =  
            random:NextNumber(24, 45)  

    else  
        from =  
            Vector2.new(1.05, -1.05)  

        to =  
            Vector2.new(-1.05, 1.05)  

        rotation =  
            random:NextNumber(135, 156)  
    end  

    local secondaryLayer =  
        Instance.new("Frame")  

    secondaryLayer.Name =  
        "__NyvexSecondaryReflection"  

    secondaryLayer.Size =  
        UDim2.fromScale(1, 1)  

    secondaryLayer.Position =  
        UDim2.fromScale(0, 0)  

    secondaryLayer.BackgroundColor3 =  
        Color3.fromRGB(255, 190, 225)  

    secondaryLayer.BackgroundTransparency = 0  
    secondaryLayer.BorderSizePixel = 0  
    secondaryLayer.ZIndex = 1  
    secondaryLayer.Archivable = false  
    secondaryLayer.Parent = baseLayer  

    local secondaryGradient =  
        Instance.new("UIGradient")  

    secondaryGradient.Name =  
        "__NyvexSecondaryReflectionGradient"  

    secondaryGradient.Type =  
        Enum.GradientType.Linear  

    secondaryGradient.Rotation =  
        rotation  

    secondaryGradient.Scale =  
        random:NextNumber(0.82, 1.05)  

    secondaryGradient.TileMode =  
        Enum.GradientTileMode.Clamp  

    secondaryGradient.Color =  
        ColorSequence.new({  
            ColorSequenceKeypoint.new(  
                0,  
                Color3.fromRGB(205, 132, 183)  
            ),  
            ColorSequenceKeypoint.new(  
                0.36,  
                Color3.fromRGB(235, 175, 215)  
            ),  
            ColorSequenceKeypoint.new(  
                0.48,  
                Color3.fromRGB(255, 226, 242)  
            ),  
            ColorSequenceKeypoint.new(  
                0.52,  
                Color3.fromRGB(255, 238, 248)  
            ),  
            ColorSequenceKeypoint.new(  
                0.64,  
                Color3.fromRGB(235, 175, 215)  
            ),  
            ColorSequenceKeypoint.new(  
                1,  
                Color3.fromRGB(205, 132, 183)  
            ),  
        })  

    secondaryGradient.Transparency =  
        NumberSequence.new({  
            NumberSequenceKeypoint.new(0, 1),  
            NumberSequenceKeypoint.new(0.32, 1),  
            NumberSequenceKeypoint.new(0.42, 0.97),  
            NumberSequenceKeypoint.new(0.47, 0.88),  
            NumberSequenceKeypoint.new(0.50, 0.78),  
            NumberSequenceKeypoint.new(0.53, 0.88),  
            NumberSequenceKeypoint.new(0.58, 0.97),  
            NumberSequenceKeypoint.new(0.68, 1),  
            NumberSequenceKeypoint.new(1, 1),  
        })  

    secondaryGradient.Offset =  
        from  

    secondaryGradient.Parent =  
        secondaryLayer  

    st.secondaryReflectionLayer =  
        secondaryLayer  

    st.secondaryReflectionGradient =  
        secondaryGradient  

    st.secondaryReflectionActive =  
        true  

    st.secondaryReflectionStartedAt =  
        os.clock()  

    st.secondaryReflectionDuration =  
        random:NextNumber(17, 25)  

    st.secondaryReflectionFrom =  
        from  

    st.secondaryReflectionTo =  
        to  
end  

st.reflectionConn =  
    _RunService.RenderStepped:Connect(  
        function(dt)  
            local previousReflectionPhase =  
                st.reflectionPhase  

            st.reflectionPhase =  
                (  
                    st.reflectionPhase  
                    + dt * st.reflectionSpeed  
                ) % 1  

            if st.reflectionPhase  
                < previousReflectionPhase then  

                st.reflectionCycle =  
                    st.reflectionCycle + 1  
            end  

            st.reflectionGradientA.Offset =  
                Vector2.new(  
                    st.reflectionPhase,  
                    0  
                )  

            st.reflectionGradientB.Offset =  
                Vector2.new(  
                    st.reflectionPhase - 1,  
                    0  
                )  

            st.thirdReflectionPhase =  
                (  
                    st.thirdReflectionPhase  
                    - dt * st.thirdReflectionSpeed  
                ) % 1  

            st.thirdReflectionGradientA.Offset =  
                Vector2.new(  
                    0,  
                    st.thirdReflectionPhase  
                )  

            st.thirdReflectionGradientB.Offset =  
                Vector2.new(  
                    0,  
                    st.thirdReflectionPhase - 1  
                )  

            if st.reflectionPhase >= 0.78  
                and st.secondaryReflectionCycle  
                    ~= st.reflectionCycle then  

                st.secondaryReflectionCycle =  
                    st.reflectionCycle  

                if st.random:NextNumber()  
                    < 0.48 then  

                    createSecondaryReflection()  
                end  
            end  

            if st.secondaryReflectionActive  
                and st.secondaryReflectionGradient  
                and st.secondaryReflectionGradient.Parent then  

                local elapsed =  
                    os.clock()  
                    - st.secondaryReflectionStartedAt  

                local progress =  
                    math.clamp(  
                        elapsed  
                        / st.secondaryReflectionDuration,  
                        0,  
                        1  
                    )  

                local smoothProgress =  
                    progress  
                    * progress  
                    * (  
                        3  
                        - 2 * progress  
                    )  

                st.secondaryReflectionGradient.Offset =  
                    st.secondaryReflectionFrom:Lerp(  
                        st.secondaryReflectionTo,  
                        smoothProgress  
                    )  

                if progress >= 1 then  
                    st.secondaryReflectionLayer:Destroy()  

                    st.secondaryReflectionLayer =  
                        nil  

                    st.secondaryReflectionGradient =  
                        nil  

                    st.secondaryReflectionActive =  
                        false  
                end  
            end  
        end  
    )  

    local firstLayer =  
    baseLayer:Clone()  

firstLayer.Name =  
    "__NyvexFirstBeam"  

    firstLayer.ZIndex = 2  
firstLayer.Parent = baseLayer  

            firstLayer.BackgroundTransparency = 0.04  

local firstGradient =  
    firstLayer:FindFirstChildOfClass(  
        "UIGradient"  
    )  

if not firstGradient then  
    firstLayer:Destroy()  
    return  
end  

firstGradient.Name =  
    "__NyvexFirstBeamGradient"  

firstGradient:SetAttribute(  
    "_NyvexIndependentBeam",  
    true  
)  

firstGradient:SetAttribute(  
    "_ShineAnimated",  
    true  
)  

firstGradient:SetAttribute(  
    "_t",  
    0  
)  

        local firstColorSeq =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(58, 14, 32)  
        ),  
        ColorSequenceKeypoint.new(  
            0.18,  
            Color3.fromRGB(58, 14, 32)  
        ),  
        ColorSequenceKeypoint.new(  
            0.28,  
            Color3.fromRGB(65, 16, 37)  
        ),  
        ColorSequenceKeypoint.new(  
            0.36,  
            Color3.fromRGB(78, 18, 44)  
        ),  
        ColorSequenceKeypoint.new(  
            0.43,  
            Color3.fromRGB(101, 23, 55)  
        ),  
        ColorSequenceKeypoint.new(  
            0.50,  
            Color3.fromRGB(132, 32, 62)  
        ),  
        ColorSequenceKeypoint.new(  
            0.57,  
            Color3.fromRGB(101, 23, 55)  
        ),  
        ColorSequenceKeypoint.new(  
            0.64,  
            Color3.fromRGB(78, 18, 44)  
        ),  
        ColorSequenceKeypoint.new(  
            0.72,  
            Color3.fromRGB(65, 16, 37)  
        ),  
        ColorSequenceKeypoint.new(  
            0.82,  
            Color3.fromRGB(58, 14, 32)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(58, 14, 32)  
        ),  
    })  

firstGradient.Color =  
    firstColorSeq  

        firstGradient.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 1),  
        NumberSequenceKeypoint.new(0.18, 0.92),  
        NumberSequenceKeypoint.new(0.28, 0.68),  
        NumberSequenceKeypoint.new(0.36, 0.34),  
        NumberSequenceKeypoint.new(0.43, 0.10),  
        NumberSequenceKeypoint.new(0.50, 0),  
        NumberSequenceKeypoint.new(0.57, 0.10),  
        NumberSequenceKeypoint.new(0.64, 0.34),  
        NumberSequenceKeypoint.new(0.72, 0.68),  
        NumberSequenceKeypoint.new(0.82, 0.92),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

firstGradient.Rotation = 0  
firstGradient.Offset =  
    Vector2.new(0, 0)  

table.insert(  
    _gradients,  
    firstGradient  
)  

pcall(function()  
    if firstLayer:IsA("GuiObject") then  
        firstLayer.ClipsDescendants =  
            false  
    end  
end)  

local secondLayer =  
    firstLayer:Clone()  

    secondLayer.Name =  
    "__NyvexSecondBeam"  

        secondLayer.ZIndex = 3  
secondLayer.BackgroundTransparency = 0.12  

secondLayer.Parent =  
    baseLayer  

local secondGradient =  
    secondLayer:FindFirstChildOfClass(  
        "UIGradient"  
    )  

if not secondGradient then  
    secondLayer:Destroy()  
    return  
end  

secondGradient.Name =  
    "__NyvexSecondBeamGradient"  

secondGradient:SetAttribute(  
    "_NyvexIndependentBeam",  
    true  
)  

secondGradient:SetAttribute(  
    "_ShineAnimated",  
    nil  
)  

secondGradient:SetAttribute(  
    "_ShineDirection",  
    nil  
)  

secondGradient:SetAttribute(  
    "_ShinePhase",  
    nil  
)  

secondGradient:SetAttribute(  
    "_ShineSpeed",  
    nil  
)  

secondGradient:SetAttribute(  
    "_t",  
    0  
)  

    local secondColorSeq =  
    ColorSequence.new({  
        ColorSequenceKeypoint.new(  
            0,  
            Color3.fromRGB(45, 12, 30)  
        ),  
        ColorSequenceKeypoint.new(  
            0.20,  
            Color3.fromRGB(45, 12, 30)  
        ),  
        ColorSequenceKeypoint.new(  
            0.28,  
            Color3.fromRGB(52, 14, 36)  
        ),  
        ColorSequenceKeypoint.new(  
            0.34,  
            Color3.fromRGB(68, 16, 45)  
        ),  
        ColorSequenceKeypoint.new(  
            0.40,  
            Color3.fromRGB(90, 20, 54)  
        ),  
        ColorSequenceKeypoint.new(  
            0.45,  
            Color3.fromRGB(112, 26, 64)  
        ),  
        ColorSequenceKeypoint.new(  
            0.50,  
            Color3.fromRGB(132, 32, 72)  
        ),  
        ColorSequenceKeypoint.new(  
            0.55,  
            Color3.fromRGB(112, 26, 64)  
        ),  
        ColorSequenceKeypoint.new(  
            0.60,  
            Color3.fromRGB(90, 20, 54)  
        ),  
        ColorSequenceKeypoint.new(  
            0.66,  
            Color3.fromRGB(68, 16, 45)  
        ),  
        ColorSequenceKeypoint.new(  
            0.72,  
            Color3.fromRGB(52, 14, 36)  
        ),  
        ColorSequenceKeypoint.new(  
            0.80,  
            Color3.fromRGB(45, 12, 30)  
        ),  
        ColorSequenceKeypoint.new(  
            1,  
            Color3.fromRGB(45, 12, 30)  
        ),  
    })  

secondGradient.Color =  
    secondColorSeq  

                    secondGradient.Transparency =  
    NumberSequence.new({  
        NumberSequenceKeypoint.new(0, 1),  
        NumberSequenceKeypoint.new(0.05, 0.98),  
        NumberSequenceKeypoint.new(0.10, 0.92),  
        NumberSequenceKeypoint.new(0.16, 0.82),  
        NumberSequenceKeypoint.new(0.22, 0.66),  
        NumberSequenceKeypoint.new(0.28, 0.48),  
        NumberSequenceKeypoint.new(0.34, 0.32),  
        NumberSequenceKeypoint.new(0.40, 0.18),  
        NumberSequenceKeypoint.new(0.45, 0.06),  
        NumberSequenceKeypoint.new(0.50, 0),  
        NumberSequenceKeypoint.new(0.55, 0.06),  
        NumberSequenceKeypoint.new(0.60, 0.18),  
        NumberSequenceKeypoint.new(0.66, 0.32),  
        NumberSequenceKeypoint.new(0.72, 0.48),  
        NumberSequenceKeypoint.new(0.78, 0.66),  
        NumberSequenceKeypoint.new(0.84, 0.82),  
        NumberSequenceKeypoint.new(0.90, 0.92),  
        NumberSequenceKeypoint.new(0.95, 0.98),  
        NumberSequenceKeypoint.new(1, 1),  
    })  

local secondSize =  
    secondLayer.AbsoluteSize  

local secondBaseRotation =  
    126.5  

if secondSize.X > 0  
    and secondSize.Y > 0 then  

    secondBaseRotation =  
        90  
        + math.deg(  
            math.atan2(  
                secondSize.Y,  
                secondSize.X  
            )  
        )  
end  

secondGradient.Rotation =  
    secondBaseRotation  

secondGradient.Offset =  
    Vector2.new(0, 0)  

st.firstLayer =  
    firstLayer  

st.secondLayer =  
    secondLayer  

st.firstGradient =  
    firstGradient  

st.secondGradient =  
    secondGradient  

    local firstGlowSequences =  
    buildGlowSequences(  
        ColorSeq,  
        0.62,  
        1.06  
    )  

local secondGlowSequences =  
    buildGlowSequences(  
        secondColorSeq,  
        0.58,  
        1.05  
    )  

if #_gradients == 0 and #_strokes == 0 then  
    return  
end  

            st.conn = _RunService.RenderStepped:Connect(function(dt)  
    glowTime =  
        glowTime  
        + dt  

    glowAccumulator =  
        glowAccumulator  
        + dt  

    local random = st.random  

    local function updateMotionTarget(  
        current,  
        target,  
        change,  
        dt,  
        minimum,  
        maximum,  
        minimumTime,  
        maximumTime  
    )  
        change = math.max(change - dt, 0)  

        if change <= 0 then  
            target = random:NextNumber(  
                minimum,  
                maximum  
            )  

            change = random:NextNumber(  
                minimumTime,  
                maximumTime  
            )  
        end  

        local response =  
            1  
            - math.exp(  
                -dt * 1.8  
            )  

        current =  
            current  
            + (target - current)  
            * response  

        return current, target, change  
    end  

    st.firstSpeed,  
    st.firstSpeedTarget,  
    st.firstSpeedChange =  
        updateMotionTarget(  
            st.firstSpeed,  
            st.firstSpeedTarget,  
            st.firstSpeedChange,  
            dt,  
            0.92,  
            1.08,  
            1.8,  
            4.2  
        )  

    st.secondSpeed,  
    st.secondSpeedTarget,  
    st.secondSpeedChange =  
        updateMotionTarget(  
            st.secondSpeed,  
            st.secondSpeedTarget,  
            st.secondSpeedChange,  
            dt,  
            0.74,  
            0.98,  
            1.4,  
            3.8  
        )  

    st.firstRotationSpeed,  
    st.firstRotationSpeedTarget,  
    st.firstRotationChange =  
        updateMotionTarget(  
            st.firstRotationSpeed,  
            st.firstRotationSpeedTarget,  
            st.firstRotationChange,  
            dt,  
            0.94,  
            1.06,  
            2.0,  
            4.6  
        )  

    st.secondRotationSpeed,  
    st.secondRotationSpeedTarget,  
    st.secondRotationChange =  
        updateMotionTarget(  
            st.secondRotationSpeed,  
            st.secondRotationSpeedTarget,  
            st.secondRotationChange,  
            dt,  
            0.78,  
            0.96,  
            1.5,  
            4.0  
        )  

    local firstSpeed =  
        Speed * st.firstSpeed  

    local secondSpeed =  
        Speed * st.secondSpeed  

    local firstRotationSpeed =  
        RotationSpeed  
        * st.firstRotationSpeed  

    local secondRotationSpeed =  
        RotationSpeed  
        * st.secondRotationSpeed  

            for i = #_gradients, 1, -1 do  
        local obj = _gradients[i]  

        if obj.Parent then  
            local t =  
                (obj:GetAttribute("_t") or 0)  
                + dt * firstSpeed  

            obj:SetAttribute("_t", t)  

            st.firstRotation =  
                st.firstRotation  
                + dt * firstRotationSpeed  

            obj.Rotation =  
                st.firstRotation  
                % 360  

            obj.Offset =  
                Vector2.new(  
                    math.sin(t * 0.6) * 0.18,  
                    obj.Offset.Y  
                )  
        else  
            table.remove(_gradients, i)  
        end  
    end  

    if glowAccumulator >= 1 / 30 then  
        glowAccumulator =  
            glowAccumulator  
            - 1 / 30  

                    local firstPulse =  
            (  
                math.noise(  
                    glowTime * 0.72,  
                    glowSeedFirst  
                )  
                + 1  
            ) * 0.5  

        local secondPulse =  
            (  
                math.noise(  
                    glowTime * 0.91,  
                    glowSeedSecond  
                )  
                + 1  
            ) * 0.5  

        firstPulse =  
            firstPulse  
            * firstPulse  
            * (3 - 2 * firstPulse)  

        secondPulse =  
            secondPulse  
            * secondPulse  
            * (3 - 2 * secondPulse)  

        if firstGlowSequences  
            and _gradients[1] then  

            local firstIndex =  
                math.clamp(  
                    math.floor(  
                        firstPulse  
                        * (  
                            #firstGlowSequences  
                            - 1  
                        )  
                        + 0.5  
                    ) + 1,  
                    1,  
                    #firstGlowSequences  
                )  

            _gradients[1].Color =  
                firstGlowSequences[  
                    firstIndex  
                ]  
        end  

        if secondGlowSequences  
            and st.secondGradient  
            and st.secondGradient.Parent then  

            local secondIndex =  
                math.clamp(  
                    math.floor(  
                        secondPulse  
                        * (  
                            #secondGlowSequences  
                            - 1  
                        )  
                        + 0.5  
                    ) + 1,  
                    1,  
                    #secondGlowSequences  
                )  

            st.secondGradient.Color =  
                secondGlowSequences[  
                    secondIndex  
                ]  
        end  
    end  

    if st.secondGradient  
        and st.secondGradient.Parent then  

        st.secondT =  
            st.secondT  
            + dt * secondSpeed  

        local secondT =  
            st.secondT  

        local secondSize =  
            secondLayer.AbsoluteSize  

        if secondSize.X > 0  
            and secondSize.Y > 0 then  

            local secondBaseRotation =  
                90  
                + math.deg(  
                    math.atan2(  
                        secondSize.Y,  
                        secondSize.X  
                    )  
                )  

            st.secondRotation =  
                st.secondRotation  
                + dt * secondRotationSpeed  

            st.secondGradient.Rotation =  
                (  
                    secondBaseRotation  
                    + st.secondRotation  
                ) % 360  
        end  

        st.secondGradient.Offset =  
            Vector2.new(  
                math.sin(  
                    secondT * 0.6  
                ) * 0.18,  
                math.sin(  
                    secondT * 0.32  
                ) * 0.035  
            )  
    end  

    if StrokeFrom and StrokeTo then  
        for i = #_strokes, 1, -1 do  
            local obj = _strokes[i]  

            if obj.Parent then  
                local t =  
                    (obj:GetAttribute("_t") or 0)  
                    + dt * Speed  

                obj:SetAttribute("_t", t)  

                local pulse =  
                    (math.sin(t) + 1) / 2  

                obj.Thickness =  
                    1.25  
                    + pulse * 1.25  

                obj.Color =  
                    StrokeFrom:Lerp(  
                        StrokeTo,  
                        pulse  
                    )  
            else  
                table.remove(_strokes, i)  
            end  
        end  
    end  
end)

end
]]

source =
source:sub(1, animationStart - 1)
.. customAnimation
.. source:sub(animationEnd + 1)

local function replaceSourceExact(
oldText,
newText,
label
)
local startPos, endPos =
source:find(
oldText,
1,
true
)

assert(  
	startPos,  
	"Nyvex Hub: não foi possível corrigir "  
	.. tostring(label)  
)  

source =  
	source:sub(  
		1,  
		startPos - 1  
	)  
	.. newText  
	.. source:sub(  
		endPos + 1  
	)

end

replaceSourceExact(
"Position = UDim2.fromOffset(t.TabWidth + 26, 60),",
"Position = UDim2.fromOffset(28, 60),",
"posição do ícone da aba"
)

replaceSourceExact(
"Position = UDim2.fromOffset(t.TabWidth + 26, 56),",
"Position = UDim2.fromOffset(60, 56),",
"posição do título da aba"
)

replaceSourceExact(
"Size = UDim2.new(1, -t.TabWidth - 32, 1, -102),\n"
.. "                    Position = UDim2.fromOffset(t.TabWidth + 26, 90),",
"Size = UDim2.new(1, -54, 1, -102),\n"
.. "                    Position = UDim2.fromOffset(28, 90),",
"geometria do conteúdo"
)

replaceSourceExact(
"v.ContainerHolder.Position = UDim2.fromOffset(t.TabWidth + 26, 90)\n"
.. "                v.ContainerHolder.Size     = UDim2.new(1, -t.TabWidth - 32, 1, -102)",
"v.ContainerHolder.Position = UDim2.fromOffset(28, 90)\n"
.. "                v.ContainerHolder.Size     = UDim2.new(1, -54, 1, -102)",
"geometria do conteúdo após busca"
)

replaceSourceExact(
"v.ContainerHolder.Position = UDim2.fromOffset(t.TabWidth + 26, K)",
"v.ContainerHolder.Position = UDim2.fromOffset(28, K)",
"posição do conteúdo durante a animação"
)

-- ============================================================
-- ===== NATIVE GROUPMOTOR RESIZE BRIDGE ========================
-- ============================================================
-- Fluent already owns Root.Size through this GroupMotor. During our external
-- gesture we do not write Root.Size from a second system; the motor callback
-- consumes the latest external logical value instead. When the gesture ends,
-- normal Fluent motor behavior resumes unchanged.
replaceSourceExact(
"G:onStep(\n                function(I)\n                    v.Root.Size = UDim2.new(0, math.round(I.X), 0, math.round(I.Y))\n                end\n            )",
[=[local _NyvexExternalResizeLocked = false
local _NyvexExternalResizeValue =
    Vector2.new(
        math.round(v.Size.X.Offset),
        math.round(v.Size.Y.Offset)
    )

local function _NyvexCommitExternalSize(width, height)
    local logicalWidth =
        math.max(1, math.round(width))
    local logicalHeight =
        math.max(1, math.round(height))

    _NyvexExternalResizeValue =
        Vector2.new(
            logicalWidth,
            logicalHeight
        )

    v.Size =
        UDim2.fromOffset(
            logicalWidth,
            logicalHeight
        )

    v.Root.Size =
        UDim2.fromOffset(
            logicalWidth,
            logicalHeight
        )
end

G:onStep(
    function(I)
        if _NyvexExternalResizeLocked then
            v.Root.Size =
                UDim2.fromOffset(
                    _NyvexExternalResizeValue.X,
                    _NyvexExternalResizeValue.Y
                )
            return
        end

        v.Root.Size =
            UDim2.fromOffset(
                math.round(I.X),
                math.round(I.Y)
            )
    end
)

v._NyvexMotorBeginExternalResize = function(width, height)
    _NyvexExternalResizeLocked = true
    _NyvexCommitExternalSize(width, height)

    G:setGoal {
        X = l.Instant.new(_NyvexExternalResizeValue.X),
        Y = l.Instant.new(_NyvexExternalResizeValue.Y),
    }
end

v._NyvexMotorUpdateExternalResize = function(width, height)
    if not _NyvexExternalResizeLocked then
        return
    end

    _NyvexCommitExternalSize(width, height)
end

v._NyvexMotorEndExternalResize = function(width, height)
    _NyvexCommitExternalSize(width, height)

    G:setGoal {
        X = l.Instant.new(_NyvexExternalResizeValue.X),
        Y = l.Instant.new(_NyvexExternalResizeValue.Y),
    }

    _NyvexExternalResizeLocked = false
end]=],
"motor de resize externo sincronizado no próprio GroupMotor"
)

local uiChunk, compileError = loadstring(
source,
"@NyvexUI"
)

assert(
uiChunk,
"Nyvex Hub: falha ao compilar a UI: " .. tostring(compileError)
)

local Fluent = uiChunk()

assert(
Fluent,
"Nyvex Hub: o main-fix.lua não retornou a biblioteca da UI."
)

Fluent:AddTheme({
Name = "Nyvex Nocturne",

Accent = Color3.fromRGB(178, 42, 76),  

							AcrylicMain = Color3.fromRGB(23, 9, 17),  
AcrylicBorder = Color3.fromRGB(78, 25, 43),  

AcrylicGradient = ColorSequence.new({  
	ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 12, 30)),  
	ColorSequenceKeypoint.new(0.14, Color3.fromRGB(78, 18, 44)),  
	ColorSequenceKeypoint.new(0.28, Color3.fromRGB(61, 14, 36)),  
	ColorSequenceKeypoint.new(0.43, Color3.fromRGB(86, 20, 51)),  
	ColorSequenceKeypoint.new(0.58, Color3.fromRGB(71, 15, 44)),  
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(81, 19, 53)),  
	ColorSequenceKeypoint.new(0.86, Color3.fromRGB(53, 12, 36)),  
	ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 7, 19)),  
}),  

AcrylicNoise = 0.95,  

TitleBarLine = Color3.fromRGB(78, 27, 46),  

Tab = Color3.fromRGB(25, 13, 21),  
Element = Color3.fromRGB(20, 12, 19),  

ElementBorder = Color3.fromRGB(44, 25, 36),  
InElementBorder = Color3.fromRGB(78, 35, 52),  

ElementTransparency = 0.86,  

ToggleSlider = Color3.fromRGB(178, 42, 76),  
ToggleToggled = Color3.fromRGB(238, 203, 214),  

SliderRail = Color3.fromRGB(58, 31, 42),  

CheckboxUnchecked = Color3.fromRGB(58, 31, 42),  
CheckboxChecked = Color3.fromRGB(178, 42, 76),  
CheckboxCheck = Color3.fromRGB(13, 7, 11),  

ProgressBarRail = Color3.fromRGB(42, 24, 34),  
ProgressBarFill = Color3.fromRGB(178, 42, 76),  

DropdownFrame = Color3.fromRGB(28, 15, 24),  
DropdownHolder = Color3.fromRGB(13, 7, 13),  
DropdownBorder = Color3.fromRGB(62, 30, 45),  
DropdownOption = Color3.fromRGB(178, 42, 76),  

Keybind = Color3.fromRGB(25, 13, 21),  

Input = Color3.fromRGB(19, 11, 18),  
InputFocused = Color3.fromRGB(12, 7, 13),  
InputIndicator = Color3.fromRGB(178, 42, 76),  

Dialog = Color3.fromRGB(20, 11, 20),  
DialogHolder = Color3.fromRGB(12, 7, 13),  
DialogHolderLine = Color3.fromRGB(34, 18, 29),  

DialogButton = Color3.fromRGB(22, 12, 21),  
DialogButtonBorder = Color3.fromRGB(62, 30, 45),  
DialogBorder = Color3.fromRGB(67, 32, 48),  

DialogInput = Color3.fromRGB(18, 10, 18),  
DialogInputLine = Color3.fromRGB(178, 42, 76),  

Text = Color3.fromRGB(240, 235, 240),  
SubText = Color3.fromRGB(157, 143, 153),  
IconColor = Color3.fromRGB(192, 169, 180),  

Hover = Color3.fromRGB(50, 25, 37),  
HoverChange = 0.04,  

ShineEnabled = true,  

Shine = {  
	Speed = 0.42,  
	RotationSpeed = 5.5,  

	MaxGradients = 2,  
	PhaseSpacing = 0.5,  
	AlternateDirection = true,  

			ColorSequence = ColorSequence.new({  
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 12, 24)),  
		ColorSequenceKeypoint.new(0.40, Color3.fromRGB(45, 12, 24)),  
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(132, 32, 62)),  
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(45, 12, 24)),  
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 12, 24)),  
	}),  
},  

StrokeShine = true,  
StrokeDark = Color3.fromRGB(61, 23, 38),  

ButtonGradient = {  
	Background = ColorSequence.new({  
		ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 17, 32)),  
		ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 10, 24)),  
	}),  

	Stroke = ColorSequence.new({  
		ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 28, 52)),  
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(178, 42, 76)),  
		ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 22, 42)),  
	}),  
},  

ThemeAccentColors = {  
	Color3.fromRGB(178, 42, 76),  
	Color3.fromRGB(124, 39, 104),  
	Color3.fromRGB(94, 34, 111),  
	Color3.fromRGB(178, 42, 76),  
},

})

local GuiService = game:GetService("GuiService")

GuiService:SendNotification({
Title = "Nyvex Hub",
Text = "UI carregada com sucesso.",
Icon = "rbxassetid://6031094678",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character
local humanoid
local hrp

local function setupCharacter(newCharacter)
character = newCharacter
humanoid = character:WaitForChild("Humanoid")
hrp = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
setupCharacter(player.Character)
end

local SPEED_GLITCH_SPEED = 25

local MOVE_THRESHOLD = 0.1
local ANGLE_MIN = 20
local ANGLE_MAX = 160

local speedGlitchConnection = nil
local speedGlitchEnabled = false
local speedGlitchActive = false
local normalWalkSpeed = 16

local function getSpeedGlitchAngle(lookVector, moveVector)
local look = Vector3.new(
lookVector.X,
0,
lookVector.Z
)

local move = Vector3.new(  
	moveVector.X,  
	0,  
	moveVector.Z  
)  

if look.Magnitude < 1e-4  
	or move.Magnitude < 1e-4 then  
	return nil  
end  

look = look.Unit  
move = move.Unit  

local dot = math.clamp(  
	look:Dot(move),  
	-1,  
	1  
)  

local cross = look:Cross(move)  

return math.deg(  
	math.atan2(  
		cross.Y,  
		dot  
	)  
)

end

local function setSpeedGlitch(state)
if not humanoid then
return
end

if state == speedGlitchActive then  
	return  
end  

speedGlitchActive = state  

if state then  
	normalWalkSpeed = humanoid.WalkSpeed  
	humanoid.WalkSpeed = SPEED_GLITCH_SPEED  
else  
	humanoid.WalkSpeed = normalWalkSpeed  
end

end

local function startSpeedGlitch()
if speedGlitchConnection then
return
end

speedGlitchEnabled = true  

if humanoid then  
	normalWalkSpeed = humanoid.WalkSpeed  
	speedGlitchActive = false  
end  

speedGlitchConnection = RunService.Heartbeat:Connect(function()  
	if not speedGlitchEnabled then  
		return  
	end  

	if not humanoid  
		or not hrp  
		or humanoid.Health <= 0 then  
		return  
	end  

	local state = humanoid:GetState()  

	local isAirborne =  
		state == Enum.HumanoidStateType.Jumping  
		or state == Enum.HumanoidStateType.Freefall  

	if not isAirborne then  
		if speedGlitchActive then  
			setSpeedGlitch(false)  
		end  

		normalWalkSpeed = humanoid.WalkSpeed  
		return  
	end  

	if not speedGlitchActive then  
		normalWalkSpeed = humanoid.WalkSpeed  
	end  

	local moveDir = humanoid.MoveDirection  

	local movementValid =  
		moveDir.Magnitude > MOVE_THRESHOLD  

	local angleValid = false  

	if movementValid then  
		local angle =  
			getSpeedGlitchAngle(  
				hrp.CFrame.LookVector,  
				moveDir  
			)  

		if angle then  
			local absoluteAngle = math.abs(angle)  

			angleValid =  
				absoluteAngle >= ANGLE_MIN  
				and absoluteAngle <= ANGLE_MAX  
		end  
	end  

	setSpeedGlitch(  
		movementValid  
		and angleValid  
	)  
end)

end

local function stopSpeedGlitch()
speedGlitchEnabled = false

if speedGlitchConnection then  
	speedGlitchConnection:Disconnect()  
	speedGlitchConnection = nil  
end  

if humanoid and humanoid.Health > 0 then  
	if speedGlitchActive then  
		humanoid.WalkSpeed = normalWalkSpeed  
	end  
end  

speedGlitchActive = false

end

player.CharacterAdded:Connect(function()
speedGlitchActive = false

if humanoid then  
	normalWalkSpeed = humanoid.WalkSpeed  
end

end)

local WALL_DISTANCE = 1.75
local WALL_SPHERE_RADIUS = 0.20
local WALL_ALIGNMENT_MIN = 0.35

local WALLJUMP_GUARD_DISTANCE = 2.25

local MIN_TURN_DEGREES = 120
local MIN_TURN_DOT = math.cos(math.rad(MIN_TURN_DEGREES))

local EXIT_CLEARANCE = 0.03
local EXIT_RAY_MARGIN = 0.25

local SUCCESS_COOLDOWN = 0.12

local wallClipConnection = nil
local previousState = nil

local lastSuccessTime = -math.huge

local function createExcludeParams()
local params = RaycastParams.new()

params.FilterType = Enum.RaycastFilterType.Exclude  
params.FilterDescendantsInstances = {character}  
params.IgnoreWater = true  
params.RespectCanCollide = true  

return params

end

local function createIncludeParams(instance)
local params = RaycastParams.new()

params.FilterType = Enum.RaycastFilterType.Include  
params.FilterDescendantsInstances = {instance}  
params.IgnoreWater = true  
params.RespectCanCollide = true  

return params

end

local function isWallJumpPart(part)
if not part or not part:IsA("BasePart") then
return false
end

local marker = part:FindFirstChild("_Wall")  

return marker ~= nil  
	and marker:IsA("ObjectValue")

end

local function getWallInDirection(direction)
if not hrp then
return nil, false
end

local params = createExcludeParams()  
local unitDirection = direction.Unit  

local result =  
	Workspace:Raycast(  
		hrp.Position,  
		unitDirection * WALL_DISTANCE,  
		params  
	)  

if not result then  
	result =  
		Workspace:Spherecast(  
			hrp.Position,  
			WALL_SPHERE_RADIUS,  
			unitDirection * WALL_DISTANCE,  
			params  
		)  
end  

if not result then  
	return nil, false  
end  

local part = result.Instance  

if not part  
	or not part:IsA("BasePart")  
	or not part.CanCollide then  
	return nil, false  
end  

if isWallJumpPart(part) then  
	return nil, true  
end  

if result.Normal:Dot(unitDirection)  
	> -WALL_ALIGNMENT_MIN then  
	return nil, false  
end  

return {  
	instance = part,  
	position = result.Position,  
	normal = result.Normal,  
	distance = result.Distance,  
}, false

end

local function hasWallJumpNearby()
if not hrp then
return false
end

local params = OverlapParams.new()  

params.FilterType = Enum.RaycastFilterType.Exclude  
params.FilterDescendantsInstances = {character}  
params.MaxParts = 64  
params.RespectCanCollide = true  

local look = hrp.CFrame.LookVector  

local boxCFrame =  
	CFrame.lookAt(  
		hrp.Position,  
		hrp.Position + look  
	)  

local parts =  
	Workspace:GetPartBoundsInBox(  
		boxCFrame,  
		Vector3.new(  
			1.5,  
			6,  
			WALLJUMP_GUARD_DISTANCE * 2  
		),  
		params  
	)  

for _, part in ipairs(parts) do  
	if isWallJumpPart(part) then  
		return true  
	end  
end  

return false

end

local function sampleWallClipFrame()
local look = hrp.CFrame.LookVector

local frontWall, frontWallJump =  
	getWallInDirection(look)  

local backWall, backWallJump =  
	getWallInDirection(-look)  

return {  
	look = look,  

	frontWall =  
		frontWall  
		and frontWall.instance  
		or nil,  

	frontPosition =  
		frontWall  
		and frontWall.position  
		or nil,  

	frontNormal =  
		frontWall  
		and frontWall.normal  
		or nil,  

	frontDistance =  
		frontWall  
		and frontWall.distance  
		or nil,  

	backWall =  
		backWall  
		and backWall.instance  
		or nil,  

	backPosition =  
		backWall  
		and backWall.position  
		or nil,  

	backNormal =  
		backWall  
		and backWall.normal  
		or nil,  

	backDistance =  
		backWall  
		and backWall.distance  
		or nil,  

	frontWallJump = frontWallJump,  
	backWallJump = backWallJump,  
	wallJumpNearby = hasWallJumpNearby(),  
}

end

local function wallsMatch(previous, current)
if not previous.frontWall
or not current.backWall
or not previous.frontNormal
or not previous.frontPosition
or not current.backPosition then
return false
end

if previous.frontWall == current.backWall then  
	return true  
end  

if not current.backNormal then  
	return false  
end  

local normalSimilarity =  
	previous.frontNormal.Unit:Dot(  
		current.backNormal.Unit  
	)  

if normalSimilarity < 0.80 then  
	return false  
end  

local previousPlane =  
	previous.frontNormal.Unit:Dot(  
		previous.frontPosition  
	)  

local currentPlane =  
	previous.frontNormal.Unit:Dot(  
		current.backPosition  
	)  

return math.abs(  
	previousPlane - currentPlane  
) <= 0.75

end

local function getProjectedHalfExtent(
boxCFrame,
boxSize,
direction
)
local right = boxCFrame.RightVector
local up = boxCFrame.UpVector
local look = boxCFrame.LookVector

return  
	math.abs(  
		direction:Dot(right)  
	) * boxSize.X * 0.5  
	+  
	math.abs(  
		direction:Dot(up)  
	) * boxSize.Y * 0.5  
	+  
	math.abs(  
		direction:Dot(look)  
	) * boxSize.Z * 0.5

end

local function findExitSurface(previous)
if not previous
or not previous.frontWall
or not previous.frontNormal then
return nil, nil
end

local wallPart = previous.frontWall  

if isWallJumpPart(wallPart) then  
	return nil, nil  
end  

local traverseDirection =  
	-previous.frontNormal.Unit  

local halfExtent =  
	math.abs(  
		traverseDirection:Dot(  
			wallPart.CFrame.RightVector  
		)  
	) * wallPart.Size.X * 0.5  
	+  
	math.abs(  
		traverseDirection:Dot(  
			wallPart.CFrame.UpVector  
		)  
	) * wallPart.Size.Y * 0.5  
	+  
	math.abs(  
		traverseDirection:Dot(  
			wallPart.CFrame.LookVector  
		)  
	) * wallPart.Size.Z * 0.5  

local farDistance =  
	halfExtent + EXIT_RAY_MARGIN  

local farOrigin =  
	wallPart.Position  
	+  
	traverseDirection * farDistance  

local params =  
	createIncludeParams(wallPart)  

local result =  
	Workspace:Raycast(  
		farOrigin,  
		-traverseDirection  
			* (  
				farDistance * 2  
				+ EXIT_RAY_MARGIN  
			),  
		params  
	)  

if not result  
	or result.Instance ~= wallPart  
	or isWallJumpPart(result.Instance) then  
	return nil, nil  
end  

if result.Normal:Dot(  
	traverseDirection  
) < WALL_ALIGNMENT_MIN then  
	return nil, nil  
end  

return result, traverseDirection

end

local function calculateEscapeDistance(
traverseDirection,
exitSurface
)
if not character
or not exitSurface then
return nil
end

local boxCFrame, boxSize =  
	character:GetBoundingBox()  

local centerProjection =  
	boxCFrame.Position:Dot(  
		traverseDirection  
	)  

local characterHalfExtent =  
	getProjectedHalfExtent(  
		boxCFrame,  
		boxSize,  
		traverseDirection  
	)  

local exitProjection =  
	exitSurface.Position:Dot(  
		traverseDirection  
	)  

local requiredDistance =  
	exitProjection  
	+ characterHalfExtent  
	+ EXIT_CLEARANCE  
	- centerProjection  

return math.max(  
	requiredDistance,  
	0  
)

end

local function executeWallClip(previous)
if os.clock() - lastSuccessTime
< SUCCESS_COOLDOWN then
return
end

if previous.frontWallJump  
	or previous.backWallJump  
	or previous.wallJumpNearby then  
	return  
end  

if isWallJumpPart(previous.frontWall) then  
	return  
end  

local exitSurface,  
	traverseDirection =  
	findExitSurface(previous)  

if not exitSurface  
	or not traverseDirection then  
	return  
end  

local escapeDistance =  
	calculateEscapeDistance(  
		traverseDirection,  
		exitSurface  
	)  

if not escapeDistance then  
	return  
end  

character:PivotTo(  
	character:GetPivot()  
	+  
	traverseDirection  
	* escapeDistance  
)  

lastSuccessTime = os.clock()

end

local function processWallClipFrame()
if not character
or not humanoid
or not hrp
or humanoid.Health <= 0 then
previousState = nil
return
end

local currentState =  
	sampleWallClipFrame()  

if previousState then  
	local turnDot =  
		math.clamp(  
			previousState.look:Dot(  
				currentState.look  
			),  
			-1,  
			1  
		)  

	local wallJumpBlocked =  
		previousState.frontWallJump  
		or previousState.backWallJump  
		or previousState.wallJumpNearby  
		or currentState.frontWallJump  
		or currentState.backWallJump  
		or currentState.wallJumpNearby  

	local turnValid =  
		turnDot <= MIN_TURN_DOT  

	if  
		not wallJumpBlocked  
		and turnValid  
		and wallsMatch(  
			previousState,  
			currentState  
		)  
		and currentState.backWall ~= nil  
		and not isWallJumpPart(  
			currentState.backWall  
		)  
	then  
		executeWallClip(  
			previousState  
		)  
	end  
end  

previousState =  
	currentState

end

local function startWallClip()
if wallClipConnection then
return
end

previousState = nil  
lastSuccessTime = -math.huge  

wallClipConnection =  
	RunService.Heartbeat:Connect(  
		processWallClipFrame  
	)

end

local function stopWallClip()
if wallClipConnection then
wallClipConnection:Disconnect()
wallClipConnection = nil
end

previousState = nil

end

player.CharacterAdded:Connect(function()
previousState = nil
lastSuccessTime = -math.huge
end)

local Window = Fluent:CreateWindow({
Title = "Nyvex Hub",
SubTitle = "Functions",
TabWidth = 170,
Size = UDim2.fromOffset(540, 400),
Acrylic = true,
Theme = "Nyvex Nocturne",

Search = {  
	Search = true,  
	Highlight = true,  
	HighlightColor = Color3.fromRGB(180, 150, 255),  
},  

UserInfo = {  
	UserInfoTop = true,  
	UserInfoTitle = player.DisplayName,  
	UserInfoSubtitle = "@" .. player.Name,  
	UserInfoColor = Color3.fromRGB(210, 200, 240),  
},  

TitleIcon = "lucide/sparkles",

})

local windowRoot =
Window.Root

-- Disable only the native Fluent resize grip.
-- The instance stays inside the library tree so the Window structure remains intact.
-- We hide the exact grip by its unique resize icon instead of destroying its parent.
local function disableLibraryResizeGrip(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("Frame") then
			for _, child in ipairs(descendant:GetChildren()) do
				if child:IsA("ImageLabel")
					and child.Image == "rbxassetid://10709767750" then
					descendant.Visible = false
					descendant.Active = false
					child.Visible = false
					child.Active = false
				end
			end
		end
	end
end

disableLibraryResizeGrip(windowRoot)

for _, child in ipairs(
windowRoot:GetDescendants()
) do
if child:IsA("ImageLabel")
and child.Image ==
"rbxassetid://8992230677" then

child:Destroy()  
end

end

local windowShadow =
Instance.new("UIShadow")

windowShadow.Name =
"__NyvexWindowShadow"

windowShadow.Color =
Color3.fromRGB(21, 4, 13)

windowShadow.Transparency =
0.20

windowShadow.BlurRadius =
UDim.new(0, 34)

windowShadow.Offset =
UDim2.fromOffset(0, 0)

windowShadow.Spread =
UDim2.fromOffset(10, 10)

windowShadow.ZIndex =
-1

windowShadow.Enabled =
true

windowShadow.Parent =
windowRoot

local titleBarFrame = Window.TitleBar and Window.TitleBar.Frame

if titleBarFrame then
titleBarFrame.BackgroundTransparency = 1
titleBarFrame.BorderSizePixel = 0
titleBarFrame.ZIndex = 5

for _, child in ipairs(titleBarFrame:GetChildren()) do  
	if child:IsA("Frame")  
		and child.Size.X.Scale == 1  
		and child.Size.X.Offset == 0  
		and child.Size.Y.Scale == 0  
		and child.Size.Y.Offset == 1  
		and child.Position.X.Scale == 0  
		and child.Position.X.Offset == 0  
		and child.Position.Y.Scale == 1  
		and child.Position.Y.Offset == 0 then  

		child.BackgroundTransparency = 1  
	end  
end  

local oldHeaderSurface =  
	windowRoot:FindFirstChild(  
		"__NyvexHeaderSurface"  
	)  

if oldHeaderSurface then  
	oldHeaderSurface:Destroy()  
end  

local headerSurface =
	Instance.new("Frame")

headerSurface.Name =
	"__NyvexHeaderSurface"

headerSurface.Size =
	UDim2.new(1, 0, 0, 42)

headerSurface.Position =
	UDim2.fromOffset(0, 0)

headerSurface.BackgroundColor3 =
	Color3.fromRGB(60, 13, 34)

headerSurface.BackgroundTransparency =
	0.14

headerSurface.BorderSizePixel =
	0

headerSurface.ZIndex =
	4

headerSurface.Active =
	false

headerSurface.ClipsDescendants =
	true

headerSurface.Parent =
	windowRoot

local headerCorner =
	Instance.new("UICorner")

headerCorner.TopLeftRadius =
	UDim.new(0, 10)

headerCorner.TopRightRadius =
	UDim.new(0, 10)

headerCorner.BottomLeftRadius =
	UDim.new(0, 0)

headerCorner.BottomRightRadius =
	UDim.new(0, 0)

headerCorner.Parent =
	headerSurface

local headerGradient =
	Instance.new("UIGradient")

headerGradient.Name =
	"Gradient"

headerGradient.Rotation =
	112

headerGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(62, 13, 36)
		),
		ColorSequenceKeypoint.new(
			0.12,
			Color3.fromRGB(92, 20, 54)
		),
		ColorSequenceKeypoint.new(
			0.26,
			Color3.fromRGB(112, 28, 66)
		),
		ColorSequenceKeypoint.new(
			0.40,
			Color3.fromRGB(132, 35, 75)
		),
		ColorSequenceKeypoint.new(
			0.53,
			Color3.fromRGB(116, 27, 72)
		),
		ColorSequenceKeypoint.new(
			0.66,
			Color3.fromRGB(126, 34, 84)
		),
		ColorSequenceKeypoint.new(
			0.80,
			Color3.fromRGB(96, 22, 68)
		),
		ColorSequenceKeypoint.new(
			0.92,
			Color3.fromRGB(69, 16, 57)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(46, 10, 42)
		),
	})

headerGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.16),
		NumberSequenceKeypoint.new(0.14, 0.12),
		NumberSequenceKeypoint.new(0.30, 0.09),
		NumberSequenceKeypoint.new(0.46, 0.11),
		NumberSequenceKeypoint.new(0.62, 0.12),
		NumberSequenceKeypoint.new(0.78, 0.13),
		NumberSequenceKeypoint.new(0.92, 0.18),
		NumberSequenceKeypoint.new(1, 0.24),
	})

headerGradient.Parent =
	headerSurface

local headerColorWash =
	Instance.new("Frame")

headerColorWash.Name =
	"ColorWash"

headerColorWash.Size =
	UDim2.fromScale(1, 1)

headerColorWash.Position =
	UDim2.fromScale(0, 0)

headerColorWash.BackgroundColor3 =
	Color3.fromRGB(178, 42, 76)

headerColorWash.BackgroundTransparency =
	0.88

headerColorWash.BorderSizePixel =
	0

headerColorWash.ZIndex =
	1

headerColorWash.Active =
	false

headerColorWash.Parent =
	headerSurface

local headerColorWashGradient =
	Instance.new("UIGradient")

headerColorWashGradient.Name =
	"Gradient"

headerColorWashGradient.Rotation =
	18

headerColorWashGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(178, 42, 76)
		),
		ColorSequenceKeypoint.new(
			0.18,
			Color3.fromRGB(205, 65, 106)
		),
		ColorSequenceKeypoint.new(
			0.34,
			Color3.fromRGB(124, 39, 104)
		),
		ColorSequenceKeypoint.new(
			0.52,
			Color3.fromRGB(94, 34, 111)
		),
		ColorSequenceKeypoint.new(
			0.70,
			Color3.fromRGB(124, 39, 104)
		),
		ColorSequenceKeypoint.new(
			0.86,
			Color3.fromRGB(198, 49, 101)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(178, 42, 76)
		),
	})

headerColorWashGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.90),
		NumberSequenceKeypoint.new(0.18, 0.84),
		NumberSequenceKeypoint.new(0.36, 0.88),
		NumberSequenceKeypoint.new(0.52, 0.91),
		NumberSequenceKeypoint.new(0.68, 0.86),
		NumberSequenceKeypoint.new(0.84, 0.82),
		NumberSequenceKeypoint.new(1, 0.92),
	})

headerColorWashGradient.Parent =
	headerColorWash

local headerLeftBloom =
	Instance.new("Frame")

headerLeftBloom.Name =
	"LeftBloom"

headerLeftBloom.Size =
	UDim2.fromScale(1, 1)

headerLeftBloom.Position =
	UDim2.fromScale(0, 0)

headerLeftBloom.BackgroundColor3 =
	Color3.fromRGB(112, 24, 59)

headerLeftBloom.BackgroundTransparency =
	0.84

headerLeftBloom.BorderSizePixel =
	0

headerLeftBloom.ZIndex =
	1

headerLeftBloom.Active =
	false

headerLeftBloom.Parent =
	headerSurface

local headerLeftBloomGradient =
	Instance.new("UIGradient")

headerLeftBloomGradient.Name =
	"Gradient"

headerLeftBloomGradient.Type =
	Enum.GradientType.Radial

headerLeftBloomGradient.Offset =
	Vector2.new(-0.10, -0.20)

headerLeftBloomGradient.Scale =
	Vector2.new(1.55, 1.10)

headerLeftBloomGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(240, 93, 132)
		),
		ColorSequenceKeypoint.new(
			0.16,
			Color3.fromRGB(209, 57, 99)
		),
		ColorSequenceKeypoint.new(
			0.36,
			Color3.fromRGB(178, 42, 76)
		),
		ColorSequenceKeypoint.new(
			0.60,
			Color3.fromRGB(127, 28, 60)
		),
		ColorSequenceKeypoint.new(
			0.80,
			Color3.fromRGB(69, 13, 39)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(20, 4, 14)
		),
	})

headerLeftBloomGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.54),
		NumberSequenceKeypoint.new(0.16, 0.68),
		NumberSequenceKeypoint.new(0.34, 0.82),
		NumberSequenceKeypoint.new(0.58, 0.93),
		NumberSequenceKeypoint.new(0.78, 0.985),
		NumberSequenceKeypoint.new(1, 1),
	})

headerLeftBloomGradient.Parent =
	headerLeftBloom

local headerRightBloom =
	Instance.new("Frame")

headerRightBloom.Name =
	"RightBloom"

headerRightBloom.Size =
	UDim2.fromScale(1, 1)

headerRightBloom.Position =
	UDim2.fromScale(0, 0)

headerRightBloom.BackgroundColor3 =
	Color3.fromRGB(94, 34, 111)

headerRightBloom.BackgroundTransparency =
	0.86

headerRightBloom.BorderSizePixel =
	0

headerRightBloom.ZIndex =
	1

headerRightBloom.Active =
	false

headerRightBloom.Parent =
	headerSurface

local headerRightBloomGradient =
	Instance.new("UIGradient")

headerRightBloomGradient.Name =
	"Gradient"

headerRightBloomGradient.Type =
	Enum.GradientType.Radial

headerRightBloomGradient.Offset =
	Vector2.new(0.86, -0.10)

headerRightBloomGradient.Scale =
	Vector2.new(1.18, 0.92)

headerRightBloomGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(164, 70, 181)
		),
		ColorSequenceKeypoint.new(
			0.18,
			Color3.fromRGB(126, 51, 146)
		),
		ColorSequenceKeypoint.new(
			0.40,
			Color3.fromRGB(94, 34, 111)
		),
		ColorSequenceKeypoint.new(
			0.62,
			Color3.fromRGB(60, 21, 74)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(29, 8, 36)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(12, 3, 12)
		),
	})

headerRightBloomGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.62),
		NumberSequenceKeypoint.new(0.18, 0.76),
		NumberSequenceKeypoint.new(0.38, 0.87),
		NumberSequenceKeypoint.new(0.60, 0.94),
		NumberSequenceKeypoint.new(0.82, 0.988),
		NumberSequenceKeypoint.new(1, 1),
	})

headerRightBloomGradient.Parent =
	headerRightBloom

local headerCenterBloom =
	Instance.new("Frame")

headerCenterBloom.Name =
	"CenterBloom"

headerCenterBloom.Size =
	UDim2.fromScale(1, 1)

headerCenterBloom.Position =
	UDim2.fromScale(0, 0)

headerCenterBloom.BackgroundColor3 =
	Color3.fromRGB(122, 32, 78)

headerCenterBloom.BackgroundTransparency =
	0.90

headerCenterBloom.BorderSizePixel =
	0

headerCenterBloom.ZIndex =
	1

headerCenterBloom.Active =
	false

headerCenterBloom.Parent =
	headerSurface

local headerCenterBloomGradient =
	Instance.new("UIGradient")

headerCenterBloomGradient.Name =
	"Gradient"

headerCenterBloomGradient.Type =
	Enum.GradientType.Radial

headerCenterBloomGradient.Offset =
	Vector2.new(0, 0.20)

headerCenterBloomGradient.Scale =
	Vector2.new(1.22, 0.82)

headerCenterBloomGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(244, 136, 173)
		),
		ColorSequenceKeypoint.new(
			0.18,
			Color3.fromRGB(211, 67, 111)
		),
		ColorSequenceKeypoint.new(
			0.40,
			Color3.fromRGB(178, 42, 76)
		),
		ColorSequenceKeypoint.new(
			0.64,
			Color3.fromRGB(110, 28, 61)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(49, 11, 30)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(14, 3, 10)
		),
	})

headerCenterBloomGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.66),
		NumberSequenceKeypoint.new(0.18, 0.78),
		NumberSequenceKeypoint.new(0.38, 0.88),
		NumberSequenceKeypoint.new(0.64, 0.95),
		NumberSequenceKeypoint.new(0.82, 0.988),
		NumberSequenceKeypoint.new(1, 1),
	})

headerCenterBloomGradient.Parent =
	headerCenterBloom

local headerAurora =
	Instance.new("Frame")

headerAurora.Name =
	"Aurora"

headerAurora.Size =
	UDim2.fromScale(1, 1)

headerAurora.Position =
	UDim2.fromScale(0, 0)

headerAurora.BackgroundColor3 =
	Color3.fromRGB(212, 79, 131)

headerAurora.BackgroundTransparency =
	0.90

headerAurora.BorderSizePixel =
	0

headerAurora.ZIndex =
	2

headerAurora.Active =
	false

headerAurora.Parent =
	headerSurface

local headerAuroraGradient =
	Instance.new("UIGradient")

headerAuroraGradient.Name =
	"Gradient"

headerAuroraGradient.Rotation =
	132

headerAuroraGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(120, 35, 82)
		),
		ColorSequenceKeypoint.new(
			0.18,
			Color3.fromRGB(208, 65, 115)
		),
		ColorSequenceKeypoint.new(
			0.34,
			Color3.fromRGB(245, 133, 170)
		),
		ColorSequenceKeypoint.new(
			0.47,
			Color3.fromRGB(177, 77, 154)
		),
		ColorSequenceKeypoint.new(
			0.60,
			Color3.fromRGB(103, 54, 132)
		),
		ColorSequenceKeypoint.new(
			0.78,
			Color3.fromRGB(70, 25, 84)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(39, 10, 35)
		),
	})

headerAuroraGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.96),
		NumberSequenceKeypoint.new(0.18, 0.90),
		NumberSequenceKeypoint.new(0.32, 0.82),
		NumberSequenceKeypoint.new(0.46, 0.87),
		NumberSequenceKeypoint.new(0.60, 0.91),
		NumberSequenceKeypoint.new(0.76, 0.94),
		NumberSequenceKeypoint.new(1, 0.98),
	})

headerAuroraGradient.Offset =
	Vector2.new(0, 0)

headerAuroraGradient.Parent =
	headerAurora

local headerGlassBand =
	Instance.new("Frame")

headerGlassBand.Name =
	"GlassBand"

headerGlassBand.Size =
	UDim2.fromScale(1, 1)

headerGlassBand.Position =
	UDim2.fromScale(0, 0)

headerGlassBand.BackgroundColor3 =
	Color3.fromRGB(255, 226, 241)

headerGlassBand.BackgroundTransparency =
	0.985

headerGlassBand.BorderSizePixel =
	0

headerGlassBand.ZIndex =
	2

headerGlassBand.Active =
	false

headerGlassBand.Parent =
	headerSurface

local headerGlassBandGradient =
	Instance.new("UIGradient")

headerGlassBandGradient.Name =
	"Gradient"

headerGlassBandGradient.Rotation =
	116

headerGlassBandGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(173, 66, 105)
		),
		ColorSequenceKeypoint.new(
			0.30,
			Color3.fromRGB(236, 151, 190)
		),
		ColorSequenceKeypoint.new(
			0.48,
			Color3.fromRGB(255, 232, 244)
		),
		ColorSequenceKeypoint.new(
			0.56,
			Color3.fromRGB(188, 93, 153)
		),
		ColorSequenceKeypoint.new(
			0.76,
			Color3.fromRGB(103, 48, 126)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(56, 17, 48)
		),
	})

headerGlassBandGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.28, 0.998),
		NumberSequenceKeypoint.new(0.42, 0.985),
		NumberSequenceKeypoint.new(0.49, 0.944),
		NumberSequenceKeypoint.new(0.54, 0.970),
		NumberSequenceKeypoint.new(0.62, 0.992),
		NumberSequenceKeypoint.new(0.72, 0.998),
		NumberSequenceKeypoint.new(1, 1),
	})

headerGlassBandGradient.Offset =
	Vector2.new(0, 0)

headerGlassBandGradient.Parent =
	headerGlassBand

local headerAmbientDepth =
	Instance.new("Frame")

headerAmbientDepth.Name =
	"AmbientDepth"

headerAmbientDepth.Size =
	UDim2.fromScale(1, 1)

headerAmbientDepth.Position =
	UDim2.fromScale(0, 0)

headerAmbientDepth.BackgroundColor3 =
	Color3.fromRGB(40, 12, 32)

headerAmbientDepth.BackgroundTransparency =
	0.72

headerAmbientDepth.BorderSizePixel =
	0

headerAmbientDepth.ZIndex =
	2

headerAmbientDepth.Active =
	false

headerAmbientDepth.Parent =
	headerSurface

local headerAmbientDepthGradient =
	Instance.new("UIGradient")

headerAmbientDepthGradient.Name =
	"Gradient"

headerAmbientDepthGradient.Rotation =
	90

headerAmbientDepthGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(172, 45, 92)
		),
		ColorSequenceKeypoint.new(
			0.22,
			Color3.fromRGB(96, 27, 63)
		),
		ColorSequenceKeypoint.new(
			0.58,
			Color3.fromRGB(66, 20, 51)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(35, 9, 30)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(12, 3, 11)
		),
	})

headerAmbientDepthGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.90),
		NumberSequenceKeypoint.new(0.18, 0.94),
		NumberSequenceKeypoint.new(0.46, 0.97),
		NumberSequenceKeypoint.new(0.72, 0.82),
		NumberSequenceKeypoint.new(1, 0.36),
	})

headerAmbientDepthGradient.Parent =
	headerAmbientDepth


local headerFlowLayers = {}

local headerFlowRandom =
	Random.new(
		20260925
	)

local headerFlowConfigs = {
	{
		name = "CrimsonSpiral",
		type = Enum.GradientType.Conical,
		zIndex = 2,
		rotation = 18,
		offset = Vector2.new(-0.08, -0.12),
		background = Color3.fromRGB(102, 20, 48),
		backgroundTransparency = 0.93,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(116, 16, 48)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(206, 35, 84)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 78, 125)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(156, 26, 86)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 10, 38)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.96),
			NumberSequenceKeypoint.new(0.26, 0.91),
			NumberSequenceKeypoint.new(0.50, 0.78),
			NumberSequenceKeypoint.new(0.74, 0.91),
			NumberSequenceKeypoint.new(1, 0.97),
		}),
		speed = 0.010,
		rotationSpeed = 0.55,
		rotationJitter = 7,
		ampX = 0.08,
		ampY = 0.06,
		phase = 0.00,
	},
	{
		name = "RoseSpiral",
		type = Enum.GradientType.Conical,
		zIndex = 2,
		rotation = 122,
		offset = Vector2.new(0.34, -0.10),
		background = Color3.fromRGB(132, 34, 82),
		backgroundTransparency = 0.95,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(89, 21, 60)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(182, 65, 122)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(245, 145, 191)),
			ColorSequenceKeypoint.new(0.72, Color3.fromRGB(141, 56, 124)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(49, 17, 49)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.98),
			NumberSequenceKeypoint.new(0.24, 0.93),
			NumberSequenceKeypoint.new(0.50, 0.83),
			NumberSequenceKeypoint.new(0.76, 0.94),
			NumberSequenceKeypoint.new(1, 0.99),
		}),
		speed = 0.008,
		rotationSpeed = -0.42,
		rotationJitter = 5,
		ampX = 0.07,
		ampY = 0.05,
		phase = 0.17,
	},
	{
		name = "VioletSpiral",
		type = Enum.GradientType.Conical,
		zIndex = 2,
		rotation = 208,
		offset = Vector2.new(0.70, 0.18),
		background = Color3.fromRGB(82, 31, 101),
		backgroundTransparency = 0.955,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 17, 71)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(112, 49, 143)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(176, 91, 189)),
			ColorSequenceKeypoint.new(0.74, Color3.fromRGB(104, 41, 135)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 10, 46)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.99),
			NumberSequenceKeypoint.new(0.24, 0.94),
			NumberSequenceKeypoint.new(0.50, 0.86),
			NumberSequenceKeypoint.new(0.76, 0.95),
			NumberSequenceKeypoint.new(1, 0.995),
		}),
		speed = 0.006,
		rotationSpeed = 0.34,
		rotationJitter = 6,
		ampX = 0.06,
		ampY = 0.08,
		phase = 0.32,
	},
	{
		name = "CrimsonDiagonal",
		type = Enum.GradientType.Linear,
		zIndex = 2,
		rotation = 22,
		offset = Vector2.new(-0.18, 0.04),
		background = Color3.fromRGB(130, 24, 54),
		backgroundTransparency = 0.955,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 11, 33)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(175, 32, 72)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(240, 72, 114)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(153, 32, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 12, 43)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.98),
			NumberSequenceKeypoint.new(0.24, 0.93),
			NumberSequenceKeypoint.new(0.50, 0.86),
			NumberSequenceKeypoint.new(0.76, 0.94),
			NumberSequenceKeypoint.new(1, 0.99),
		}),
		speed = 0.012,
		rotationSpeed = 0.12,
		rotationJitter = 3,
		ampX = 0.10,
		ampY = 0.035,
		phase = 0.08,
	},
	{
		name = "MagentaDiagonal",
		type = Enum.GradientType.Linear,
		zIndex = 2,
		rotation = 142,
		offset = Vector2.new(0.22, -0.06),
		background = Color3.fromRGB(126, 38, 95),
		backgroundTransparency = 0.96,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 13, 46)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(138, 41, 112)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(222, 88, 161)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(125, 42, 119)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 11, 43)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.99),
			NumberSequenceKeypoint.new(0.22, 0.95),
			NumberSequenceKeypoint.new(0.50, 0.88),
			NumberSequenceKeypoint.new(0.78, 0.96),
			NumberSequenceKeypoint.new(1, 0.995),
		}),
		speed = 0.009,
		rotationSpeed = -0.08,
		rotationJitter = 4,
		ampX = 0.08,
		ampY = 0.05,
		phase = 0.26,
	},
	{
		name = "PlumAtmosphere",
		type = Enum.GradientType.Radial,
		zIndex = 2,
		rotation = 0,
		offset = Vector2.new(0.84, 0.02),
		background = Color3.fromRGB(77, 25, 92),
		backgroundTransparency = 0.955,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(171, 64, 177)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(120, 43, 143)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(83, 28, 104)),
			ColorSequenceKeypoint.new(0.74, Color3.fromRGB(45, 14, 61)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 5, 25)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.90),
			NumberSequenceKeypoint.new(0.24, 0.94),
			NumberSequenceKeypoint.new(0.50, 0.97),
			NumberSequenceKeypoint.new(0.76, 0.985),
			NumberSequenceKeypoint.new(1, 0.997),
		}),
		speed = 0.006,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.08,
		ampY = 0.06,
		phase = 0.41,
	},
	{
		name = "RoseAtmosphere",
		type = Enum.GradientType.Radial,
		zIndex = 2,
		rotation = 0,
		offset = Vector2.new(0.18, -0.05),
		background = Color3.fromRGB(138, 31, 75),
		backgroundTransparency = 0.96,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(236, 101, 154)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(185, 58, 118)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(119, 34, 78)),
			ColorSequenceKeypoint.new(0.74, Color3.fromRGB(64, 16, 49)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 5, 18)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.91),
			NumberSequenceKeypoint.new(0.22, 0.94),
			NumberSequenceKeypoint.new(0.48, 0.97),
			NumberSequenceKeypoint.new(0.76, 0.99),
			NumberSequenceKeypoint.new(1, 0.998),
		}),
		speed = 0.007,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.10,
		ampY = 0.04,
		phase = 0.54,
	},
	{
		name = "DeepVioletFog",
		type = Enum.GradientType.Radial,
		zIndex = 2,
		rotation = 0,
		offset = Vector2.new(0.48, 1.06),
		background = Color3.fromRGB(69, 26, 88),
		backgroundTransparency = 0.965,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 59, 159)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(92, 43, 128)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(61, 25, 91)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(35, 12, 57)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 3, 23)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(0.24, 0.96),
			NumberSequenceKeypoint.new(0.50, 0.98),
			NumberSequenceKeypoint.new(0.76, 0.992),
			NumberSequenceKeypoint.new(1, 0.999),
		}),
		speed = 0.005,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.05,
		ampY = 0.09,
		phase = 0.67,
	},
	{
		name = "CrimsonHaze",
		type = Enum.GradientType.Linear,
		zIndex = 3,
		rotation = 84,
		offset = Vector2.new(0.00, -0.12),
		background = Color3.fromRGB(130, 22, 50),
		backgroundTransparency = 0.975,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(79, 13, 39)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(137, 27, 59)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(197, 49, 87)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(132, 30, 85)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 9, 37)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.992),
			NumberSequenceKeypoint.new(0.20, 0.97),
			NumberSequenceKeypoint.new(0.50, 0.90),
			NumberSequenceKeypoint.new(0.80, 0.975),
			NumberSequenceKeypoint.new(1, 0.995),
		}),
		speed = 0.011,
		rotationSpeed = 0.07,
		rotationJitter = 2,
		ampX = 0.04,
		ampY = 0.10,
		phase = 0.21,
	},
	{
		name = "OrchidFlow",
		type = Enum.GradientType.Linear,
		zIndex = 3,
		rotation = 154,
		offset = Vector2.new(-0.15, 0.10),
		background = Color3.fromRGB(92, 31, 101),
		backgroundTransparency = 0.978,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(53, 17, 66)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(103, 36, 116)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(155, 66, 164)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(100, 38, 126)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(36, 9, 43)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.994),
			NumberSequenceKeypoint.new(0.22, 0.978),
			NumberSequenceKeypoint.new(0.50, 0.92),
			NumberSequenceKeypoint.new(0.78, 0.98),
			NumberSequenceKeypoint.new(1, 0.997),
		}),
		speed = 0.007,
		rotationSpeed = -0.06,
		rotationJitter = 2,
		ampX = 0.07,
		ampY = 0.05,
		phase = 0.79,
	},
	{
		name = "HotRoseMist",
		type = Enum.GradientType.Radial,
		zIndex = 3,
		rotation = 0,
		offset = Vector2.new(0.54, 0.36),
		background = Color3.fromRGB(160, 49, 98),
		backgroundTransparency = 0.975,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 145, 192)),
			ColorSequenceKeypoint.new(0.20, Color3.fromRGB(223, 89, 147)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(166, 49, 111)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(83, 22, 67)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 5, 24)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.95),
			NumberSequenceKeypoint.new(0.22, 0.968),
			NumberSequenceKeypoint.new(0.50, 0.982),
			NumberSequenceKeypoint.new(0.78, 0.994),
			NumberSequenceKeypoint.new(1, 0.999),
		}),
		speed = 0.009,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.08,
		ampY = 0.05,
		phase = 0.88,
	},
	{
		name = "RubySheen",
		type = Enum.GradientType.Linear,
		zIndex = 3,
		rotation = 118,
		offset = Vector2.new(0.16, -0.06),
		background = Color3.fromRGB(136, 25, 62),
		backgroundTransparency = 0.982,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 13, 35)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(138, 25, 63)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(225, 63, 105)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(146, 30, 91)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 9, 37)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.997),
			NumberSequenceKeypoint.new(0.20, 0.985),
			NumberSequenceKeypoint.new(0.50, 0.93),
			NumberSequenceKeypoint.new(0.80, 0.986),
			NumberSequenceKeypoint.new(1, 0.999),
		}),
		speed = 0.013,
		rotationSpeed = 0.05,
		rotationJitter = 2,
		ampX = 0.09,
		ampY = 0.045,
		phase = 0.36,
	},
	{
		name = "PurpleDepth",
		type = Enum.GradientType.Conical,
		zIndex = 2,
		rotation = 284,
		offset = Vector2.new(0.44, 0.64),
		background = Color3.fromRGB(66, 25, 89),
		backgroundTransparency = 0.98,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(41, 11, 58)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(83, 28, 116)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(137, 66, 164)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(82, 31, 124)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 7, 38)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.997),
			NumberSequenceKeypoint.new(0.22, 0.987),
			NumberSequenceKeypoint.new(0.50, 0.946),
			NumberSequenceKeypoint.new(0.78, 0.988),
			NumberSequenceKeypoint.new(1, 0.999),
		}),
		speed = 0.005,
		rotationSpeed = 0.26,
		rotationJitter = 8,
		ampX = 0.06,
		ampY = 0.07,
		phase = 0.61,
	},
	{
		name = "CrimsonPulse",
		type = Enum.GradientType.Radial,
		zIndex = 3,
		rotation = 0,
		offset = Vector2.new(-0.05, 0.54),
		background = Color3.fromRGB(126, 24, 52),
		backgroundTransparency = 0.981,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(224, 66, 107)),
			ColorSequenceKeypoint.new(0.20, Color3.fromRGB(180, 36, 79)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(121, 27, 63)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(61, 13, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 4, 18)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.96),
			NumberSequenceKeypoint.new(0.22, 0.978),
			NumberSequenceKeypoint.new(0.50, 0.985),
			NumberSequenceKeypoint.new(0.78, 0.996),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.008,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.09,
		ampY = 0.07,
		phase = 0.47,
	},
	{
		name = "VioletMist",
		type = Enum.GradientType.Linear,
		zIndex = 3,
		rotation = 62,
		offset = Vector2.new(0.00, 0.12),
		background = Color3.fromRGB(86, 32, 108),
		backgroundTransparency = 0.982,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 13, 61)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(90, 38, 128)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(149, 73, 171)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(92, 35, 128)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 7, 39)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.998),
			NumberSequenceKeypoint.new(0.22, 0.988),
			NumberSequenceKeypoint.new(0.50, 0.94),
			NumberSequenceKeypoint.new(0.78, 0.989),
			NumberSequenceKeypoint.new(1, 0.999),
		}),
		speed = 0.006,
		rotationSpeed = -0.04,
		rotationJitter = 2.5,
		ampX = 0.05,
		ampY = 0.08,
		phase = 0.73,
	},
	{
		name = "MagentaVortex",
		type = Enum.GradientType.Conical,
		zIndex = 3,
		rotation = 342,
		offset = Vector2.new(0.94, 0.54),
		background = Color3.fromRGB(112, 31, 96),
		backgroundTransparency = 0.983,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 14, 61)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(132, 45, 121)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(208, 89, 169)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(122, 40, 131)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 8, 47)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.998),
			NumberSequenceKeypoint.new(0.22, 0.988),
			NumberSequenceKeypoint.new(0.50, 0.95),
			NumberSequenceKeypoint.new(0.78, 0.99),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.0045,
		rotationSpeed = -0.30,
		rotationJitter = 7,
		ampX = 0.07,
		ampY = 0.06,
		phase = 0.92,
	},
	{
		name = "SoftRoseVeil",
		type = Enum.GradientType.Linear,
		zIndex = 3,
		rotation = 8,
		offset = Vector2.new(-0.12, 0.00),
		background = Color3.fromRGB(152, 55, 103),
		backgroundTransparency = 0.986,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 35, 76)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(161, 69, 116)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(228, 130, 170)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(150, 57, 128)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 15, 47)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.999),
			NumberSequenceKeypoint.new(0.24, 0.993),
			NumberSequenceKeypoint.new(0.50, 0.966),
			NumberSequenceKeypoint.new(0.76, 0.993),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.0055,
		rotationSpeed = 0.03,
		rotationJitter = 2,
		ampX = 0.08,
		ampY = 0.03,
		phase = 0.14,
	},
	{
		name = "RubyVioletDepth",
		type = Enum.GradientType.Conical,
		zIndex = 3,
		rotation = 84,
		offset = Vector2.new(0.50, 0.12),
		background = Color3.fromRGB(101, 25, 66),
		backgroundTransparency = 0.986,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 16, 47)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(125, 34, 84)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(192, 72, 137)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(111, 37, 116)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 8, 42)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.999),
			NumberSequenceKeypoint.new(0.24, 0.992),
			NumberSequenceKeypoint.new(0.50, 0.968),
			NumberSequenceKeypoint.new(0.76, 0.994),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.0048,
		rotationSpeed = 0.21,
		rotationJitter = 5,
		ampX = 0.045,
		ampY = 0.06,
		phase = 0.58,
	},
	{
		name = "CrimsonLumen",
		type = Enum.GradientType.Radial,
		zIndex = 3,
		rotation = 0,
		offset = Vector2.new(0.20, 0.80),
		background = Color3.fromRGB(130, 24, 54),
		backgroundTransparency = 0.986,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 83, 124)),
			ColorSequenceKeypoint.new(0.20, Color3.fromRGB(192, 51, 92)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(121, 30, 68)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(62, 16, 45)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 4, 16)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.96),
			NumberSequenceKeypoint.new(0.22, 0.98),
			NumberSequenceKeypoint.new(0.50, 0.989),
			NumberSequenceKeypoint.new(0.78, 0.997),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.005,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.06,
		ampY = 0.08,
		phase = 0.84,
	},
	{
		name = "VelvetPlum",
		type = Enum.GradientType.Linear,
		zIndex = 2,
		rotation = 196,
		offset = Vector2.new(0.10, 0.08),
		background = Color3.fromRGB(74, 23, 84),
		backgroundTransparency = 0.988,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(37, 11, 47)),
			ColorSequenceKeypoint.new(0.24, Color3.fromRGB(79, 27, 94)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(118, 50, 137)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(72, 26, 94)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 27)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.999),
			NumberSequenceKeypoint.new(0.24, 0.995),
			NumberSequenceKeypoint.new(0.50, 0.976),
			NumberSequenceKeypoint.new(0.76, 0.996),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.004,
		rotationSpeed = -0.05,
		rotationJitter = 2,
		ampX = 0.06,
		ampY = 0.04,
		phase = 0.69,
	},
	{
		name = "RoseEdgeLight",
		type = Enum.GradientType.Radial,
		zIndex = 3,
		rotation = 0,
		offset = Vector2.new(1.03, 0.66),
		background = Color3.fromRGB(158, 48, 109),
		backgroundTransparency = 0.989,
		colors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 124, 182)),
			ColorSequenceKeypoint.new(0.20, Color3.fromRGB(206, 78, 141)),
			ColorSequenceKeypoint.new(0.48, Color3.fromRGB(145, 48, 107)),
			ColorSequenceKeypoint.new(0.76, Color3.fromRGB(76, 21, 64)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 4, 20)),
		}),
		transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.96),
			NumberSequenceKeypoint.new(0.20, 0.98),
			NumberSequenceKeypoint.new(0.48, 0.988),
			NumberSequenceKeypoint.new(0.76, 0.998),
			NumberSequenceKeypoint.new(1, 1),
		}),
		speed = 0.0065,
		rotationSpeed = 0,
		rotationJitter = 0,
		ampX = 0.05,
		ampY = 0.06,
		phase = 0.96,
	},
}

local function createHeaderFlowLayer(
	config,
	index
)
	local layer =
		Instance.new("Frame")

	layer.Name =
		"__NyvexHeaderFlow_"
		.. config.name

	layer.Size =
		UDim2.fromScale(1, 1)

	layer.Position =
		UDim2.fromScale(0, 0)

	layer.BackgroundColor3 =
		config.background

	layer.BackgroundTransparency =
		config.backgroundTransparency

	layer.BorderSizePixel =
		0

	layer.ZIndex =
		config.zIndex

	layer.Active =
		false

	layer.Parent =
		headerSurface

	local gradient =
		Instance.new("UIGradient")

	gradient.Name =
		"Gradient"

	gradient.Type =
		config.type

	gradient.Rotation =
		config.rotation

	gradient.Color =
		config.colors

	gradient.Transparency =
		config.transparency

	gradient.Offset =
		config.offset

	gradient.Parent =
		layer

	table.insert(
		headerFlowLayers,
		{
			layer = layer,
			gradient = gradient,
			speed =
				config.speed
				* headerFlowRandom:NextNumber(
					0.84,
					1.18
				),
			rotationSpeed =
				config.rotationSpeed,
			rotationJitter =
				config.rotationJitter,
			baseRotation =
				config.rotation,
			baseX =
				config.offset.X,
			baseY =
				config.offset.Y,
			ampX =
				config.ampX
				* headerFlowRandom:NextNumber(
					0.84,
					1.16
				),
			ampY =
				config.ampY
				* headerFlowRandom:NextNumber(
					0.84,
					1.16
				),
			seed =
				headerFlowRandom:NextNumber(
					-10000,
					10000
				),
			phase =
				config.phase
				+ headerFlowRandom:NextNumber(
					-0.12,
					0.12
				),
			index = index,
		}
	)
end

for index, config in ipairs(
	headerFlowConfigs
) do
	createHeaderFlowLayer(
		config,
		index
	)
end

local headerSurfaceNoiseA =
	Instance.new("ImageLabel")

headerSurfaceNoiseA.Name =
	"__NyvexHeaderAcrylicNoiseA"

headerSurfaceNoiseA.Size =
	UDim2.fromScale(1, 1)

headerSurfaceNoiseA.Position =
	UDim2.fromScale(0, 0)

headerSurfaceNoiseA.BackgroundTransparency =
	1

headerSurfaceNoiseA.Image =
	"rbxassetid://9968344105"

headerSurfaceNoiseA.ImageTransparency =
	0.972

headerSurfaceNoiseA.ScaleType =
	Enum.ScaleType.Tile

headerSurfaceNoiseA.TileSize =
	UDim2.fromOffset(128, 128)

headerSurfaceNoiseA.ZIndex =
	4

headerSurfaceNoiseA.Active =
	false

headerSurfaceNoiseA.Parent =
	headerSurface

local headerSurfaceNoiseB =
	Instance.new("ImageLabel")

headerSurfaceNoiseB.Name =
	"__NyvexHeaderAcrylicNoiseB"

headerSurfaceNoiseB.Size =
	UDim2.fromScale(1, 1)

headerSurfaceNoiseB.Position =
	UDim2.fromScale(0, 0)

headerSurfaceNoiseB.BackgroundTransparency =
	1

headerSurfaceNoiseB.Image =
	"rbxassetid://9968344227"

headerSurfaceNoiseB.ImageTransparency =
	0.988

headerSurfaceNoiseB.ScaleType =
	Enum.ScaleType.Tile

headerSurfaceNoiseB.TileSize =
	UDim2.fromOffset(160, 160)

headerSurfaceNoiseB.ZIndex =
	4

headerSurfaceNoiseB.Active =
	false

headerSurfaceNoiseB.Parent =
	headerSurface

local headerSpecularVeil =
	Instance.new("Frame")

headerSpecularVeil.Name =
	"__NyvexHeaderSpecularVeil"

headerSpecularVeil.Size =
	UDim2.fromScale(1, 1)

headerSpecularVeil.Position =
	UDim2.fromScale(0, 0)

headerSpecularVeil.BackgroundColor3 =
	Color3.fromRGB(255, 220, 238)

headerSpecularVeil.BackgroundTransparency =
	0.994

headerSpecularVeil.BorderSizePixel =
	0

headerSpecularVeil.ZIndex =
	4

headerSpecularVeil.Active =
	false

headerSpecularVeil.Parent =
	headerSurface

local headerSpecularVeilGradient =
	Instance.new("UIGradient")

headerSpecularVeilGradient.Name =
	"Gradient"

headerSpecularVeilGradient.Rotation =
	116

headerSpecularVeilGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(178, 42, 76)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(224, 118, 164)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 239, 248)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(212, 104, 166)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(103, 38, 111)),
	})

headerSpecularVeilGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.34, 0.996),
		NumberSequenceKeypoint.new(0.46, 0.975),
		NumberSequenceKeypoint.new(0.50, 0.90),
		NumberSequenceKeypoint.new(0.54, 0.975),
		NumberSequenceKeypoint.new(0.66, 0.996),
		NumberSequenceKeypoint.new(1, 1),
	})

headerSpecularVeilGradient.Parent =
	headerSpecularVeil

local headerReflection =
{
	softA = nil,
	softB = nil,
	midA = nil,
	midB = nil,
	coreA = nil,
	coreB = nil,
	softGradientA = nil,
	softGradientB = nil,
	midGradientA = nil,
	midGradientB = nil,
	coreGradientA = nil,
	coreGradientB = nil,
	connection = nil,
}

local function createHeaderReflectionLayer(
	name,
	zIndex,
	rotation,
	scale,
	colors,
	transparency
)
	local layer =
		Instance.new("Frame")

	layer.Name =
		name

	layer.Size =
		UDim2.fromScale(1, 1)

	layer.Position =
		UDim2.fromScale(0, 0)

	layer.BackgroundColor3 =
		Color3.fromRGB(255, 226, 241)

	layer.BackgroundTransparency =
		0.995

	layer.BorderSizePixel =
		0

	layer.ZIndex =
		zIndex

	layer.Active =
		false

	layer.Parent =
		headerSurface

	local gradient =
		Instance.new("UIGradient")

	gradient.Name =
		"Gradient"

	gradient.Type =
		Enum.GradientType.Linear

	gradient.Rotation =
		rotation

	gradient.Scale =
		scale

	gradient.TileMode =
		Enum.GradientTileMode.Clamp

	gradient.Color =
		colors

	gradient.Transparency =
		transparency

	gradient.Offset =
		Vector2.new(0, 0)

	gradient.Parent =
		layer

	return layer, gradient
end

local headerReflectionColors =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(184, 85, 135)
		),
		ColorSequenceKeypoint.new(
			0.20,
			Color3.fromRGB(222, 133, 181)
		),
		ColorSequenceKeypoint.new(
			0.38,
			Color3.fromRGB(244, 189, 219)
		),
		ColorSequenceKeypoint.new(
			0.50,
			Color3.fromRGB(255, 235, 246)
		),
		ColorSequenceKeypoint.new(
			0.62,
			Color3.fromRGB(244, 189, 219)
		),
		ColorSequenceKeypoint.new(
			0.80,
			Color3.fromRGB(222, 133, 181)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(184, 85, 135)
		),
	})

local headerReflectionTransparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.20, 1),
		NumberSequenceKeypoint.new(0.30, 0.98),
		NumberSequenceKeypoint.new(0.36, 0.86),
		NumberSequenceKeypoint.new(0.42, 0.58),
		NumberSequenceKeypoint.new(0.47, 0.28),
		NumberSequenceKeypoint.new(0.50, 0.14),
		NumberSequenceKeypoint.new(0.53, 0.28),
		NumberSequenceKeypoint.new(0.58, 0.58),
		NumberSequenceKeypoint.new(0.64, 0.86),
		NumberSequenceKeypoint.new(0.70, 0.98),
		NumberSequenceKeypoint.new(0.80, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

local headerReflectionMidTransparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 1),
		NumberSequenceKeypoint.new(0.28, 0.996),
		NumberSequenceKeypoint.new(0.38, 0.94),
		NumberSequenceKeypoint.new(0.46, 0.72),
		NumberSequenceKeypoint.new(0.50, 0.40),
		NumberSequenceKeypoint.new(0.54, 0.72),
		NumberSequenceKeypoint.new(0.62, 0.94),
		NumberSequenceKeypoint.new(0.74, 0.996),
		NumberSequenceKeypoint.new(0.86, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

local headerReflectionSoftTransparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.10, 1),
		NumberSequenceKeypoint.new(0.22, 0.998),
		NumberSequenceKeypoint.new(0.34, 0.985),
		NumberSequenceKeypoint.new(0.44, 0.91),
		NumberSequenceKeypoint.new(0.50, 0.62),
		NumberSequenceKeypoint.new(0.56, 0.91),
		NumberSequenceKeypoint.new(0.68, 0.985),
		NumberSequenceKeypoint.new(0.80, 0.998),
		NumberSequenceKeypoint.new(0.92, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

local softLayerA,
	softGradientA =
	createHeaderReflectionLayer(
		"ReflectionBlurA",
		5,
		24,
		2.35,
		headerReflectionColors,
		headerReflectionSoftTransparency
	)

local softLayerB,
	softGradientB =
	createHeaderReflectionLayer(
		"ReflectionBlurB",
		5,
		24,
		2.35,
		headerReflectionColors,
		headerReflectionSoftTransparency
	)

local midLayerA,
	midGradientA =
	createHeaderReflectionLayer(
		"ReflectionMidA",
		6,
		24,
		1.52,
		headerReflectionColors,
		headerReflectionMidTransparency
	)

local midLayerB,
	midGradientB =
	createHeaderReflectionLayer(
		"ReflectionMidB",
		6,
		24,
		1.52,
		headerReflectionColors,
		headerReflectionMidTransparency
	)

local coreLayerA,
	coreGradientA =
	createHeaderReflectionLayer(
		"ReflectionCoreA",
		6,
		24,
		1.0,
		headerReflectionColors,
		headerReflectionTransparency
	)

local coreLayerB,
	coreGradientB =
	createHeaderReflectionLayer(
		"ReflectionCoreB",
		6,
		24,
		1.0,
		headerReflectionColors,
		headerReflectionTransparency
	)

headerReflection.softA =
	softLayerA

headerReflection.softB =
	softLayerB

headerReflection.midA =
	midLayerA

headerReflection.midB =
	midLayerB

headerReflection.coreA =
	coreLayerA

headerReflection.coreB =
	coreLayerB

headerReflection.softGradientA =
	softGradientA

headerReflection.softGradientB =
	softGradientB

headerReflection.midGradientA =
	midGradientA

headerReflection.midGradientB =
	midGradientB

headerReflection.coreGradientA =
	coreGradientA

headerReflection.coreGradientB =
	coreGradientB


local headerReflectionBoostTransparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.24, 1),
		NumberSequenceKeypoint.new(0.34, 0.92),
		NumberSequenceKeypoint.new(0.42, 0.58),
		NumberSequenceKeypoint.new(0.48, 0.28),
		NumberSequenceKeypoint.new(0.50, 0.10),
		NumberSequenceKeypoint.new(0.52, 0.28),
		NumberSequenceKeypoint.new(0.58, 0.58),
		NumberSequenceKeypoint.new(0.66, 0.92),
		NumberSequenceKeypoint.new(0.76, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

local reflectionBoostLayerA,
	reflectionBoostGradientA =
	createHeaderReflectionLayer(
		"ReflectionBoostA",
		7,
		24,
		1.12,
		headerReflectionColors,
		headerReflectionBoostTransparency
	)

local reflectionBoostLayerB,
	reflectionBoostGradientB =
	createHeaderReflectionLayer(
		"ReflectionBoostB",
		7,
		24,
		1.12,
		headerReflectionColors,
		headerReflectionBoostTransparency
	)

local reflectionHaloTransparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 1),
		NumberSequenceKeypoint.new(0.34, 0.988),
		NumberSequenceKeypoint.new(0.44, 0.92),
		NumberSequenceKeypoint.new(0.50, 0.74),
		NumberSequenceKeypoint.new(0.56, 0.92),
		NumberSequenceKeypoint.new(0.68, 0.988),
		NumberSequenceKeypoint.new(0.80, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

local reflectionHaloLayerA,
	reflectionHaloGradientA =
	createHeaderReflectionLayer(
		"ReflectionHaloA",
		5,
		24,
		2.85,
		headerReflectionColors,
		reflectionHaloTransparency
	)

local reflectionHaloLayerB,
	reflectionHaloGradientB =
	createHeaderReflectionLayer(
		"ReflectionHaloB",
		5,
		24,
		2.85,
		headerReflectionColors,
		reflectionHaloTransparency
	)

local shineData =
	Fluent.GetShine
	and Fluent:GetShine()

local shineConfig =
	shineData
	and shineData.Shine

local shineColorSequence =
	shineConfig
	and shineConfig.ColorSequence

local function buildHeaderGlowSequences(
	sequence,
	minimumBrightness,
	maximumBrightness
)
	if not sequence then
		return nil
	end

	local levels = {}
	local levelCount = 24

	for level = 1, levelCount do
		local alpha =
			(level - 1)
			/ (levelCount - 1)

		local brightness =
			minimumBrightness
			+ (
				maximumBrightness
				- minimumBrightness
			) * alpha

		local keypoints = {}

		for _, keypoint in ipairs(
			sequence.Keypoints
		) do
			local h, s, v =
				Color3.toHSV(
					keypoint.Value
				)

			v =
				math.clamp(
					v * brightness,
					0,
					1
				)

			table.insert(
				keypoints,
				ColorSequenceKeypoint.new(
					keypoint.Time,
					Color3.fromHSV(
						h,
						s,
						v
					)
				)
			)
		end

		levels[level] =
			ColorSequence.new(
				keypoints
			)
	end

	return levels
end

local headerThemeWash =
	Instance.new("Frame")

headerThemeWash.Name =
	"ThemeWash"

headerThemeWash.Size =
	UDim2.fromScale(1, 1)

headerThemeWash.Position =
	UDim2.fromScale(0, 0)

headerThemeWash.BackgroundColor3 =
	Color3.fromRGB(178, 42, 76)

headerThemeWash.BackgroundTransparency =
	0.985

headerThemeWash.BorderSizePixel =
	0

headerThemeWash.ZIndex =
	3

headerThemeWash.Active =
	false

headerThemeWash.Parent =
	headerSurface

local headerThemeWashGradient =
	Instance.new("UIGradient")

headerThemeWashGradient.Name =
	"Gradient"

headerThemeWashGradient.Rotation =
	24

headerThemeWashGradient.Color =
	shineColorSequence
	or headerReflectionColors

headerThemeWashGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.34, 0.996),
		NumberSequenceKeypoint.new(0.46, 0.978),
		NumberSequenceKeypoint.new(0.50, 0.952),
		NumberSequenceKeypoint.new(0.54, 0.978),
		NumberSequenceKeypoint.new(0.66, 0.996),
		NumberSequenceKeypoint.new(1, 1),
	})

headerThemeWashGradient.Offset =
	Vector2.new(-0.15, 0)

headerThemeWashGradient.Parent =
	headerThemeWash

local headerGlowSequences =
	buildHeaderGlowSequences(
		shineColorSequence
		or headerReflectionColors,
		0.84,
		1.24
	)

local headerMidGlowSequences =
	buildHeaderGlowSequences(
		headerReflectionColors,
		0.78,
		1.16
	)

local headerSoftGlowSequences =
	buildHeaderGlowSequences(
		headerReflectionColors,
		0.68,
		1.08
	)

local headerReflectionPhase =
	0

local headerReflectionSpeed =
	0.041

local headerAmbientPhase =
	0

local headerAmbientSpeed =
	0.012

local headerFlowClock =
	0

local headerGlowTime =
	0

local headerGlowAccumulator =
	0

local headerGlowSeedCore =
	Random.new():NextNumber(
		-10000,
		10000
	)

local headerGlowSeedMid =
	Random.new():NextNumber(
		-10000,
		10000
	)

local headerGlowSeedSoft =
	Random.new():NextNumber(
		-10000,
		10000
	)

local function updateHeaderGlowSequence(
	gradient,
	sequences,
	pulse
)
	if not gradient
		or not sequences
		or #sequences == 0 then
		return
	end

	local index =
		math.clamp(
			math.floor(
				pulse
				* (
					#sequences
					- 1
				) + 0.5
			) + 1,
			1,
			#sequences
		)

	gradient.Color =
		sequences[index]
end

local buttonGradientData = {}

local function addHeaderButtonGradient(
	buttonFrame,
	index
)
	local gradient =
		buttonFrame:FindFirstChild(
			"__NyvexHeaderButtonGradient"
		)

	if not gradient then
		gradient =
			Instance.new("UIGradient")

		gradient.Name =
			"__NyvexHeaderButtonGradient"

		gradient.Rotation =
			114

		gradient.TileMode =
			Enum.GradientTileMode.Clamp

		gradient.Color =
			index == 3
			and ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(70, 14, 33)
				),
				ColorSequenceKeypoint.new(
					0.34,
					Color3.fromRGB(121, 24, 52)
				),
				ColorSequenceKeypoint.new(
					0.50,
					Color3.fromRGB(178, 42, 76)
				),
				ColorSequenceKeypoint.new(
					0.66,
					Color3.fromRGB(121, 24, 52)
				),
				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(46, 10, 23)
				),
			})
			or ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(31, 13, 24)
				),
				ColorSequenceKeypoint.new(
					0.36,
					Color3.fromRGB(60, 23, 46)
				),
				ColorSequenceKeypoint.new(
					0.50,
					Color3.fromRGB(94, 34, 111)
				),
				ColorSequenceKeypoint.new(
					0.64,
					Color3.fromRGB(60, 23, 46)
				),
				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(22, 9, 19)
				),
			})

		gradient.Transparency =
			NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.68),
				NumberSequenceKeypoint.new(0.30, 0.52),
				NumberSequenceKeypoint.new(0.50, 0.34),
				NumberSequenceKeypoint.new(0.70, 0.52),
				NumberSequenceKeypoint.new(1, 0.68),
			})

		gradient.Parent =
			buttonFrame
	end

	buttonFrame.BackgroundColor3 =
		index == 3
		and Color3.fromRGB(41, 8, 21)
		or Color3.fromRGB(27, 10, 23)

	buttonFrame.BackgroundTransparency =
		index == 3
		and 0.30
		or 0.46

	table.insert(
		buttonGradientData,
		{
			gradient = gradient,
			phase = (index - 1) * 0.18,
		}
	)
end

headerReflection.connection =
	RunService.PreRender:Connect(
		function(dt)
			if not headerSurface.Parent then
				headerReflection.connection:Disconnect()
				return
			end

			headerReflectionPhase =
			(
				headerReflectionPhase
				+ dt
				* headerReflectionSpeed
			) % 1

			local phase =
				headerReflectionPhase

			softGradientA.Offset =
				Vector2.new(
					phase,
					0
				)

			softGradientB.Offset =
				Vector2.new(
					phase - 1,
					0
				)

			midGradientA.Offset =
				Vector2.new(
					phase,
					0
				)

			midGradientB.Offset =
				Vector2.new(
					phase - 1,
					0
				)

			coreGradientA.Offset =
				Vector2.new(
					phase,
					0
				)

			coreGradientB.Offset =
				Vector2.new(
					phase - 1,
					0
				)

			headerAmbientPhase =
			(
				headerAmbientPhase
				+ dt
				* headerAmbientSpeed
			) % 1


			headerFlowClock =
				(headerFlowClock or 0)
				+ dt

			for _, flowData in ipairs(
				headerFlowLayers
			) do
				local t =
					headerFlowClock
				local waveX =
					math.noise(
						t * flowData.speed,
						flowData.seed,
						0
					)
				local waveY =
					math.noise(
						t * flowData.speed * 0.73,
						flowData.seed,
						11
					)
				local rotationNoise =
					math.noise(
						t * math.max(
							0.0008,
							math.abs(flowData.rotationSpeed)
							* 0.012
						),
						flowData.seed,
						27
					)

				flowData.gradient.Offset =
					Vector2.new(
						flowData.baseX
						+ waveX
						* flowData.ampX,
						flowData.baseY
						+ waveY
						* flowData.ampY
					)

				if flowData.rotationSpeed ~= 0 then
					flowData.gradient.Rotation =
						flowData.baseRotation
						+ math.sin(
							t * flowData.rotationSpeed
							+ flowData.phase * math.pi * 2
						)
						* flowData.rotationJitter
				end
			end

			reflectionBoostGradientA.Offset =
				Vector2.new(
					headerReflectionPhase,
					0
				)

			reflectionBoostGradientB.Offset =
				Vector2.new(
					headerReflectionPhase - 1,
					0
				)

			reflectionHaloGradientA.Offset =
				Vector2.new(
					headerReflectionPhase,
					0
				)

			reflectionHaloGradientB.Offset =
				Vector2.new(
					headerReflectionPhase - 1,
					0
				)

			headerAuroraGradient.Offset =
				Vector2.new(
					headerAmbientPhase * 0.85,
					headerAmbientPhase * 0.14
				)

			headerGlassBandGradient.Offset =
				Vector2.new(
					headerAmbientPhase * 0.65,
					0
				)

			headerThemeWashGradient.Offset =
				Vector2.new(
					-0.15
					+ headerAmbientPhase * 0.90,
					headerAmbientPhase * 0.08
				)

			headerTopHighlightGradient.Offset =
				Vector2.new(
					headerAmbientPhase * 0.42,
					0
				)

			headerInnerRimGradient.Offset =
				Vector2.new(
					headerAmbientPhase * 0.30,
					0
				)

			headerColorWashGradient.Offset =
				Vector2.new(
					-headerAmbientPhase
					* 0.55,
					0
				)


			headerSpecularVeilGradient.Offset =
				Vector2.new(
					headerAmbientPhase * 0.95,
					headerAmbientPhase * 0.08
				)

			headerSurfaceNoiseA.ImageTransparency =
				0.970
				+ (
					math.sin(
						headerFlowClock * 0.17
					)
					+ 1
				) * 0.004

			headerSurfaceNoiseB.ImageTransparency =
				0.986
				+ (
					math.sin(
						headerFlowClock * 0.11
					+ 1.7
					)
					+ 1
				) * 0.003

			headerGlowTime =
				headerGlowTime
				+ dt

			headerGlowAccumulator =
				headerGlowAccumulator
				+ dt

			if headerGlowAccumulator >= 1 / 30 then
				headerGlowAccumulator =
					headerGlowAccumulator
					- 1 / 30

				local corePulse =
					(
						math.noise(
							headerGlowTime * 0.56,
							headerGlowSeedCore
						)
						+ 1
					) * 0.5

				local midPulse =
					(
						math.noise(
							headerGlowTime * 0.72,
							headerGlowSeedMid
						)
						+ 1
					) * 0.5

				local softPulse =
					(
						math.noise(
							headerGlowTime * 0.90,
							headerGlowSeedSoft
						)
						+ 1
					) * 0.5

				corePulse =
					corePulse
					* corePulse
					* (3 - 2 * corePulse)

				midPulse =
					midPulse
					* midPulse
					* (3 - 2 * midPulse)

				softPulse =
					softPulse
					* softPulse
					* (3 - 2 * softPulse)

				updateHeaderGlowSequence(
					coreGradientA,
					headerGlowSequences,
					corePulse
				)

				coreGradientB.Color =
					coreGradientA.Color

				updateHeaderGlowSequence(
					midGradientA,
					headerMidGlowSequences,
					midPulse
				)

				midGradientB.Color =
					midGradientA.Color

				updateHeaderGlowSequence(
					softGradientA,
					headerSoftGlowSequences,
					softPulse
				)

				softGradientB.Color =
					softGradientA.Color

				for _, buttonData in ipairs(
					buttonGradientData
				) do
					buttonData.gradient.Offset =
						Vector2.new(
							(
								headerGlowTime
								* 0.026
								+ buttonData.phase
							) % 1,
							0
						)
				end
			end
		end
	)

local titleIcon =
	titleBarFrame:FindFirstChild(
		"TitleIcon",
		true
	)

if titleIcon and titleIcon:IsA("ImageLabel") then
	titleIcon.Size =
		UDim2.fromOffset(18, 18)

	titleIcon.ImageColor3 =
		Color3.fromRGB(228, 201, 216)

	local iconGradient =
		titleIcon:FindFirstChild(
			"__NyvexHeaderIconGradient"
		)

	if not iconGradient then
		iconGradient =
			Instance.new("UIGradient")

		iconGradient.Name =
			"__NyvexHeaderIconGradient"

		iconGradient.Rotation =
			116

		iconGradient.Color =
			ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(168, 47, 86)
				),
				ColorSequenceKeypoint.new(
					0.26,
					Color3.fromRGB(225, 112, 151)
				),
				ColorSequenceKeypoint.new(
					0.50,
					Color3.fromRGB(255, 232, 242)
				),
				ColorSequenceKeypoint.new(
					0.72,
					Color3.fromRGB(213, 139, 196)
				),
				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(109, 46, 122)
				),
			})

		iconGradient.Transparency =
			NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.36),
				NumberSequenceKeypoint.new(0.50, 0.01),
				NumberSequenceKeypoint.new(1, 0.38),
			})

		iconGradient.Offset =
			Vector2.new(0, 0)

		iconGradient.Parent =
			titleIcon
	end
end

local titleLabel =
	titleBarFrame:FindFirstChild(
		"Title",
		true
	)

if titleLabel and titleLabel:IsA("TextLabel") then
	titleLabel.TextSize =
		13

	titleLabel.TextColor3 =
		Color3.fromRGB(244, 238, 243)

	titleLabel.TextTransparency =
		0

	titleLabel.FontFace =
		Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		)

	local titleGradient =
		titleLabel:FindFirstChild(
			"__NyvexHeaderTitleGradient"
		)

	if not titleGradient then
		titleGradient =
			Instance.new("UIGradient")

		titleGradient.Name =
			"__NyvexHeaderTitleGradient"

		titleGradient.Rotation =
			18

		titleGradient.Color =
			ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(212, 180, 197)
				),
				ColorSequenceKeypoint.new(
					0.26,
					Color3.fromRGB(247, 234, 242)
				),
				ColorSequenceKeypoint.new(
					0.48,
					Color3.fromRGB(255, 248, 252)
				),
				ColorSequenceKeypoint.new(
					0.66,
					Color3.fromRGB(242, 190, 213)
				),
				ColorSequenceKeypoint.new(
					0.84,
					Color3.fromRGB(201, 122, 162)
				),
				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(161, 76, 119)
				),
			})

		titleGradient.Transparency =
			NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.28),
				NumberSequenceKeypoint.new(0.26, 0.04),
				NumberSequenceKeypoint.new(0.48, 0),
				NumberSequenceKeypoint.new(0.66, 0.04),
				NumberSequenceKeypoint.new(0.84, 0.10),
				NumberSequenceKeypoint.new(1, 0.30),
			})

		titleGradient.Parent =
			titleLabel
	end

	local titleStroke =
		titleLabel:FindFirstChild(
			"__NyvexTitleStroke"
		)

	if not titleStroke then
		titleStroke =
			Instance.new("UIStroke")

		titleStroke.Name =
			"__NyvexTitleStroke"

		titleStroke.Thickness =
			0.8

		titleStroke.Transparency =
			0.68

		titleStroke.Color =
			Color3.fromRGB(88, 20, 49)

		titleStroke.ApplyStrokeMode =
			Enum.ApplyStrokeMode.Contextual

		titleStroke.Parent =
			titleLabel
	else
		titleStroke.Thickness =
			0.8

		titleStroke.Transparency =
			0.68

		titleStroke.Color =
			Color3.fromRGB(88, 20, 49)
	end
end

local subTitleLabel =
	titleBarFrame:FindFirstChild(
		"SubTitle",
		true
	)

if subTitleLabel and subTitleLabel:IsA("TextLabel") then
	subTitleLabel.TextSize =
		10

	subTitleLabel.TextColor3 =
		Color3.fromRGB(184, 150, 170)

	subTitleLabel.TextTransparency =
		0.04

	local subTitleGradient =
		subTitleLabel:FindFirstChild(
			"__NyvexHeaderSubTitleGradient"
		)

	if not subTitleGradient then
		subTitleGradient =
			Instance.new("UIGradient")

		subTitleGradient.Name =
			"__NyvexHeaderSubTitleGradient"

		subTitleGradient.Rotation =
			16

		subTitleGradient.Color =
			ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(128, 82, 111)
				),
				ColorSequenceKeypoint.new(
					0.28,
					Color3.fromRGB(185, 130, 160)
				),
				ColorSequenceKeypoint.new(
					0.48,
					Color3.fromRGB(224, 185, 206)
				),
				ColorSequenceKeypoint.new(
					0.68,
					Color3.fromRGB(178, 108, 151)
				),
				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(110, 53, 94)
				),
			})

		subTitleGradient.Transparency =
			NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.36),
				NumberSequenceKeypoint.new(0.32, 0.12),
				NumberSequenceKeypoint.new(0.48, 0.02),
				NumberSequenceKeypoint.new(0.68, 0.10),
				NumberSequenceKeypoint.new(1, 0.42),
			})

		subTitleGradient.Parent =
			subTitleLabel
	end

	local subTitleStroke =
		subTitleLabel:FindFirstChild(
			"__NyvexSubTitleStroke"
		)

	if not subTitleStroke then
		subTitleStroke =
			Instance.new("UIStroke")

		subTitleStroke.Name =
			"__NyvexSubTitleStroke"

		subTitleStroke.Thickness =
			0.45

		subTitleStroke.Transparency =
			0.76

		subTitleStroke.Color =
			Color3.fromRGB(65, 16, 39)

		subTitleStroke.ApplyStrokeMode =
			Enum.ApplyStrokeMode.Contextual

		subTitleStroke.Parent =
			subTitleLabel
	end
end

local titleButtons = {
	Window.TitleBar
		and Window.TitleBar.MinButton,

	Window.TitleBar
		and Window.TitleBar.MaxButton,

	Window.TitleBar
		and Window.TitleBar.CloseButton,
}

for index, buttonObject in ipairs(
	titleButtons
) do
	local buttonFrame =
		buttonObject
		and buttonObject.Frame

	if buttonFrame then
		addHeaderButtonGradient(
			buttonFrame,
			index
		)

		buttonFrame.ZIndex =
			8

		local oldStroke =
			buttonFrame:FindFirstChild(
				"__NyvexHeaderButtonStroke"
			)

		if not oldStroke then
			local buttonStroke =
				Instance.new("UIStroke")

			buttonStroke.Name =
				"__NyvexHeaderButtonStroke"

			buttonStroke.Thickness =
				1

			buttonStroke.Transparency =
				index == 3
				and 0.66
				or 0.80

			buttonStroke.Color =
				index == 3
				and Color3.fromRGB(
					156,
					43,
					78
				)
				or Color3.fromRGB(
					115,
					61,
					99
				)

			buttonStroke.ApplyStrokeMode =
				Enum.ApplyStrokeMode.Border

			buttonStroke.Parent =
				buttonFrame

			local buttonStrokeGradient =
				Instance.new("UIGradient")

			buttonStrokeGradient.Name =
				"Gradient"

			buttonStrokeGradient.Color =
				index == 3
				and ColorSequence.new({
					ColorSequenceKeypoint.new(
						0,
						Color3.fromRGB(81, 20, 41)
					),
					ColorSequenceKeypoint.new(
						0.34,
						Color3.fromRGB(141, 34, 64)
					),
					ColorSequenceKeypoint.new(
						0.50,
						Color3.fromRGB(194, 58, 91)
					),
					ColorSequenceKeypoint.new(
						0.66,
						Color3.fromRGB(141, 34, 64)
					),
					ColorSequenceKeypoint.new(
						1,
						Color3.fromRGB(81, 20, 41)
					),
				})
				or ColorSequence.new({
					ColorSequenceKeypoint.new(
						0,
						Color3.fromRGB(58, 34, 48)
					),
					ColorSequenceKeypoint.new(
						0.30,
						Color3.fromRGB(91, 53, 76)
					),
					ColorSequenceKeypoint.new(
						0.50,
						Color3.fromRGB(136, 72, 113)
					),
					ColorSequenceKeypoint.new(
						0.70,
						Color3.fromRGB(91, 53, 76)
					),
					ColorSequenceKeypoint.new(
						1,
						Color3.fromRGB(58, 34, 48)
					),
				})

			buttonStrokeGradient.Transparency =
				NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.24),
					NumberSequenceKeypoint.new(0.30, 0.06),
					NumberSequenceKeypoint.new(0.50, 0),
					NumberSequenceKeypoint.new(0.70, 0.06),
					NumberSequenceKeypoint.new(1, 0.24),
				})

			buttonStrokeGradient.Parent =
				buttonStroke
		else
			oldStroke.Thickness =
				1

			oldStroke.Transparency =
				index == 3
				and 0.66
				or 0.80

			oldStroke.Color =
				index == 3
				and Color3.fromRGB(
					156,
					43,
					78
				)
				or Color3.fromRGB(
					115,
					61,
					99
				)
		end
	end
end

if titleBarFrame then
	titleBarFrame.ZIndex =
		8

	for _, child in ipairs(
		titleBarFrame:GetDescendants()
	) do
		if child:IsA("GuiObject") then
			child.ZIndex =
				math.max(
					child.ZIndex,
					8
				)
		end
	end
end

local headerTopHighlight =
	Instance.new("Frame")

headerTopHighlight.Name =
	"TopHighlight"

headerTopHighlight.Size =
	UDim2.new(1, -16, 0, 1)

headerTopHighlight.Position =
	UDim2.fromOffset(8, 0)

headerTopHighlight.BackgroundColor3 =
	Color3.fromRGB(244, 223, 234)

headerTopHighlight.BackgroundTransparency =
	0.72

headerTopHighlight.BorderSizePixel =
	0

headerTopHighlight.ZIndex =
	9

headerTopHighlight.Active =
	false

headerTopHighlight.Parent =
	headerSurface

local headerTopHighlightGradient =
	Instance.new("UIGradient")

headerTopHighlightGradient.Name =
	"Gradient"

headerTopHighlightGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(124, 39, 104)
		),
		ColorSequenceKeypoint.new(
			0.18,
			Color3.fromRGB(194, 92, 141)
		),
		ColorSequenceKeypoint.new(
			0.32,
			Color3.fromRGB(236, 158, 191)
		),
		ColorSequenceKeypoint.new(
			0.50,
			Color3.fromRGB(255, 244, 250)
		),
		ColorSequenceKeypoint.new(
			0.68,
			Color3.fromRGB(232, 149, 188)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(152, 71, 131)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(94, 34, 111)
		),
	})

headerTopHighlightGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.70),
		NumberSequenceKeypoint.new(0.20, 0.34),
		NumberSequenceKeypoint.new(0.34, 0.22),
		NumberSequenceKeypoint.new(0.50, 0.06),
		NumberSequenceKeypoint.new(0.66, 0.22),
		NumberSequenceKeypoint.new(0.80, 0.36),
		NumberSequenceKeypoint.new(1, 0.72),
	})

headerTopHighlightGradient.Parent =
	headerTopHighlight

local headerInnerRim =
	Instance.new("Frame")

headerInnerRim.Name =
	"InnerRim"

headerInnerRim.Size =
	UDim2.new(1, -20, 0, 1)

headerInnerRim.Position =
	UDim2.fromOffset(10, 2)

headerInnerRim.BackgroundColor3 =
	Color3.fromRGB(255, 210, 232)

headerInnerRim.BackgroundTransparency =
	0.88

headerInnerRim.BorderSizePixel =
	0

headerInnerRim.ZIndex =
	9

headerInnerRim.Active =
	false

headerInnerRim.Parent =
	headerSurface

local headerInnerRimGradient =
	Instance.new("UIGradient")

headerInnerRimGradient.Name =
	"Gradient"

headerInnerRimGradient.Rotation =
	18

headerInnerRimGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(102, 33, 77)
		),
		ColorSequenceKeypoint.new(
			0.24,
			Color3.fromRGB(204, 101, 153)
		),
		ColorSequenceKeypoint.new(
			0.50,
			Color3.fromRGB(255, 230, 243)
		),
		ColorSequenceKeypoint.new(
			0.76,
			Color3.fromRGB(198, 98, 153)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(105, 36, 90)
		),
	})

headerInnerRimGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.74),
		NumberSequenceKeypoint.new(0.24, 0.42),
		NumberSequenceKeypoint.new(0.50, 0.16),
		NumberSequenceKeypoint.new(0.76, 0.44),
		NumberSequenceKeypoint.new(1, 0.76),
	})

headerInnerRimGradient.Parent =
	headerInnerRim

local headerBottomDepth =
	Instance.new("Frame")

headerBottomDepth.Name =
	"BottomDepth"

headerBottomDepth.Size =
	UDim2.new(1, 0, 0, 12)

headerBottomDepth.Position =
	UDim2.fromOffset(0, 30)

headerBottomDepth.BackgroundColor3 =
	Color3.fromRGB(13, 4, 13)

headerBottomDepth.BackgroundTransparency =
	0.78

headerBottomDepth.BorderSizePixel =
	0

headerBottomDepth.ZIndex =
	4

headerBottomDepth.Active =
	false

headerBottomDepth.Parent =
	headerSurface

local headerBottomDepthGradient =
	Instance.new("UIGradient")

headerBottomDepthGradient.Name =
	"Gradient"

headerBottomDepthGradient.Rotation =
	90

headerBottomDepthGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(37, 10, 27)
		),
		ColorSequenceKeypoint.new(
			0.34,
			Color3.fromRGB(77, 20, 50)
		),
		ColorSequenceKeypoint.new(
			0.62,
			Color3.fromRGB(54, 13, 39)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(31, 7, 25)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(12, 3, 11)
		),
	})

headerBottomDepthGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.28, 0.99),
		NumberSequenceKeypoint.new(0.58, 0.86),
		NumberSequenceKeypoint.new(0.78, 0.64),
		NumberSequenceKeypoint.new(1, 0.34),
	})

headerBottomDepthGradient.Parent =
	headerBottomDepth

local bottomDividerGlow =
	Instance.new("Frame")

bottomDividerGlow.Name =
	"BottomDividerGlow"

bottomDividerGlow.Size =
	UDim2.new(1, 0, 0, 4)

bottomDividerGlow.Position =
	UDim2.fromOffset(0, 39)

bottomDividerGlow.BackgroundColor3 =
	Color3.fromRGB(178, 42, 76)

bottomDividerGlow.BackgroundTransparency =
	0.90

bottomDividerGlow.BorderSizePixel =
	0

bottomDividerGlow.ZIndex =
	8

bottomDividerGlow.Active =
	false

bottomDividerGlow.Parent =
	headerSurface

local bottomDividerGlowGradient =
	Instance.new("UIGradient")

bottomDividerGlowGradient.Name =
	"Gradient"

bottomDividerGlowGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(96, 24, 47)
		),
		ColorSequenceKeypoint.new(
			0.26,
			Color3.fromRGB(170, 44, 80)
		),
		ColorSequenceKeypoint.new(
			0.50,
			Color3.fromRGB(230, 90, 125)
		),
		ColorSequenceKeypoint.new(
			0.74,
			Color3.fromRGB(170, 44, 80)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(96, 24, 47)
		),
	})

bottomDividerGlowGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.88),
		NumberSequenceKeypoint.new(0.26, 0.56),
		NumberSequenceKeypoint.new(0.50, 0.30),
		NumberSequenceKeypoint.new(0.74, 0.56),
		NumberSequenceKeypoint.new(1, 0.88),
	})

bottomDividerGlowGradient.Parent =
	bottomDividerGlow

local bottomDivider =
	Instance.new("Frame")

bottomDivider.Name =
	"BottomDivider"

bottomDivider.Size =
	UDim2.new(1, 0, 0, 1)

bottomDivider.Position =
	UDim2.fromOffset(0, 41)

bottomDivider.BackgroundColor3 =
	Color3.fromRGB(128, 35, 64)

bottomDivider.BackgroundTransparency =
	0.36

bottomDivider.BorderSizePixel =
	0

bottomDivider.ZIndex =
	9

bottomDivider.Active =
	false

bottomDivider.Parent =
	headerSurface

local dividerGradient =
	Instance.new("UIGradient")

dividerGradient.Name =
	"Gradient"

dividerGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(68, 20, 37)
		),
		ColorSequenceKeypoint.new(
			0.16,
			Color3.fromRGB(118, 32, 58)
		),
		ColorSequenceKeypoint.new(
			0.32,
			Color3.fromRGB(171, 42, 77)
		),
		ColorSequenceKeypoint.new(
			0.50,
			Color3.fromRGB(216, 71, 106)
		),
		ColorSequenceKeypoint.new(
			0.68,
			Color3.fromRGB(171, 42, 77)
		),
		ColorSequenceKeypoint.new(
			0.84,
			Color3.fromRGB(118, 32, 58)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(68, 20, 37)
		),
	})

dividerGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.70),
		NumberSequenceKeypoint.new(0.18, 0.42),
		NumberSequenceKeypoint.new(0.34, 0.20),
		NumberSequenceKeypoint.new(0.50, 0.05),
		NumberSequenceKeypoint.new(0.66, 0.20),
		NumberSequenceKeypoint.new(0.82, 0.42),
		NumberSequenceKeypoint.new(1, 0.70),
	})

dividerGradient.Parent =
	bottomDivider

local headerStroke =
	Instance.new("UIStroke")

headerStroke.Name =
	"Border"

headerStroke.Thickness =
	1

headerStroke.Transparency =
	0.70

headerStroke.Color =
	Color3.fromRGB(116, 33, 61)

headerStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

headerStroke.Parent =
	headerSurface

local headerStrokeGradient =
	Instance.new("UIGradient")

headerStrokeGradient.Name =
	"Gradient"

headerStrokeGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(62, 18, 35)
		),
		ColorSequenceKeypoint.new(
			0.16,
			Color3.fromRGB(119, 34, 62)
		),
		ColorSequenceKeypoint.new(
			0.32,
			Color3.fromRGB(178, 42, 76)
		),
		ColorSequenceKeypoint.new(
			0.48,
			Color3.fromRGB(221, 76, 111)
		),
		ColorSequenceKeypoint.new(
			0.64,
			Color3.fromRGB(178, 42, 76)
		),
		ColorSequenceKeypoint.new(
			0.82,
			Color3.fromRGB(119, 34, 62)
		),
		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(62, 18, 35)
		),
	})

headerStrokeGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.70),
		NumberSequenceKeypoint.new(0.18, 0.82),
		NumberSequenceKeypoint.new(0.34, 0.56),
		NumberSequenceKeypoint.new(0.50, 0.34),
		NumberSequenceKeypoint.new(0.66, 0.56),
		NumberSequenceKeypoint.new(0.82, 0.82),
		NumberSequenceKeypoint.new(1, 0.70),
	})

headerStrokeGradient.Parent =
	headerStroke

end

local sidebarFrame =
windowRoot:FindFirstChild("_SidebarFrame", true)

if sidebarFrame then
sidebarFrame.Visible = false
end

local Lighting =
game:GetService("Lighting")

local worldBlur =
Lighting:FindFirstChild(
"__NyvexWorldBlur"
)

if not worldBlur
or not worldBlur:IsA("BlurEffect") then

if worldBlur then  
	worldBlur:Destroy()  
end  

worldBlur =  
	Instance.new("BlurEffect")  

worldBlur.Name =  
	"__NyvexWorldBlur"  

worldBlur.Size =  
	0  

worldBlur.Enabled =  
	true  

worldBlur.Parent =  
	Lighting

end

local worldBlurTween = nil

local function updateWorldBlur(isOpen)
if not worldBlur
or not worldBlur.Parent then
return
end

if worldBlurTween then  
	worldBlurTween:Cancel()  
	worldBlurTween = nil  
end  

worldBlur.Enabled =  
	true  

local targetSize =  
isOpen  
and 9  
or 0  

worldBlurTween =  
	TweenService:Create(  
		worldBlur,  
		TweenInfo.new(  
			isOpen  
			and 0.24  
			or 0.18,  
			Enum.EasingStyle.Quad,  
			Enum.EasingDirection.Out  
		),  
		{  
			Size = targetSize,  
		}  
	)  

worldBlurTween:Play()  

local activeTween =  
	worldBlurTween  

if not isOpen then  
	activeTween.Completed:Connect(  
		function()  
			if worldBlurTween ==  
					activeTween  
				and Window.Root  
				and not Window.Root.Visible  
				and worldBlur  
				and worldBlur.Parent then  

				worldBlur.Enabled =  
					false  
			end  
		end  
	)  
end

end

updateWorldBlur(
Window.Root.Visible
)

Window.Root:GetPropertyChangedSignal(
"Visible"
):Connect(
function()
updateWorldBlur(
Window.Root.Visible
)
end
)

local sourceScreenGui =
Window.Root:FindFirstAncestorOfClass("ScreenGui")

assert(
sourceScreenGui,
"Nyvex Hub: não foi possível localizar o ScreenGui da Window.Root para o resize."
)

-- O handle continua FORA da Window.Root para não ser cortado pelo CanvasGroup,
-- mas fica dentro do MESMO ScreenGui da janela. Assim AbsolutePosition e Position
-- trabalham no mesmo sistema de coordenadas da própria Window, sem uma segunda
-- ScreenGui introduzir diferença de inset/coordenadas.
local ResizeGui = Instance.new("Frame")
ResizeGui.Name = "NyvexResizeLayer"
ResizeGui.Position = UDim2.fromScale(0, 0)
ResizeGui.Size = UDim2.fromScale(1, 1)
ResizeGui.BackgroundTransparency = 1
ResizeGui.BorderSizePixel = 0
ResizeGui.Active = false
ResizeGui.Selectable = false
ResizeGui.ClipsDescendants = false
ResizeGui.ZIndex = 1000
ResizeGui.Parent = sourceScreenGui

-- Camada de HIT-TEST dedicada. Ela fica em um ScreenGui próprio, acima das demais
-- interfaces, porque o handle visual pode estar em uma árvore que não recebe o
-- input primário mesmo estando desenhado corretamente. O proxy não desenha nada;
-- ele só recebe o clique/toque e entrega o mesmo InputObject ao resize.
local resizeInputGui = Instance.new("ScreenGui")
resizeInputGui.Name = "NyvexResizeInputLayer"
resizeInputGui.IgnoreGuiInset = false
resizeInputGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
resizeInputGui.ResetOnSpawn = false
resizeInputGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
resizeInputGui.DisplayOrder = math.max(
    (sourceScreenGui.DisplayOrder or 0) + 1000,
    1000000
)
resizeInputGui.Parent = sourceScreenGui.Parent

local resizeInputProxy = Instance.new("TextButton")
resizeInputProxy.Name = "ResizeInputProxy"
resizeInputProxy.AnchorPoint = Vector2.new(0.5, 0.5)
resizeInputProxy.Size = UDim2.fromOffset(34, 34)
resizeInputProxy.BackgroundTransparency = 1
resizeInputProxy.BorderSizePixel = 0
resizeInputProxy.AutoButtonColor = false
resizeInputProxy.Text = ""
resizeInputProxy.Active = true
resizeInputProxy.Interactable = true
resizeInputProxy.InputSink = Enum.InputSink.Activate
resizeInputProxy.Selectable = false
resizeInputProxy.ZIndex = 1000
resizeInputProxy.Parent = resizeInputGui

-- ============================================================
-- ===== ROOT UISCALE + LIBRARY-CANONICAL LIVE RESIZE ============
-- ============================================================
-- A arquitetura anterior criava uma segunda árvore visual (canvas/shell) e
-- reparentava a Window.Root. Isso altera a hierarquia que a Fluent usa para
-- drag, input, overlays, layering e outros contratos internos.
--
-- Nesta versão a árvore original permanece intacta: Window.Root continua com o
-- mesmo Parent, os mesmos descendentes e as mesmas conexões de input.
--
-- O único transform visual é um UIScale diretamente no Root. A escala nativa
-- do Roblox multiplica proporcionalmente o AbsoluteSize do Root e de toda a
-- sua árvore, incluindo UIStroke/UICorner, sem tocar em TextSize, Position,
-- Size, Padding ou layouts individuais.
--
-- Durante o resize, o tamanho visual desejado é a fonte de verdade. A library
-- continua sendo dona do mesmo GroupMotor, mas recebe o tamanho lógico que,
-- multiplicado pelo UIScale, produz exatamente o tamanho visual apontado pelo
-- dedo/mouse.
local MIN_WIDTH = 470
local MIN_HEIGHT = 380

local responsiveBaseSize = Vector2.new(
    Window.Root.AbsoluteSize.X > 0 and Window.Root.AbsoluteSize.X or 540,
    Window.Root.AbsoluteSize.Y > 0 and Window.Root.AbsoluteSize.Y or 400
)

local responsiveVisualSize = Vector2.new(
    responsiveBaseSize.X,
    responsiveBaseSize.Y
)

local responsiveCurrentScale = 1

-- ============================================================
-- ====== RESIZE-TIME LAYOUT OWNERSHIP ==========================
-- ============================================================
-- AutomaticSize remains owned by Fluent/Roblox during the gesture. UIScale
-- supplies the visual transform while the underlying layout remains stable.
local responsiveRootScale =
    Window.Root:FindFirstChild("__NyvexRootVisualScale")

if not responsiveRootScale then
    responsiveRootScale = Instance.new("UIScale")
    responsiveRootScale.Name = "__NyvexRootVisualScale"
    responsiveRootScale.Scale = 1
    responsiveRootScale.Parent = Window.Root
else
    responsiveRootScale.Scale = 1
end

local function getResponsiveScale(width, height)
    local widthRatio =
        math.max(
            width / math.max(responsiveBaseSize.X, 0.0001),
            0.0001
        )

    local heightRatio =
        math.max(
            height / math.max(responsiveBaseSize.Y, 0.0001),
            0.0001
        )

    return math.sqrt(
        math.max(
            widthRatio * heightRatio,
            0.0001
        )
    )
end

local function visualToLogicalSize(width, height)
    local scale =
        getResponsiveScale(
            width,
            height
        )

    local logicalWidth =
        math.max(
            1,
            math.round(width / scale)
        )

    local logicalHeight =
        math.max(
            1,
            math.round(height / scale)
        )

    return Vector2.new(
        logicalWidth,
        logicalHeight
    ), scale
end

-- The actual GroupMotor bridge lives inside the compiled library closure. The
-- outer code deliberately uses different method names so it cannot overwrite
-- those bridge functions on the Window table.
local function beginExternalResize(width, height)
    if Window._NyvexMotorBeginExternalResize then
        Window._NyvexMotorBeginExternalResize(
            width,
            height
        )
    else
        Window.Root.Size = UDim2.fromOffset(width, height)
    end
end

local function updateExternalResize(width, height)
    if Window._NyvexMotorUpdateExternalResize then
        Window._NyvexMotorUpdateExternalResize(
            width,
            height
        )
    else
        Window.Root.Size = UDim2.fromOffset(width, height)
    end
end

local function endExternalResize(width, height)
    if Window._NyvexMotorEndExternalResize then
        Window._NyvexMotorEndExternalResize(
            width,
            height
        )
    else
        Window.Root.Size = UDim2.fromOffset(width, height)
    end
end

local function applyVisualResizeTarget(visualSize)
    local width = math.max(visualSize.X, MIN_WIDTH)
    local height = math.max(visualSize.Y, MIN_HEIGHT)

    local logicalSize, scale =
        visualToLogicalSize(width, height)

    responsiveVisualSize = Vector2.new(width, height)
    responsiveCurrentScale = scale

    responsiveRootScale.Scale = scale

    -- The native GroupMotor bridge is the canonical writer during the gesture.
    -- One rounded logical size is committed through the library's own resize path.
    updateExternalResize(
        logicalSize.X,
        logicalSize.Y
    )
end

responsiveRootScale.Scale = 1

local initialLogicalWidth =
    math.max(1, math.round(responsiveBaseSize.X))

local initialLogicalHeight =
    math.max(1, math.round(responsiveBaseSize.Y))

Window.Root.Size =
    UDim2.fromOffset(
        initialLogicalWidth,
        initialLogicalHeight
    )

Window.Size =
    UDim2.fromOffset(
        initialLogicalWidth,
        initialLogicalHeight
    )

local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
resizeHandle.Size = UDim2.fromOffset(34, 34)
resizeHandle.BackgroundTransparency = 1
resizeHandle.BorderSizePixel = 0
resizeHandle.AutoButtonColor = false
resizeHandle.Text = ""
resizeHandle.Active = true
resizeHandle.Interactable = true
resizeHandle.InputSink = Enum.InputSink.Activate
resizeHandle.Selectable = false
resizeHandle.ZIndex = 1001
resizeHandle.Parent = ResizeGui

local function updateResizeHandle()
local root = Window.Root

if not root  
	or not root.Parent  
	or not root.Visible then  
	resizeHandle.Visible = false  
	resizeInputProxy.Visible = false
	return  
end  

local position = root.AbsolutePosition  
local size = root.AbsoluteSize  

resizeHandle.Visible = true  
resizeInputProxy.Visible = true

resizeHandle.Position =  
	UDim2.fromOffset(  
		position.X + size.X - 13,  
		position.Y + size.Y - 17  
	)

resizeInputProxy.Position =
	UDim2.fromOffset(
		position.X + size.X - 13,
		position.Y + size.Y - 17
	)

end

updateResizeHandle()

Window.Root:GetPropertyChangedSignal(
"AbsolutePosition"
):Connect(updateResizeHandle)

Window.Root:GetPropertyChangedSignal(
"AbsoluteSize"
):Connect(updateResizeHandle)

Window.Root:GetPropertyChangedSignal(
"Visible"
):Connect(updateResizeHandle)

local gripContainer = Instance.new("Frame")
gripContainer.Name = "Grip"
gripContainer.AnchorPoint = Vector2.new(0.5, 0.5)
gripContainer.Position = UDim2.fromScale(0.5, 0.5)
gripContainer.Size = UDim2.fromScale(1, 1)
gripContainer.BackgroundTransparency = 1
gripContainer.BorderSizePixel = 0
gripContainer.ZIndex = 1001
gripContainer.Parent = resizeHandle

local gripA = Instance.new("Frame")
gripA.AnchorPoint = Vector2.new(1, 1)
gripA.Position = UDim2.new(1, -7, 1, -7)
gripA.Size = UDim2.fromOffset(13, 2)
gripA.Rotation = -45
gripA.BackgroundColor3 = Color3.fromRGB(165, 160, 185)
gripA.BackgroundTransparency = 0.15
gripA.BorderSizePixel = 0
gripA.ZIndex = 1002
gripA.Parent = gripContainer

local gripB = Instance.new("Frame")
gripB.AnchorPoint = Vector2.new(1, 1)
gripB.Position = UDim2.new(1, -14, 1, -12)
gripB.Size = UDim2.fromOffset(9, 2)
gripB.Rotation = -45
gripB.BackgroundColor3 = Color3.fromRGB(165, 160, 185)
gripB.BackgroundTransparency = 0.15
gripB.BorderSizePixel = 0
gripB.ZIndex = 1002
gripB.Parent = gripContainer

for _, grip in ipairs({gripA, gripB}) do
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = grip
end

local resizeGlowA = Instance.new("UIGradient")
resizeGlowA.Rotation = 0
resizeGlowA.Parent = gripA

local resizeGlowB = Instance.new("UIGradient")
resizeGlowB.Rotation = 0
resizeGlowB.Parent = gripB

-- O resize antigo não era apenas duas linhas: cada grip tinha seu próprio
-- UIShadow, invisível em repouso e revelado suavemente enquanto o símbolo
-- estava pressionado. Esta é a mesma estrutura visual, restaurada aqui.
local gripGlowA = Instance.new("UIShadow")
gripGlowA.Name = "GripGlowA"
gripGlowA.Color = Color3.fromRGB(255, 255, 255)
gripGlowA.Transparency = 1
gripGlowA.BlurRadius = UDim.new(0, 6)
gripGlowA.Offset = UDim2.fromOffset(0, 0)
gripGlowA.Spread = UDim2.fromOffset(1, 1)
gripGlowA.Enabled = true
gripGlowA.Parent = gripA

local gripGlowB = Instance.new("UIShadow")
gripGlowB.Name = "GripGlowB"
gripGlowB.Color = Color3.fromRGB(255, 255, 255)
gripGlowB.Transparency = 1
gripGlowB.BlurRadius = UDim.new(0, 6)
gripGlowB.Offset = UDim2.fromOffset(0, 0)
gripGlowB.Spread = UDim2.fromOffset(1, 1)
gripGlowB.Enabled = true
gripGlowB.Parent = gripB

local gripGlows = {gripGlowA, gripGlowB}

local resizeActive = false
local resizeInput = nil
local resizeStartPoint = nil
local resizeStartSize = nil

local RESIZE_HIT_SLOP = 5

local function setResizePressed(pressed)
local targetTransparency = pressed and 0 or 0.15

for _, glow in ipairs(gripGlows) do
local tween = TweenService:Create(
	glow,
	TweenInfo.new(pressed and 0.08 or 0.18),
	{
		Transparency = pressed and 0.35 or 1,
	}
)
tween:Play()
end

TweenService:Create(
	gripA,
	TweenInfo.new(pressed and 0.08 or 0.18),
	{
		BackgroundColor3 = pressed and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 160, 185),
		BackgroundTransparency = targetTransparency,
	}
):Play()

TweenService:Create(
	gripB,
	TweenInfo.new(pressed and 0.08 or 0.18),
	{
		BackgroundColor3 = pressed and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 160, 185),
		BackgroundTransparency = targetTransparency,
	}
):Play()
end

local function getGuiInset()
local ok, inset = pcall(function()
	return game:GetService("GuiService"):GetGuiInset()
end)

if ok and typeof(inset) == "Vector2" then
	return inset
end

return Vector2.zero
end

local function pointInsideResize(point)
if not resizeHandle.Visible then
	return false
end

local position = resizeHandle.AbsolutePosition
local size = resizeHandle.AbsoluteSize
local slop = RESIZE_HIT_SLOP
local inset = getGuiInset()

local function inside(testPoint)
	return testPoint.X >= position.X - slop
		and testPoint.X <= position.X + size.X + slop
		and testPoint.Y >= position.Y - slop
		and testPoint.Y <= position.Y + size.Y + slop
end

return inside(point)
	or inside(point + inset)
	or inside(point - inset)
end

local resizeLastPointerPoint = nil

local function beginResize(input, point)
if resizeActive then
	return
end

resizeActive = true
resizeInput = input
resizeStartPoint = point
resizeLastPointerPoint = point

resizeStartSize = Vector2.new(
    responsiveVisualSize.X,
    responsiveVisualSize.Y
)

local beginLogicalSize =
    select(1, visualToLogicalSize(
        responsiveVisualSize.X,
        responsiveVisualSize.Y
    ))

beginExternalResize(
    beginLogicalSize.X,
    beginLogicalSize.Y
)

setResizePressed(true)
end

local function applyResizeFromPoint(point)
if not resizeActive or not resizeStartPoint or not resizeStartSize then
	return
end

resizeLastPointerPoint = point

local delta = point - resizeStartPoint
local width = math.max(MIN_WIDTH, resizeStartSize.X + delta.X)
local height = math.max(MIN_HEIGHT, resizeStartSize.Y + delta.Y)

-- O alvo visual é derivado diretamente do mesmo delta do ponteiro.
-- Root lógico e UIScale recebem esse mesmo estado, sem alterar descendentes.
applyVisualResizeTarget(
    Vector2.new(width, height)
)
end

local function updateResize(point)
if not resizeActive then
	return
end

applyResizeFromPoint(point)
end

local function endResize(input)
if not resizeActive then
	return
end

if input and resizeInput and input ~= resizeInput then
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
end

local finalVisualSize =
    resizeStartSize
        and resizeLastPointerPoint
        and Vector2.new(
            math.max(
                MIN_WIDTH,
                resizeStartSize.X + (
                    resizeLastPointerPoint.X - resizeStartPoint.X
                )
            ),
            math.max(
                MIN_HEIGHT,
                resizeStartSize.Y + (
                    resizeLastPointerPoint.Y - resizeStartPoint.Y
                )
            )
        )
    or responsiveVisualSize

local finalLogicalSize, finalScale =
    visualToLogicalSize(
        finalVisualSize.X,
        finalVisualSize.Y
    )

responsiveVisualSize = finalVisualSize
responsiveCurrentScale = finalScale
responsiveRootScale.Scale = finalScale

endExternalResize(
    finalLogicalSize.X,
    finalLogicalSize.Y
)

resizeActive = false
resizeInput = nil
resizeStartPoint = nil
resizeStartSize = nil
resizeLastPointerPoint = nil

setResizePressed(false)
end

-- Hit-test global: o resize não depende da árvore de GuiObjects para começar.
-- Isso é proposital. O handle visual pode estar em uma camada que não ganha o
-- hit-test, mas UserInputService continua recebendo o input físico.
UserInputService.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
	and input.UserInputType ~= Enum.UserInputType.Touch then
	return
end

local point = Vector2.new(input.Position.X, input.Position.Y)

if pointInsideResize(point) then
	beginResize(input, point)
end
end)

UserInputService.TouchStarted:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.Touch then
	return
end

local point = Vector2.new(input.Position.X, input.Position.Y)

if pointInsideResize(point) then
	beginResize(input, point)
end
end)

UserInputService.InputChanged:Connect(function(input)
if not resizeActive or not resizeInput then
	return
end

if resizeInput.UserInputType == Enum.UserInputType.MouseButton1 then
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	updateResize(Vector2.new(input.Position.X, input.Position.Y))
	return
end

if resizeInput.UserInputType == Enum.UserInputType.Touch then
	if input ~= resizeInput then
		return
	end
	updateResize(Vector2.new(input.Position.X, input.Position.Y))
end
end)

UserInputService.TouchMoved:Connect(function(input)
if not resizeActive or not resizeInput then
	return
end

if resizeInput.UserInputType == Enum.UserInputType.Touch
	and input == resizeInput then
	updateResize(Vector2.new(input.Position.X, input.Position.Y))
end
end)

UserInputService.InputEnded:Connect(function(input)
if not resizeActive or not resizeInput then
	return
end

if input == resizeInput
	or input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
	endResize(input)
end
end)

UserInputService.TouchEnded:Connect(function(input)
if resizeActive and resizeInput == input then
	endResize(input)
end
end)

local Tabs = {
Functions = Window:AddTab({
Title = "Funções",
Icon = "zap",
}),

Appearance = Window:AddTab({  
	Title = "Aparência",  
	Icon = "palette",  
}),  

Settings = Window:AddTab({  
	Title = "Ajustes",  
	Icon = "settings",  
}),

}

local navTabs = {
{
tab = Tabs.Functions,
icon = "zap",
},
{
tab = Tabs.Appearance,
icon = "palette",
},
{
tab = Tabs.Settings,
icon = "settings",
},
}

local navGui =
Instance.new("Frame")

navGui.Name =
"NyvexNavigationRail"

navGui.Size =
UDim2.fromScale(1, 1)

navGui.Position =
UDim2.fromOffset(0, 0)

navGui.BackgroundTransparency =
1

navGui.BorderSizePixel =
0

navGui.Active =
false

navGui.ZIndex =
0

navGui.Visible =
Window.Root.Visible

navGui.Parent =
Window.Root.Parent

local navClip =
Instance.new("Frame")

navClip.Name =
"Clip"

navClip.Size =
UDim2.fromScale(1, 1)

navClip.Position =
UDim2.fromOffset(0, 0)

navClip.BackgroundTransparency =
1

navClip.BorderSizePixel =
0

navClip.ClipsDescendants =
true

navClip.Active =
false

navClip.ZIndex =
0

navClip.Parent =
navGui

-- Stable logical coordinate space for the entire rail. The clipping parent
-- remains screen-space, preserving the original layering behavior, while this
-- inner frame receives one UIScale for the whole sidebar.
local navScaleFrame =
Instance.new("Frame")

navScaleFrame.Name =
"ScaledRail"

navScaleFrame.Size =
UDim2.fromOffset(
    math.round(responsiveBaseSize.X),
    math.round(responsiveBaseSize.Y)
)

navScaleFrame.Position =
UDim2.fromOffset(
    Window.Root.AbsolutePosition.X,
    Window.Root.AbsolutePosition.Y
)

navScaleFrame.BackgroundTransparency =
1

navScaleFrame.BorderSizePixel =
0

navScaleFrame.ClipsDescendants =
false

navScaleFrame.Active =
false

navScaleFrame.ZIndex =
0

navScaleFrame.Parent =
navClip

local navResponsiveScale =
Instance.new("UIScale")

navResponsiveScale.Name =
"ResponsiveScale"

navResponsiveScale.Scale =
responsiveCurrentScale

navResponsiveScale.Parent =
navScaleFrame

local NAV_WIDTH = 130
local NAV_HEIGHT = 34
local NAV_GAP = 7
local NAV_WINDOW_GAP = 5
local NAV_EXPOSED = 34

local navItems = {}

local function setIconImage(imageObject, iconName)
local icon =
Fluent.GetIcon
and Fluent:GetIcon(iconName)

if type(icon) == "table" then  
	imageObject.Image =  
		icon.Image or ""  

	imageObject.ImageRectOffset =  
		icon.ImageRectOffset  
		or Vector2.zero  

	imageObject.ImageRectSize =  
		icon.ImageRectSize  
		or Vector2.zero  
elseif icon then  
	imageObject.Image =  
		tostring(icon)  
end

end

for index, config in ipairs(navTabs) do
local button =
Instance.new("TextButton")

button.Name =  
	"NavItem" .. index  

button.Size =  
	UDim2.fromOffset(  
		NAV_WIDTH,  
		NAV_HEIGHT  
	)  

button.Position =  
	UDim2.fromOffset(  
		0,  
		0  
	)  

button.BackgroundTransparency =  
	1  

button.BorderSizePixel =  
	0  

button.AutoButtonColor =  
	false  

button.Text =  
	""  

button.ZIndex =  
0

button.Active =
false

button.InputSink =
Enum.InputSink.None

button.Parent =
navScaleFrame

local panel =  
	Instance.new("Frame")  

panel.Name =  
	"Panel"  

panel.Size =  
	UDim2.fromScale(1, 1)  

panel.Position =  
	UDim2.fromOffset(0, 0)  

panel.BackgroundColor3 =  
	Color3.fromRGB(20, 7, 15)  

panel.BackgroundTransparency =  
	0.10  

panel.BorderSizePixel =  
	0  

panel.ZIndex =  
0  

panel.Active =  
	false  

panel.Parent =  
	button  

local panelCorner =  
	Instance.new("UICorner")  

panelCorner.CornerRadius =  
	UDim.new(0, 10)  

panelCorner.Parent =  
	panel  

local panelStroke =  
	Instance.new("UIStroke")  

panelStroke.Thickness =  
	1  

panelStroke.Color =  
	Color3.fromRGB(74, 24, 43)  

panelStroke.Transparency =  
	0.50  

panelStroke.Parent =  
	panel  

local indicator =  
	Instance.new("Frame")  

indicator.Name =  
	"Indicator"  

indicator.AnchorPoint =  
	Vector2.new(0, 0.5)  

indicator.Position =  
	UDim2.fromOffset(3, NAV_HEIGHT * 0.5)  

indicator.Size =  
	UDim2.fromOffset(3, 26)  

indicator.BackgroundColor3 =  
	Color3.fromRGB(178, 42, 76)  

indicator.BackgroundTransparency =  
	1  

indicator.BorderSizePixel =  
	0  

indicator.ZIndex =  
0  

indicator.Active =  
	false  

indicator.Parent =  
	panel  

local indicatorCorner =  
	Instance.new("UICorner")  

indicatorCorner.CornerRadius =  
	UDim.new(1, 0)  

indicatorCorner.Parent =  
	indicator  

local icon =  
	Instance.new("ImageLabel")  

icon.Name =  
	"Icon"  

icon.AnchorPoint =  
	Vector2.new(0, 0.5)  

icon.Position =  
UDim2.fromOffset(  
	10,  
	NAV_HEIGHT * 0.5  
)  

icon.Size =  
UDim2.fromOffset(  
	18,  
	18  
)  

icon.BackgroundTransparency =  
	1  

icon.ImageTransparency =  
	0.04  

icon.ZIndex =  
0  

icon.Active =  
	false  

icon.Parent =  
	panel  

setIconImage(  
	icon,  
	config.icon  
)  

local title =  
	Instance.new("TextLabel")  

title.Name =  
	"Title"  

title.AnchorPoint =  
	Vector2.new(0, 0.5)  

title.Position =  
UDim2.fromOffset(  
	42,  
	NAV_HEIGHT * 0.5  
)

title.Size =
UDim2.new(
1,
-51,
0,
26
)

title.BackgroundTransparency =  
	1  

title.Text =  
	config.tab.Name  
	or "Tab"  

title.TextColor3 =  
	Color3.fromRGB(240, 235, 240)  

title.TextTransparency =  
	1  

title.TextSize =  
13  

title.FontFace =  
	Font.new(  
		"rbxasset://fonts/families/GothamSSm.json",  
		Enum.FontWeight.SemiBold,  
		Enum.FontStyle.Normal  
	)  

title.TextXAlignment =  
	Enum.TextXAlignment.Left  

title.TextYAlignment =  
	Enum.TextYAlignment.Center  

title.ZIndex =  
0  

title.Active =  
	false  

title.Parent =  
panel

local hitbox =
Instance.new("TextButton")

hitbox.Name =
"Hitbox"

hitbox.Size =
UDim2.fromOffset(
NAV_EXPOSED,
NAV_HEIGHT
)

hitbox.Position =
UDim2.fromOffset(0, 0)

hitbox.BackgroundTransparency =
1

hitbox.BorderSizePixel =
0

hitbox.AutoButtonColor =
false

hitbox.Text =
""

hitbox.Active =
true

hitbox.InputSink =
Enum.InputSink.Activate

hitbox.ZIndex =
0

hitbox.Parent =
navScaleFrame

local item = {
index = index,
button = button,
hitbox = hitbox,
panel = panel,
icon = icon,
title = title,
indicator = indicator,
stroke = panelStroke,
progress = 0,
velocity = 0,
target = 0,
}

table.insert(
navItems,
item
)

hitbox.Activated:Connect(function()
if selectedTabIndex ~= index then
selectedTabIndex =
index

Window:SelectTab(  
		index  
	)  
end

end)
end

local selectedTabIndex = 1
local hoveredTabIndex = nil
local activeTouch = nil
local touchPosition = nil

local function pointInside(
point,
position,
size
)
return point.X >= position.X
and point.X <= position.X + size.X
and point.Y >= position.Y
and point.Y <= position.Y + size.Y
end

local function getNavHitIndex(point)
for index, item in ipairs(navItems) do
    if item.hitbox.Visible
        and pointInside(
            point,
            item.hitbox.AbsolutePosition,
            item.hitbox.AbsoluteSize
        ) then
        return index
    end
end

return nil
end

UserInputService.TouchStarted:Connect(
function(touch)
local point =
    Vector2.new(
        touch.Position.X,
        touch.Position.Y
    )

if getNavHitIndex(point) then
    activeTouch = touch
    touchPosition = point
end
end
)

UserInputService.TouchMoved:Connect(
function(touch)
if touch ~= activeTouch then
return
end

touchPosition =
    Vector2.new(
        touch.Position.X,
        touch.Position.Y
    )
end
)

UserInputService.TouchEnded:Connect(
function(touch)
if touch ~= activeTouch then
return
end

activeTouch = nil
touchPosition = nil
end
)

Window.Root:GetPropertyChangedSignal(
"Visible"
):Connect(function()
navGui.Visible =
Window.Root.Visible
end)

Window.Root.AncestryChanged:Connect(
function(_, parent)
if not parent then
pcall(function()
navGui:Destroy()
end)
end
end
)

Window.Root.AncestryChanged:Connect(
function(_, parent)
if not parent then
pcall(function()
navGui:Destroy()
end)
end
end
)

local navRenderSignal =
RunService.PreRender
or RunService.RenderStepped

local navConnection

navConnection =
navRenderSignal:Connect(
function(dt)
if not navGui.Parent
or not Window.Root
or not Window.Root.Parent then

if navConnection then  
    navConnection:Disconnect()  
    navConnection = nil  
end  

return

end

if not Window.Root.Visible then
navGui.Visible =
false

return

end

navGui.Visible =
true

local rootPosition =
Window.Root.AbsolutePosition

local camera = Workspace.CurrentCamera
local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)

navClip.Size = UDim2.fromOffset(
    math.max(rootPosition.X, 0),
    viewportSize.Y
)

-- The entire rail is now one scaled coordinate space. This is deliberate:
-- changing one UIScale on the rail is continuous, while rewriting every item's
-- Position/Size/UIScale on every frame creates separate quantization points.
navScaleFrame.Position =
UDim2.fromOffset(
    rootPosition.X,
    rootPosition.Y
)

navResponsiveScale.Scale =
responsiveCurrentScale

local pointerPosition = nil

if activeTouch
and touchPosition then
    pointerPosition = touchPosition
elseif UserInputService.MouseEnabled then
    local mouse =
        UserInputService:GetMouseLocation()

    pointerPosition =
        Vector2.new(
            mouse.X,
            mouse.Y
        )
end

-- The hitbox itself is the interaction geometry. The animation's easing
-- never creates a second coordinate system for input.
hoveredTabIndex = nil

if pointerPosition then
    hoveredTabIndex =
        getNavHitIndex(pointerPosition)
end

local totalHeight =
#navItems * NAV_HEIGHT
+ math.max(
0,
#navItems - 1
) * NAV_GAP

local navigationTop =
responsiveBaseSize.Y * 0.5
- totalHeight * 0.5

local collapsedX =
-NAV_EXPOSED

local expandedX =
-NAV_WINDOW_GAP
-NAV_WIDTH

local api =
Window.TabsAPI

if api
and tonumber(api.SelectedTab)
and api.SelectedTab >= 1
and api.SelectedTab <= #navItems
then
selectedTabIndex =
api.SelectedTab
end

for index, item in ipairs(navItems) do
local selected =
selectedTabIndex
== index

local hovered =
hoveredTabIndex
== index

local target =
(selected or hovered)
and 1
or 0

if target ~= item.target then
item.target =
target
item.velocity =
0
end

local smoothTime =
target == 1
and 0.105
or 0.090

local newProgress
local newVelocity

newProgress, newVelocity =
TweenService:SmoothDamp(
item.progress,
target,
item.velocity,
smoothTime,
math.huge,
dt
)

item.progress =
math.clamp(
newProgress,
0,
1
)

item.velocity =
newVelocity

if math.abs(
item.progress
- target
) < 0.0005
then
item.progress =
target
item.velocity =
0
end

local p =
item.progress

local eased =
p * p
* (
3
- 2 * p
)

local currentX =
collapsedX
+ (
expandedX
- collapsedX
)
* p

local y =
navigationTop
+ (index - 1)
* (
NAV_HEIGHT
+ NAV_GAP
)

item.button.Position =
UDim2.fromOffset(
currentX,
y
)

local hitboxWidth =
math.clamp(
currentX < 0 and math.min(
NAV_WIDTH,
-currentX
) or 0,
0,
NAV_WIDTH
)

item.hitbox.Position =
UDim2.fromOffset(
currentX,
y
)

item.hitbox.Size =
UDim2.fromOffset(
math.max(1, hitboxWidth),
NAV_HEIGHT
)

item.hitbox.Visible =
hitboxWidth > 0.5

item.panel.BackgroundTransparency =
0.10
+ (1 - eased)
* 0.08

item.icon.ImageTransparency =
0.04
+ (1 - eased)
* 0.08

item.title.TextTransparency =
1
- eased

item.indicator.BackgroundTransparency =
selected
and 0
or hovered
and 0.42
or 1

item.stroke.Transparency =
selected
and 0.18
or hovered
and 0.34
or 0.58

if selected then
item.icon.ImageColor3 =
Color3.fromRGB(
238,
203,
214
)
elseif hovered then
item.icon.ImageColor3 =
Color3.fromRGB(
230,
210,
223
)
else
item.icon.ImageColor3 =
Color3.fromRGB(
192,
169,
180
)
end

if selected then
item.panel.BackgroundColor3 =
Color3.fromRGB(
31,
8,
19
)
elseif hovered then
item.panel.BackgroundColor3 =
Color3.fromRGB(
27,
8,
18
)
else
item.panel.BackgroundColor3 =
Color3.fromRGB(
20,
7,
15
)
end
end
end
)

-- ============================================================
-- ========== FINALIZE RESPONSIVE RESIZE PIPELINE ===============
-- ============================================================
-- O Root recebe o tamanho físico real. O canvas lógico parte do canto superior-
-- esquerdo e usa um único fator canônico, sempre recalculado diretamente do
-- tamanho atual. Nenhum estado anterior participa do cálculo.
local resizeHandleScale = resizeHandle:FindFirstChild(
    "ResponsiveResizeScale"
)
if not resizeHandleScale then
    resizeHandleScale = Instance.new("UIScale")
    resizeHandleScale.Name = "ResponsiveResizeScale"
    resizeHandleScale.Scale = 1
    resizeHandleScale.Parent = resizeHandle
end

local resizeProxyScale = resizeInputProxy:FindFirstChild(
    "ResponsiveResizeScale"
)
if not resizeProxyScale then
    resizeProxyScale = Instance.new("UIScale")
    resizeProxyScale.Name = "ResponsiveResizeScale"
    resizeProxyScale.Scale = 1
    resizeProxyScale.Parent = resizeInputProxy
end

local resizeRenderSignal =
    RunService.PreRender
    or RunService.RenderStepped

local responsiveConnection
responsiveConnection =
    resizeRenderSignal:Connect(function()
        if not Window.Root
            or not Window.Root.Parent then
            if responsiveConnection then
                responsiveConnection:Disconnect()
                responsiveConnection = nil
            end
            return
        end

        -- O gesto já foi aplicado pelo evento de input correspondente.
        -- PreRender apenas sincroniza os adornos visuais com o estado canônico.
        local uniformScale = responsiveCurrentScale

        if resizeHandleScale then
            resizeHandleScale.Scale = uniformScale
        end

        if resizeProxyScale then
            resizeProxyScale.Scale = uniformScale
        end

        local glowBlur = 6 * uniformScale

        for _, glow in ipairs({gripGlowA, gripGlowB}) do
            if glow and glow.Parent then
                glow.BlurRadius = UDim.new(
                    0,
                    math.max(1, glowBlur)
                )

                glow.Spread = UDim2.fromOffset(
                    math.max(1, uniformScale),
                    math.max(1, uniformScale)
                )
            end
        end
    end)

-- Sincronização final depois de toda a árvore visual ter sido montada.
responsiveRootScale.Scale = responsiveCurrentScale
navResponsiveScale.Scale = responsiveCurrentScale


