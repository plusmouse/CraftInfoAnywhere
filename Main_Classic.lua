local function ShowInfo(tooltip)
  local _, itemLink = tooltip:GetItem()
  if itemLink == nil then
    return
  end
  local itemID = GetItemInfoInstant(itemLink)

  local recipeDetails = CraftInfoAnywhere.Data[itemID]

  if recipeDetails then 
    --tooltip:AddDoubleLine("Basic Craft Cost", GetMoneyString(GetCost(recipeDetails.reagents)), nil, nil, nil, 1, 1, 1)
    tooltip:AddLine("Reagents Required:")
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
    tooltip:AddDoubleLine("Makes:", WHITE_FONT_COLOR:WrapTextInColorCode(recipeDetails.quantity))
  end
end

GameTooltip:HookScript("OnTooltipSetItem", ShowInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowInfo)
