--// ============================================================
--// 🌙 ULTRA SLEEP REJOIN
--// PERSISTENT START / STOP
--// TEST REJOIN
--// ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PLACE_ID = game.PlaceId

local REJOIN_TIME = 15 * 60
local RETRY_DELAY = 5
local MAX_RETRIES = 8

local SAVE_FILE = "SleepMode_AutoRejoin.txt"

--==============================================================
-- DATEI-FUNKTIONEN
--==============================================================

local function canFileSave()
    return type(readfile) == "function"
        and type(writefile) == "function"
end

local function saveState(enabled)

    if not canFileSave() then
        warn("⚠️ readfile/writefile wird von diesem Executor nicht unterstützt.")
        return false
    end

    local success, err = pcall(function()

        writefile(
            SAVE_FILE,
            enabled and "ON" or "OFF"
        )

    end)

    if not success then
        warn("❌ Konnte Status nicht speichern:", err)
        return false
    end

    return true
end

local function loadState()

    if not canFileSave() then
        return false
    end

    local success, result = pcall(function()

        return readfile(SAVE_FILE)

    end)

    if not success then
        return false
    end

    return result == "ON"
end

--==============================================================
-- TELEPORT-DATEN ALS ZUSÄTZLICHER FALLBACK
--==============================================================

local teleportState = false

pcall(function()

    local data = TeleportService:GetLocalPlayerTeleportData()

    if type(data) == "table" then

        if data.AutoRejoin == true then
            teleportState = true
        end

    end

end)

--==============================================================
-- STATUS LADEN
--==============================================================

local savedState = loadState()

local running = savedState or teleportState

local teleporting = false
local remaining = REJOIN_TIME

--==============================================================
-- ALTES GUI ENTFERNEN
--==============================================================

pcall(function()

    local old = CoreGui:FindFirstChild("UltraSleepRejoin")

    if old then
        old:Destroy()
    end

end)

--==============================================================
-- GUI
--==============================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "UltraSleepRejoin"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

pcall(function()
    Gui.Parent = CoreGui
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

--==============================================================
-- FRAME
--==============================================================

local Frame = Instance.new("Frame")

Frame.Size = UDim2.new(0, 310, 0, 225)
Frame.Position = UDim2.new(0.5, -155, 0.5, -112)

Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0

Frame.Parent = Gui

local Corner = Instance.new("UICorner")

Corner.CornerRadius = UDim.new(0,12)
Corner.Parent = Frame

--==============================================================
-- TITLE
--==============================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1,-20,0,35)
Title.Position = UDim2.new(0,10,0,5)

Title.BackgroundTransparency = 1

Title.Text = "🌙 ULTRA SLEEP MODE"
Title.TextColor3 = Color3.new(1,1,1)

Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

Title.Parent = Frame

--==============================================================
-- STATUS
--==============================================================

local Status = Instance.new("TextLabel")

Status.Size = UDim2.new(1,-20,0,25)
Status.Position = UDim2.new(0,10,0,42)

Status.BackgroundTransparency = 1

Status.TextSize = 13
Status.Font = Enum.Font.Gotham

Status.Parent = Frame

--==============================================================
-- TIMER
--==============================================================

local Timer = Instance.new("TextLabel")

Timer.Size = UDim2.new(1,-20,0,40)
Timer.Position = UDim2.new(0,10,0,68)

Timer.BackgroundTransparency = 1

Timer.TextColor3 = Color3.new(1,1,1)

Timer.TextSize = 27
Timer.Font = Enum.Font.GothamBold

Timer.Parent = Frame

--==============================================================
-- START
--==============================================================

local Start = Instance.new("TextButton")

Start.Size = UDim2.new(0.48,-5,0,36)
Start.Position = UDim2.new(0,10,1,-82)

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

Stop.Size = UDim2.new(0.48,-5,0,36)
Stop.Position = UDim2.new(0.52,0,1,-82)

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
-- TEST
--==============================================================

local Test = Instance.new("TextButton")

Test.Size = UDim2.new(1,-20,0,36)
Test.Position = UDim2.new(0,10,1,-40)

Test.BackgroundColor3 = Color3.fromRGB(65,95,180)

Test.Text = "🧪 TEST REJOIN"

Test.TextColor3 = Color3.new(1,1,1)

Test.TextSize = 14
Test.Font = Enum.Font.GothamBold

Test.BorderSizePixel = 0

Test.Parent = Frame

local TestCorner = Instance.new("UICorner")

TestCorner.CornerRadius = UDim.new(0,8)
TestCorner.Parent = Test

--==============================================================
-- TIME
--==============================================================

local function formatTime(seconds)

    seconds = math.max(0,math.floor(seconds))

    local minutes = math.floor(seconds/60)
    local secs = seconds % 60

    return string.format("%02d:%02d",minutes,secs)

end

--==============================================================
-- STATUS
--==============================================================

local function setStatus(text,color)

    Status.Text = "Status: "..text
    Status.TextColor3 = color

end

--==============================================================
-- TELEPORT DATA
--==============================================================

local function createOptions()

    local options = Instance.new("TeleportOptions")

    options:SetTeleportData({

        AutoRejoin = true,
        Version = 4

    })

    return options

end

--==============================================================
-- REJOIN
--==============================================================

local function rejoin()

    if teleporting then
        return
    end

    teleporting = true

    -- VOR dem Rejoin speichern!
    saveState(true)

    running = true

    setStatus(
        "Rejoin wird gestartet...",
        Color3.fromRGB(255,210,70)
    )

    Timer.Text = "REJOIN..."

    print("==========================================")
    print("🌙 SLEEP MODE REJOIN")
    print("🔒 Status gespeichert: ON")
    print("==========================================")


    for attempt = 1,MAX_RETRIES do

        if not Player or not Player.Parent then
            return
        end

        setStatus(
            "Rejoin "..attempt.."/"..MAX_RETRIES,
            Color3.fromRGB(255,210,70)
        )

        print("🚀 Versuch:",attempt)

        local success,err = pcall(function()

            TeleportService:TeleportAsync(
                PLACE_ID,
                {Player},
                createOptions()
            )

        end)

        if success then

            print("✅ Teleport-Aufruf erfolgreich")

            task.wait(RETRY_DELAY)

            if not Player.Parent then
                return
            end

        else

            warn("❌ Teleport Fehler:",err)

            task.wait(RETRY_DELAY)

        end

    end


    --==========================================================
    -- FALLBACK
    --==========================================================

    if Player and Player.Parent then

        warn("⚠️ Fallback-Rejoin")

        pcall(function()

            TeleportService:Teleport(
                PLACE_ID,
                Player
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

    -- DAUERHAFT SPEICHERN
    saveState(true)

    setStatus(
        "AKTIV",
        Color3.fromRGB(80,255,120)
    )

    Timer.Text = formatTime(remaining)

    print("==========================================")
    print("✅ AUTO REJOIN AKTIV")
    print("💾 Status gespeichert: ON")
    print("⏱️ 15 Minuten")
    print("==========================================")

end)

--==============================================================
-- STOP
--==============================================================

Stop.MouseButton1Click:Connect(function()

    running = false
    teleporting = false
    remaining = REJOIN_TIME

    -- DAUERHAFT DEAKTIVIEREN
    saveState(false)

    setStatus(
        "GESTOPPT",
        Color3.fromRGB(255,80,80)
    )

    Timer.Text = formatTime(REJOIN_TIME)

    print("==========================================")
    print("⛔ AUTO REJOIN AUS")
    print("💾 Status gespeichert: OFF")
    print("==========================================")

end)

--==============================================================
-- TEST
--==============================================================

Test.MouseButton1Click:Connect(function()

    if teleporting then
        return
    end

    -- TEST aktiviert die dauerhafte Kette
    running = true

    saveState(true)

    setStatus(
        "TEST REJOIN...",
        Color3.fromRGB(100,170,255)
    )

    Timer.Text = "TEST"

    print("==========================================")
    print("🧪 TEST REJOIN")
    print("💾 Status gespeichert: ON")
    print("==========================================")

    task.spawn(function()

        rejoin()

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
                    rejoin()
                end)

            else

                Timer.Text = formatTime(remaining)

            end

        end

    end

end)

--==============================================================
-- STARTZUSTAND
--==============================================================

if running then

    remaining = REJOIN_TIME

    setStatus(
        "AUTOMATISCH AKTIV",
        Color3.fromRGB(80,255,120)
    )

    Timer.Text = formatTime(REJOIN_TIME)

    print("==========================================")
    print("🎉 GESPEICHERTER STATUS GEFUNDEN")
    print("🔄 AUTO REJOIN WIRD FORTGESETZT")
    print("⏱️ 15:00")
    print("==========================================")

else

    setStatus(
        "BEREIT",
        Color3.fromRGB(255,210,70)
    )

    Timer.Text = formatTime(REJOIN_TIME)

    print("==========================================")
    print("🌙 SLEEP MODE GELADEN")
    print("▶ START = aktivieren")
    print("🧪 TEST = sofort testen")
    print("■ STOP = dauerhaft deaktivieren")
    print("==========================================")

end
