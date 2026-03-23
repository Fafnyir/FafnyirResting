local MAX_LEVEL = 90

-- Wait for UUF_Player to exist
local function InitFafnyirResting()
    local playerFrame = _G["UUF_Player"]
    if not playerFrame then
        C_Timer.After(0.5, InitFafnyirResting) -- try again in 0.5s
        return
    end

    -- Create our own frame and texture
    local frame = CreateFrame("Frame", "FafnyirRestingFrame", playerFrame)
    frame:SetSize(36, 36)
    frame:SetPoint("BOTTOMRIGHT", playerFrame, "TOPRIGHT", 20, -15)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)

    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetAtlas("UI-HUD-UnitFrame-Player-Rest-Flipbook")

    -- Create animation group with Flipbook matching Blizzard's exact settings:
    -- 42 frames, 7 rows, 6 columns, 1.5s duration
    local animGroup = texture:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")

    local flipbook = animGroup:CreateAnimation("Flipbook")
    flipbook:SetDuration(1.5)
    flipbook:SetOrder(1)
    flipbook:SetFlipBookFrames(42)
    flipbook:SetFlipBookRows(7)
    flipbook:SetFlipBookColumns(6)

    frame:Hide()

    -- Show/hide and play/stop our animation
    local function UpdateResting()
        if FafnyirRestingDB.hideAtMaxLevel and UnitLevel("player") >= MAX_LEVEL then
            frame:Hide()
            animGroup:Stop()
            return
        end
        if IsResting() then
            frame:Show()
            animGroup:Play()
        else
            frame:Hide()
            animGroup:Stop()
        end
    end

    -- Initial state
    UpdateResting()

    -- Watch for resting state changes
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", UpdateResting)

    -- Slash command to toggle hiding at max level
    SLASH_FAFNYIRRESTING1 = "/fafrest"
    SlashCmdList["FAFNYIRRESTING"] = function()
        FafnyirRestingDB.hideAtMaxLevel = not FafnyirRestingDB.hideAtMaxLevel
        if FafnyirRestingDB.hideAtMaxLevel then
            print("FafnyirResting: Rest icon will be hidden at max level.")
        else
            print("FafnyirResting: Rest icon will show at max level.")
        end
        UpdateResting()
    end
end

-- Initialize after login, only if UnhaltedUnitFrames is loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "FafnyirResting" then
        -- Initialize SavedVariables with defaults if first time
        FafnyirRestingDB = FafnyirRestingDB or { hideAtMaxLevel = false }
    elseif event == "PLAYER_LOGIN" then
        if not C_AddOns.IsAddOnLoaded("UnhaltedUnitFrames") then return end
        InitFafnyirResting()
    end
end)