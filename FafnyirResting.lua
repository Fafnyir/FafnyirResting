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
end

-- Initialize after login, only if UnhaltedUnitFrames is loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    if not C_AddOns.IsAddOnLoaded("UnhaltedUnitFrames") then return end
    InitFafnyirResting()
end)