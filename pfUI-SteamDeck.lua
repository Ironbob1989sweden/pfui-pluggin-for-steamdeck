local addonName = "pfUI-SteamDeck"
local iconPath = "Interface\\AddOns\\" .. addonName .. "\\tga\\"

-- 1. INITIALIZE CONFIG (Nu med 'true' som standard för show_icons)
pfUI_config = pfUI_config or {}
pfUI_config.pfsd = pfUI_config.pfsd or {}
if pfUI_config.pfsd.show_icons == nil then pfUI_config.pfsd.show_icons = true end
if pfUI_config.pfsd.icon_size == nil then pfUI_config.pfsd.icon_size = 14 end

local iconSize = pfUI_config.pfsd.icon_size

-- 2. UPDATE BUTTON FUNCTION
local function UpdateButton(btn, iconFile, modFile)
    if not btn or not btn:GetName() then return end

    local mainTex = getglobal(btn:GetName().."FinalMain") or btn:CreateTexture(btn:GetName().."FinalMain", "OVERLAY")
    local modTex = getglobal(btn:GetName().."FinalMod") or btn:CreateTexture(btn:GetName().."FinalMod", "OVERLAY")

    -- Hide default pfUI hotkey text
    local hk = getglobal(btn:GetName().."HotKey")
    if hk then hk:SetAlpha(0) end

    -- GLOBAL TOGGLE: If "Show Icons" is unchecked, hide everything and stop
    if not pfUI_config.pfsd.show_icons then
        mainTex:Hide()
        modTex:Hide()
        return
    end

    -- Draw Modifier (R4/R5)
    if modFile then
        modTex:SetTexture(iconPath .. modFile .. ".tga")
        modTex:SetWidth(iconSize)
        modTex:SetHeight(iconSize)
        modTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        modTex:Show()
    else
        modTex:Hide()
    end

    -- Draw Primary Button (A/B/X/Y)
    if iconFile then
        mainTex:SetTexture(iconPath .. iconFile .. ".tga")
        mainTex:SetWidth(iconSize)
        mainTex:SetHeight(iconSize)
        mainTex:ClearAllPoints()
        if modFile then
            mainTex:SetPoint("RIGHT", modTex, "LEFT", 0, 0)
        else
            mainTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        end
        mainTex:Show()
    else
        mainTex:Hide()
    end
end

local buttonIcons = {
    [1] = "y", [2] = "x", [3] = "a", [4] = "b",
    [5] = "up", [6] = "left", [7] = "down", [8] = "right",
}

local function Refresh()
    iconSize = pfUI_config.pfsd.icon_size
    for i=1, 12 do
        local m = getglobal("pfActionBarMainButton"..i)
        local l = getglobal("pfActionBarLeftButton"..i)
        local t = getglobal("pfActionBarTopButton"..i)

        if m then UpdateButton(m, buttonIcons[i], nil) end
        if l then UpdateButton(l, buttonIcons[i], "r5") end
        if t then UpdateButton(t, buttonIcons[i], "r4") end
    end
end

-- 3. CREATE SETTINGS WINDOW
local settings = CreateFrame("Frame", "PFSD_Settings", UIParent)
settings:SetWidth(220)
settings:SetHeight(280)
settings:SetPoint("CENTER", 0, 0)
settings:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
settings:SetBackdropColor(0, 0, 0, 0.9)
settings:SetMovable(true)
settings:EnableMouse(true)
settings:RegisterForDrag("LeftButton")
settings:SetScript("OnDragStart", function() this:StartMoving() end)
settings:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
settings:Hide()

-- Title
local title = settings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Steam Deck Settings")

-- Close Button
local close = CreateFrame("Button", nil, settings, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 2, 2)
close:SetScript("OnClick", function() settings:Hide() end)

-- CHECKBOX: SHOW ICONS
local check = CreateFrame("CheckButton", "PFSD_ShowIconsCheck", settings, "UICheckButtonTemplate")
check:SetPoint("TOPLEFT", 20, -40)
getglobal(check:GetName() .. 'Text'):SetText(" Show Action Bar Icons")
check:SetChecked(pfUI_config.pfsd.show_icons)
check:SetScript("OnClick", function()
    pfUI_config.pfsd.show_icons = this:GetChecked()
    Refresh()
end)

-- SLIDER: SIZE
local slider = CreateFrame("Slider", "PFSD_Slider", settings, "OptionsSliderTemplate")
slider:SetPoint("TOP", 0, -100)
slider:SetWidth(160)
slider:SetMinMaxValues(10, 40)
slider:SetValueStep(1)
slider:SetValue(iconSize)
getglobal(slider:GetName() .. 'Text'):SetText("Icon Size: " .. iconSize)
slider:SetScript("OnValueChanged", function()
    local val = math.floor(this:GetValue())
    getglobal(this:GetName() .. 'Text'):SetText("Icon Size: " .. val)
    pfUI_config.pfsd.icon_size = val
    Refresh()
end)

-- BUTTON: BINDS
local bindBtn = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
bindBtn:SetWidth(180)
bindBtn:SetHeight(25)
bindBtn:SetPoint("TOP", 0, -150)
bindBtn:SetText("Update Key binds")
bindBtn:SetScript("OnClick", function()
    for i=1, 8 do
        SetBinding("SHIFT-"..i, "MULTIACTIONBAR1BUTTON"..i)
        SetBinding("CTRL-"..i, "MULTIACTIONBAR2BUTTON"..i)
    end
    SaveBindings(GetCurrentBindingSet())
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Binds updated!")
end)

-- BUTTON: EXPORT
local exportBtn = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
exportBtn:SetWidth(180)
exportBtn:SetHeight(25)
exportBtn:SetPoint("TOP", bindBtn, "BOTTOM", 0, -10)
exportBtn:SetText("Copy pfUI Profile")

local exportBox = CreateFrame("EditBox", "PFSD_ExportBox", settings)
exportBox:SetHeight(20) exportBox:SetWidth(170)
exportBox:SetPoint("TOP", exportBtn, "BOTTOM", 0, -10)
exportBox:SetFontObject(GameFontHighlightSmall)
exportBox:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
exportBox:SetBackdropColor(0,0,0,1)
exportBox:SetText("Y3AAZgBVAEkAXwBjAG8AbgBmAGkAZwAgAD0AIAB7AAoAIAAgAFsAIgBkAGkAcwBhAGIAbABlAGQAIgBdAAsBDQEPARAB
EQEiAHQAbwB0AGUAbQBzABwBHgEiADAAIgAsACABEAESAXAAaQB4AGUAbABwAGUAcgBmAGUAYwB0ACoBDAEsAS4BMAEi
AXMAawBpAG4AXwBNADkBYwBoAGEAbgA+AR0BQAEtAS8BIQFEAUYBSAFPAHAAdABpAAYBcwAgAC0AIABTAG8AdQBuABsB
UQEgAEEBVAEhARIBRQFHAV8AWQFbAV0BXwEgAFYAaQBkAGUAbwA/AWgBUwFDARIBZAFsAG8AYwBrAHoBaQF9ASIABQFt
AGIAbwBwAG8ARwF0ACkBZwGFAVUBEgEFAW8AbABkAG8AdwBuAIQBfAGTASIAgAElAZwBQgGeATsBCQFlAWUAYQB0AGgA
ogFqATEBIwFhAHIAZwBlAFABKwGdAWsBIgBtAVgBWgFcAW4AXgFgAU4AZQB3AKwBhgG5AV8ARQB2ADkBoAFrACAAQgBy
AG8AYQBkAGMAYQBzAFsBbgBnAMMBngFzAIEBaQBhAGwAbQBvAGYBtQGjAbcBbQBhAHAA2AG3AWEAPQG8AWIAsAHoAa4B
xQFUAHIAYQBHATkB7wFWAW4BQgCwAWIAOQFzAGgAiwH3AWwBVwFfAFAAzgE7AXMAcwC8AQECIwFvAJYBWwHnAZEBtgHw
AQMCVADdAWUATwGQAeIBrQEiAQgBcgDUAXIAZAELAmgAZABnAPMBcABoAGkAYwCEATEA4wGuAXAAbABhAHkA9gERAi0C
+AFIAUcAbwAIAmkAcAAgAE4BZAAgAFEAdQBlANQBCwJ1AHAAZACpARcCJQFpAGYAeQAiAmQBJgFyAO0BcgALAsUBUgD0
AWQAAgFFAm4AaQB0AHgAEAIaAsQBAwJBAikCawBIAKgBbABVAgMCUACLAUYCIABEANwBgAFnABkCUgE1AgICbgFDAJYB
bwByACAAUABlAjMCYQKeAWIAdQBmAGYAdwCpAUwBagJ4Ak0B8wE9AYACdQIbAhIB5QFwAHIAZQDIAd0BCwLtAXMCKwJ2
ArgBAwL6AXMCaAB1AGkACwJMAakBCwJhAHUAJAH+AUwCtAGQAmICbgFEAJUCCAIgAFUAPAJGAPMBbQBlAAsCdAB1AHIA
dAAZAS0AdwCZAYoCSAH6AXQAwAJlAAgBNgHhAa8CngGqAWkAcgBkAHAAsAF0AHkALQB2AE4BaQBsADACCwLzAXYBxQJf
AEkAvQE4AT0BIgJvAMgBUgJHAc0CewGdAmYAgQF1AHQC7QKRAp4CbgFQALMBXQIKAjQC9ALFAUcAowKXASAAUgBlAGcA
FQF0APMBVAL7ArACSAFTAHQA6gHLAVMALwJdAuECZwI3AeECVAC+AskCYQH/AWACzgK3AQ0DsQGzAR8DsgGuAvMCxAE2
AWwA2QJsAEICFgPzAb0B3wHXAQkD2QEDAlkB6gFdAk4CMQO3AWIAcwIFAZUC4QJBAHUA6wEGAf8B8QK7AjgDEwJuARcD
JAFyAHEC4QJwAbwBvgEgAOMCUQJmAOoBRQOBAuQB0QLOAb8CaQC6Ah4C4QJNAOoBzgFVAowCVgMdA0cDSAH3AnQAYQEN
AxgBZQAgAGAD1AGPAiUDggKEAmYAqAKqAugCFwKYAQgDVwOuAYMCYgBtA/ICkgG3AfEBGAMZAWAD2wLhAkIADQJrAIID
EgIiAagBcQOVAmcAMAN9AzYCXwB5AkcBfQJlAkYCigOpAckCywIAA00ARwFcA+YBRQJmAF8AvQJrAKMCxQIsA9ABZQNz
A7cBJQJ5ACcCXQELAm4AYQBtAIwBdwByA4MDrgGAAdIBcQFuAC8C8QILAkcBCAFnAGgAJAO+A5cDuAJpAHoDjgOdAl8C
UwKoAmQAmAG9AdUD1wODAsgCtgNGAyIB5QFjAM4BdAC8A2EAgwHeA34BbgDxAhcBGQEWA4YDbgNMAEYAVAC8AigC0gLU
Ar8CNwOWAxIBdwAoAnMAOAFyAJQCbwB4APgDZgOXA0cAuQNuA0oB6QPhAksAZQB5AEIA6wJHAZsC5wMiAGcAbQALApMC
BQGAAV4DEwRlAHEAiAH2A7ADzAMSARcCOQFnAHkAWwGCAVUC4QNlABcC/gGhARME0AHXAx8EpwITBM4B3ALhAkECQwJq
A0wAbwCVAwQEEgElAmMBHAOxA64BVANyAG0A3wF3AQsCOAHLA48DkgKkA5MCFwRjAXMAeAHpAgsCcQBCAtQBXQInAZkC
IQM5ASQBJgEoAeEC/gLbAj8CFQJTAuwCIgT1AsYCnwMZAaEDPwJTADwDIQROBGsEXwAQAycDigFvAOYD+QOHAU0BdAAF
AXAAAwREBJcDOQTUASAAVABcA70DdATUAm4ANgHZA10BVwGNBHwDPwQiALgDugIvAkkCggMsAvQC0gHUAdQDEwTFAYgD
bACKAXgAvAKwASMDIgMhA6cEswFLBKoEIANNBJ0CxQFGAGwACQHKA+UBkgPGA2EEYwC0BCkEMARmAGsA0gEWBBMEYwDx
AiQBwgR8BFYCqAFkAHkATAE8AXsElARzAEYCOQHDAsIBoAQUAg0CbAAPAtED9AIGAw4DEQRjBE0AYQG+AsgBggSDA30A
agGUAX4EegEOAZ4BZwCAAe0BaQJnAewEVQEiAYoB0gKKBC4AMQAsADAA+QT7BP0E/AQ1ADUCrgHEBNQBbwCJAT4EaAGb
BEMBfgMOA0EEZAFpBPwE+gQRBf4EEgUuADIANQLnBIYBJgF4ACQD8wSeAUcBcACqAl8AdwB2AaoBhAEzADAAjwMZBZ4B
SwPJAx0FCwWQA7gDbQOcAhsCKwUgADYFMgFmAHMA7AIeBSIBKQIGAV8ACQJ6ALADMQA0AGoBOAWfAYEBxAPyAj0FIwQy
BRkBRwGIAe0BywMKBSwFtQR/BA0C0gJHAUkCZgC5AsEBJQWrAZEBMgA3AJ0CbgR0AEgCDQOMBMwCqQFJAhwFhAFkAL4C
FwHbAjYDnQIXAusDswEtA/0DsAEXAlQFZQWBAakBvAFdBQcEaABlAFcFKwJkBfQCZgVoBeYBTgE2ASQFZAAmBZEBMQAp
BXUFTwU5ATwBBgW6AqcBZAB6AAYBQwI0BYYBLQXKA4sFagVsAIQFhgWSBTMAnQIZBHsCGgHUAakB8QLAA4AFBgELAnYF
bQOkA70BDQNuAGMAIQRVBbcBZgWVAVoFuAMmAYIFugKnBS4FKwKqBfQCogVnBWwFpQWLBRsFywNbAboCfgXBA4EFXgWP
BZEFKwFjBXQEwAVZBRQBwwXKAl4FtgXsA5IFZQXKAlgFewLgBVwF2AVgBYQBYwWVBXcF/gHQAcQC5gXLBVcFwQXrBcQF
XgXHBcoDyQWdAswF+QVbBfsFBwTkBb0FAAZXBaQFjQUZAZYFoAWeAYoFzgULBv0FVAXKBYYBBgaVAogBmgV3AeAFrwW7
BZ8F9gWGARAGaQULBgYGDga3AcwFCgaNBGwA2QVhBSsBkwW2AUgFUwJMBYYBUwKqBfIEMAUSAe8CRwRUAz0BewIrAiAA
eAAgADEAFwUbAq4BZAGWAhcChAFEAJkBmwE1BfQCUwI4AOsEOAYiAEcGyAGbAZEBSwaaARgFTwawATkAUgb0BCIBVQZJ
BlgGTAZbBjQGsAEsAjcGYAZsAf8BdwBrAA0EYgDrAvcBfgOqAiQB2AORAVEGRQY+BQUBSAFCBSEEKAUCBWEGjQRWBkoG
ZQZOBoYBbwZ5AJgBWgYgBoICsAFkBWoG9AToA0gGVwYrAVkGTQZDATYFDAVyAEMGXwaSBlQGgwZjBpYGhgaZBlwGnAYt
AZEGngFiBpUGQAGXBmYGjgZyABcFqQa3AasGhQZaBocGsAY2AJ4G2QFtBokGcQZlAXMG9QR1Bt0DKwF5BlMGPwV9BmkA
QwUnBY8DRgahBqwGaAGuBrgGOQOwAQEFswbwAb0GcAZyBt4DdAbcA3cGxQaBBhIByAZBBcoGfwbNBhwCewJtADwGSgMr...")
exportBox:SetScript("OnEditFocusGained", function() this:HighlightText() end)
exportBox:Hide()

exportBtn:SetScript("OnClick", function()
    if exportBox:IsShown() then exportBox:Hide() else exportBox:Show() exportBox:SetFocus() end
end)

-- 4. SLASH COMMAND
SLASH_PFSD1 = "/pfsd"
SlashCmdList["PFSD"] = function()
    if settings:IsShown() then settings:Hide() else settings:Show() end
end

-- 5. REFRESH LOOP
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
    this.elapsed = (this.elapsed or 0) + arg1
    if this.elapsed > 2 then
        Refresh()
        this.elapsed = 0
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Loaded. Type /pfsd for settings.")
