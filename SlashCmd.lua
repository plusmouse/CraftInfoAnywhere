CraftInfoAnywhere.SlashCmd = {}

local function ToggleOption(option, label)
  CraftInfoAnywhere.Config.Set(option, not CraftInfoAnywhere.Config.Get(option))
  if CraftInfoAnywhere.Config.Get(option) then
    print("Turned " .. label .. " on")
  else
    print("Turned " .. label .. " off")
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

local COMMANDS = {
  ["prices"] = CraftInfoAnywhere.SlashCmd.TogglePrices,
  ["p"] = CraftInfoAnywhere.SlashCmd.TogglePrices,
  ["made"] = CraftInfoAnywhere.SlashCmd.ToggleMade,
  ["makes"] = CraftInfoAnywhere.SlashCmd.ToggleMade,
  ["m"] = CraftInfoAnywhere.SlashCmd.ToggleMade,
  ["reagents"] = CraftInfoAnywhere.SlashCmd.ToggleReagents,
  ["r"] = CraftInfoAnywhere.SlashCmd.ToggleReagents,
}

function CraftInfoAnywhere.SlashCmd.Handler(input)
  if COMMANDS[input] ~= nil then
    COMMANDS[input]()
  else
    print("Unknown command '" .. input .. "'")
  end
end

SlashCmdList["CraftInfoAnywhere"] = CraftInfoAnywhere.SlashCmd.Handler
SLASH_CraftInfoAnywhere1 = "/craftinfoanywhere"
SLASH_CraftInfoAnywhere2 = "/cia"
