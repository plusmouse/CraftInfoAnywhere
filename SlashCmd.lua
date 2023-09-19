CraftInfoAnywhere.SlashCmd = {}

local function ToggleOption(option, label)
  CraftInfoAnywhere.Config.Set(option, not CraftInfoAnywhere.Config.Get(option))
  if CraftInfoAnywhere.Config.Get(option) then
    print("Turned " .. BLUE_FONT_COLOR:WrapTextInColorCode(label) .. " on")
  else
    print("Turned " .. BLUE_FONT_COLOR:WrapTextInColorCode(label) .. " off")
  end
end

function CraftInfoAnywhere.SlashCmd.TogglePrices()
  ToggleOption(CraftInfoAnywhere.Config.Options.PRICES, "prices")
end
function CraftInfoAnywhere.SlashCmd.ToggleMade()
  ToggleOption(CraftInfoAnywhere.Config.Options.MADE_COUNT, "made count")
end
function CraftInfoAnywhere.SlashCmd.ToggleReagents()
  ToggleOption(CraftInfoAnywhere.Config.Options.REAGENTS, "reagents")
end
function CraftInfoAnywhere.SlashCmd.ToggleProfession()
  ToggleOption(CraftInfoAnywhere.Config.Options.PROFESSION, "profession")
end
function CraftInfoAnywhere.SlashCmd.ToggleReagentsToItems()
  ToggleOption(CraftInfoAnywhere.Config.Options.REAGENTS_TO_ITEMS, "reagents to items")
end

local COMMANDS = {
  ["prices"] = CraftInfoAnywhere.SlashCmd.TogglePrices,
  ["made"] = CraftInfoAnywhere.SlashCmd.ToggleMade,
  ["makes"] = CraftInfoAnywhere.SlashCmd.ToggleMade,
  ["reagents"] = CraftInfoAnywhere.SlashCmd.ToggleReagents,
  ["profession"] = CraftInfoAnywhere.SlashCmd.ToggleProfession,
  ["reagents_to_items"] = CraftInfoAnywhere.SlashCmd.ToggleReagentsToItems,
  ["rti"] = CraftInfoAnywhere.SlashCmd.ToggleReagentsToItems,
}

function CraftInfoAnywhere.SlashCmd.Handler(input)
  if COMMANDS[input] ~= nil then
    COMMANDS[input]()
  else
    print(BLUE_FONT_COLOR:WrapTextInColorCode("/craftinfoanywhere") .. " Valid options are '" .. BLUE_FONT_COLOR:WrapTextInColorCode("prices") .. "' (toggle the reagents value line), '" .. BLUE_FONT_COLOR:WrapTextInColorCode("made") .. "' (toggle the makes amount line), '" .. BLUE_FONT_COLOR:WrapTextInColorCode("reagents") .. "' (toggle the individual reagents needed to make the item lines), '" .. BLUE_FONT_COLOR:WrapTextInColorCode("profession") .. "' (toggle the profession required line) and '" .. BLUE_FONT_COLOR:WrapTextInColorCode("reagents_to_items") .. "' (show the items created by a given reagent)")
  end
end

SlashCmdList["CraftInfoAnywhere"] = CraftInfoAnywhere.SlashCmd.Handler
SLASH_CraftInfoAnywhere1 = "/craftinfoanywhere"
SLASH_CraftInfoAnywhere2 = "/cia"
