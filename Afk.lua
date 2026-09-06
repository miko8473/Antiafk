--// ============================================================
--// 🔥 ULTRA AUTO REJOIN - PERSISTENT MODE
--// START EINMAL = IMMER AKTIV
--// STOP = KOMPLETT AUS
--// ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PLACE_ID = game.PlaceId

local REJOIN_TIME = 15 * 60
local RETRY_DELAY = 5
local MAX_RETRIES = 10

--==============================================================
-- PERSISTENTER STATUS
--==============================================================

-- Der Status bleibt beim erneuten Ausführen des Scripts erhalten.
local sharedState = shared and shared or getgenv and getgenv()

if not sharedState then
    sharedState = {}
end

if sharedState.UltraAutoRejoinActive == nil then
    sharedState.UltraAutoRejoinActive = false
end

--==============================================================
-- ALTES GUI ENTFERNEN
--==============================================================

pcall(function()
    local old = CoreGui:FindFirstChild("UltraAutoRejoin")
    if old then
        old:Destroy()
    end
end)

--==============================================================
-- VARIABLEN
--==============================================================

local running = sharedState.UltraAutoRejoinActive
local teleporting = false
local remaining = REJOIN_TIME

--==============================================================
-- GUI
--==============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "UltraAutoRejoin"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 175)
Frame.Position = UDim2.new(0.5, -135, 0.5, -87)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.Parent = Frame

--==============================================================
-- TITEL
--==============================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,38)
Title.BackgroundTransparency = 1
Title.Text = "🔄 ULTRA AUTO REJOIN"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

--==============================================================
-- STATUS
--==============================================================

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0,10,0,40)
Status.Size = UDim2.new(1,-20,0,25)
Status.BackgroundTransparency = 1
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

--==============================================================
-- TIMER
--==============================================================

local Timer = Instance.new("TextLabel")
Timer.Position = UDim2.new(0,10,0,67)
Timer.Size = UDim2.new(1,-20,0,32)
Timer.BackgroundTransparency = 1
Timer.TextColor3 = Color3.new(1,1,1)
Timer.TextSize = 22
Timer.Font = Enum.Font.GothamBold
Timer.Parent = Frame

--==============================================================
-- START
--==============================================================

local Start = Instance.new("TextButton")
Start.Position = UDim2.new(0,10,1,-50)
Start.Size = UDim2.new(0.48,-5,0,40)
Start.BackgroundColor3 = Color3.fromRGB(45,175,80)
Start.Text = "▶ START"
Start.TextColor3 = Color3.new(1,1,1)
Start.TextSize = 14
Start.Font = Enum.Font.GothamBold
Start.BorderSizePixel = 0
Start.Parent = Frame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0,8)
StartCorner.Parent = Start

--==============================================================
-- STOP
--==============================================================

local Stop = Instance.new("TextButton")
Stop.Position = UDim2.new(0.52,0,1,-50)
Stop.Size = UDim2.new(0.48,-10,0,40)
Stop.BackgroundColor3 = Color3.fromRGB(180,55,55)
Stop.Text = "■ STOP"
Stop.TextColor3 = Color3.new(1,1,1)
Stop.TextSize = 14
Stop.Font = Enum.Font.GothamBold
Stop.BorderSizePixel = 0
Stop.Parent = Frame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0,8)
StopCorner.Parent = Stop

--==============================================================
-- ZEIT FORMATIEREN
--==============================================================

local function formatTime(seconds)

    seconds = math.max(0, math.floor(seconds))

    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    return string.format("%02d:%02d", minutes, secs)
end

--==============================================================
-- STATUS SETZEN
--==============================================================

local function setStatus(text, color)

    Status.Text = "Status: " .. text
    Status.TextColor3 = color
end

--==============================================================
-- REJOIN
--==============================================================

local function Rejoin()

    if teleporting then
        return
    end

    teleporting = true

    setStatus(
        "Rejoin...",
        Color3.fromRGB(255,210,60)
    )

    Timer.Text = "REJOIN..."

    print("🔄 AUTO REJOIN")
    print("Versuche:", MAX_RETRIES)

    for attempt = 1, MAX_RETRIES do

        if not Player or not Player.Parent then
            return
        end

        setStatus(
            "Rejoin " .. attempt .. "/" .. MAX_RETRIES,
            Color3.fromRGB(255,210,60)
        )

        local success, errorMessage = pcall(function()

            TeleportService:Teleport(
                PLACE_ID,
                Player
            )

        end)

        if not success then
            warn("Teleport Fehler:", errorMessage)
        end

        task.wait(RETRY_DELAY)

        if not Player.Parent then
            return
        end
    end

    --==========================================================
    -- FALLBACK
    --==========================================================

    if Player and Player.Parent then

        pcall(function()

            TeleportService:TeleportAsync(
                PLACE_ID,
                {Player}
            )

        end)

    end
end

--==============================================================
-- START
--==============================================================

Start.MouseButton1Click:Connect(function()

    if running then
        return
    end

    running = true

    -- WICHTIG:
    -- Status für zukünftige Auto-Execute-Ausführungen speichern.
    sharedState.UltraAutoRejoinActive = true

    remaining = REJOIN_TIME

    setStatus(
        "Aktiv",
        Color3.fromRGB(80,255,120)
    )

    Timer.Text = formatTime(remaining)

    print("========================================")
    print("✅ AUTO REJOIN AKTIVIERT")
    print("🔒 BLEIBT ÜBER REJOIN AKTIV")
    print("========================================")
end)

--==============================================================
-- STOP
--==============================================================

Stop.MouseButton1Click:Connect(function()

    running = false
    teleporting = false

    -- WICHTIG:
    -- Erst STOP schaltet den persistenten Status aus.
    sharedState.UltraAutoRejoinActive = false

    remaining = REJOIN_TIME

    setStatus(
        "Gestoppt",
        Color3.fromRGB(255,80,80)
    )

    Timer.Text = formatTime(REJOIN_TIME)

    print("========================================")
    print("⛔ AUTO REJOIN KOMPLETT AUS")
    print("========================================")
end)

--==============================================================
-- TIMER
--==============================================================

task.spawn(function()

    while Gui and Gui.Parent do

        task.wait(1)

        if running and not teleporting then

            remaining -= 1

            if remaining <= 0 then

                remaining = 0
                Timer.Text = "00:00"

                Rejoin()

            else

                Timer.Text = formatTime(remaining)

            end
        end
    end
end)

--==============================================================
-- AUTO START NACH REJOIN
--==============================================================

if running then

    setStatus(
        "Automatisch aktiv",
        Color3.fromRGB(80,255,120)
    )

    Timer.Text = formatTime(REJOIN_TIME)

    print("========================================")
    print("🔄 AUTO REJOIN WIEDERHERGESTELLT")
    print("⏱️ Neuer Timer: 15:00")
    print("========================================")

else

    setStatus(
        "Bereit",
        Color3.fromRGB(255,210,60)
    )

    Timer.Text = "15:00"

    print("========================================")
    print("🔥 ULTRA AUTO REJOIN GELADEN")
    print("▶ START drücken")
    print("========================================")
end
