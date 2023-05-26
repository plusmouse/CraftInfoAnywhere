-- Get vendor or auction cost of an item depending on which is available
local function GetCostByItemID(itemID, multiplier)
  local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)
  local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemID)

  local unitPrice = vendorPrice or auctionPrice

  if unitPrice ~= nil then
    return multiplier * unitPrice
  end
  return 0
end

local function GetByMinCostOption(reagents, multiplier)
  local min = 0
  for _, itemID in ipairs(reagents) do
    if itemID ~= nil then
      local newValue = GetCostByItemID(itemID, multiplier)
      if newValue ~= 0 and (min == 0 or newValue < min) then
        min = newValue
      end
    end
  end
  return min
end

local function GetCraftCost(reagents)
  local total = 0
  for _, r in ipairs(reagents) do
    total = total + GetByMinCostOption(r.items, r.quantity)
  end
  return total
end

local function ShowInfo(tooltip)
  local _, itemLink = TooltipUtil.GetDisplayedItem(tooltip)
  if itemLink == nil then
    return
  end
  local itemLevel = GetDetailedItemLevelInfo(itemLink)
  local itemID = GetItemInfoInstant(itemLink)
  local recipeDetails = CraftInfoAnywhere.Data[itemID]

  if recipeDetails then 
    if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.REAGENTS) then
      tooltip:AddLine(CraftInfoAnywhere.Locales.REAGENTS_REQUIRED_COLON)
      local details = {}
      for _, rData in ipairs(recipeDetails.reagents) do
        local name = GetItemInfo(rData.items[1])
        if name ~= nil then
          table.insert(details, {name = name, quantity = rData.quantity})
        else
          table.insert(details, {name = CraftInfoAnywhere.Locales.PENDING_ELLIPSE, quantity = rData.quantity})
        end
      end
      table.sort(details, function(a, b) return a.name < b.name end)
      for _, nameAndQuantity in ipairs(details) do
        tooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(nameAndQuantity.name) .. BLUE_FONT_COLOR:WrapTextInColorCode(" x" .. nameAndQuantity.quantity))
      end
    end
    if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.MADE_COUNT) then
      tooltip:AddDoubleLine(CraftInfoAnywhere.Locales.MAKES_COLON_X:format(WHITE_FONT_COLOR:WrapTextInColorCode(recipeDetails.quantity)))
    end
    if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.PRICES) then
      if Auctionator and Auctionator.API then
        tooltip:AddDoubleLine(CraftInfoAnywhere.Locales.REAGENTS_VALUE_COLON_X:format(WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetCraftCost(recipeDetails.reagents)), true)))
      end
    end
  end
end

local function OnTooltipSetItem(tooltip, data)
  if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then
    return
  end

  ShowInfo(tooltip)
end
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
