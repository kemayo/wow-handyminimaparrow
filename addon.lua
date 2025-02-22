local myname, ns = ...
local myfullname = C_AddOns.GetAddOnMetadata(myname, "Title")
local db
local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

function ns.Print(...) print("|cFF33FF99".. myfullname.. "|r:", ...) end

-- can't set the default arrow to an empty string, but this is a tiny transparent texture:
local SPACER = [[Interface\Common\Spacer]]

-- events
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, event, ...)
    ns[ns.events[event]](ns, event, ...)
end)
f:Hide()
ns.events = {}
function ns:RegisterEvent(event, method)
    self.events[event] = method or event
    f:RegisterEvent(event)
end
function ns:UnregisterEvent(...) for i=1,select("#", ...) do f:UnregisterEvent((select(i, ...))) end end

local setDefaults
ns.defaults = {
    scale = 1,
    atlas = "UI-HUD-Minimap-Arrow-Player",
}

function ns:ADDON_LOADED(event, addon)
    if addon == myname then
        _G[myname.."DB"] = setDefaults(_G[myname.."DB"] or {}, ns.defaults)
        db = _G[myname.."DB"]
        ns.db = db
        self:UnregisterEvent("ADDON_LOADED")

        self.arrow = self:CreateArrow()
        Minimap:SetPlayerTexture(SPACER)
    end
end
ns:RegisterEvent("ADDON_LOADED")

function ns:CreateArrow()
    local arrow = CreateFrame("Frame", "HMAArrow", Minimap)
    arrow:SetFrameStrata("MEDIUM")
    arrow:SetPoint("CENTER")
    arrow:SetSize(10, 10)
    arrow.texture = arrow:CreateTexture(nil, "OVERLAY")
    -- arrow.texture:SetTexture([[Interface\Minimap\MinimapArrow]])
    arrow.texture:SetAtlas(db.atlas, true)
    arrow.texture:SetScale(db.scale or 1)
    arrow.texture:SetPoint("CENTER")
    arrow.texture:SetTexelSnappingBias(0)
    arrow.texture:SetSnapToPixelGrid(false)

    arrow.facing = "none"
    arrow.elapsed = 0
    arrow:SetScript("OnUpdate", function(_, t)
        arrow.elapsed = arrow.elapsed + t
        if arrow.elapsed < 0.05 then return end
        arrow.elapsed = 0

        if GetCVar("rotateMinimap") == "1" then
            arrow.texture:SetRotation(0)
            return
        end
        local facing = GetPlayerFacing()
        if facing == arrow.facing then return end
        if facing then
            if arrow.facing == nil then
                Minimap:SetPlayerTexture(SPACER)
            end
            arrow.facing = facing
            arrow.texture:SetRotation(facing)
            arrow.texture:Show()
        else
            -- Somewhere this is protected, hide so any arrow at all is visible
            Minimap:SetPlayerTexture([[Interface\AddOns\HandyMinimapArrow\MinimapArrow2x.png]])
            arrow.facing = nil
            arrow.texture:Hide()
        end
    end)

    arrow:Show()

    return arrow
end

--

function setDefaults(options, defaults)
    setmetatable(options, { __index = function(t, k)
        if type(defaults[k]) == "table" then
            t[k] = setDefaults({}, defaults[k])
            return t[k]
        end
        return defaults[k]
    end, })
    -- and add defaults to existing tables
    for k, v in pairs(options) do
        if defaults[k] and type(v) == "table" then
            setDefaults(v, defaults[k])
        end
    end
    return options
end
