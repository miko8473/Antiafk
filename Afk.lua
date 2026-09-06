--// ============================================================
--// 🌙 SLEEP MODE - PERSISTENT AUTO REJOIN
--// ============================================================
--//
--// START:
--//   Aktiviert die automatische Rejoin-Kette.
--//
--// TEST REJOIN:
--//   Führt sofort einen Rejoin durch.
--//
--// REJOIN:
--//   Übergibt AutoRejoin=true an den nächsten Server.
--//
--// NACH DEM JOIN:
--//   Auto Execute startet das Script erneut.
--//   GetLocalPlayerTeleportData() liest AutoRejoin=true.
--//   Timer startet automatisch wieder.
--//
--// STOP:
--//   Deaktiviert die automatische Kette.
--//
--// Hinweis:
--//   Roblox/Delta können keine 100%-Garantie für Teleports geben.
--// ============================================================


--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PLACE_ID = game.PlaceId


--==============================================================
-- SETTINGS
--==============================================================

local REJOIN_TIME = 15 * 60

local RETRY_DELAY = 5
local MAX_RETRIES = 8

local TELEPORT_FLAG = "AutoRejoin"
local VERSION = 3


--==============================================================
-- TELEPORT DATA
--==============================================================

local cameFromAutoRejoin = false

pcall(function()

    local data = TeleportService:GetLocalPlayerTeleportData()

    if type(data) == "table" then

        if data[TELEPORT_FLAG] == true
            and data.Version == VERSION then

            cameFromAutoRejoin = true

        end

    end

end)


--==============================================================
-- VARIABLES
--==============================================================

local running = cameFromAutoRejoin
local teleporting = false
local remaining = REJOIN_TIME


--==============================================================
-- REMOVE OLD GUI
--==============================================================

pcall(function()

    local old = CoreGui:FindFirstChild("SleepModeAutoRejoin")

    if old then
        old:Destroy()
    end

end)


--==============================================================
-- GUI
--==============================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "SleepModeAutoRejoin"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    Gui.Parent = CoreGui
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end


--==============================================================
-- MAIN FRAME
--==============================================================

local Frame = Instance.new("Frame")

Frame.Name = "Main"
Frame.Size = UDim2.new(0, 300, 0, 215)
Frame.Position = UDim2.new(0.5, -150, 0.5, -107)

Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0

Frame.Parent = Gui


local FrameCorner = Instance.new("UICorner")

FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame


local FrameStroke = Instance.new("UIStroke")

FrameStroke.Thickness = 1
FrameStroke.Transparency = 0.4

FrameStroke.Parent = Frame


--==============================================================
-- TITLE
--==============================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)

Title.BackgroundTransparency = 1

Title.Text = "🌙 SLEEP MODE"
Title.TextColor3 = Color3.new(1, 1, 1)

Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

Title.Parent = Frame


--==============================================================
-- STATUS
--==============================================================

local Status = Instance.new("TextLabel")

Status.Size = UDim2.new(1, -20, 0, 24)
Status.Position = UDim2.new(0, 10, 0, 40)

Status.BackgroundTransparency = 1

Status.TextSize = 13
Status.Font = Enum.Font.Gotham

Status.Parent = Frame


--==============================================================
-- TIMER
--==============================================================

local Timer = Instance.new("TextLabel")

Timer.Size = UDim2.new(1, -20, 0, 40)
Timer.Position = UDim2.new(0, 10, 0, 67)

Timer.BackgroundTransparency = 1

Timer.TextColor3 = Color3.new(1, 1, 1)

Timer.TextSize = 27
Timer.Font = Enum.Font.GothamBold

Timer.Parent = Frame


--==============================================================
-- START BUTTON
--==============================================================

local Start = Instance.new("TextButton")

Start.Size = UDim2.new(0.48, -5, 0, 36)
Start.Position = UDim2.new(0, 10, 1, -82)

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
-- STOP BUTTON
--==============================================================

local Stop = Instance.new("TextButton")

Stop.Size = UDim2.new(0.48, -5, 0, 36)
Stop.Position = UDim2.new(0.52, 0, 1, -82)

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
-- TEST BUTTON
--==============================================================

local Test = Instance.new("TextButton")

Test.Size = UDim2.new(1, -20, 0, 36)
Test.Position = UDim2.new(0, 10, 1, -40)

Test.BackgroundColor3 = Color3.fromRGB(65, 95, 180)

Test.Text = "🧪 TEST REJOIN"

Test.TextColor3 = Color3.new(1, 1, 1)

Test.TextSize = 14
Test.Font = Enum.Font.GothamBold

Test.BorderSizePixel = 0

Test.Parent = Frame


local TestCorner = Instance.new("UICorner")

TestCorner.CornerRadius = UDim.new(0, 8)
TestCorner.Parent = Test


--==============================================================
-- FORMAT TIME
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
-- CREATE TELEPORT DATA
--==============================================================

local function getTeleportData()

    return {

        [TELEPORT_FLAG] = true,

        Version = VERSION,

        Timestamp = os.time()

    }

end


--==============================================================
-- REJOIN
--==============================================================

local function Rejoin()

    if teleporting then
        return
    end

    teleporting = true

    -- Ganz wichtig:
    -- Vor jedem Rejoin wird der Zustand auf aktiv gesetzt.
    -- Dadurch soll der nächste Server wieder automatisch
    -- in den 15-Minuten-Modus gehen.

    running = true

    setStatus(
        "Rejoin wird gestartet...",
        Color3.fromRGB(255, 210, 70)
    )

    Timer.Text = "REJOIN..."

    print("==============================================")
    print("🌙 SLEEP MODE")
    print("🔄 REJOIN")
    print("📍 PlaceId:", PLACE_ID)
    print("🔒 AutoRejoin = TRUE")
    print("==============================================")


    --==========================================================
    -- RETRY LOOP
    --==========================================================

    for attempt = 1, MAX_RETRIES do

        if not Player or not Player.Parent then
            return
        end


        setStatus(
            "Rejoin " .. attempt .. "/" .. MAX_RETRIES,
            Color3.fromRGB(255, 210, 70)
        )


        print(
            "🚀 Teleport Versuch "
            .. attempt
            .. "/"
            .. MAX_RETRIES
        )


        local success, errorMessage = pcall(function()

            -- CLIENT-SAFE TELEPORT
            --
            -- Die Teleport-Daten werden direkt mitgegeben.
            -- Der nächste Client kann sie über
            -- GetLocalPlayerTeleportData() lesen.

            TeleportService:Teleport(
                PLACE_ID,
                Player,
                getTeleportData()
            )

        end)


        if success then

            print("✅ Teleport-Aufruf erfolgreich")

            -- Wir warten, damit Roblox den Teleport
            -- durchführen kann.

            task.wait(RETRY_DELAY)


            -- Wenn wir noch im alten Server sind,
            -- versuchen wir es erneut.

            if not Player.Parent then
                return
            end

        else

            warn("❌ Teleport fehlgeschlagen:")
            warn(errorMessage)

            task.wait(RETRY_DELAY)

        end

    end


    --==========================================================
    -- FINAL FALLBACK
    --==========================================================

    if Player and Player.Parent then

        warn("⚠️ Normale Teleport-Versuche fehlgeschlagen.")
        warn("🔁 Letzter Versuch...")


        pcall(function()

            TeleportService:Teleport(
                PLACE_ID,
                Player,
                getTeleportData()
            )

        end)

    end

end


--==============================================================
-- START
--==============================================================

Start.MouseButton1Click:Connect(function()

    if running or teleporting then
        return
    end


    running = true

    remaining = REJOIN_TIME


    setStatus(
        "Aktiv",
        Color3.fromRGB(80, 255, 120)
    )


    Timer.Text = formatTime(remaining)


    print("==============================================")
    print("✅ SLEEP MODE AKTIV")
    print("⏱️ 15 Minuten")
    print("🔄 Danach automatischer Rejoin")
    print("==============================================")

end)


--==============================================================
-- STOP
--==============================================================

Stop.MouseButton1Click:Connect(function()

    running = false
    teleporting = false

    remaining = REJOIN_TIME


    setStatus(
        "Gestoppt",
        Color3.fromRGB(255, 80, 80)
    )


    Timer.Text = formatTime(REJOIN_TIME)


    print("==============================================")
    print("⛔ SLEEP MODE GESTOPPT")
    print("==============================================")

end)


--==============================================================
-- TEST REJOIN
--==============================================================

Test.MouseButton1Click:Connect(function()

    if teleporting then
        return
    end


    -- Der Test aktiviert die Kette ebenfalls.
    running = true

    remaining = 0


    setStatus(
        "TEST REJOIN...",
        Color3.fromRGB(100, 170, 255)
    )


    Timer.Text = "TEST"


    print("==============================================")
    print("🧪 TEST REJOIN")
    print("🔒 AutoRejoin = TRUE")
    print("🔄 Sofortiger Rejoin")
    print("==============================================")


    task.spawn(function()

        Rejoin()

    end)

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

                remaining = REJOIN_TIME

                task.spawn(function()

                    Rejoin()

                end)

            else

                Timer.Text = formatTime(remaining)

            end

        end

    end

end)


--==============================================================
-- INITIAL STATE
--==============================================================

if cameFromAutoRejoin then

    running = true
    remaining = REJOIN_TIME


    setStatus(
        "Nach Rejoin automatisch aktiv",
        Color3.fromRGB(80, 255, 120)
    )


    Timer.Text = formatTime(REJOIN_TIME)


    print("==============================================")
    print("🎉 AUTO REJOIN ERKANNT")
    print("✅ STATUS WIEDERHERGESTELLT")
    print("⏱️ NEUER TIMER: 15:00")
    print("==============================================")


else

    setStatus(
        "Bereit",
        Color3.fromRGB(255, 210, 70)
    )


    Timer.Text = formatTime(REJOIN_TIME)


    print("==============================================")
    print("🌙 SLEEP MODE GELADEN")
    print("▶ START = aktivieren")
    print("🧪 TEST = sofort testen")
    print("■ STOP = deaktivieren")
    print("==============================================")

end
