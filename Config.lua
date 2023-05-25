CraftInfoAnywhere.Config = {}

CraftInfoAnywhere.Config.Options = {
  REAGENTS = "reagents",
  PRICES = "prices",
  MADE_COUNT = "made_count",
}

CraftInfoAnywhere.Config.Defaults = {
  [CraftInfoAnywhere.Config.Options.PRICES] = true,
  [CraftInfoAnywhere.Config.Options.MADE_COUNT] = true,
  [CraftInfoAnywhere.Config.Options.REAGENTS] = true,
}

function CraftInfoAnywhere.Config.IsValidOption(name)
  for _, option in pairs(CraftInfoAnywhere.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function CraftInfoAnywhere.Config.Create(constant, name, defaultValue)
  CraftInfoAnywhere.Config.Options[constant] = name

  CraftInfoAnywhere.Config.Defaults[CraftInfoAnywhere.Config.Options[constant]] = defaultValue

  if CRAFT_INFO_ANYWHERE_CONFIG ~= nil and CRAFT_INFO_ANYWHERE_CONFIG[name] == nil then
    CRAFT_INFO_ANYWHERE_CONFIG[name] = defaultValue
  end
end

function CraftInfoAnywhere.Config.Set(name, value)
  if CRAFT_INFO_ANYWHERE_CONFIG == nil then
    error("CRAFT_INFO_ANYWHERE_CONFIG not initialized")
  elseif not CraftInfoAnywhere.Config.IsValidOption(name) then
    error("Invalid option '" .. name .. "'")
  else
    CRAFT_INFO_ANYWHERE_CONFIG[name] = value
  end
end

function CraftInfoAnywhere.Config.Reset()
  CRAFT_INFO_ANYWHERE_CONFIG = {}
  for option, value in pairs(CraftInfoAnywhere.Config.Defaults) do
    CRAFT_INFO_ANYWHERE_CONFIG[option] = value
  end
end

function CraftInfoAnywhere.Config.InitializeData()
  if CRAFT_INFO_ANYWHERE_CONFIG == nil then
    CraftInfoAnywhere.Config.Reset()
  else
    for option, value in pairs(CraftInfoAnywhere.Config.Defaults) do
      if CRAFT_INFO_ANYWHERE_CONFIG[option] == nil then
        CRAFT_INFO_ANYWHERE_CONFIG[option] = value
      end
    end
  end
end

function CraftInfoAnywhere.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if CRAFT_INFO_ANYWHERE_CONFIG == nil then
    return CraftInfoAnywhere.Config.Defaults[name]
  else
    return CRAFT_INFO_ANYWHERE_CONFIG[name]
  end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, eventName, addonName)
  if addonName == "CraftInfoAnywhere" then
    frame:UnregisterEvent("ADDON_LOADED")
    CraftInfoAnywhere.Config.InitializeData()
  end
end)
frame:RegisterEvent("ADDON_LOADED")
