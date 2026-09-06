--==============================================================
-- 🧪 TEST REJOIN BUTTON
--==============================================================

local Test = Instance.new("TextButton")
Test.Position = UDim2.new(0, 10, 1, -95)
Test.Size = UDim2.new(1, -20, 0, 35)
Test.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
Test.Text = "🧪 TEST REJOIN"
Test.TextColor3 = Color3.new(1, 1, 1)
Test.TextSize = 13
Test.Font = Enum.Font.GothamBold
Test.BorderSizePixel = 0
Test.Parent = Frame

local TestCorner = Instance.new("UICorner")
TestCorner.CornerRadius = UDim.new(0, 8)
TestCorner.Parent = Test

--==============================================================
-- TEST
--==============================================================

Test.MouseButton1Click:Connect(function()

    if teleporting then
        return
    end

    -- Wichtig:
    -- Test verhält sich genauso wie ein echter Timer-Rejoin.
    running = true
    sharedState.UltraAutoRejoinActive = true

    print("========================================")
    print("🧪 TEST REJOIN")
    print("🔄 Rejoin wird sofort ausgeführt")
    print("🔒 AutoRejoin bleibt aktiviert")
    print("========================================")

    Rejoin()
end)
