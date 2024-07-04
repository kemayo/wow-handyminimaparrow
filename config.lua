local myname, ns = ...
local myfullname = C_AddOns.GetAddOnMetadata(myname, "Title")

local scale, atlas

local frame = CreateFrame("Frame")
frame.OnCommit = function() end
frame.OnDefault = function() end
frame.OnRefresh = function() end
frame:Hide()

local category, layout = Settings.RegisterCanvasLayoutCategory(frame, myfullname)
category.ID = myname
layout:AddAnchorPoint("TOPLEFT", 10, -10)
layout:AddAnchorPoint("BOTTOMRIGHT", -10, 10)

do
    local slider = CreateFrame("Frame", nil, frame, "MinimalSliderWithSteppersTemplate")
    slider.Slider:SetWidth(250)
    slider.Slider:ClearAllPoints()
    slider.Slider:SetPoint("LEFT", slider, "CENTER", -80, 3)
    slider.Text = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slider.Text:SetJustifyH("LEFT")
    slider.Text:SetText(UI_SCALE)
    slider.Text:SetPoint("LEFT", slider, 37, 0)
    -- slider.Text:SetPoint("LEFT", slider, (15 + 37), 0) -- indent variant
    slider.Text:SetPoint("RIGHT", slider, "CENTER", -85, 0)
    slider:SetSize(280, 26)

    local options = Settings.CreateSliderOptions(0.5, 3, 0.1)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return string.format("%.1f", value) end)
    slider:Init(1, options.minValue, options.maxValue, options.steps, options.formatters)

    slider:SetPoint("TOPLEFT", frame)
    slider:SetPoint("RIGHT", frame)

    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
        ns.db.scale = value
        ns.arrow.texture:SetScale(ns.db.scale)
    end)

    scale = slider
end

do
    local values = {
        ["minimaparrow"] = "Classic minimap",
        ["UI-HUD-Minimap-Arrow-Player"] = "Default minimap",
        ["UI-HUD-Minimap-Arrow-Corpse"] = "Corpse",
        ["UI-HUD-Minimap-Arrow-QuestTracking"] = "Quest tracking",
        ["UI-HUD-Minimap-Arrow-Vignettes"] = "Vignette",
        ["UI-HUD-Minimap-Arrow-GenericDistantPOI"] = "Short default",
        ["UI-HUD-Minimap-Arrow-Group"] = "Short group",
        ["UI-HUD-Minimap-Arrow-Guard"] = "Short guard",
    }
    local dropdown = CreateFrame("Frame", nil, frame)
    -- HandyMinimapArrowOptionsAtlasDropdown
    dropdown.Dropdown = CreateFrame("Frame", myname .. "OptionsAtlasDropdown", dropdown, "UIDropDownMenuTemplate")
    dropdown.Dropdown:SetPoint("LEFT", dropdown, "CENTER", -110, 3)
    dropdown.Dropdown:HookScript("OnShow", function()
        if dropdown.initialize then return end
        UIDropDownMenu_Initialize(dropdown.Dropdown, function(frame)
            for k, v in pairs(values) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = v .. " " .. CreateAtlasMarkup(k)
                info.value = k
                info.func = function(self)
                    ns.db.atlas = self.value
                    ns.arrow.texture:SetAtlas(ns.db.atlas, true)
                    UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, self.value)
                end
                UIDropDownMenu_AddButton(info)
            end
            UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, ns.db and ns.db.atlas or ns.defaults.atlas)
        end)
    end)
    UIDropDownMenu_SetWidth(dropdown.Dropdown, 280)
    UIDropDownMenu_SetFrameStrata(dropdown.Dropdown, "FULLSCREEN_DIALOG")

    dropdown.Text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdown.Text:SetJustifyH("LEFT")
    dropdown.Text:SetText(TEXTURES_SUBHEADER)
    dropdown.Text:SetPoint("LEFT", dropdown, 37, 0)
    -- slider.Text:SetPoint("LEFT", dropdown, (15 + 37), 0) -- indent variant
    dropdown.Text:SetPoint("RIGHT", dropdown, "CENTER", -85, 0)
    
    dropdown:SetSize(280, 26)
    dropdown:SetPoint("TOPLEFT", scale, "BOTTOMLEFT", 0, -4)
    dropdown:SetPoint("RIGHT", frame)

    atlas = dropdown
end

Settings.RegisterAddOnCategory(category)

-- Settings.OpenToCategory(myname)

do return end

-- if settings are fixed to not SUPERTAINT, I could just do this:

local category = Settings.RegisterVerticalLayoutCategory(myfullname)

do
    local variable = "scale"
    local name = UI_SCALE -- "UI Scale"
    local tooltip = "Adjust the size of the minimap arrow"
    local defaultValue = ns.defaults.scale
    local minValue = 0.2
    local maxValue = 2
    local step = 0.1

    local setting = Settings.RegisterProxySetting(category, variable, ns.db, type(defaultValue), name, defaultValue)
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, setting, options)
end

do
    local variable = "atlas"
    local defaultValue = ns.defaults.atlas
    local name = TEXTURES_SUBHEADER -- "Textures"
    local tooltip = "Change the texture used for the minimap arrow"

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("minimaparrow", "Classic minimap")
        container:Add("UI-HUD-Minimap-Arrow-Player", "Default minimap")
        container:Add("UI-HUD-Minimap-Arrow-Corpse", "Corpse")
        container:Add("UI-HUD-Minimap-Arrow-QuestTracking", "Quest tracking")
        container:Add("UI-HUD-Minimap-Arrow-Vignettes", "Vignette")
        container:Add("UI-HUD-Minimap-Arrow-GenericDistantPOI", "Short default")
        container:Add("UI-HUD-Minimap-Arrow-Group", "Short group")
        container:Add("UI-HUD-Minimap-Arrow-Guard", "Short guard")
        -- container:Add("", "")
        return container:GetData()
    end

    local setting = Settings.RegisterProxySetting(category, variable, ns.db, type(defaultValue), name, defaultValue)
    Settings.CreateDropDown(category, setting, GetOptions, tooltip)
end

Settings.RegisterAddOnCategory(category)
