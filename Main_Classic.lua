local function GetVellum(data)
  local vellumForClass = Auctionator.CraftingInfo.EnchantVellums[data.itemClass]
  if vellumForClass == nil then
    return nil
  end

  -- Find the cheapest vellum that will work
  local vellumCost
  local anyMatch = false
  for vellumItemID, vellumLevel in pairs(vellumForClass) do
    if data.level <= vellumLevel then
      return vellumItemID
    end
  end
end

local function GetCraftCost(details)
  local total = 0
  for _, entry in ipairs(details) do
    local price = Auctionator.API.v1.GetAuctionPriceByItemID("Craft Info Anywhere", entry.itemID)
    if price then
      total = total + price * entry.quantity
    end
  end
  return total
end

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
    local setEnchantVellum = false
    for _, rData in ipairs(recipeDetails.reagents) do
      local name = GetItemInfo(rData.items[1])
      if name ~= nil then
        table.insert(details, {name = name, quantity = rData.quantity, itemID = rData.items[1]})
      else
        table.insert(details, {name = "Pending...", quantity = rData.quantity, itemID = rData.items[1]})
      end
    end
    if Auctionator and Auctionator.CraftingInfo.EnchantSpellsToItemData then
      local spellData = Auctionator.CraftingInfo.EnchantSpellsToItemData[recipeDetails.spell]
      if spellData then
        local vellumID = GetVellum(spellData)
        if vellumID ~= nil then
          table.insert(details, {name = GetItemInfo(vellumID) or "", quantity = 1, itemID = vellumID})
          setEnchantVellum = true
        end
      end
    end
    table.sort(details, function(a, b) return a.name < b.name end)
    for _, nameAndQuantity in ipairs(details) do
      tooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(nameAndQuantity.name) .. BLUE_FONT_COLOR:WrapTextInColorCode(" x" .. nameAndQuantity.quantity))
    end
    if setEnchantVellum then
      tooltip:AddDoubleLine("Makes:", WHITE_FONT_COLOR:WrapTextInColorCode(1))
    else
      tooltip:AddDoubleLine("Makes:", WHITE_FONT_COLOR:WrapTextInColorCode(recipeDetails.quantity))
    end
    if Auctionator and Auctionator.API then
      tooltip:AddDoubleLine("Reagents Value:", WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetCraftCost(details)), true))
    end
  end
end

GameTooltip:HookScript("OnTooltipSetItem", ShowInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowInfo)
