-- Wait for UUF_Player to exist
local function InitFafnyirResting()
    local playerFrame = _G["UUF_Player"]
    if not playerFrame then
        C_Timer.After(0.5, InitFafnyirResting) -- try again in 0.5s
        return
    end

    -- Blizzard's native rest indicator (found via enumeration)
    local restLoop = PlayerFrame
        and PlayerFrame.PlayerFrameContent
        and PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
        and PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop

    if not restLoop then
        print("FafnyirResting: Could not find PlayerRestLoop")
        return
    end

    -- Reparent and reposition onto our custom unit frame
    restLoop:SetParent(playerFrame)
    restLoop:ClearAllPoints()
    restLoop:SetPoint("BOTTOMRIGHT", playerFrame, "BOTTOMRIGHT", 30, 10)
    restLoop:SetSize(56, 56)
    restLoop:SetFrameStrata("MEDIUM")
    restLoop:SetFrameLevel(10)

    -- Blizzard drives all show/hide and animation automatically from here
end

-- Initialize after login
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    InitFafnyirResting()
end)