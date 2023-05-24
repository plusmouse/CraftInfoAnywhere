function CraftInfoAnywhere.AddToTooltip(tooltip, data)
  local _, itemLink = TooltipUtil.GetDisplayedItem(tooltip)
  if itemLink == nil then
    return
  end
  local itemLevel = GetDetailedItemLevelInfo(itemLink)
  local itemID = GetItemInfoInstant(itemLink)
  local recipeDetails = CraftInfoAnywhere.Data[itemID]

  if recipeDetails then 
    --tooltip:AddDoubleLine("Basic Craft Cost", GetMoneyString(GetCost(recipeDetails.reagents)), nil, nil, nil, 1, 1, 1)
    local details = {}
    for _, rData in ipairs(recipeDetails.reagents) do
      local name = GetItemInfo(rData.items[1])
      if name ~= nil then
        table.insert(details, {name = name, quantity = rData.quantity})
      else
        table.insert(details, {name = "Pending...", quantity = rData.quantity})
      end
    end
    table.sort(details, function(a, b) return a.name < b.name end)
    for _, nameAndQuantity in ipairs(details) do
      tooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(nameAndQuantity.name) .. BLUE_FONT_COLOR:WrapTextInColorCode(" x" .. nameAndQuantity.quantity))
    end
  end
end

local function OnTooltipSetItem(tooltip, data)
  if tooltip ~= GameTooltip then
    return
  end

  CraftInfoAnywhere.AddToTooltip(tooltip, data)
end
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
