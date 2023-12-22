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
    local price = Auctionator.API.v1.GetVendorPriceByItemID("Craft Info Anywhere", entry.itemID) or Auctionator.API.v1.GetAuctionPriceByItemID("Craft Info Anywhere", entry.itemID)
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

  local possibleRecipes = CraftInfoAnywhere.Data.ItemsToRecipes[itemID]
  if possibleRecipes ~= nil then
    local recipeDetails = CraftInfoAnywhere.Data.Recipes[possibleRecipes[#possibleRecipes]]

    if recipeDetails then
      if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.PROFESSION) then
        local spellID = CraftInfoAnywhere.Data.SkillLinesToSpells[recipeDetails.skillLine]
        if spellID ~= nil then
          local name = GetSpellInfo(spellID) or CraftInfoAnywhere.Locales.PENDING_ELLIPSE
          tooltip:AddLine(CraftInfoAnywhere.Locales.PROFESSION_X:format(WHITE_FONT_COLOR:WrapTextInColorCode(name)))
        end
      end

      local details = {}
      local setEnchantVellum = false
      for _, rData in ipairs(recipeDetails.reagents) do
        local name = GetItemInfo(rData.items[1])
        table.insert(details, {name = name or CraftInfoAnywhere.Locales.PENDING_ELLIPSE, quantity = rData.quantity, itemID = rData.items[1]})
      end
      if Auctionator and Auctionator.CraftingInfo.EnchantSpellsToItemData then
        local spellData = Auctionator.CraftingInfo.EnchantSpellsToItemData[recipeDetails.spell]
        if spellData then
          local vellumID = GetVellum(spellData)
          if vellumID ~= nil then
            local name = GetItemInfo(vellumID)
            table.insert(details, {name = name or CraftInfoAnywhere.Locales.PENDING_ELLIPSE, quantity = 1, itemID = vellumID})
            setEnchantVellum = true
          end
        end
      end

      table.sort(details, function(a, b) return a.name < b.name end)
      if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.REAGENTS) then
        tooltip:AddLine(CraftInfoAnywhere.Locales.REAGENTS_REQUIRED_COLON)
        for _, nameAndQuantity in ipairs(details) do
          tooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(nameAndQuantity.name) .. BLUE_FONT_COLOR:WrapTextInColorCode(" x" .. nameAndQuantity.quantity))
        end
      end

      if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.MADE_COUNT) then
        if setEnchantVellum then
          tooltip:AddDoubleLine(CraftInfoAnywhere.Locales.MAKES_COLON_X:format(WHITE_FONT_COLOR:WrapTextInColorCode(1)))
        else
          tooltip:AddDoubleLine(CraftInfoAnywhere.Locales.MAKES_COLON_X:format( WHITE_FONT_COLOR:WrapTextInColorCode(recipeDetails.quantity)))
        end
      end

      if CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.PRICES) then
        if Auctionator and Auctionator.API then
          tooltip:AddDoubleLine(CraftInfoAnywhere.Locales.REAGENTS_VALUE_COLON_X:format(WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetCraftCost(details)), true)))
        end
      end
    end
  end

  local itemsForReagents = CraftInfoAnywhere.Data.ReagentsToItems[itemID] or {}
  local spellsForReagents = CraftInfoAnywhere.Data.ReagentsToSpells[itemID] or {}

  if #itemsForReagents + #spellsForReagents > 0 and CraftInfoAnywhere.Config.Get(CraftInfoAnywhere.Config.Options.REAGENTS_TO_ITEMS) then
    tooltip:AddLine(CraftInfoAnywhere.Locales.USED_IN_CRAFTING_COLON)
    local details = {}
    for _, item_id in ipairs(itemsForReagents) do
      local name = GetItemInfo(item_id)
      if name ~= nil then
        table.insert(details, name)
      else
        table.insert(details, CraftInfoAnywhere.Locales.PENDING_ELLIPSE)
      end
    end
    for _, spell_id in ipairs(spellsForReagents) do
      local name = GetSpellInfo(spell_id)
      if name ~= nil then
        table.insert(details, name)
      else
        table.insert(details, CraftInfoAnywhere.Locales.PENDING_ELLIPSE)
      end
    end
    table.sort(details)
    for _, name in ipairs(details) do
      tooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(name))
    end
  end
end

GameTooltip:HookScript("OnTooltipSetItem", ShowInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowInfo)
