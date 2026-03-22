return function(settings)
    local self = {}

    self._settings = {
    TOGGLE = "L",
	TARGET_LIMB = "HumanoidRootPart",
	LIMB_SIZE = 15,
	LIMB_TRANSPARENCY = 0.9,
	LIMB_CAN_COLLIDE = false,
	MOBILE_BUTTON = true,
	LISTEN_FOR_INPUT = true,
	TEAM_CHECK = true,
	FORCEFIELD_CHECK = true,
	RESET_LIMB_ON_DEATH2 = false,
	USE_HIGHLIGHT = true,
	DEPTH_MODE = "AlwaysOnTop",
	HIGHLIGHT_FILL_COLOR = Color3.fromRGB(255, 117, 24),
	HIGHLIGHT_FILL_TRANSPARENCY = 0.7,
	HIGHLIGHT_OUTLINE_COLOR = Color3.fromRGB(0,0,0),
	HIGHLIGHT_OUTLINE_TRANSPARENCY = 1,
    }

    for k,v in pairs(settings or {}) do
        self._settings[k] = v
    end

    self._enabled = false
    self._connections = {}

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- =========================
    -- CHECK LIMB (MULTI)
    -- =========================
    local function isTarget(part, target)
        if typeof(target) == "table" then
            return target[part.Name]
        else
            return part.Name == target
        end
    end

    -- =========================
    -- APPLY
    -- =========================
    function self:apply(char)
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if isTarget(part, self._settings.TARGET_LIMB) then

                    part.Size = Vector3.new(
                        self._settings.LIMB_SIZE,
                        self._settings.LIMB_SIZE,
                        self._settings.LIMB_SIZE
                    )

                    part.Transparency = self._settings.LIMB_TRANSPARENCY
                    part.CanCollide = self._settings.LIMB_CAN_COLLIDE
                end
            end
        end
    end

    -- =========================
    -- LOOP
    -- =========================
    function self:loop()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if self._settings.TEAM_CHECK and player.Team == LocalPlayer.Team then
                    continue
                end

                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        if self._settings.FORCEFIELD_CHECK and char:FindFirstChild("ForceField") then
                            continue
                        end
                        self:apply(char)
                    end
                end
            end
        end
    end

    -- =========================
    -- ENABLE
    -- =========================
    function self:Toggle(state)
        self._enabled = state

        if state then
            self._connections.loop = game:GetService("RunService").RenderStepped:Connect(function()
                self:loop()
            end)
        else
            if self._connections.loop then
                self._connections.loop:Disconnect()
                self._connections.loop = nil
            end
        end
    end

    function self:Set(key, value)
        self._settings[key] = value
    end

    function self:Get(key)
        return self._settings[key]
    end

    return self
end
