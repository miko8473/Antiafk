--// ============================================================
--// 🔥 ULTRA AUTO REJOIN
--// ⏱️ 15 MINUTEN
--// 🤖 DELTA / AUTO EXECUTE
--// ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PLACE_ID = game.PlaceId

local REJOIN_AFTER = 15 * 60
local RETRY_DELAY = 5
local MAX_RETRIES = 10

local running = false
local teleporting = false
local remaining = REJOIN_AFTER

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
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.Parent = Frame

--==============================================================
-- TITEL
--==============================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "🔄 ULTRA AUTO REJOIN"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

--==============================================================
-- STATUS
--==============================================================

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 10, 0, 40)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "Status: Bereit"
Status.TextColor3 = Color3.fromRGB(255, 210, 80)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

--==============================================================
-- TIMER
--==============================================================

local Timer = Instance.new("TextLabel")
Timer.Position = UDim2.new(0, 10, 0, 67)
Timer.Size = UDim2.new(1, -20, 0, 32)
Timer.BackgroundTransparency = 1
Timer.Text = "15:00"
Timer.TextColor3 = Color3.new(1, 1, 1)
Timer.TextSize = 22
Timer.Font = Enum.Font.GothamBold
Timer.Parent = Frame

--==============================================================
-- START
--==============================================================

local Start = Instance.new("TextButton")
Start.Position = UDim2.new(0, 10, 1, -50)
Start.Size = UDim2.new(0.48, -5, 0, 40)
Start.BackgroundColor3 = Color3.fromRGB(45, 175, 80)
Start.Text = "▶ START"
Start.TextColor3 = Color3.new(1, 1, 1)
Start.TextSize = 14
Start.Font = Enum.Font.GothamBold
Start.BorderSizePixel = 0
Start.Parent = Frame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = Start

--==============================================================
-- STOP
--==============================================================

local Stop = Instance.new("TextButton")
Stop.Position = UDim2.new(0.52, 0, 1, -50)
Stop.Size = UDim2.new(0.48, -10, 0, 40)
Stop.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
Stop.Text = "■ STOP"
Stop.TextColor3 = Color3.new(1, 1, 1)
Stop.TextSize = 14
Stop.Font = Enum.Font.GothamBold
Stop.BorderSizePixel = 0
Stop.Parent = Frame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
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
-- STATUS
--==============================================================

local function setStatus(text, color)

    Status.Text = "Status: " .. text

    if color then
        Status.TextColor3 = color
    end
end

--==============================================================
-- TELEPORT FEHLER
--==============================================================

local teleportFailedConnection

pcall(function()

    teleportFailedConnection =
        TeleportService.TeleportInitFailed:Connect(function(
            player,
            teleportResult,
            errorMessage
        )

            if player ~= Player then
                return
            end

            warn("⚠️ TELEPORT FEHLER")
            warn("Result:", teleportResult)
            warn("Message:", errorMessage)

            teleporting = false

            if running then
                setStatus(
                    "Teleport fehlgeschlagen – Retry",
                    Color3.fromRGB(255, 120, 80)
                )
            end
        end)
end)

--==============================================================
-- REJOIN
--==============================================================

local function Rejoin()

    if teleporting then
        return
    end

    teleporting = true
    running = false

    setStatus(
        "Server wird verlassen...",
        Color3.fromRGB(255, 210, 60)
    )

    Timer.Text = "REJOIN..."

    print("================================================")
    print("🔄 ULTRA AUTO REJOIN")
    print("📍 PlaceId:", PLACE_ID)
    print("================================================")

    --==========================================================
    -- MEHRERE VERSUCHE
    --==========================================================

    for attempt = 1, MAX_RETRIES do

        if not Player or not Player.Parent then
            return
        end

        setStatus(
            "Rejoin Versuch " .. attempt .. "/" .. MAX_RETRIES,
            Color3.fromRGB(255, 210, 60)
        )

        print("🚀 Rejoin Versuch:", attempt)

        local success, errorMessage = pcall(function()

            -- Standard-Rejoin
            TeleportService:Teleport(
                PLACE_ID,
                Player
            )

        end)

        if success then

            print("✅ Teleport-Aufruf erfolgreich")

            -- Roblox sollte jetzt den aktuellen Server verlassen.
            -- Wir warten etwas, bevor wir ggf. erneut versuchen.
            task.wait(RETRY_DELAY)

            -- Wenn der Spieler immer noch da ist,
            -- wurde der Teleport wahrscheinlich nicht abgeschlossen.
            if not Player.Parent then
                return
            end

        else

            warn(
                "❌ Teleport-Aufruf fehlgeschlagen:",
                errorMessage
            )

            task.wait(RETRY_DELAY)
        end
    end

    --==========================================================
    -- FINALER FALLBACK
    --==========================================================

    if Player and Player.Parent then

        setStatus(
            "Finaler Rejoin-Versuch...",
            Color3.fromRGB(255, 80, 80)
        )

        print("🔥 FINALER TELEPORT")

        pcall(function()

            TeleportService:TeleportAsync(
                PLACE_ID,
                { Player }
            )

        end)
    end
end

--==============================================================
-- START BUTTON
--==============================================================

Start.MouseButton1Click:Connect(function()

    if running or teleporting then
        return
    end

    running = true
    teleporting = false
    remaining = REJOIN_AFTER

    setStatus(
        "Aktiv",
        Color3.fromRGB(80, 255, 120)
    )

    Timer.Text = formatTime(remaining)

    print("================================================")
    print("✅ AUTO REJOIN GESTARTET")
    print("⏱️ Nächster Rejoin: 15 Minuten")
    print("================================================")
end)

--==============================================================
-- STOP BUTTON
--==============================================================

Stop.MouseButton1Click:Connect(function()

    running = false
    teleporting = false
    remaining = REJOIN_AFTER

    setStatus(
        "Gestoppt",
        Color3.fromRGB(255, 80, 80)
    )

    Timer.Text = formatTime(REJOIN_AFTER)

    print("⛔ AUTO REJOIN GESTOPPT")
end)

--==============================================================
-- TIMER LOOP
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
-- STARTMELDUNG
--==============================================================

print("================================================")
print("🔥 ULTRA AUTO REJOIN GELADEN")
print("⏱️ Timer: 15 Minuten")
print("▶ Drücke START")
print("🤖 Auto Execute kompatibel")
print("================================================")
