local textMapping = {
    -- HUVUDKNAPPAR
    ["1"] = "|cff00ff00[A]|r", ["2"] = "|cffff0000[B]|r", 
    ["3"] = "|cff5555ff[X]|r", ["4"] = "|cffffff00[Y]|r", 

    -- D-PAD
    ["5"] = "|cffffffcc[^]|r", ["6"] = "|cffffffcc[v]|r", 
    ["7"] = "|cffffffcc[<]|r", ["8"] = "|cffffffcc[>]|r", 

    -- R4 MODIFIER (Shift)
    ["s-1"] = "|cff00ff00R4+A|r", ["s-2"] = "|cffff0000R4+B|r",
    ["s-3"] = "|cff5555ffR4+X|r", ["s-4"] = "|cffffff00R4+Y|r",
    ["s-5"] = "|cffffffccR4+^|r", ["s-6"] = "|cffffffccR4+v|r",
    ["s-7"] = "|cffffffccR4+<|r", ["s-8"] = "|cffffffccR4+>|r",

    -- R5 MODIFIER (Ctrl)
    ["c-1"] = "|cff00ff00R5+A|r", ["c-2"] = "|cffff0000R5+B|r",
    ["c-3"] = "|cff5555ffR5+X|r", ["c-4"] = "|cffffff00R5+Y|r",
    ["c-5"] = "|cffffffccR5+^|r", ["c-6"] = "|cffffffccR5+v|r",
    ["c-7"] = "|cffffffccR5+<|r", ["c-8"] = "|cffffffccR5+>|r",
}

local function ApplySteamDeckText()
    for bar=1, 6 do
        for btnIdx=1, 12 do
            local buttonName = "pfActionBar"..bar.."Button"..btnIdx
            local hotkey = getglobal(buttonName.."HotKey")
            if hotkey then
                local txt = hotkey:GetText()
                if txt and textMapping[txt] then
                    hotkey:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
                    hotkey:SetText(textMapping[txt])
                    hotkey:SetAlpha(1)
                    hotkey:Show()
                end
            end
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:SetScript("OnEvent", function()
    local elapsed = 0
    f:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed > 0.5 then
            ApplySteamDeckText()
            f:SetScript("OnUpdate", nil)
        end
    end)
end)
