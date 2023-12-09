CraftInfoAnywhere.API = {}

function CraftInfoAnywhere.API.GetRecipeReagents(recipeID)
  local data = CraftInfoAnywhere.Data.Recipes[recipeID]
  if data then
    return CopyTable(data)
  end
end

function CraftInfoAnywhere.API.GetRecipesForItem(itemID)
  local data = CraftInfoAnywhere.Data.ItemsToRecipes[itemID]
  if data then
    return CopyTable(data)
  end
end
